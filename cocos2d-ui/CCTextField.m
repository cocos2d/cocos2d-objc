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

#import "CCTextField.h"
#import "CCControlSubclass.h"
#import "CCDirector_Private.h"
#import "CCPlatformTextField.h"
#if __CC_PLATFORM_IOS
#import "CCPlatformTextFieldIOS.h"
#elif __CC_PLATFORM_MAC
#import "CCPlatformTextFieldMac.h"
#elif __CC_PLATFORM_ANDROID
#import "CCPlatformTextFieldAndroid.h"
#endif

@implementation CCTextField {

}

+ (id) textFieldWithSpriteFrame:(CCSpriteFrame *)frame
{
    return [[self alloc] initWithSpriteFrame:frame];
}

- (id) init
{
    return [self initWithSpriteFrame:NULL];
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)frame
{
    self = [super init];
    if (!self) return NULL;
    
    if (frame)
    {
        _background = [[CCSprite9Slice alloc] initWithSpriteFrame:frame];
    }
    else
    {
        _background = [[CCSprite9Slice alloc] init];
    }
    
    [self addChild:_background];
    
#if __CC_PLATFORM_IOS
    _platformTextField = [[CCPlatformTextFieldIOS alloc] init];
#elif __CC_PLATFORM_ANDROID
    _platformTextField = [[CCPlatformTextFieldAndroid alloc] init];
#elif __CC_PLATFORM_MAC
    _platformTextField = [[CCPlatformTextFieldMac alloc] init];
#endif
    _platformTextField.delegate = self;
    // Set default font size
    [self setFontSize: 17];

    
    _padding = 4;
    
    return self;
}

#if __CC_PLATFORM_IOS
- (UITextField *)textField {
    return _platformTextField.nativeTextField;
}
#elif __CC_PLATFORM_MAC
- (NSTextField *)textField {
    return _platformTextField.nativeTextField;
}
#endif


- (void) setString:(NSString *)string {
    _platformTextField.string = string;
}

- (NSString *)string {
    return _platformTextField.string;
}


- (void) onEnter
{
    [super onEnter];
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];

    [_platformTextField onEnterTransitionDidFinish];
    [_platformTextField positionInControl:self padding:_padding];

}

- (void) onExitTransitionDidStart
{
    [super onExitTransitionDidStart];

    [_platformTextField onExitTransitionDidStart];

}

- (void) update:(CCTime)delta
{
    BOOL isVisible = self.visible;
    if (isVisible) {
    	// run through ancestors and see if we are visible
        for (CCNode *parent = self.parent; parent && isVisible; parent = parent.parent)
            isVisible &= parent.visible;
    }
    
    // hide the UITextField if node is invisible

    _platformTextField.hidden = !isVisible;

    
    if (isVisible)  [_platformTextField positionInControl:self padding:_padding];
}

- (void) layout
{
    CGSize sizeInPoints = [self convertContentSizeToPoints: self.preferredSize type:self.preferredSizeType];
    
    [_background setContentSize:sizeInPoints];
    _background.anchorPoint = ccp(0,0);
    _background.position = ccp(0,0);
    
    self.contentSize = [self convertContentSizeFromPoints: sizeInPoints type:self.contentSizeType];
    

    [_platformTextField setFontSize:self.fontSizeInPoints];
    [super layout];
}

- (void) setEnabled:(BOOL)enabled {
//#if !__CC_PLATFORM_ANDROID
//    _textField.enabled = enabled;
//#endif
    [super setEnabled:enabled];
}




#pragma mark Properties



- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame
{
    _background.spriteFrame = spriteFrame;
}

- (CCSpriteFrame*) backgroundSpriteFrame
{
    return _background.spriteFrame;
}

- (void) setFontSize:(float)fontSize
{
    _fontSize = fontSize;
    [self needsLayout];
}

- (float) fontSizeInPoints
{
    if (self.contentSizeType.heightUnit == CCSizeUnitUIPoints)
    {
        return _fontSize * [CCDirector sharedDirector].UIScaleFactor;
    }
    else
    {
        return _fontSize;
    }
}

- (void) platformTextFieldDidFinishEditing:(CCPlatformTextField *) platformTextField {
    [self triggerAction];
}

@end
