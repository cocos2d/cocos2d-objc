//
//  CCLabel.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCLabel.h"

@interface CCLabel ()
- (void) alignText;
@end

@implementation CCLabel
{
    BOOL _isOpacityModifyRGB;
    
    CCSprite* _reusedLetter;
}
@synthesize color = _realColor;
@synthesize displayedColor = _displayedColor;
@synthesize cascadeColorEnabled = _cascadeColorEnabled;
@synthesize cascadeOpacityEnabled = _cascadeOpacityEnabled;
@synthesize opacity = _realOpacity;
@synthesize displayedOpacity = _displayedOpacity;

- (void) setScale:(float)scale
{
    [super setScale:scale];
    [self alignText];
}

- (void) setScaleX:(float)scaleX
{
    [super setScaleX:scaleX];
    [self alignText];
}

- (void) setScaleY:(float)scaleY
{
    [super setScaleY:scaleY];
    [self alignText];
}

- (void) alignText
{
    
}

#pragma mark - CCLabelTextFormatProtocol

- (CGSize) labelContentSize
{
    return [self contentSize];
}

- (void) setLabelContentSize:(CGSize)labelContentSize
{
    [self setContentSize:labelContentSize];
}

#pragma mark - CCRGBAProtocol

- (BOOL) doesOpacityModifyRGB
{
    return _isOpacityModifyRGB;
}

- (void) setOpacityModifyRGB:(BOOL)isOpacityModifyRGB
{
    _isOpacityModifyRGB = isOpacityModifyRGB;
    
    for (CCNode* child in _children) {
        if ([child conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            [(id<CCRGBAProtocol>)child setOpacityModifyRGB:isOpacityModifyRGB];
        }
    }
    
    [_reusedLetter setOpacityModifyRGB:YES];
}

- (unsigned char) opacity
{
    return _realOpacity;
}

- (unsigned char) displayedOpacity
{
    return _displayedOpacity;
}


- (void) setOpacity:(GLubyte)opacity
{
    _displayedOpacity = _realOpacity = opacity;
    [_reusedLetter setOpacity:opacity];
	if( _cascadeOpacityEnabled ) {
		GLubyte parentOpacity = 255;
        if ([_parent conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            id<CCRGBAProtocol> parentRGBA = (id<CCRGBAProtocol>)_parent;
            if ([parentRGBA isCascadeOpacityEnabled])
                parentOpacity = [parentRGBA displayedOpacity];
        }
        [self updateDisplayedOpacity:parentOpacity];
	}
}

- (void) updateDisplayedOpacity:(GLubyte)parentOpacity
{
    _displayedOpacity = _realOpacity * parentOpacity/255.0;
    
    for (CCSprite* child in _children) {
        [child updateDisplayedOpacity:_displayedOpacity];
    }
    
    ccV3F_C4B_T2F_Quad *quads = [_textureAtlas quads];
    int count = [_textureAtlas totalQuads];
    ccColor4B color4 = (ccColor4B){_displayedColor.r, _displayedColor.g, _displayedColor.b, _displayedOpacity};

    if (_isOpacityModifyRGB)
    {
        color4.r *= _displayedOpacity/255.0f;
        color4.g *= _displayedOpacity/255.0f;
        color4.b *= _displayedOpacity/255.0f;
    }
    for (int index = 0; index < count; ++index)
    {
        quads[index].bl.colors = color4;
        quads[index].br.colors = color4;
        quads[index].tl.colors = color4;
        quads[index].tr.colors = color4;
        [_textureAtlas updateQuad:&quads[index] atIndex:index];
    }

}


- (BOOL) isCascadeOpacityEnabled
{
    return NO;
}

- (void) setCascadeOpacityEnabled:(BOOL)cascadeOpacityEnabled
{
    _cascadeOpacityEnabled = cascadeOpacityEnabled;
}

- (ccColor3B) color
{
    return _realColor;
}

- (ccColor3B) displayedColor
{
    return _displayedColor;
}

- (void) setColor:(ccColor3B)color
{
    _displayedColor = _realColor = color;
    [_reusedLetter setColor:color];
	if( _cascadeColorEnabled )
    {
		ccColor3B parentColor = ccWHITE;
        
        if ([_parent conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            parentColor = [(id<CCRGBAProtocol>)_parent displayedColor];
        }
        
        [self updateDisplayedColor:parentColor];
	}
}

- (void) updateDisplayedColor:(ccColor3B)parentColor
{
    _displayedColor.r = _realColor.r * parentColor.r/255.0;
	_displayedColor.g = _realColor.g * parentColor.g/255.0;
	_displayedColor.b = _realColor.b * parentColor.b/255.0;
    
    for (CCSprite* child in _children) {
        [child updateDisplayedColor:_displayedColor];
    }
    
    
    ccV3F_C4B_T2F_Quad *quads = [_textureAtlas quads];
    int count = [_textureAtlas totalQuads];
    ccColor4B color4 = (ccColor4B){ _displayedColor.r, _displayedColor.g, _displayedColor.b, _displayedOpacity };
    
    // special opacity for premultiplied textures
    if (_isOpacityModifyRGB)
    {
        color4.r *= _displayedOpacity/255.0f;
        color4.g *= _displayedOpacity/255.0f;
        color4.b *= _displayedOpacity/255.0f;
    }
    for (int index=0; index<count; ++index)
    {
        quads[index].bl.colors = color4;
        quads[index].br.colors = color4;
        quads[index].tl.colors = color4;
        quads[index].tr.colors = color4;
        [_textureAtlas updateQuad:&quads[index] atIndex:index];
    }
}

- (BOOL) isCascadeColorEnabled
{
    return NO;
}

- (void) setCascadeColorEnabled:(BOOL)cascadeColorEnabled
{
    _cascadeColorEnabled = cascadeColorEnabled;
}



@end
