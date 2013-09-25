/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Scott Lembcke
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCNode.h"
#import "CCScene.h"
#import "ObjectiveChipmunk/ObjectiveChipmunk.h"

// For comparison:
// https://developer.apple.com/library/ios/documentation/SpriteKit/Reference/SpriteKitFramework_Ref/_index.html#//apple_ref/doc/uid/TP40013041

// TODO and consider:
// * Collision only mode
// * Sensors
// * Interpolation?
// * Post-step callbacks?
// * Projectile bodies?
// * Body queries?


@class CCPhysicsCollisionPair;


/// Basic rigid body type.
@interface CCPhysicsBody : NSObject

//MARK: Constructors:

/// Create a circular body.
+(CCPhysicsBody *)bodyWithCircleOfRadius:(CGFloat)radius andCenter:(CGFloat)center;
/// Create a box shaped body with rounded corners.
+(CCPhysicsBody *)bodyWithRectangle:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
/// Create a pill shaped body with rounded corners that stretches from 'start' to 'end'.
+(CCPhysicsBody *)bodyWithPillWithStart:(CGPoint)start end:(CGPoint)end cornerRadius:(CGFloat)cornerRadius;
/// Create a convex polygon shaped body with rounded corners.
/// If the points do not form a convex polygon, then a convex hull will be created for them automatically.
+(CCPhysicsBody *)bodyWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;

// Be careful with dynamic segment-based bodies.
// Because the segments are allowed to be very thin, it can cause problems with collision detection.

/// Create a closed segment-based body from a series of points and the given corner radius.
+(CCPhysicsBody *)bodyWithSegmentLoopFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;
/// Create an open ended segment-based body from a series of points and the given corner radius.
+(CCPhysicsBody *)bodyWithSegmentChainFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;

//MARK: Basic Properties:

/// Mass of the physics body.
/// Changing this property also changes the density.
/// Defaults to 1.0.
@property(nonatomic, assign) CGFloat mass;
/// Density of the physics body.
/// Changing this property also changes the mass.
@property(nonatomic, assign) CGFloat density;
/// Surface area of the physics body.
@property(nonatomic, readonly) CGFloat area;
/// Surface friction of the physics body.
/// When two objects collide, their friction is multiplied together.
/// The calculated value can be overriden in a CCCollisionPairDelegate pre-solve method.
@property(nonatomic, assign) CGFloat friction;
/// Surface friction of the physics body.
/// When two objects collide, their elaticity is multiplied together.
/// The calculated value can be ovrriden in a CCCollisionPairDelegate pre-solve method.
@property(nonatomic, assign) CGFloat elasticity;
/// Velocity of the surface of the object relative to it's normal velocity.
/// This is useful for modeling conveyor belts or the feet of a player character.
/// The calculated surface velocity of two colliding shapes by default only affects their friction.
/// The calculated value can be overriden in a CCCollisionPairDelegate pre-solve method.
@property(nonatomic, assign) CGPoint surfaceVelocity;

//MARK: Simulation Properties:

/// Whether or not the physics body is affected by gravity.
@property(nonatomic, assign) BOOL affectedByGravity;
/// Whether or not the physics body should be allowed to rotate.
@property(nonatomic, assign) BOOL allowsRotation;
/// Whether or not the physics body is dynamic or static.
/// Static physics bodies are immovable. (Like the ground or a wall).
@property(nonatomic, assign) BOOL dynamic;

//MARK: Collision and Contact:

/// If two physics bodies share the same group object, then they don't collide.
@property(nonatomic, assign) id collisionGroup;
/// A string that identifies which collision pair delegate method should be called.
@property(nonatomic, copy) NSString *collisionType;
/// An array of NSStrings of category names this physics body is a member of.
/// Up to 32 categories can be used in a single scene.
/// The default value is nil, which means the physics body exists in all categories.
@property(nonatomic, copy) NSArray *collisionCategories;
/// An array of NSStrings of category names this physics body will collide with.
/// The default value is nil, which means the physics body collides with all categories.
// TODO this is a bad, low level name.
@property(nonatomic, copy) NSArray *collisionBitmask;

/// Iterate over all of the CCPhysicsCollisionPairs this body is currently in contact with.
/// NOTE: The CCPhysicsCollisionPair object is shared and you should not store a reference to it.
-(void)eachContactPair:(void (^)(CCPhysicsCollisionPair *pair))block;

//MARK: Velocity:

/// The velocity of the body in absolute coordinates.
@property(nonatomic, assign) CGPoint velocity;
/// Angular velocity of the body in radians per second.
// TODO should match Cocos2D's degrees instead?
@property(nonatomic, assign) CGFloat angularVelocity;

//MARK: Forces, Torques and Impulses:

/// Linear force applied to the body this fixed timestep.
@property(nonatomic, assign) CGPoint force;
/// Torque applied to the body this fixed timestep.
@property(nonatomic, assign) CGFloat torque;

/// Accumulate a torque on the body.
-(void)applyTorque:(CGPoint)force;

/// Accumulate a force on the body.
-(void)applyForce:(CGPoint)force;
/// Accumulate force and torque on the body from a force applied at point in the parent CCNode's coordinates.
/// The force will be rotated by, but not scaled by the CCNode's transform.
-(void)applyForce:(CGPoint)force atLocalPoint:(CGPoint)point;
/// Accumulate force and torque on the body from a force applied at point in absolute coordinates.
-(void)applyForce:(CGPoint)force atWorldPoint:(CGPoint)point;

// Impulses immediately change the velocity and angular velocity of a physics body as if a very sudden force happened.
// This works well for applying recoil from firing a projectile, applying custom collision forces, or jumping a character.

/// Apply an angular impulse
-(void)applyAngularImpulse:(CGFloat)impulse;

/// Accumulate an impulse on the body.
-(void)applyImpulse:(CGPoint)impulse;
/// Accumulate an impulse and angular impulse on the body from an impulse applied at point in the parent CCNode's coordinates.
/// The impulse will be rotated by, but not scaled by the CCNode's transform.
-(void)applyImpulse:(CGPoint)impulse atLocalPoint:(CGPoint)point;
/// Accumulate an impulse and angular impulse on the body from an impulse applied at point in absolute coordinates.
-(void)applyImpulse:(CGPoint)impulse atWorldPoint:(CGPoint)point;

//MARK: Misc.

/// Joints connected to this body.
@property(nonatomic, readonly) NSArray *joints;

/// Sleeping bodies are not simulated and use minimal CPU resources.
/// Normally bodies fall asleep automatically when they stop moving, but you can trigger sleeping explicity.
@property(nonatomic, assign) BOOL sleeping;

/// The CCNode this physics body is attached to.
@property(nonatomic, readonly) CCNode *node;

@end


@interface CCPhysicsJoint : NSObject

/// The first body this joint is attached to.
@property(nonatomic, strong) CCPhysicsBody *bodyA;
/// The second body this joint is attached to.
@property(nonatomic, strong) CCPhysicsBody *bodyB;

/// The maximum force this joint is allowed to use.
/// Defaults to INFINITY.
@property(nonatomic, assign) CGFloat maxForce;
/// The maximum speed this joint is allowed to fix any stretching at in absolute coordinates or radians (depending on the joint).
/// Defaults to INFINITY.
@property(nonatomic, assign) CGFloat maxBias;

/// Depending on the joint, either the magnitude of the linear or angular impulse that this joint applied on the previous fixed time step.
@property(nonatomic, readonly) CGFloat impulse;

/// Whether the joint is active or not.
/// NOTE: Be careful when reactivating a joint if the two bodies have drifted apart. It will cause them to snap back together.
@property(nonatomic, assign) BOOL enabled;

/// Maximum force that can be applied before the joint disables itself.
/// To avoid problems with round-off errors, make sure that this value is lower than CCPhysicsJoint.maxForce.
/// Defaults to INFINITY.
@property(nonatomic, assign) CGFloat breakingForce;

@end


/// Contains information about colliding physics bodies.
/// NOTE: There is only one CCPhysicsCollisionPair object per scene and it's reused.
/// Only use the CCPhysicsCollisionPair object in the method or block it was given to you in.
@interface CCPhysicsCollisionPair : NSObject

/// The contact information from the two colliding bodies.
@property(nonatomic, readonly) cpContactPointSet contacts;

/// Ignore the collision between these two physics bodies until they stop colliding.
/// It's idomatic to write "return [pair ignore];" if using this method from a CCCollisionPairDelegate pre-solve method.
/// Always returns false.
-(BOOL)ignore;

/// The friction coefficient for this pair of colliding bodies.
/// The default value is pair.bodyA.friction*pair.bodyB.friction.
/// Can be overriden in a CCCollisionPairDelegate pre-solve method to change the collision.
@property(nonatomic, assign) CGFloat friction;
/// The restitution coefficient for this pair of colliding bodies.
/// The default value is "pair.bodyA.elasticity*pair.bodyB.elasticity".
/// Can be overriden in a CCCollisionPairDelegate pre-solve method to change the collision.
@property(nonatomic, assign) CGFloat restitution;
/// The relative surface velocities of the two colliding shapes.
/// The default value is TODO
/// Can be overriden in a CCCollisionPairDelegate pre-solve method to change the collision.
@property(nonatomic, assign) CGFloat surfaceVelocity;

// NOTE: The following two methods return the value from the previous collision.
// They are intended to be called from a CCPhysicsCollisionPairDelegate post-solve method or from a [CCPhysicsBody eachContactPair:] block.
// TODO Is it possible to make a warning for this?

/// The amount of kinetic energy disappated by the last collision of the two bodies.
/// This is roughly equivalent to the idea of damage.
/// NOTE: By definition, fully elastic collisions do not lose any energy or cause any permanent damage.
@property(nonatomic, readonly) CGFloat totalKineticEnergy;
/// The total impulse applied by this collision to the colliding bodies.
@property(nonatomic, readonly) CGPoint totalImpulse;

/// A persistent object reference associated with these two colliding objects.
/// If you want to store some information about a collision from time step to time step, store it here.
// TODO Possible to add a default to release it automatically?
@property(nonatomic, assign) id userData;



@end

/// Delegate type called when two physics bodies collide.
/// The final two parameter names should be replaced with strings used with CCPhysicsBody.collisionType.
/// If both final parameter names are "default" then the method is called when a more specific method isn't found.
/// "wildcard" can be used as the final parameter name to mean "collides with anything".
@protocol CCPhysicsCollisionPairDelegate

@optional
/// Begin methods are called on the first fixed time step when two bodies begin colliding.
/// If you return NO from a begin method, the collision between the two bodies will be ignored.
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair typeA:(CCPhysicsBody *)bodyA typeB:(CCPhysicsBody *)bodyB;
/// Pre-solve methods are called every fixed time step when two bodies are in contact before the physics solver runs.
/// You can call use properties such as friction, restitution, surfaceVelocity on CCPhysicsCollisionPair from a post-solve method.
/// If you return NO from a pre-solve method, the collision will be ignored for the current time step.
-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair player:(CCPhysicsBody *)bodyA monster:(CCPhysicsBody *)bodyB;
/// Post-solve methods are called every fixed time step when two bodies are in contact after the physics solver runs.
/// You can call use properties such as totalKineticEnergy and totalImpulse on CCPhysicsCollisionPair from a post-solve method.
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair player:(CCPhysicsBody *)bodyA wildcard:(CCPhysicsBody *)bodyB;
/// Separate methods are called the first fixed time step after two bodies stop colliding.
-(void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair default:(CCPhysicsBody *)bodyA default:(CCPhysicsBody *)bodyB;

@end


@interface CCPhysicsSpace : NSObject

/// Gravity applied to the dynamic bodies in the world.
/// Defaults to CGPointZero.
@property(nonatomic, assign) CGPoint gravity;

/// The delegate that is called when two physics bodies collide.
@property(nonatomic, assign) id<CCPhysicsCollisionPairDelegate> delegate;

/// Physics bodies fall asleep when a group of them move slowly for longer than the threshold.
/// Sleeping bodies use minimal CPU resources and wake automatically when a collision happens.
/// Defaults to 0.5 seconds.
@property(nonatomic, assign) ccTime sleepTimeThreshold;

// TODO think about these more.
// More variations? Filtering? thickness?
-(CCPhysicsBody *)rayQueryFirstFrom:(CGPoint)start to:(CGPoint)end block:(BOOL (^)(CCPhysicsBody *body, CGPoint point, CGPoint normal, CGFloat distance))block;
-(CCPhysicsBody *)pointQueryAt:(CGPoint)point within:(CGFloat)radius block:(BOOL (^)(CCPhysicsBody *body, CGPoint nearest, CGFloat distance))block;
-(BOOL)rectQuery:(CGRect)rect block:(BOOL (^)(CCPhysicsBody *body))block;
// Unsure about this one.
//-(BOOL)bodyQuery:(CCPhysicsBody *)body withPosition:(CGPoint)position rotation:(CGFloat)rotation block:(BOOL (^)(ChipmunkBody *bodyB, cpContactPointSet))block;

@end


//MARK: Extention categories:

@interface CCNode(CCPhysics)

/// The scene this node is attached to.
@property(nonatomic, readonly) CCScene *scene;

/// The CCPhysicsBody (if any) that is attached to this CCNode.
@property(nonatomic, strong) CCPhysicsBody *physicsBody;

@end


@interface CCScene(CCPhysics)

/// The CCPhysicsSpace associated with this scene.
@property(nonatomic, readonly) CCPhysicsSpace *physicsWorld;

@end
