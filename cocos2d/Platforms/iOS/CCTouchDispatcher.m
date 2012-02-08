/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
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

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#ifdef __CC_PLATFORM_IOS


#import "CCTouchDispatcher.h"
#import "CCTouchHandler.h"

@implementation CCTouchDispatcher

@synthesize dispatchEvents;

-(id) init
{
	if((self = [super init])) {

		dispatchEvents = YES;
		targetedHandlers = [[NSMutableArray alloc] initWithCapacity:8];
		standardHandlers = [[NSMutableArray alloc] initWithCapacity:4];

		handlersToAdd = [[NSMutableArray alloc] initWithCapacity:8];
		handlersToRemove = [[NSMutableArray alloc] initWithCapacity:8];

		toRemove = NO;
		toAdd = NO;
		toQuit = NO;
		locked = NO;

		handlerHelperData[kCCTouchBegan] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesBegan:withEvent:),@selector(ccTouchBegan:withEvent:),kCCTouchSelectorBeganBit};
		handlerHelperData[kCCTouchMoved] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesMoved:withEvent:),@selector(ccTouchMoved:withEvent:),kCCTouchSelectorMovedBit};
		handlerHelperData[kCCTouchEnded] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesEnded:withEvent:),@selector(ccTouchEnded:withEvent:),kCCTouchSelectorEndedBit};
		handlerHelperData[kCCTouchCancelled] = (struct ccTouchHandlerHelperData) {@selector(ccTouchesCancelled:withEvent:),@selector(ccTouchCancelled:withEvent:),kCCTouchSelectorCancelledBit};

	}

	return self;
}

-(void) dealloc
{
	[targetedHandlers release];
	[standardHandlers release];
	[handlersToAdd release];
	[handlersToRemove release];
	[super dealloc];
}

//
// handlers management
//

#pragma mark TouchDispatcher - Add Hanlder

-(void) forceAddHandler:(CCTouchHandler*)handler array:(NSMutableArray*)array
{
	NSUInteger i = 0;

	for( CCTouchHandler *h in array ) {
		if( h.priority < handler.priority )
			i++;

		NSAssert( h.delegate != handler.delegate, @"Delegate already added to touch dispatcher.");
	}
	[array insertObject:handler atIndex:i];
}

-(void) addStandardDelegate:(id<CCStandardTouchDelegate>) delegate priority:(int)priority
{
	CCTouchHandler *handler = [CCStandardTouchHandler handlerWithDelegate:delegate priority:priority];
	if( ! locked ) {
		[self forceAddHandler:handler array:standardHandlers];
	} else {
		[handlersToAdd addObject:handler];
		toAdd = YES;
	}
}

-(void) addTargetedDelegate:(id<CCTargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches
{
	CCTouchHandler *handler = [CCTargetedTouchHandler handlerWithDelegate:delegate priority:priority swallowsTouches:swallowsTouches];
	if( ! locked ) {
		[self forceAddHandler:handler array:targetedHandlers];
	} else {
		[handlersToAdd addObject:handler];
		toAdd = YES;
	}
}

#pragma mark TouchDispatcher - removeDelegate

-(void) forceRemoveDelegate:(id)delegate
{
	// XXX: remove it from both handlers ???

	for( CCTouchHandler *handler in targetedHandlers ) {
		if( handler.delegate == delegate ) {
			[targetedHandlers removeObject:handler];
			break;
		}
	}

	for( CCTouchHandler *handler in standardHandlers ) {
		if( handler.delegate == delegate ) {
			[standardHandlers removeObject:handler];
			break;
		}
	}
}

-(void) removeDelegate:(id) delegate
{
	if( delegate == nil )
		return;

	if( ! locked ) {
		[self forceRemoveDelegate:delegate];
	} else {
		[handlersToRemove addObject:delegate];
		toRemove = YES;
	}
}

#pragma mark TouchDispatcher  - removeAllDelegates

-(void) forceRemoveAllDelegates
{
	[standardHandlers removeAllObjects];
	[targetedHandlers removeAllObjects];
}
-(void) removeAllDelegates
{
	if( ! locked )
		[self forceRemoveAllDelegates];
	else
		toQuit = YES;
}

#pragma mark Changing priority of added handlers

-(CCTouchHandler*) findHandler:(id)delegate
{
	for( CCTouchHandler *handler in targetedHandlers ) {
		if( handler.delegate == delegate ) {
            return handler;
		}
	}

	for( CCTouchHandler *handler in standardHandlers ) {
		if( handler.delegate == delegate ) {
            return handler;
        }
	}

    if (toAdd) {
		for( CCTouchHandler *handler in handlersToAdd ) {
            if (handler.delegate == delegate) {
                return handler;
            }
        }
    }

    return nil;
}

NSComparisonResult sortByPriority(id first, id second, void *context)
{
    if (((CCTouchHandler*)first).priority < ((CCTouchHandler*)second).priority)
        return NSOrderedAscending;
    else if (((CCTouchHandler*)first).priority > ((CCTouchHandler*)second).priority)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

-(void) rearrangeHandlers:(NSMutableArray*)array
{
    [array sortUsingFunction:sortByPriority context:nil];
}

-(void) setPriority:(int) priority forDelegate:(id) delegate
{
	NSAssert(delegate != nil, @"Got nil touch delegate!");

	CCTouchHandler *handler = nil;
    handler = [self findHandler:delegate];

    NSAssert(handler != nil, @"Delegate not found!");

    handler.priority = priority;

    [self rearrangeHandlers:targetedHandlers];
    [self rearrangeHandlers:standardHandlers];
}

//
// dispatch events
//
-(void) touches:(NSSet*)touches withEvent:(UIEvent*)event withTouchType:(unsigned int)idx
{
	NSAssert(idx < 4, @"Invalid idx value");

	id mutableTouches;
	locked = YES;

	// optimization to prevent a mutable copy when it is not necessary
	unsigned int targetedHandlersCount = [targetedHandlers count];
	unsigned int standardHandlersCount = [standardHandlers count];
	BOOL needsMutableSet = (targetedHandlersCount && standardHandlersCount);

	mutableTouches = (needsMutableSet ? [touches mutableCopy] : touches);

	struct ccTouchHandlerHelperData helper = handlerHelperData[idx];
	//
	// process the target handlers 1st
	//
	if( targetedHandlersCount > 0 ) {
		for( UITouch *touch in touches ) {
			for(CCTargetedTouchHandler *handler in targetedHandlers) {

				BOOL claimed = NO;
				if( idx == kCCTouchBegan ) {
					claimed = [handler.delegate ccTouchBegan:touch withEvent:event];
					if( claimed )
						[handler.claimedTouches addObject:touch];
				}

				// else (moved, ended, cancelled)
				else if( [handler.claimedTouches containsObject:touch] ) {
					claimed = YES;
					if( handler.enabledSelectors & helper.type )
						[handler.delegate performSelector:helper.touchSel withObject:touch withObject:event];

					if( helper.type & (kCCTouchSelectorCancelledBit | kCCTouchSelectorEndedBit) )
						[handler.claimedTouches removeObject:touch];
				}

				if( claimed && handler.swallowsTouches ) {
					if( needsMutableSet )
						[mutableTouches removeObject:touch];
					break;
				}
			}
		}
	}

	//
	// process standard handlers 2nd
	//
	if( standardHandlersCount > 0 && [mutableTouches count]>0 ) {
		for( CCTouchHandler *handler in standardHandlers ) {
			if( handler.enabledSelectors & helper.type )
				[handler.delegate performSelector:helper.touchesSel withObject:mutableTouches withObject:event];
		}
	}
	if( needsMutableSet )
		[mutableTouches release];

	//
	// Optimization. To prevent a [handlers copy] which is expensive
	// the add/removes/quit is done after the iterations
	//
	locked = NO;

	//issue 1084, 1139 first add then remove
	if( toAdd ) {
		toAdd = NO;
		Class targetedClass = [CCTargetedTouchHandler class];

		for( CCTouchHandler *handler in handlersToAdd ) {
			if( [handler isKindOfClass:targetedClass] )
				[self forceAddHandler:handler array:targetedHandlers];
			else
				[self forceAddHandler:handler array:standardHandlers];
		}
		[handlersToAdd removeAllObjects];
	}

	if( toRemove ) {
		toRemove = NO;
		for( id delegate in handlersToRemove )
			[self forceRemoveDelegate:delegate];
		[handlersToRemove removeAllObjects];
	}

	if( toQuit ) {
		toQuit = NO;
		[self forceRemoveAllDelegates];
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

#endif // __CC_PLATFORM_IOS
