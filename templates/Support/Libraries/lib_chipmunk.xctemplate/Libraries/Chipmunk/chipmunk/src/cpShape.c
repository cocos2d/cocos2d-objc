/* Copyright (c) 2013 Scott Lembcke and Howling Moon Software
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

#include "chipmunk/chipmunk_private.h"
#include "chipmunk_unsafe.h"

#define CP_DefineShapeGetter(struct, type, member, name) \
CP_DeclareShapeGetter(struct, type, name){ \
	cpAssertHard(shape->klass == &struct##Class, "shape is not a "#struct); \
	return ((struct *)shape)->member; \
}

cpShape *
cpShapeInit(cpShape *shape, const cpShapeClass *klass, cpBody *body, struct cpShapeMassInfo massInfo)
{
	shape->klass = klass;
	
	shape->body = body;
	shape->massInfo = massInfo;
	
	shape->sensor = 0;
	
	shape->e = 0.0f;
	shape->u = 0.0f;
	shape->surfaceV = cpvzero;
	
	shape->type = 0;
	shape->filter.group = CP_NO_GROUP;
	shape->filter.categories = CP_ALL_CATEGORIES;
	shape->filter.mask = CP_ALL_CATEGORIES;
	
	shape->userData = NULL;
	
	shape->space = NULL;
	
	shape->next = NULL;
	shape->prev = NULL;
	
	return shape;
}

void
cpShapeDestroy(cpShape *shape)
{
	if(shape->klass && shape->klass->destroy) shape->klass->destroy(shape);
}

void
cpShapeFree(cpShape *shape)
{
	if(shape){
		cpShapeDestroy(shape);
		cpfree(shape);
	}
}

cpSpace *
cpShapeGetSpace(const cpShape *shape)
{
	return shape->space;
}

cpBody *
cpShapeGetBody(const cpShape *shape)
{
	return shape->body;
}

void
cpShapeSetBody(cpShape *shape, cpBody *body)
{
	cpAssertHard(!cpShapeActive(shape), "You cannot change the body on an active shape. You must remove the shape from the space before changing the body.");
	shape->body = body;
}

cpFloat cpShapeGetMass(cpShape *shape){ return shape->massInfo.m; }

void
cpShapeSetMass(cpShape *shape, cpFloat mass){
	cpBody *body = shape->body;
	cpBodyActivate(body);
	
	shape->massInfo.m = mass;
	cpBodyAccumulateMassFromShapes(body);
}

cpFloat cpShapeGetDensity(cpShape *shape){ return shape->massInfo.m/shape->massInfo.area; }
void cpShapeSetDensity(cpShape *shape, cpFloat density){ cpShapeSetMass(shape, density*shape->massInfo.area); }

cpFloat cpShapeGetMoment(cpShape *shape){ return shape->massInfo.m*shape->massInfo.i; }
cpFloat cpShapeGetArea(cpShape *shape){ return shape->massInfo.area; }
cpVect cpShapeGetCenterOfGravity(cpShape *shape) { return shape->massInfo.cog; }

cpBB
cpShapeGetBB(const cpShape *shape)
{
	return shape->bb;
}

cpBool
cpShapeGetSensor(const cpShape *shape)
{
	return shape->sensor;
}

void
cpShapeSetSensor(cpShape *shape, cpBool sensor)
{
	cpBodyActivate(shape->body);
	shape->sensor = sensor;
}

cpFloat
cpShapeGetElasticity(const cpShape *shape)
{
	return shape->e;
}

void
cpShapeSetElasticity(cpShape *shape, cpFloat elasticity)
{
	cpAssertHard(elasticity >= 0.0f, "Elasticity must be positive and non-zero.");
	cpBodyActivate(shape->body);
	shape->e = elasticity;
}

cpFloat
cpShapeGetFriction(const cpShape *shape)
{
	return shape->u;
}

void
cpShapeSetFriction(cpShape *shape, cpFloat friction)
{
	cpAssertHard(friction >= 0.0f, "Friction must be postive and non-zero.");
	cpBodyActivate(shape->body);
	shape->u = friction;
}

cpVect
cpShapeGetSurfaceVelocity(const cpShape *shape)
{
	return shape->surfaceV;
}

void
cpShapeSetSurfaceVelocity(cpShape *shape, cpVect surfaceVelocity)
{
	cpBodyActivate(shape->body);
	shape->surfaceV = surfaceVelocity;
}

cpDataPointer
cpShapeGetUserData(const cpShape *shape)
{
	return shape->userData;
}

void
cpShapeSetUserData(cpShape *shape, cpDataPointer userData)
{
	shape->userData = userData;
}

cpCollisionType
cpShapeGetCollisionType(const cpShape *shape)
{
	return shape->type;
}

void
cpShapeSetCollisionType(cpShape *shape, cpCollisionType collisionType)
{
	cpBodyActivate(shape->body);
	shape->type = collisionType;
}

cpShapeFilter
cpShapeGetFilter(const cpShape *shape)
{
	return shape->filter;
}

void
cpShapeSetFilter(cpShape *shape, cpShapeFilter filter)
{
	cpBodyActivate(shape->body);
	shape->filter = filter;
}

cpBB
cpShapeCacheBB(cpShape *shape)
{
	return cpShapeUpdate(shape, shape->body->transform);
}

cpBB
cpShapeUpdate(cpShape *shape, cpTransform transform)
{
	return (shape->bb = shape->klass->cacheData(shape, transform));
}

cpFloat
cpShapePointQuery(const cpShape *shape, cpVect p, cpPointQueryInfo *info)
{
	cpPointQueryInfo blank = {NULL, cpvzero, INFINITY, cpvzero};
	if(info){
		(*info) = blank;
	} else {
		info = &blank;
	}
	
	shape->klass->pointQuery(shape, p, info);
	return info->distance;
}


cpBool
cpShapeSegmentQuery(const cpShape *shape, cpVect a, cpVect b, cpFloat radius, cpSegmentQueryInfo *info){
	cpSegmentQueryInfo blank = {NULL, b, cpvzero, 1.0f};
	if(info){
		(*info) = blank;
	} else {
		info = &blank;
	}
	
	cpPointQueryInfo nearest;
	shape->klass->pointQuery(shape, a, &nearest);
	if(nearest.distance <= radius){
		info->shape = shape;
		info->alpha = 0.0;
		info->normal = cpvnormalize(cpvsub(a, nearest.point));
	} else {
		shape->klass->segmentQuery(shape, a, b, radius, info);
	}
	
	return (info->shape != NULL);
}

cpContactPointSet
cpShapesCollide(const cpShape *a, const cpShape *b)
{
	struct cpContact contacts[CP_MAX_CONTACTS_PER_ARBITER];
	struct cpCollisionInfo info = cpCollide(a, b, 0, contacts);
	
	cpContactPointSet set;
	set.count = info.count;
	
	// cpCollideShapes() may have swapped the contact order. Flip the normal.
	cpBool swapped = (a != info.a);
	set.normal = (swapped ? cpvneg(info.n) : info.n);
	
	for(int i=0; i<info.count; i++){
		// cpCollideShapesInfo() returns contacts with absolute positions.
		cpVect p1 = contacts[i].r1;
		cpVect p2 = contacts[i].r2;
		
		set.points[i].pointA = (swapped ? p2 : p1);
		set.points[i].pointB = (swapped ? p1 : p2);
		set.points[i].distance = cpvdot(cpvsub(p2, p1), set.normal);
	}
	
	return set;
}

cpCircleShape *
cpCircleShapeAlloc(void)
{
	return (cpCircleShape *)cpcalloc(1, sizeof(cpCircleShape));
}

static cpBB
cpCircleShapeCacheData(cpCircleShape *circle, cpTransform transform)
{
	cpVect c = circle->tc = cpTransformPoint(transform, circle->c);
	return cpBBNewForCircle(c, circle->r);
}

static void
cpCircleShapePointQuery(cpCircleShape *circle, cpVect p, cpPointQueryInfo *info)
{
	cpVect delta = cpvsub(p, circle->tc);
	cpFloat d = cpvlength(delta);
	cpFloat r = circle->r;
	
	info->shape = (cpShape *)circle;
	info->point = cpvadd(circle->tc, cpvmult(delta, r/d)); // TODO: div/0
	info->distance = d - r;
	
	// Use up for the gradient if the distance is very small.
	info->gradient = (d > MAGIC_EPSILON ? cpvmult(delta, 1.0f/d) : cpv(0.0f, 1.0f));
}

static void
cpCircleShapeSegmentQuery(cpCircleShape *circle, cpVect a, cpVect b, cpFloat radius, cpSegmentQueryInfo *info)
{
	CircleSegmentQuery((cpShape *)circle, circle->tc, circle->r, a, b, radius, info);
}

static struct cpShapeMassInfo
cpCircleShapeMassInfo(cpFloat mass, cpFloat radius, cpVect center)
{
	struct cpShapeMassInfo info = {
		mass, cpMomentForCircle(1.0f, 0.0f, radius, cpvzero),
		center,
		cpAreaForCircle(0.0f, radius),
	};
	
	return info;
}

static const cpShapeClass cpCircleShapeClass = {
	CP_CIRCLE_SHAPE,
	(cpShapeCacheDataImpl)cpCircleShapeCacheData,
	NULL,
	(cpShapePointQueryImpl)cpCircleShapePointQuery,
	(cpShapeSegmentQueryImpl)cpCircleShapeSegmentQuery,
};

cpCircleShape *
cpCircleShapeInit(cpCircleShape *circle, cpBody *body, cpFloat radius, cpVect offset)
{
	circle->c = offset;
	circle->r = radius;
	
	cpShapeInit((cpShape *)circle, &cpCircleShapeClass, body, cpCircleShapeMassInfo(0.0f, radius, offset));
	
	return circle;
}

cpShape *
cpCircleShapeNew(cpBody *body, cpFloat radius, cpVect offset)
{
	return (cpShape *)cpCircleShapeInit(cpCircleShapeAlloc(), body, radius, offset);
}

cpVect
cpCircleShapeGetOffset(const cpShape *shape)
{
	cpAssertHard(shape->klass == &cpCircleShapeClass, "Shape is not a circle shape.");
	return ((cpCircleShape *)shape)->c;
}

cpFloat
cpCircleShapeGetRadius(const cpShape *shape)
{
	cpAssertHard(shape->klass == &cpCircleShapeClass, "Shape is not a circle shape.");
	return ((cpCircleShape *)shape)->r;
}


cpSegmentShape *
cpSegmentShapeAlloc(void)
{
	return (cpSegmentShape *)cpcalloc(1, sizeof(cpSegmentShape));
}

static cpBB
cpSegmentShapeCacheData(cpSegmentShape *seg, cpTransform transform)
{
	seg->ta = cpTransformPoint(transform, seg->a);
	seg->tb = cpTransformPoint(transform, seg->b);
	seg->tn = cpTransformVect(transform, seg->n);
	
	cpFloat l,r,b,t;
	
	if(seg->ta.x < seg->tb.x){
		l = seg->ta.x;
		r = seg->tb.x;
	} else {
		l = seg->tb.x;
		r = seg->ta.x;
	}
	
	if(seg->ta.y < seg->tb.y){
		b = seg->ta.y;
		t = seg->tb.y;
	} else {
		b = seg->tb.y;
		t = seg->ta.y;
	}
	
	cpFloat rad = seg->r;
	return cpBBNew(l - rad, b - rad, r + rad, t + rad);
}

static void
cpSegmentShapePointQuery(cpSegmentShape *seg, cpVect p, cpPointQueryInfo *info)
{
	cpVect closest = cpClosetPointOnSegment(p, seg->ta, seg->tb);
	
	cpVect delta = cpvsub(p, closest);
	cpFloat d = cpvlength(delta);
	cpFloat r = seg->r;
	cpVect g = cpvmult(delta, 1.0f/d);
	
	info->shape = (cpShape *)seg;
	info->point = (d ? cpvadd(closest, cpvmult(g, r)) : closest);
	info->distance = d - r;
	
	// Use the segment's normal if the distance is very small.
	info->gradient = (d > MAGIC_EPSILON ? g : seg->n);
}

static void
cpSegmentShapeSegmentQuery(cpSegmentShape *seg, cpVect a, cpVect b, cpFloat r2, cpSegmentQueryInfo *info)
{
	cpVect n = seg->tn;
	cpFloat d = cpvdot(cpvsub(seg->ta, a), n);
	cpFloat r = seg->r + r2;
	
	cpVect flipped_n = (d > 0.0f ? cpvneg(n) : n);
	cpVect seg_offset = cpvsub(cpvmult(flipped_n, r), a);
	
	// Make the endpoints relative to 'a' and move them by the thickness of the segment.
	cpVect seg_a = cpvadd(seg->ta, seg_offset);
	cpVect seg_b = cpvadd(seg->tb, seg_offset);
	cpVect delta = cpvsub(b, a);
	
	if(cpvcross(delta, seg_a)*cpvcross(delta, seg_b) <= 0.0f){
		cpFloat d_offset = d + (d > 0.0f ? -r : r);
		cpFloat ad = -d_offset;
		cpFloat bd = cpvdot(delta, n) - d_offset;
		
		if(ad*bd < 0.0f){
			cpFloat t = ad/(ad - bd);
			
			info->shape = (cpShape *)seg;
			info->point = cpvsub(cpvlerp(a, b, t), cpvmult(flipped_n, r2));
			info->normal = flipped_n;
			info->alpha = t;
		}
	} else if(r != 0.0f){
		cpSegmentQueryInfo info1 = {NULL, b, cpvzero, 1.0f};
		cpSegmentQueryInfo info2 = {NULL, b, cpvzero, 1.0f};
		CircleSegmentQuery((cpShape *)seg, seg->ta, seg->r, a, b, r2, &info1);
		CircleSegmentQuery((cpShape *)seg, seg->tb, seg->r, a, b, r2, &info2);
		
		if(info1.alpha < info2.alpha){
			(*info) = info1;
		} else {
			(*info) = info2;
		}
	}
}

static struct cpShapeMassInfo
cpSegmentShapeMassInfo(cpFloat mass, cpVect a, cpVect b, cpFloat r)
{
	struct cpShapeMassInfo info = {
		mass, cpMomentForBox(1.0f, cpvdist(a, b) + 2.0f*r, 2.0f*r), // TODO is an approximation.
		cpvlerp(a, b, 0.5f),
		cpAreaForSegment(a, b, r),
	};
	
	return info;
}

static const cpShapeClass cpSegmentShapeClass = {
	CP_SEGMENT_SHAPE,
	(cpShapeCacheDataImpl)cpSegmentShapeCacheData,
	NULL,
	(cpShapePointQueryImpl)cpSegmentShapePointQuery,
	(cpShapeSegmentQueryImpl)cpSegmentShapeSegmentQuery,
};

cpSegmentShape *
cpSegmentShapeInit(cpSegmentShape *seg, cpBody *body, cpVect a, cpVect b, cpFloat r)
{
	seg->a = a;
	seg->b = b;
	seg->n = cpvrperp(cpvnormalize(cpvsub(b, a)));
	
	seg->r = r;
	
	seg->a_tangent = cpvzero;
	seg->b_tangent = cpvzero;
	
	cpShapeInit((cpShape *)seg, &cpSegmentShapeClass, body, cpSegmentShapeMassInfo(0.0f, a, b, r));
	
	return seg;
}

cpShape*
cpSegmentShapeNew(cpBody *body, cpVect a, cpVect b, cpFloat r)
{
	return (cpShape *)cpSegmentShapeInit(cpSegmentShapeAlloc(), body, a, b, r);
}

cpVect
cpSegmentShapeGetA(const cpShape *shape)
{
	cpAssertHard(shape->klass == &cpSegmentShapeClass, "Shape is not a segment shape.");
	return ((cpSegmentShape *)shape)->a;
}

cpVect
cpSegmentShapeGetB(const cpShape *shape)
{
	cpAssertHard(shape->klass == &cpSegmentShapeClass, "Shape is not a segment shape.");
	return ((cpSegmentShape *)shape)->b;
}

cpVect
cpSegmentShapeGetNormal(const cpShape *shape)
{
	cpAssertHard(shape->klass == &cpSegmentShapeClass, "Shape is not a segment shape.");
	return ((cpSegmentShape *)shape)->n;
}

cpFloat
cpSegmentShapeGetRadius(const cpShape *shape)
{
	cpAssertHard(shape->klass == &cpSegmentShapeClass, "Shape is not a segment shape.");
	return ((cpSegmentShape *)shape)->r;
}

void
cpSegmentShapeSetNeighbors(cpShape *shape, cpVect prev, cpVect next)
{
	cpAssertHard(shape->klass == &cpSegmentShapeClass, "Shape is not a segment shape.");
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	
	seg->a_tangent = cpvsub(prev, seg->a);
	seg->b_tangent = cpvsub(next, seg->b);
}

// Unsafe API (chipmunk_unsafe.h)

// TODO setters should wake the shape up?

void
cpCircleShapeSetRadius(cpShape *shape, cpFloat radius)
{
	cpAssertHard(shape->klass == &cpCircleShapeClass, "Shape is not a circle shape.");
	cpCircleShape *circle = (cpCircleShape *)shape;
	
	circle->r = radius;
	
	cpFloat mass = shape->massInfo.m;
	shape->massInfo = cpCircleShapeMassInfo(mass, circle->r, circle->c);
	if(mass > 0.0f) cpBodyAccumulateMassFromShapes(shape->body);
}

void
cpCircleShapeSetOffset(cpShape *shape, cpVect offset)
{
	cpAssertHard(shape->klass == &cpCircleShapeClass, "Shape is not a circle shape.");
	cpCircleShape *circle = (cpCircleShape *)shape;
	
	circle->c = offset;

	cpFloat mass = shape->massInfo.m;
	shape->massInfo = cpCircleShapeMassInfo(shape->massInfo.m, circle->r, circle->c);
	if(mass > 0.0f) cpBodyAccumulateMassFromShapes(shape->body);
}

void
cpSegmentShapeSetEndpoints(cpShape *shape, cpVect a, cpVect b)
{
	cpAssertHard(shape->klass == &cpSegmentShapeClass, "Shape is not a segment shape.");
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	
	seg->a = a;
	seg->b = b;
	seg->n = cpvperp(cpvnormalize(cpvsub(b, a)));

	cpFloat mass = shape->massInfo.m;
	shape->massInfo = cpSegmentShapeMassInfo(shape->massInfo.m, seg->a, seg->b, seg->r);
	if(mass > 0.0f) cpBodyAccumulateMassFromShapes(shape->body);
}

void
cpSegmentShapeSetRadius(cpShape *shape, cpFloat radius)
{
	cpAssertHard(shape->klass == &cpSegmentShapeClass, "Shape is not a segment shape.");
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	
	seg->r = radius;

	cpFloat mass = shape->massInfo.m;
	shape->massInfo = cpSegmentShapeMassInfo(shape->massInfo.m, seg->a, seg->b, seg->r);
	if(mass > 0.0f) cpBodyAccumulateMassFromShapes(shape->body);
}
