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

extern cpSpace *space;
extern cpBody *staticBody;

void demo1_update(int ticks)
{
	int steps = 2;
	cpFloat dt = 1.0f/60.0f/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
}

int some_value = 42;

static int
collFunc(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data)
{
//	int *some_ptr = (int *)data;

// Do various things with the contact information. 
// Make particle effects, estimate the impact damage from the relative velocities, etc.
//	for(int i=0; i<numContacts; i++)
//		printf("Collision at %s. (%d - %d) %d\n", cpvstr(contacts[i].p), a->collision_type, b->collision_type, *some_ptr);
	
	// Returning 0 will cause the collision to be discarded. This allows you to do conditional collisions.
	return 1;
}

void demo1_init(void)
{
	// Initialize a static body with infinite mass and moment of inertia
	// to attach the static geometry to.
	staticBody = cpBodyNew(INFINITY, INFINITY);
	
	// Optional. Read the docs to see what this really does.
	cpResetShapeIdCounter();
	
	// Create a space and adjust some of it's parameters.
	space = cpSpaceNew();
	cpSpaceResizeStaticHash(space, 20.0f, 999);
	space->gravity = cpv(0, -100);
	
	cpBody *body;
	cpShape *shape;
	
	// Vertexes we'll use to create a box.
	// Note that the vertexes are in counterclockwise order.
	int num = 4;
	cpVect verts[] = {
		cpv(-15,-15),
		cpv(-15, 15),
		cpv( 15, 15),
		cpv( 15,-15),
	};
	
	// Create some segments around the edges of the screen.
	shape = cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(-320,240), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);

	shape = cpSegmentShapeNew(staticBody, cpv(320,-240), cpv(320,240), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);

	shape = cpSegmentShapeNew(staticBody,cpv(-320,-240), cpv(320,-240), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);

	// Create the stair steps.
	for(int i=0; i<50; i++){
		int j = i + 1;
		cpVect a = cpv(i*10 - 320, i*-10 + 240);
		cpVect b = cpv(j*10 - 320, i*-10 + 240);
		cpVect c = cpv(j*10 - 320, j*-10 + 240);
		
		shape = cpSegmentShapeNew(staticBody, a, b, 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		shape = cpSegmentShapeNew(staticBody, b, c, 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
	}
	
	// Create a box and initialize some of its parameters.
	body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpvzero));
	body->p = cpv(-280, 240);
	cpSpaceAddBody(space, body);
	shape = cpPolyShapeNew(body, num, verts, cpvzero);
	shape->e = 0.0f; shape->u = 1.5f;
	shape->collision_type = 1;
	cpSpaceAddShape(space, shape);
	
	// Add a collision callback between objects of the default type and the box.
	cpSpaceAddCollisionPairFunc(space, 1, 0, &collFunc, &some_value);
}
