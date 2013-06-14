//
//  CCFontDefinition.m
//  cocos2d-osx
//
//  Created by Carlo Morgantini on 6/12/13.
//
//

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
