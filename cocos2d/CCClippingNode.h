/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2012 Pierre-David Bélanger
 * Copyright (c) 2013-2014 Cocos2D Authors
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

#import "CCNode.h"

/**
 CCClippingNode can be used to clip (crop) your node content using a stencil (mask) node. 
 
 Where the stencil node draws opaque pixels (respectively pixels with alphaThreshold or higher alpha values) the clipping node
 will draw its children. Where the stencil node's pixels are below the alphaThreshold the clipping node's children will not be drawn.
 
 By default alphaThreshold is 1.0 which means the stencil node's area where it draws fully opaque pixels will draw the clippin node's children.
 
 The alpha clipping behavior can be inverted.
 The stencil node itself will not be visible.
 */
@interface CCClippingNode : CCNode {
    
    // Stencil Node.
    CCNode *_stencil;
    
    // Alpha threshold.
    NSNumber *_alphaThreshold;
    
    // Inverted.
    BOOL _inverted;
}


/// -----------------------------------------------------------------------
/// @name Creating a CCClippingNode
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a clipping node without a stencil.
 *
 *  @return The new CCClippingNode instance.
 *  @see clippingNodeWithStencil:
 */
+(id) clippingNode;

/**
 *  Creates and returns a clipping node object with the specified stencil node.
 *
 *  @param stencil Node to use as stencil (mask).
 *
 *  @return The new CCClippingNode instance.
 *  @see clippingNode
 */
+(id) clippingNodeWithStencil:(CCNode *)stencil;

// purposefully undocumented: init is inherited from NSObject
-(id) init;

/**
 *  Initializes and returns a clipping node object with the specified stencil node.
 *
 *  @param stencil Node to use as stencil (mask).
 *
 *  @return The new CCClippingNode instance.
 *  @see clippingNodeWithStencil:
 */
-(id) initWithStencil:(CCNode *)stencil;

/// -----------------------------------------------------------------------
/// @name Accessing the Stencil (Mask) Node
/// -----------------------------------------------------------------------

/** The stencil node's content will define which area is clipped (masked). */
@property (nonatomic, strong) CCNode *stencil;

/// -----------------------------------------------------------------------
/// @name Modify Clipping Behavior
/// -----------------------------------------------------------------------

/** The alpha threshold determines the minimum alpha value that is considered as masked. 
 Defaults to 1.0 (any pixel not fully opaque will clip/mask contents). */
@property (nonatomic) GLfloat alphaThreshold;

/** If inverted, the alpha-based clipping will be reversed such that pixels with alphaThreshold or higher will clip/mask out content. */
@property (nonatomic) BOOL inverted;

@end
