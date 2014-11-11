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

#ifndef CP_SPACE_DISABLE_DEBUG_API

static void
cpSpaceDebugDrawShape(cpShape *shape, cpSpaceDebugDrawOptions *options)
{
	cpBody *body = shape->body;
	cpDataPointer *data = options->data;
	
	cpSpaceDebugColor outline_color = options->shapeOutlineColor;
	cpSpaceDebugColor fill_color = options->colorForShape(shape, data);
	
	switch(shape->klass->type){
		case CP_CIRCLE_SHAPE: {
			cpCircleShape *circle = (cpCircleShape *)shape;
			options->drawCircle(circle->tc, body->a, circle->r, outline_color, fill_color, data);
			break;
		}
		case CP_SEGMENT_SHAPE: {
			cpSegmentShape *seg = (cpSegmentShape *)shape;
			options->drawFatSegment(seg->ta, seg->tb, seg->r, outline_color, fill_color, data);
			break;
		}
		case CP_POLY_SHAPE: {
			cpPolyShape *poly = (cpPolyShape *)shape;
			
			int count = poly->count;
			struct cpSplittingPlane *planes = poly->planes;
			cpVect *verts = (cpVect *)alloca(count*sizeof(cpVect));
			
			for(int i=0; i<count; i++) verts[i] = planes[i].v0;
			options->drawPolygon(count, verts, poly->r, outline_color, fill_color, data);
			break;
		}
		default: break;
	}
}

static const cpVect spring_verts[] = {
	{0.00f, 0.0f},
	{0.20f, 0.0f},
	{0.25f, 3.0f},
	{0.30f,-6.0f},
	{0.35f, 6.0f},
	{0.40f,-6.0f},
	{0.45f, 6.0f},
	{0.50f,-6.0f},
	{0.55f, 6.0f},
	{0.60f,-6.0f},
	{0.65f, 6.0f},
	{0.70f,-3.0f},
	{0.75f, 6.0f},
	{0.80f, 0.0f},
	{1.00f, 0.0f},
};
static const int spring_count = sizeof(spring_verts)/sizeof(cpVect);

static void
cpSpaceDebugDrawConstraint(cpConstraint *constraint, cpSpaceDebugDrawOptions *options)
{
	cpDataPointer *data = options->data;
	cpSpaceDebugColor color = options->constraintColor;
	
	cpBody *body_a = constraint->a;
	cpBody *body_b = constraint->b;

	if(cpConstraintIsPinJoint(constraint)){
		cpPinJoint *joint = (cpPinJoint *)constraint;
		
		cpVect a = cpTransformPoint(body_a->transform, joint->anchorA);
		cpVect b = cpTransformPoint(body_b->transform, joint->anchorB);
		
		options->drawDot(5, a, color, data);
		options->drawDot(5, b, color, data);
		options->drawSegment(a, b, color, data);
	} else if(cpConstraintIsSlideJoint(constraint)){
		cpSlideJoint *joint = (cpSlideJoint *)constraint;
	
		cpVect a = cpTransformPoint(body_a->transform, joint->anchorA);
		cpVect b = cpTransformPoint(body_b->transform, joint->anchorB);
		
		options->drawDot(5, a, color, data);
		options->drawDot(5, b, color, data);
		options->drawSegment(a, b, color, data);
	} else if(cpConstraintIsPivotJoint(constraint)){
		cpPivotJoint *joint = (cpPivotJoint *)constraint;
	
		cpVect a = cpTransformPoint(body_a->transform, joint->anchorA);
		cpVect b = cpTransformPoint(body_b->transform, joint->anchorB);

		options->drawDot(5, a, color, data);
		options->drawDot(5, b, color, data);
	} else if(cpConstraintIsGrooveJoint(constraint)){
		cpGrooveJoint *joint = (cpGrooveJoint *)constraint;
	
		cpVect a = cpTransformPoint(body_a->transform, joint->grv_a);
		cpVect b = cpTransformPoint(body_a->transform, joint->grv_b);
		cpVect c = cpTransformPoint(body_b->transform, joint->anchorB);
		
		options->drawDot(5, c, color, data);
		options->drawSegment(a, b, color, data);
	} else if(cpConstraintIsDampedSpring(constraint)){
		cpDampedSpring *spring = (cpDampedSpring *)constraint;
		cpDataPointer *data = options->data;
		cpSpaceDebugColor color = options->constraintColor;
		
		cpVect a = cpTransformPoint(body_a->transform, spring->anchorA);
		cpVect b = cpTransformPoint(body_b->transform, spring->anchorB);
		
		options->drawDot(5, a, color, data);
		options->drawDot(5, b, color, data);

		cpVect delta = cpvsub(b, a);
		cpFloat cos = delta.x;
		cpFloat sin = delta.y;
		cpFloat s = 1.0f/cpvlength(delta);
		
		cpVect r1 = cpv(cos, -sin*s);
		cpVect r2 = cpv(sin,  cos*s);
		
		cpVect *verts = (cpVect *)alloca(spring_count*sizeof(cpVect));
		for(int i=0; i<spring_count; i++){
			cpVect v = spring_verts[i];
			verts[i] = cpv(cpvdot(v, r1) + a.x, cpvdot(v, r2) + a.y);
		}
		
		for(int i=0; i<spring_count-1; i++){
			options->drawSegment(verts[i], verts[i + 1], color, data);
		}
	}
}

void
cpSpaceDebugDraw(cpSpace *space, cpSpaceDebugDrawOptions *options)
{
	if(options->flags & CP_SPACE_DEBUG_DRAW_SHAPES){
		cpSpaceEachShape(space, (cpSpaceShapeIteratorFunc)cpSpaceDebugDrawShape, options);
	}
	
	if(options->flags & CP_SPACE_DEBUG_DRAW_CONSTRAINTS){
		cpSpaceEachConstraint(space, (cpSpaceConstraintIteratorFunc)cpSpaceDebugDrawConstraint, options);
	}
	
	if(options->flags & CP_SPACE_DEBUG_DRAW_COLLISION_POINTS){
		cpArray *arbiters = space->arbiters;
		cpSpaceDebugColor color = options->collisionPointColor;
		cpSpaceDebugDrawSegmentImpl draw_seg = options->drawSegment;
		cpDataPointer *data = options->data;
		
		for(int i=0; i<arbiters->num; i++){
			cpArbiter *arb = (cpArbiter*)arbiters->arr[i];
			cpVect n = arb->n;
			
			for(int j=0; j<arb->count; j++){
				cpVect p1 = cpvadd(arb->body_a->p, arb->contacts[j].r1);
				cpVect p2 = cpvadd(arb->body_b->p, arb->contacts[j].r2);
				
				cpFloat d = 2.0f;
				cpVect a = cpvadd(p1, cpvmult(n, -d));
				cpVect b = cpvadd(p2, cpvmult(n,  d));
				draw_seg(a, b, color, data);
			}
		}
	}
}

#endif
