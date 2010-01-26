/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCAtlasNode.h"
#import "ccMacros.h"


@interface CCAtlasNode (Private)
-(void) calculateMaxItems;
-(void) calculateTexCoordsSteps;
-(void) updateBlendFunc;
-(void) updateOpacityModifyRGB;
@end

@implementation CCAtlasNode

@synthesize opacity=opacity_, color=color_;
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
	
		itemWidth = w;
		itemHeight = h;

		opacity_ = 255;
		color_ = ccWHITE;
		opacityModifyRGB_ = NO;
		
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		
		// retained
		self.textureAtlas = [CCTextureAtlas textureAtlasWithFile:tile capacity:c];
		
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

#pragma mark CCAtlasNode - Atlas generation

-(void) calculateMaxItems
{
	CGSize s = [[textureAtlas_ texture] contentSize];
	itemsPerColumn = s.height / itemHeight;
	itemsPerRow = s.width / itemWidth;
}

-(void) calculateTexCoordsSteps
{
	CCTexture2D *tex = [textureAtlas_ texture];
	texStepX = itemWidth / (float) [tex pixelsWide];
	texStepY = itemHeight / (float) [tex pixelsHigh]; 	
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

-(void) setOpacity:(GLubyte)opacity
{
	// special opacity for premultiplied textures
	opacity_ = opacity;
	if( opacityModifyRGB_ )
		color_.r = color_.g = color_.b = opacity_;	
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
