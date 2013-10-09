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
- (CCFontDefinition*) prepareFontDefinitionAndAdjustForResolution:(Boolean) resAdjust;
@end

@implementation CCLabelTTF

// -
+ (id) labelWithString:(NSString*)string fontDefinition:(CCFontDefinition *)definition
{
    return [[[self alloc] initWithString:string fontDefinition:definition] autorelease];
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
    
    if ( _shadowEnabled || _strokeEnabled )
    {
        CCFontDefinition *tempDef = [self prepareFontDefinitionAndAdjustForResolution:true];
        tex = [[CCTexture2D alloc ]initWithString:_string fontDef:tempDef];
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

/** init the label with string and text definition*/
- (id) initWithString:(NSString *) string fontDefinition:(CCFontDefinition *)definition
{
    if( (self=[super init]) ) {
        
		// shader program
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:SHADER_PROGRAM];
        
		_dimensions     = definition.dimensions;
		_hAlignment     = definition.alignment;
		_vAlignment     = definition.vertAlignment;
		_fontName       = [definition.fontName copy];
		_fontSize       = definition.fontSize;
		_lineBreakMode  = definition.lineBreakMode;
        
        // take care of shadow
        if ([definition shadowEnabled])
        {
            [self enableShadowWithOffset:[definition shadowOffset] opacity:0.5 blur:[definition shadowBlur] updateImage: false];
        }
        else
        {
            [self disableShadowAndUpdateImage:false];
        }
        
        // take care of stroke
        if ([definition strokeEnabled])
        {
            [self enableStrokeWithColor:[definition strokeColor] size:[definition strokeSize] updateImage:false];
        }
        else
        {
            [self disableStrokeAndUpdateImage:false];
        }
        
        
        [self setFontFillColor: definition.fontFillColor updateImage:false];
        
        
        // actually update the string
        [self setString:string];
	}
    
    return self;
}


/** enable or disable shadow for the label */
- (void) enableShadowWithOffset:(CGSize)shadowOffset opacity:(float)shadowOpacity blur:(float)shadowBlur updateImage:(Boolean) mustUpdate
{
    bool valueChanged = false;
    
    if (false == _shadowEnabled)
    {
        _shadowEnabled = true;
        valueChanged    = true;
    }
    
    if ( (_shadowOffset.width != shadowOffset.width) || (_shadowOffset.height!=shadowOffset.height) )
    {
        _shadowOffset.width  = shadowOffset.width;
        _shadowOffset.height = shadowOffset.height;
        
        valueChanged = true;
    }
    
    if (_shadowOpacity != shadowOpacity )
    {
        _shadowOpacity = shadowOpacity;
        valueChanged = true;
    }
    
    if (_shadowBlur    != shadowBlur)
    {
        _shadowBlur = shadowBlur;
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
    if (_shadowEnabled)
    {
        _shadowEnabled = false;
        
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
    
    if(_strokeEnabled == false)
    {
        _strokeEnabled = true;
        valueChanged = true;
    }
    
    if ( (_strokeColor.r != strokeColor.r) || (_strokeColor.g != strokeColor.g) || (_strokeColor.b != strokeColor.b) )
    {
        _strokeColor = strokeColor;
        valueChanged = true;
    }
    
    if (_strokeSize!=strokeSize)
    {
        _strokeSize = strokeSize;
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
    
    if ( _strokeEnabled )
    {
        _strokeEnabled = false;
        
        if ( mustUpdate )
        {
            [self updateTexture];
        }
    }
}

/** set fill color */
- (void) setFontFillColor:(ccColor3B) tintColor updateImage:(Boolean) mustUpdate
{
    if (_textFillColor.r != tintColor.r || _textFillColor.g != tintColor.g || _textFillColor.b != tintColor.b)
    {
        _textFillColor = tintColor;
        
        if (mustUpdate)
        {
            [self updateTexture];
        }
    }
}

- (CCFontDefinition*) prepareFontDefinitionAndAdjustForResolution:(Boolean) resAdjust
{
    int tempFontSize = 0;
    
    if (resAdjust)
       tempFontSize       =  _fontSize * CC_CONTENT_SCALE_FACTOR();
    else
       tempFontSize       =  _fontSize;
    
    CCFontDefinition *retDefinition = [[CCFontDefinition alloc]initWithFontName:_fontName fontSize:tempFontSize];
    
    if (retDefinition)
    {
        
        [retDefinition autorelease];
        
        retDefinition.lineBreakMode  = _lineBreakMode;
        retDefinition.alignment      = _hAlignment;
        retDefinition.vertAlignment  = _vAlignment;
        retDefinition.lineBreakMode  = _lineBreakMode;
        retDefinition.fontFillColor  = _textFillColor;
    
    
        // stroke
        if ( _strokeEnabled )
        {
            [retDefinition enableStroke: true];
            [retDefinition setStrokeColor: _strokeColor];
            
            if (resAdjust)
                [retDefinition setStrokeSize: _strokeSize * CC_CONTENT_SCALE_FACTOR()];
            else
                [retDefinition setStrokeSize: _strokeSize];
        }
        else
        {
            [retDefinition enableStroke: false];
        }
        
        
        // shadow
        if ( _shadowEnabled )
        {
            [retDefinition enableShadow:true];
            [retDefinition setShadowBlur:_shadowBlur];
            
            if (resAdjust)
            {
                [retDefinition setShadowOffset: CC_SIZE_POINTS_TO_PIXELS(_shadowOffset)];
            }
            else
            {
                [retDefinition setShadowOffset: _shadowOffset];
            }
        }
        else
        {
            [retDefinition enableShadow:false];
        }
    }
    
    return retDefinition;
}

- (CCFontDefinition *) getFontDefinition
{
    return [self prepareFontDefinitionAndAdjustForResolution:false];
}

- (void) setFontDefinition: (CCFontDefinition *) fontDef
{
    if(_fontName)
    {
        [_fontName release];
    }
    
    _dimensions     = fontDef.dimensions;
    _hAlignment     = fontDef.alignment;
    _vAlignment     = fontDef.vertAlignment;
    _fontName       = [fontDef.fontName copy];
    _fontSize       = fontDef.fontSize;
    _lineBreakMode  = fontDef.lineBreakMode;
    
    // take care of shadow
    if ([fontDef shadowEnabled])
    {
        [self enableShadowWithOffset:[fontDef shadowOffset] opacity:0.5 blur:[fontDef shadowBlur] updateImage: false];
    }
    else
    {
        [self disableShadowAndUpdateImage:false];
    }
    
    // take care of stroke
    if ([fontDef strokeEnabled])
    {
        [self enableStrokeWithColor:[fontDef strokeColor] size:[fontDef strokeSize] updateImage:false];
    }
    else
    {
        [self disableStrokeAndUpdateImage:false];
    }
    
    
    [self setFontFillColor: fontDef.fontFillColor updateImage:false];
    
    
    // actually update the texture
    [self updateTexture];
}

@end
