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

#import "cocos2d.h"

// I don't want to require Chipmunk to use HMVectorNode.
// But I don't want to maintain an entirely different version either.
#ifndef CHIPMUNK_HEADER
	typedef CGFloat	cpFloat;
	typedef CGPoint cpVect;
#endif

typedef ccColor4F Color;


@interface HMVectorNode : CCNode

-(void)drawDot:(cpVect)pos radius:(cpFloat)radius color:(Color)color;
-(void)drawSegmentFrom:(cpVect)a to:(cpVect)b radius:(cpFloat)radius color:(Color)color;
-(void)drawPolyWithVerts:(cpVect *)verts count:(NSUInteger)count width:(cpFloat)width fill:(Color)fill line:(Color)line;

/// Clear the geometry in the node's buffer.
-(void)clear;

@property(nonatomic, assign) ccBlendFunc blendFunc;

@end
