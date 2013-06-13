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
    NSString               *fontName;
    // font size
    int                     fontSize;
    // horizontal alignment
    CCTextAlignment         alignment;
    // vertical alignment
    CCVerticalTextAlignment vertAlignment;
    // line break mode
    CCLineBreakMode         lineBreakMode;
    // renering box
    CGSize                  dimensions;
    // font color
    ccColor3B               fontFillColor;
    // font shadow
    ccFontShadow            shadow;
    // font stroke
    ccFontStroke            stroke;
}

@property (nonatomic,copy) NSString*                        fontName;
@property (nonatomic,assign) int                            fontSize;
@property (nonatomic,assign) CCTextAlignment                alignment;
@property (nonatomic,assign) CCVerticalTextAlignment        vertAlignment;
@property (nonatomic,assign) CCLineBreakMode                lineBreakMode;
@property (nonatomic,assign) CGSize                         dimensions;
@property (nonatomic,assign) ccColor3B                      fontFillColor;

-(id) init;
-(id) initWithFontName:(NSString *)name fontSize:(int)fontSize;
-(void) enableShadow:(bool) shadowEnabled;
-(bool) shadowEnabled;
-(void) setShadowOffset:(CGSize)offset;
-(CGSize) shadowOffset;
-(void) setShadowBlur:(CGFloat)blur;
-(CGFloat) shadowBlur;

-(void) enableStoke:(bool) strokeEnabled;
-(bool) strokeEnabled;
-(void) setStrokeSize:(CGFloat)size;
-(CGFloat) strokeSize;
-(void) setStrokeColor:(ccColor3B)strokeColor;
-(ccColor3B) strokeColor;

@end
