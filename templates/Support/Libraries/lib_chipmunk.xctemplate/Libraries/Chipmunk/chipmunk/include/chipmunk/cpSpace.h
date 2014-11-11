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

/// @defgroup cpSpace cpSpace
/// @{

//MARK: Definitions

typedef struct cpContactBufferHeader cpContactBufferHeader;
typedef void (*cpSpaceArbiterApplyImpulseFunc)(cpArbiter *arb);

/// Collision begin event function callback type.
/// Returning false from a begin callback causes the collision to be ignored until
/// the the separate callback is called when the objects stop colliding.
typedef cpBool (*cpCollisionBeginFunc)(cpArbiter *arb, cpSpace *space, cpDataPointer userData);
/// Collision pre-solve event function callback type.
/// Returning false from a pre-step callback causes the collision to be ignored until the next step.
typedef cpBool (*cpCollisionPreSolveFunc)(cpArbiter *arb, cpSpace *space, cpDataPointer userData);
/// Collision post-solve event function callback type.
typedef void (*cpCollisionPostSolveFunc)(cpArbiter *arb, cpSpace *space, cpDataPointer userData);
/// Collision separate event function callback type.
typedef void (*cpCollisionSeparateFunc)(cpArbiter *arb, cpSpace *space, cpDataPointer userData);

struct cpCollisionHandler {
	const cpCollisionType typeA, typeB;
	cpCollisionBeginFunc beginFunc;
	cpCollisionPreSolveFunc preSolveFunc;
	cpCollisionPostSolveFunc postSolveFunc;
	cpCollisionSeparateFunc separateFunc;
	cpDataPointer userData;
};

// TODO: Make timestep a parameter?


//MARK: Memory and Initialization

/// Allocate a cpSpace.
cpSpace* cpSpaceAlloc(void);
/// Initialize a cpSpace.
cpSpace* cpSpaceInit(cpSpace *space);
/// Allocate and initialize a cpSpace.
cpSpace* cpSpaceNew(void);

/// Destroy a cpSpace.
void cpSpaceDestroy(cpSpace *space);
/// Destroy and free a cpSpace.
void cpSpaceFree(cpSpace *space);


//MARK: Properties

/// Number of iterations to use in the impulse solver to solve contacts and other constraints.
int cpSpaceGetIterations(const cpSpace *space);
void cpSpaceSetIterations(cpSpace *space, int iterations);

/// Gravity to pass to rigid bodies when integrating velocity.
cpVect cpSpaceGetGravity(const cpSpace *space);
void cpSpaceSetGravity(cpSpace *space, cpVect gravity);

/// Damping rate expressed as the fraction of velocity bodies retain each second.
/// A value of 0.9 would mean that each body's velocity will drop 10% per second.
/// The default value is 1.0, meaning no damping is applied.
/// @note This damping value is different than those of cpDampedSpring and cpDampedRotarySpring.
cpFloat cpSpaceGetDamping(const cpSpace *space);
void cpSpaceSetDamping(cpSpace *space, cpFloat damping);

/// Speed threshold for a body to be considered idle.
/// The default value of 0 means to let the space guess a good threshold based on gravity.
cpFloat cpSpaceGetIdleSpeedThreshold(const cpSpace *space);
void cpSpaceSetIdleSpeedThreshold(cpSpace *space, cpFloat idleSpeedThreshold);

/// Time a group of bodies must remain idle in order to fall asleep.
/// Enabling sleeping also implicitly enables the the contact graph.
/// The default value of INFINITY disables the sleeping algorithm.
cpFloat cpSpaceGetSleepTimeThreshold(const cpSpace *space);
void cpSpaceSetSleepTimeThreshold(cpSpace *space, cpFloat sleepTimeThreshold);

/// Amount of encouraged penetration between colliding shapes.
/// Used to reduce oscillating contacts and keep the collision cache warm.
/// Defaults to 0.1. If you have poor simulation quality,
/// increase this number as much as possible without allowing visible amounts of overlap.
cpFloat cpSpaceGetCollisionSlop(const cpSpace *space);
void cpSpaceSetCollisionSlop(cpSpace *space, cpFloat collisionSlop);

/// Determines how fast overlapping shapes are pushed apart.
/// Expressed as a fraction of the error remaining after each second.
/// Defaults to pow(1.0 - 0.1, 60.0) meaning that Chipmunk fixes 10% of overlap each frame at 60Hz.
cpFloat cpSpaceGetCollisionBias(const cpSpace *space);
void cpSpaceSetCollisionBias(cpSpace *space, cpFloat collisionBias);

/// Number of frames that contact information should persist.
/// Defaults to 3. There is probably never a reason to change this value.
cpTimestamp cpSpaceGetCollisionPersistence(const cpSpace *space);
void cpSpaceSetCollisionPersistence(cpSpace *space, cpTimestamp collisionPersistence);

/// User definable data pointer.
/// Generally this points to your game's controller or game state
/// class so you can access it when given a cpSpace reference in a callback.
cpDataPointer cpSpaceGetUserData(const cpSpace *space);
void cpSpaceSetUserData(cpSpace *space, cpDataPointer userData);

/// The Space provided static body for a given cpSpace.
/// This is merely provided for convenience and you are not required to use it.
cpBody* cpSpaceGetStaticBody(const cpSpace *space);

/// Returns the current (or most recent) time step used with the given space.
/// Useful from callbacks if your time step is not a compile-time global.
cpFloat cpSpaceGetCurrentTimeStep(const cpSpace *space);

/// returns true from inside a callback when objects cannot be added/removed.
cpBool cpSpaceIsLocked(cpSpace *space);


//MARK: Collision Handlers

cpCollisionHandler *cpSpaceAddDefaultCollisionHandler(cpSpace *space);
cpCollisionHandler *cpSpaceAddCollisionHandler(cpSpace *space, cpCollisionType a, cpCollisionType b);
cpCollisionHandler *cpSpaceAddWildcardHandler(cpSpace *space, cpCollisionType type);


//MARK: Add/Remove objects

/// Add a collision shape to the simulation.
/// If the shape is attached to a static body, it will be added as a static shape.
cpShape* cpSpaceAddShape(cpSpace *space, cpShape *shape);
/// Add a rigid body to the simulation.
cpBody* cpSpaceAddBody(cpSpace *space, cpBody *body);
/// Add a constraint to the simulation.
cpConstraint* cpSpaceAddConstraint(cpSpace *space, cpConstraint *constraint);

/// Remove a collision shape from the simulation.
void cpSpaceRemoveShape(cpSpace *space, cpShape *shape);
/// Remove a rigid body from the simulation.
void cpSpaceRemoveBody(cpSpace *space, cpBody *body);
/// Remove a constraint from the simulation.
void cpSpaceRemoveConstraint(cpSpace *space, cpConstraint *constraint);

/// Test if a collision shape has been added to the space.
cpBool cpSpaceContainsShape(cpSpace *space, cpShape *shape);
/// Test if a rigid body has been added to the space.
cpBool cpSpaceContainsBody(cpSpace *space, cpBody *body);
/// Test if a constraint has been added to the space.
cpBool cpSpaceContainsConstraint(cpSpace *space, cpConstraint *constraint);

//MARK: Post-Step Callbacks

/// Post Step callback function type.
typedef void (*cpPostStepFunc)(cpSpace *space, void *key, void *data);
/// Schedule a post-step callback to be called when cpSpaceStep() finishes.
/// You can only register one callback per unique value for @c key.
/// Returns true only if @c key has never been scheduled before.
/// It's possible to pass @c NULL for @c func if you only want to mark @c key as being used.
cpBool cpSpaceAddPostStepCallback(cpSpace *space, cpPostStepFunc func, void *key, void *data);


//MARK: Queries

// TODO: Queries and iterators should take a cpSpace parametery.
// TODO: They should also be abortable.

/// Nearest point query callback function type.
typedef void (*cpSpacePointQueryFunc)(cpShape *shape, cpVect point, cpFloat distance, cpVect gradient, void *data);
/// Query the space at a point and call @c func for each shape found.
void cpSpacePointQuery(cpSpace *space, cpVect point, cpFloat maxDistance, cpShapeFilter filter, cpSpacePointQueryFunc func, void *data);
/// Query the space at a point and return the nearest shape found. Returns NULL if no shapes were found.
cpShape *cpSpacePointQueryNearest(cpSpace *space, cpVect point, cpFloat maxDistance, cpShapeFilter filter, cpPointQueryInfo *out);

/// Segment query callback function type.
typedef void (*cpSpaceSegmentQueryFunc)(cpShape *shape, cpVect point, cpVect normal, cpFloat alpha, void *data);
/// Perform a directed line segment query (like a raycast) against the space calling @c func for each shape intersected.
void cpSpaceSegmentQuery(cpSpace *space, cpVect start, cpVect end, cpFloat radius, cpShapeFilter filter, cpSpaceSegmentQueryFunc func, void *data);
/// Perform a directed line segment query (like a raycast) against the space and return the first shape hit. Returns NULL if no shapes were hit.
cpShape *cpSpaceSegmentQueryFirst(cpSpace *space, cpVect start, cpVect end, cpFloat radius, cpShapeFilter filter, cpSegmentQueryInfo *out);

/// Rectangle Query callback function type.
typedef void (*cpSpaceBBQueryFunc)(cpShape *shape, void *data);
/// Perform a fast rectangle query on the space calling @c func for each shape found.
/// Only the shape's bounding boxes are checked for overlap, not their full shape.
void cpSpaceBBQuery(cpSpace *space, cpBB bb, cpShapeFilter filter, cpSpaceBBQueryFunc func, void *data);

/// Shape query callback function type.
typedef void (*cpSpaceShapeQueryFunc)(cpShape *shape, cpContactPointSet *points, void *data);
/// Query a space for any shapes overlapping the given shape and call @c func for each shape found.
cpBool cpSpaceShapeQuery(cpSpace *space, cpShape *shape, cpSpaceShapeQueryFunc func, void *data);


//MARK: Iteration

/// Space/body iterator callback function type.
typedef void (*cpSpaceBodyIteratorFunc)(cpBody *body, void *data);
/// Call @c func for each body in the space.
void cpSpaceEachBody(cpSpace *space, cpSpaceBodyIteratorFunc func, void *data);

/// Space/body iterator callback function type.
typedef void (*cpSpaceShapeIteratorFunc)(cpShape *shape, void *data);
/// Call @c func for each shape in the space.
void cpSpaceEachShape(cpSpace *space, cpSpaceShapeIteratorFunc func, void *data);

/// Space/constraint iterator callback function type.
typedef void (*cpSpaceConstraintIteratorFunc)(cpConstraint *constraint, void *data);
/// Call @c func for each shape in the space.
void cpSpaceEachConstraint(cpSpace *space, cpSpaceConstraintIteratorFunc func, void *data);


//MARK: Indexing

/// Update the collision detection info for the static shapes in the space.
void cpSpaceReindexStatic(cpSpace *space);
/// Update the collision detection data for a specific shape in the space.
void cpSpaceReindexShape(cpSpace *space, cpShape *shape);
/// Update the collision detection data for all shapes attached to a body.
void cpSpaceReindexShapesForBody(cpSpace *space, cpBody *body);

/// Switch the space to use a spatial has as it's spatial index.
void cpSpaceUseSpatialHash(cpSpace *space, cpFloat dim, int count);


//MARK: Time Stepping

/// Step the space forward in time by @c dt.
void cpSpaceStep(cpSpace *space, cpFloat dt);


//MARK: Debug API

#ifndef CP_SPACE_DISABLE_DEBUG_API

typedef struct cpSpaceDebugColor {
	float r, g, b, a;
} cpSpaceDebugColor;

typedef void (*cpSpaceDebugDrawCircleImpl)(cpVect pos, cpFloat angle, cpFloat radius, cpSpaceDebugColor outlineColor, cpSpaceDebugColor fillColor, cpDataPointer *data);
typedef void (*cpSpaceDebugDrawSegmentImpl)(cpVect a, cpVect b, cpSpaceDebugColor color, cpDataPointer *data);
typedef void (*cpSpaceDebugDrawFatSegmentImpl)(cpVect a, cpVect b, cpFloat radius, cpSpaceDebugColor outlineColor, cpSpaceDebugColor fillColor, cpDataPointer *data);
typedef void (*cpSpaceDebugDrawPolygonImpl)(int count, const cpVect *verts, cpFloat radius, cpSpaceDebugColor outlineColor, cpSpaceDebugColor fillColor, cpDataPointer *data);
typedef void (*cpSpaceDebugDrawDotImpl)(cpFloat size, cpVect pos, cpSpaceDebugColor color, cpDataPointer *data);
typedef cpSpaceDebugColor (*cpSpaceDebugDrawColorForShapeImpl)(cpShape *shape, cpDataPointer *data);

typedef enum cpSpaceDebugDrawFlags {
	CP_SPACE_DEBUG_DRAW_SHAPES = 1<<0,
	CP_SPACE_DEBUG_DRAW_CONSTRAINTS = 1<<1,
	CP_SPACE_DEBUG_DRAW_COLLISION_POINTS = 1<<2,
} cpSpaceDebugDrawFlags;

typedef struct cpSpaceDebugDrawOptions {
	cpSpaceDebugDrawCircleImpl drawCircle;
	cpSpaceDebugDrawSegmentImpl drawSegment;
	cpSpaceDebugDrawFatSegmentImpl drawFatSegment;
	cpSpaceDebugDrawPolygonImpl drawPolygon;
	cpSpaceDebugDrawDotImpl drawDot;
	
	cpSpaceDebugDrawFlags flags;
	cpSpaceDebugColor shapeOutlineColor;
	cpSpaceDebugDrawColorForShapeImpl colorForShape;
	cpSpaceDebugColor constraintColor;
	cpSpaceDebugColor collisionPointColor;
	
	cpDataPointer data;
} cpSpaceDebugDrawOptions;

void cpSpaceDebugDraw(cpSpace *space, cpSpaceDebugDrawOptions *options);

#endif

/// @}
