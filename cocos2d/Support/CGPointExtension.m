/* Copyright (c) 2007 Scott Lembcke
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

#include "stdio.h"
#include "math.h"

#include "CGPointExtension.h"

CGFloat
CGPointLength(const CGPoint v)
{
	return sqrtf( CGPointDot(v, v) );
}

CGFloat
CGPointDistance(const CGPoint v1, const CGPoint v2)
{
	return CGPointLength(CGPointSub(v1, v2));
}

CGPoint
CGPointNormalize(const CGPoint v)
{
	return CGPointMult( v, 1.0f/CGPointLength(v) );
}

CGPoint
CGPointForAngle(const CGFloat a)
{
	return CGPointMake(cosf(a), sinf(a));
}

CGFloat
CGPointToAngle(const CGPoint v)
{
	return atan2f(v.y, v.x);
}

const char*
CGPointToCString(const CGPoint v)
{
	static char str[256];
	sprintf(str, "(% .3f, % .3f)", v.x, v.y);
	return str;
}
