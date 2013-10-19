/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2012 Pierre-David Bélanger
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

/** CCClippingNode is a subclass of CCNode.
 It draws its content (childs) clipped using a stencil.
 The stencil is an other CCNode that will not be drawn.
 The clipping is done using the alpha part of the stencil (adjusted with an alphaThreshold).
 */
@interface CCClippingNode : CCNode
{
    CCNode *_stencil;
    GLfloat _alphaThreshold;
    BOOL _inverted;
}

/** The CCNode to use as a stencil to do the clipping.
 The stencil node will be retained.
 This default to nil.
 */
@property (nonatomic, strong) CCNode *stencil;

/** The alpha threshold.
 The content is drawn only where the stencil have pixel with alpha greater than the alphaThreshold.
 Should be a float between 0 and 1.
 This default to 1 (so alpha test is disabled).
 */
@property (nonatomic) GLfloat alphaThreshold;

/** Inverted. If this is set to YES,
 the stencil is inverted, so the content is drawn where the stencil is NOT drawn.
 This default to NO.
 */
@property (nonatomic) BOOL inverted;

/** Creates and initializes a clipping node without a stencil.
 */
+ (id)clippingNode;

/** Creates and initializes a clipping node with an other node as its stencil.
 The stencil node will be retained.
 */
+ (id)clippingNodeWithStencil:(CCNode *)stencil;

/** Initializes a clipping node without a stencil.
 */
- (id)init;

/** Initializes a clipping node with an other node as its stencil.
 The stencil node will be retained, and its parent will be set to this clipping node.
 */
- (id)initWithStencil:(CCNode *)stencil;

@end
