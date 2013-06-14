//
//  CCFontDefinition.h
//  cocos2d-osx
//
//  Created by Carlo Morgantini on 6/12/13.
//
//
#import "ccTypes.h"

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

@property (nonatomic,copy)   NSString*                      fontName;
@property (nonatomic,assign) int                            fontSize;
@property (nonatomic,assign) CCTextAlignment                alignment;
@property (nonatomic,assign) CCVerticalTextAlignment        vertAlignment;
@property (nonatomic,assign) CCLineBreakMode                lineBreakMode;
@property (nonatomic,assign) CGSize                         dimensions;
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
