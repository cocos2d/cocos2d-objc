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
#include <assert.h>

#include "chipmunk.h"

unsigned int SHAPE_ID_COUNTER = 0;

void
cpResetShapeIdCounter(void)
{
	SHAPE_ID_COUNTER = 0;
}


cpShape*
cpShapeInit(cpShape *shape, cpShapeType type, cpBody *body)
{
	shape->type = type;
	
	shape->id = SHAPE_ID_COUNTER;
	SHAPE_ID_COUNTER++;
	
	assert(body != NULL);
	shape->body = body;
	
	shape->e = 0.0f;
	shape->u = 0.0f;
	shape->surface_v = cpvzero;
	
	shape->collision_type = 0;
	shape->group = 0;
	shape->layers = 0xFFFF;
	
	shape->data = NULL;
	
	cpShapeCacheBB(shape);
	
	return shape;
}

void
cpShapeDestroy(cpShape *shape)
{
	if(shape->destroy) shape->destroy(shape);
}

void
cpShapeFree(cpShape *shape)
{
	if(shape) cpShapeDestroy(shape);
	free(shape);
}

cpBB
cpShapeCacheBB(cpShape *shape)
{
	cpBody *body = shape->body;
	
	shape->bb = shape->cacheData(shape, body->p, body->rot);
	return shape->bb;
}


cpCircleShape *
cpCircleShapeAlloc(void)
{
	return (cpCircleShape *)calloc(1, sizeof(cpCircleShape));
}

static inline cpBB
bbFromCircle(const cpVect c, const cpFloat r)
{
	return cpBBNew(c.x-r, c.y-r, c.x+r, c.y+r);
}

static cpBB
cpCircleShapeCacheData(cpShape *shape, cpVect p, cpVect rot)
{
	cpCircleShape *circle = (cpCircleShape *)shape;
	
	circle->tc = cpvadd(p, cpvrotate(circle->c, rot));
	return bbFromCircle(circle->tc, circle->r);
}

cpCircleShape *
cpCircleShapeInit(cpCircleShape *circle, cpBody *body, cpFloat radius, cpVect offset)
{
	circle->c = offset;
	circle->r = radius;
	
	circle->shape.cacheData = &cpCircleShapeCacheData;
	circle->shape.destroy = NULL;
	cpShapeInit((cpShape *)circle, CP_CIRCLE_SHAPE, body);
	
	return circle;
}

cpShape *
cpCircleShapeNew(cpBody *body, cpFloat radius, cpVect offset)
{
	return (cpShape *)cpCircleShapeInit(cpCircleShapeAlloc(), body, radius, offset);
}

cpSegmentShape *
cpSegmentShapeAlloc(void)
{
	return (cpSegmentShape *)calloc(1, sizeof(cpSegmentShape));
}

static cpBB
cpSegmentShapeCacheData(cpShape *shape, cpVect p, cpVect rot)
{
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	
	seg->ta = cpvadd(p, cpvrotate(seg->a, rot));
	seg->tb = cpvadd(p, cpvrotate(seg->b, rot));
	seg->tn = cpvrotate(seg->n, rot);
	
	cpFloat l,r,s,t;
	
	if(seg->ta.x < seg->tb.x){
		l = seg->ta.x;
		r = seg->tb.x;
	} else {
		l = seg->tb.x;
		r = seg->ta.x;
	}
	
	if(seg->ta.y < seg->tb.y){
		s = seg->ta.y;
		t = seg->tb.y;
	} else {
		s = seg->tb.y;
		t = seg->ta.y;
	}
	
	cpFloat rad = seg->r;
	return cpBBNew(l - rad, s - rad, r + rad, t + rad);
}

cpSegmentShape *
cpSegmentShapeInit(cpSegmentShape *seg, cpBody *body, cpVect a, cpVect b, cpFloat r)
{
	seg->a = a;
	seg->b = b;
	seg->n = cpvperp(cpvnormalize(cpvsub(b, a)));
	
	seg->r = r;
	
	seg->shape.cacheData = &cpSegmentShapeCacheData;
	seg->shape.destroy = NULL;
	cpShapeInit((cpShape *)seg, CP_SEGMENT_SHAPE, body);
	
	return seg;
}

cpShape*
cpSegmentShapeNew(cpBody *body, cpVect a, cpVect b, cpFloat r)
{
	return (cpShape *)cpSegmentShapeInit(cpSegmentShapeAlloc(), body, a, b, r);
}
