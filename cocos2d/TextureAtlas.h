/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

#import "Texture2D.h"
#import "ccTypes.h"

/** A class that implements a basic Texture Atlas */
@interface TextureAtlas : NSObject {
	NSUInteger			totalQuads;
	ccQuad2		*texCoordinates;
	ccQuad3		*vertices;
	GLushort	*indices;
	Texture2D	*texture;
}

@property (readonly) NSUInteger totalQuads;
@property (nonatomic,retain) Texture2D *texture;

/** creates a TextureAtlas with an iname filename and with a capacity for n Quads
 * n is the number of Quads that will be rendered at once from this Atlas
 * n is the maximun number of Quads it will be able to render, but not the minimun
 */
+(id) textureAtlasWithFile:(NSString*)file capacity: (NSUInteger) n;

/** initializes a TextureAtlas with an iname filename and with a capacity for n Quads
 * n is the number of Quads that will be rendered at once from this Atlas
 * n is the maximun number of Quads it will be able to render, but not the minimun
 */
-(id) initWithFile: (NSString*) file capacity:(NSUInteger)n;

/** updates a certain texture coordinate & vertex with new Quads.
 * n must be between 0 and the atlas capacity - 1
 * The default value of all of the Quads is 0,0,0,0,0,0,0,0, so this selector
 * must be called to initializes every Quad
 */
-(void) updateQuadWithTexture: (ccQuad2*) quadT vertexQuad:(ccQuad3*) quadV atIndex:(NSUInteger) n;


/** draws n quads
 * n can't be greater than the capacity of the Atlas
 */
-(void) drawNumberOfQuads: (NSUInteger) n;

/** draws all the Atlas's Quads
 */
-(void) drawQuads;


/** resize the capacity of the Texture Atlas.
 * The new capacity can be lower or higher
 */
-(void) resizeCapacity: (NSUInteger) n;

@end
