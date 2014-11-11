/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
#import "CCActionManager_Private.h"
#import "ccMacros.h"

@interface CCActionManager (Private)
-(void) removeActionAtIndex:(NSUInteger)index hashElement:(tHashElement*)element;
-(void) deleteHashElement:(tHashElement*)element;
-(void) actionAllocWithHashElement:(tHashElement*)element;
@end


@implementation CCActionManager

-(id) init
{
	if ((self=[super init]) ) {
		targets = NULL;
	}

	return self;
}

-(NSInteger)priority
{
	return NSIntegerMin;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p>", [self class], self];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	[self removeAllActions];

}

#pragma mark ActionManager - Private

-(void) deleteHashElement:(tHashElement*)element
{
    void* a = (__bridge void*) element->actions;
    CFRelease(a);
	HASH_DEL(targets, element);
//	CCLOG(@"cocos2d: ---- buckets: %d/%d - %@", targets->entries, targets->size, element->target);
    void* t = (__bridge void*) element->target;
    CFRelease(t);
	free(element);
}

-(void) actionAllocWithHashElement:(tHashElement*)element
{
	// if actions array doesn't exist yet, create one
	if( element->actions == nil ) {
        NSMutableArray* aObj = [[NSMutableArray alloc] init];
        void* a = (__bridge void*) aObj;
        CFRetain(a);
		element->actions = aObj;
    }
}

-(void) removeActionAtIndex:(NSUInteger)index hashElement:(tHashElement*)element
{
	id action = [element->actions objectAtIndex:index];

	if( action == element->currentAction && !element->currentActionSalvaged ) {
        void* a = (__bridge void*) element->currentAction;
        CFRetain(a);
		element->currentActionSalvaged = YES;
	}
    
    [element->actions removeObjectAtIndex:index];

	// update actionIndex in case we are in tick:, looping over the actions
	if( element->actionIndex >= index )
		element->actionIndex--;

	if( element->actions.count == 0 ) {
		if( currentTarget == element )
			currentTargetSalvaged = YES;
		else
			[self deleteHashElement: element];
	}
}

#pragma mark ActionManager - Pause / Resume

-(void) pauseTarget:(id)target
{
	tHashElement *element = NULL;
    void* t = (__bridge void*) target;
	HASH_FIND_INT(targets, &t, element);
	if( element )
		element->paused = YES;
//	else
//		CCLOG(@"cocos2d: pauseAllActions: Target not found");
}

-(void) resumeTarget:(id)target
{
	tHashElement *element = NULL;
    void* t = (__bridge void*) target;
	HASH_FIND_INT(targets, &t, element);
	if( element )
		element->paused = NO;
//	else
//		CCLOG(@"cocos2d: resumeAllActions: Target not found");
}

-(NSSet *) pauseAllRunningActions
{
    NSMutableSet* idsWithActions = [NSMutableSet setWithCapacity:50];
    
    for(tHashElement *element=targets; element != NULL; element=element->hh.next) {
        if( !element->paused ) {
            element->paused = YES;
            [idsWithActions addObject:element->target];
        }
    }
    return idsWithActions;
}

-(void) resumeTargets:(NSSet *)targetsToResume
{
    for(id target in targetsToResume) {
        [self resumeTarget:target];
    }
}

#pragma mark ActionManager - run

-(void) addAction:(CCAction*)action target:(id)t paused:(BOOL)paused
{
	NSAssert( action != nil, @"Argument action must be non-nil");
	NSAssert( t != nil, @"Argument target must be non-nil");

	tHashElement *element = NULL;
    void* target = (__bridge void*)t;
	HASH_FIND_INT(targets, &target, element);
	if( ! element ) {
		element = calloc( sizeof( *element ), 1 );
		element->paused = paused;
        CFBridgingRetain(t);
        element->target = t;
		HASH_ADD_INT(targets, target, element);
//		CCLOG(@"cocos2d: ---- buckets: %d/%d - %@", targets->entries, targets->size, element->target);

	}

	[self actionAllocWithHashElement:element];

	NSAssert( ![element->actions containsObject:action], @"runAction: Action already running");
    [element->actions addObject:action];

	[action startWithTarget:t];
}

#pragma mark ActionManager - remove

-(void) removeAllActions
{
	for(tHashElement *element=targets; element != NULL; ) {
		id target = element->target;
		element = element->hh.next;
		[self removeAllActionsFromTarget:target];
	}
}
-(void) removeAllActionsFromTarget:(id)target
{
	// explicit nil handling
	if( target == nil )
		return;

    void* t = (__bridge void*) target;
	tHashElement *element = NULL;
	HASH_FIND_INT(targets, &t, element);
	if( element ) {
		if( [element->actions containsObject:element->currentAction] && !element->currentActionSalvaged ) {
            void* a = (__bridge void*) element->currentAction;
            CFRetain(a);
			element->currentActionSalvaged = YES;
		}
        [element->actions removeAllObjects];
		if( currentTarget == element )
			currentTargetSalvaged = YES;
		else
			[self deleteHashElement:element];
	}
//	else {
//		CCLOG(@"cocos2d: removeAllActionsFromTarget: Target not found");
//	}
}

-(void) removeAction: (CCAction*) action
{
	// explicit nil handling
	if (action == nil)
		return;

	tHashElement *element = NULL;
	id target = [action originalTarget];
    void* t = (__bridge void*) target;
	HASH_FIND_INT(targets, &t, element );
	if( element ) {
		NSUInteger i = [element->actions indexOfObject:action];
		if( i != NSNotFound )
			[self removeActionAtIndex:i hashElement:element];
	}
//	else {
//		CCLOG(@"cocos2d: removeAction: Target not found");
//	}
}

-(void) removeActionByTag:(NSInteger)aTag target:(id)target
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	NSAssert( target != nil, @"Target should be ! nil");

	tHashElement *element = NULL;
    void* t = (__bridge void*) target;
	HASH_FIND_INT(targets, &t, element);

	if( element ) {
		NSUInteger limit = element->actions.count;
		for( NSUInteger i = 0; i < limit; i++) {
			CCAction *a = [element->actions objectAtIndex:i];

			if( a.tag == aTag && [a originalTarget]==target) {
				[self removeActionAtIndex:i hashElement:element];
				break;
			}
		}

	}
}

#pragma mark ActionManager - get

-(CCAction*) getActionByTag:(NSInteger)aTag target:(id)target
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");

	tHashElement *element = NULL;
    void* t = (__bridge void*) target;
	HASH_FIND_INT(targets, &t, element);

	if( element ) {
		if( element->actions != nil ) {
			NSUInteger limit = element->actions.count;
			for( NSUInteger i = 0; i < limit; i++) {
				CCAction *a = [element->actions objectAtIndex:i];

				if( a.tag == aTag )
					return a;
			}
		}
//		CCLOG(@"cocos2d: getActionByTag: Action not found");
	}
//	else {
//		CCLOG(@"cocos2d: getActionByTag: Target not found");
//	}
	return nil;
}

-(NSUInteger) numberOfRunningActionsInTarget:(id) target
{
	tHashElement *element = NULL;
    void* t = (__bridge void*) target;
	HASH_FIND_INT(targets, &t, element);
	if( element )
		return element->actions ? element->actions.count : 0;

//	CCLOG(@"cocos2d: numberOfRunningActionsInTarget: Target not found");
	return 0;
}

#pragma mark ActionManager - main loop

-(void) update: (CCTime) dt
{
	for(tHashElement *elt = targets; elt != NULL; ) {

		currentTarget = elt;
		currentTargetSalvaged = NO;

		if( ! currentTarget->paused ) {

			// The 'actions' ccArray may change while inside this loop.
			for( currentTarget->actionIndex = 0; currentTarget->actionIndex < currentTarget->actions.count; currentTarget->actionIndex++) {
				currentTarget->currentAction = [currentTarget->actions objectAtIndex:currentTarget->actionIndex];
				currentTarget->currentActionSalvaged = NO;

				[currentTarget->currentAction step: dt];

				if( currentTarget->currentActionSalvaged ) {
					// The currentAction told the node to remove it. To prevent the action from
					// accidentally deallocating itself before finishing its step, we retained
					// it. Now that step is done, it's safe to release it.
                    void* a = (__bridge void*) currentTarget->currentAction;
                    CFRelease(a);

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
		elt = elt->hh.next;

		// only delete currentTarget if no actions were scheduled during the cycle (issue #481)
		if( currentTargetSalvaged && currentTarget->actions.count == 0 )
			[self deleteHashElement:currentTarget];
	}

	// issue #635
	currentTarget = nil;
}


-(void)migrateActions:(id)target from:(CCActionManager*)oldManager
{
	
	tHashElement *elementOld = NULL;
    void* t = (__bridge void*) target;
	HASH_FIND_INT(oldManager->targets, &t, elementOld);
	if( elementOld )
	{
			
		tHashElement *elementNew = NULL;
		HASH_FIND_INT(targets, &t, elementNew);
		if( ! elementNew ) {
			elementNew = calloc( sizeof( *elementNew ), 1 );
			elementNew->paused = elementOld->paused;
			CFBridgingRetain(target);
			elementNew->target = target;
			HASH_ADD_INT(targets, target, elementNew);
			
		}
		
		[self actionAllocWithHashElement:elementNew];
		[elementNew->actions addObjectsFromArray:elementOld->actions];
		[elementOld->actions removeAllObjects];
		[oldManager deleteHashElement:elementOld];
		
	}

}


@end


@implementation CCFixedActionManager

-(void)update:(CCTime)delta
{
    //return. Do nothing.
}

-(void)fixedUpdate:(CCTime)delta
{
    [super update:delta];
}

@end
