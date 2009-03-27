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

/** A class that implements a basic Texture Atlas
 * The Texture Atlas supports vertex array and color array.
 */
@interface TextureAtlas : NSObject {
	NSUInteger			_totalQuads;
	NSUInteger			_capacity;
	ccQuad2		*texCoordinates;
	ccQuad3		*vertices;
	ccColorB	*colors;			// RGBA for each vertex
	GLushort	*indices;
	Texture2D	*texture;
	
	BOOL		_withColorArray;
}

/** quantity of quads that are going to be drawn */
@property (readonly) NSUInteger totalQuads;
/** quantity of quads that can be stored with the current texture atlas size */
@property (readonly) NSUInteger capacity;
/** Texture of the texture atlas */
@property (nonatomic,retain) Texture2D *texture;
/** whether or not the TextureAtlas object is using a color array */
@property (readonly) BOOL withColorArray;

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

/** creates a TextureAtlas with a previously initialized Texture2D object, and
 * with an initial capacity for n Quads.  n is the number of Quads that can be rendered
 * at once with this Atlas.
 */
+(id) textureAtlasWithTexture:(Texture2D *)tex capacity:(NSUInteger)n;

/** initializes a TextureAtlas with a previously initialized Texture2D object, and
 * with an initial capacity for n Quads.  n is the number of Quads that can be rendered
 * at once with this Atlas.
 */
-(id) initWithTexture:(Texture2D *)tex capacity:(NSUInteger)n;

/** updates a certain texture coordinate & vertex with new Quads.
 * n must be between 0 and the atlas capacity - 1
 * The default value of all of the Quads is 0,0,0,0,0,0,0,0, so this selector
 * must be called to initializes every Quad
 */
-(void) updateQuadWithTexture: (ccQuad2*) quadT vertexQuad:(ccQuad3*) quadV atIndex:(NSUInteger) n;

/** updates the color (RGBA) for a certain quad
 * The 4 vertices of the Quad will be updated with this new quad color
 */
-(void) updateColorWithColorQuad:(ccColorB*)color atIndex:(NSUInteger)n;

/** draws n quads
 * n can't be greater than the capacity of the Atlas
 */
-(void) drawNumberOfQuads: (NSUInteger) n;

/** draws all the Atlas's Quads
 */
-(void) drawQuads;

/** removes a quad at a given index number.
 The capacity remains the same, but the total number of quads to be drawn is reduced in 1
 @since v0.7.2
 */
-(void) removeQuadAtIndex:(NSUInteger) index;

/** resize the capacity of the Texture Atlas.
 * The new capacity can be lower or higher
 */
-(void) resizeCapacity: (NSUInteger) n;

@end
