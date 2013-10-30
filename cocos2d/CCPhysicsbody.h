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

#import "cocos2d.h"

@class CCPhysicsCollisionPair;

// TODO Are we going to use NSENUM and such? Decided on naming conventions?

/// Used to control how or if a body's position and velocity are updated.
typedef enum ccPhysicsBodyType {
	/// A regular rigid body that is affected by gravity, forces and collisions.
	CCPhysicsBodyTypeDynamic,
	
	/// A body that is immovable by gravity, forces or collisions, but is moved using code.
	CCPhysicsBodyTypeKinematic,
	
	/// A body that never moves such as a wall or the ground.
	CCPhysicsBodyTypeStatic,
} ccPhysicsBodyType;


/// Basic rigid body type.
@interface CCPhysicsBody : NSObject

//MARK: Constructors:

/// Create a circular body.
+(CCPhysicsBody *)bodyWithCircleOfRadius:(CGFloat)radius andCenter:(CGPoint)center;
/// Create a box shaped body with rounded corners.
+(CCPhysicsBody *)bodyWithRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
/// Create a pill shaped body with rounded corners that stretches from 'start' to 'end'.
+(CCPhysicsBody *)bodyWithPillFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius;
/// Create a convex polygon shaped body with rounded corners.
/// If the points do not form a convex polygon, then a convex hull will be created for them automatically.
+(CCPhysicsBody *)bodyWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;

/// Create a body with many pill shapes attached. One for each segment in the polyline.
/// Will default to being a CCPhysicsBodyTypeStatic type body.
/// It is not recommended, though it is possible, to make a polyline based body non-static.
+(CCPhysicsBody *)bodyWithPolylineFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius looped:(bool)looped;

/// Create a body with a number of shapes attached to it.
+(CCPhysicsBody *)bodyWithShapes:(NSArray *)shapes;

//MARK: Basic Properties:

/// Mass of the physics body.
/// If the body has multiple shapes, you cannot change the mass directly.
/// Defaults to 1.0.
@property(nonatomic, assign) CGFloat mass;
/// Surface friction of the physics body.
/// When two objects collide, their friction is multiplied together.
/// The calculated value can be overriden in a CCCollisionPairDelegate pre-solve method.
/// Defaults to 0.7.
@property(nonatomic, assign) CGFloat friction;
/// Surface friction of the physics body.
/// When two objects collide, their elaticity is multiplied together.
/// The calculated value can be ovrriden in a CCCollisionPairDelegate pre-solve method.
/// Defaults to 0.2.
@property(nonatomic, assign) CGFloat elasticity;
/// Velocity of the surface of the object relative to it's normal velocity.
/// This is useful for modeling conveyor belts or the feet of a player character.
/// The calculated surface velocity of two colliding shapes by default only affects their friction.
/// The calculated value can be overriden in a CCCollisionPairDelegate pre-solve method.
/// Defaults to CGPointZero.
@property(nonatomic, assign) CGPoint surfaceVelocity;

//MARK: Simulation Properties:

// Not yet implemented due to time constraints.
///// Whether or not the physics body is affected by gravity.
///// Defaults to YES.
//@property(nonatomic, assign) BOOL affectedByGravity;

/// Whether or not the physics body should be allowed to rotate.
/// Defaults to YES.
@property(nonatomic, assign) BOOL allowsRotation;
/// Whether the physics body is dynamic, kinematic or static.
/// Defaults to CCPhysicsBodyTypeDynamic.
@property(nonatomic, assign) ccPhysicsBodyType type;

//MARK: Collision and Contact:

/// Sensors call collision delegate methods, but don't cause collisions between bodies.
/// Defaults to NO.
@property(nonatomic, assign) BOOL sensor;
/// If two physics bodies share the same group identifier, then they don't collide.
/// Defaults to nil.
@property(nonatomic, assign) id collisionGroup;
/// A string that identifies which collision pair delegate method should be called.
/// Defaults to @"default".
@property(nonatomic, copy) NSString *collisionType;
/// An array of NSStrings of category names of which this physics body is a member.
/// Up to 32 categories can be used in a single scene.
/// The default value is nil, which means the physics body exists in all categories.
@property(nonatomic, copy) NSArray *collisionCategories;
/// An array of NSStrings of category names this physics body will collide with.
/// The default value is nil, which means the physics body collides with all categories.
@property(nonatomic, copy) NSArray *collisionMask;

/// Iterate over all of the CCPhysicsCollisionPairs this body is currently in contact with.
/// NOTE: The CCPhysicsCollisionPair object is shared and you should not store a reference to it.
-(void)eachCollisionPair:(void (^)(CCPhysicsCollisionPair *pair))block;

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

// TODO: Mention this in some other documentation:
// Impulses immediately change the velocity and angular velocity of a physics body as if a very sudden force happened.
// This works well for applying recoil from firing a projectile, applying custom collision forces, or jumping a character.

/// Accumulate a torque on the body.
-(void)applyTorque:(CGFloat)torque;
/// Apply an angular impulse
-(void)applyAngularImpulse:(CGFloat)impulse;

/// Accumulate a force on the body.
-(void)applyForce:(CGPoint)force;
/// Accumulate an impulse on the body.
-(void)applyImpulse:(CGPoint)impulse;

/// Accumulate force and torque on the body from a force applied at point in the parent CCNode's coordinates.
/// The force will be rotated by, but not scaled by the CCNode's transform.
-(void)applyForce:(CGPoint)force atLocalPoint:(CGPoint)point;
/// Accumulate an impulse and angular impulse on the body from an impulse applied at point in the parent CCNode's coordinates.
/// The impulse will be rotated by, but not scaled by the CCNode's transform.
-(void)applyImpulse:(CGPoint)impulse atLocalPoint:(CGPoint)point;

/// Accumulate force and torque on the body from a force applied at point in absolute coordinates.
-(void)applyForce:(CGPoint)force atWorldPoint:(CGPoint)point;
/// Accumulate an impulse and angular impulse on the body from an impulse applied at point in absolute coordinates.
-(void)applyImpulse:(CGPoint)impulse atWorldPoint:(CGPoint)point;

//MARK: Misc.

/// Joints connected to this body.
@property(nonatomic, readonly) NSArray *joints;

/// Sleeping bodies are not simulated and use minimal CPU resources.
/// Normally bodies fall asleep automatically when they stop moving, but you can trigger sleeping explicity.
@property(nonatomic, assign) BOOL sleeping;

/// The CCNode to which this physics body is attached.
@property(nonatomic, readonly) CCNode *node;

@end
