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

#import <UIKit/UIKit.h>

/**
 CCTouchOneByOneDelegate.

 Using this type of delegate results in two benefits:
 1. You don't need to deal with NSSets, the dispatcher does the job of splitting
 them. You get exactly one UITouch per call.
 2. You can *claim* a UITouch by returning YES in ccTouchBegan. Updates of claimed
 touches are sent only to the delegate(s) that claimed them. So if you get a move/
 ended/cancelled update you're sure it is your touch. This frees you from doing a
 lot of checks when doing multi-touch.

 (The name TargetedTouchDelegate relates to updates "targeting" their specific
 handler, without bothering the other handlers.)
 @since v0.8
 */
@protocol CCTouchOneByOneDelegate <NSObject>

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
 CCTouchAllAtOnceDelegate.

 This type of delegate is the same one used by CocoaTouch. You will receive all the events (Began,Moved,Ended,Cancelled).
 @since v0.8
*/
@protocol CCTouchAllAtOnceDelegate <NSObject>
@optional
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

#endif // __CC_PLATFORM_IOS
