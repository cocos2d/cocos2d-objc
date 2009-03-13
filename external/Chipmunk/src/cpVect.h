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
 
#import <CoreGraphics/CGGeometry.h>
#define cpVect CGPoint
//typedef struct cpVect{
//	cpFloat x,y;
//} cpVect;

static const cpVect cpvzero={0.0f,0.0f};

static inline cpVect
cpv(const cpFloat x, const cpFloat y)
{
	cpVect v = {x, y};
	return v;
}

static inline cpVect
cpvadd(const cpVect v1, const cpVect v2)
{
	return cpv(v1.x + v2.x, v1.y + v2.y);
}

static inline cpVect
cpvneg(const cpVect v)
{
	return cpv(-v.x, -v.y);
}

static inline cpVect
cpvsub(const cpVect v1, const cpVect v2)
{
	return cpv(v1.x - v2.x, v1.y - v2.y);
}

static inline cpVect
cpvmult(const cpVect v, const cpFloat s)
{
	return cpv(v.x*s, v.y*s);
}

static inline cpFloat
cpvdot(const cpVect v1, const cpVect v2)
{
	return v1.x*v2.x + v1.y*v2.y;
}

static inline cpFloat
cpvcross(const cpVect v1, const cpVect v2)
{
	return v1.x*v2.y - v1.y*v2.x;
}

static inline cpVect
cpvperp(const cpVect v)
{
	return cpv(-v.y, v.x);
}

static inline cpVect
cpvrperp(const cpVect v)
{
	return cpv(v.y, -v.x);
}

static inline cpVect
cpvproject(const cpVect v1, const cpVect v2)
{
	return cpvmult(v2, cpvdot(v1, v2)/cpvdot(v2, v2));
}

static inline cpVect
cpvrotate(const cpVect v1, const cpVect v2)
{
	return cpv(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
}

static inline cpVect
cpvunrotate(const cpVect v1, const cpVect v2)
{
	return cpv(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
}

cpFloat cpvlength(const cpVect v);
cpFloat cpvlengthsq(const cpVect v); // no sqrt() call
cpVect cpvnormalize(const cpVect v);
cpVect cpvforangle(const cpFloat a); // convert radians to a normalized vector
cpFloat cpvtoangle(const cpVect v); // convert a vector to radians
char *cpvstr(const cpVect v); // get a string representation of a vector
