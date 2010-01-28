/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CCActionManager.h"
#import "CCScheduler.h"
#import "ccMacros.h"
#import "Support/ccHashSet.h"


//
// hash
//
// Equal function for targetSet.
static int
targetSetEql(void *ptr, void *elt)
{
	tHashElement *first = (tHashElement*) ptr;
	tHashElement *second = (tHashElement*) elt;
	return (first->target == second->target);
}

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
	@synchronized([CCActionManager class])
	{
		if (!_sharedManager)
			_sharedManager = [[self alloc] init];
		
	}
	// to avoid compiler warning
	return _sharedManager;
}

+(id)alloc
{
	@synchronized([CCActionManager class])
	{
		NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	// to avoid compiler warning
	return nil;
}

+(void)purgeSharedManager
{
	@synchronized( self ) {
		[_sharedManager release];
	}
}

-(id) init
{
	if ((self=[super init]) ) {
		[[CCScheduler sharedScheduler] scheduleTimer: [CCTimer timerWithTarget:self selector:@selector(tick:)]];
		targets = ccHashSetNew(131, targetSetEql);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG( @"cocos2d: deallocing %@", self);
	
	[self removeAllActions];
	ccHashSetFree(targets);

	_sharedManager = nil;

	[super dealloc];
}

#pragma mark ActionManager - Private

-(void) deleteHashElement:(tHashElement*)element
{
	ccArrayFree(element->actions);
	ccHashSetRemove(targets, CC_HASH_INT(element->target), element);
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

-(void) pauseAllActionsForTarget:(id)target
{
	tHashElement elementTmp;
	elementTmp.target = target;
	tHashElement *element = ccHashSetFind(targets, CC_HASH_INT(target), &elementTmp);
	if( element )
		element->paused = YES;
//	else
//		CCLOG(@"cocos2d: pauseAllActions: Target not found");
}
-(void) resumeAllActionsForTarget:(id)target
{
	tHashElement elementTmp;
	elementTmp.target = target;
	tHashElement *element = ccHashSetFind(targets, CC_HASH_INT(target), &elementTmp);
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
	
	tHashElement elementTmp;
	elementTmp.target = target;
	tHashElement *element = ccHashSetFind(targets, CC_HASH_INT(target), &elementTmp);
	if( ! element ) {
		element = malloc( sizeof( *element ) );
		bzero(element, sizeof(*element));
		element->paused = paused;
		element->target = [target retain];
		ccHashSetInsert(targets, CC_HASH_INT(target), element, nil);
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
	for(int i=0; i< targets->size; i++) {
		ccHashSetBin *bin;
		for(bin = targets->table[i]; bin; ) {
			tHashElement *elt = (tHashElement*)bin->elt;
			id target = elt->target;
			bin = bin->next;
			[self removeAllActionsFromTarget:target];
		}
	}
}
-(void) removeAllActionsFromTarget:(id)target
{
	// explicit nil handling
	if( target == nil )
		return;
	
	tHashElement elementTmp;
	elementTmp.target = target;
	tHashElement *element = ccHashSetFind(targets, CC_HASH_INT(target), &elementTmp);
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
	
	tHashElement elementTmp;
	elementTmp.target = [action originalTarget];
	tHashElement *element = ccHashSetFind(targets, CC_HASH_INT(elementTmp.target), &elementTmp);
	if( element ) {
		NSUInteger i = ccArrayGetIndexOfObject(element->actions, action);
		if( i != NSNotFound ) {
			if( action == element->currentAction && !element->currentActionSalvaged ) {
				[element->currentAction retain];
				element->currentActionSalvaged = YES;
			}
			
			[self removeActionAtIndex:i hashElement:element];
		}
	} else {
//		CCLOG(@"cocos2d: removeAction: Target not found");
	}
}

-(void) removeActionByTag:(int) aTag target:(id)target
{
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");
	NSAssert( target != nil, @"Target should be ! nil");
	
	tHashElement elementTmp;
	elementTmp.target = target;
	tHashElement *element = ccHashSetFind(targets, CC_HASH_INT(target), &elementTmp);
	
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
	NSAssert( aTag != kActionTagInvalid, @"Invalid tag");

	tHashElement elementTmp;
	elementTmp.target = target;
	tHashElement *element = ccHashSetFind(targets, CC_HASH_INT(target), &elementTmp);

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
	tHashElement elementTmp;
	elementTmp.target = target;
	tHashElement *element = ccHashSetFind(targets, CC_HASH_INT(target), &elementTmp);
	if( element )
		return element->actions ? element->actions->num : 0;

//	CCLOG(@"cocos2d: numberOfRunningActionsInTarget: Target not found");
	return 0;
}

#pragma mark ActionManager - main loop

-(void) tick: (ccTime) dt
{
	for(int i=0; i< targets->size; i++) {
		ccHashSetBin *bin;
		for(bin = targets->table[i]; bin; ) {
			currentTarget = (tHashElement*) bin->elt;
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

			// bin, at this moment, is still valid
			// so it is safe to ask this here (issue #490)
			bin = bin->next;

			// only delete currentTarget if no actions were scheduled during the cycle (issue #481)
			if( currentTargetSalvaged && currentTarget->actions->num == 0 )
				[self deleteHashElement:currentTarget];
		}
	}
	
	// issue #635
	currentTarget = nil;
}
@end
