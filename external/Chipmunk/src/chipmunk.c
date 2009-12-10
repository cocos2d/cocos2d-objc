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
 
#include <stdlib.h>
#include <stdio.h>

#include "chipmunk.h"

#ifdef __cplusplus
extern "C" {
#endif
	void cpInitCollisionFuncs(void);
#ifdef __cplusplus
}
#endif

char *cpVersionString = "5.0.0";

void
cpInitChipmunk(void)
{
#ifndef NDEBUG	
	printf("Initializing Chipmunk v%s (Debug Enabled)\n", cpVersionString);
#endif
	
	cpInitCollisionFuncs();
}

cpFloat
cpMomentForCircle(cpFloat m, cpFloat r1, cpFloat r2, cpVect offset)
{
	return (1.0f/2.0f)*m*(r1*r1 + r2*r2) + m*cpvdot(offset, offset);
}

cpFloat
cpMomentForSegment(cpFloat m, cpVect a, cpVect b)
{
	cpFloat length = cpvlength(cpvsub(b, a));
	cpVect offset = cpvmult(cpvadd(a, b), 1.0f/2.0f);
	
	return m*length*length/12.0f + m*cpvdot(offset, offset);
}

cpFloat
cpMomentForPoly(cpFloat m, const int numVerts, cpVect *verts, cpVect offset)
{
	cpVect *tVerts = (cpVect *)cpcalloc(numVerts, sizeof(cpVect));
	for(int i=0; i<numVerts; i++)
		tVerts[i] = cpvadd(verts[i], offset);
	
	cpFloat sum1 = 0.0f;
	cpFloat sum2 = 0.0f;
	for(int i=0; i<numVerts; i++){
		cpVect v1 = tVerts[i];
		cpVect v2 = tVerts[(i+1)%numVerts];
		
		cpFloat a = cpvcross(v2, v1);
		cpFloat b = cpvdot(v1, v1) + cpvdot(v1, v2) + cpvdot(v2, v2);
		
		sum1 += a*b;
		sum2 += a;
	}
	
	cpfree(tVerts);
	return (m*sum1)/(6.0f*sum2);
}

// Create non static inlined copies of Chipmunk functions, useful for working with dynamic FFIs
#define MAKE_REF(name) __typeof__(name) *_##name = name;
MAKE_REF(cpv); // makes a variable named _cpv that contains the function pointer for cpv()
MAKE_REF(cpvadd);
MAKE_REF(cpvneg);
MAKE_REF(cpvsub);
MAKE_REF(cpvmult);
MAKE_REF(cpvdot);
MAKE_REF(cpvcross);
MAKE_REF(cpvperp);
MAKE_REF(cpvrperp);
MAKE_REF(cpvproject);
MAKE_REF(cpvrotate);
MAKE_REF(cpvunrotate);
MAKE_REF(cpvlengthsq);
MAKE_REF(cpvlerp);
MAKE_REF(cpvnormalize);
MAKE_REF(cpvnormalize_safe);
MAKE_REF(cpvclamp);
MAKE_REF(cpvlerpconst);
MAKE_REF(cpvdist);
MAKE_REF(cpvnear);
MAKE_REF(cpvdistsq);

MAKE_REF(cpBBNew);
MAKE_REF(cpBBintersects);
MAKE_REF(cpBBcontainsBB);
MAKE_REF(cpBBcontainsVect);
MAKE_REF(cpBBmerge);
MAKE_REF(cpBBexpand);

MAKE_REF(cpBodyWorld2Local);
MAKE_REF(cpBodyLocal2World);
MAKE_REF(cpBodyApplyImpulse);
