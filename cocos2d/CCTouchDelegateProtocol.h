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
 
 This type of delegate is the same one used by CocoaTouch. You will receive all the events (Began,Moved,Ended,Cancelled).
 @since v0.8
*/
@protocol CCStandardTouchDelegate <NSObject>
@optional
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end
