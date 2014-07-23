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

#import "CCControl.h"
#import "CCControlSubclass.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "CCTouch.h"
#import "CCTouchEvent.h"

#if __CC_PLATFORM_IOS

// iOS headers
//#import "PlatformTouch+CC.h"


#elif __CC_PLATFORM_MAC

// Mac headers
#import "NSEvent+CC.h"

#endif


@implementation CCControl

#pragma mark Initializers

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.userInteractionEnabled = YES;
    self.exclusiveTouch = YES;
    
    return self;
}

#pragma mark Action handling

- (void) setTarget:(id)target selector:(SEL)selector
{
    __weak id weakTarget = target; // avoid retain cycle
    [self setBlock:^(id sender) {
        typedef void (*Func)(id, SEL, id);
        ((Func)objc_msgSend)(weakTarget, selector, sender);
	}];
}

- (void) triggerAction
{
    if (self.enabled && _block)
    {
        _block(self);
    }
}

#pragma mark Touch handling

#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID

- (void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    _tracking = YES;
    _touchInside = YES;
    
    [self touchEntered:touch withEvent:event];
}

- (void) touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if ([self hitTestWithWorldPos:[touch locationInWorld]])
    {
        if (!_touchInside)
        {
            [self touchEntered:touch withEvent:event];
            _touchInside = YES;
        }
    }
    else
    {
        if (_touchInside)
        {
            [self touchExited:touch withEvent:event];
            _touchInside = NO;
        }
    }
}

- (void) touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if (_touchInside)
    {
        [self touchUpInside:touch withEvent:event];
    }
    else
    {
        [self touchUpOutside:touch withEvent:event];
    }
    
    _touchInside = NO;
    _tracking = NO;
}

- (void) touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    if (_touchInside)
    {
        [self touchUpOutside:touch withEvent:event];
        [self touchExited:touch withEvent:event];
    }
    
    _touchInside = NO;
    _tracking = NO;
}

- (void) touchEntered:(CCTouch*) touch withEvent:(CCTouchEvent*)event
{}

- (void) touchExited:(CCTouch*) touch withEvent:(CCTouchEvent*) event
{}

- (void) touchUpInside:(CCTouch*) touch withEvent:(CCTouchEvent*) event
{}

- (void) touchUpOutside:(CCTouch*) touch withEvent:(CCTouchEvent*) event
{}

#elif __CC_PLATFORM_MAC

- (void) mouseDown:(NSEvent *)event
{
    _tracking = YES;
    _touchInside = YES;
    
    [self mouseDownEntered:event];
}

- (void) mouseDragged:(NSEvent *)event
{
    if ([self hitTestWithWorldPos:[event locationInWorld]])
    {
        if (!_touchInside)
        {
            [self mouseDownEntered:event];
            _touchInside = YES;
        }
    }
    else
    {
        if (_touchInside)
        {
            [self mouseDownExited:event];
            _touchInside = NO;
        }
    }
}

- (void) mouseUp:(NSEvent *)event
{
    if (_touchInside)
    {
        [self mouseUpInside:event];
    }
    else
    {
        [self mouseUpOutside:event];
    }
    
    _touchInside = NO;
    _tracking = NO;
}

- (void) mouseDownEntered:(NSEvent*) event
{}

- (void) mouseDownExited:(NSEvent*) event
{}

- (void) mouseUpInside:(NSEvent*) event
{}

- (void) mouseUpOutside:(NSEvent*) event
{}

#endif


#pragma mark State properties

- (BOOL) enabled
{
    if (!(_state & CCControlStateDisabled)) return YES;
    else return NO;
}

- (void) setEnabled:(BOOL)enabled
{
    if (self.enabled == enabled) return;
    
    BOOL disabled = !enabled;
    
    if (disabled)
    {
        _state |= CCControlStateDisabled;
    }
    else
    {
        _state &= ~CCControlStateDisabled;
    }
    
    [self stateChanged];
}

- (BOOL) selected
{
    if (_state & CCControlStateSelected) return YES;
    else return NO;
}

- (void) setSelected:(BOOL)selected
{
    if (self.selected == selected) return;
    
    if (selected)
    {
        _state |= CCControlStateSelected;
    }
    else
    {
        _state &= ~CCControlStateSelected;
    }
    
    [self stateChanged];
}

- (BOOL) highlighted
{
    if (_state & CCControlStateHighlighted) return YES;
    else return NO;
}

- (void) setHighlighted:(BOOL)highlighted
{
    if (self.highlighted == highlighted) return;
    
    if (highlighted)
    {
        _state |= CCControlStateHighlighted;
    }
    else
    {
        _state &= ~CCControlStateHighlighted;
    }
    
    [self stateChanged];
}

#pragma mark Layout and state changes

- (void) stateChanged
{
    [self needsLayout];
}

- (void) needsLayout
{
    _needsLayout = YES;
}

- (void) layout
{
    _needsLayout = NO;
}

- (void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    if (_needsLayout) [self layout];
    [super visit:renderer parentTransform:parentTransform];
}

- (CGSize) contentSize
{
    if (_needsLayout) [self layout];
    return [super contentSize];
}

- (void) onEnter
{
    [self needsLayout];
    [super onEnter];
}

- (void) setContentSizeType:(CCSizeType)contentSizeType
{
    [super setContentSizeType:contentSizeType];
    [self needsLayout];
}

- (void) setPreferredSize:(CGSize)preferredSize
{
    _preferredSize = preferredSize;
    [self needsLayout];
}

- (void) setMaxSize:(CGSize)maxSize
{
    _maxSize = maxSize;
    [self needsLayout];
}

- (void) setPreferredSizeType:(CCSizeType)preferredSizeType
{
    self.contentSizeType = preferredSizeType;
}

- (CCSizeType) preferredSizeType
{
    return self.contentSizeType;
}

- (void) setMaxSizeType:(CCSizeType)maxSizeType
{
    self.contentSizeType = maxSizeType;
}

- (CCSizeType) maxSizeType
{
    return self.contentSizeType;
}


#pragma mark Setting properties for control states by name

- (CCControlState) controlStateFromString:(NSString*)stateName
{
    CCControlState state = 0;
    if ([stateName isEqualToString:@"Normal"]) state = CCControlStateNormal;
    else if ([stateName isEqualToString:@"Highlighted"]) state = CCControlStateHighlighted;
    else if ([stateName isEqualToString:@"Disabled"]) state = CCControlStateDisabled;
    else if ([stateName isEqualToString:@"Selected"]) state = CCControlStateSelected;
    
    return state;
}

- (void) setValue:(id)value forKey:(NSString *)key state:(CCControlState) state
{
}

- (id) valueForKey:(NSString *)key state:(CCControlState)state
{
    return NULL;
}

- (void) setValue:(id)value forKey:(NSString *)key
{
    NSRange separatorRange = [key rangeOfString:@"|"];
    NSUInteger separatorLoc = separatorRange.location;
    
    if (separatorLoc == NSNotFound)
    {
        [super setValue:value forKey:key];
        return;
    }
    
    NSString* propName = [key substringToIndex:separatorLoc];
    NSString* stateName = [key substringFromIndex:separatorLoc+1];
    
    CCControlState state = [self controlStateFromString:stateName];
    
    [self setValue:value forKey:propName state:state];
}

- (id) valueForKey:(NSString *)key
{
    NSRange separatorRange = [key rangeOfString:@"|"];
    NSUInteger separatorLoc = separatorRange.location;
    
    if (separatorLoc == NSNotFound)
    {
        return [super valueForKey:key];
    }
    
    NSString* propName = [key substringToIndex:separatorLoc];
    NSString* stateName = [key substringFromIndex:separatorLoc+1];
    
    CCControlState state = [self controlStateFromString:stateName];
    
    return [self valueForKey:propName state:state];
}

@end
