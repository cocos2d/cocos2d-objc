/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
 */

// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#ifdef __CC_PLATFORM_MAC

#import "CCEventDispatcher.h"
#import "../../CCDirector.h"
#import "../../ccConfig.h"

enum  {
	// mouse
	kCCImplementsMouseDown			= 1 << 0,
	kCCImplementsMouseMoved			= 1 << 1,
	kCCImplementsMouseDragged		= 1 << 2,
	kCCImplementsMouseUp			= 1 << 3,
	kCCImplementsRightMouseDown		= 1 << 4,
	kCCImplementsRightMouseDragged	= 1 << 5,
	kCCImplementsRightMouseUp		= 1 << 6,
	kCCImplementsOtherMouseDown		= 1 << 7,
	kCCImplementsOtherMouseDragged	= 1 << 8,
	kCCImplementsOtherMouseUp		= 1 << 9,
	kCCImplementsScrollWheel		= 1 << 10,
	kCCImplementsMouseEntered		= 1 << 11,
	kCCImplementsMouseExited		= 1 << 12,

	kCCImplementsTouchesBegan		= 1 << 13,
	kCCImplementsTouchesMoved		= 1 << 14,
	kCCImplementsTouchesEnded		= 1 << 15,
	kCCImplementsTouchesCancelled	= 1 << 16,

    // gesture
    kCCImplementsBeginGestureWithEvent = 1 << 0,
    kCCImplementsMagnifyWithEvent      = 1 << 1,
    kCCImplementsSmartMagnifyWithEvent = 1 << 2,
    kCCImplementsRotateWithEvent       = 1 << 3,
    kCCImplementsSwipeWithEvent        = 1 << 4,
    kCCImplementsEndGestureWithEvent   = 1 << 5,
    
	// keyboard
	kCCImplementsKeyUp				= 1 << 0,
	kCCImplementsKeyDown			= 1 << 1,
	kCCImplementsFlagsChanged		= 1 << 2,
};


typedef struct _listEntry
{
	// XXX do no change the order of these 3 fields. Needed for "subclassing"
	struct	_listEntry	*prev, *next;
	id					delegate;
	// (end)

	NSInteger			priority;
	NSUInteger			flags;
} tListEntry;

typedef struct _listDeletedEntry
{
	// XXX do no change the order of these 3 fields. Needed for "subclassing"
	struct	_listDeletedEntry	*prev, *next;
	id							delegate;
	// (end)
	
	struct	_listEntry			**listToBeDeleted;

} tListDeletedEntry;

typedef struct _listAddedEntry
{
	// XXX do no change the order of these 3 fields. Needed for "subclassing"
	struct	_listAddedEntry *prev, *next;
	id						delegate;
	// (end)

	NSInteger				priority;
	NSUInteger				flags;
	struct	_listEntry		**listToBeAdded;
} tListAddedEntry;



#pragma  mark - CCEventObject

@implementation CCEventObject
@end

#pragma  mark - CCEventDispatcher

@interface CCEventDispatcher()
-(BOOL) removeDelegate:(id)delegate fromList:(tListEntry**)list;
@end

@implementation CCEventDispatcher

@synthesize dispatchEvents=dispatchEvents_;

-(id) init
{
	if( (self = [super init]) )
	{
		// events enabled by default
		dispatchEvents_ = YES;

		// delegates
		keyboardDelegates_ = NULL;
		mouseDelegates_ = NULL;
		touchDelegates_ = NULL;
        gestureDelegates_ = NULL;
		
		delegatesToBeAdded_ = NULL;
		delegatesToBeRemoved_ = NULL;
		
		locked_ = NO;
	}

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

#pragma mark CCEventDispatcher - add / remove delegates


-(void) addLaterDelegate:(id)delegate priority:(NSInteger)priority flags:(NSUInteger)flags list:(tListEntry**)list
{
	// XXX: Since, "remove" is "executed" after "add", it is not needed to check if the delegate was already added for removal.
	// In fact, if you remove it now, it could be a bug, since EventDispatcher doesn't support updated priority.
	// And the only way to update the priority is by deleting, re-adding the delegate with a new priority
	tListAddedEntry *listElement = malloc( sizeof(*listElement) );
	
	listElement->delegate = [delegate retain];
	listElement->priority = priority;
	listElement->flags = flags;
	listElement->listToBeAdded = list;
	listElement->next = listElement->prev = NULL;
	
	DL_APPEND( delegatesToBeAdded_, listElement );
}

-(void) addDelegate:(id)delegate priority:(NSInteger)priority flags:(NSUInteger)flags list:(tListEntry**)list
{
	tListEntry *listElement = malloc( sizeof(*listElement) );

	listElement->delegate = [delegate retain];
	listElement->priority = priority;
	listElement->flags = flags;
	listElement->next = listElement->prev = NULL;

	// empty list ?
	if( ! *list ) {
		DL_APPEND( *list, listElement );

	} else {
		BOOL added = NO;

		for( tListEntry *elem = *list; elem ; elem = elem->next ) {
			if( priority < elem->priority ) {

				if( elem == *list )
					DL_PREPEND(*list, listElement);
				else {
					listElement->next = elem;
					listElement->prev = elem->prev;

					elem->prev->next = listElement;
					elem->prev = listElement;
				}

				added = YES;
				break;
			}
		}

		// Not added? priority has the higher value. Append it.
		if( !added )
			DL_APPEND(*list, listElement);
	}
}

-(void) removeLaterDelegate:(id)delegate fromList:(tListEntry**)list
{
	// Only add it if it was not already added for deletion
	if( ! [self removeDelegate:delegate fromList:(tListEntry**)&delegatesToBeAdded_] ) {

		tListDeletedEntry *listElement = malloc( sizeof(*listElement) );
		
		listElement->delegate = [delegate retain];
		listElement->listToBeDeleted = list;
		listElement->next = listElement->prev = NULL;
		
		DL_APPEND( delegatesToBeRemoved_, listElement );
	}
}

-(BOOL) removeDelegate:(id)delegate fromList:(tListEntry**)list
{
	tListEntry *entry, *tmp;
	
	DL_FOREACH_SAFE( *list, entry, tmp ) {
		if( entry->delegate == delegate ) {
			DL_DELETE( *list, entry );
			[delegate release];
			free(entry);
			return YES;
			break;
		}
	}
	return NO;
}

-(void) removeAllDelegatesFromList:(tListEntry**)list
{
	NSAssert( ! locked_, @"BUG. Open a ticket. Can't call this function when processing events.");

	@synchronized(self) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( *list, entry, tmp ) {
			DL_DELETE( *list, entry );
			[entry->delegate release];
			free(entry);
		}
	}
}


-(void) addMouseDelegate:(id<CCMouseEventDelegate>) delegate priority:(NSInteger)priority
{
	NSUInteger flags = 0;

	flags |= ( [delegate respondsToSelector:@selector(ccMouseDown:)] ? kCCImplementsMouseDown : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseDragged:)] ? kCCImplementsMouseDragged : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseMoved:)] ? kCCImplementsMouseMoved : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseUp:)] ? kCCImplementsMouseUp : 0 );

	flags |= ( [delegate respondsToSelector:@selector(ccRightMouseDown:)] ? kCCImplementsRightMouseDown : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccRightMouseDragged:)] ? kCCImplementsRightMouseDragged : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccRightMouseUp:)] ? kCCImplementsRightMouseUp : 0 );

	flags |= ( [delegate respondsToSelector:@selector(ccOtherMouseDown:)] ? kCCImplementsOtherMouseDown : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccOtherMouseDragged:)] ? kCCImplementsOtherMouseDragged : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccOtherMouseUp:)] ? kCCImplementsOtherMouseUp : 0 );

	flags |= ( [delegate respondsToSelector:@selector(ccMouseEntered:)] ? kCCImplementsMouseEntered : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseExited:)] ? kCCImplementsMouseExited : 0 );

	flags |= ( [delegate respondsToSelector:@selector(ccScrollWheel:)] ? kCCImplementsScrollWheel : 0 );

	if( locked_ )
		[self addLaterDelegate:delegate priority:priority flags:flags list:&mouseDelegates_];
	else
		[self addDelegate:delegate priority:priority flags:flags list:&mouseDelegates_];

}

-(void) removeMouseDelegate:(id) delegate
{
	if( locked_ )
		[self removeLaterDelegate:delegate fromList:&mouseDelegates_];
	else
		[self removeDelegate:delegate fromList:&mouseDelegates_];
}

-(void) removeAllMouseDelegates
{
	[self removeAllDelegatesFromList:&mouseDelegates_];
}

-(void) addKeyboardDelegate:(id<CCKeyboardEventDelegate>) delegate priority:(NSInteger)priority
{
	NSUInteger flags = 0;

	flags |= ( [delegate respondsToSelector:@selector(ccKeyUp:)] ? kCCImplementsKeyUp : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccKeyDown:)] ? kCCImplementsKeyDown : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccFlagsChanged:)] ? kCCImplementsFlagsChanged : 0 );

	if( locked_ )
		[self addLaterDelegate:delegate priority:priority flags:flags list:&keyboardDelegates_];
	else
		[self addDelegate:delegate priority:priority flags:flags list:&keyboardDelegates_];
}

-(void) removeKeyboardDelegate:(id) delegate
{
	if( locked_ )
		[self removeLaterDelegate:delegate fromList:&keyboardDelegates_];
	else
		[self removeDelegate:delegate fromList:&keyboardDelegates_];
}

-(void) removeAllKeyboardDelegates
{
	[self removeAllDelegatesFromList:&keyboardDelegates_];
}

-(void) addTouchDelegate:(id<CCTouchEventDelegate>) delegate priority:(NSInteger)priority
{
	NSUInteger flags = 0;

	flags |= ( [delegate respondsToSelector:@selector(ccTouchesBeganWithEvent:)] ? kCCImplementsTouchesBegan : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccTouchesMovedWithEvent:)] ? kCCImplementsTouchesMoved : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccTouchesEndedWithEvent:)] ? kCCImplementsTouchesEnded : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccTouchesCancelledWithEvent:)] ? kCCImplementsTouchesCancelled : 0 );

	if( locked_ )
		[self addLaterDelegate:delegate priority:priority flags:flags list:&touchDelegates_];
	else
		[self addDelegate:delegate priority:priority flags:flags list:&touchDelegates_];
}

-(void) removeTouchDelegate:(id) delegate
{
	if( locked_ )
		[self removeLaterDelegate:delegate fromList:&touchDelegates_];
	else
		[self removeDelegate:delegate fromList:&touchDelegates_];
}

-(void) removeAllTouchDelegates
{
	[self removeAllDelegatesFromList:&touchDelegates_];
}

- (void)addGestureDelegate:(id<CCGestureEventDelegate>)delegate priority:(NSInteger)priority
{
	NSUInteger flags = 0;
    
	flags |= ( [delegate respondsToSelector:@selector(ccBeginGestureWithEvent:)] ? kCCImplementsBeginGestureWithEvent : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMagnifyWithEvent:)] ? kCCImplementsMagnifyWithEvent : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccSmartMagnifyWithEvent:)] ? kCCImplementsSmartMagnifyWithEvent : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccRotateWithEvent:)] ? kCCImplementsRotateWithEvent : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccSwipeWithEvent:)] ? kCCImplementsSwipeWithEvent : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccEndGestureWithEvent:)] ? kCCImplementsEndGestureWithEvent : 0 );
    
	if( locked_ )
		[self addLaterDelegate:delegate priority:priority flags:flags list:&gestureDelegates_];
	else
		[self addDelegate:delegate priority:priority flags:flags list:&gestureDelegates_];
}

- (void)removeGestureDelegate:(id) delegate
{
	if( locked_ )
		[self removeLaterDelegate:delegate fromList:&gestureDelegates_];
	else
		[self removeDelegate:delegate fromList:&gestureDelegates_];
}

- (void)removeAllGestureDelegates
{
	[self removeAllDelegatesFromList:&gestureDelegates_];
}

#pragma mark CCEventDispatcher - Mouse events
//
// Mouse events
//

//
// Left
//
- (void)mouseDown:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseDown ) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseDown:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)mouseMoved:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseMoved ) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseMoved:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)mouseDragged:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseDragged ) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseDragged:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)mouseUp:(NSEvent *)event
{
	@synchronized(self) {
		if( dispatchEvents_ ) {
			tListEntry *entry, *tmp;

			DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
				if ( entry->flags & kCCImplementsMouseUp ) {
					void *swallows = [entry->delegate performSelector:@selector(ccMouseUp:) withObject:event];
					if( swallows )
						break;
				}
			}
		}
	}
}

//
// Mouse Right
//
- (void)rightMouseDown:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsRightMouseDown ) {
				void *swallows = [entry->delegate performSelector:@selector(ccRightMouseDown:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)rightMouseDragged:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsRightMouseDragged ) {
				void *swallows = [entry->delegate performSelector:@selector(ccRightMouseDragged:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)rightMouseUp:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsRightMouseUp ) {
				void *swallows = [entry->delegate performSelector:@selector(ccRightMouseUp:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

//
// Mouse Other
//
- (void)otherMouseDown:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsOtherMouseDown ) {
				void *swallows = [entry->delegate performSelector:@selector(ccOtherMouseDown:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)otherMouseDragged:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsOtherMouseDragged ) {
				void *swallows = [entry->delegate performSelector:@selector(ccOtherMouseDragged:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)otherMouseUp:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsOtherMouseUp ) {
				void *swallows = [entry->delegate performSelector:@selector(ccOtherMouseUp:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

//
// Scroll Wheel
//
- (void)scrollWheel:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsScrollWheel ) {
				void *swallows = [entry->delegate performSelector:@selector(ccScrollWheel:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

//
// Mouse enter / exit
- (void)mouseExited:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags &  kCCImplementsMouseExited) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseExited:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)mouseEntered:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseEntered) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseEntered:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}


#pragma mark CCEventDispatcher - Keyboard events

// Keyboard events
- (void)keyDown:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( keyboardDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsKeyDown ) {
				void *swallows = [entry->delegate performSelector:@selector(ccKeyDown:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)keyUp:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( keyboardDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsKeyUp ) {
				void *swallows = [entry->delegate performSelector:@selector(ccKeyUp:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)flagsChanged:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( keyboardDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsFlagsChanged ) {
				void *swallows = [entry->delegate performSelector:@selector(ccFlagsChanged:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}


#pragma mark CCEventDispatcher - Touch events

- (void)touchesBeganWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsTouchesBegan) {
				void *swallows = [entry->delegate performSelector:@selector(ccTouchesBeganWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsTouchesMoved) {
				void *swallows = [entry->delegate performSelector:@selector(ccTouchesMovedWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)touchesEndedWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsTouchesEnded) {
				void *swallows = [entry->delegate performSelector:@selector(ccTouchesEndedWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)touchesCancelledWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsTouchesCancelled) {
				void *swallows = [entry->delegate performSelector:@selector(ccTouchesCancelledWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

#pragma mark CCEventDispatcher - Gesture events

- (void)beginGestureWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
        
		DL_FOREACH_SAFE( gestureDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsBeginGestureWithEvent) {
				void *swallows = [entry->delegate performSelector:@selector(ccBeginGestureWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)magnifyWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
        
		DL_FOREACH_SAFE( gestureDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMagnifyWithEvent) {
				void *swallows = [entry->delegate performSelector:@selector(ccMagnifyWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)smartMagnifyWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
        
		DL_FOREACH_SAFE( gestureDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsSmartMagnifyWithEvent) {
				void *swallows = [entry->delegate performSelector:@selector(ccSmartMagnifyWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)rotateWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
        
		DL_FOREACH_SAFE( gestureDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsRotateWithEvent) {
				void *swallows = [entry->delegate performSelector:@selector(ccRotateWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)swipeWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
        
		DL_FOREACH_SAFE( gestureDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsSwipeWithEvent) {
				void *swallows = [entry->delegate performSelector:@selector(ccSwipeWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)endGestureWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
        
		DL_FOREACH_SAFE( gestureDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsEndGestureWithEvent) {
				void *swallows = [entry->delegate performSelector:@selector(ccEndGestureWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

#pragma mark CCEventDispatcher - Dispatch

- (void)dispatchEvent:(CCEventObject*)e
{
	@synchronized(self)
	{
		NSEvent *event = e->event;
		SEL selector = e->selector;

		// Dispatch events
		if( dispatchEvents_ ) {
			locked_ = YES;
			[self performSelector:selector onThread:[[CCDirector sharedDirector] runningThread] withObject:event waitUntilDone:YES];
			locked_ = NO;
		}
		
		
		[event release];
		
		// FIRST: Remove possible delegates
		tListDeletedEntry *dEntry, *tTmp;
		DL_FOREACH_SAFE( delegatesToBeRemoved_ , dEntry, tTmp ) {
			
			[self removeDelegate:dEntry->delegate fromList:dEntry->listToBeDeleted];
			
			DL_DELETE( delegatesToBeRemoved_, dEntry );
			[dEntry->delegate release];
			free(dEntry);
		}
		
		// LATER: Add possible delegates
		tListAddedEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( delegatesToBeAdded_, entry, tmp ) {
			
			[self addDelegate:entry->delegate priority:entry->priority flags:entry->flags list:entry->listToBeAdded];
			
			DL_DELETE( delegatesToBeAdded_, entry );
			[entry->delegate release];
			free(entry);
		}
		
	}
}

@end

#endif // __CC_PLATFORM_MAC
