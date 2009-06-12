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
 */
@protocol TargetedTouchDelegate <NSObject>

/** Return YES to claim the touch.
 Updates of claimed touches (move/ended/cancelled) are sent only to the
 delegate(s) that claimed them when they began. In other words, updates
 will "target" their specific handler, without bothering the other handlers.
 */
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
@optional
// touch updates:
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;
@end

/**
 DirectTouchDelegate.
 Every event that is received will be propagated to the delegate,
 unless a previous delegate consumes the event.
 To consume the event (prevent propagation) you should return kEventHandled.
 To ignore the event (the event will be forwarded to the next delegate in the chain) return kEventIgnored.
*/
@protocol DirectTouchDelegate <NSObject>
@optional
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end


