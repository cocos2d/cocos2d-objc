/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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


#import "ccConfig.h"
#import "ccMacros.h"
#import "CCLabelAtlas.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "CCTextureCache.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "Support/TransformUtils.h"
#import "Support/CCFileUtils.h"

// external
#import "kazmath/GL/matrix.h"

@implementation CCLabelAtlas

#pragma mark CCLabelAtlas - Creation & Init
+(id) labelWithString:(NSString*)string charMapFile:(NSString*)charmapfile itemWidth:(NSUInteger)w itemHeight:(NSUInteger)h startCharMap:(NSUInteger)c
{
	return [[self alloc] initWithString:string charMapFile:charmapfile itemWidth:w itemHeight:h startCharMap:c];
}

+(id) labelWithString:(NSString*)string fntFile:(NSString*)fntFile
{
	return [[self alloc] initWithString:string fntFile:fntFile];
}

-(id) initWithString:(NSString*) theString fntFile:(NSString*)fntFile
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathForFilename:fntFile]];
	
	NSAssert( [[dict objectForKey:@"version"] intValue] == 1, @"Unsupported version. Upgrade cocos2d version");

	// obtain the path, and prepend it
	NSString *path = [fntFile stringByDeletingLastPathComponent];
	NSString *textureFilename = [path stringByAppendingPathComponent:[dict objectForKey:@"textureFilename"]];
	
	CGFloat scale = [CCDirector sharedDirector].contentScaleFactor;
	NSUInteger width = [[dict objectForKey:@"itemWidth"] unsignedIntValue]  / scale;
	NSUInteger height = [[dict objectForKey:@"itemHeight"] unsignedIntValue] / scale;
	NSUInteger startChar = [[dict objectForKey:@"firstChar"] unsignedIntValue];
	
	return [self initWithString:theString
					charMapFile:textureFilename
					  itemWidth:width
					 itemHeight:height
				   startCharMap:startChar];
}

-(id) initWithString:(NSString*)string charMapFile: (NSString*)filename itemWidth:(NSUInteger)w itemHeight:(NSUInteger)h startCharMap:(NSUInteger)c
{
	CCTexture *texture = [[CCTextureCache sharedTextureCache] addImage:filename];
	return [self initWithString:string texture:texture itemWidth:w itemHeight:h startCharMap:c];
}

-(id) initWithString:(NSString*) theString texture:(CCTexture*)texture itemWidth:(NSUInteger)w itemHeight:(NSUInteger)h startCharMap:(NSUInteger)c
{
	if ((self=[super initWithTexture:texture tileWidth:w tileHeight:h itemsToRender:[theString length] ]) ) {
		
		_mapStartChar = c;
		[self setString: theString];
	}
	
	return self;
}


#pragma mark CCLabelAtlas - Atlas generation

-(void) updateAtlasValues
{
	NSUInteger n = [_string length];

	ccV3F_C4B_T2F_Quad quad;

	const unsigned char *s = (unsigned char*) [_string UTF8String];

	CCTexture *texture = [_textureAtlas texture];
	float textureWide = [texture pixelWidth];
	float textureHigh = [texture pixelHeight];
	
	CGFloat scale = _textureAtlas.texture.contentScale;
	float itemWidthInPixels = _itemWidth * scale;
	float itemHeightInPixels = _itemHeight * scale;


	for( NSUInteger i=0; i<n; i++)
	{
		unsigned char a = s[i] - _mapStartChar;
		float row = (a % _itemsPerRow);
		float col = (a / _itemsPerRow);

#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		// Issue #938. Don't use texStepX & texStepY
		float left		= (2*row*itemWidthInPixels+1)/(2*textureWide);
		float right		= left+(itemWidthInPixels*2-2)/(2*textureWide);
		float top		= (2*col*itemHeightInPixels+1)/(2*textureHigh);
		float bottom	= top+(itemHeightInPixels*2-2)/(2*textureHigh);
#else
		float left		= row*itemWidthInPixels/textureWide;
		float right		= left+itemWidthInPixels/textureWide;
		float top		= col*itemHeightInPixels/textureHigh;
		float bottom	= top+itemHeightInPixels/textureHigh;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL

		quad.tl.texCoords.u = left;
		quad.tl.texCoords.v = top;
		quad.tr.texCoords.u = right;
		quad.tr.texCoords.v = top;
		quad.bl.texCoords.u = left;
		quad.bl.texCoords.v = bottom;
		quad.br.texCoords.u = right;
		quad.br.texCoords.v = bottom;

		quad.bl.vertices.x = (int) (i * _itemWidth);
		quad.bl.vertices.y = 0;
		quad.bl.vertices.z = 0.0f;
		quad.br.vertices.x = (int)(i * _itemWidth + _itemWidth);
		quad.br.vertices.y = 0;
		quad.br.vertices.z = 0.0f;
		quad.tl.vertices.x = (int)(i * _itemWidth);
		quad.tl.vertices.y = (int)(_itemHeight);
		quad.tl.vertices.z = 0.0f;
		quad.tr.vertices.x = (int)(i * _itemWidth + _itemWidth);
		quad.tr.vertices.y = (int)(_itemHeight);
		quad.tr.vertices.z = 0.0f;

		ccColor4B c = ccc4BFromccc4F(_displayColor);
		quad.tl.colors = c;
		quad.tr.colors = c;
		quad.bl.colors = c;
		quad.br.colors = c;
		[_textureAtlas updateQuad:&quad atIndex:i];
	}
}

#pragma mark CCLabelAtlas - CCLabelProtocol

- (void) setString:(NSString*) newString
{
	if( newString == _string )
		return;

	if( [newString hash] != [_string hash] ) {

		NSUInteger len = [newString length];
		if( len > _textureAtlas.capacity )
			[_textureAtlas resizeCapacity:len];

		_string = [newString copy];
		[self updateAtlasValues];

		CGSize s = CGSizeMake(len * _itemWidth, _itemHeight);
		[self setContentSize:s];

		self.quadsToDraw = len;
	}
}

-(NSString*) string
{
	return _string;
}

#pragma mark CCLabelAtlas - DebugDraw

#if CC_LABELATLAS_DEBUG_DRAW
- (void) draw
{
	[super draw];

	CGSize s = [self contentSize];
	CGPoint vertices[4]={
		ccp(0,0),ccp(s.width,0),
		ccp(s.width,s.height),ccp(0,s.height),
	};
	ccDrawPoly(vertices, 4, YES);
}
#endif // CC_LABELATLAS_DEBUG_DRAW

@end
