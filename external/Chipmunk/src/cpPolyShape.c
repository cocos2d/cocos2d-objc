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
#include <math.h>

#include "chipmunk.h"

cpPolyShape *
cpPolyShapeAlloc(void)
{
	return (cpPolyShape *)calloc(1, sizeof(cpPolyShape));
}

static void
cpPolyShapeTransformVerts(cpPolyShape *poly, cpVect p, cpVect rot)
{
	cpVect *src = poly->verts;
	cpVect *dst = poly->tVerts;
	
	for(int i=0; i<poly->numVerts; i++)
		dst[i] = cpvadd(p, cpvrotate(src[i], rot));
}

static void
cpPolyShapeTransformAxes(cpPolyShape *poly, cpVect p, cpVect rot)
{
	cpPolyShapeAxis *src = poly->axes;
	cpPolyShapeAxis *dst = poly->tAxes;
	
	for(int i=0; i<poly->numVerts; i++){
		cpVect n = cpvrotate(src[i].n, rot);
		dst[i].n = n;
		dst[i].d = cpvdot(p, n) + src[i].d;
	}
}

static cpBB
cpPolyShapeCacheData(cpShape *shape, cpVect p, cpVect rot)
{
	cpPolyShape *poly = (cpPolyShape *)shape;
	
	cpFloat l, b, r, t;
	
	cpPolyShapeTransformAxes(poly, p, rot);
	cpPolyShapeTransformVerts(poly, p, rot);
	
	cpVect *verts = poly->tVerts;
	l = r = verts[0].x;
	b = t = verts[0].y;
	
	// TODO do as part of cpPolyShapeTransformVerts?
	for(int i=1; i<poly->numVerts; i++){
		cpVect v = verts[i];
		
		l = cpfmin(l, v.x);
		r = cpfmax(r, v.x);
		
		b = cpfmin(b, v.y);
		t = cpfmax(t, v.y);
	}
	
	return cpBBNew(l, b, r, t);
}

static void
cpPolyShapeDestroy(cpShape *shape)
{
	cpPolyShape *poly = (cpPolyShape *)shape;
	
	free(poly->verts);
	free(poly->tVerts);
	
	free(poly->axes);
	free(poly->tAxes);
}

static int
cpPolyShapePointQuery(cpShape *shape, cpVect p){
	// TODO Check against BB first?
	return cpPolyShapeContainsVert((cpPolyShape *)shape, p);
}

static const cpShapeClass polyClass = {
	CP_POLY_SHAPE,
	cpPolyShapeCacheData,
	cpPolyShapeDestroy,
	cpPolyShapePointQuery,
};

cpPolyShape *
cpPolyShapeInit(cpPolyShape *poly, cpBody *body, int numVerts, cpVect *verts, cpVect offset)
{	
	poly->numVerts = numVerts;

	poly->verts = (cpVect *)calloc(numVerts, sizeof(cpVect));
	poly->tVerts = (cpVect *)calloc(numVerts, sizeof(cpVect));
	poly->axes = (cpPolyShapeAxis *)calloc(numVerts, sizeof(cpPolyShapeAxis));
	poly->tAxes = (cpPolyShapeAxis *)calloc(numVerts, sizeof(cpPolyShapeAxis));
	
	for(int i=0; i<numVerts; i++){
		cpVect a = cpvadd(offset, verts[i]);
		cpVect b = cpvadd(offset, verts[(i+1)%numVerts]);
		cpVect n = cpvnormalize(cpvperp(cpvsub(b, a)));

		poly->verts[i] = a;
		poly->axes[i].n = n;
		poly->axes[i].d = cpvdot(n, a);
	}
	
	cpShapeInit((cpShape *)poly, &polyClass, body);

	return poly;
}

cpShape *
cpPolyShapeNew(cpBody *body, int numVerts, cpVect *verts, cpVect offset)
{
	return (cpShape *)cpPolyShapeInit(cpPolyShapeAlloc(), body, numVerts, verts, offset);
}
