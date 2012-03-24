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

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.

#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import "CCTouchDelegateProtocol.h"
#import "EAGLView.h"
#import "CCArray.h"			// CCArray
#import "../../ccMacros.h"	// CCLOG


#define CC_UNUSED_ARGUMENT			0

typedef enum
{
	kCCTouchSelectorBeganBit = 1 << 0,
	kCCTouchSelectorMovedBit = 1 << 1,
	kCCTouchSelectorEndedBit = 1 << 2,
	kCCTouchSelectorCancelledBit = 1 << 3,
	kCCTouchSelectorAllBits = ( kCCTouchSelectorBeganBit | kCCTouchSelectorMovedBit | kCCTouchSelectorEndedBit | kCCTouchSelectorCancelledBit),
} ccTouchSelectorFlag;

enum {
	kCCTouchBegan,
	kCCTouchMoved,
	kCCTouchEnded,
	kCCTouchCancelled,
	
	kCCTouchMax,
};

struct ccTouchHandlerHelperData {
	SEL				touchesSel;
	SEL				touchSel;
	ccTouchSelectorFlag  type;
};

/** typedef enum ccSortingAlgorithm @since v1.1.0 */
typedef enum{
	kCCAlgInsertionSort = 0,	// Insertion Sort is the default algorithm used
	kCCAlgQSort,				// C qsort
	kCCAlgMergeLSort,			// mergeLSort
	kCCDoNotSort				// do not sort
}ccSortingAlgorithm;

/** typedef struct ccActionToDo @since v1.1.0 */
typedef struct{
	int	targetedRemoval;
	int	standardRemoval;
	//
	BOOL processStandardHandlersFirstFlag; 
	BOOL processStandardHandlersFirstArg;	// order of processing
	//
	BOOL sortingAlgorithmFlag;
	ccSortingAlgorithm sortingAlgorithmArg;	// sorting algorithm type
	//
	BOOL reversePriorityFlag;
	BOOL reversePriorityArg;				// reverse priority
	//
	BOOL usersComparatorFlag;
	int(*usersComparatorArg)(const void *, const void *); // new user comparator function 
	//	
	int	targetedPriority;
	int	standardPriority;
	//
	BOOL targetedDebugLogFlag;
	int targetedDebugLogArg;
	//
	BOOL standardDebugLogFlag;
	int standardDebugLogArg;
}ccActionToDo; // All critical operations should be only done only when event processing is finished

/** typedef enum ccDispatcherDelegateType @since v1.1.0 */
typedef enum {
	kCCTargeted,
	kCCStandard
}ccDispatcherDelegateType;

/** typedef enum ccHandlerFieldName @since v1.1.0 */
typedef enum {
	kCCDelegate = 0,	// use with care
	// real fields - their values can be accessed using 'retrieveField' function 
	kCCPriority,		// use to change priorities 
	kCCTag,				// use to change tag(s)
	kCCDisable,			// use to disable delegate(s)
	kCCRemove,			// use to remove delegate(s)
	kCCSwallowsTouches,
	//	special virtual fields - use it if you understand its purpose
	kCCPriorityToDo,	// use to prepare change of priority, do the actual sorting by calling 'sortDelegates:' function
    // useful for compound priority changes
	kCCRemoveToDo,		// use to mark delegates for removal, do actual removal by calling 'removeToDoDelegates:' function
    // useful for compound removals
    // kCC*ToDo fields are designed to work with 'setField' and 'setDelegatesField' functions
    //
	kCCNotRemoved,		// do an action only for the delegates which are not marked for removal						
	kCCNone,			// no field is searched for evaluation
	kCCDebug,			// prints debug info to console 
}ccHandlerFieldName;

/** typedef enum ccOperators @since v1.1.0 */
typedef enum{
	kCCFALSE = 0, // always false
	kCCTRUE, // always true
	// One argument operators use with arg1; arg2 not used
	kCCNEQ,//(v != arg1)
	kCCEQ, //(v == arg1)
	kCCGE, //(v >= arg1)
	kCCGT, //(v >  arg1)
	kCCLE, //(v <= arg1)
	kCCLT, //(v <  arg1)
	// And
	kCCGEAndLE, // very useful (one closed range) (v >= arg1) && (v <= arg2); (arg1 <= arg2)
	kCCGEAndLT, // one range (arg1 < arg2)
	kCCGTAndLE, // one range (arg1 < arg2)
	kCCGTAndLT, // very useful (one open range) (v > arg1) && (v < arg2); (arg1+1 < arg2)
	kCCLEAndGE, // one inverted endpoints range (v <= arg1) && (v>= arg2); (arg1 >= arg2)
	kCCLEAndGT, // one inverted endpoints range (arg1 > arg2)
	kCCLTAndGE, // one inverted endpoints range (arg1 > arg2)
	kCCLTAndGT, // one inverted endpoints range (arg1 > arg2+1)
	// Or	
	kCCGEOrLE, // inverted endpoints values (arg1 > arg2) 
	kCCGEOrLT, // inverted endpoints values (arg1 > arg2) 
	kCCGTOrLE, // inverted endpoints values (arg1 > arg2) 
	kCCGTOrLT, // inverted endpoints values (arg1 > arg2) 
	kCCLEOrGE, // whole domain if arg1==arg2 (== kTRUE);  two ranges (v <= arg1) && (v>= arg2); (arg1 < arg2) 
	kCCLEOrGT, // two ranges
	kCCLTOrGE, // two ranges
	kCCLTOrGT, // two ranges 
}ccOperators;

typedef enum 
{
	kCCAddTargetedHandler,
	kCCAddStandardHandler,
}ccHandlersToDoType; 

/** CCTouchDispatcher.
 Singleton that handles all the touch events.
 The dispatcher dispatches events to the registered TouchHandlers.
 There are 2 different type of touch handlers:
 - Standard Touch Handlers
 - Targeted Touch Handlers
 
 The Standard Touch Handlers work like the CocoaTouch touch handler: a set of touches is passed to the delegate.
 On the other hand, the Targeted Touch Handlers only receive 1 touch at the time, and they can "swallow" touches (avoid the propagation of the event).
 
 Firstly, the dispatcher sends the received touches to the targeted touches.
 These touches can be swallowed by the Targeted Touch Handlers. If there are still remaining touches, then the remaining touches will be sent
 to the Standard Touch Handlers.
 @since v0.8.0
 
 The above processing order can be reversed by setting 'processStandardHandlersFirst' to YES.  
 @since v1.1.0
 */
@interface CCTouchDispatcher : NSObject <EAGLTouchDelegate>
{
	CCArray	*targetedHandlers;
	CCArray	*standardHandlers;
	CCArray *handlersToDo;
    
	BOOL	dispatchEvents;						// default is YES;
	BOOL	processStandardHandlersFirst;		// default is NO;
	BOOL	locked;								// do not disturb, executing touch callbacks
	
	ccActionToDo actionToDo;					// outstanding processing to do 
	
	ccSortingAlgorithm sortingAlgorithm;		// default kAlgInsertionSort
	int(* usersComparator)(const void *, const void *); // user's comparator for sorting default NULL
	
	// 4, 1 for each type of event
	struct ccTouchHandlerHelperData handlerHelperData[kCCTouchMax];
}

/** singleton of the CCTouchDispatcher */
+ (CCTouchDispatcher*)sharedDispatcher;

/** Whether or not the events are going to be dispatched. Default: YES */
@property (nonatomic,readwrite,assign) BOOL dispatchEvents;
/** Adds a standard touch delegate to the dispatcher's list.
 See StandardTouchDelegate description.
 IMPORTANT: The delegate will be retained.
 */
-(void) addStandardDelegate:(id<CCStandardTouchDelegate>) delegate priority:(int)priority;
/** Adds a targeted touch delegate to the dispatcher's list.
 See TargetedTouchDelegate description.
 IMPORTANT: The delegate will be retained.
 */
-(void) addTargetedDelegate:(id<CCTargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches;
/** Removes a touch delegate.
 The delegate will be released
 */
-(void) removeDelegate:(id) delegate;
/** Removes all touch delegates, releasing all the delegates */
-(void) removeAllDelegates;
/** Changes the priority of a previously added delegate. The lower the number,
 the higher the priority
 @since v1.0 
 depreciated in v1.1 use:  
 - (int) setPriority:(int)newValue delegate:(id)delegate delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)type; 
 */
-(void) setPriority:(int) priority forDelegate:(id) delegate;

// -------------------------------------------------------------------
//  @since v1.1.0:
//--------------------------------------------------------------------

//----------------------------------
// adding delegates with tags
//----------------------------------

/** Adds a standard touch delegate to the dispatcher's list.
 in addition to priority, tag and disabled flag can be specified.
 'doNotSort' prevents sorting delegates after the addition of a new one. 
 Events will be distributed to the delegates in the same order as delegates were added. 
 See StandardTouchDelegate description.
 IMPORTANT: The delegate will be retained.
 @since v1.1.0
 */
- (void) addStandardDelegate:(id<CCStandardTouchDelegate>) delegate priority:(int)priority 
                         tag:(int)aTag disable:(int)yesOrNo doNotSort:(int)YN;
/** Adds a targeted touch delegate to the dispatcher's list.
 in addition to swallowsTouches or priority, tag and disable flag can be specified.
 'doNoSort' prevents sorting delegates after adding a new one.
 Events will be distributed to the delegates in the same order as delegates were added.
 See TargetedTouchDelegate description.
 IMPORTANT: The delegate will be retained.
 @since v1.1.0
 */
- (void) addTargetedDelegate:(id<CCTargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches
                         tag:(int)aTag disable:(int)yesOrNo doNotSort:(int)YN;

//---------------------------------------------------------------------
// safe touch call-back getters and setters for internal control fields
//---------------------------------------------------------------------

/** As per default targeted handlers are executed first 
 If needed this order can be reversed:
 @since v1.1.0
 */
-(void) setProcessStandardHandlersFirst:(BOOL)yesOrNo;

/** gets - current/requested - order of processing 
 @return whether or not standard handlers are processed first in the event loop
 @since v1.1.0
 */
-(BOOL) processStandardHandlersFirst;

/** get locked state of the dispatcher. It returns YES when called from touch callback function. 
 @since v1.1.0
 */
-(BOOL) locked;

/** set sorting algorithm 
 @since v1.1.0
 */
- (void) setSortingAlgorithm:(ccSortingAlgorithm)alg;

/** get - current/requested - sortingAlgorithm
 
 @since v1.1.0
 */
- (ccSortingAlgorithm) sortingAlgorithm;

/** set reverse/normal order of priorities 
 This operation will NOT force resorting
 Call sorting yourself via: sortDelegates:(ccDispatcherDelegateType)type; 
 */ 
- (void) setReversePriority:(BOOL)yesNo;
/** get - current/requested 'reversePriority'
 @since v1.1.0
 */
- (BOOL) reversePriority;

/** User can sets his own order of handling touches by supplying comparator functions.
 'setUsersComparator' sets new comparator for the sorting algorithms.
 This operation will NOT force resorting. To do sorting use: sortDelegates:(ccDispatcherDelegateType)type;
 'reversePriority' parameter has NO bearing when user supplies his own comparator
 @since v1.1.0
 */ 
- (void) setUsersComparator:(int(*)(const void *, const void *))comparator;

/** get - current/requested - usersComparator 
 @since v1.1.0
 */
- (int(*)(const void *, const void *)) usersComparator;

//--------------------------------------------
//		debug
//--------------------------------------------

/** prints debug info about handlers. If format = 1, info about delegate is added. 
 If 'after' = YES, the debug log is printed after all callback requests to the touch dispatcher
 have been processed. In this case the return value is equal to -1.
 If requested outside a touch callback it returns the number of the handlers' objects of the given type.
 It is equal to the count of the printed handlers.
 @since v1.1.0
 */
- (int) printDebugLog:(int)format afterEvents:(BOOL)after type:(ccDispatcherDelegateType)type;

//--------------------------------------------
//		priority sort
//--------------------------------------------
//--------------------------------------------
/** sorts delegates of the given type according to the following factors:
 - sortingAlgorithm
 - reversePriority
 - comparator 
 
 This function is also useful when priority is changed without sorting by the following functions used with kCCPriorityToDo field:
 setField:kCCPriorityToDo ... or/and setDelegatesField:kCCPriorityToDo ...
 Regardless, delegates will be sorted at the end of the callback event processing loop if required. 
 
 @since v1.1.0
 */
- (void) sortDelegates:(ccDispatcherDelegateType)type;
//--------------------------------------------

//---------------------------------
// counting delegates
//---------------------------------

/** returns number of delegates of the given type
 User's callback safe: delegates in the process of being removed are not counted. 
 @since v1.1.0
 */						
- (int) countDelegatesUsage:(ccDispatcherDelegateType)type; 

/** checks if the touch delegate is already added to the dispatcher's list of the given type 
 It may be important since any attempt to add two identical delegates triggers the 'NSAssert'. 
 User's callback safe: 
 It returns 0 if delegate does not exist or is marked for removal or >0 if delegate is added. 
 If delegate is marked for removal adding the same delegate is safe.  
 @since v1.1.0
 */
- (int) countDelegateUsage:(id) delegate type:(ccDispatcherDelegateType)type;	

/** returns number of delegates with the specified tag
 User's callback safe: delegates in the process of being removed are not counted. 
 */
- (int) countTagUsage:(int)tagValue type:(ccDispatcherDelegateType)type; 

/** returns number of delegates with the specified priority
 User's callback safe: delegates in the process of being removed are not counted. 
 @since v1.1.0
 */
- (int) countPriorityUsage:(int)priorityValue type:(ccDispatcherDelegateType)type;

/** returns number of delegates with the specified disable value ((Use: YES or NO)
 User's callback safe: delegates in the process of being removed are not counted. 
 @since v1.1.0
 */
- (int) countDisableUsage:(int)disableValue type:(ccDispatcherDelegateType)type;

/** returns number of delegates with the specified value for given field 
 User's callback safe: delegates in the process of being removed are not counted. 
 Notice: It is generic functions covering all sugar 'countThisFieldUsage()' functions
 @since v1.1.0
 */
- (int) countFieldUsage:(ccHandlerFieldName)field fieldValue:(int)value type:(ccDispatcherDelegateType)type;

//----------------------------------
// retrieval of the field value
// ---------------------------------

/** returns priority of the delegate or if the delegate does not exist, returns NSNotFound 
 @since v1.1.0
 */
- (int) retrievePriorityField:(id) delegate type:(ccDispatcherDelegateType)type;

/** returns tag of the delegate or if the delegate does not exist, returns NSNotFound 
 @since v1.1.0
 */
- (int) retrieveTagField:(id) delegate type:(ccDispatcherDelegateType)type;

/** returns value of the disable field or if the delegate does not exist, returns NSNotFound 
 @since v1.1.0
 */
-(int) retrieveDisableField:(id) delegate type:(ccDispatcherDelegateType)type;

/** returns value of the field or if the delegate does not exist, returns NSNotFound 
 Notice: It is generic functions covering all sugar 'retrieve*Field(.)' functions
 @since v1.1.0
 */
- (int) retrieveField:(ccHandlerFieldName)field delegate:(id)delegate type:(ccDispatcherDelegateType)type;

//--------------------------------
// disabling of the delegate(s)
//--------------------------------

/** disables/enables already added touch delegate 
 @since v1.1.0
 */			
- (int) disableDelegate:(id) delegate disable:(int)yesOrNo type:(ccDispatcherDelegateType)type;

/**  disables/enables all delegates of the given type 
 returns number of disabled delegates
 @since v1.1.0
 */
- (int) disableAllDelegates:(int)yesOrNo type:(ccDispatcherDelegateType)type;
/** disables/enables already added touch delegates of the given type
 with specified tag. (That allows for fast and selective disabling/enabling of delegates. 
 Otherwise, delegates would have to be removed and added again to the list)
 returns number of disabled delegates
 @since v1.1.0
 */
- (int) disableDelegatesWithTag:(int)aTag disable:(int)yesOrNo type:(ccDispatcherDelegateType)type;
/** disables/enables already added targeted touch delegates of the given type
 with specified priority (including those marked for removal).
 returns number of disabled delegates 
 @since v1.1.0
 */
- (int) disableDelegatesWithPriority:(int)aPriority disable:(int)yesOrNo type:(ccDispatcherDelegateType)type;

/** inside the event loop, delegates marked for removal still receive touches (default)
 'disableRemovedDelegates' disables/enables delegates marked for removal inside the event loop.
 Use it inside the touch callback function if you do not want removed delegates to be active
 during event loop.
 returns number of disabled delegates (including those marked for removal)
 @since v1.1.0
 */ 
- (int) disableRemovedDelegates:(int)yesOrNo type:(ccDispatcherDelegateType)type;

/** generic function to disable/enable delegates when a specific field contains a certain value.  
 The content of the field is evaluated against arg1 and arg2 using (ccOperators)op.
 @since v1.1.0
 */
- (int) disableDelegatesWithField:(ccHandlerFieldName)fieldName arg1:(int)leftEndPoint arg2:(int)rightEndPoint operator:(ccOperators)op
disable:(int)yesOrNo type:(ccDispatcherDelegateType)type;

//---------------------------------
// removal of the delegate/s
//---------------------------------
// Note: removal cannot be undone. If you need an already removed delegate then add it again.

/** Removes the delegate of the given type, releasing the delegate
 If delay: is set to YES the removal is delayed until removeToDoDelegates:type is called or current/first
 event loop ends.
 @since v1.1.0
 */
- (int) removeDelegate:(id) delegate delay:(BOOL)yesOrNO type:(ccDispatcherDelegateType)type;

/** removes all delegates of the given type 
 returns number of delegates removed
 @since v1.1.0
 */ 
- (int) removeAllDelegates:(ccDispatcherDelegateType)type;

/** removes all delegates of the given type with specified tag 
 returns number of delegates removed 
 If delay: is set to YES the removal is delayed until removeToDoDelegates:type is called or current/first
 event loop ends.
 @since v1.1.0
 */ 
- (int) removeDelegatesWithTag:(int)tag delay:(BOOL)yesOrNO type:(ccDispatcherDelegateType)type;

/** removes all delegates of the given type with specified priority
 returns number of delegates removed
 If delay: is set to YES the removal is delayed until removeToDoDelegates:type is called or current/first
 event loop ends.
 @since v1.1.0
 */ 
- (int) removeDelegatesWithPriority:(int)priority delay:(BOOL)yesOrNO type:(ccDispatcherDelegateType)type;

/** removes all delegates of the given type marked for removal by the following functions used with kCCRemoveToDo field:
 setField:kCCRemoveToDo ... or/and setDelegatesField:kCCRemoveToDo ... or remove* functions with delay:YES
 If 'removeToDoDelegates' is not used all marked delegates will be removed at the end of the first event processing loop. 
 returns number of delegates removed.
 If function is called in the touch callback it returns -1. (Delegates will be removed at the end of the event loop)
 @since v1.1.0
 */ 
- (int) removeToDoDelegates:(ccDispatcherDelegateType)type; 

/** power function: covers all 'removeDelegates*' functions. Removes delegates of the given type 
 for which a given field contains desired value.
 The value of the field is evaluated against arg1 and arg2 using (ccOperators)op.
 @since v1.1.0
 */
- (int) removeDelegatesWithField:(ccHandlerFieldName)fieldName 
                            arg1:(int)leftEndPoint arg2:(int)rightEndPoint operator:(ccOperators)op delay:(BOOL)yesOrNO type:(ccDispatcherDelegateType)type;

//-------------------------------------------------------------------------
// setting the value of a specific field to a new value for a given delegate
//-------------------------------------------------------------------------

/** Changes the priority of the previously added delegate.
 If the new value is different from the old one, it will commence sorting of the delegates.
 returns the number of delegates which changed priority. Removed delegates are not counted.
 If delay: is set to YES, sorting is delayed until 'sortDelegates:type' is called or the current/first
 event loop ends.
 @since v1.1.0
 */
- (int) setPriority:(int)newValue delegate:(id)delegate delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)type;

/** setRemove == removeDelegate
 If delay: is set to YES then the removal is delayed until removeToDoDelegates:type is called or current/first
 event loop ends.
 @since v1.1.0
 */
- (int) setRemove:(id)delegate delay:(BOOL)yesOrNo type:(ccDispatcherDelegateType)type;						

/** set a new tag for delegate
 @since v1.1.0
 */
- (int) setTag:(int)newValue delegate:(id)delegate type:(ccDispatcherDelegateType)type; 
/** setDisable == disableDelegate  - disable/enable delegate
 @since v1.1.0
 */
- (int) setDisable:(int)newValue delegate:(id)delegate type:(ccDispatcherDelegateType)type;

/** generic power function: sets value of the specific field to a new value.
 @return number of affected delegates. It returns 0 if delegate is not found. It returns less than 0 for an error.  
 @since v1.1.0
 */
- (int) setField:(ccHandlerFieldName)field newValue:(int)newValue delegate:(id)delegate type:(ccDispatcherDelegateType)type;

//------------------------------------------------------------------------------------------------
// setting a new value for a specific field in delegate(s) which is conditional on the value of a certain field in the delegate
//------------------------------------------------------------------------------------------------
/** sets new priority for all delegates with the given tag
 If delay: is set to YES sorting is delayed until sortDelegates:type; is called or the current/first
 event loop ends.
 @since v1.1.0
 */
- (int)	setPriorityForTag:(int)tag newPriority:(int)value delay:(BOOL)yesOrNO type:(ccDispatcherDelegateType)type;
/** sets new tag for all delegates with the given priority 
 @since v1.1.0
 */
- (int)	setTagForPriority:(int)priority newTag:(int)value type:(ccDispatcherDelegateType)type;

/** 'Only For Eagles' - generic power function - allows changes for delegates with the specific field value
 The content of the field is evaluated against arg1 and arg2 using (ccOperators)op.
 It returns number of affected delegates.
 @since v1.1.0
 */
- (int) setDelegatesField:(ccHandlerFieldName)field newValue:(int)newValue
                  ifField:(ccHandlerFieldName)fieldToSearch arg1:(int)leftEndPoint arg2:(int)rightEndPoint operator:(ccOperators)op
type:(ccDispatcherDelegateType)type;
//-----------------------------------------------------------------------------------------------
@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
