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

#define SLEEP_TICKS 16

extern cpSpace *space;
extern cpBody *staticBody;

void demo5_update(int ticks)
{
	int steps = 2;
	cpFloat dt = 1.0f/60.0f/(cpFloat)steps;
	
	for(int i=0; i<steps; i++)
		cpSpaceStep(space, dt);
}

void demo5_init(void)
{
	staticBody = cpBodyNew(INFINITY, INFINITY);
	
	cpResetShapeIdCounter();
	
	space = cpSpaceNew();
	space->iterations = 20;
	cpSpaceResizeActiveHash(space, 40.0f, 2999);
	cpSpaceResizeStaticHash(space, 40.0f, 999);
	space->gravity = cpv(0, -300);
	
	cpBody *body;
	
	cpShape *shape;
	
	// Vertexes for the dominos.
	int num = 4;
	cpVect verts[] = {
		cpv(-3,-20),
		cpv(-3, 20),
		cpv( 3, 20),
		cpv( 3,-20),
	};
	
	// Add a floor.
	shape = cpSegmentShapeNew(staticBody, cpv(-600,-240), cpv(600,-240), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	// Shared friction constant.
	cpFloat u = 0.6f;
	
	// Add the dominoes. Skim over this. It doesn't do anything fancy, and it's hard to follow.
	int n = 9;
	for(int i=1; i<=n; i++){
		cpVect offset = cpv(-i*60/2.0f, (n - i)*52);
		
		for(int j=0; j<i; j++){
			body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpvzero));
			body->p = cpvadd(cpv(j*60, -220), offset);
			cpSpaceAddBody(space, body);
			shape = cpPolyShapeNew(body, num, verts, cpvzero);
			shape->e = 0.0f; shape->u = u;
			cpSpaceAddShape(space, shape);

			body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpvzero));
			body->p = cpvadd(cpv(j*60, -197), offset);
			cpBodySetAngle(body, (cpFloat) M_PI/2.0f);
			cpSpaceAddBody(space, body);
			shape = cpPolyShapeNew(body, num, verts, cpvzero);
			shape->e = 0.0f; shape->u = u;
			cpSpaceAddShape(space, shape);
			
			if(j == (i - 1)) continue;
			body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpvzero));
			body->p = cpvadd(cpv(j*60 + 30, -191), offset);
			cpBodySetAngle(body, (cpFloat) M_PI/2.0f);
			cpSpaceAddBody(space, body);
			shape = cpPolyShapeNew(body, num, verts, cpvzero);
			shape->e = 0.0f; shape->u = u;
			cpSpaceAddShape(space, shape);		
		}

		body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpvzero));
		body->p = cpvadd(cpv(-17, -174), offset);
		cpSpaceAddBody(space, body);
		shape = cpPolyShapeNew(body, num, verts, cpvzero);
		shape->e = 0.0f; shape->u = u;
		cpSpaceAddShape(space, shape);		

		body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpvzero));
		body->p = cpvadd(cpv((i - 1)*60 + 17, -174), offset);
		cpSpaceAddBody(space, body);
		shape = cpPolyShapeNew(body, num, verts, cpvzero);
		shape->e = 0.0f; shape->u = u;
		cpSpaceAddShape(space, shape);		
	}
	
	// Give the last domino a little tip.
//	body->w = -1;
//	body->v = cpv(-body->w*20, 0);
}
