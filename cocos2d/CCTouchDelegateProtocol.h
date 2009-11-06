/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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
 CCTargetedTouchDelegate.
 
 Using this type of delegate results in two benefits:
 1. You don't need to deal with NSSets, the dispatcher does the job of splitting
 them. You get exactly one UITouch per call.
 2. You can *claim* a UITouch by returning YES in ccTouchBegan. Updates of claimed
 touches are sent only to the delegate(s) that claimed them. So if you get a move/
 ended/cancelled update you're sure it's your touch. This frees you from doing a
 lot of checks when doing multi-touch.
 
 (The name TargetedTouchDelegate relates to updates "targeting" their specific
 handler, without bothering the other handlers.)
 @since v0.8
 */
@protocol CCTargetedTouchDelegate <NSObject>

/** Return YES to claim the touch.
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
 CCStandardTouchDelegate.
 Each event that is received will be propagated to the delegate,
 unless a previous delegate consumes the event.
 To consume the event (prevent propagation) the delegate should return kEventHandled.
 To ignore the event (the event will be forwarded to the next delegate in the chain) the delegate should return kEventIgnored.
 @since v0.8
*/
@protocol CCStandardTouchDelegate <NSObject>
@optional
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

enum {
	/// return kEventHandled if the event should NOT be forwarded to the next handler in the chain
	kEventHandled = YES,
	/// return kEventIgnored if the event should be forwarded to the next handler in the chain
	kEventIgnored = NO,
};
