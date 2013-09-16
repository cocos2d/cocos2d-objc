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

@interface CCButton : CCControl
{
    NSMutableDictionary* _backgroundSpriteFrames;
    NSMutableDictionary* _backgroundColors;
    NSMutableDictionary* _backgroundOpacities;
    NSMutableDictionary* _labelColors;
    NSMutableDictionary* _labelOpacities;
    float _originalScaleX;
    float _originalScaleY;
}

@property (nonatomic,readonly) CCSprite9Slice* background;
@property (nonatomic,readonly) CCLabelTTF* label;
@property (nonatomic,assign) BOOL zoomWhenHighlighted;
@property (nonatomic,assign) float horizontalPadding;
@property (nonatomic,assign) float verticalPadding;

+ (id) buttonWithTitle:(NSString*) title;
+ (id) buttonWithTitle:(NSString*) title fontName:(NSString*)fontName fontSize:(float)size;
+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame;
+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled;

- (id) initWithTitle:(NSString*) title;
- (id) initWithTitle:(NSString *)title fontName:(NSString*)fontName fontSize:(float)size;
- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame;
- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled;

- (void) setBackgroundColor:(ccColor3B) color forState:(CCControlState) state;
- (void) setBackgroundOpacity:(GLubyte) opacity forState:(CCControlState) state;

- (void) setLabelColor:(ccColor3B) color forState:(CCControlState) state;
- (void) setLabelOpacity:(GLubyte) opacity forState:(CCControlState) state;

- (ccColor3B) backgroundColorForState:(CCControlState)state;
- (GLubyte) backgroundOpacityForState:(CCControlState)state;

- (ccColor3B) labelColorForState:(CCControlState) state;
- (GLubyte) labelOpacityForState:(CCControlState) state;

@end
