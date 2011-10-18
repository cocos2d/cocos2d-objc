/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Ricardo Quesada
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
 */

#import "CCShaderCache.h"
#import "GLProgram.h"
#import "ccMacros.h"
#import "Support/OpenGL_Internal.h"

static CCShaderCache *_sharedShaderCache;

@implementation CCShaderCache

#pragma mark CCShaderCache - Alloc, Init & Dealloc

+ (CCShaderCache *)sharedShaderCache
{
	if (!_sharedShaderCache)
		_sharedShaderCache = [[CCShaderCache alloc] init];
	
	return _sharedShaderCache;
}

+(void)purgeSharedShaderCache
{
	[_sharedShaderCache release];
	_sharedShaderCache = nil;	
}


+(id)alloc
{
	NSAssert(_sharedShaderCache == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

- (void)dealloc
{
	CCLOGINFO(@"cocos2d deallocing %@", self);
	
	[programs_ release];
    [super dealloc];
}

+(void)purgeSharedTextureCache
{
	[_sharedShaderCache release];
	_sharedShaderCache = nil;
}

-(id) init
{
	if( (self=[super init]) ) {
		programs_ = [[NSMutableDictionary alloc ] initWithCapacity: 10];
		
		[self loadDefaultShaders];
	}
	
	return self;
}

-(void) loadDefaultShaders
{
	// Position Texture Color shader
	GLProgram *p = [[GLProgram alloc] initWithVertexShaderFilename:@"PositionTextureColor.vsh"
											fragmentShaderFilename:@"PositionTextureColor.fsh"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	
	[p link];
	[p updateUniforms];
		
	[programs_ setObject:p forKey:kCCShader_PositionTextureColor];
	[p release];
	
	// Position Texture Color alpha test
	p = [[GLProgram alloc] initWithVertexShaderFilename:@"PositionTextureColor.vsh"
								 fragmentShaderFilename:@"PositionTextureColorAlphaTest.fsh"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_PositionTextureColorAlphaTest];
	[p release];
	
	//
	// Position, Color shader
	//
	p = [[GLProgram alloc] initWithVertexShaderFilename:@"PositionColor.vsh"
								 fragmentShaderFilename:@"PositionColor.fsh"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_PositionColor];
	[p release];

	//
	// Position Texture shader
	//
	p = [[GLProgram alloc] initWithVertexShaderFilename:@"PositionTexture.vsh"
								 fragmentShaderFilename:@"PositionTexture.fsh"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_PositionTexture];
	[p release];	

	//
	// Position, Texture attribs, 1 Color as uniform shader
	//
	p = [[GLProgram alloc] initWithVertexShaderFilename:@"PositionTexture_uColor.vsh"
								 fragmentShaderFilename:@"PositionTexture_uColor.fsh"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_PositionTexture_uColor];
	[p release];

	//
	// Position Texture A8 Color shader
	//
	p = [[GLProgram alloc] initWithVertexShaderFilename:@"PositionTextureA8Color.vsh"
								 fragmentShaderFilename:@"PositionTextureA8Color.fsh"];
	
	[p addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[p addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[p addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	
	[p link];
	[p updateUniforms];
	
	[programs_ setObject:p forKey:kCCShader_PositionTextureA8Color];
	[p release];	

	CHECK_GL_ERROR_DEBUG();
}

-(GLProgram *) programForKey:(NSString*)key
{
	return [programs_ objectForKey:key];
}

- (void) addProgram:(GLProgram*)program forKey:(NSString*)key
{
    [programs_ setObject:program forKey:key];
}

@end
