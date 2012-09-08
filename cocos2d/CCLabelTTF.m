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
#endif

#if CC_USE_LA88_LABELS
#define SHADER_PROGRAM kCCShader_PositionTextureColor
#else
#define SHADER_PROGRAM kCCShader_PositionTextureA8Color
#endif

@interface CCLabelTTF ()
-(void) updateTexture;
- (NSString*) getFontName:(NSString*)fontName;
@end

@implementation CCLabelTTF

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

		dimensions_ = dimensions;
		hAlignment_ = alignment;
		vAlignment_ = vertAlignment;
		fontName_ = [[self getFontName: name] copy];
		fontSize_ = size;
		lineBreakMode_ = lineBreakMode;

		[self setString:str];
	}
	return self;
}

- (void) setString:(NSString*)str
{
	NSAssert( str, @"Invalid string" );

	if( string_.hash != str.hash ) {
		[string_ release];
		string_ = [str copy];
		
		[self updateTexture];
	}
}

-(NSString*) string
{
	return string_;
}

- (NSString*) getFontName:(NSString*)fontName
{
#ifdef __CC_PLATFORM_MAC
	// Custom .ttf file ?
    if ([[fontName lowercaseString] hasSuffix:@".ttf"])
    {
        // This is a file, register font with font manager
        NSString* fontFile = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:fontName];
        NSURL* fontURL = [NSURL fileURLWithPath:fontFile];
        CTFontManagerRegisterFontsForURL((CFURLRef)fontURL, kCTFontManagerScopeProcess, NULL);

		return [[fontFile lastPathComponent] stringByDeletingPathExtension];
    }
#endif //

    return fontName;
}

- (void)setFontName:(NSString*)fontName
{
    fontName = [self getFontName:fontName];
    
	if( fontName.hash != fontName_.hash ) {
		[fontName_ release];
		fontName_ = [fontName copy];
		
		// Force update
		if( string_ )
			[self updateTexture];
	}
}

- (NSString*)fontName
{
    return fontName_;
}

- (void) setFontSize:(float)fontSize
{
	if( fontSize != fontSize_ ) {
		fontSize_ = fontSize;
		
		// Force update
		if( string_ )
			[self updateTexture];
	}
}

- (float) fontSize
{
    return fontSize_;
}

-(void) setDimensions:(CGSize) dim
{
    if( dim.width != dimensions_.width || dim.height != dimensions_.height)
	{
        dimensions_ = dim;
        
		// Force update
		if( string_ )
			[self updateTexture];
    }
}

-(CGSize) dimensions
{
    return dimensions_;
}

-(void) setHorizontalAlignment:(CCTextAlignment)alignment
{
    if (alignment != hAlignment_)
    {
        hAlignment_ = alignment;
        
        // Force update
		if( string_ )
			[self updateTexture];

    }
}

- (CCTextAlignment) horizontalAlignment
{
    return hAlignment_;
}

-(void) setVerticalAlignment:(CCVerticalTextAlignment)verticalAlignment
{
    if (vAlignment_ != verticalAlignment)
    {
        vAlignment_ = verticalAlignment;
        
		// Force update
		if( string_ )
			[self updateTexture];
    }
}

- (CCVerticalTextAlignment) verticalAlignment
{
    return vAlignment_;
}

- (void) dealloc
{
	[string_ release];
	[fontName_ release];

	[super dealloc];
}

- (NSString*) description
{
	// XXX: string_, fontName_ can't be displayed here, since they might be already released

	return [NSString stringWithFormat:@"<%@ = %p | FontSize = %.1f>", [self class], self, fontSize_];
}

// Helper
- (void) updateTexture
{				
	CCTexture2D *tex;
	if( dimensions_.width == 0 || dimensions_.height == 0 )
		tex = [[CCTexture2D alloc] initWithString:string_
										 fontName:fontName_
										 fontSize:fontSize_  * CC_CONTENT_SCALE_FACTOR()];
	else
		tex = [[CCTexture2D alloc] initWithString:string_
										 fontName:fontName_
										 fontSize:fontSize_  * CC_CONTENT_SCALE_FACTOR()
									   dimensions:CC_SIZE_POINTS_TO_PIXELS(dimensions_)
									   hAlignment:hAlignment_
									   vAlignment:vAlignment_
									lineBreakMode:lineBreakMode_
			   ];
		
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
	rect.size = [texture_ contentSize];
	[self setTextureRect: rect];
}
@end
