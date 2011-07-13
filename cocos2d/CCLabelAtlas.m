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


#import "ccConfig.h"
#import "ccMacros.h"
#import "CCDrawingPrimitives.h"
#import "CCLabelAtlas.h"
#import "Support/CGPointExtension.h"



@implementation CCLabelAtlas

#pragma mark CCLabelAtlas - Creation & Init
+(id) labelWithString:(NSString*)string charMapFile:(NSString*)charmapfile itemWidth:(NSUInteger)w itemHeight:(NSUInteger)h startCharMap:(unsigned char)c
{
	return [[[self alloc] initWithString:string charMapFile:charmapfile itemWidth:w itemHeight:h startCharMap:c] autorelease];
}

// XXX DEPRECATED. Remove it in 1.0.1
+(id) labelAtlasWithString:(NSString*) string charMapFile: (NSString*) charmapfile itemWidth:(NSUInteger)w itemHeight:(NSUInteger)h startCharMap:(unsigned char)c
{
	return [self labelWithString:string charMapFile:charmapfile itemWidth:w itemHeight:h startCharMap:c];
}


-(id) initWithString:(NSString*) theString charMapFile: (NSString*) charmapfile itemWidth:(NSUInteger)w itemHeight:(NSUInteger)h startCharMap:(unsigned char)c
{

	if ((self=[super initWithTileFile:charmapfile tileWidth:w tileHeight:h itemsToRender:[theString length] ]) ) {

		mapStartChar_ = c;		
		[self setString: theString];
	}

	return self;
}

-(void) dealloc
{
	[string_ release];

	[super dealloc];
}

#pragma mark CCLabelAtlas - Atlas generation

-(void) updateAtlasValues
{
	NSUInteger n = [string_ length];
	
	ccV3F_C4B_T2F_Quad quad;

	const unsigned char *s = (unsigned char*) [string_ UTF8String];

	CCTexture2D *texture = [textureAtlas_ texture];
	float textureWide = [texture pixelsWide];
	float textureHigh = [texture pixelsHigh];

	for( NSUInteger i=0; i<n; i++) {
		unsigned char a = s[i] - mapStartChar_;
		float row = (a % itemsPerRow_);
		float col = (a / itemsPerRow_);
		
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		// Issue #938. Don't use texStepX & texStepY
		float left		= (2*row*itemWidth_+1)/(2*textureWide);
		float right		= left+(itemWidth_*2-2)/(2*textureWide);
		float top		= (2*col*itemHeight_+1)/(2*textureHigh);
		float bottom	= top+(itemHeight_*2-2)/(2*textureHigh);
#else
		float left		= row*itemWidth_/textureWide;
		float right		= left+itemWidth_/textureWide;
		float top		= col*itemHeight_/textureHigh;
		float bottom	= top+itemHeight_/textureHigh;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		
		quad.tl.texCoords.u = left;
		quad.tl.texCoords.v = top;
		quad.tr.texCoords.u = right;
		quad.tr.texCoords.v = top;
		quad.bl.texCoords.u = left;
		quad.bl.texCoords.v = bottom;
		quad.br.texCoords.u = right;
		quad.br.texCoords.v = bottom;
		
		quad.bl.vertices.x = (int) (i * itemWidth_);
		quad.bl.vertices.y = 0;
		quad.bl.vertices.z = 0.0f;
		quad.br.vertices.x = (int)(i * itemWidth_ + itemWidth_);
		quad.br.vertices.y = 0;
		quad.br.vertices.z = 0.0f;
		quad.tl.vertices.x = (int)(i * itemWidth_);
		quad.tl.vertices.y = (int)(itemHeight_);
		quad.tl.vertices.z = 0.0f;
		quad.tr.vertices.x = (int)(i * itemWidth_ + itemWidth_);
		quad.tr.vertices.y = (int)(itemHeight_);
		quad.tr.vertices.z = 0.0f;
		
		[textureAtlas_ updateQuad:&quad atIndex:i];
	}
}

#pragma mark CCLabelAtlas - CCLabelProtocol

- (void) setString:(NSString*) newString
{
	NSUInteger len = [newString length];
	if( len > textureAtlas_.capacity )
		[textureAtlas_ resizeCapacity:len];

	[string_ release];
	string_ = [newString copy];
	[self updateAtlasValues];

	CGSize s;
	s.width = len * itemWidth_;
	s.height = itemHeight_;
	[self setContentSizeInPixels:s];
	
	self.quadsToDraw = len;
}

-(NSString*) string
{
	return string_;
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
