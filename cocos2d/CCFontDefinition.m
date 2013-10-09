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

#import "CCFontDefinition.h"

@implementation CCFontDefinition

@synthesize fontName        = _fontName;
@synthesize fontSize        = _fontSize;
@synthesize alignment       = _alignment;
@synthesize vertAlignment   = _vertAlignment;
@synthesize lineBreakMode   = _lineBreakMode;
@synthesize dimensions      = _dimensions;
@synthesize fontFillColor   = _fontFillColor;

-(id) init
{
    if( (self=[super init]) )
    {
        self.fontName = 0;
    }
    return self;
}

-(id) initWithFontName:(NSString *)name fontSize:(int)size
{
    if( (self=[super init]) )
    {
        _fontName = [name copy];
        _fontSize = size;
    }
    
    return self;
}

- (void) dealloc
{
    [_fontName release];
    [super dealloc];
}

-(void) enableShadow:(bool) shadowEnabled
{
    _shadow.m_shadowEnabled = shadowEnabled;
}

-(bool) shadowEnabled
{
    return  _shadow.m_shadowEnabled;
}

-(void) setShadowOffset:(CGSize)offset
{
    _shadow.m_shadowOffset = offset;
}

-(CGSize) shadowOffset
{
    return _shadow.m_shadowOffset;
}

-(void) setShadowBlur:(CGFloat)blur
{
    _shadow.m_shadowBlur = blur;
}

-(CGFloat) shadowBlur
{
    return _shadow.m_shadowBlur;
}

-(void) enableStroke:(bool) strokeEnabled
{
    _stroke.m_strokeEnabled = strokeEnabled;
}

-(bool) strokeEnabled
{
    return _stroke.m_strokeEnabled;
}

-(void) setStrokeSize:(CGFloat)size
{
    _stroke.m_strokeSize = size;
}

-(CGFloat) strokeSize
{
    return _stroke.m_strokeSize;
}

-(void) setStrokeColor:(ccColor3B)strokeColor
{
    _stroke.m_strokeColor = strokeColor;
}

-(ccColor3B) strokeColor
{
    return _stroke.m_strokeColor;
}

@end
