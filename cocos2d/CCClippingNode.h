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
 CCClippingNode can be used to clip (crop) your node content using a stencil.
 
 ### Notes
 
 - The stencil is an other CCNode that will not be drawn.
 - The clipping is done using the alpha part of the stencil (adjusted with an alphaThreshold).
 - Alpha threshold, content is only drawn where the stencil has pixels with alpha greater than the alpha threshold. (Default 1 disable alpha test)
 - Inverted, when True only draw the content outside of the stencil. (Default False)
 
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
/// @name Accessing Clipping Node Attributes
/// -----------------------------------------------------------------------


/** Stencil Node. */
@property (nonatomic, strong) CCNode *stencil;

/** The Alpha threshold. */
@property (nonatomic) GLfloat alphaThreshold;

/** Inverted. */
@property (nonatomic) BOOL inverted;


/// -----------------------------------------------------------------------
/// @name Creating a CCClippingNode Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a clipping node object without a stencil.
 *
 *  @return The CCClippingNode Object.
 */
+(id) clippingNode;

/**
 *  Creates and returns a clipping node object with the specified stencil node.
 *
 *  @param stencil Node to use as stencil.
 *
 *  @return The CCClippingNode Object.
 */
+(id) clippingNodeWithStencil:(CCNode *)stencil;


/// -----------------------------------------------------------------------
/// @name Initializing a CCClippingNode Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns a clipping node object without a stencil.
 *
 *  @return An initialized CCClippingNode Object.
 */
-(id) init;

/**
 *  Initializes and returns a clipping node object with the specified stencil node.
 *
 *  @param stencil Node to use as stencil.
 *
 *  @return An initialized CCClippingNode Object.
 */
-(id) initWithStencil:(CCNode *)stencil;

@end
