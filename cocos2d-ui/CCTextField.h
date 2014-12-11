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

#import "CCPlatformTextField.h"

#if __CC_PLATFORM_ANDROID
#import <AndroidKit/AndroidEditText.h>
#endif


@class CCPlatformTextField;

/**
 A text field is used for editing text. It is implemented by encapsulating the platform's native text field ([NSTextField](https://developer.apple.com/library/mac/Documentation/Cocoa/Reference/ApplicationKit/Classes/NSTextField_Class/index.html#//apple_ref/doc/uid/20000128-SW2)
 on Mac and [UITextField](https://developer.apple.com/library/ios/documentation/Uikit/reference/UITextField_Class/index.html) on iOS and
 [EditText](http://developer.android.com/reference/android/widget/EditText.html) on Android).
 
 An action callback will be sent when the user is done editing the text (clicks/taps outside) or when the return key is pressed.
 
 A CCSprite9Slice is used a the text field's background image.
 
 @note The native text field is only translated (positioned), no other transformations (rotation, scale) are applied.
 The text field may not be displayed correctly if the node is rotated, scaled, skewed.
 
 @warning Since the text field is a native UI control, it will always be drawn on top of everything that Cocos2D draws. That means you can't
 have another node (ie a sprite) partially or entirely drawn above the text field.
 */
@interface CCTextField : CCControl <CCPlatformTextFieldDelegate>
{
    CCSprite9Slice* _background;

}

/** @name Creating a Text Field */

/**
 *  Creates a new text field with the specified sprite frame used as its background.
 *
 *  @param frame Sprite frame to use as the text fields background.
 *
 *  @return Returns a new text field.
 */
+ (id) textFieldWithSpriteFrame:(CCSpriteFrame*)frame;

/**
 Initializes a text field with the specified sprite frame used as its background.
 
 @param frame Sprite frame to use as the text fields background.
 
 @return Returns a new text field.
 */
- (id) initWithSpriteFrame:(CCSpriteFrame*)frame;

/** @name Accessing the Platform-Specific Text Field */

/** The platform-native text field object. On iOS it's a UITextField, on OS X it's a NSTextField, on Android it's a EditText.
 @see [UITextField](https://developer.apple.com/library/ios/documentation/Uikit/reference/UITextField_Class/index.html)
 @see [NSTextField](https://developer.apple.com/library/mac/Documentation/Cocoa/Reference/ApplicationKit/Classes/NSTextField_Class/index.html#//apple_ref/doc/uid/20000128-SW2)
 @see [EditText](http://developer.android.com/reference/android/widget/EditText.html)
 */
#if __CC_PLATFORM_IOS
@property (nonatomic,readonly) UITextField* textField;
#elif __CC_PLATFORM_MAC
@property (nonatomic,readonly) NSTextField* textField;
#elif __CC_PLATFORM_ANDROID
@property (nonatomic,readonly) AndroidEditText* textField;
#endif

// purposefully undocumented: internal property
@property (nonatomic,readonly) CCPlatformTextField *platformTextField;

/** @name Changing the Text Field's Appearance */

/** The sprite frame used to render the text field's background.
 @see CCSpriteFrame */
@property (nonatomic,strong) CCSpriteFrame* backgroundSpriteFrame;

/** The font size of the text field, defined in the unit specified by the heightUnit component of the contentSizeType. */
@property (nonatomic,assign) float fontSize;

/* The font size of the text field in points. */
@property (nonatomic,readonly) float fontSizeInPoints;

/** Padding from the edge of the text field's background to the native text field component. */
@property (nonatomic,assign) CGFloat padding;

/** The text displayed by the text field. Directly forwarded to/from the native text field object. */
@property (nonatomic,strong) NSString* string;

@end
