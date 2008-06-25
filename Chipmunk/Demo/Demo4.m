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

void demo4_update(int ticks)
{
	int steps = 3;
	cpFloat dt = 1.0/60.0/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
		cpBodyUpdatePosition(staticBody, dt);
		cpSpaceRehashStatic(space);
	}
}

void demo4_init(void)
{
	staticBody = cpBodyNew(INFINITY, INFINITY);
	
	cpResetShapeIdCounter();
	space = cpSpaceNew();
	cpSpaceResizeActiveHash(space, 30.0, 999);
	cpSpaceResizeStaticHash(space, 200.0, 99);
	space->gravity = cpv(0, -600);
	
	cpBody *body;
	cpShape *shape;
	
	int num = 4;
	cpVect verts[] = {
		cpv(-30,-15),
		cpv(-30, 15),
		cpv( 30, 15),
		cpv( 30,-15),
	};
	
	cpVect a = cpv(-200, -200);
	cpVect b = cpv(-200,  200);
	cpVect c = cpv( 200,  200);
	cpVect d = cpv( 200, -200);
	
	shape = cpSegmentShapeNew(staticBody, a, b, 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);

	shape = cpSegmentShapeNew(staticBody, b, c, 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);

	shape = cpSegmentShapeNew(staticBody, c, d, 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);

	shape = cpSegmentShapeNew(staticBody, d, a, 0.0f);
	shape->e = 1.0; shape->u = 1.0;
	cpSpaceAddStaticShape(space, shape);
	
	staticBody->w = 0.4;
	
	for(int i=0; i<3; i++){
		for(int j=0; j<7; j++){
			body = cpBodyNew(1.0, cpMomentForPoly(1.0, num, verts, cpvzero));
			body->p = cpv(i*60 - 150, j*30 - 150);
			cpSpaceAddBody(space, body);
			shape = cpPolyShapeNew(body, num, verts, cpvzero);
			shape->e = 0.0; shape->u = 0.7;
			cpSpaceAddShape(space, shape);
		}
	}
}
