/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
 Moving the parallax node via actions or by changing its position will move its child nodes
 based on parallax ratios. This allows you to create parallax layers of nodes.
 */
@interface CCParallaxNode : CCNode {
    
    // Parallax child ratios.
    NSMutableArray      *_parallaxArray;
    
    // Last position.
	CGPoint				_lastPosition;
}


/// -----------------------------------------------------------------------
/// @name Accessing Parallax Ratios
/// -----------------------------------------------------------------------

/** Array that holds the offset / ratio of the child nodes. */
@property (nonatomic,readonly) NSArray * parallaxArray;


/// -----------------------------------------------------------------------
/// @name Adding Parallax Nodes
/// -----------------------------------------------------------------------

/**
 *  Adds the specified child node with zOrder, ratio and offset values to the parallax node.
 *
 *  @param node           Node to add.
 *  @param z              zOrder to use for the added node.
 *  @param c              Parallax ratio to use for the added node.
 *  @param positionOffset Parallax offset to use for the added node.
 *  @see CCNode
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z parallaxRatio:(CGPoint)c positionOffset:(CGPoint)positionOffset;

@end
