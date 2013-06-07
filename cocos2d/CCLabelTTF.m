/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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


#import "CCLabelTTF.h"
#import "Support/CGPointExtension.h"
#import "ccMacros.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "Support/CCFileUtils.h"
#import "ccDeprecated.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#import <CoreText/CoreText.h>
#endif

#if CC_USE_LA88_LABELS
#define SHADER_PROGRAM kCCShader_PositionTextureColor
#else
#define SHADER_PROGRAM kCCShader_PositionTextureA8Color
#endif

@interface CCLabelTTF ()
- (BOOL) updateTexture;
- (NSString*) getFontName:(NSString*)fontName;
- (ccFontDefinition) prepareFontDefinitionAndAdjustForResolution:(Boolean) resAdjust;
@end

@implementation CCLabelTTF

// - 
+ (id) labelWithString:(NSString*)string fontDefinition:(ccFontDefinition)definition
{
    return [[self alloc] initWithString:string fontDefinition:definition];
}

// -
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [[[self alloc] initWithString:string fontName:name fontSize:size]autorelease];
}

// hAlignment
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment
{
	return [[[self alloc] initWithString:string  fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:kCCLineBreakModeWordWrap]autorelease];
}

// hAlignment, vAlignment
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment) vertAlignment
{
	return [[[self alloc] initWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:vertAlignment]autorelease];
}

// hAlignment, lineBreakMode
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode
{
	return [[[self alloc] initWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:lineBreakMode]autorelease];
}

// hAlignment, vAlignment, lineBreakMode
+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment) vertAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode
{
	return [[[self alloc] initWithString:string fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:vertAlignment lineBreakMode:lineBreakMode]autorelease];
}

- (id) init
{
    return [self initWithString:@"" fontName:@"Helvetica" fontSize:12];
}

- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [self initWithString:str fontName:name fontSize:size dimensions:CGSizeZero hAlignment:kCCTextAlignmentLeft vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:kCCLineBreakModeWordWrap];
}

// hAlignment
- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment
{
	return [self initWithString:str fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:kCCLineBreakModeWordWrap];
}

// hAlignment, vAlignment
- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment) vertAlignment
{
	return [self initWithString:str fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:vertAlignment lineBreakMode:kCCLineBreakModeWordWrap];
}

// hAlignment, lineBreakMode
- (id) initWithString:(NSString*)str fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment lineBreakMode:(CCLineBreakMode)lineBreakMode
{
	return [self initWithString:str fontName:name fontSize:size dimensions:dimensions hAlignment:alignment vAlignment:kCCVerticalTextAlignmentTop lineBreakMode:lineBreakMode];
}

// hAlignment, vAligment, lineBreakMode
- (id) initWithString:(NSString*)str  fontName:(NSString*)name fontSize:(CGFloat)size dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)alignment vAlignment:(CCVerticalTextAlignment) vertAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode
{
	if( (self=[super init]) ) {

		// shader program
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:SHADER_PROGRAM];

		_dimensions = dimensions;
		_hAlignment = alignment;
		_vAlignment = vertAlignment;
		_fontName = [[self getFontName: name] copy];
		_fontSize = size;
		_lineBreakMode = lineBreakMode;

		[self setString:str];
	}
	return self;
}

- (void) setString:(NSString*)str
{
	NSAssert( str, @"Invalid string" );

	if( _string.hash != str.hash ) {
		[_string release];
		_string = [str copy];
		
		[self updateTexture];
	}
}

-(NSString*) string
{
	return _string;
}

- (NSString*) getFontName:(NSString*)fontName
{
	// Custom .ttf file ?
    if ([[fontName lowercaseString] hasSuffix:@".ttf"])
    {
        // This is a file, register font with font manager
        NSString* fontFile = [[CCFileUtils sharedFileUtils] fullPathForFilename:fontName];
        NSURL* fontURL = [NSURL fileURLWithPath:fontFile];
        CTFontManagerRegisterFontsForURL((CFURLRef)fontURL, kCTFontManagerScopeProcess, NULL);

		return [[fontFile lastPathComponent] stringByDeletingPathExtension];
    }

    return fontName;
}

- (void)setFontName:(NSString*)fontName
{
    fontName = [self getFontName:fontName];
    
	if( fontName.hash != _fontName.hash ) {
		[_fontName release];
		_fontName = [fontName copy];
		
		// Force update
		if( _string )
			[self updateTexture];
	}
}

- (NSString*)fontName
{
    return _fontName;
}

- (void) setFontSize:(float)fontSize
{
	if( fontSize != _fontSize ) {
		_fontSize = fontSize;
		
		// Force update
		if( _string )
			[self updateTexture];
	}
}

- (float) fontSize
{
    return _fontSize;
}

-(void) setDimensions:(CGSize) dim
{
    if( dim.width != _dimensions.width || dim.height != _dimensions.height)
	{
        _dimensions = dim;
        
		// Force update
		if( _string )
			[self updateTexture];
    }
}

-(CGSize) dimensions
{
    return _dimensions;
}

-(void) setHorizontalAlignment:(CCTextAlignment)alignment
{
    if (alignment != _hAlignment)
    {
        _hAlignment = alignment;
        
        // Force update
		if( _string )
			[self updateTexture];

    }
}

- (CCTextAlignment) horizontalAlignment
{
    return _hAlignment;
}

-(void) setVerticalAlignment:(CCVerticalTextAlignment)verticalAlignment
{
    if (_vAlignment != verticalAlignment)
    {
        _vAlignment = verticalAlignment;
        
		// Force update
		if( _string )
			[self updateTexture];
    }
}

- (CCVerticalTextAlignment) verticalAlignment
{
    return _vAlignment;
}

- (void) dealloc
{
	[_string release];
	[_fontName release];

	[super dealloc];
}

- (NSString*) description
{
	// XXX: _string, _fontName can't be displayed here, since they might be already released

	return [NSString stringWithFormat:@"<%@ = %p | FontSize = %.1f>", [self class], self, _fontSize];
}

// Helper
- (BOOL) updateTexture
{				
	CCTexture2D *tex;
    
    if ( m_shadowEnabled || m_strokeEnabled )
    {
        ccFontDefinition tempDefinition;
        tempDefinition = [self prepareFontDefinitionAndAdjustForResolution:true];
        tex = [[CCTexture2D alloc] initWithString:_string fontDef:&tempDefinition];
    }
    else
    {
        if( _dimensions.width == 0 || _dimensions.height == 0 )
            tex = [[CCTexture2D alloc] initWithString:_string
                                             fontName:_fontName
                                             fontSize:_fontSize  * CC_CONTENT_SCALE_FACTOR()];
        else
            tex = [[CCTexture2D alloc] initWithString:_string
                                             fontName:_fontName
                                             fontSize:_fontSize  * CC_CONTENT_SCALE_FACTOR()
                                           dimensions:CC_SIZE_POINTS_TO_PIXELS(_dimensions)
                                           hAlignment:_hAlignment
                                           vAlignment:_vAlignment
                                        lineBreakMode:_lineBreakMode
                   ];
    }

	if( !tex )
		return NO;

#ifdef __CC_PLATFORM_IOS
	// iPad ?
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:kCCResolutioniPadRetinaDisplay];
		else
			[tex setResolutionType:kCCResolutioniPad];
	}
	// iPhone ?
	else
	{
		if( CC_CONTENT_SCALE_FACTOR() == 2 )
			[tex setResolutionType:kCCResolutioniPhoneRetinaDisplay];
		else
			[tex setResolutionType:kCCResolutioniPhone];
	}
#endif
	
	[self setTexture:tex];
	[tex release];
	
	CGRect rect = CGRectZero;
	rect.size = [_texture contentSize];
	[self setTextureRect: rect];
	
	return YES;
}

/* init the label using string and a font definition*/
- (id) initWithString:(NSString *) string fontDefinition:(ccFontDefinition) fontDefinition
{
    if( (self=[super init]) ) {
        
		// shader program
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:SHADER_PROGRAM];
        
		_dimensions     = fontDefinition.m_dimensions;
		_hAlignment     = fontDefinition.m_alignment;
		_vAlignment     = fontDefinition.m_vertAlignment;
		_fontName       = [fontDefinition.m_fontName copy];
		_fontSize       = fontDefinition.m_fontSize;
		_lineBreakMode  = fontDefinition.m_lineBreakMode;
        
        // take care of shadow
        if (fontDefinition.m_shadow.m_shadowEnabled)
        {
            [self enableShadowWithOffset:fontDefinition.m_shadow.m_shadowOffset opacity:fontDefinition.m_shadow.m_shadowOpacity blur:fontDefinition.m_shadow.m_shadowBlur updateImage: false];
        }
        else
        {
            [self disableShadowAndUpdateImage:false];
        }
        
        // take care of stroke
        if (fontDefinition.m_stroke.m_strokeEnabled)
        {
            [self enableStrokeWithColor:fontDefinition.m_stroke.m_strokeColor size:fontDefinition.m_stroke.m_strokeSize updateImage:false];
        }
        else
        {
            [self disableStrokeAndUpdateImage:false];
        }
        
        
        [self setFontFillColor: fontDefinition.m_fontFillColor updateImage:false];
        
        
        // actually update the string
        [self setString:string];
	}
    
	return self;
}

/** enable or disable shadow for the label */
- (void) enableShadowWithOffset:(CGSize)shadowOffset opacity:(float)shadowOpacity blur:(float)shadowBlur updateImage:(Boolean) mustUpdate
{
    bool valueChanged = false;
    
    if (false == m_shadowEnabled)
    {
        m_shadowEnabled = true;
        valueChanged    = true;
    }
    
    if ( (m_shadowOffset.width != shadowOffset.width) || (m_shadowOffset.height!=shadowOffset.height) )
    {
        m_shadowOffset.width  = shadowOffset.width;
        m_shadowOffset.height = shadowOffset.height;
        
        valueChanged = true;
    }
    
    if (m_shadowOpacity != shadowOpacity )
    {
        m_shadowOpacity = shadowOpacity;
        valueChanged = true;
    }
    
    if (m_shadowBlur    != shadowBlur)
    {
        m_shadowBlur = shadowBlur;
        valueChanged = true;
    }
    
    if ( valueChanged && mustUpdate )
    {
        [self updateTexture];
    }
}

/** disable shadow rendering */
- (void) disableShadowAndUpdateImage:(Boolean)mustUpdate
{
    if (m_shadowEnabled)
    {
        m_shadowEnabled = false;
        
        if ( mustUpdate )
        {
            [self updateTexture];
        }
    }
}

/** enable or disable stroke */
- (void) enableStrokeWithColor:(ccColor3B)strokeColor size:(float)strokeSize updateImage:(Boolean) mustUpdate
{
    bool valueChanged = false;
    
    if(m_strokeEnabled == false)
    {
        m_strokeEnabled = true;
        valueChanged = true;
    }
    
    if ( (m_strokeColor.r != strokeColor.r) || (m_strokeColor.g != strokeColor.g) || (m_strokeColor.b != strokeColor.b) )
    {
        m_strokeColor = strokeColor;
        valueChanged = true;
    }
    
    if (m_strokeSize!=strokeSize)
    {
        m_strokeSize = strokeSize;
        valueChanged = true;
    }
    
    if ( valueChanged && mustUpdate )
    {
        [self updateTexture];
    }

}

/** disable stroke */
- (void) disableStrokeAndUpdateImage:(Boolean) mustUpdate
{
    
    if ( m_strokeEnabled )
    {
        m_strokeEnabled = false;
        
        if ( mustUpdate )
        {
            [self updateTexture];
        }
    }
}

/** set fill color */
- (void) setFontFillColor:(ccColor3B) tintColor updateImage:(Boolean) mustUpdate
{
    if (m_textFillColor.r != tintColor.r || m_textFillColor.g != tintColor.g || m_textFillColor.b != tintColor.b)
    {
        m_textFillColor = tintColor;
        
        if (mustUpdate)
        {
            [self updateTexture];
        }
    }
}

- (ccFontDefinition) prepareFontDefinitionAndAdjustForResolution:(Boolean) resAdjust
{
    ccFontDefinition texDef;
    
    if (resAdjust)
        texDef.m_fontSize       =  _fontSize * CC_CONTENT_SCALE_FACTOR();
    else
        texDef.m_fontSize       =  _fontSize;
    
    texDef.m_fontName       = [_fontName copy];
    texDef.m_alignment      =  _hAlignment;
    texDef.m_vertAlignment  =  _vAlignment;
    
    if (resAdjust)
        texDef.m_dimensions     =  CC_SIZE_POINTS_TO_PIXELS(_dimensions);
    else
        texDef.m_dimensions     =  _dimensions;
    
    
    // stroke
    if ( m_strokeEnabled )
    {
        texDef.m_stroke.m_strokeEnabled = true;
        texDef.m_stroke.m_strokeColor   = m_strokeColor;
        
        if (resAdjust)
            texDef.m_stroke.m_strokeSize = m_strokeSize * CC_CONTENT_SCALE_FACTOR();
        else
            texDef.m_stroke.m_strokeSize = m_strokeSize;
        
        
    }
    else
    {
        texDef.m_stroke.m_strokeEnabled = false;
    }
    
    
    // shadow
    if ( m_shadowEnabled )
    {
        texDef.m_shadow.m_shadowEnabled         = true;
        texDef.m_shadow.m_shadowBlur            = m_shadowBlur;
        texDef.m_shadow.m_shadowOpacity         = m_shadowOpacity;
        
        if (resAdjust)
            texDef.m_shadow.m_shadowOffset = CC_SIZE_POINTS_TO_PIXELS(m_shadowOffset);
        else
            texDef.m_shadow.m_shadowOffset = m_shadowOffset;
    }
    else
    {
        texDef.m_shadow.m_shadowEnabled = false;
    }
    
    // text tint
    texDef.m_fontFillColor = m_textFillColor;
    
    return texDef;
}

@end
