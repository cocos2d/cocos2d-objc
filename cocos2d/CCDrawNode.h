/* Copyright (c) 2012 Scott Lembcke and Howling Moon Software
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
 * araker edited for 1.1. (really basic implementation)
 */

#import "CCNode.h"

/** CCDrawNode
 Node that draws dots, segments and polygons.
 Faster than the "drawing primitives" since they it draws everything in one single batch.

 @since v1.1RC0
 */
@interface CCDrawNode : CCNode
{
    ccV2F_C4B_T2F_Triangle *triangles_;
    int total_;
    NSUInteger capacity_;
}

- (void) render;

- (void) draw;

-(BOOL) resizeCapacity: (NSUInteger) newCapacity;


/** draw a dot at a position, with a given radius and color */
-(void)drawDot:(CGPoint)pos radius:(CGFloat)radius color:(ccColor4F)color;

/** draw a segment with a radius and color */
-(void)drawSegmentFrom:(CGPoint)a to:(CGPoint)b radius:(CGFloat)radius color:(ccColor4F)color;

/** draw a polygon with a fill color and line color */
-(void)drawPolyWithVerts:(CGPoint*)verts count:(NSUInteger)count fillColor:(ccColor4F)fill borderWidth:(CGFloat)width  borderColor:(ccColor4F)line;

/** Clear the geometry in the node's buffer. */
-(void)clear;

@end
