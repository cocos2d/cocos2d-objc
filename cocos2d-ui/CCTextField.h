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

#import "cocos2d.h"
#import "CCControl.h"

#ifdef __CC_PLATFORM_IOS
/**
 The CCTextField is used for editing text by encapsulating a native text field (NSTextField on Mac and UITextField on iOS). An action callback will be sent when the text finishes editing or if the return key is pressed.
 
 @warning The native text field is only translated, no other transformations are applied. The text field may not be displayed correctly if rotated or scaled.
 */
@interface CCTextField : CCControl <UITextFieldDelegate>
#elif defined(__CC_PLATFORM_MAC)
@interface CCTextField : CCControl <NSTextFieldDelegate>
#endif
{
    CCSprite9Slice* _background;
#ifdef __CC_PLATFORM_IOS
    BOOL _keyboardIsShown;
    float _keyboardHeight;
#endif
}

/**
 *  Creates a new text field with the specified sprite frame used as its background.
 *
 *  @param frame Sprite frame to use as the text fields background.
 *
 *  @return Returns a new text field.
 */
+ (id) textFieldWithSpriteFrame:(CCSpriteFrame*)frame;

/**
 *  Initializes a text field with the specified sprite frame used as its background.
 *
 *  @param frame Sprite frame to use as the text fields background.
 *
 *  @return Returns a new text field.
 */
- (id) initWithSpriteFrame:(CCSpriteFrame*)frame;

#ifdef __CC_PLATFORM_IOS
/** iOS: UITextField used by the CCTextField. */
@property (nonatomic,readonly) UITextField* textField;
#elif defined(__CC_PLATFORM_MAC)

/** Mac: NSTextField used by the CCTextField. */
@property (nonatomic,readonly) NSTextField* textField;
#endif

/** The sprite frame used to render the text field's background. */
@property (nonatomic,strong) CCSpriteFrame* backgroundSpriteFrame;

/** Padding from the edge of the text field's background to the native text field component. */
@property (nonatomic,assign) float padding;

/** The text displayed by the text field. */
@property (nonatomic,strong) NSString* string;

@end
