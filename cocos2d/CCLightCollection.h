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
#import "CCColor.h"
#import "CCLightGroups.h"

extern const CCLightGroupMask CCLightCollectionAllGroups;

@class CCLightNode;

/**
 * CCLightCollection is a container for light nodes within the scene.  It allows
 * CCEffectLighting to find the most influential N lights given the relative positions
 * of a node and the contained lights.
 *
 * @note This class is currently considered experimental. Set the `CC_EFFECTS_EXPERIMENTAL` macro to 1 in ccConfig.h if you want to use this class.
 *
 */

@interface CCLightCollection : NSObject

/// -----------------------------------------------------------------------
/// @name Creating a Light Collection
/// -----------------------------------------------------------------------

/**
 *  Initializes an empty CCLightCollection object.
 *
 *  @return The CCLightCollection object.
 *  @since v3.4 and later
 */
- (id)init;


/// -----------------------------------------------------------------------
/// @name Adding and Removing Lights
/// -----------------------------------------------------------------------

/**
 *  Adds a light to the collection.
 *
 *  @param light CCLightNode to add.
 *  @since v3.4 and later
 *  @see CCLightNode
 */
- (void)addLight:(CCLightNode *)light;

/**
 *  Removes a light from the collection.
 *
 *  @param light The light node to remove.
 *  @since v3.4 and later
 *  @see CCLightNode
 */
- (void)removeLight:(CCLightNode *)light;

/**
 *  Removes all lights from the collection.
 *  @since v3.4 and later
 */
- (void)removeAllLights;



/// -----------------------------------------------------------------------
/// @name Querying for a Subset of Lights
/// -----------------------------------------------------------------------

/**
 *  Finds the closest lights to the supplied point.
 *
 *  @note CCLightGroupMask is declared as NSUInteger
 *
 *  @param count The number of lights to return.
 *  @param point The reference point.
 *  @param mask The light group mask.
 *  @since v3.4 and later
 */
- (NSArray*)findClosestKLights:(NSUInteger)count toPoint:(CGPoint)point withMask:(CCLightGroupMask)mask;

/**
 *  Return the sum of ambient colors for all lights matching the
 *  supplied mask.
 *
 *  @param mask    The light group mask to match.
 */
- (CCColor*)findAmbientSumForLightsWithMask:(CCLightGroupMask)mask;


/// -----------------------------------------------------------------------
/// @name Getting a Light Groups Mask
/// -----------------------------------------------------------------------

/**
 *  Convert an array of light group identifiers into a group bitmask.
 *  The groups are retained and assigned indexes.
 *
 *  @note CCLightGroupMask is declared as NSUInteger
 *
 *  @param groups Array of groups.
 *
 *  @return Bitmask.
 *  @since v3.4 and later
 */
- (CCLightGroupMask)maskForGroups:(NSArray *)groups;

/**
 *  Reset the group name to group mask mapping. This invalidates any outstanding
 *  group masks.
 */
- (void)flushGroupNames;

@end
