/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "AtlasNode.h"
#import "ccMacros.h"


@interface AtlasNode (Private)
-(void) calculateMaxItems;
-(void) calculateTexCoordsSteps;
-(void) updateBlendFunc;
-(void) updateOpacityModifyRGB;
@end

@implementation AtlasNode

@synthesize opacity=opacity_, r=r_, g=g_, b=b_;
@synthesize textureAtlas = textureAtlas_;
@synthesize blendFunc = blendFunc_;

#pragma mark AtlasNode - Creation & Init
+(id) atlasWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c
{
	return [[[self alloc] initWithTileFile:tile tileWidth:w tileHeight:h itemsToRender:c] autorelease];
}


-(id) initWithTileFile:(NSString*)tile tileWidth:(int)w tileHeight:(int)h itemsToRender: (int) c
{
	if( (self=[super init]) ) {
	
		itemWidth = w;
		itemHeight = h;

		opacity_ = 255;
		r_ = g_ = b_ = 255;
		opacityModifyRGB_ = NO;
		
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		
		// retained
		self.textureAtlas = [TextureAtlas textureAtlasWithFile:tile capacity:c];
		
		[self updateBlendFunc];
		[self updateOpacityModifyRGB];
			
		[self calculateMaxItems];
		[self calculateTexCoordsSteps];
	}
	
	return self;
}

-(void) dealloc
{
	[textureAtlas_ release];
	
	[super dealloc];
}

#pragma mark AtlasNode - Atlas generation

-(void) calculateMaxItems
{
	CGSize s = [[textureAtlas_ texture] contentSize];
	itemsPerColumn = s.height / itemHeight;
	itemsPerRow = s.width / itemWidth;
}

-(void) calculateTexCoordsSteps
{
	texStepX = itemWidth / (float) [[textureAtlas_ texture] pixelsWide];
	texStepY = itemHeight / (float) [[textureAtlas_ texture] pixelsHigh]; 	
}

-(void) updateAtlasValues
{
	[NSException raise:@"AtlasNode:Abstract" format:@"updateAtlasValue not overriden"];
}

#pragma mark AtlasNode - draw
- (void) draw
{
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	
	glEnable( GL_TEXTURE_2D);

	glColor4ub( r_, g_, b_, opacity_);

	BOOL newBlend = NO;
	if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
		newBlend = YES;
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	}
		
	[textureAtlas_ drawQuads];
		
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// is this chepear than saving/restoring color state ?
	glColor4ub( 255, 255, 255, 255);

	glDisable( GL_TEXTURE_2D);
	
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}

#pragma mark AtlasNode - RGBA protocol

-(void) setRGB: (GLubyte) rr :(GLubyte) gg :(GLubyte)bb
{
	r_=rr;
	g_=gg;
	b_=bb;
}

-(void) setOpacity:(GLubyte)opacity
{
	// special opacity for premultiplied textures
	opacity_ = opacity;
	if( opacityModifyRGB_ )
		r_ = g_ = b_ = opacity_;	
}
-(void) updateOpacityModifyRGB
{
	opacityModifyRGB_ = [textureAtlas_.texture hasPremultipliedAlpha];
}
-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_ = modify;
}
-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

#pragma mark AtlasNode - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	if( ! [textureAtlas_.texture hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
}

-(void) setTexture:(Texture2D*)texture
{
	textureAtlas_.texture = texture;
	[self updateBlendFunc];
	[self updateOpacityModifyRGB];
}

-(Texture2D*) texture
{
	return textureAtlas_.texture;
}


@end
