/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 * Copyright (c) 2011 Samuel J. Grabski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import "CCTouchDispatcher.h"
#import "CCTouchHandler.h"
#include <stdlib.h> // qsort

/**   @since v1.1.0 */
@interface CCHandlersToDo : NSObject // treat as private
{
@private
    ccHandlersToDoType type_;
    CCTouchHandler *handler_;
    int arg_;
}

@property(nonatomic,readwrite,assign) ccHandlersToDoType type;
@property(nonatomic,readwrite,retain) CCTouchHandler *handler;
@property(nonatomic,readwrite,assign) int arg;

@end

static BOOL	reversePriority;			// default is NO;

static NSComparisonResult sortByPriority(const void * first, const void * second);
static BOOL eval(int v, ccOperators op, int arg);
static ccOperators calcOp1(ccOperators compOp);
static BOOL isItAnd(ccOperators compOp);
static ccOperators calcOp3(ccOperators compOp);
static BOOL evaluate(int v, ccOperators op1, int v1, BOOL useAnd, ccOperators op3, int v2);

@implementation CCTouchDispatcher

@synthesize dispatchEvents;

#define CC_SEARCH_NOT_SUCCESSFUL	NSNotFound

static CCTouchDispatcher *sharedDispatcher = nil;

+(CCTouchDispatcher*) sharedDispatcher
{
	@synchronized(self) {
		if (sharedDispatcher == nil)
			sharedDispatcher = [[self alloc] init]; // assignment not done here
	}
	return sharedDispatcher;
}

+(id) allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		NSAssert(sharedDispatcher == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super allocWithZone:zone];
	}
	return nil; // on subsequent allocation attempts return nil
}

-(id) init
{
	if((self = [super init])) {

		locked = NO;
		dispatchEvents = YES;
		int capacity = 30;

		targetedHandlers = [[CCArray alloc] initWithCapacity:capacity];
		standardHandlers = [[CCArray alloc] initWithCapacity:capacity];
		handlersToDo = [[CCArray alloc] initWithCapacity:capacity];

		actionToDo.targetedRemoval = actionToDo.standardRemoval = 0;
		actionToDo.processStandardHandlersFirstFlag = NO;
		actionToDo.processStandardHandlersFirstArg = processStandardHandlersFirst = NO;
		actionToDo.sortingAlgorithmFlag = NO;
		actionToDo.sortingAlgorithmArg = sortingAlgorithm = kCCAlgInsertionSort;
		actionToDo.reversePriorityFlag = actionToDo.reversePriorityArg = reversePriority = NO;
		actionToDo.usersComparatorFlag = NO;
		actionToDo.usersComparatorArg = usersComparator = NULL;
		actionToDo.targetedPriority = actionToDo.standardPriority = 0;
		actionToDo.targetedDebugLogFlag = actionToDo.standardDebugLogFlag = NO;
		actionToDo.targetedDebugLogArg = actionToDo.standardDebugLogArg = 0;

		handlerHelperData[kCCTouchBegan] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesBegan:withEvent:),@selector(ccTouchBegan:withEvent:),kCCTouchSelectorBeganBit};
		handlerHelperData[kCCTouchMoved] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesMoved:withEvent:),@selector(ccTouchMoved:withEvent:),kCCTouchSelectorMovedBit};
		handlerHelperData[kCCTouchEnded] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesEnded:withEvent:),@selector(ccTouchEnded:withEvent:),kCCTouchSelectorEndedBit};
		handlerHelperData[kCCTouchCancelled] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesCancelled:withEvent:),@selector(ccTouchCancelled:withEvent:),kCCTouchSelectorCancelledBit};
	}

	return self;
}

-(void) dealloc
{
   	CCLOGINFO( @"cocos2d: deallocing %@", self);

	[targetedHandlers release];
	[standardHandlers release];
	[handlersToDo release];

    sharedDispatcher = nil;

	[super dealloc];
}

//
// handlers management
//

#pragma mark -
#pragma mark - Changing priority of the added handlers

static NSComparisonResult sortByPriority(const void * first, const void * second)
{
    id fId = ((id *) first)[0];  // Lord, Have Mercy on Us!
    id sId = ((id *) second)[0]; // Amen.

	CCTouchHandler *f = (CCTouchHandler*) fId;
	CCTouchHandler *s = (CCTouchHandler*) sId;

	int fP = f.priority;
	int sP = s.priority;

	if (fP == sP) return NSOrderedSame;

	if (reversePriority){
		if (fP > sP)	// if p1 > p2 > p3   order:  p1,p2,p3
			return NSOrderedAscending;
		else
			return NSOrderedDescending;
	}
	else{ // default
		if (fP < sP)   // if p1 < p2 < p3   order:  p1,p2,p3
			return NSOrderedAscending;
		else
			return NSOrderedDescending;
	}
}

-(void) rearrangeHandlers:(CCArray *)array
{
	if ( usersComparator ){
		switch (sortingAlgorithm) {
			default:
			case kCCAlgInsertionSort:
				[array insertionSortUsingCFuncComparator:usersComparator];
			case kCCAlgQSort:
				[array qsortUsingCFuncComparator:usersComparator];
				break;
			case kCCAlgMergeLSort:
				[array mergesortLUsingCFuncComparator:usersComparator];
				break;
			case kCCDoNotSort:
				break;
		}
	}
	else{
		switch (sortingAlgorithm) {
			default:
			case kCCAlgInsertionSort:
				[array insertionSortUsingCFuncComparator:sortByPriority];
				break;
			case kCCAlgQSort:
				[array qsortUsingCFuncComparator:sortByPriority];
				break;
			case kCCAlgMergeLSort:
				[array mergesortLUsingCFuncComparator:sortByPriority];
				break;
			case kCCDoNotSort:
				break;
		}
	}
}

- (void) forceSetPriority
{
	if (actionToDo.targetedPriority){
		[self rearrangeHandlers:targetedHandlers];
		actionToDo.targetedPriority = 0;
	}
	if (actionToDo.standardPriority){
		[self rearrangeHandlers:standardHandlers];
		actionToDo.standardPriority = 0;
	}
}

#pragma mark TouchDispatcher - arrayForType

-(CCArray *) arrayForType:(ccDispatcherDelegateType)delegateType
{
	CCArray *array;

	switch (delegateType){
		default:
		case kCCTargeted:
			array = targetedHandlers;
			break;
		case kCCStandard:
			array = standardHandlers;
			break;
	}
	return array;
}
//-----------------------------------------------------------

//  removes all delegates of the given type
-(int) forceRemoveAllObjects:(ccDispatcherDelegateType) delegateType
{
	CCArray *array = [self arrayForType:delegateType];
	int numberOfObjectsRemoved = [array count];

	[array removeAllObjects];

	return numberOfObjectsRemoved;
}

#pragma mark TouchDispatcher - removeAllDelegates

-(int) removeAllDelegates:(ccDispatcherDelegateType) type
{
	if ( locked ) {
		return ( [self removeDelegatesWithField:kCCNotRemoved arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE delay:YES type:type] );
	}
	else {
		return ( [self forceRemoveAllObjects:type] );
	}
}

#pragma mark TouchDispatcher  - removeAllDelegates

-(void) removeAllDelegates // since: v0.8.0
{
	[self removeAllDelegates:kCCTargeted];
	[self removeAllDelegates:kCCStandard];
}

#pragma mark TouchDispatcher - forceRemoveOfMarkedHandlers

-(void) forceRemoveOfMarkedHandlers:(ccDispatcherDelegateType)delegateType nrOfObjects:(int)nrOfObjects
{   // fast removal in one pass
	int counter = 0;
	CCTouchHandler *handler;

	CCArray *array = [self arrayForType:delegateType];
	ccArray *arrayData = array->data;

	for (int i = arrayData->num - 1; i>=0; --i) {

		handler = arrayData->arr[i]; // get handler

		if (handler.remove){

			ccArrayRemoveObjectAtIndex(arrayData,i); // remove it

			//--- this works well if there is more smaller removals than the big ones
			counter++;
			if (counter >= nrOfObjects)
				break;
			//---
		}
	}
}

#pragma mark TouchDispatcher  - forceRemoveMarkedDelegates

-(void) forceRemoveMarkedDelegates
{
	if ( actionToDo.targetedRemoval ) {
		[self forceRemoveOfMarkedHandlers:kCCTargeted nrOfObjects:actionToDo.targetedRemoval];
		actionToDo.targetedRemoval = 0;
	}

	if ( actionToDo.standardRemoval ) {
		[self forceRemoveOfMarkedHandlers:kCCStandard nrOfObjects:actionToDo.standardRemoval];
		actionToDo.standardRemoval = 0;
	}
}
//---
#pragma mark TouchDispatcher - toDoAddType

-(ccHandlersToDoType) toDoAddType:(ccDispatcherDelegateType)type
{
    ccHandlersToDoType toDo;
 	switch(type) {
		default:
		case kCCTargeted:
			toDo = kCCAddTargetedHandler;
			break;
		case kCCStandard:
			toDo = kCCAddStandardHandler;
			break;
	}
	return toDo;
}

-(void) debugLog:(ccDispatcherDelegateType)delegateType nr:(int)nr handler:(CCTouchHandler *) h formatType:(int)format
{
	switch (delegateType) {

        case kCCTargeted:
            switch (format){
                case 1:
                    CCLOG(@"N%3d Targ  priority%4d tag%4d dis%2d rem%2d swallow%2d enabledSelectors %02X handlersFirst%d revPrio%d sortAlgo%d usersComp%p del %@",
                          nr, h.priority, h.tag, h.disable, h.remove, ((CCTargetedTouchHandler*)h).swallowsTouches,
                          ((CCTargetedTouchHandler*)h).enabledSelectors,
                          processStandardHandlersFirst, reversePriority, sortingAlgorithm, usersComparator,
                          h.delegate);
                    break;
                default:
                case 0:
                    CCLOG(@"N%3d Targ priority%4d tag%4d dis%2d rem%2d swallow%2d enabledSelectors %02X handlersFirst%d revPrio%d sortAlgo%d usersComp%p",
                          nr, h.priority, h.tag, h.disable, h.remove,((CCTargetedTouchHandler*)h).swallowsTouches,
                          ((CCTargetedTouchHandler*)h).enabledSelectors,
                          processStandardHandlersFirst, reversePriority, sortingAlgorithm, usersComparator);
                    break;
            }
            break;

        case kCCStandard:
            switch (format){
                case 1:
                    CCLOG(@"N%3d Stnd pri%4d tag%4d dis%2d rem%2d handlersFirst%d revPrio%d sortAlgo%d usersComp%p del %@",
                          nr, h.priority, h.tag, h.disable, h.remove,
                          processStandardHandlersFirst, reversePriority, sortingAlgorithm, usersComparator,
                          h.delegate);
                    break;
                default:
                case 0:
                    CCLOG(@"N%3d Stnd pri%4d tag%4d dis%2d rem%2d handlersFirst%d revPrio%d sortAlgo%d usersComp%p",
                          nr, h.priority, h.tag, h.disable, h.remove,
                          processStandardHandlersFirst, reversePriority, sortingAlgorithm, usersComparator);
                    break;
            }
            break;
	} // switch (delegateType)
}

-(void) debugLog:(ccHandlersToDoType)type nr:(int)cnr handlerToDo:(CCHandlersToDo *)h formatType:(int)format
{
	switch (type) {

        case kCCAddTargetedHandler:
            switch (format) {
                case 1:
                    CCLOG(@"C%3d Trg pri%4d tag%4d dis%2d rem%2d swl%2d eS %02X hF%d rP%d sA%d uC%p %@",
                          cnr, h.handler.priority, h.handler.tag, h.handler.disable, h.handler.remove,
                          ((CCTargetedTouchHandler *) h.handler).swallowsTouches,
                          ((CCTargetedTouchHandler *) h.handler).enabledSelectors,
                          processStandardHandlersFirst,reversePriority, sortingAlgorithm, usersComparator,
                          h.handler.delegate);
                    break;
                default:
                case 0:
                    CCLOG(@"C%3d Trg pri%4d tag%4d dis%2d rem%2d swl%2d eS %02X hF%d rP%d sA%d uC%p",
                          cnr, h.handler.priority, h.handler.tag, h.handler.disable, h.handler.remove,
                          ((CCTargetedTouchHandler *) h.handler).swallowsTouches,
                          ((CCTargetedTouchHandler *) h.handler).enabledSelectors,
                          processStandardHandlersFirst, reversePriority, sortingAlgorithm, usersComparator);
                    break;
            }
            break;

        case kCCAddStandardHandler:
            switch (format) {
                case 1:
                    CCLOG(@"C%3d Stn pri%4d tag%4d dis%2d rem%2d             hF%d rP%d sA%d uC%p %@",
                          cnr, h.handler.priority, h.handler.tag, h.handler.disable, h.handler.remove,
                          processStandardHandlersFirst, reversePriority, sortingAlgorithm, usersComparator,
                          h.handler.delegate);
                    break;
                default:
                case 0:
                    CCLOG(@"C%3d Stn pri%4d tag%4d dis%2d rem%2d             hF%d rP%d sA%d uC%p",
                          cnr, h.handler.priority, h.handler.tag, h.handler.disable, h.handler.remove,
                          processStandardHandlersFirst, reversePriority, sortingAlgorithm, usersComparator);
                    break;
            }
            break;
	} //switch (type)
}

#pragma mark -
#pragma mark - alterTouchHandler

-(void)	fieldToAlter:(ccHandlerFieldName)fieldToAlter withValue:(int)v forHandler:(CCTouchHandler *)h type:(ccDispatcherDelegateType)delegateType action:(int *)a
{
	switch ( fieldToAlter ) {
		case kCCDelegate:
			break;
		case kCCPriority:
		case kCCPriorityToDo:
			if ( h.priority != v ){
				if (!h.remove) { // otherwise no need it is gone soon
					h.priority = v;
					(*a)++;
				}
			}
			break;
		case kCCTag:
			h.tag = v;
			(*a)++;;
			break;
		case kCCDisable:
			h.disable = v;
			(*a)++;
			break;
		case kCCRemove:
		case kCCRemoveToDo:
			if (!h.remove) {  // one way only, no undo of course
				if (v) {
					h.remove = YES;
					(*a)++;
				}
			}
			break;
		case kCCSwallowsTouches:
			if(delegateType == kCCTargeted){
				((CCTargetedTouchHandler *) h).swallowsTouches = (BOOL)(v!=0);
				(*a)++;
			}
			break;
		case kCCNotRemoved:
			if (!h.remove)
				(*a)++;
			break;
		case kCCNone: // just counting all objects
			(*a)++;
			break;
		case kCCDebug:
			(*a)++;
			[self debugLog:delegateType nr:(*a) handler:h formatType:v];
			break;
	}
}

-(void)	fieldToAlter:(ccHandlerFieldName)fieldToAlter withValue:(int)v forToDoHandler:(CCHandlersToDo *)hToDo action:(int *)c
{
	switch ( fieldToAlter ){
		case kCCDelegate:
			break;
		case kCCPriority:
		case kCCPriorityToDo:
			if (hToDo.handler.priority != v ){
				if (!hToDo.handler.remove){
					hToDo.handler.priority = v;
					(*c)++;
				}
			}
			break;
		case kCCTag:
			hToDo.handler.tag = v;
			(*c)++;
			break;
		case kCCDisable:
			hToDo.handler.disable = v;
			(*c)++;
			break;
		case kCCRemove:
		case kCCRemoveToDo:
			if (!hToDo.handler.remove) {
				if ( v ) {	// one way only, no undo of course
					hToDo.handler.remove = YES;
					(*c)++;
				}
			}
			break;
		case kCCSwallowsTouches:
			if (hToDo.type == kCCAddTargetedHandler) {
				((CCTargetedTouchHandler *) hToDo.handler).swallowsTouches = (BOOL)(v!=0);
				(*c)++;
			}
			break;
		case kCCNotRemoved:
			if (!hToDo.handler.remove)
				(*c)++;
			break;
		case kCCNone: // counting all objects
			(*c)++;
			break;
		case kCCDebug:
			(*c)++;
			[self debugLog:hToDo.type nr:(*c) handlerToDo:hToDo formatType:v];
			break;
	}
}

- (void) sortDelegates:(ccDispatcherDelegateType)type; // API
{
	switch(type){
		case kCCTargeted: actionToDo.targetedPriority = YES; break;
		case kCCStandard: actionToDo.standardPriority = YES; break;
	}

	if (!locked) { // sorting can be done now  (if not it will be done in the 'processCallbackRequestsToTheDispatcher'
		[self forceSetPriority];} // priority flags are cleared here
}

- (int) removeToDoDelegates:(ccDispatcherDelegateType)type; // API
{
	int ret = -1;

	if (!locked) { // removal can be done now (if not it will be done in the 'processCallbackRequestsToTheDispatcher'

		switch ( type ) {
			case kCCTargeted:
				ret = actionToDo.targetedRemoval;
				[self forceRemoveOfMarkedHandlers:kCCTargeted nrOfObjects:actionToDo.targetedRemoval];
				actionToDo.targetedRemoval = 0;  // removal flags are cleared here
                break;
			case kCCStandard:
				ret = actionToDo.standardRemoval;
				[self forceRemoveOfMarkedHandlers:kCCStandard nrOfObjects:actionToDo.standardRemoval];
				actionToDo.standardRemoval = 0;	// removal flags are cleared here
                break;
		}
	}

	return ret;
}

-(void) actionProcessing:(ccHandlerFieldName)fieldToAlter type:(ccDispatcherDelegateType)delegateType action:(int)action
{
	switch(fieldToAlter)
	{
		case kCCDelegate:
			break;
		case kCCPriority:
			if (action) {
				[self sortDelegates:delegateType];
			}
			break;
		case kCCPriorityToDo:
			if (action) {
				switch( delegateType ){
					case kCCTargeted: actionToDo.targetedPriority = YES; break;
					case kCCStandard: actionToDo.standardPriority = YES; break;
				}
			}// sort will be done at the end of all callbacks or when 'sortDelegates' is issued
			break;
		case kCCTag:
			break;
		case kCCDisable:
			break;
		case kCCRemove:
			if (action) {
				switch ( delegateType ) {
					case kCCTargeted: actionToDo.targetedRemoval += action; break; // accumulate number of removals
					case kCCStandard: actionToDo.standardRemoval += action; break; // accumulate number of removals
				}
				if (!locked) { //removal can be done now; no accumulation from other remove calls
					[self removeToDoDelegates:delegateType];	// removal flags are cleared here
				}
			}
			break;
		case kCCRemoveToDo:
			if (action) {
				switch ( delegateType ) {
					case kCCTargeted: actionToDo.targetedRemoval += action; break; // accumulate number of removals
					case kCCStandard: actionToDo.standardRemoval += action; break; // accumulate number of removals
				}
			} // removal will be done at the end of all callbacks or
			break;
		case kCCSwallowsTouches:
			break;
		case kCCNotRemoved:
			break;
		case kCCNone:
			break;
		case kCCDebug:
			break;
	}
}

static BOOL eval(int v, ccOperators op, int arg)
{
	switch(op){
		case kCCFALSE: return NO;	 break;
		case kCCTRUE:  return YES; break;
		case kCCNEQ: return (v != arg); break;
		case kCCEQ:  return (v == arg); break;
		case kCCGE:  return (v >= arg); break;
		case kCCGT:  return (v >  arg); break;
		case kCCLE:  return (v <= arg); break;
		case kCCLT:  return (v <  arg); break;
		default: return NO;	break;
	}
}

static ccOperators calcOp1(ccOperators compOp)
{
	switch(compOp){ // fast parsing does not depend on the order of 'ccOperators'
		case kCCFALSE:case kCCTRUE:case kCCNEQ:case kCCEQ:case kCCGE:case kCCGT:case kCCLE:case kCCLT:return compOp;break;
		case kCCGEAndLE:case kCCGEAndLT:case kCCGEOrLE:case kCCGEOrLT:return kCCGE;break;
		case kCCGTAndLE:case kCCGTAndLT:case kCCGTOrLE:case kCCGTOrLT:return kCCGT;break;
		case kCCLEAndGE:case kCCLEAndGT:case kCCLEOrGE:case kCCLEOrGT:return kCCLE;break;
		case kCCLTAndGE:case kCCLTAndGT:case kCCLTOrGE:case kCCLTOrGT:return kCCLT;break;
		default: return kCCFALSE; break;
	}
}

static BOOL isItAnd(ccOperators compOp)
{
	switch(compOp){ // fast parsing does not depend on the order of 'ccOperators'
		case kCCFALSE:case kCCTRUE:case kCCNEQ:case kCCEQ:case kCCGE:case kCCGT:case kCCLE:case kCCLT:return NO;break;
		case kCCGEAndLE:case kCCGEAndLT:case kCCGTAndLE:case kCCGTAndLT:
		case kCCLEAndGE:case kCCLEAndGT:case kCCLTAndGE:case kCCLTAndGT:return YES;break;
		case kCCGEOrLE:case kCCGEOrLT:case kCCGTOrLE:case kCCGTOrLT:
		case kCCLEOrGE:case kCCLEOrGT:case kCCLTOrGE:case kCCLTOrGT:return NO;break;
		default:return NO;break;
	}
}

static ccOperators calcOp3(ccOperators compOp)
{
	switch(compOp){ // fast parsing does not depend on the order of 'ccOperators'
		case kCCFALSE:case kCCTRUE:case kCCNEQ:case kCCEQ:case kCCGE:case kCCGT:case kCCLE:case kCCLT:return kCCTRUE;break;
		case kCCLEAndGE:case kCCLTAndGE:case kCCLEOrGE:case kCCLTOrGE:return kCCGE;break;
		case kCCLEAndGT:case kCCLTAndGT:case kCCLEOrGT:case kCCLTOrGT:return kCCGT;break;
		case kCCGEAndLE:case kCCGTAndLE:case kCCGEOrLE:case kCCGTOrLE:return kCCLE;break;
		case kCCGEAndLT:case kCCGTAndLT:case kCCGEOrLT:case kCCGTOrLT:return kCCLT;break;
		default:return kCCTRUE;break;
	}
}

static BOOL evaluate(int v, ccOperators op1, int v1, BOOL useAnd, ccOperators op3, int v2)
{
	BOOL result1 = eval(v,op1,v1);
	if (op3 == kCCTRUE) return result1;

	BOOL result3 = eval(v,op3,v2);
	if (useAnd) return (result1 && result3);
	else return (result1 || result3); // use OR
}

// magic function:
-(int) alterTouchHandler:(ccDispatcherDelegateType)dType delegate:(id)delegate
		   fieldToSearch:(ccHandlerFieldName)searchField
                    arg1:(int)v1
                    arg2:(int)v2
				operator:(ccOperators)op
			fieldToAlter:(ccHandlerFieldName)fieldToAlter withValue:(int)nV
{
	int action = 0; // number of objects affected

	if ( (searchField == kCCDelegate) && (delegate == nil) ) {
		return -1; // NSAssert(delegate != nil, @"Got nil touch delegate!");
	}

	ccOperators op1 = calcOp1(op);
	BOOL useAnd = isItAnd(op); // if false use OR operator
	ccOperators op3 = calcOp3(op);

	CCArray *array = [self arrayForType:dType]; // array for given handler's type
	ccHandlersToDoType hToDoType = [self toDoAddType:dType];

	CCTouchHandler *h;
	CCARRAY_FOREACH(array, h) {
		switch(searchField) {
			case kCCDelegate:
				if( h.delegate == delegate ) {
					[self fieldToAlter:fieldToAlter withValue:nV forHandler:h type:dType action:&action];
					break; // delegate has been found
				}
				break;
			case kCCPriority:
			case kCCPriorityToDo:
				if ( evaluate(h.priority, op1, v1, useAnd, op3, v2) ) {
					[self fieldToAlter:fieldToAlter withValue:nV forHandler:h type:dType action:&action];
				}
				break;
			case kCCTag:
				if ( evaluate(h.tag, op1, v1, useAnd, op3, v2) ) {
					[self fieldToAlter:fieldToAlter withValue:nV forHandler:h type:dType action:&action];
				}
				break;
			case kCCDisable:
				if ( evaluate(h.disable, op1, v1, useAnd, op3, v2) ) {
					[self fieldToAlter:fieldToAlter withValue:nV forHandler:h type:dType action:&action];
				}
				break;
			case kCCRemove:
			case kCCRemoveToDo:
				if ( evaluate(h.remove, op1, v1, useAnd, op3, v2) ) {
					[self fieldToAlter:fieldToAlter withValue:nV forHandler:h type:dType action:&action];
				}
				break;
			case kCCSwallowsTouches:
				if ( dType == kCCTargeted ) {
					if ( evaluate( ((CCTargetedTouchHandler*)h).swallowsTouches, op1, v1, useAnd, op3, v2) ) {
						[self fieldToAlter:fieldToAlter withValue:nV forHandler:h type:dType action:&action];
					}
				}
				break;
			case kCCNotRemoved:
				if (!h.remove)
					[self fieldToAlter:fieldToAlter withValue:nV forHandler:h type:dType action:&action];
				break;
			case kCCNone: // for any value (for all value) no conditions checked
				[self fieldToAlter:fieldToAlter withValue:nV forHandler:h type:dType action:&action];
				break;
			case kCCDebug:
				action++; [self debugLog:dType nr:action handler:h formatType:nV];
				break;
			default:
				CCLOG(@"alterTouchHandler:You must be kidding!");
				break;

		}// search
	}//ccarray

	// handlersToDo array should be empty if we are NOT 'locked'
	int callback = 0;	// number of object affected in the callback ToDo array
	CCHandlersToDo *hToDo;
	CCARRAY_FOREACH(handlersToDo, hToDo) {
		if ( hToDo.type != hToDoType )  //   kCCAddTargetedHandler, kCCAddStandardHandler
			continue;
		switch(searchField) {
			case kCCDelegate:
				if( hToDo.handler.delegate == delegate ) {
					[self fieldToAlter:fieldToAlter withValue:nV forToDoHandler:hToDo action:&callback];
				}// notice: all delegates are searched
				break;
			case kCCPriority:
			case kCCPriorityToDo:
				if ( evaluate(hToDo.handler.priority, op1, v1, useAnd, op3, v2) ) {
					[self fieldToAlter:fieldToAlter withValue:nV forToDoHandler:hToDo action:&callback];
				}
				break;
			case kCCTag:
				if ( evaluate(hToDo.handler.tag, op1, v1, useAnd, op3, v2) ) {
					[self fieldToAlter:fieldToAlter withValue:nV forToDoHandler:hToDo action:&callback];
				}
				break;
			case kCCDisable:
				if ( evaluate(hToDo.handler.disable, op1, v1, useAnd, op3, v2) ) {
					[self fieldToAlter:fieldToAlter withValue:nV forToDoHandler:hToDo action:&callback];
				}
				break;
			case kCCRemove:
			case kCCRemoveToDo:
				if ( evaluate(hToDo.handler.remove, op1, v1, useAnd, op3, v2) ) {
					[self fieldToAlter:fieldToAlter withValue:nV forToDoHandler:hToDo action:&callback];
				}
				break;
			case kCCSwallowsTouches:
				if ( hToDo.type == kCCAddTargetedHandler ) {
					if ( evaluate(((CCTargetedTouchHandler*)hToDo.handler).swallowsTouches, op1, v1, useAnd, op3, v2) ) {
						[self fieldToAlter:fieldToAlter withValue:nV forToDoHandler:hToDo action:&callback];
					}
				}
				break;
			case kCCNotRemoved:
				if (!hToDo.handler.remove)
					[self fieldToAlter:fieldToAlter withValue:nV forToDoHandler:hToDo action:&callback];
				break;
			case kCCNone: // for any value (for all value) no conditions checked
				[self fieldToAlter:fieldToAlter withValue:nV forToDoHandler:hToDo action:&callback];
				break;
			case kCCDebug:
				callback++; [self debugLog:hToDoType nr:callback handlerToDo:hToDo formatType:nV];
				break;
		} // search
	}//ccarray

	[self actionProcessing:fieldToAlter type:dType action:action];

	return (action + callback);	// number of handlers affected
}

#pragma mark -
#pragma mark - Add Handlers

-(void) forceAddHandler:(CCTouchHandler*)handler doNotSort:(int)doNotSort type:(ccDispatcherDelegateType)delegateType
{
	if (handler.remove) return; // if handler is marked for removal do not add it to the array

	CCArray *array = [self arrayForType:delegateType];

	if ( doNotSort ) {
		NSAssert( [array containsObject:handler] != YES, @"Delegate already added to touch dispatcher!");
		[array addObject:handler];	// add at the end
		return;
	}

	NSUInteger i = 0;
	CCTouchHandler *h;
	CCARRAY_FOREACH(array, h){ // search all array

		if ( usersComparator ) {
			if ( usersComparator( & h, & handler ) == NSOrderedAscending ){
				i++;
			}
		}
		else {
			if (reversePriority) { // Descending order.  Priority list looks like: 10, 5, 1 - 5, - 10, - 20

				if ( h.priority > handler.priority ) {
					i++; // count elements which have greater priority than given one
				}
			}
			else{ // DEFAULT:   Ascending order
				if ( h.priority < handler.priority ) {	// Priority list looks like:  - 20, - 10, -5 ,  1 , 5,  10
					i++; // count elements which have lesser priority than given one
				}
			}
		}

		NSAssert( h.delegate != handler.delegate, @"Delegate already added to touch dispatcher.");
	}

	[array insertObject:handler atIndex:i];	// insert
}

-(void) safelyAddHandler:(CCTouchHandler*)handler doNotSort:(int)yesOrNo type:(ccDispatcherDelegateType)delegateType
{
	ccHandlersToDoType toDoType = [self toDoAddType:delegateType];

	CCHandlersToDo *todo = [[CCHandlersToDo alloc] init]; // autorelease could be used

	todo.type = toDoType;
	todo.handler = handler;
	todo.arg = yesOrNo;

	[handlersToDo addObject:todo];
	[todo release]; todo = nil; // no need when autorelease done
}

-(void) add:(id) handler doNotSort:(int)yesOrNo type:(ccDispatcherDelegateType) delegateType
{
	if (handler == nil )
		return;

	if ( locked ) {
		[self safelyAddHandler:handler doNotSort:yesOrNo type:delegateType]; // safe in to do loop
	}
	else {
		[self forceAddHandler:handler doNotSort:yesOrNo type:delegateType];
	}
}

//----------------------
// adding a delegate
//----------------------

-(void) addStandardDelegate:(id<CCStandardTouchDelegate>) delegate priority:(int)priority tag:(int)aTag disable:(int)yesOrNo doNotSort:(int)YN
{
	[self add:[CCStandardTouchHandler handlerWithDelegate:delegate priority:priority tag:aTag disable:yesOrNo] doNotSort:YN type:kCCStandard];
}

-(void) addStandardDelegate:(id<CCStandardTouchDelegate>) delegate priority:(int)priority
{
	[self addStandardDelegate:(id<CCStandardTouchDelegate>) delegate priority:priority tag:0 disable:NO doNotSort:NO];
}

-(void) addTargetedDelegate:(id<CCTargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches tag:(int)aTag disable:(int)yesOrNo doNotSort:(int)YN
{
	[self add:[CCTargetedTouchHandler handlerWithDelegate:delegate priority:priority swallowsTouches:swallowsTouches tag:aTag disable:yesOrNo] doNotSort:YN type:kCCTargeted];
}

-(void) addTargetedDelegate:(id<CCTargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches
{
	[self addTargetedDelegate:delegate priority:priority swallowsTouches:swallowsTouches tag:0 disable:NO doNotSort:NO];
}

//----------------------------------------------------------------------
// safe touch call-back getters and setters for internal control fields
//----------------------------------------------------------------------
// API - touch callbacks safe

-(BOOL) locked
{
	return locked;
}

- (void) setProcessStandardHandlersFirst:(BOOL)yesOrNo
{
	if (locked){
		actionToDo.processStandardHandlersFirstFlag = YES;
		actionToDo.processStandardHandlersFirstArg = yesOrNo;
	}
	else{
		processStandardHandlersFirst = yesOrNo;
	}
}
/* get - current/requested - order of processing */
- (BOOL) processStandardHandlersFirst
{
	if (locked){
		if (actionToDo.processStandardHandlersFirstFlag){
			return actionToDo.processStandardHandlersFirstArg;
		}
		else{
			return processStandardHandlersFirst;
		}
	}
	return processStandardHandlersFirst;
}
//
- (void) setSortingAlgorithm:(ccSortingAlgorithm)alg
{
	if (locked){
		actionToDo.sortingAlgorithmFlag = YES;
		actionToDo.sortingAlgorithmArg = alg;
	}
	else{
		sortingAlgorithm = alg;
	}
}
/* get - current/requested - sortingAlgorithm */
- (ccSortingAlgorithm) sortingAlgorithm
{
	if (locked){
		if (actionToDo.sortingAlgorithmFlag){
			return actionToDo.sortingAlgorithmArg;
		}
		else{
			return sortingAlgorithm;
		}
	}
	return sortingAlgorithm;
}

- (void) setReversePriority:(BOOL)yesNo
{
	if (locked){
		actionToDo.reversePriorityFlag = YES;
		actionToDo.reversePriorityArg = yesNo;
	}
	else{
		reversePriority = yesNo;
	}
}
/* get - current/requested - reversePriority */
- (BOOL) reversePriority
{ //  it is up to user to call the sort at his convenience
	if (locked){
		if (actionToDo.reversePriorityFlag){
			return actionToDo.reversePriorityArg;
		}
		else{
			return reversePriority;
		}
	}
	return reversePriority;
}

- (void) setUsersComparator:(int(*)(const void *, const void *))comparator;
{ //  it is up to user to call the sort at his convenience
	if (locked){
		actionToDo.usersComparatorFlag = YES;
		actionToDo.usersComparatorArg = comparator;
	}
	else{
		usersComparator = comparator;
	}
}
/* get - current/requested usersComparator */
- (int(*)(const void *, const void *)) usersComparator
{
	if (locked){
		if (actionToDo.usersComparatorFlag){
			return actionToDo.usersComparatorArg;
		}
		else{
			return usersComparator;
		}
	}
	return usersComparator;
}

#pragma mark TouchDispatcher  - retrieveField

// returns value of the field or NSNotFound when delegate does not exist
- (int) retrieveField:(ccHandlerFieldName)field delegate:(id)delegate type:(ccDispatcherDelegateType)delegateType // power function
{
	NSAssert(delegate != nil, @"Got nil touch delegate!");

	BOOL notFound = YES;
	int value = CC_SEARCH_NOT_SUCCESSFUL;

	CCArray *array = [self arrayForType:delegateType];
	ccHandlersToDoType type = [self toDoAddType:delegateType];

	CCTouchHandler *handler;
	CCARRAY_FOREACH(array, handler) {

		if ( handler.delegate == delegate ) {

			notFound = NO;

			switch ( field ) {
				case kCCDelegate:
					value = YES;
					break;
				case kCCPriority:
				case kCCPriorityToDo:
					value = handler.priority;
					break;
				case kCCTag:
					value = handler.tag;
					break;
				case kCCDisable:
					value = handler.disable;
					break;
				case kCCRemove:
				case kCCRemoveToDo:
					value = handler.remove;
                    break;
				case kCCSwallowsTouches:
					if(delegateType == kCCTargeted){
						value = ((CCTargetedTouchHandler *) handler).swallowsTouches;}
                    break;
				default:
                    break;

			}
			break; // break the loop if delegate had been found
		}//if
	}//ccarray

	CCHandlersToDo *handlerToDo;
	CCARRAY_FOREACH(handlersToDo, handlerToDo) {

		if( handlerToDo.handler.delegate == delegate ) {

			if ( handlerToDo.type == type ) {

				notFound = NO;

				switch ( field ){
					case kCCDelegate:
						value = YES;
						break;
					case kCCPriority:
					case kCCPriorityToDo:
						value = handlerToDo.handler.priority;
						break;
					case kCCTag:
						value = handlerToDo.handler.tag;
						break;
					case kCCDisable:
						value = handlerToDo.handler.disable;
						break;
					case kCCRemove:
					case kCCRemoveToDo:
						value = handlerToDo.handler.remove;
                        break;
					case kCCSwallowsTouches:
						if(type == kCCAddTargetedHandler){
							value = ((CCTargetedTouchHandler *) handlerToDo.handler).swallowsTouches;}
                        break;
					default:
                        break;
				}
			}//if
		}//if
	}//ccarray

	if (notFound) CCLOG(@"TouchHandler:delegate not found!");
	return value;
}

//---------------------------------
// counting delegates
//---------------------------------

- (int) countDelegatesUsage:(ccDispatcherDelegateType)type
{
	return ([self alterTouchHandler:type delegate:nil
                      fieldToSearch:kCCNone arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:kCCNotRemoved withValue:CC_UNUSED_ARGUMENT]);
}

-(int) countDelegateUsage:(id)delegate type:(ccDispatcherDelegateType)type
{
	return ([self alterTouchHandler:type delegate:delegate
                      fieldToSearch:kCCDelegate arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:kCCNotRemoved withValue:CC_UNUSED_ARGUMENT]);
}

-(int) countTagUsage:(int)tag type:(ccDispatcherDelegateType)type
{
	return ([self alterTouchHandler:type delegate:nil
                      fieldToSearch:kCCTag arg1:tag arg2:tag operator:kCCEQ fieldToAlter:kCCNotRemoved withValue:CC_UNUSED_ARGUMENT]);
}

- (int) countPriorityUsage:(int)priority type:(ccDispatcherDelegateType)type
{
	return ([self alterTouchHandler:type delegate:nil
                      fieldToSearch:kCCPriority arg1:priority arg2:priority operator:kCCEQ fieldToAlter:kCCNotRemoved withValue:CC_UNUSED_ARGUMENT]);
}

- (int) countDisableUsage:(int)aDisable type:(ccDispatcherDelegateType)type
{
	return ([self alterTouchHandler:type delegate:nil
                      fieldToSearch:kCCDisable arg1:aDisable arg2:aDisable operator:kCCEQ fieldToAlter:kCCNotRemoved withValue:CC_UNUSED_ARGUMENT]);
}

- (int) countFieldUsage:(ccHandlerFieldName)field fieldValue:(int)value type:(ccDispatcherDelegateType)type // power function
{
	return ([self alterTouchHandler:type delegate:nil
                      fieldToSearch:field arg1:value arg2:value operator:kCCEQ fieldToAlter:kCCNotRemoved withValue:CC_UNUSED_ARGUMENT]);
}

//-------------------------------------------------------------------------------
// retrieval of the field value
// Function returns value of the field or NSNotFound when delegate does not exist
// ------------------------------------------------------------------------------

// helper functions based on the generic 'retrieveField' function

-(int) retrievePriorityField:(id)delegate type:(ccDispatcherDelegateType)type
{
	return ( [self retrieveField:kCCPriority delegate:delegate type:type] );
}
// returns value of the field or NSNotFound when delegate does not exist
-(int) retrieveTagField:(id)delegate type:(ccDispatcherDelegateType)type
{
	return ( [self retrieveField:kCCTag delegate:delegate type:type] );
}
// returns value of the field or NSNotFound when delegate does not exist
-(int) retrieveDisableField:(id)delegate type:(ccDispatcherDelegateType)type
{
	return ( [self retrieveField:kCCDisable delegate:delegate type:type] );
}

//--------------------------------
// disabling of the delegate/s
//--------------------------------

#pragma mark -
#pragma mark - disable/enable particular touch delegate or group

- (int) disableDelegate:(id)delegate disable:(int)yesOrNo type:(ccDispatcherDelegateType)type
{
	return ( [self alterTouchHandler:type delegate:delegate fieldToSearch:kCCDelegate
                                arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:kCCDisable withValue:yesOrNo] );
}

-(int) disableAllDelegates:(int)yesOrNo type:(ccDispatcherDelegateType)type
{
	return ( [self alterTouchHandler:type delegate:nil fieldToSearch:kCCNone
                                arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:kCCDisable withValue:yesOrNo]);
}

- (int) disableDelegatesWithTag:(int)tag disable:(int) yesOrNo type:(ccDispatcherDelegateType)type
{
	return ( [self alterTouchHandler:type delegate:nil fieldToSearch:kCCTag
                                arg1:tag arg2:tag operator:kCCEQ fieldToAlter:kCCDisable withValue:yesOrNo] );
}

- (int) disableDelegatesWithPriority:(int) priority disable:(int) yesOrNo type:(ccDispatcherDelegateType)type
{
	return ( [self alterTouchHandler:type delegate:nil fieldToSearch:kCCPriority
                                arg1:priority arg2:priority operator:kCCEQ fieldToAlter:kCCDisable withValue:yesOrNo] );
}

-(int) disableRemovedDelegates:(int)yesOrNo type:(ccDispatcherDelegateType)type
{
	return ( [self alterTouchHandler:type delegate:nil fieldToSearch:kCCRemove
                                arg1:YES arg2:YES operator:kCCEQ fieldToAlter:kCCDisable withValue:yesOrNo] );
}

- (int) disableDelegatesWithField:(ccHandlerFieldName)fieldName arg1:(int)leftEndPoint arg2:(int)rightEndPoint operator:(ccOperators)op
                          disable:(int)yesOrNo type:(ccDispatcherDelegateType)type
{
	return ( [self alterTouchHandler:type delegate:nil fieldToSearch:fieldName
                                arg1:leftEndPoint arg2:rightEndPoint operator:op fieldToAlter:kCCDisable withValue:yesOrNo] );
}

//---------------------------------
// removal of the delegate/s
//---------------------------------
#pragma mark -
#pragma mark - removeDelegate

-(void) removeDelegate:(id) delegate // since v0.8.0
{
	[self removeDelegate:delegate delay:NO type:kCCTargeted];
	[self removeDelegate:delegate delay:NO type:kCCStandard];
}

-(int) removeDelegate:(id)delegate delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)delegateType
{
	ccHandlerFieldName r = kCCRemove; if (yesOrNo) r = kCCRemoveToDo;
	return ([self alterTouchHandler:delegateType delegate:delegate fieldToSearch:kCCDelegate
                               arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:r withValue:YES]);
}

- (int) removeDelegatesWithTag:(int)tag delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)delegateType
{
	ccHandlerFieldName r = kCCRemove; if (yesOrNo) r = kCCRemoveToDo;
	return ([self alterTouchHandler:delegateType delegate:nil fieldToSearch:kCCTag
                               arg1:tag arg2:tag operator:kCCEQ fieldToAlter:r withValue:YES]);
}

- (int) removeDelegatesWithPriority:(int)priority delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)delegateType
{
	ccHandlerFieldName r = kCCRemove; if (yesOrNo) r = kCCRemoveToDo;
	return ([self alterTouchHandler:delegateType delegate:nil fieldToSearch:kCCPriority
                               arg1:priority arg2:priority operator:kCCEQ fieldToAlter:r withValue:YES]);
}

// Only For Eagles - Power API Function
- (int) removeDelegatesWithField:(ccHandlerFieldName)fieldToSearch arg1:(int)leftV arg2:(int)rightV operator:(ccOperators)op
                           delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)delegateType
{
	if (fieldToSearch == kCCDelegate) return -1; // user cannot search this field

	ccHandlerFieldName r = kCCRemove; if (yesOrNo) r = kCCRemoveToDo;
	return ([self alterTouchHandler:delegateType delegate:nil fieldToSearch:fieldToSearch
                               arg1:leftV arg2:rightV operator:op fieldToAlter:r withValue:YES]);
}

//------------------------------------
// setting value for a delegate field
//------------------------------------

-(void) setPriority:(int)priority forDelegate:(id)delegate /** since v1.0 obsolete */
{
	[self setPriority:priority delegate:delegate delay:NO type:kCCTargeted];
	[self setPriority:priority delegate:delegate delay:NO type:kCCStandard];
}

-(int) setPriority:(int)newValue delegate:(id)delegate delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)type;
{
	ccHandlerFieldName p = kCCPriority; if (yesOrNo) p = kCCPriorityToDo;
	return [self alterTouchHandler:type delegate:delegate fieldToSearch:kCCDelegate
                              arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:p withValue:newValue];
}

- (int) setTag:(int)newValue delegate:(id)delegate type:(ccDispatcherDelegateType)type
{
	return [self alterTouchHandler:type delegate:delegate fieldToSearch:kCCDelegate
                              arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:kCCTag withValue:newValue];
}

- (int) setDisable:(int)newValue delegate:(id)delegate type:(ccDispatcherDelegateType)type
{
	return [self alterTouchHandler:type delegate:delegate fieldToSearch:kCCDelegate
                              arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:kCCDisable withValue:newValue];
}

- (int) setRemove:(id)delegate delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)type
{
	ccHandlerFieldName r = kCCRemove; if (yesOrNo) r = kCCRemoveToDo;
	return [self alterTouchHandler:type delegate:delegate fieldToSearch:kCCDelegate
                              arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:r withValue:YES];
}

// generic power function
- (int) setField:(ccHandlerFieldName)field newValue:(int)newValue delegate:(id)delegate type:(ccDispatcherDelegateType)type
{
	return ([self alterTouchHandler:type delegate:delegate fieldToSearch:kCCDelegate
                               arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE fieldToAlter:field withValue:newValue]);
}

//------------------------------------------------------------------------------------------------
// setting new value for a delegates specific field conditional on the value of other(same) field
//------------------------------------------------------------------------------------------------
- (int)	setTagForPriority:(int)priority newTag:(int)value type:(ccDispatcherDelegateType)delegateType
{
	return ([self alterTouchHandler:delegateType delegate:nil
                      fieldToSearch:kCCPriority arg1:priority arg2:priority operator:kCCEQ fieldToAlter:kCCTag withValue:value]);
}

- (int)	setPriorityForTag:(int)tag newPriority:(int)value delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)delegateType
{
	ccHandlerFieldName p = kCCPriority; if (yesOrNo) p = kCCPriorityToDo;
	return ([self alterTouchHandler:delegateType delegate:nil
                      fieldToSearch:kCCTag arg1:tag arg2:tag operator:kCCEQ fieldToAlter:p withValue:value]);
}

/** Only For Eagles - Power Functions: */
-(int) setDelegatesField:(ccHandlerFieldName)field newValue:(int)newValue
				 ifField:(ccHandlerFieldName)fieldToSearch arg1:(int)leftEndPoint arg2:(int)rightEndPoint operator:(ccOperators)op
					type:(ccDispatcherDelegateType)type
{
	return ([self alterTouchHandler:type delegate:nil fieldToSearch:fieldToSearch
                               arg1:leftEndPoint arg2:rightEndPoint operator:op fieldToAlter:field withValue:newValue]);
}
//------------------------------------------------------------------------------------------------

- (int)	printDebugLog:(int)format type:(ccDispatcherDelegateType)type // API
{
	int count = 0;
	switch(type){
		case kCCTargeted:
			count = [self setDelegatesField:kCCDebug newValue:format ifField:kCCNone
                                       arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE type:type];
            break;
		case kCCStandard:
			count = [self setDelegatesField:kCCDebug newValue:format ifField:kCCNone
                                       arg1:CC_UNUSED_ARGUMENT arg2:CC_UNUSED_ARGUMENT operator:kCCTRUE type:type];
            break;
	}
	return count;
}

- (int) printDebugLog:(int)format afterEvents:(BOOL)after type:(ccDispatcherDelegateType)type; // API
{
	if (!after || !locked) {
		return ( [self printDebugLog:format type:type] );
	}
	// after && locked

	switch(type){
		case kCCTargeted: actionToDo.targetedDebugLogFlag = YES; actionToDo.targetedDebugLogArg = format; break;
		case kCCStandard: actionToDo.standardDebugLogFlag = YES; actionToDo.standardDebugLogArg = format; break;
	}
	return -1;
}

-(void) processCallbackRequestsToTheDispatcher
{
	// check if we need to change the order of processing:
	if (actionToDo.processStandardHandlersFirstFlag) {
		processStandardHandlersFirst = actionToDo.processStandardHandlersFirstArg;
		actionToDo.processStandardHandlersFirstFlag = NO;
	}
	// check if we need to change the sortingAlgorithm
	if (actionToDo.sortingAlgorithmFlag) {
		sortingAlgorithm = actionToDo.sortingAlgorithmArg;
		actionToDo.sortingAlgorithmFlag = NO;
	}
	// check if we need to change the priority order
	if (actionToDo.reversePriorityFlag){
		reversePriority = actionToDo.reversePriorityArg;
		actionToDo.reversePriorityFlag = NO;
	}
	// check if we need to change the user's 'usersComparator'
	if (actionToDo.usersComparatorFlag){
		usersComparator = actionToDo.usersComparatorArg;
		actionToDo.usersComparatorFlag = NO;
	}

	// -- handle priority change --
	[self forceSetPriority];
	//-----------------------------

	// print debug log
	if (actionToDo.targetedDebugLogFlag){
		[self printDebugLog:actionToDo.targetedDebugLogArg type:kCCTargeted];
		actionToDo.targetedDebugLogFlag = NO;
	}
	if (actionToDo.standardDebugLogFlag){
		[self printDebugLog:actionToDo.standardDebugLogArg type:kCCStandard];
		actionToDo.standardDebugLogFlag = NO;
	}
}

#pragma mark TouchDispatcher - safeProcessing

-(void) safeProcessing // process messages to the Dispatcher sent by user's touch callbacks
{
	// -- remove marked for removal delegates --
	[self forceRemoveMarkedDelegates];
	//------------------------------------------

	CCHandlersToDo *todo;
	CCARRAY_FOREACH(handlersToDo, todo) {
		switch (todo.type) {
			case kCCAddTargetedHandler:
				[self forceAddHandler:todo.handler doNotSort:todo.arg type:kCCTargeted];
				break;
			case kCCAddStandardHandler:
				[self forceAddHandler:todo.handler doNotSort:todo.arg type:kCCStandard];
				break;
			default:
				break;
		}
	}
	[handlersToDo removeAllObjects];

	//  -- process deleyed requests from user's touch callbacks --
	[self processCallbackRequestsToTheDispatcher];
	//------------------------------------------------------------
}

typedef struct{
	unsigned int targetedHandlersCount;
	unsigned int standardHandlersCount;
	BOOL needsMutableSet;
	id mutableTouches;
	struct ccTouchHandlerHelperData helper;
}ccTouchesHelper;

#pragma mark -
#pragma mark TouchDispatcher - Process Targeted Handlers

- (void) processTargetedHandlers:(NSSet*)touches withEvent:(UIEvent*)event withTouchType:(unsigned int)idx localData:(ccTouchesHelper *)d
{
	CCTargetedTouchHandler *handler;
	if( d->targetedHandlersCount > 0 ) {
		for( UITouch *touch in touches ) {
			CCARRAY_FOREACH(targetedHandlers, handler) { // speed is critical here

				if ( handler.disable ) continue; // handlers marked for removal are serviced

				BOOL claimed = NO;
				if( idx == kCCTouchBegan ) {
					claimed = [handler.delegate ccTouchBegan:touch withEvent:event];
					if( claimed )
						[handler.claimedTouches addObject:touch];
				}

				// else (moved, ended, cancelled)
				else if( [handler.claimedTouches containsObject:touch] ) {
					claimed = YES;
					if( handler.enabledSelectors & d->helper.type )
						[handler.delegate performSelector:d->helper.touchSel withObject:touch withObject:event];

					if( d->helper.type & (kCCTouchSelectorCancelledBit | kCCTouchSelectorEndedBit) )
						[handler.claimedTouches removeObject:touch];
				}

				if( claimed && handler.swallowsTouches ) {
					if( d->needsMutableSet )
						[d->mutableTouches removeObject:touch];
					break;
				}
			}
		}
	}
}

#pragma mark TouchDispatcher - Process Standard Handlers

- (void) processStandardHandlers:(UIEvent*)event localData:(ccTouchesHelper *)d
{
	CCTouchHandler *handler;
	if( d->standardHandlersCount > 0 && [d->mutableTouches count]>0 ) {
		CCARRAY_FOREACH(standardHandlers, handler) {
			if (handler.disable) continue; // handlers marked for removal are serviced (default)
			if (handler.enabledSelectors & d->helper.type)
				[handler.delegate performSelector:d->helper.touchesSel withObject:d->mutableTouches withObject:event];
		}
	}
}

#pragma mark TouchDispatcher - touches - dispatch events!

-(void) touches:(NSSet*)touches withEvent:(UIEvent*)event withTouchType:(unsigned int)idx
{
    NSAssert(idx < 4, @"Invalid idx value");

    BOOL secondLock = NO;
    if (locked)
        secondLock = YES;

    locked = YES; // processing of the touch callbacks is in progress

    ccTouchesHelper l;
    l.targetedHandlersCount = [targetedHandlers count];
	l.standardHandlersCount = [standardHandlers count];
	l.needsMutableSet = (l.targetedHandlersCount && l.standardHandlersCount);

	l.mutableTouches = (l.needsMutableSet ? [touches mutableCopy] : touches); // copy is expensive

	l.helper = handlerHelperData[idx];

	//
	// processing touches
	//
	if ( processStandardHandlersFirst ) {
		[self processStandardHandlers:event localData:&l];
		[self processTargetedHandlers:touches withEvent:event withTouchType:idx localData:&l];
	}
	else{ // this is the default order of the event processing
		[self processTargetedHandlers:touches withEvent:event withTouchType:idx localData:&l];
		[self processStandardHandlers:event localData:&l];
	}

    if (l.needsMutableSet)
		[l.mutableTouches release];

    if (secondLock){
        // skip safeProcessing
    }
    else{
        locked = NO; // processing of the touch callbacks is done
        // all critical operations are done after touch callback processing loop is finished
        [self safeProcessing];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )
		[self touches:touches withEvent:event withTouchType:kCCTouchBegan];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )
		[self touches:touches withEvent:event withTouchType:kCCTouchMoved];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )
		[self touches:touches withEvent:event withTouchType:kCCTouchEnded];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( dispatchEvents )
		[self touches:touches withEvent:event withTouchType:kCCTouchCancelled];
}

@end


#pragma mark -
#pragma mark CCHandlersToDo

@implementation CCHandlersToDo

@synthesize type = type_;
@synthesize handler = handler_;
@synthesize arg = arg_;

-(void) dealloc
{
    [handler_ release];
    [super dealloc];
}
@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
