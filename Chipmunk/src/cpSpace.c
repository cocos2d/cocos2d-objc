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
#include <assert.h>

#include "chipmunk.h"

int cp_contact_persistence = 3;

// Equal function for contactSet.
static int
contactSetEql(void *ptr, void *elt)
{
	cpShape **shapes = (cpShape **)ptr;
	cpShape *a = shapes[0];
	cpShape *b = shapes[1];
	
	cpArbiter *arb = (cpArbiter *)elt;
	
	return ((a == arb->a && b == arb->b) || (b == arb->a && a == arb->b));
}

// Transformation function for contactSet.
static void *
contactSetTrans(void *ptr, void *data)
{
	cpShape **shapes = (cpShape **)ptr;
	cpShape *a = shapes[0];
	cpShape *b = shapes[1];
	
	cpSpace *space = (cpSpace *)data;
	
	return cpArbiterNew(a, b, space->stamp);
}

// Collision pair function wrapper struct.
typedef struct collFuncData {
	cpCollFunc func;
	void *data;
} collFuncData;

// Equals function for collFuncSet.
static int
collFuncSetEql(void *ptr, void *elt)
{
	unsigned int *ids = (unsigned int *)ptr;
	unsigned int a = ids[0];
	unsigned int b = ids[1];
	
	cpCollPairFunc *pair = (cpCollPairFunc *)elt;
	
	return ((a == pair->a && b == pair->b) || (b == pair->a && a == pair->b));
}

// Transformation function for collFuncSet.
static void *
collFuncSetTrans(void *ptr, void *data)
{
	unsigned int *ids = (unsigned int *)ptr;
	collFuncData *funcData = (collFuncData *)data;

	cpCollPairFunc *pair = (cpCollPairFunc *)malloc(sizeof(cpCollPairFunc));
	pair->a = ids[0];
	pair->b = ids[1];
	pair->func = funcData->func;
	pair->data = funcData->data;

	return pair;
}

// Default collision pair function.
static int
alwaysCollide(cpShape *a, cpShape *b, cpContact *arr, int numCon, cpFloat normal_coef, void *data)
{
	return 1;
}

// BBfunc callback for the spatial hash.
static cpBB
bbfunc(void *ptr)
{
	cpShape *shape = (cpShape *)ptr;
	return shape->bb;
}

// Iterator functions for destructors.
static void        freeWrap(void *ptr, void *unused){          free(             ptr);}
static void   shapeFreeWrap(void *ptr, void *unused){   cpShapeFree((cpShape *)  ptr);}
static void arbiterFreeWrap(void *ptr, void *unused){ cpArbiterFree((cpArbiter *)ptr);}
static void    bodyFreeWrap(void *ptr, void *unused){    cpBodyFree((cpBody *)   ptr);}
static void   jointFreeWrap(void *ptr, void *unused){   cpJointFree((cpJoint *)  ptr);}

cpSpace*
cpSpaceAlloc(void)
{
	return (cpSpace *)calloc(1, sizeof(cpSpace));
}

#define DEFAULT_DIM_SIZE 100.0f
#define DEFAULT_COUNT 1000
#define DEFAULT_ITERATIONS 10
#define DEFAULT_ELASTIC_ITERATIONS 0

cpSpace*
cpSpaceInit(cpSpace *space)
{
	space->iterations = DEFAULT_ITERATIONS;
	space->elasticIterations = DEFAULT_ELASTIC_ITERATIONS;
//	space->sleepTicks = 300;
	
	space->gravity = cpvzero;
	space->damping = 1.0f;
	
	space->stamp = 0;

	space->staticShapes = cpSpaceHashNew(DEFAULT_DIM_SIZE, DEFAULT_COUNT, &bbfunc);
	space->activeShapes = cpSpaceHashNew(DEFAULT_DIM_SIZE, DEFAULT_COUNT, &bbfunc);
	
	space->bodies = cpArrayNew(0);
	space->arbiters = cpArrayNew(0);
	space->contactSet = cpHashSetNew(0, contactSetEql, contactSetTrans);
	
	space->joints = cpArrayNew(0);
	
	cpCollPairFunc pairFunc = {0, 0, alwaysCollide, NULL};
	space->defaultPairFunc = pairFunc;
	space->collFuncSet = cpHashSetNew(0, collFuncSetEql, collFuncSetTrans);
	space->collFuncSet->default_value = &space->defaultPairFunc;
	
	return space;
}

cpSpace*
cpSpaceNew(void)
{
	return cpSpaceInit(cpSpaceAlloc());
}

void
cpSpaceDestroy(cpSpace *space)
{
	cpSpaceHashFree(space->staticShapes);
	cpSpaceHashFree(space->activeShapes);
	
	cpArrayFree(space->bodies);
	
	cpArrayFree(space->joints);
	
	if(space->contactSet)
		cpHashSetEach(space->contactSet, &arbiterFreeWrap, NULL);
	cpHashSetFree(space->contactSet);
	cpArrayFree(space->arbiters);
	
	if(space->collFuncSet)
		cpHashSetEach(space->collFuncSet, &freeWrap, NULL);
	cpHashSetFree(space->collFuncSet);
}

void
cpSpaceFree(cpSpace *space)
{
	if(space) cpSpaceDestroy(space);
	free(space);
}

void
cpSpaceFreeChildren(cpSpace *space)
{
	cpSpaceHashEach(space->staticShapes, &shapeFreeWrap, NULL);
	cpSpaceHashEach(space->activeShapes, &shapeFreeWrap, NULL);
	cpArrayEach(space->bodies, &bodyFreeWrap, NULL);
	cpArrayEach(space->joints, &jointFreeWrap, NULL);
}

void
cpSpaceAddCollisionPairFunc(cpSpace *space, unsigned int a, unsigned int b,
                                 cpCollFunc func, void *data)
{
	unsigned int ids[] = {a, b};
	unsigned int hash = CP_HASH_PAIR(a, b);
	// Remove any old function so the new one will get added.
	cpSpaceRemoveCollisionPairFunc(space, a, b);
		
	collFuncData funcData = {func, data};
	cpHashSetInsert(space->collFuncSet, hash, ids, &funcData);
}

void
cpSpaceRemoveCollisionPairFunc(cpSpace *space, unsigned int a, unsigned int b)
{
	unsigned int ids[] = {a, b};
	unsigned int hash = CP_HASH_PAIR(a, b);
	cpCollPairFunc *old_pair = (cpCollPairFunc *)cpHashSetRemove(space->collFuncSet, hash, ids);
	free(old_pair);
}

void
cpSpaceSetDefaultCollisionPairFunc(cpSpace *space, cpCollFunc func, void *data)
{
	cpCollPairFunc pairFunc = {0, 0, (func ? func : alwaysCollide), (func ? data : NULL)};
	space->defaultPairFunc = pairFunc;
}

void
cpSpaceAddShape(cpSpace *space, cpShape *shape)
{
	cpSpaceHashInsert(space->activeShapes, shape, shape->id, shape->bb);
}

void
cpSpaceAddStaticShape(cpSpace *space, cpShape *shape)
{
	cpShapeCacheBB(shape);
	cpSpaceHashInsert(space->staticShapes, shape, shape->id, shape->bb);
}

void
cpSpaceAddBody(cpSpace *space, cpBody *body)
{
	cpArrayPush(space->bodies, body);
}

void
cpSpaceAddJoint(cpSpace *space, cpJoint *joint)
{
	cpArrayPush(space->joints, joint);
}

void
cpSpaceRemoveShape(cpSpace *space, cpShape *shape)
{
	cpSpaceHashRemove(space->activeShapes, shape, shape->id);
}

void
cpSpaceRemoveStaticShape(cpSpace *space, cpShape *shape)
{
	cpSpaceHashRemove(space->staticShapes, shape, shape->id);
}

void
cpSpaceRemoveBody(cpSpace *space, cpBody *body)
{
	cpArrayDeleteObj(space->bodies, body);
}

void
cpSpaceRemoveJoint(cpSpace *space, cpJoint *joint)
{
	cpArrayDeleteObj(space->joints, joint);
}

void
cpSpaceEachBody(cpSpace *space, cpSpaceBodyIterator func, void *data)
{
	cpArray *bodies = space->bodies;
	
	for(int i=0; i<bodies->num; i++)
		func((cpBody *)bodies->arr[i], data);
}

// Iterator function used for updating shape BBoxes.
static void
updateBBCache(void *ptr, void *unused)
{
	cpShape *shape = (cpShape *)ptr;
	cpShapeCacheBB(shape);
}

void
cpSpaceResizeStaticHash(cpSpace *space, cpFloat dim, int count)
{
	cpSpaceHashResize(space->staticShapes, dim, count);
	cpSpaceHashRehash(space->staticShapes);
}

void
cpSpaceResizeActiveHash(cpSpace *space, cpFloat dim, int count)
{
	cpSpaceHashResize(space->activeShapes, dim, count);
}

void 
cpSpaceRehashStatic(cpSpace *space)
{
	cpSpaceHashEach(space->staticShapes, &updateBBCache, NULL);
	cpSpaceHashRehash(space->staticShapes);
}

typedef struct pointQueryFuncPair {
	cpSpacePointQueryFunc func;
	void *data;
} pointQueryFuncPair;

static int 
pointQueryHelper(void *point, void *obj, void *data)
{
	cpShape *shape = (cpShape *)obj;
	pointQueryFuncPair *pair = (pointQueryFuncPair *)data;
	
	if(cpShapePointQuery(shape, *((cpVect *)point)))
		pair->func(shape, pair->data);
	
	return 1; // return value needed for historical reasons (value is ignored)
}

static void
pointQuery(cpSpaceHash *hash, cpVect point, cpSpacePointQueryFunc func, void *data)
{
	pointQueryFuncPair pair = {func, data};
	cpSpaceHashPointQuery(hash, point, pointQueryHelper, &pair);
}

void
cpSpaceShapePointQuery(cpSpace *space, cpVect point, cpSpacePointQueryFunc func, void *data)
{
	pointQuery(space->activeShapes, point, func, data);
}

void
cpSpaceStaticShapePointQuery(cpSpace *space, cpVect point, cpSpacePointQueryFunc func, void *data)
{
	pointQuery(space->staticShapes, point, func, data);
}

static inline int
queryReject(cpShape *a, cpShape *b)
{
	return
		// BBoxes must overlap
		!cpBBintersects(a->bb, b->bb)
		// Don't collide shapes attached to the same body.
		|| a->body == b->body
		// Don't collide objects in the same non-zero group
		|| (a->group && b->group && a->group == b->group)
		// Don't collide objects that don't share at least on layer.
		|| !(a->layers & b->layers);
}

// Callback from the spatial hash.
// TODO: Refactor this into separate functions?
static int
queryFunc(void *p1, void *p2, void *data)
{
	// Cast the generic pointers from the spatial hash back to usefull types
	cpShape *a = (cpShape *)p1;
	cpShape *b = (cpShape *)p2;
	cpSpace *space = (cpSpace *)data;
	
	// Reject any of the simple cases
	if(queryReject(a,b)) return 0;
	
	// Shape 'a' should have the lower shape type. (required by cpCollideShapes() )
	if(a->klass->type > b->klass->type){
		cpShape *temp = a;
		a = b;
		b = temp;
	}
	
	// Find the collision pair function for the shapes.
	unsigned int ids[] = {a->collision_type, b->collision_type};
	unsigned int hash = CP_HASH_PAIR(a->collision_type, b->collision_type);
	cpCollPairFunc *pairFunc = (cpCollPairFunc *)cpHashSetFind(space->collFuncSet, hash, ids);
	if(!pairFunc->func) return 0; // A NULL pair function means don't collide at all.
	
	// Narrow-phase collision detection.
	cpContact *contacts = NULL;
	int numContacts = cpCollideShapes(a, b, &contacts);
	if(!numContacts) return 0; // Shapes are not colliding.
	
	// The collision pair function requires objects to be ordered by their collision types.
	cpShape *pair_a = a;
	cpShape *pair_b = b;
	cpFloat normal_coef = 1.0f;
	
	// Swap them if necessary.
	if(pair_a->collision_type != pairFunc->a){
		cpShape *temp = pair_a;
		pair_a = pair_b;
		pair_b = temp;
		normal_coef = -1.0f;
	}
	
	if(pairFunc->func(pair_a, pair_b, contacts, numContacts, normal_coef, pairFunc->data)){
		// The collision pair function OKed the collision. Record the contact information.
		
		// Get an arbiter from space->contactSet for the two shapes.
		// This is where the persistant contact magic comes from.
		cpShape *shape_pair[] = {a, b};
		cpArbiter *arb = (cpArbiter *)cpHashSetInsert(space->contactSet, CP_HASH_PAIR(a, b), shape_pair, space);
		
		// Timestamp the arbiter.
		arb->stamp = space->stamp;
		arb->a = a; arb->b = b; // TODO: Investigate why this is still necessary?
		// Inject the new contact points into the arbiter.
		cpArbiterInject(arb, contacts, numContacts);
		
		// Add the arbiter to the list of active arbiters.
		cpArrayPush(space->arbiters, arb);
		
		return numContacts;
	} else {
		// The collision pair function rejected the collision.
		
		free(contacts);
		return 0;
	}
}

// Iterator for active/static hash collisions.
static void
active2staticIter(void *ptr, void *data)
{
	cpShape *shape = (cpShape *)ptr;
	cpSpace *space = (cpSpace *)data;
	cpSpaceHashQuery(space->staticShapes, shape, shape->bb, &queryFunc, space);
}

// Hashset reject func to throw away old arbiters.
static int
contactSetReject(void *ptr, void *data)
{
	cpArbiter *arb = (cpArbiter *)ptr;
	cpSpace *space = (cpSpace *)data;
	
	if((space->stamp - arb->stamp) > cp_contact_persistence){
		cpArbiterFree(arb);
		return 0;
	}
	
	return 1;
}

void
cpSpaceStep(cpSpace *space, cpFloat dt)
{
	if(!dt) return; // prevents div by zero.
	cpFloat dt_inv = 1.0f/dt;

	cpArray *bodies = space->bodies;
	cpArray *arbiters = space->arbiters;
	cpArray *joints = space->joints;
	
	// Empty the arbiter list.
	cpHashSetReject(space->contactSet, &contactSetReject, space);
	space->arbiters->num = 0;

	// Integrate positions.
	for(int i=0; i<bodies->num; i++){
		cpBody *body = (cpBody *)bodies->arr[i];
		body->position_func(body, dt);
	}
	
	// Pre-cache BBoxes and shape data.
	cpSpaceHashEach(space->activeShapes, &updateBBCache, NULL);
	
	// Collide!
	cpSpaceHashEach(space->activeShapes, &active2staticIter, space);
	cpSpaceHashQueryRehash(space->activeShapes, &queryFunc, space);

	// Prestep the arbiters.
	for(int i=0; i<arbiters->num; i++)
		cpArbiterPreStep((cpArbiter *)arbiters->arr[i], dt_inv);

	// Prestep the joints.
	for(int i=0; i<joints->num; i++){
		cpJoint *joint = (cpJoint *)joints->arr[i];
		joint->klass->preStep(joint, dt_inv);
	}

	for(int i=0; i<space->elasticIterations; i++){
		for(int j=0; j<arbiters->num; j++)
			cpArbiterApplyImpulse((cpArbiter *)arbiters->arr[j], 1.0f);
			
		for(int j=0; j<joints->num; j++){
			cpJoint *joint = (cpJoint *)joints->arr[j];
			joint->klass->applyImpulse(joint);
		}
	}

	// Integrate velocities.
	cpFloat damping = powf(1.0f/space->damping, -dt);
	for(int i=0; i<bodies->num; i++){
		cpBody *body = (cpBody *)bodies->arr[i];
		body->velocity_func(body, space->gravity, damping, dt);
	}

	for(int i=0; i<arbiters->num; i++)
		cpArbiterApplyCachedImpulse((cpArbiter *)arbiters->arr[i]);
	
	// Run the impulse solver.
	for(int i=0; i<space->iterations; i++){
		for(int j=0; j<arbiters->num; j++)
			cpArbiterApplyImpulse((cpArbiter *)arbiters->arr[j], 0.0f);
			
		for(int j=0; j<joints->num; j++){
			cpJoint *joint = (cpJoint *)joints->arr[j];
			joint->klass->applyImpulse(joint);
		}
	}

//	cpFloat dvsq = cpvdot(space->gravity, space->gravity);
//	dvsq *= dt*dt * space->damping*space->damping;
//	for(int i=0; i<bodies->num; i++)
//		cpBodyMarkLowEnergy(bodies->arr[i], dvsq, space->sleepTicks);
	
	// Increment the stamp.
	space->stamp++;
}
