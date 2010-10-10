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

#pragma mark Sleeping Functions

// Chipmunk uses a data structure called a disjoint set forest.
// My attempts to find a way to splice circularly linked lists in
// constant time failed, and so I found this neat data structure instead.

static inline cpBody *
componentNodeRoot(cpBody *body)
{
	cpBody *parent = body->node.parent;
	
	if(parent){
		// path compression, attaches this node directly to the root
		return (body->node.parent = componentNodeRoot(parent));
	} else {
		return body;
	}
}

static inline void
componentNodeMerge(cpBody *a_root, cpBody *b_root)
{
	if(a_root->node.rank < b_root->node.rank){
		a_root->node.parent = b_root;
	} else if(a_root->node.rank > b_root->node.rank){
		b_root->node.parent = a_root;
	} else if(a_root != b_root){
		b_root->node.parent = a_root;
		a_root->node.rank++;
	}
}

static inline void
componentActivate(cpBody *root)
{
	if(!cpBodyIsSleeping(root)) return;
	
	cpSpace *space = root->space;
	cpAssert(space, "Trying to activate a body that was never added to a space.");
	
	cpBody *body = root, *next;
	do {
		next = body->node.next;
		
		cpComponentNode node = {NULL, NULL, 0, 0.0f};
		body->node = node;
		cpArrayPush(space->bodies, body);
		
		for(cpShape *shape=body->shapesList; shape; shape=shape->next){
			cpSpaceHashRemove(space->staticShapes, shape, shape->hashid);
			cpSpaceHashInsert(space->activeShapes, shape, shape->hashid, shape->bb);
		}
	} while((body = next) != root);
	
	cpArrayDeleteObj(space->sleepingComponents, root);
}

void
cpBodyActivate(cpBody *body)
{
	// Reset the idle time even if it's not in a currently sleeping component
	// Like a body resting on or jointed to a rogue body.
	body->node.idleTime = 0.0f;
	componentActivate(componentNodeRoot(body));
}

static inline void
mergeBodies(cpSpace *space, cpArray *components, cpArray *rogueBodies, cpBody *a, cpBody *b)
{
	// Don't merge with the static body
	if(cpBodyIsStatic(a) || cpBodyIsStatic(b)) return;
	
	cpBody *a_root = componentNodeRoot(a);
	cpBody *b_root = componentNodeRoot(b);
	
	cpBool a_sleep = cpBodyIsSleeping(a_root);
	cpBool b_sleep = cpBodyIsSleeping(b_root);
	
	if(a_sleep && b_sleep){
		return;
	} else if(a_sleep || b_sleep){
		componentActivate(a_root);
		componentActivate(b_root);
	} 
	
	// Add any rogue bodies (bodies not added to the space)
	if(!a->space) cpArrayPush(rogueBodies, a);
	if(!b->space) cpArrayPush(rogueBodies, b);
	
	componentNodeMerge(a_root, b_root);
}

static inline cpBool
componentActive(cpBody *root, cpFloat threshold)
{
	cpBody *body = root, *next;
	do {
		next = body->node.next;
		if(cpBodyIsRogue(body) || body->node.idleTime < threshold) return cpTrue;
	} while((body = next) != root);
	
	return cpFalse;
}

static inline void
addToComponent(cpBody *body, cpArray *components)
{
	// Check that the body is not already added to the component list
	if(body->node.next) return;
	cpBody *root = componentNodeRoot(body);
	
	cpBody *next = root->node.next;
	if(!next){
		// If the root isn't part of a list yet, then it hasn't been
		// added to the components list. Do that now.
		cpArrayPush(components, root);
		// Start the list
		body->node.next = root;
		root->node.next = body;
	} else if(root != body) {
		// Splice in body after the root.
		body->node.next = next;
		root->node.next = body;
	}
}

// TODO this function needs more commenting.
void
cpSpaceProcessComponents(cpSpace *space, cpFloat dt)
{
	cpArray *bodies = space->bodies;
	cpArray *newBodies = cpArrayNew(bodies->num);
	cpArray *rogueBodies = cpArrayNew(16);
	cpArray *arbiters = space->arbiters;
	cpArray *constraints = space->constraints;
	cpArray *components = cpArrayNew(bodies->num/8);
	
	cpFloat dv = space->idleSpeedThreshold;
	cpFloat dvsq = (dv ? dv*dv : cpvdot(space->gravity, space->gravity)*dt*dt);
	// update idling
	for(int i=0; i<bodies->num; i++){
		cpBody *body = (cpBody*)bodies->arr[i];
		
		cpFloat thresh = (dvsq ? body->m*dvsq : 0.0f);
		body->node.idleTime = (cpBodyKineticEnergy(body) > thresh ? 0.0f : body->node.idleTime + dt);
	}
	
	// iterate graph edges and build forests
	for(int i=0; i<arbiters->num; i++){
		cpArbiter *arb = (cpArbiter*)arbiters->arr[i];
		mergeBodies(space, components, rogueBodies, arb->private_a->body, arb->private_b->body);
	}
	for(int j=0; j<constraints->num; j++){
		cpConstraint *constraint = (cpConstraint *)constraints->arr[j];
		mergeBodies(space, components, rogueBodies, constraint->a, constraint->b);
	}
	
	// iterate bodies and add them to their components
	for(int i=0; i<bodies->num; i++)
		addToComponent((cpBody*)bodies->arr[i], components);
	for(int i=0; i<rogueBodies->num; i++)
		addToComponent((cpBody*)rogueBodies->arr[i], components);
	
	// iterate components, copy or deactivate
	for(int i=0; i<components->num; i++){
		cpBody *root = (cpBody*)components->arr[i];
		if(componentActive(root, space->sleepTimeThreshold)){
			cpBody *body = root, *next;
			do {
				next = body->node.next;
				
				if(!cpBodyIsRogue(body)) cpArrayPush(newBodies, body);
				body->node.next = NULL;
				body->node.parent = NULL;
				body->node.rank = 0;
			} while((body = next) != root);
		} else {
			cpBody *body = root, *next;
			do {
				next = body->node.next;
				
				for(cpShape *shape = body->shapesList; shape; shape = shape->next){
					cpSpaceHashRemove(space->activeShapes, shape, shape->hashid);
					cpSpaceHashInsert(space->staticShapes, shape, shape->hashid, shape->bb);
				}
			} while((body = next) != root);
			
			cpArrayPush(space->sleepingComponents, root);
		}
	}
	
	space->bodies = newBodies;
	cpArrayFree(bodies);
	cpArrayFree(rogueBodies);
	cpArrayFree(components);
}

void
cpSpaceSleepBody(cpSpace *space, cpBody *body){
	cpComponentNode node = {NULL, body, 0, 0.0f};
	body->node = node;
	
	for(cpShape *shape = body->shapesList; shape; shape = shape->next){
		cpSpaceHashRemove(space->activeShapes, shape, shape->hashid);
		
		cpShapeCacheBB(shape);
		cpSpaceHashInsert(space->staticShapes, shape, shape->hashid, shape->bb);
	}
	
	cpArrayPush(space->sleepingComponents, body);
	cpArrayDeleteObj(space->bodies, body);
}
