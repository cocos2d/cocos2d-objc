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

#import "Texture2D.h"
#import "ccTypes.h"

/** A class that implements a Texture Atlas.
 Supported features:
   * The atlas file can be a PVRTC, PNG or any other fomrat supported by Texture2D
   * Quads can be udpated in runtime
   * Quads can be added in runtime
   * Quads can be removed in runtime
   * Quads can be re-ordered in runtime
   * The TextureAtlas capacity can be increased or decreased in runtime
   * OpenGL component: V3F, C4B, T2F.
 The quads are rendered using an OpenGL ES an interleaved vertex array list
 */
@interface TextureAtlas : NSObject {
	NSUInteger			totalQuads_;
	NSUInteger			capacity_;
	ccV3F_C4B_T2F_Quad	*quads;	// quads to be rendered
	GLushort			*indices;
	Texture2D			*texture_;	
}

/** quantity of quads that are going to be drawn */
@property (readonly) NSUInteger totalQuads;
/** quantity of quads that can be stored with the current texture atlas size */
@property (readonly) NSUInteger capacity;
/** Texture of the texture atlas */
@property (nonatomic,retain) Texture2D *texture;

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

/** updates a Quad (texture, vertex and color) at a certain index
 * index must be between 0 and the atlas capacity - 1
 @since v0.8
 */
-(void) updateQuad:(ccV3F_C4B_T2F_Quad*)quad atIndex:(NSUInteger)index;

/** Inserts a Quad (texture, vertex and color) at a certain index
 index must be between 0 and the atlas capacity - 1
 @since v0.8
 */
-(void) insertQuad:(ccV3F_C4B_T2F_Quad*)quad atIndex:(NSUInteger)index;

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
 * The new capacity can be lower or higher than the current one
 * It returns YES if the resize was successful.
 * If it fails to resize the capacity it will return NO with a new capacity of 0.
 */
-(BOOL) resizeCapacity: (NSUInteger) n;


/** draws n quads
 * n can't be greater than the capacity of the Atlas
 */
-(void) drawNumberOfQuads: (NSUInteger) n;

/** draws all the Atlas's Quads
 */
-(void) drawQuads;

@end
