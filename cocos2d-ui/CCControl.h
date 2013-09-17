/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
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

#import "CCNode.h"

/** The possible state for a control.  */
enum
{
    CCControlStateNormal       = 1 << 0, // The normal, or default state of a control—that is, enabled but neither selected nor highlighted.
    CCControlStateHighlighted  = 1 << 1, // Highlighted state of a control. A control enters this state when a touch down, drag inside or drag enter is performed. You can retrieve and set this value through the highlighted property.
    CCControlStateDisabled     = 1 << 2, // Disabled state of a control. This state indicates that the control is currently disabled. You can retrieve and set this value through the enabled property.
    CCControlStateSelected     = 1 << 3  // Selected state of a control. This state indicates that the control is currently selected. You can retrieve and set this value through the selected property.
};
typedef NSUInteger CCControlState;

@interface CCControl : CCNode
{
    BOOL _needsLayout;
}

@property (nonatomic,assign) CGSize preferredSize;
@property (nonatomic,assign) CGSize maxSize;

@property (nonatomic,assign) CCControlState state;
@property (nonatomic,assign) BOOL enabled;
@property (nonatomic,assign) BOOL selected;
@property (nonatomic,assign) BOOL highlighted;

@property (nonatomic,assign) BOOL continuous;

@property (nonatomic,readonly) BOOL tracking;
@property (nonatomic,readonly) BOOL touchInside;

@property (nonatomic,copy) void(^block)(id sender);
-(void) setTarget:(id)target selector:(SEL)selector;

- (void) triggerAction;
- (void) stateChanged;

- (void) needsLayout;
- (void) layout;

#ifdef __CC_PLATFORM_IOS
- (void) touchEntered:(UITouch*) touch withEvent:(UIEvent*)event;
- (void) touchExited:(UITouch*) touch withEvent:(UIEvent*) event;
- (void) touchUpInside:(UITouch*) touch withEvent:(UIEvent*) event;
- (void) touchUpOutside:(UITouch*) touch withEvent:(UIEvent*) event;
#elif defined (__CC_PLATFORM_MAC)
- (void) mouseDownEntered:(NSEvent*) event;
- (void) mouseDownExited:(NSEvent*) event;
- (void) mouseUpInside:(NSEvent*) event;
- (void) mouseUpOutside:(NSEvent*) event;
#endif
@end
