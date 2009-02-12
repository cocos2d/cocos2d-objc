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

// TODO clean this up

extern cpSpace *space;
extern cpBody *staticBody;

cpJoint *joint;
cpBody *chassis, *wheel1, *wheel2;

void demo7_update(int ticks)
{
	int steps = 3;
	cpFloat dt = 1.0f/60.0f/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpBodyResetForces(chassis);
		cpBodyResetForces(wheel1);
		cpBodyResetForces(wheel2);
		cpDampedSpring(chassis, wheel1, cpv(40, 15), cpvzero, 50.0f, 150.0f, 10.0f, dt);
		cpDampedSpring(chassis, wheel2, cpv(-40, 15), cpvzero, 50.0f, 150.0f, 10.0f, dt);
		
		cpSpaceStep(space, dt);
	}
}

static cpBody *
make_box(cpFloat x, cpFloat y)
{
	int num = 4;
	cpVect verts[] = {
		cpv(-15,-7),
		cpv(-15, 7),
		cpv( 15, 7),
		cpv( 15,-7),
	};
	
	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpv(0,0)));
	//	cpBody *body1 = cpBodyNew(1.0/0.0, 1.0/0.0);
	body->p = cpv(x, y);
	cpSpaceAddBody(space, body);
	cpShape *shape = cpPolyShapeNew(body, num, verts, cpv(0,0));
	shape->e = 0.0f; shape->u = 1.0f;
	cpSpaceAddShape(space, shape);
	
	return body;
}

void demo7_init(void)
{
	staticBody = cpBodyNew(INFINITY, INFINITY);
	
	cpResetShapeIdCounter();
	space = cpSpaceNew();
	space->iterations = 10;
	cpSpaceResizeActiveHash(space, 50.0f, 999);
	cpSpaceResizeStaticHash(space, 50.0f, 999);
	space->gravity = cpv(0, -300);

	cpShape *shape;
	
	shape = cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(-320,240), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(320,-240), cpv(320,240), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(320,-240), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(-320,70), cpv(0,-240), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(0,-240), cpv(320,-200), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	shape = cpSegmentShapeNew(staticBody, cpv(200,-240), cpv(320,-100), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	//	shape = cpShapeNew(CP_SEGMENT_SHAPE, cpSegmentNew(cpv(-320,240), cpv(320,240)), space->staticBody);
//	shape->e = 1.0; shape->u = 1.0;
//	cpSpaceAddStaticShape(space, shape);
	
	cpBody *body1, *body2, *body3, *body4, *body5, *body6, *body7;
		
	body1 = make_box(-100, 100);
	body2 = make_box(body1->p.x + 40, 100);
	body3 = make_box(body2->p.x + 40, 100);
	body4 = make_box(body3->p.x + 40, 100);
	body5 = make_box(body4->p.x + 40, 100);
	body6 = make_box(body5->p.x + 40, 100);
	body7 = make_box(body6->p.x + 40, 100);
	
	joint = cpPivotJointNew(staticBody, body1, cpv(body1->p.x - 20, 100));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPivotJointNew(body1, body2, cpv(body2->p.x - 20, 100));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPivotJointNew(body2, body3, cpv(body3->p.x - 20, 100));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPivotJointNew(body3, body4, cpv(body4->p.x - 20, 100));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPivotJointNew(body4, body5, cpv(body5->p.x - 20, 100));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPivotJointNew(body5, body6, cpv(body6->p.x - 20, 100));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPivotJointNew(body6, body7, cpv(body7->p.x - 20, 100));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPivotJointNew(body7, staticBody, cpv(body7->p.x + 20, 100));
	cpSpaceAddJoint(space, joint);
	
	
	body1 = make_box(-100, 50);
	body2 = make_box(body1->p.x + 40, 50);
	body3 = make_box(body2->p.x + 40, 50);
	body4 = make_box(body3->p.x + 40, 50);
	body5 = make_box(body4->p.x + 40, 50);
	body6 = make_box(body5->p.x + 40, 50);
	body7 = make_box(body6->p.x + 40, 50);
	
	cpFloat max = 25.0f;
	cpFloat min = 10.0f;
	
	joint = cpSlideJointNew(staticBody, body1, cpv(body1->p.x - 15 - 10, 50), cpv(-15, 0), min, max);
	cpSpaceAddJoint(space, joint);
	
	joint = cpSlideJointNew(body1, body2, cpv(15, 0), cpv(-15, 0), min, max);
	cpSpaceAddJoint(space, joint);
	
	joint = cpSlideJointNew(body2, body3, cpv(15, 0), cpv(-15, 0), min, max);
	cpSpaceAddJoint(space, joint);
	
	joint = cpSlideJointNew(body3, body4, cpv(15, 0), cpv(-15, 0), min, max);
	cpSpaceAddJoint(space, joint);
	
	joint = cpSlideJointNew(body4, body5, cpv(15, 0), cpv(-15, 0), min, max);
	cpSpaceAddJoint(space, joint);
	
	joint = cpSlideJointNew(body5, body6, cpv(15, 0), cpv(-15, 0), min, max);
	cpSpaceAddJoint(space, joint);
	
	joint = cpSlideJointNew(body6, body7, cpv(15, 0), cpv(-15, 0), min, max);
	cpSpaceAddJoint(space, joint);
	
	joint = cpSlideJointNew(body7, staticBody, cpv(15, 0), cpv(body7->p.x + 15 + 10, 50), min, max);
	cpSpaceAddJoint(space, joint);
	
	body1 = make_box(-100, 150);
	body2 = make_box(body1->p.x + 40, 150);
	body3 = make_box(body2->p.x + 40, 150);
	body4 = make_box(body3->p.x + 40, 150);
	body5 = make_box(body4->p.x + 40, 150);
	body6 = make_box(body5->p.x + 40, 150);
	body7 = make_box(body6->p.x + 40, 150);
	
	joint = cpPinJointNew(staticBody, body1, cpv(body1->p.x - 15 - 10, 150), cpv(-15, 0));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPinJointNew(body1, body2, cpv(15, 0), cpv(-15, 0));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPinJointNew(body2, body3, cpv(15, 0), cpv(-15, 0));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPinJointNew(body3, body4, cpv(15, 0), cpv(-15, 0));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPinJointNew(body4, body5, cpv(15, 0), cpv(-15, 0));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPinJointNew(body5, body6, cpv(15, 0), cpv(-15, 0));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPinJointNew(body6, body7, cpv(15, 0), cpv(-15, 0));
	cpSpaceAddJoint(space, joint);
	
	joint = cpPinJointNew(body7, staticBody, cpv(15, 0), cpv(body7->p.x + 15 + 10, 150));
	cpSpaceAddJoint(space, joint);
	
	body1 = make_box(190, 200);
	joint = cpGrooveJointNew(staticBody, body1, cpv(0, 195), cpv(250, 200), cpv(-15, 0));
	cpSpaceAddJoint(space, joint);
	
	int num = 4;
	cpVect verts[] = {
		cpv(-20,-15),
		cpv(-20, 15),
		cpv( 20, 15),
		cpv( 20,-15),
	};
	
	chassis = cpBodyNew(10.0f, cpMomentForPoly(10.0f, num, verts, cpv(0,0)));
	chassis->p = cpv(-200, 100);
//	body->v = cpv(200, 0);
	cpSpaceAddBody(space, chassis);
	shape = cpPolyShapeNew(chassis, num, verts, cpv(0,0));
	shape->e = 0.0f; shape->u = 1.0f;
	cpSpaceAddShape(space, shape);
	
	cpFloat radius = 15;
	cpFloat wheel_mass = 0.3f;
	cpVect offset = cpv(radius + 30, -25);
	wheel1 = cpBodyNew(wheel_mass, cpMomentForCircle(wheel_mass, 0.0f, radius, cpvzero));
	wheel1->p = cpvadd(chassis->p, offset);
	wheel1->v = chassis->v;
	cpSpaceAddBody(space, wheel1);
	shape = cpCircleShapeNew(wheel1, radius, cpvzero);
	shape->e = 0.0f; shape->u = 2.5f;
	cpSpaceAddShape(space, shape);
	
	joint = cpPinJointNew(chassis, wheel1, cpvzero, cpvzero);
	cpSpaceAddJoint(space, joint);
	
	
	wheel2 = cpBodyNew(wheel_mass, cpMomentForCircle(wheel_mass, 0.0f, radius, cpvzero));
	wheel2->p = cpvadd(chassis->p, cpv(-offset.x, offset.y));
	wheel2->v = chassis->v;
	cpSpaceAddBody(space, wheel2);
	shape = cpCircleShapeNew(wheel2, radius, cpvzero);
	shape->e = 0.0f; shape->u = 2.5f;
	cpSpaceAddShape(space, shape);
	
	joint = cpPinJointNew(chassis, wheel2, cpvzero, cpvzero);
	cpSpaceAddJoint(space, joint);
}
