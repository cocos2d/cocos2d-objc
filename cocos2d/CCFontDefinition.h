/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Zynga Inc.
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
#import "ccTypes.h"

/** Class used to define the properties of a CCLabelTTF label
 */
@interface CCFontDefinition : NSObject
{
    // font name
    NSString               *_fontName;
    // font size
    int                     _fontSize;
    // horizontal alignment
    CCTextAlignment         _alignment;
    // vertical alignment
    CCVerticalTextAlignment _vertAlignment;
    // line break mode
    CCLineBreakMode         _lineBreakMode;
    // renering box
    CGSize                  _dimensions;
    // font color
    ccColor3B               _fontFillColor;
    // font shadow
    ccFontShadow            _shadow;
    // font stroke
    ccFontStroke            _stroke;
}

/** font name */
@property (nonatomic,copy)   NSString*                      fontName;
/** font size */
@property (nonatomic,assign) int                            fontSize;
/** Horizontal alignment */
@property (nonatomic,assign) CCTextAlignment                alignment;
/** vertical alignment */
@property (nonatomic,assign) CCVerticalTextAlignment        vertAlignment;
/** Line break */
@property (nonatomic,assign) CCLineBreakMode                lineBreakMode;
/** Dimension of the texture */
@property (nonatomic,assign) CGSize                         dimensions;
/** Fill color */
@property (nonatomic,assign) ccColor3B                      fontFillColor;

-(id)      init;
-(id)      initWithFontName:(NSString *)name fontSize:(int)fontSize;

// shadow
-(void)    enableShadow:(bool) shadowEnabled;
-(bool)    shadowEnabled;
-(void)    setShadowOffset:(CGSize)offset;
-(CGSize)  shadowOffset;
-(void)    setShadowBlur:(CGFloat)blur;
-(CGFloat) shadowBlur;

// stroke
-(void)     enableStroke:(bool) strokeEnabled;
-(bool)     strokeEnabled;
-(void)     setStrokeSize:(CGFloat)size;
-(CGFloat)  strokeSize;
-(void)     setStrokeColor:(ccColor3B)strokeColor;
-(ccColor3B)strokeColor;

@end
