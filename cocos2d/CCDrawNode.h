/* Copyright (c) 2012 Scott Lembcke and Howling Moon Software
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Code copied & pasted from SpacePatrol game https://github.com/slembcke/SpacePatrol
 *
 * Renamed and added some changes for cocos2d
 *
 */

#import "CCNode.h"

/** 
 Node that draws dots, segments and polygons. Draws everything in a single batch draw.
 
 The geometry will be saved and batch-drawn, so added primitives do not need to be re-added every frame.
 
 @warning This node is primarily meant for debug drawing (debug overlays). It does not support changing already added primitives
 without first removing and re-adding all primitives, which makes modifying the draw node's state inefficient. 
 For complex vector drawing and entire games built on vector graphics it is strongly recommended to write your own
 vector rendering node by using CCRenderer (OpenGL or Metal).
 */
@interface CCDrawNode : CCNode


/// -----------------------------------------------------------------------
/// @name Adding Primitives
/// -----------------------------------------------------------------------

/**
 *  Adds a dot at a position, with a given radius and color.
 *
 *  @param pos    Dot position.
 *  @param radius Dot radius.
 *  @param color  Dot color.
 *  @see CCColor
 */
-(void)drawDot:(CGPoint)pos radius:(CGFloat)radius color:(CCColor *)color;

/**
 *  Adds a segment with a radius and color.
 *
 *  @param a      Segment starting point.
 *  @param b      Segment end point.
 *  @param radius Segment radius.
 *  @param color  Segment color.
 *  @see CCColor
 */
-(void)drawSegmentFrom:(CGPoint)a to:(CGPoint)b radius:(CGFloat)radius color:(CCColor *)color;

/**
 *  Draw a convex polygon with a fill color and line color.
 *  The polygon winding must be clockwise.
 *
 *  @param verts Array of CGPoints, containing the vertices.
 *  @param count Number of vertices.
 *  @param fill  Polygon fill color.
 *  @param width Polygon outline width.
 *  @param line  Polygon outline color.
 *  @see CCColor
 */
-(void)drawPolyWithVerts:(const CGPoint *)verts count:(NSUInteger)count fillColor:(CCColor *)fill borderWidth:(CGFloat)width  borderColor:(CCColor *)line;


/// -----------------------------------------------------------------------
/// @name Removing all Primitives
/// -----------------------------------------------------------------------

/** Removes all buffered primitives from the node's buffer. 
 After calling this the draw node will not draw anything.
 
 @warning If you need to just change a single primitive, you have to clear the draw node, and re-add all existing primitives that you've
 stored somewhere, with the changes applied. This is of course inefficient, hence the recommendation to use this node primarily for debug drawing. */
-(void)clear;

@end
