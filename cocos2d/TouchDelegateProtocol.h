/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */
#import <UIKit/UIKit.h>

/**
 TargetedTouchDelegate.
 Updates of claimed touches (move/ended/cancelled) are sent only to the
 delegate(s) that claimed them when they began. In other words, updates
 will "target" their specific handler, without bothering the other handlers. 
 @since v0.8
 */
@protocol TargetedTouchDelegate <NSObject>

/** Return YES to claim the touch.
 Updates of claimed touches (move/ended/cancelled) are sent only to the
 delegate(s) that claimed them when they began. In other words, updates
 will "target" their specific handler, without bothering the other handlers.
 @since v0.8
 */
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
@optional
// touch updates:
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;
@end

/**
 StandardTouchDelegate.
 Each event that is received will be propagated to the delegate,
 unless a previous delegate consumes the event.
 To consume the event (prevent propagation) the delegate should return kEventHandled.
 To ignore the event (the event will be forwarded to the next delegate in the chain) the delegate should return kEventIgnored.
 @since v0.8
*/
@protocol StandardTouchDelegate <NSObject>
@optional
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

/** types of events to handle
 @since v0.8
 */
typedef enum
{
	/// No Touch events will be forwarded (default)
	kTouchHandlerNone,
	/// Standard events will be forwarded (like in v0.7)
	kTouchHandlerStandard,
	/// Targeted events will be forwarded
	kTouchHandlerTargeted,
} ccTouchHandlerType;


enum {
	/// return kEventHandled if the event should NOT be forwarded to the next handler in the chain
	kEventHandled = YES,
	/// return kEventIgnored if the event should be forwarded to the next handler in the chain
	kEventIgnored = NO,
};


