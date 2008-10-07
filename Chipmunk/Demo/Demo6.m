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

// TODO clean this up.

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "chipmunk.h"

extern cpSpace *space;
extern cpBody *staticBody;

#define WIDTH 200
#define HEIGHT 40


// Apply an approximate bouyancy and drag force to an object.
static void
apply_buoyancy(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	int numx = 20;
	int numy = 4;
	
	float stepx = (float)WIDTH/(float)numx;
	float stepy = (float)HEIGHT/(float)numy;
	
	cpBodyResetForces(body);
//	glBegin(GL_POINTS);
	for(int x=0; x<numx; x++){
		for(int y=0; y<numy; y++){
			cpVect p_sample = cpv((x + 0.5)*stepx - WIDTH/2, (y + 0.5)*stepy - HEIGHT/2);
			cpVect p = cpBodyLocal2World(body, p_sample);
			cpVect r = cpvsub(p, body->p);
			
			if(p.y < 0){
				cpVect v = cpvadd(body->v, cpvmult(cpvperp(r), body->w));
				cpVect f_damp = cpvmult(v, -0.0003*cpvlength(v));
				cpVect f = cpvadd(cpv(0, 2.0), f_damp);
				cpBodyApplyForce(body, f, r);

//				glVertex2f(p.x, p.y);
			}
		}
	}
//	glEnd();

	cpBodyUpdateVelocity(body, gravity, damping, dt);
}

void demo6_update(int ticks)
{
	int steps = 1;
	cpFloat dt = 1.0/60.0/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
}

static void
make_box(cpVect p, cpVect v, cpFloat a, cpFloat w)
{
	cpVect verts[] = {
		cpv(-WIDTH/2.0,-HEIGHT/2.0),
		cpv(-WIDTH/2.0, HEIGHT/2.0),
		cpv( WIDTH/2.0, HEIGHT/2.0),
		cpv( WIDTH/2.0,-HEIGHT/2.0),
	};

	cpBody *body = cpBodyNew(1.0, cpMomentForPoly(1.0, 4, verts, cpvzero));
	body->p = p;
	body->v = v;
	cpBodySetAngle(body, a);
	body->w = w;
	body->velocity_func = apply_buoyancy;
	cpSpaceAddBody(space, body);
	
	cpShape *shape = cpPolyShapeNew(body, 4, verts, cpvzero);
	shape->e = 0.0; shape->u = 0.7;
	cpSpaceAddShape(space, shape);
}

void demo6_init(void)
{
	staticBody = cpBodyNew(INFINITY, INFINITY);
	
	cpResetShapeIdCounter();
	space = cpSpaceNew();
	space->iterations = 5;
	space->gravity = cpv(0, -100);
	
	cpSpaceResizeStaticHash(space, 40.0, 999);
	cpSpaceResizeActiveHash(space, 30.0, 2999);
	
	cpShape *shape;
	
	// Screen border
	shape = cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(-320,240), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);

	shape = cpSegmentShapeNew(staticBody, cpv(320,-240), cpv(320,240), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);

	shape = cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(320,-240), 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
	
	// Reference line
	// Does not collide with other objects, we just want to draw it.
	shape = cpSegmentShapeNew(staticBody, cpv(-320,0), cpv(320,0), 0.0f);
	shape->collision_type = 1;
	cpSpaceAddStaticShape(space, shape);
	// Add a collision pair function to filter collisions
	cpSpaceAddCollisionPairFunc(space, 0, 1, NULL, NULL);
	
	// Create boxes
	make_box(cpv(-150, 150), cpv(200, -100), M_PI/2.0, 0.0);
	make_box(cpv(150, 150), cpv(0, -300), M_PI/4.0, 0.0);
	make_box(cpv(0, 150), cpv(0, 200), 0.0, 0.0);
	make_box(cpv(0, 250), cpv(50, 100), 0.0, 3.0);
}
