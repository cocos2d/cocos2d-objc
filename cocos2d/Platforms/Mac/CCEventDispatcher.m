/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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

#import "CCEventDispatcher.h"

static CCEventDispatcher *sharedDispatcher = nil;

enum  {
	kCCImplementsMouseDown = 1 << 0,
	kCCImplementsMouseUp = 1 << 1,
	kCCImplementsMouseMoved = 1 << 2,
	kCCImplementsMouseDragged = 1 << 3,
	
	kCCImplementsKeyUp = 1 << 0,
	kCCImplementsKeyDown = 1 << 1,
};


typedef struct _listEntry
{
	struct	_listEntry	*prev, *next;
	id					delegate;
	NSInteger			priority;
	NSUInteger			flags;
} tListEntry;

@implementation CCEventDispatcher

@synthesize dispatchEvents=dispatchEvents_;


+(CCEventDispatcher*) sharedDispatcher
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
	if( (self = [super init]) )
	{
		// events enabled by default
		dispatchEvents_ = YES;

		// delegates
		keyboardDelegates_ = NULL;
		mouseDelegates_ = NULL;
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

#pragma mark CCEventDispatcher - add / remove delegates

-(void) addDelegate:(id)delegate priority:(NSInteger)priority flags:(NSUInteger)flags list:(tListEntry**)list
{
	tListEntry *listElement = malloc( sizeof(*listElement) );
	
	listElement->delegate = delegate;
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

-(void) removeDelegate:(id)delegate fromList:(tListEntry**)list
{
	tListEntry *entry, *tmp;
	
	// updates with priority < 0
	DL_FOREACH_SAFE( *list, entry, tmp ) {
		if( entry->delegate == delegate ) {
			DL_DELETE( *list, entry );
			free(entry);
			break;
		}
	}
}

-(void) removeAllDelegatesFromList:(tListEntry**)list
{
	tListEntry *entry, *tmp;

	DL_FOREACH_SAFE( *list, entry, tmp ) {
		DL_DELETE( *list, entry );
		free(entry);
	}
}


-(void) addMouseDelegate:(id<CCMouseEventDelegate>) delegate priority:(NSInteger)priority
{
	NSUInteger flags = 0;
	
	flags |= ( [delegate respondsToSelector:@selector(ccMouseUp:)] ? kCCImplementsMouseUp : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseDown:)] ? kCCImplementsMouseDown : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseDragged:)] ? kCCImplementsMouseDragged : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseMoved:)] ? kCCImplementsMouseMoved : 0 );
	
	[self addDelegate:delegate priority:priority flags:flags list:&mouseDelegates_];
}

-(void) removeMouseDelegate:(id) delegate
{
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
	
	[self addDelegate:delegate priority:priority flags:flags list:&keyboardDelegates_];
}

-(void) removeKeyboardDelegate:(id) delegate
{
	[self removeDelegate:delegate fromList:&keyboardDelegates_];
}

-(void) removeAllKeyboardDelegates
{
	[self removeAllDelegatesFromList:&keyboardDelegates_];
}

#pragma mark CCEventDispatcher - Mouse events
// Mouse events
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

- (void)mouseUp:(NSEvent *)event
{
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

#pragma mark CCEventDispatcher - Touch events

- (void)touchesBeganWithEvent:(NSEvent *)event
{
	if (dispatchEvents_ ) {
		NSLog(@"Touch Events: Not supported yet");
	}
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
	if (dispatchEvents_ ) {
		NSLog(@"Touch Events: Not supported yet");
	}
}

- (void)touchesEndedWithEvent:(NSEvent *)event
{
	if (dispatchEvents_ ) {
		NSLog(@"Touch Events: Not supported yet");
	}
}

- (void)touchesCancelledWithEvent:(NSEvent *)event
{
	if (dispatchEvents_ ) {
		NSLog(@"Touch Events: Not supported yet");
	}
}
@end
