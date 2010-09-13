/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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


#import "CCAtlasNode.h"
#import "ccMacros.h"


@interface CCAtlasNode ()
-(void) calculateMaxItems;
-(void) updateBlendFunc;
-(void) updateOpacityModifyRGB;
@end

@implementation CCAtlasNode

@synthesize textureAtlas = textureAtlas_;
@synthesize blendFunc = blendFunc_;

#pragma mark CCAtlasNode - Creation & Init
+(id) atlasWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c
{
	return [[[self alloc] initWithTileFile:tile tileWidth:w tileHeight:h itemsToRender:c] autorelease];
}


-(id) initWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c
{
	if( (self=[super init]) ) {
	
		itemWidth_ = w * CC_CONTENT_SCALE_FACTOR();
		itemHeight_ = h * CC_CONTENT_SCALE_FACTOR();

		opacity_ = 255;
		color_ = colorUnmodified_ = ccWHITE;
		opacityModifyRGB_ = YES;
		
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		
		// double retain to avoid the autorelease pool
		// also, using: self.textureAtlas supports re-initialization without leaking
		self.textureAtlas = [[CCTextureAtlas alloc] initWithFile:tile capacity:c];
		[textureAtlas_ release];
		
		if( ! textureAtlas_ ) {
			CCLOG(@"cocos2d: Could not initialize CCAtlasNode. Invalid Texture");
			[self release];
			return nil;
		}
		
		[self updateBlendFunc];
		[self updateOpacityModifyRGB];
		
		[self calculateMaxItems];
		
	}
	
	return self;
}

-(void) dealloc
{
	[textureAtlas_ release];
	
	[super dealloc];
}

#pragma mark CCAtlasNode - Atlas generation

-(void) calculateMaxItems
{
	CGSize s = [[textureAtlas_ texture] contentSizeInPixels];
	itemsPerColumn_ = s.height / itemHeight_;
	itemsPerRow_ = s.width / itemWidth_;
}

-(void) updateAtlasValues
{
	[NSException raise:@"CCAtlasNode:Abstract" format:@"updateAtlasValue not overriden"];
}

#pragma mark CCAtlasNode - draw
- (void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	glDisableClientState(GL_COLOR_ARRAY);

	glColor4ub( color_.r, color_.g, color_.b, opacity_);

	BOOL newBlend = NO;
	if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
		newBlend = YES;
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	}
		
	[textureAtlas_ drawQuads];
		
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// is this chepear than saving/restoring color state ?
	// XXX: There is no need to restore the color to (255,255,255,255). Objects should use the color
	// XXX: that they need
//	glColor4ub( 255, 255, 255, 255);

	// restore default GL state
	glEnableClientState(GL_COLOR_ARRAY);

}

#pragma mark CCAtlasNode - RGBA protocol

- (ccColor3B) color
{
	if(opacityModifyRGB_){
		return colorUnmodified_;
	}
	return color_;
}

-(void) setColor:(ccColor3B)color3
{
	color_ = colorUnmodified_ = color3;
	
	if( opacityModifyRGB_ ){
		color_.r = color3.r * opacity_/255;
		color_.g = color3.g * opacity_/255;
		color_.b = color3.b * opacity_/255;
	}	
}

-(GLubyte) opacity
{
	return opacity_;
}

-(void) setOpacity:(GLubyte) anOpacity
{
	opacity_			= anOpacity;
	
	// special opacity for premultiplied textures
	if( opacityModifyRGB_ )
		[self setColor: (opacityModifyRGB_ ? colorUnmodified_ : color_ )];	
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	ccColor3B oldColor	= self.color;
	opacityModifyRGB_	= modify;
	self.color			= oldColor;
}

-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

-(void) updateOpacityModifyRGB
{
	opacityModifyRGB_ = [textureAtlas_.texture hasPremultipliedAlpha];
}

#pragma mark CCAtlasNode - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	if( ! [textureAtlas_.texture hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(void) setTexture:(CCTexture2D*)texture
{
	textureAtlas_.texture = texture;
	[self updateBlendFunc];
	[self updateOpacityModifyRGB];
}

-(CCTexture2D*) texture
{
	return textureAtlas_.texture;
}

@end
