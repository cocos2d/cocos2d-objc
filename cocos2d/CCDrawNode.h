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
 *  CCDrawNode
 *  Node that draws dots, segments and polygons.
 *  The geometry will be saved, so primitives does not need to be redrawn for each frame
 *  Faster than the "drawing primitives" since they it draws everything in one single batch.
 */
@interface CCDrawNode : CCNode {
    
	GLuint			_vao;
	GLuint			_vbo;
	
	NSUInteger		_bufferCapacity;
	GLsizei			_bufferCount;
	ccV2F_C4B_T2F	*_buffer;

	ccBlendFunc		_blendFunc;

	BOOL _dirty;
}

/** Sets the blending function for the draw node.  All primitives will be drawn using the same blend function. */
@property(nonatomic, assign) ccBlendFunc blendFunc;


/// -----------------------------------------------------------------------
/// @name Primitive Drawing Methods
/// -----------------------------------------------------------------------

/**
 *  Draw a dot at a position, with a given radius and color.
 *
 *  @param pos    Dot position.
 *  @param radius Dot radius.
 *  @param color  Dot color.
 */
-(void)drawDot:(CGPoint)pos radius:(CGFloat)radius color:(CCColor*)color;

/**
 *  Draw a segment with a radius and color.
 *
 *  @param a      Segment starting point.
 *  @param b      Segment end point.
 *  @param radius Segment radius.
 *  @param color  Segment color.
 */
-(void)drawSegmentFrom:(CGPoint)a to:(CGPoint)b radius:(CGFloat)radius color:(CCColor*)color;

/**
 *  Draw a polygon with a fill color and line color.
 *
 *  @param verts Array of CGPoints, containing the vertices.
 *  @param count Number of vertices.
 *  @param fill  Polygon fill color.
 *  @param width Polygon outline width.
 *  @param line  Polygon outline color.
 */
-(void)drawPolyWithVerts:(const CGPoint*)verts count:(NSUInteger)count fillColor:(CCColor*)fill borderWidth:(CGFloat)width  borderColor:(CCColor*)line;


/// -----------------------------------------------------------------------
/// @name Draw Node Management
/// -----------------------------------------------------------------------

/** Clear the geometry in the node's buffer. */
-(void)clear;

@end
