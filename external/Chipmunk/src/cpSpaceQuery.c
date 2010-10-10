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

#include "chipmunk.h"

#pragma mark Point Query Functions

typedef struct pointQueryContext {
	cpLayers layers;
	cpGroup group;
	cpSpacePointQueryFunc func;
	void *data;
} pointQueryContext;

static void 
pointQueryHelper(cpVect *point, cpShape *shape, pointQueryContext *context)
{
	if(
		!(shape->group && context->group == shape->group) && (context->layers&shape->layers) &&
		cpShapePointQuery(shape, *point)
	){
		context->func(shape, context->data);
	}
}

void
cpSpacePointQuery(cpSpace *space, cpVect point, cpLayers layers, cpGroup group, cpSpacePointQueryFunc func, void *data)
{
	pointQueryContext context = {layers, group, func, data};
	cpSpaceHashPointQuery(space->activeShapes, point, (cpSpaceHashQueryFunc)pointQueryHelper, &context);
	cpSpaceHashPointQuery(space->staticShapes, point, (cpSpaceHashQueryFunc)pointQueryHelper, &context);
}

static void
rememberLastPointQuery(cpShape *shape, cpShape **outShape)
{
	if(!shape->sensor) *outShape = shape;
}

cpShape *
cpSpacePointQueryFirst(cpSpace *space, cpVect point, cpLayers layers, cpGroup group)
{
	cpShape *shape = NULL;
	cpSpacePointQuery(space, point, layers, group, (cpSpacePointQueryFunc)rememberLastPointQuery, &shape);
	
	return shape;
}

void
cpSpaceEachBody(cpSpace *space, cpSpaceBodyIterator func, void *data)
{
	cpArray *bodies = space->bodies;
	
	for(int i=0; i<bodies->num; i++)
		func((cpBody *)bodies->arr[i], data);
}

#pragma mark Segment Query Functions

typedef struct segQueryContext {
	cpVect start, end;
	cpLayers layers;
	cpGroup group;
	cpSpaceSegmentQueryFunc func;
} segQueryContext;

static cpFloat
segQueryFunc(segQueryContext *context, cpShape *shape, void *data)
{
	cpSegmentQueryInfo info;
	
	if(
		!(shape->group && context->group == shape->group) && (context->layers&shape->layers) &&
		cpShapeSegmentQuery(shape, context->start, context->end, &info)
	){
		context->func(shape, info.t, info.n, data);
	}
	
	return 1.0f;
}

void
cpSpaceSegmentQuery(cpSpace *space, cpVect start, cpVect end, cpLayers layers, cpGroup group, cpSpaceSegmentQueryFunc func, void *data)
{
	segQueryContext context = {
		start, end,
		layers, group,
		func,
	};
	
	cpSpaceHashSegmentQuery(space->staticShapes, &context, start, end, 1.0f, (cpSpaceHashSegmentQueryFunc)segQueryFunc, data);
	cpSpaceHashSegmentQuery(space->activeShapes, &context, start, end, 1.0f, (cpSpaceHashSegmentQueryFunc)segQueryFunc, data);
}

typedef struct segQueryFirstContext {
	cpVect start, end;
	cpLayers layers;
	cpGroup group;
} segQueryFirstContext;

static cpFloat
segQueryFirst(segQueryFirstContext *context, cpShape *shape, cpSegmentQueryInfo *out)
{
	cpSegmentQueryInfo info;
	
	if(
		!(shape->group && context->group == shape->group) &&
		(context->layers&shape->layers) &&
		!shape->sensor &&
		cpShapeSegmentQuery(shape, context->start, context->end, &info) &&
		info.t < out->t
	){
		*out = info;
	}
	
	return out->t;
}

cpShape *
cpSpaceSegmentQueryFirst(cpSpace *space, cpVect start, cpVect end, cpLayers layers, cpGroup group, cpSegmentQueryInfo *out)
{
	cpSegmentQueryInfo info = {NULL, 1.0f, cpvzero};
	if(out){
		(*out) = info;
  } else {
		out = &info;
	}
	
	segQueryFirstContext context = {
		start, end,
		layers, group
	};
	
	cpSpaceHashSegmentQuery(space->staticShapes, &context, start, end, 1.0f, (cpSpaceHashSegmentQueryFunc)segQueryFirst, out);
	cpSpaceHashSegmentQuery(space->activeShapes, &context, start, end, out->t, (cpSpaceHashSegmentQueryFunc)segQueryFirst, out);
	
	return out->shape;
}

#pragma mark BB Query functions

typedef struct bbQueryContext {
	cpLayers layers;
	cpGroup group;
	cpSpaceBBQueryFunc func;
	void *data;
} bbQueryContext;

static void 
bbQueryHelper(cpBB *bb, cpShape *shape, bbQueryContext *context)
{
	if(
		!(shape->group && context->group == shape->group) && (context->layers&shape->layers) &&
		cpBBintersects(*bb, shape->bb)
	){
		context->func(shape, context->data);
	}
}

void
cpSpaceBBQuery(cpSpace *space, cpBB bb, cpLayers layers, cpGroup group, cpSpaceBBQueryFunc func, void *data)
{
	bbQueryContext context = {layers, group, func, data};
	cpSpaceHashQuery(space->activeShapes, &bb, bb, (cpSpaceHashQueryFunc)bbQueryHelper, &context);
	cpSpaceHashQuery(space->staticShapes, &bb, bb, (cpSpaceHashQueryFunc)bbQueryHelper, &context);
}
