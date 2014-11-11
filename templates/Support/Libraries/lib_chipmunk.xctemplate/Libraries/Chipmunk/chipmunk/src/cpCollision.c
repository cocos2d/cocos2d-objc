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

#include <stdio.h>
#include <string.h>

#include "chipmunk/chipmunk_private.h"

#if DEBUG && 0
#include "ChipmunkDemo.h"
#define DRAW_ALL 0
#define DRAW_GJK (0 || DRAW_ALL)
#define DRAW_EPA (0 || DRAW_ALL)
#define DRAW_CLOSEST (0 || DRAW_ALL)
#define DRAW_CLIP (0 || DRAW_ALL)

#define PRINT_LOG 0
#endif

#define ENABLE_CACHING 1

#define MAX_GJK_ITERATIONS 30
#define MAX_EPA_ITERATIONS 30
#define WARN_GJK_ITERATIONS 20
#define WARN_EPA_ITERATIONS 20

static inline void
cpCollisionInfoPushContact(struct cpCollisionInfo *info, cpVect p1, cpVect p2, cpHashValue hash)
{
	cpAssertSoft(info->count <= CP_MAX_CONTACTS_PER_ARBITER, "Internal error: Tried to push too many contacts.");
	
	struct cpContact *con = &info->arr[info->count];
	con->r1 = p1;
	con->r2 = p2;
	con->hash = hash;
	
	info->count++;
}

//MARK: Support Points and Edges:

// Support points are the maximal points on a shape's perimeter along a certain axis.
// The GJK and EPA algorithms use support points to iteratively sample the surface of the two shapes' minkowski difference.

static inline int
PolySupportPointIndex(const int count, const struct cpSplittingPlane *planes, const cpVect n)
{
	cpFloat max = -INFINITY;
	int index = 0;
	
	for(int i=0; i<count; i++){
		cpVect v = planes[i].v0;
		cpFloat d = cpvdot(v, n);
		if(d > max){
			max = d;
			index = i;
		}
	}
	
	return index;
}

struct SupportPoint {
	cpVect p;
	// Save an index of the point so it can be cheaply looked up as a starting point for the next frame.
	cpCollisionID index;
};

static inline struct SupportPoint
SupportPointNew(cpVect p, cpCollisionID index)
{
	struct SupportPoint point = {p, index};
	return point;
}

typedef struct SupportPoint (*SupportPointFunc)(const cpShape *shape, const cpVect n);

static inline struct SupportPoint
CircleSupportPoint(const cpCircleShape *circle, const cpVect n)
{
	return SupportPointNew(circle->tc, 0);
}

static inline struct SupportPoint
SegmentSupportPoint(const cpSegmentShape *seg, const cpVect n)
{
	if(cpvdot(seg->ta, n) > cpvdot(seg->tb, n)){
		return SupportPointNew(seg->ta, 0);
	} else {
		return SupportPointNew(seg->tb, 1);
	}
}

static inline struct SupportPoint
PolySupportPoint(const cpPolyShape *poly, const cpVect n)
{
	const struct cpSplittingPlane *planes = poly->planes;
	int i = PolySupportPointIndex(poly->count, planes, n);
	return SupportPointNew(planes[i].v0, i);
}

// A point on the surface of two shape's minkowski difference.
struct MinkowskiPoint {
	// Cache the two original support points.
	cpVect a, b;
	// b - a
	cpVect ab;
	// Concatenate the two support point indexes.
	cpCollisionID id;
};

static inline struct MinkowskiPoint
MinkowskiPointNew(const struct SupportPoint a, const struct SupportPoint b)
{
	struct MinkowskiPoint point = {a.p, b.p, cpvsub(b.p, a.p), (a.index & 0xFF)<<8 | (b.index & 0xFF)};
	return point;
}

struct SupportContext {
	const cpShape *shape1, *shape2;
	SupportPointFunc func1, func2;
};

// Calculate the maximal point on the minkowski difference of two shapes along a particular axis.
static inline struct MinkowskiPoint
Support(const struct SupportContext *ctx, const cpVect n)
{
	struct SupportPoint a = ctx->func1(ctx->shape1, cpvneg(n));
	struct SupportPoint b = ctx->func2(ctx->shape2, n);
	return MinkowskiPointNew(a, b);
}

struct EdgePoint {
	cpVect p;
	// Keep a hash value for Chipmunk's collision hashing mechanism.
	cpHashValue hash;
};

// Support edges are the edges of a polygon or segment shape that are in contact.
struct Edge {
	struct EdgePoint a, b;
	cpFloat r;
	cpVect n;
};

static struct Edge
SupportEdgeForPoly(const cpPolyShape *poly, const cpVect n)
{
	int count = poly->count;
	int i1 = PolySupportPointIndex(poly->count, poly->planes, n);
	
	// TODO: get rid of mod eventually, very expensive on ARM
	int i0 = (i1 - 1 + count)%count;
	int i2 = (i1 + 1)%count;
	
	const struct cpSplittingPlane *planes = poly->planes;
	cpHashValue hashid = poly->shape.hashid;
	if(cpvdot(n, planes[i1].n) > cpvdot(n, planes[i2].n)){
		struct Edge edge = {{planes[i0].v0, CP_HASH_PAIR(hashid, i0)}, {planes[i1].v0, CP_HASH_PAIR(hashid, i1)}, poly->r, planes[i1].n};
		return edge;
	} else {
		struct Edge edge = {{planes[i1].v0, CP_HASH_PAIR(hashid, i1)}, {planes[i2].v0, CP_HASH_PAIR(hashid, i2)}, poly->r, planes[i2].n};
		return edge;
	}
}

static struct Edge
SupportEdgeForSegment(const cpSegmentShape *seg, const cpVect n)
{
	cpHashValue hashid = seg->shape.hashid;
	if(cpvdot(seg->tn, n) > 0.0){
		struct Edge edge = {{seg->ta, CP_HASH_PAIR(hashid, 0)}, {seg->tb, CP_HASH_PAIR(hashid, 1)}, seg->r, seg->tn};
		return edge;
	} else {
		struct Edge edge = {{seg->tb, CP_HASH_PAIR(hashid, 1)}, {seg->ta, CP_HASH_PAIR(hashid, 0)}, seg->r, cpvneg(seg->tn)};
		return edge;
	}
}

// Find the closest p(t) to (0, 0) where p(t) = a*(1-t)/2 + b*(1+t)/2
// The range for t is [-1, 1] to avoid floating point issues if the parameters are swapped.
static inline cpFloat
ClosestT(const cpVect a, const cpVect b)
{
	cpVect delta = cpvsub(b, a);
	return -cpfclamp(cpvdot(delta, cpvadd(a, b))/cpvlengthsq(delta), -1.0f, 1.0f);
}

// Basically the same as cpvlerp(), except t = [-1, 1]
static inline cpVect
LerpT(const cpVect a, const cpVect b, const cpFloat t)
{
	cpFloat ht = 0.5f*t;
	return cpvadd(cpvmult(a, 0.5f - ht), cpvmult(b, 0.5f + ht));
}

// Closest points on the surface of two shapes.
struct ClosestPoints {
	// Surface points in absolute coordinates.
	cpVect a, b;
	// Minimum separating axis of the two shapes.
	cpVect n;
	// Signed distance between the points.
	cpFloat d;
	// Concatenation of the id's of the minkoski points.
	cpCollisionID id;
};

// Calculate the closest points on two shapes given the closest edge on their minkowski difference to (0, 0)
static inline struct ClosestPoints
ClosestPointsNew(const struct MinkowskiPoint v0, const struct MinkowskiPoint v1)
{
	// Find the closest p(t) on the minkowski difference to (0, 0)
	cpFloat t = ClosestT(v0.ab, v1.ab);
	cpVect p = LerpT(v0.ab, v1.ab, t);
	
	// Interpolate the original support points using the same 't' value as above.
	// This gives you the closest surface points in absolute coordinates. NEAT!
	cpVect pa = LerpT(v0.a, v1.a, t);
	cpVect pb = LerpT(v0.b, v1.b, t);
	cpCollisionID id = (v0.id & 0xFFFF)<<16 | (v1.id & 0xFFFF);
	
	// First try calculating the MSA from the minkowski difference edge.
	// This gives us a nice, accurate MSA when the surfaces are close together.
	cpVect delta = cpvsub(v1.ab, v0.ab);
	cpVect n = cpvnormalize(cpvrperp(delta));
	cpFloat d = cpvdot(n, p);
	
	if(d <= 0.0f || (-1.0f < t && t < 1.0f)){
		// If the shapes are overlapping, or we have a regular vertex/edge collision, we are done.
		struct ClosestPoints points = {pa, pb, n, d, id};
		return points;
	} else {
		// Vertex/vertex collisions need special treatment since the MSA won't be shared with an axis of the minkowski difference.
		cpFloat d = cpvlength(p);
		cpVect n = cpvmult(p, 1.0f/(d + CPFLOAT_MIN));
		
		struct ClosestPoints points = {pa, pb, n, d, id};
		return points;
	}
}

//MARK: EPA Functions

static inline cpFloat
ClosestDist(const cpVect v0,const cpVect v1)
{
	return cpvlengthsq(LerpT(v0, v1, ClosestT(v0, v1)));
}

static inline cpBool
CheckArea(cpVect v1, cpVect v2)
{
	return (v1.x*v2.y) > (v1.y*v2.x);
}

// Recursive implementation of the EPA loop.
// Each recursion adds a point to the convex hull until it's known that we have the closest point on the surface.
static struct ClosestPoints
EPARecurse(const struct SupportContext *ctx, const int count, const struct MinkowskiPoint *hull, const int iteration)
{
	int mini = 0;
	cpFloat minDist = INFINITY;
	
	// TODO: precalculate this when building the hull and save a step.
	// Find the closest segment hull[i] and hull[i + 1] to (0, 0)
	for(int j=0, i=count-1; j<count; i=j, j++){
		cpFloat d = ClosestDist(hull[i].ab, hull[j].ab);
		if(d < minDist){
			minDist = d;
			mini = i;
		}
	}
	
	struct MinkowskiPoint v0 = hull[mini];
	struct MinkowskiPoint v1 = hull[(mini + 1)%count];
	cpAssertSoft(!cpveql(v0.ab, v1.ab), "Internal Error: EPA vertexes are the same (%d and %d)", mini, (mini + 1)%count);
	
	// Check if there is a point on the minkowski difference beyond this edge.
	struct MinkowskiPoint p = Support(ctx, cpvperp(cpvsub(v1.ab, v0.ab)));
	
#if DRAW_EPA
	cpVect verts[count];
	for(int i=0; i<count; i++) verts[i] = hull[i].ab;
	
	ChipmunkDebugDrawPolygon(count, verts, 0.0, RGBAColor(1, 1, 0, 1), RGBAColor(1, 1, 0, 0.25));
	ChipmunkDebugDrawSegment(v0.ab, v1.ab, RGBAColor(1, 0, 0, 1));
	
	ChipmunkDebugDrawDot(5, p.ab, LAColor(1, 1));
#endif
	
	if(CheckArea(cpvsub(v1.ab, v0.ab), cpvadd(cpvsub(p.ab, v0.ab), cpvsub(p.ab, v1.ab))) && iteration < MAX_EPA_ITERATIONS){
		// Rebuild the convex hull by inserting p.
		struct MinkowskiPoint *hull2 = (struct MinkowskiPoint *)alloca((count + 1)*sizeof(struct MinkowskiPoint));
		int count2 = 1;
		hull2[0] = p;
		
		for(int i=0; i<count; i++){
			int index = (mini + 1 + i)%count;
			
			cpVect h0 = hull2[count2 - 1].ab;
			cpVect h1 = hull[index].ab;
			cpVect h2 = (i + 1 < count ? hull[(index + 1)%count] : p).ab;
			
			if(CheckArea(cpvsub(h2, h0), cpvadd(cpvsub(h1, h0), cpvsub(h1, h2)))){
				hull2[count2] = hull[index];
				count2++;
			}
		}
		
		return EPARecurse(ctx, count2, hull2, iteration + 1);
	} else {
		// Could not find a new point to insert, so we have found the closest edge of the minkowski difference.
		cpAssertWarn(iteration < WARN_EPA_ITERATIONS, "High EPA iterations: %d", iteration);
		return ClosestPointsNew(v0, v1);
	}
}

// Find the closest points on the surface of two overlapping shapes using the EPA algorithm.
// EPA is called from GJK when two shapes overlap.
// This is moderately expensive step! Avoid it by adding radii to your shapes so their inner polygons won't overlap.
static struct ClosestPoints
EPA(const struct SupportContext *ctx, const struct MinkowskiPoint v0, const struct MinkowskiPoint v1, const struct MinkowskiPoint v2)
{
	// TODO: allocate a NxM array here and do an in place convex hull reduction in EPARecurse
	struct MinkowskiPoint hull[3] = {v0, v1, v2};
	return EPARecurse(ctx, 3, hull, 1);
}

//MARK: GJK Functions.

// Recursive implementatino of the GJK loop.
static inline struct ClosestPoints
GJKRecurse(const struct SupportContext *ctx, const struct MinkowskiPoint v0, const struct MinkowskiPoint v1, const int iteration)
{
	if(iteration > MAX_GJK_ITERATIONS){
		cpAssertWarn(iteration < WARN_GJK_ITERATIONS, "High GJK iterations: %d", iteration);
		return ClosestPointsNew(v0, v1);
	}
	
	cpVect delta = cpvsub(v1.ab, v0.ab);
	if(CheckArea(delta, cpvadd(v0.ab, v1.ab))){
		// Origin is behind axis. Flip and try again.
		return GJKRecurse(ctx, v1, v0, iteration);
	} else {
		cpFloat t = ClosestT(v0.ab, v1.ab);
		cpVect n = (-1.0f < t && t < 1.0f ? cpvperp(delta) : cpvneg(LerpT(v0.ab, v1.ab, t)));
		struct MinkowskiPoint p = Support(ctx, n);
		
#if DRAW_GJK
		ChipmunkDebugDrawSegment(v0.ab, v1.ab, RGBAColor(1, 1, 1, 1));
		cpVect c = cpvlerp(v0.ab, v1.ab, 0.5);
		ChipmunkDebugDrawSegment(c, cpvadd(c, cpvmult(cpvnormalize(n), 5.0)), RGBAColor(1, 0, 0, 1));
		
		ChipmunkDebugDrawDot(5.0, p.ab, LAColor(1, 1));
#endif
		
		if(
			CheckArea(cpvsub(v1.ab, p.ab), cpvadd(v1.ab, p.ab)) &&
			CheckArea(cpvadd(v0.ab, p.ab), cpvsub(v0.ab, p.ab))
		){
			// The triangle v0, p, v1 contains the origin. Use EPA to find the MSA.
			cpAssertWarn(iteration < WARN_GJK_ITERATIONS, "High GJK->EPA iterations: %d", iteration);
			return EPA(ctx, v0, p, v1);
		} else {
			if(cpvdot(p.ab, n) <= cpfmax(cpvdot(v0.ab, n), cpvdot(v1.ab, n))){
				// The edge v0, v1 that we already have is the closest to (0, 0) since p was not closer.
				cpAssertWarn(iteration < WARN_GJK_ITERATIONS, "High GJK iterations: %d", iteration);
				return ClosestPointsNew(v0, v1);
			} else {
				// p was closer to the origin than our existing edge.
				// Need to figure out which existing point to drop.
				if(ClosestDist(v0.ab, p.ab) < ClosestDist(p.ab, v1.ab)){
					return GJKRecurse(ctx, v0, p, iteration + 1);
				} else {
					return GJKRecurse(ctx, p, v1, iteration + 1);
				}
			}
		}
	}
}

// Get a SupportPoint from a cached shape and index.
static struct SupportPoint
ShapePoint(const cpShape *shape, const int i)
{
	switch(shape->klass->type){
		case CP_CIRCLE_SHAPE: {
			return SupportPointNew(((cpCircleShape *)shape)->tc, 0);
		} case CP_SEGMENT_SHAPE: {
			cpSegmentShape *seg = (cpSegmentShape *)shape;
			return SupportPointNew(i == 0 ? seg->ta : seg->tb, i);
		} case CP_POLY_SHAPE: {
			cpPolyShape *poly = (cpPolyShape *)shape;
			// Poly shapes may change vertex count.
			int index = (i < poly->count ? i : 0);
			return SupportPointNew(poly->planes[index].v0, index);
		} default: {
			return SupportPointNew(cpvzero, 0);
		}
	}
}

// Find the closest points between two shapes using the GJK algorithm.
static struct ClosestPoints
GJK(const struct SupportContext *ctx, cpCollisionID *id)
{
#if DRAW_GJK || DRAW_EPA
	int count1 = 1;
	int count2 = 1;
	
	switch(ctx->shape1->klass->type){
		case CP_SEGMENT_SHAPE: count1 = 2; break;
		case CP_POLY_SHAPE: count1 = ((cpPolyShape *)ctx->shape1)->count; break;
		default: break;
	}
	
	switch(ctx->shape2->klass->type){
		case CP_SEGMENT_SHAPE: count1 = 2; break;
		case CP_POLY_SHAPE: count2 = ((cpPolyShape *)ctx->shape2)->count; break;
		default: break;
	}
	
	
	// draw the minkowski difference origin
	cpVect origin = cpvzero;
	ChipmunkDebugDrawDot(5.0, origin, RGBAColor(1,0,0,1));
	
	int mdiffCount = count1*count2;
	cpVect *mdiffVerts = alloca(mdiffCount*sizeof(cpVect));
	
	for(int i=0; i<count1; i++){
		for(int j=0; j<count2; j++){
			cpVect v = cpvsub(ShapePoint(ctx->shape2, j).p, ShapePoint(ctx->shape1, i).p);
			mdiffVerts[i*count2 + j] = v;
			ChipmunkDebugDrawDot(2.0, v, RGBAColor(1, 0, 0, 1));
		}
	}
	 
	cpVect *hullVerts = alloca(mdiffCount*sizeof(cpVect));
	int hullCount = cpConvexHull(mdiffCount, mdiffVerts, hullVerts, NULL, 0.0);
	
	ChipmunkDebugDrawPolygon(hullCount, hullVerts, 0.0, RGBAColor(1, 0, 0, 1), RGBAColor(1, 0, 0, 0.25));
#endif
	
	struct MinkowskiPoint v0, v1;
	if(*id && ENABLE_CACHING){
		// Use the minkowski points from the last frame as a starting point using the cached indexes.
		v0 = MinkowskiPointNew(ShapePoint(ctx->shape1, (*id>>24)&0xFF), ShapePoint(ctx->shape2, (*id>>16)&0xFF));
		v1 = MinkowskiPointNew(ShapePoint(ctx->shape1, (*id>> 8)&0xFF), ShapePoint(ctx->shape2, (*id    )&0xFF));
	} else {
		// No cached indexes, use the shapes' bounding box centers as a guess for a starting axis.
		cpVect axis = cpvperp(cpvsub(cpBBCenter(ctx->shape1->bb), cpBBCenter(ctx->shape2->bb)));
		v0 = Support(ctx, axis);
		v1 = Support(ctx, cpvneg(axis));
	}
	
	struct ClosestPoints points = GJKRecurse(ctx, v0, v1, 1);
	*id = points.id;
	return points;
}

//MARK: Contact Clipping

// Given two support edges, find contact point pairs on their surfaces.
static inline void
ContactPoints(const struct Edge e1, const struct Edge e2, const struct ClosestPoints points, struct cpCollisionInfo *info)
{
	cpFloat mindist = e1.r + e2.r;
	if(points.d <= mindist){
#ifdef DRAW_CLIP
	ChipmunkDebugDrawFatSegment(e1.a.p, e1.b.p, e1.r, RGBAColor(0, 1, 0, 1), LAColor(0, 0));
	ChipmunkDebugDrawFatSegment(e2.a.p, e2.b.p, e2.r, RGBAColor(1, 0, 0, 1), LAColor(0, 0));
#endif
		cpVect n = info->n = points.n;
		
		// Distances along the axis parallel to n
		cpFloat d_e1_a = cpvcross(e1.a.p, n);
		cpFloat d_e1_b = cpvcross(e1.b.p, n);
		cpFloat d_e2_a = cpvcross(e2.a.p, n);
		cpFloat d_e2_b = cpvcross(e2.b.p, n);
		
		cpFloat e1_denom = 1.0f/(d_e1_b - d_e1_a);
		cpFloat e2_denom = 1.0f/(d_e2_b - d_e2_a);
		
		// Project the endpoints of the two edges onto the opposing edge, clamping them as necessary.
		// Compare the projected points to the collision normal to see if the shapes overlap there.
		{
			cpVect p1 = cpvadd(cpvmult(n,  e1.r), cpvlerp(e1.a.p, e1.b.p, cpfclamp01((d_e2_b - d_e1_a)*e1_denom)));
			cpVect p2 = cpvadd(cpvmult(n, -e2.r), cpvlerp(e2.a.p, e2.b.p, cpfclamp01((d_e1_a - d_e2_a)*e2_denom)));
			cpFloat dist = cpvdot(cpvsub(p2, p1), n);
			if(dist <= 0.0f){
				cpHashValue hash_1a2b = CP_HASH_PAIR(e1.a.hash, e2.b.hash);
				cpCollisionInfoPushContact(info, p1, p2, hash_1a2b);
			}
		}{
			cpVect p1 = cpvadd(cpvmult(n,  e1.r), cpvlerp(e1.a.p, e1.b.p, cpfclamp01((d_e2_a - d_e1_a)*e1_denom)));
			cpVect p2 = cpvadd(cpvmult(n, -e2.r), cpvlerp(e2.a.p, e2.b.p, cpfclamp01((d_e1_b - d_e2_a)*e2_denom)));
			cpFloat dist = cpvdot(cpvsub(p2, p1), n);
			if(dist <= 0.0f){
				cpHashValue hash_1b2a = CP_HASH_PAIR(e1.b.hash, e2.a.hash);
				cpCollisionInfoPushContact(info, p1, p2, hash_1b2a);
			}
		}
	}
}

//MARK: Collision Functions

typedef void (*CollisionFunc)(const cpShape *a, const cpShape *b, struct cpCollisionInfo *info);

// Collide circle shapes.
static void
CircleToCircle(const cpCircleShape *c1, const cpCircleShape *c2, struct cpCollisionInfo *info)
{
	cpFloat mindist = c1->r + c2->r;
	cpVect delta = cpvsub(c2->tc, c1->tc);
	cpFloat distsq = cpvlengthsq(delta);
	
	if(distsq < mindist*mindist){
		cpFloat dist = cpfsqrt(distsq);
		cpVect n = info->n = (dist ? cpvmult(delta, 1.0f/dist) : cpv(1.0f, 0.0f));
		cpCollisionInfoPushContact(info, cpvadd(c1->tc, cpvmult(n, c1->r)), cpvadd(c2->tc, cpvmult(n, -c2->r)), 0);
	}
}

static void
CircleToSegment(const cpCircleShape *circle, const cpSegmentShape *segment, struct cpCollisionInfo *info)
{
	cpVect seg_a = segment->ta;
	cpVect seg_b = segment->tb;
	cpVect center = circle->tc;
	
	// Find the closest point on the segment to the circle.
	cpVect seg_delta = cpvsub(seg_b, seg_a);
	cpFloat closest_t = cpfclamp01(cpvdot(seg_delta, cpvsub(center, seg_a))/cpvlengthsq(seg_delta));
	cpVect closest = cpvadd(seg_a, cpvmult(seg_delta, closest_t));
	
	// Compare the radii of the two shapes to see if they are colliding.
	cpFloat mindist = circle->r + segment->r;
	cpVect delta = cpvsub(closest, center);
	cpFloat distsq = cpvlengthsq(delta);
	if(distsq < mindist*mindist){
		cpFloat dist = cpfsqrt(distsq);
		// Handle coincident shapes as gracefully as possible.
		cpVect n = info->n = (dist ? cpvmult(delta, 1.0f/dist) : segment->tn);
		
		// Reject endcap collisions if tangents are provided.
		cpVect rot = cpBodyGetRotation(segment->shape.body);
		if(
			(closest_t != 0.0f || cpvdot(n, cpvrotate(segment->a_tangent, rot)) >= 0.0) &&
			(closest_t != 1.0f || cpvdot(n, cpvrotate(segment->b_tangent, rot)) >= 0.0)
		){
			cpCollisionInfoPushContact(info, cpvadd(center, cpvmult(n, circle->r)), cpvadd(closest, cpvmult(n, -segment->r)), 0);
		}
	}
}

static void
SegmentToSegment(const cpSegmentShape *seg1, const cpSegmentShape *seg2, struct cpCollisionInfo *info)
{
	struct SupportContext context = {(cpShape *)seg1, (cpShape *)seg2, (SupportPointFunc)SegmentSupportPoint, (SupportPointFunc)SegmentSupportPoint};
	struct ClosestPoints points = GJK(&context, &info->id);
	
#if DRAW_CLOSEST
#if PRINT_LOG
//	ChipmunkDemoPrintString("Distance: %.2f\n", points.d);
#endif
	
	ChipmunkDebugDrawDot(6.0, points.a, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawDot(6.0, points.b, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawSegment(points.a, points.b, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawSegment(points.a, cpvadd(points.a, cpvmult(points.n, 10.0)), RGBAColor(1, 0, 0, 1));
#endif
	
	cpVect n = points.n;
	cpVect rot1 = cpBodyGetRotation(seg1->shape.body);
	cpVect rot2 = cpBodyGetRotation(seg2->shape.body);
	
	// If the closest points are nearer than the sum of the radii...
	if(
		points.d <= (seg1->r + seg2->r) &&
		(
			// Reject endcap collisions if tangents are provided.
			(!cpveql(points.a, seg1->ta) || cpvdot(n, cpvrotate(seg1->a_tangent, rot1)) <= 0.0) &&
			(!cpveql(points.a, seg1->tb) || cpvdot(n, cpvrotate(seg1->b_tangent, rot1)) <= 0.0) &&
			(!cpveql(points.b, seg2->ta) || cpvdot(n, cpvrotate(seg2->a_tangent, rot2)) >= 0.0) &&
			(!cpveql(points.b, seg2->tb) || cpvdot(n, cpvrotate(seg2->b_tangent, rot2)) >= 0.0)
		)
	){
		ContactPoints(SupportEdgeForSegment(seg1, n), SupportEdgeForSegment(seg2, cpvneg(n)), points, info);
	}
}

static void
PolyToPoly(const cpPolyShape *poly1, const cpPolyShape *poly2, struct cpCollisionInfo *info)
{
	struct SupportContext context = {(cpShape *)poly1, (cpShape *)poly2, (SupportPointFunc)PolySupportPoint, (SupportPointFunc)PolySupportPoint};
	struct ClosestPoints points = GJK(&context, &info->id);
	
#if DRAW_CLOSEST
#if PRINT_LOG
//	ChipmunkDemoPrintString("Distance: %.2f\n", points.d);
#endif
	
	ChipmunkDebugDrawDot(3.0, points.a, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawDot(3.0, points.b, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawSegment(points.a, points.b, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawSegment(points.a, cpvadd(points.a, cpvmult(points.n, 10.0)), RGBAColor(1, 0, 0, 1));
#endif
	
	// If the closest points are nearer than the sum of the radii...
	if(points.d - poly1->r - poly2->r <= 0.0){
		ContactPoints(SupportEdgeForPoly(poly1, points.n), SupportEdgeForPoly(poly2, cpvneg(points.n)), points, info);
	}
}

static void
SegmentToPoly(const cpSegmentShape *seg, const cpPolyShape *poly, struct cpCollisionInfo *info)
{
	struct SupportContext context = {(cpShape *)seg, (cpShape *)poly, (SupportPointFunc)SegmentSupportPoint, (SupportPointFunc)PolySupportPoint};
	struct ClosestPoints points = GJK(&context, &info->id);
	
#if DRAW_CLOSEST
#if PRINT_LOG
//	ChipmunkDemoPrintString("Distance: %.2f\n", points.d);
#endif
	
	ChipmunkDebugDrawDot(3.0, points.a, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawDot(3.0, points.b, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawSegment(points.a, points.b, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawSegment(points.a, cpvadd(points.a, cpvmult(points.n, 10.0)), RGBAColor(1, 0, 0, 1));
#endif
	
	cpVect n = points.n;
	cpVect rot = cpBodyGetRotation(seg->shape.body);
	
	if(
		// If the closest points are nearer than the sum of the radii...
		points.d - seg->r - poly->r <= 0.0 &&
		(
			// Reject endcap collisions if tangents are provided.
			(!cpveql(points.a, seg->ta) || cpvdot(n, cpvrotate(seg->a_tangent, rot)) <= 0.0) &&
			(!cpveql(points.a, seg->tb) || cpvdot(n, cpvrotate(seg->b_tangent, rot)) <= 0.0)
		)
	){
		ContactPoints(SupportEdgeForSegment(seg, n), SupportEdgeForPoly(poly, cpvneg(n)), points, info);
	}
}

static void
CircleToPoly(const cpCircleShape *circle, const cpPolyShape *poly, struct cpCollisionInfo *info)
{
	struct SupportContext context = {(cpShape *)circle, (cpShape *)poly, (SupportPointFunc)CircleSupportPoint, (SupportPointFunc)PolySupportPoint};
	struct ClosestPoints points = GJK(&context, &info->id);
	
#if DRAW_CLOSEST
	ChipmunkDebugDrawDot(3.0, points.a, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawDot(3.0, points.b, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawSegment(points.a, points.b, RGBAColor(1, 1, 1, 1));
	ChipmunkDebugDrawSegment(points.a, cpvadd(points.a, cpvmult(points.n, 10.0)), RGBAColor(1, 0, 0, 1));
#endif
	
	// If the closest points are nearer than the sum of the radii...
	if(points.d <= circle->r + poly->r){
		cpVect n = info->n = points.n;
		cpCollisionInfoPushContact(info, cpvadd(points.a, cpvmult(n, circle->r)), cpvadd(points.b, cpvmult(n, poly->r)), 0);
	}
}

static void
CollisionError(const cpShape *circle, const cpShape *poly, struct cpCollisionInfo *info)
{
	cpAssertHard(cpFalse, "Internal Error: Shape types are not sorted.");
}


static const CollisionFunc BuiltinCollisionFuncs[9] = {
	(CollisionFunc)CircleToCircle,
	CollisionError,
	CollisionError,
	(CollisionFunc)CircleToSegment,
	(CollisionFunc)SegmentToSegment,
	CollisionError,
	(CollisionFunc)CircleToPoly,
	(CollisionFunc)SegmentToPoly,
	(CollisionFunc)PolyToPoly,
};
static const CollisionFunc *CollisionFuncs = BuiltinCollisionFuncs;

struct cpCollisionInfo
cpCollide(const cpShape *a, const cpShape *b, cpCollisionID id, struct cpContact *contacts)
{
	struct cpCollisionInfo info = {a, b, id, cpvzero, 0, contacts};
	
	// Make sure the shape types are in order.
	if(a->klass->type > b->klass->type){
		info.a = b;
		info.b = a;
	}
	
	CollisionFuncs[info.a->klass->type + info.b->klass->type*CP_NUM_SHAPES](info.a, info.b, &info);
	
//	if(0){
//		for(int i=0; i<info.count; i++){
//			cpVect r1 = info.arr[i].r1;
//			cpVect r2 = info.arr[i].r2;
//			cpVect mid = cpvlerp(r1, r2, 0.5f);
//			
//			ChipmunkDebugDrawSegment(r1, mid, RGBAColor(1, 0, 0, 1));
//			ChipmunkDebugDrawSegment(r2, mid, RGBAColor(0, 0, 1, 1));
//		}
//	}
	
	return info;
}
