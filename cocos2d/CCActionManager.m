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


#pragma mark ActionManager - main loop

-(void) update: (CCTime) dt
{
    if(!self.fixedMode) [self updateActions:dt];
}
-(void)fixedUpdate:(CCTime)dt
{
    if(self.fixedMode) [self updateActions:dt];
}

-(void) updateActions: (CCTime)dt
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
#warning [self removeAction:a];
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




@end



