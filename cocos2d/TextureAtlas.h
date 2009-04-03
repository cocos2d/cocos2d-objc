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

/** A class that implements a Texture Atlas.
 Supported features:
   * The atlas file can be a PVRTC, PNG or any other fomrat supported by Texture2D
   * Quads can be added in runtime
   * Quads can be removed in runtime
   * Quads can be re-ordered in runtime
   * The TextureAtlas capacity can be increased in runtime
   * Color array created on demand
 The quads are rendered using an OpenGL ES vertex array list
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

/** creates a TextureAtlas with an filename and with an initial capacity for Quads.
 * The TextureAtlas capacity can be increased in runtime.
 */
+(id) textureAtlasWithFile:(NSString*)file capacity:(NSUInteger)capacity;

/** initializes a TextureAtlas with a filename and with a certain capacity for Quads.
 * The TextureAtlas capacity can be increased in runtime.
 */
-(id) initWithFile: (NSString*) file capacity:(NSUInteger)capacity;

/** creates a TextureAtlas with a previously initialized Texture2D object, and
 * with an initial capacity for n Quads. 
 * The TextureAtlas capacity can be increased in runtime.
 */
+(id) textureAtlasWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity;

/** initializes a TextureAtlas with a previously initialized Texture2D object, and
 * with an initial capacity for Quads. 
 * The TextureAtlas capacity can be increased in runtime.
 */
-(id) initWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity;

/** updates a certain texture coordinate & vertex with new Quads.
 * index must be between 0 and the atlas capacity - 1
 */
-(void) updateQuadWithTexture: (ccQuad2*) quadT vertexQuad:(ccQuad3*) quadV atIndex:(NSUInteger)index;

/** updates the color (RGBA) for a certain quad
 * The 4 vertices of the Quad will be updated with this new quad color
 */
-(void) updateColorWithColorQuad:(ccColorB*)color atIndex:(NSUInteger)n;

/** updates a certain texture coordinate & vertex with new Quads.
 * index must be between 0 and the atlas capacity - 1
 */
-(void) updateQuadWithTexture:(ccQuad2*)texCoords vertexQuad:(ccQuad3*)vertexCoords atIndex:(NSUInteger)index;

/** Inserts a Quad with texture coordinate & vertex coords at a certain index.
 index must be between 0 and the atlas capacity - 1
 @since v0.7.2
 */
-(void) insertQuadWithTexture:(ccQuad2*)texCoords vertexQuad:(ccQuad3*)vertexCoords atIndex:(NSUInteger)index;

/** Removes the quad that is located at a certain index and inserts it at a new index
 This operation is faster than remove and insert in 2 different steps.
 @since v0.7.2
*/
-(void) insertQuadFromIndex:(NSUInteger)fromIndex atIndex:(NSUInteger)newIndex;

/** removes a quad at a given index number.
 The capacity remains the same, but the total number of quads to be drawn is reduced in 1
 @since v0.7.2
 */
-(void) removeQuadAtIndex:(NSUInteger) index;

/** removes all Quads.
 The TextureAtlas capacity remains untouched. No memory is freed.
 The total number of quads to be drawn will be 0
 @since v0.7.2
 */
-(void) removeAllQuads;
 

/** resize the capacity of the Texture Atlas.
 * The new capacity can be lower or higher
 */
-(void) resizeCapacity: (NSUInteger) n;


/** draws n quads
 * n can't be greater than the capacity of the Atlas
 */
-(void) drawNumberOfQuads: (NSUInteger) n;

/** draws all the Atlas's Quads
 */
-(void) drawQuads;

@end
