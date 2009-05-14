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
 
/*
 IMPORTANT - READ ME!
 
 This file sets up a simple interface that the individual demos can use to get
 a Chipmunk space running and draw what's in it. In order to keep the Chipmunk
 examples clean and simple, they contain no graphics code. All drawing is done
 by accessing the Chipmunk structures at a very low level. It is NOT
 recommended to write a game or application this way as it does not scale
 beyond simple shape drawing and is very dependent on implementation details
 about Chipmunk which may change with little to no warning.
*/

#import <UIKit/UIKit.h>
#import "main.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#import "cocos2d.h"
#include "chipmunk.h"

#define SLEEP_TICKS 16

extern void demo1_init(void);
extern void demo1_update(int);

extern void demo2_init(void);
extern void demo2_update(int);

extern void demo3_init(void);
extern void demo3_update(int);

extern void demo4_init(void);
extern void demo4_update(int);

extern void demo5_init(void);
extern void demo5_update(int);

extern void demo6_init(void);
extern void demo6_update(int);

extern void demo7_init(void);
extern void demo7_update(int);


typedef void (*demo_init_func)(void);
typedef void (*demo_update_func)(int);
typedef void (*demo_destroy_func)(void);

demo_init_func init_funcs[] = {
	demo1_init,
	demo2_init,
	demo3_init,
	demo4_init,
	demo5_init,
	demo6_init,
	demo7_init,
};

demo_update_func update_funcs[] = {
	demo1_update,
	demo2_update,
	demo3_update,
	demo4_update,
	demo5_update,
	demo6_update,
	demo7_update,
};

void demo_destroy(void);

demo_destroy_func destroy_funcs[] = {
	demo_destroy,
	demo_destroy,
	demo_destroy,
	demo_destroy,
	demo_destroy,
	demo_destroy,
	demo_destroy,
};

int demo_index = 0;

int ticks = 0;
cpSpace *space;
cpBody *staticBody;

void demo_destroy(void)
{
	cpSpaceFreeChildren(space);
	cpSpaceFree(space);
	
	cpBodyFree(staticBody);
}

void drawCircleShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpCircleShape *circle = (cpCircleShape *)shape;
	cpVect c = cpvadd(body->p, cpvrotate(circle->c, body->rot));
	drawCircle( ccp(c.x, c.y), circle->r, body->a, 15, YES);
}

void drawSegmentShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	cpVect a = cpvadd(body->p, cpvrotate(seg->a, body->rot));
	cpVect b = cpvadd(body->p, cpvrotate(seg->b, body->rot));
	
	drawLine( ccp(a.x, a.y), ccp(b.x, b.y) );
}

void drawPolyShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpPolyShape *poly = (cpPolyShape *)shape;
	
	int num = poly->numVerts;
	cpVect *verts = poly->verts;
	
	CGPoint *vertices = malloc( sizeof(CGPoint)*poly->numVerts);
	if( ! vertices )
		return;
	
	for(int i=0; i<num; i++){
		cpVect v = cpvadd(body->p, cpvrotate(verts[i], body->rot));
		vertices[i] = v;
	}
	drawPoly( vertices, poly->numVerts, YES );
	
	free(vertices);
}

void drawObject(void *ptr, void *unused)
{
	cpShape *shape = (cpShape *)ptr;
	switch(shape->klass->type){
		case CP_CIRCLE_SHAPE:
			drawCircleShape(shape);
			break;
		case CP_SEGMENT_SHAPE:
			drawSegmentShape(shape);
			break;
		case CP_POLY_SHAPE:
			drawPolyShape(shape);
			break;
		default:
			printf("Bad enumeration in drawObject().\n");
	}
}

void drawCollisions(void *ptr, void *data)
{
	cpArbiter *arb = (cpArbiter *)ptr;
	for(int i=0; i<arb->numContacts; i++){
		cpVect v = arb->contacts[i].p;
		drawPoint( ccp(v.x, v.y) );
	}
}

@implementation MainLayer
-(id) init
{
	[super init];
	isTouchEnabled = YES;
	cpInitChipmunk();	
	init_funcs[demo_index]();

	[self schedule: @selector(step:)];

	return self;
}

-(void) onEnter
{
	[super onEnter];
		
	float factor = 1.0f;
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(-320/factor, 320/factor, -480/factor, 480/factor, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glPointSize(3.0f);
    glEnable(GL_LINE_SMOOTH);
	glEnable(GL_POINT_SMOOTH);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
    glHint(GL_POINT_SMOOTH_HINT, GL_DONT_CARE);
    glLineWidth(1.5f);
}

-(void) step: (ccTime) dt
{
	ticks++;	
	update_funcs[demo_index](ticks);
}

-(void) draw
{
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	cpSpaceHashEach(space->activeShapes, &drawObject, NULL);
	cpSpaceHashEach(space->staticShapes, &drawObject, NULL);
	
	cpArray *bodies = space->bodies;
	int num = bodies->num;

#if 1	// comment this block for better performance
	glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
	for(int i=0; i<num; i++){
		cpBody *body = (cpBody *)bodies->arr[i];
		drawPoint( ccp(body->p.x, body->p.y) );
	}
	
	glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
	cpArrayEach(space->arbiters, &drawCollisions, NULL);
#endif
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	UITouch *touch = [touches anyObject];	
//	CGPoint location = [touch locationInView: [touch view]];

	destroy_funcs[demo_index]();

	demo_index++;
	demo_index %=7;
	
	ticks = 0;
	init_funcs[demo_index]();
	
	return kEventHandled;
}
@end


@implementation AppController
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
	// FastDirector is faster, but consumes more battery
	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setDisplayFPS:YES];

	// Fast Director doesn't support setAnimationInterval yet
//	[[Director sharedDirector] setAnimationInterval:1.0/60];
	
	[[Director sharedDirector] attachInView:window];
	
	Scene *scene = [Scene node];
	
	MainLayer * mainLayer =[MainLayer node];
	
	[scene addChild: mainLayer];
	
	[window makeKeyAndVisible];

	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}


@end


int main(int argc, char *argv[]) {
	
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	UIApplicationMain(argc, argv, nil, @"AppController");
	[pool release];
	return 0;
}

