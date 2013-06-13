//
//  CCFontDefinition.m
//  cocos2d-osx
//
//  Created by Carlo Morgantini on 6/12/13.
//
//

#import "CCFontDefinition.h"

@implementation CCFontDefinition

@synthesize fontName;
@synthesize fontSize;
@synthesize alignment;
@synthesize vertAlignment;
@synthesize lineBreakMode;
@synthesize dimensions;
@synthesize fontFillColor;

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
        self.fontName = [name copy];
        self.fontSize = size;
    }
    
    return self;
}

-(void) enableShadow:(bool) shadowEnabled
{
    shadow.m_shadowEnabled = shadowEnabled;
}

-(bool) shadowEnabled
{
    return  shadow.m_shadowEnabled;
}

-(void) setShadowOffset:(CGSize)offset
{
    shadow.m_shadowOffset = offset;
}

-(CGSize) shadowOffset
{
    return shadow.m_shadowOffset;
}

-(void) setShadowBlur:(CGFloat)blur
{
    shadow.m_shadowBlur = blur;
}

-(CGFloat) shadowBlur
{
    return shadow.m_shadowBlur;
}

-(void) enableStoke:(bool) strokeEnabled
{
    stroke.m_strokeEnabled = strokeEnabled;
}

-(bool) strokeEnabled
{
    return stroke.m_strokeEnabled;
}

-(void) setStrokeSize:(CGFloat)size
{
    stroke.m_strokeSize = size;
}

-(CGFloat) strokeSize
{
    return stroke.m_strokeSize;
}

-(void) setStrokeColor:(ccColor3B)strokeColor
{
    stroke.m_strokeColor = strokeColor;
}

-(ccColor3B) strokeColor
{
    return stroke.m_strokeColor;
}

- (void) dealloc
{
    [fontName release];
    [super dealloc];
}

@end
