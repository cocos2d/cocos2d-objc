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

@class ChipmunkShape;
@class ChipmunkConstraint;

/**
	Rigid bodies are the basic unit of simulation in Chipmunk.
	They hold the physical properties of an object (mass, position, rotation, velocity, etc.). After creating a ChipmunkBody object, you can attach collision shapes (ChipmunkShape) and joints (ChipmunkConstraint) to it.
*/
@interface ChipmunkBody : NSObject <ChipmunkBaseObject>

/// Get the ChipmunkBody object associciated with a cpBody pointer.
/// Undefined if the cpBody wasn't created using Objective-Chipmunk.
+(ChipmunkBody *)bodyFromCPBody:(cpBody *)body;

/**
  Create an autoreleased rigid body with the given mass and moment.
  Guessing the moment of inertia is usually a bad idea. Use the moment estimation functions (cpMomentFor*()).
*/
+ (id)bodyWithMass:(cpFloat)mass andMoment:(cpFloat)moment;

/**
  Create an autoreleased static body.
*/
+ (id)staticBody;

/**
  Create an autoreleased kinematic body.
*/
+ (id)kinematicBody;

/**
  Initialize a rigid body with the given mass and moment of inertia.
  Guessing the moment of inertia is usually a bad idea. Use the moment estimation functions (cpMomentFor*()).
*/
- (id)initWithMass:(cpFloat)mass andMoment:(cpFloat)moment;

/// Type of the body (dynamic, kinematic, static).
@property(nonatomic, assign) cpBodyType type;

/// Mass of the rigid body. Mass does not have to be expressed in any particular units, but relative masses should be consistent.
@property(nonatomic, assign) cpFloat mass;

/// Moment of inertia of the body. The mass tells you how hard it is to push an object, the MoI tells you how hard it is to spin the object. Don't try to guess the MoI, use the cpMomentFor*() functions to try and estimate it.
@property(nonatomic, assign) cpFloat moment;

/// Location of the body's center of gravity relative to it's position. Defaults to @c cpvzero.
@property(nonatomic, assign) cpVect centerOfGravity;

/// The position of the rigid body's center of gravity.
@property(nonatomic, assign) cpVect position;

/// The linear velocity of the rigid body.
@property(nonatomic, assign) cpVect velocity;

/// The linear force applied to the rigid body. Unlike in some physics engines, the force does not reset itself during each step. Make sure that you are reseting the force between frames if that is what you intended.
@property(nonatomic, assign) cpVect force;

/// The rotation angle of the rigid body in radians.
@property(nonatomic, assign) cpFloat angle;

/// The angular velocity of the rigid body in radians per second.
@property(nonatomic, assign) cpFloat angularVelocity;

/// The torque being applied to the rigid body. Like force, this property is not reset every frame.
@property(nonatomic, assign) cpFloat torque;

/// The rigid transform of the body.
@property(nonatomic, readonly) cpTransform transform;

/// Returns a pointer to the underlying cpBody C struct.
@property(nonatomic, readonly) cpBody *body;

/**
	An object that this constraint is associated with. You can use this get a reference to your game object or controller object from within callbacks.
	@attention Like most @c delegate properties this is a weak reference and does not call @c retain. This prevents reference cycles from occuring.
*/
@property(nonatomic, assign) id userData;

/// Has the body been put to sleep by the space?
@property(nonatomic, readonly) bool isSleeping;

/// Get the kinetic energy of this body.
@property(nonatomic, readonly) cpFloat kineticEnergy;

/// Get the space the body is added to.
@property(nonatomic, readonly) ChipmunkSpace *space;

/**
  Convert from body local to world coordinates.
  Convert a point in world (absolute) coordinates to body local coordinates affected by the position and rotation of the rigid body.
*/
- (cpVect)localToWorld:(cpVect)v;

/**
  Convert from world to body local Coordinates.
  Convert a point in body local coordinates coordinates to world (absolute) coordinates.
*/
- (cpVect)worldToLocal:(cpVect)v;

/**
	Get the velocity of a point on a body.
	Get the world (absolute) velocity of a point on a rigid body specified in body local coordinates.
*/
- (cpVect)velocityAtLocalPoint:(cpVect)p;

/**
	Get the velocity of a point on a body.
	Get the world (absolute) velocity of a point on a rigid body specified in world coordinates.
*/
- (cpVect)velocityAtWorldPoint:(cpVect)p;

/**
  Apply a force to a rigid body. An offset of cpvzero is equivalent to adding directly to the force property.
  @param force A force in expressed in absolute (word) coordinates.
	@param offset An offset expressed in world coordinates. Note that it is still an offset, meaning that it's position is relative, but the rotation is not.
*/
- (void)applyForce:(cpVect)force atLocalPoint:(cpVect)point;
- (void)applyForce:(cpVect)force atWorldPoint:(cpVect)point;

/**
  Apply an impulse to a rigid body.
  @param impulse An impulse in expressed in absolute (word) coordinates.
	@param offset An offset expressed in world coordinates. Note that it is still an offset, meaning that it's position is relative, but the rotation is not.
*/
- (void)applyImpulse:(cpVect)impulse atLocalPoint:(cpVect)point;
- (void)applyImpulse:(cpVect)impulse atWorldPoint:(cpVect)point;

/// Wake up the body if it's sleeping, or reset the idle timer if it's active.
- (void)activate;

/// Wake up any bodies touching a static body through shape @c filter Pass @c nil for @c filter to away all touching bodies.
- (void)activateStatic:(ChipmunkShape *)filter;

/**
	Force the body to sleep immediately. The body will be added to the same group as @c group. When any object in a group is woken up, all of the bodies are woken up with it.
	If @c group is nil, then a new group is created and the body is added to it. It is an error pass a non-sleeping body as @c group.
	This is useful if you want an object to be inactive until something hits it such as a pile of boxes you want the player to plow through or a stalactite hanging from a cave ceiling.
	Make sure the body is fully set up before you call this. Adding this body or any shapes or constraints attached to it to a space, or modifying any of their properties automatically wake a body up.
*/
- (void)sleepWithGroup:(ChipmunkBody *)group;

/**
	Equivalent to [ChipmunkBody sleepWithGroup:nil]. That is the object is forced to sleep immediately, but is not grouped with any other sleeping bodies.
*/
- (void)sleep;

/// Get a list of shapes that are attached to this body and currently added to a space.
- (NSArray *)shapes;

/// Get a list of constraints that are attached to this body and currently added to a space.
- (NSArray *)constraints;

/// Body/arbiter iterator callback block type.
typedef void (^ChipmunkBodyArbiterIteratorBlock)(cpArbiter *arbiter);

/// Call @c block once for each arbiter that is currently active on the body.
- (void)eachArbiter:(ChipmunkBodyArbiterIteratorBlock)block;

/// Implements the ChipmunkBaseObject protocol, not particularly useful outside of the library code
- (void)addToSpace:(ChipmunkSpace *)space;
/// Implements the ChipmunkBaseObject protocol, not particularly useful outside of the library code
- (void)removeFromSpace:(ChipmunkSpace *)space;

/// Override this to change the way that the body's velocity is integrated.
/// You should either understand how the cpBodyUpdateVelocity() function works, or use the super method.
-(void)updateVelocity:(cpFloat)dt gravity:(cpVect)gravity damping:(cpFloat)damping;

/// OVerride this to change the way that the body's position is intgrated.
/// You should either understand how the cpBodyUpdatePosition() function works, or use the super method.
-(void)updatePosition:(cpFloat)dt;

@end
