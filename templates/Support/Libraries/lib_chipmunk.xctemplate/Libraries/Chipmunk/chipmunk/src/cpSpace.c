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

//MARK: Contact Set Helpers

// Equal function for arbiterSet.
static cpBool
arbiterSetEql(cpShape **shapes, cpArbiter *arb)
{
	cpShape *a = shapes[0];
	cpShape *b = shapes[1];
	
	return ((a == arb->a && b == arb->b) || (b == arb->a && a == arb->b));
}

//MARK: Collision Handler Set HelperFunctions

// Equals function for collisionHandlers.
static cpBool
handlerSetEql(cpCollisionHandler *check, cpCollisionHandler *pair)
{
	return (
		(check->typeA == pair->typeA && check->typeB == pair->typeB) ||
		(check->typeB == pair->typeA && check->typeA == pair->typeB)
	);
}

// Transformation function for collisionHandlers.
static void *
handlerSetTrans(cpCollisionHandler *handler, void *unused)
{
	cpCollisionHandler *copy = (cpCollisionHandler *)cpcalloc(1, sizeof(cpCollisionHandler));
	(*copy) = (*handler);
	
	return copy;
}

//MARK: Misc Helper Funcs

// Default collision functions.

static cpBool
DefaultBegin(cpArbiter *arb, cpSpace *space, void *data){
	cpBool retA = cpArbiterCallWildcardBeginA(arb, space);
	cpBool retB = cpArbiterCallWildcardBeginB(arb, space);
	return retA && retB;
}

static cpBool
DefaultPreSolve(cpArbiter *arb, cpSpace *space, void *data){
	cpBool retA = cpArbiterCallWildcardPreSolveA(arb, space);
	cpBool retB = cpArbiterCallWildcardPreSolveB(arb, space);
	return retA && retB;
}

static void
DefaultPostSolve(cpArbiter *arb, cpSpace *space, void *data){
	cpArbiterCallWildcardPostSolveA(arb, space);
	cpArbiterCallWildcardPostSolveB(arb, space);
}

static void
DefaultSeparate(cpArbiter *arb, cpSpace *space, void *data){
	cpArbiterCallWildcardSeparateA(arb, space);
	cpArbiterCallWildcardSeparateB(arb, space);
}

// Use the wildcard identifier since  the default handler should never match any type pair.
static cpCollisionHandler cpCollisionHandlerDefault = {
	CP_WILDCARD_COLLISION_TYPE, CP_WILDCARD_COLLISION_TYPE,
	DefaultBegin, DefaultPreSolve, DefaultPostSolve, DefaultSeparate, NULL
};

static cpBool AlwaysCollide(cpArbiter *arb, cpSpace *space, void *data){return cpTrue;}
static void DoNothing(cpArbiter *arb, cpSpace *space, void *data){}

cpCollisionHandler cpCollisionHandlerDoNothing = {
	CP_WILDCARD_COLLISION_TYPE, CP_WILDCARD_COLLISION_TYPE,
	AlwaysCollide, AlwaysCollide, DoNothing, DoNothing, NULL
};

// function to get the estimated velocity of a shape for the cpBBTree.
static cpVect ShapeVelocityFunc(cpShape *shape){return shape->body->v;}

// Used for disposing of collision handlers.
static void FreeWrap(void *ptr, void *unused){cpfree(ptr);}

//MARK: Memory Management Functions

cpSpace *
cpSpaceAlloc(void)
{
	return (cpSpace *)cpcalloc(1, sizeof(cpSpace));
}

cpSpace*
cpSpaceInit(cpSpace *space)
{
#ifndef NDEBUG
	static cpBool done = cpFalse;
	if(!done){
		printf("Initializing cpSpace - Chipmunk v%s (Debug Enabled)\n", cpVersionString);
		printf("Compile with -DNDEBUG defined to disable debug mode and runtime assertion checks\n");
		done = cpTrue;
	}
#endif

	space->iterations = 10;
	
	space->gravity = cpvzero;
	space->damping = 1.0f;
	
	space->collisionSlop = 0.1f;
	space->collisionBias = cpfpow(1.0f - 0.1f, 60.0f);
	space->collisionPersistence = 3;
	
	space->locked = 0;
	space->stamp = 0;
	
	space->shapeIDCounter = 0;
	space->staticShapes = cpBBTreeNew((cpSpatialIndexBBFunc)cpShapeGetBB, NULL);
	space->dynamicShapes = cpBBTreeNew((cpSpatialIndexBBFunc)cpShapeGetBB, space->staticShapes);
	cpBBTreeSetVelocityFunc(space->dynamicShapes, (cpBBTreeVelocityFunc)ShapeVelocityFunc);
	
	space->allocatedBuffers = cpArrayNew(0);
	
	space->dynamicBodies = cpArrayNew(0);
	space->staticBodies = cpArrayNew(0);
	space->sleepingComponents = cpArrayNew(0);
	space->rousedBodies = cpArrayNew(0);
	
	space->sleepTimeThreshold = INFINITY;
	space->idleSpeedThreshold = 0.0f;
	
	space->arbiters = cpArrayNew(0);
	space->pooledArbiters = cpArrayNew(0);
	
	space->contactBuffersHead = NULL;
	space->cachedArbiters = cpHashSetNew(0, (cpHashSetEqlFunc)arbiterSetEql);
	
	space->constraints = cpArrayNew(0);
	
	space->usesWildcards = cpFalse;
	space->defaultHandler = cpCollisionHandlerDoNothing;
	space->collisionHandlers = cpHashSetNew(0, (cpHashSetEqlFunc)handlerSetEql);
	
	space->postStepCallbacks = cpArrayNew(0);
	space->skipPostStep = cpFalse;
	
	cpBody *staticBody = cpBodyInit(&space->_staticBody, 0.0f, 0.0f);
	cpBodySetType(staticBody, CP_BODY_TYPE_STATIC);
	cpSpaceSetStaticBody(space, staticBody);
	
	return space;
}

cpSpace*
cpSpaceNew(void)
{
	return cpSpaceInit(cpSpaceAlloc());
}

static void cpBodyActivateWrap(cpBody *body, void *unused){cpBodyActivate(body);}

void
cpSpaceDestroy(cpSpace *space)
{
	cpSpaceEachBody(space, (cpSpaceBodyIteratorFunc)cpBodyActivateWrap, NULL);
	
	cpSpatialIndexFree(space->staticShapes);
	cpSpatialIndexFree(space->dynamicShapes);
	
	cpArrayFree(space->dynamicBodies);
	cpArrayFree(space->staticBodies);
	cpArrayFree(space->sleepingComponents);
	cpArrayFree(space->rousedBodies);
	
	cpArrayFree(space->constraints);
	
	cpHashSetFree(space->cachedArbiters);
	
	cpArrayFree(space->arbiters);
	cpArrayFree(space->pooledArbiters);
	
	if(space->allocatedBuffers){
		cpArrayFreeEach(space->allocatedBuffers, cpfree);
		cpArrayFree(space->allocatedBuffers);
	}
	
	if(space->postStepCallbacks){
		cpArrayFreeEach(space->postStepCallbacks, cpfree);
		cpArrayFree(space->postStepCallbacks);
	}
	
	if(space->collisionHandlers) cpHashSetEach(space->collisionHandlers, FreeWrap, NULL);
	cpHashSetFree(space->collisionHandlers);
}

void
cpSpaceFree(cpSpace *space)
{
	if(space){
		cpSpaceDestroy(space);
		cpfree(space);
	}
}


//MARK: Basic properties:

int
cpSpaceGetIterations(const cpSpace *space)
{
	return space->iterations;
}

void
cpSpaceSetIterations(cpSpace *space, int iterations)
{
	cpAssertHard(iterations > 0, "Iterations must be positive and non-zero.");
	space->iterations = iterations;
}

cpVect
cpSpaceGetGravity(const cpSpace *space)
{
	return space->gravity;
}

void
cpSpaceSetGravity(cpSpace *space, cpVect gravity)
{
	space->gravity = gravity;
}

cpFloat
cpSpaceGetDamping(const cpSpace *space)
{
	return space->damping;
}

void
cpSpaceSetDamping(cpSpace *space, cpFloat damping)
{
	cpAssertHard(damping >= 0.0, "Damping must be positive.");
	space->damping = damping;
}

cpFloat
cpSpaceGetIdleSpeedThreshold(const cpSpace *space)
{
	return space->idleSpeedThreshold;
}

void
cpSpaceSetIdleSpeedThreshold(cpSpace *space, cpFloat idleSpeedThreshold)
{
	space->idleSpeedThreshold = idleSpeedThreshold;
}

cpFloat
cpSpaceGetSleepTimeThreshold(const cpSpace *space)
{
	return space->sleepTimeThreshold;
}

void
cpSpaceSetSleepTimeThreshold(cpSpace *space, cpFloat sleepTimeThreshold)
{
	space->sleepTimeThreshold = sleepTimeThreshold;
}

cpFloat
cpSpaceGetCollisionSlop(const cpSpace *space)
{
	return space->collisionSlop;
}

void
cpSpaceSetCollisionSlop(cpSpace *space, cpFloat collisionSlop)
{
	space->collisionSlop = collisionSlop;
}

cpFloat
cpSpaceGetCollisionBias(const cpSpace *space)
{
	return space->collisionBias;
}

void
cpSpaceSetCollisionBias(cpSpace *space, cpFloat collisionBias)
{
	space->collisionBias = collisionBias;
}

cpTimestamp
cpSpaceGetCollisionPersistence(const cpSpace *space)
{
	return space->collisionPersistence;
}

void
cpSpaceSetCollisionPersistence(cpSpace *space, cpTimestamp collisionPersistence)
{
	space->collisionPersistence = collisionPersistence;
}

cpDataPointer
cpSpaceGetUserData(const cpSpace *space)
{
	return space->userData;
}

void
cpSpaceSetUserData(cpSpace *space, cpDataPointer userData)
{
	space->userData = userData;
}

cpBody *
cpSpaceGetStaticBody(const cpSpace *space)
{
	return space->staticBody;
}

cpFloat
cpSpaceGetCurrentTimeStep(const cpSpace *space)
{
	return space->curr_dt;
}

void
cpSpaceSetStaticBody(cpSpace *space, cpBody *body)
{
	if(space->staticBody != NULL){
		cpAssertHard(space->staticBody->shapeList == NULL, "Internal Error: Changing the designated static body while the old one still had shapes attached.");
		space->staticBody->space = NULL;
	}
	
	space->staticBody = body;
	body->space = space;
}

cpBool
cpSpaceIsLocked(cpSpace *space)
{
	return (space->locked > 0);
}

//MARK: Collision Handler Function Management

static void
cpSpaceUseWildcardDefaultHandler(cpSpace *space)
{
	// Spaces default to using the slightly faster "do nothing" default handler until wildcards are potentially needed.
	if(!space->usesWildcards){
		space->usesWildcards = cpTrue;
		space->defaultHandler = cpCollisionHandlerDefault;
	}
}

cpCollisionHandler *cpSpaceAddDefaultCollisionHandler(cpSpace *space)
{
	cpSpaceUseWildcardDefaultHandler(space);
	return &space->defaultHandler;
}

cpCollisionHandler *cpSpaceAddCollisionHandler(cpSpace *space, cpCollisionType a, cpCollisionType b)
{
	cpHashValue hash = CP_HASH_PAIR(a, b);
	// TODO should use space->defaultHandler values instead?
	cpCollisionHandler temp = {a, b, DefaultBegin, DefaultPreSolve, DefaultPostSolve, DefaultSeparate, NULL};
	
	cpHashSet *handlers = space->collisionHandlers;
	cpCollisionHandler *handler = cpHashSetFind(handlers, hash, &temp);
	return (handler ? handler : cpHashSetInsert(handlers, hash, &temp, (cpHashSetTransFunc)handlerSetTrans, NULL));
}

cpCollisionHandler *
cpSpaceAddWildcardHandler(cpSpace *space, cpCollisionType type)
{
	cpSpaceUseWildcardDefaultHandler(space);
	
	cpHashValue hash = CP_HASH_PAIR(type, CP_WILDCARD_COLLISION_TYPE);
	cpCollisionHandler temp = {type, CP_WILDCARD_COLLISION_TYPE, AlwaysCollide, AlwaysCollide, DoNothing, DoNothing, NULL};
	
	cpHashSet *handlers = space->collisionHandlers;
	cpCollisionHandler *handler = cpHashSetFind(handlers, hash, &temp);
	return (handler ? handler : cpHashSetInsert(handlers, hash, &temp, (cpHashSetTransFunc)handlerSetTrans, NULL));
}


//MARK: Body, Shape, and Joint Management
cpShape *
cpSpaceAddShape(cpSpace *space, cpShape *shape)
{
	cpBody *body = shape->body;
	
	cpAssertHard(shape->space != space, "You have already added this shape to this space. You must not add it a second time.");
	cpAssertHard(!shape->space, "You have already added this shape to another space. You cannot add it to a second.");
//	cpAssertHard(body->space == space, "The shape's body must be added to the space before the shape.");
	cpAssertSpaceUnlocked(space);
	
	cpBool isStatic = (cpBodyGetType(body) == CP_BODY_TYPE_STATIC);
	if(!isStatic) cpBodyActivate(body);
	cpBodyAddShape(body, shape);
	
	shape->hashid = space->shapeIDCounter++;
	cpShapeUpdate(shape, body->transform);
	cpSpatialIndexInsert(isStatic ? space->staticShapes : space->dynamicShapes, shape, shape->hashid);
	shape->space = space;
		
	return shape;
}

cpBody *
cpSpaceAddBody(cpSpace *space, cpBody *body)
{
	cpAssertHard(body->space != space, "You have already added this body to this space. You must not add it a second time.");
	cpAssertHard(!body->space, "You have already added this body to another space. You cannot add it to a second.");
	cpAssertSpaceUnlocked(space);
	
	cpArrayPush(cpSpaceArrayForBodyType(space, cpBodyGetType(body)), body);
	body->space = space;
	
	return body;
}

cpConstraint *
cpSpaceAddConstraint(cpSpace *space, cpConstraint *constraint)
{
	cpAssertHard(constraint->space != space, "You have already added this constraint to this space. You must not add it a second time.");
	cpAssertHard(!constraint->space, "You have already added this constraint to another space. You cannot add it to a second.");
	cpAssertSpaceUnlocked(space);
	
	cpBody *a = constraint->a, *b = constraint->b;
	cpAssertHard(a != NULL && b != NULL, "Constraint is attached to a NULL body.");
//	cpAssertHard(a->space == space && b->space == space, "The constraint's bodies must be added to the space before the constraint.");
	
	cpBodyActivate(a);
	cpBodyActivate(b);
	cpArrayPush(space->constraints, constraint);
	
	// Push onto the heads of the bodies' constraint lists
	constraint->next_a = a->constraintList; a->constraintList = constraint;
	constraint->next_b = b->constraintList; b->constraintList = constraint;
	constraint->space = space;
	
	return constraint;
}

struct arbiterFilterContext {
	cpSpace *space;
	cpBody *body;
	cpShape *shape;
};

static cpBool
cachedArbitersFilter(cpArbiter *arb, struct arbiterFilterContext *context)
{
	cpShape *shape = context->shape;
	cpBody *body = context->body;
	
	
	// Match on the filter shape, or if it's NULL the filter body
	if(
		(body == arb->body_a && (shape == arb->a || shape == NULL)) ||
		(body == arb->body_b && (shape == arb->b || shape == NULL))
	){
		// Call separate when removing shapes.
		if(shape && arb->state != CP_ARBITER_STATE_CACHED){
			// Invalidate the arbiter since one of the shapes was removed.
			arb->state = CP_ARBITER_STATE_INVALIDATED;
			
			cpCollisionHandler *handler = arb->handler;
			handler->separateFunc(arb, context->space, handler->userData);
		}
		
		cpArbiterUnthread(arb);
		cpArrayDeleteObj(context->space->arbiters, arb);
		cpArrayPush(context->space->pooledArbiters, arb);
		
		return cpFalse;
	}
	
	return cpTrue;
}

void
cpSpaceFilterArbiters(cpSpace *space, cpBody *body, cpShape *filter)
{
	cpSpaceLock(space); {
		struct arbiterFilterContext context = {space, body, filter};
		cpHashSetFilter(space->cachedArbiters, (cpHashSetFilterFunc)cachedArbitersFilter, &context);
	} cpSpaceUnlock(space, cpTrue);
}

void
cpSpaceRemoveShape(cpSpace *space, cpShape *shape)
{
	cpBody *body = shape->body;
	cpAssertHard(cpSpaceContainsShape(space, shape), "Cannot remove a shape that was not added to the space. (Removed twice maybe?)");
	cpAssertSpaceUnlocked(space);
	
	cpBool isStatic = (cpBodyGetType(body) == CP_BODY_TYPE_STATIC);
	if(isStatic){
		cpBodyActivateStatic(body, shape);
	} else {
		cpBodyActivate(body);
	}

	cpBodyRemoveShape(body, shape);
	cpSpaceFilterArbiters(space, body, shape);
	cpSpatialIndexRemove(isStatic ? space->staticShapes : space->dynamicShapes, shape, shape->hashid);
	shape->space = NULL;
	shape->hashid = 0;
}

void
cpSpaceRemoveBody(cpSpace *space, cpBody *body)
{
	cpAssertHard(body != cpSpaceGetStaticBody(space), "Cannot remove the designated static body for the space.");
	cpAssertHard(cpSpaceContainsBody(space, body), "Cannot remove a body that was not added to the space. (Removed twice maybe?)");
//	cpAssertHard(body->shapeList == NULL, "Cannot remove a body from the space before removing the bodies attached to it.");
//	cpAssertHard(body->constraintList == NULL, "Cannot remove a body from the space before removing the constraints attached to it.");
	cpAssertSpaceUnlocked(space);
	
	cpBodyActivate(body);
//	cpSpaceFilterArbiters(space, body, NULL);
	cpArrayDeleteObj(cpSpaceArrayForBodyType(space, cpBodyGetType(body)), body);
	body->space = NULL;
}

void
cpSpaceRemoveConstraint(cpSpace *space, cpConstraint *constraint)
{
	cpAssertHard(cpSpaceContainsConstraint(space, constraint), "Cannot remove a constraint that was not added to the space. (Removed twice maybe?)");
	cpAssertSpaceUnlocked(space);
	
	cpBodyActivate(constraint->a);
	cpBodyActivate(constraint->b);
	cpArrayDeleteObj(space->constraints, constraint);
	
	cpBodyRemoveConstraint(constraint->a, constraint);
	cpBodyRemoveConstraint(constraint->b, constraint);
	constraint->space = NULL;
}

cpBool cpSpaceContainsShape(cpSpace *space, cpShape *shape)
{
	return (shape->space == space);
}

cpBool cpSpaceContainsBody(cpSpace *space, cpBody *body)
{
	return (body->space == space);
}

cpBool cpSpaceContainsConstraint(cpSpace *space, cpConstraint *constraint)
{
	return (constraint->space == space);
}

//MARK: Iteration

void
cpSpaceEachBody(cpSpace *space, cpSpaceBodyIteratorFunc func, void *data)
{
	cpSpaceLock(space); {
		cpArray *bodies = space->dynamicBodies;
		for(int i=0; i<bodies->num; i++){
			func((cpBody *)bodies->arr[i], data);
		}
		
		cpArray *otherBodies = space->staticBodies;
		for(int i=0; i<otherBodies->num; i++){
			func((cpBody *)otherBodies->arr[i], data);
		}
		
		cpArray *components = space->sleepingComponents;
		for(int i=0; i<components->num; i++){
			cpBody *root = (cpBody *)components->arr[i];
			
			cpBody *body = root;
			while(body){
				cpBody *next = body->sleeping.next;
				func(body, data);
				body = next;
			}
		}
	} cpSpaceUnlock(space, cpTrue);
}

typedef struct spaceShapeContext {
	cpSpaceShapeIteratorFunc func;
	void *data;
} spaceShapeContext;

static void
spaceEachShapeIterator(cpShape *shape, spaceShapeContext *context)
{
	context->func(shape, context->data);
}

void
cpSpaceEachShape(cpSpace *space, cpSpaceShapeIteratorFunc func, void *data)
{
	cpSpaceLock(space); {
		spaceShapeContext context = {func, data};
		cpSpatialIndexEach(space->dynamicShapes, (cpSpatialIndexIteratorFunc)spaceEachShapeIterator, &context);
		cpSpatialIndexEach(space->staticShapes, (cpSpatialIndexIteratorFunc)spaceEachShapeIterator, &context);
	} cpSpaceUnlock(space, cpTrue);
}

void
cpSpaceEachConstraint(cpSpace *space, cpSpaceConstraintIteratorFunc func, void *data)
{
	cpSpaceLock(space); {
		cpArray *constraints = space->constraints;
		
		for(int i=0; i<constraints->num; i++){
			func((cpConstraint *)constraints->arr[i], data);
		}
	} cpSpaceUnlock(space, cpTrue);
}

//MARK: Spatial Index Management

void 
cpSpaceReindexStatic(cpSpace *space)
{
	cpAssertHard(!space->locked, "You cannot manually reindex objects while the space is locked. Wait until the current query or step is complete.");
	
	cpSpatialIndexEach(space->staticShapes, (cpSpatialIndexIteratorFunc)&cpShapeUpdateFunc, NULL);
	cpSpatialIndexReindex(space->staticShapes);
}

void
cpSpaceReindexShape(cpSpace *space, cpShape *shape)
{
	cpAssertHard(!space->locked, "You cannot manually reindex objects while the space is locked. Wait until the current query or step is complete.");
	
	cpShapeCacheBB(shape);
	
	// attempt to rehash the shape in both hashes
	cpSpatialIndexReindexObject(space->dynamicShapes, shape, shape->hashid);
	cpSpatialIndexReindexObject(space->staticShapes, shape, shape->hashid);
}

void
cpSpaceReindexShapesForBody(cpSpace *space, cpBody *body)
{
	CP_BODY_FOREACH_SHAPE(body, shape) cpSpaceReindexShape(space, shape);
}


static void
copyShapes(cpShape *shape, cpSpatialIndex *index)
{
	cpSpatialIndexInsert(index, shape, shape->hashid);
}

void
cpSpaceUseSpatialHash(cpSpace *space, cpFloat dim, int count)
{
	cpSpatialIndex *staticShapes = cpSpaceHashNew(dim, count, (cpSpatialIndexBBFunc)cpShapeGetBB, NULL);
	cpSpatialIndex *dynamicShapes = cpSpaceHashNew(dim, count, (cpSpatialIndexBBFunc)cpShapeGetBB, staticShapes);
	
	cpSpatialIndexEach(space->staticShapes, (cpSpatialIndexIteratorFunc)copyShapes, staticShapes);
	cpSpatialIndexEach(space->dynamicShapes, (cpSpatialIndexIteratorFunc)copyShapes, dynamicShapes);
	
	cpSpatialIndexFree(space->staticShapes);
	cpSpatialIndexFree(space->dynamicShapes);
	
	space->staticShapes = staticShapes;
	space->dynamicShapes = dynamicShapes;
}
