/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2009 Valentin Milea
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


#import "CCActionManager.h"
#import "CCScheduler.h"
#import "ccMacros.h"


//
// singleton stuff
//
static CCActionManager *_sharedManager = nil;

@interface CCActionManager (Private)
-(void) removeActionAtIndex:(NSUInteger)index hashElement:(tHashElement*)element;
-(void) deleteHashElement:(tHashElement*)element;
-(void) actionAllocWithHashElement:(tHashElement*)element;
@end


@implementation CCActionManager

#pragma mark ActionManager - init
+ (CCActionManager *)sharedManager
{
	if (!_sharedManager)
		_sharedManager = [[self alloc] init];
		
	return _sharedManager;
}

+(id)alloc
{
	NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedManager
{
	[[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
	[_sharedManager release];
}

-(id) init
{
	if ((self=[super init]) ) {
		[[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:0 paused:NO];
		targets = NULL;
	}
	
	return self;
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
	
	[self removeAllActions];

	_sharedManager = nil;

	[super dealloc];
}

#pragma mark ActionManager - Private

-(void) deleteHashElement:(tHashElement*)element
{
	ccArrayFree(element->actions);
	HASH_DEL(targets, element);
//	CCLOG(@"cocos2d: ---- buckets: %d/%d - %@", targets->entries, targets->size, element->target);
	[element->target release];
	free(element);
}

-(void) actionAllocWithHashElement:(tHashElement*)element
{
	// 4 actions per Node by default
	if( element->actions == nil )
		element->actions = ccArrayNew(4);
	else if( element->actions->num == element->actions->max )
		ccArrayDoubleCapacity(element->actions);	
}

-(void) removeActionAtIndex:(NSUInteger)index hashElement:(tHashElement*)element
{	
	id action = element->actions->arr[index];

	if( action == element->currentAction && !element->currentActionSalvaged ) {
		[element->currentAction retain];
		element->currentActionSalvaged = YES;
	}
	
	ccArrayRemoveObjectAtIndex(element->actions, index);

	// update actionIndex in case we are in tick:, looping over the actions
	if( element->actionIndex >= index )
		element->actionIndex--;
	
	if( element->actions->num == 0 ) {
		if( currentTarget == element )
			currentTargetSalvaged = YES;
		else
			[self deleteHashElement: element];
	}
}

#pragma mark ActionManager - Pause / Resume

// XXX DEPRECATED. REMOVE IN 1.0
-(void) pauseAllActionsForTarget:(id)target
{
	[self pauseTarget:target];
}

-(void) pauseTarget:(id)target
{
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	if( element )
		element->paused = YES;
//	else
//		CCLOG(@"cocos2d: pauseAllActions: Target not found");
}

// XXX DEPRECATED. REMOVE IN 1.0
-(void) resumeAllActionsForTarget:(id)target
{
	[self resumeTarget:target];
}

-(void) resumeTarget:(id)target
{
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	if( element )
		element->paused = NO;
//	else
//		CCLOG(@"cocos2d: resumeAllActions: Target not found");
}

#pragma mark ActionManager - run

-(void) addAction:(CCAction*)action target:(id)target paused:(BOOL)paused
{
	NSAssert( action != nil, @"Argument action must be non-nil");
	NSAssert( target != nil, @"Argument target must be non-nil");	
	
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	if( ! element ) {
		element = calloc( sizeof( *element ), 1 );
		element->paused = paused;
		element->target = [target retain];
		HASH_ADD_INT(targets, target, element);
//		CCLOG(@"cocos2d: ---- buckets: %d/%d - %@", targets->entries, targets->size, element->target);

	}
	
	[self actionAllocWithHashElement:element];

	NSAssert( !ccArrayContainsObject(element->actions, action), @"runAction: Action already running");	
	ccArrayAppendObject(element->actions, action);
	
	[action startWithTarget:target];
}

#pragma mark ActionManager - remove

-(void) removeAllActions
{
	for(tHashElement *element=targets; element != NULL; ) {	
		id target = element->target;
		element=element->hh.next;
		[self removeAllActionsFromTarget:target];
	}
}
-(void) removeAllActionsFromTarget:(id)target
{
	// explicit nil handling
	if( target == nil )
		return;
	
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	if( element ) {
		if( ccArrayContainsObject(element->actions, element->currentAction) && !element->currentActionSalvaged ) {
			[element->currentAction retain];
			element->currentActionSalvaged = YES;
		}
		ccArrayRemoveAllObjects(element->actions);
		if( currentTarget == element )
			currentTargetSalvaged = YES;
		else
			[self deleteHashElement:element];
	} else {
//		CCLOG(@"cocos2d: removeAllActionsFromTarget: Target not found");
	}
}

-(void) removeAction: (CCAction*) action
{
	// explicit nil handling
	if (action == nil)
		return;
	
	tHashElement *element = NULL;
	id target = [action originalTarget];
	HASH_FIND_INT(targets, &target, element );
	if( element ) {
		NSUInteger i = ccArrayGetIndexOfObject(element->actions, action);
		if( i != NSNotFound ) {
			
			[self removeActionAtIndex:i hashElement:element];
		}
	} else {
//		CCLOG(@"cocos2d: removeAction: Target not found");
	}
}

-(void) removeActionByTag:(int) aTag target:(id)target
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	NSAssert( target != nil, @"Target should be ! nil");
	
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	
	if( element ) {
		NSUInteger limit = element->actions->num;
		for( NSUInteger i = 0; i < limit; i++) {
			CCAction *a = element->actions->arr[i];
			
			if( a.tag == aTag && [a originalTarget]==target)
				return [self removeActionAtIndex:i hashElement:element];
		}
//		CCLOG(@"cocos2d: removeActionByTag: Action not found!");
	} else {
//		CCLOG(@"cocos2d: removeActionByTag: Target not found!");
	}
}

#pragma mark ActionManager - get

-(CCAction*) getActionByTag:(int)aTag target:(id)target
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");

	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);

	if( element ) {
		if( element->actions != nil ) {
			NSUInteger limit = element->actions->num;
			for( NSUInteger i = 0; i < limit; i++) {
				CCAction *a = element->actions->arr[i];
			
				if( a.tag == aTag )
					return a; 
			}
		}
//		CCLOG(@"cocos2d: getActionByTag: Action not found");
	} else {
//		CCLOG(@"cocos2d: getActionByTag: Target not found");
	}
	return nil;
}

-(int) numberOfRunningActionsInTarget:(id) target
{
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &target, element);
	if( element )
		return element->actions ? element->actions->num : 0;

//	CCLOG(@"cocos2d: numberOfRunningActionsInTarget: Target not found");
	return 0;
}

#pragma mark ActionManager - main loop

-(void) update: (ccTime) dt
{
	for(tHashElement *elt=targets; elt != NULL; ) {	

		currentTarget = elt;
		currentTargetSalvaged = NO;
		
		if( ! currentTarget->paused ) {
			
			// The 'actions' ccArray may change while inside this loop.
			for( currentTarget->actionIndex = 0; currentTarget->actionIndex <  currentTarget->actions->num; currentTarget->actionIndex++) {
				currentTarget->currentAction = currentTarget->actions->arr[currentTarget->actionIndex];
				currentTarget->currentActionSalvaged = NO;
				
				[currentTarget->currentAction step: dt];

				if( currentTarget->currentActionSalvaged ) {
					// The currentAction told the node to remove it. To prevent the action from
					// accidentally deallocating itself before finishing its step, we retained
					// it. Now that step is done, it's safe to release it.
					[currentTarget->currentAction release];

				} else if( [currentTarget->currentAction isDone] ) {
					[currentTarget->currentAction stop];
					
					CCAction *a = currentTarget->currentAction;
					// Make currentAction nil to prevent removeAction from salvaging it.
					currentTarget->currentAction = nil;
					[self removeAction:a];
				}
				
				currentTarget->currentAction = nil;
			}
		}

		// elt, at this moment, is still valid
		// so it is safe to ask this here (issue #490)
		elt=elt->hh.next;
	
		// only delete currentTarget if no actions were scheduled during the cycle (issue #481)
		if( currentTargetSalvaged && currentTarget->actions->num == 0 )
			[self deleteHashElement:currentTarget];
	}
	
	// issue #635
	currentTarget = nil;
}
@end
