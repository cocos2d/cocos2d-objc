/*
 * cocos2d swift: http://www.cocos2d-swift.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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

#import "ccTypes.h"

#import "CCLightGroups.h"


#if CC_EFFECTS_EXPERIMENTAL

extern const CCLightGroupMask CCLightCollectionAllGroups;

@class CCLightNode;

/**
 * CCLightCollection is a container for light nodes within the scene.  It allows
 * CCEffectLighting to find the most influential N lights given the relative positions
 * of a node and the contained lights.
 */

@interface CCLightCollection : NSObject

/// -----------------------------------------------------------------------
/// @name Initializing a CCLightCollection object
/// -----------------------------------------------------------------------

/**
 *  Initializes an empty CCLightCollection object.
 *
 *  @return The CCLightCollection object.
 */
- (id)init;


/// -----------------------------------------------------------------------
/// @name Adding and Removing Lights
/// -----------------------------------------------------------------------

/**
 *  Adds a light to the collection.
 *
 *  @param light CCLightNode to add.
 */
- (void)addLight:(CCLightNode *)light;

/**
 *  Removes a light from the collection.
 *
 *  @param light The light node to remove.
 */
- (void)removeLight:(CCLightNode *)light;

/**
 *  Removes all lights from the collection.
 */
- (void)removeAllLights;



/// -----------------------------------------------------------------------
/// @name Querying for a Subset of Lights
/// -----------------------------------------------------------------------

/**
 *  Finds the closest lights to the supplied point.
 *
 *  @param count The number of lights to return.
 *  @param point The reference point.
 */
- (NSArray*)findClosestKLights:(NSUInteger)count toPoint:(CGPoint)point withMask:(CCLightGroupMask)mask;


/// -----------------------------------------------------------------------
/// @name Light groups
/// -----------------------------------------------------------------------

/**
 *  Convert an array of light group identifiers into a group bitmask.
 *  The categories are retained and assigned indexes.
 *
 *  @param categories Array of categories.
 *
 *  @return Bitmask.
 */
- (CCLightGroupMask)maskForGroups:(NSArray *)groups;

@end

#endif
