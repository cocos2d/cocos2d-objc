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
 TargetedTouchDelegate
*/
@protocol TargetedTouchDelegate <NSObject>

/** Return YES to claim the touch.
 Updates of claimed touches (move/ended/cancelled) are sent only to the
 delegate(s) that claimed them when they began. In other words, updates
 will "target" their specific handler, without bothering the other handlers.
 */
- (BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
@optional
// touch updates:
- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;
@end
