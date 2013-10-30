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


#warning TODO Need to remove dependency on this.
#import "ObjectiveChipmunk/ObjectiveChipmunk.h"

@class CCPhysicsBody;
@class CCPhysicsShape;

/// Contains information about colliding physics bodies.
/// NOTE: There is only one CCPhysicsCollisionPair object per CCPhysicsNode and it's reused.
/// Only use the CCPhysicsCollisionPair object in the method or block it was given to you in. Do not retain it.
@interface CCPhysicsCollisionPair : NSObject

/// The contact information from the two colliding bodies.
@property(nonatomic, readonly) cpContactPointSet contacts;

/// The friction coefficient for this pair of colliding shapes.
/// The default value is pair.bodyA.friction*pair.bodyB.friction.
/// Can be overriden in a CCCollisionPairDelegate pre-solve method to change the collision.
@property(nonatomic, assign) CGFloat friction;
/// The restitution coefficient for this pair of colliding shapes.
/// The default value is "pair.bodyA.elasticity*pair.bodyB.elasticity".
/// Can be overriden in a CCCollisionPairDelegate pre-solve method to change the collision.
@property(nonatomic, assign) CGFloat restitution;
/// The relative surface velocities of the two colliding shapes.
/// The default value is CGPointZero.
/// Can be overriden in a CCCollisionPairDelegate pre-solve method to change the collision.
@property(nonatomic, assign) CGPoint surfaceVelocity;

// NOTE: The following two methods return the value from the previous collision.
// They are intended to be called from a CCPhysicsCollisionPairDelegate post-solve method or from a [CCPhysicsBody eachContactPair:] block.
// TODO Is it possible to make a warning for this?

/// The amount of kinetic energy dissipated by the last collision of the two shapes.
/// This is roughly equivalent to the idea of damage.
/// NOTE: By definition, fully elastic collisions do not lose any energy or cause any permanent damage.
@property(nonatomic, readonly) CGFloat totalKineticEnergy;
/// The total impulse applied by this collision to the colliding shapes.
@property(nonatomic, readonly) CGPoint totalImpulse;

/// A persistent object reference associated with these two colliding objects.
/// If you want to store some information about a collision from time step to time step, store it here.
// TODO Possible to add a default to release it automatically?
@property(nonatomic, assign) id userData;

/// Retrive the specific physics shapes that were involved in the collision.
-(void)shapeA:(__autoreleasing CCPhysicsShape **)shapeA shapeB:(__autoreleasing CCPhysicsShape **)shapeB;

/// Ignore the collision between these two shapes bodies until they stop colliding.
/// It's idomatic to write "return [pair ignore];" if using this method from a CCCollisionPairDelegate pre-solve method.
/// Always returns false.
-(BOOL)ignore;

@end


/// Delegate type called when two physics bodies collide.
/// The final two parameter names should be replaced with strings used with CCPhysicsBody.collisionType or CCPhysicsShape.collisionType.
/// If both final parameter names are "default" then the method is called when a more specific method isn't found.
/// "wildcard" can be used as the final parameter name to mean "collides with anything".
@protocol CCPhysicsCollisionDelegate

@optional
/// Begin methods are called on the first fixed time step when two bodies begin colliding.
/// If you return NO from a begin method, the collision between the two bodies will be ignored.
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB;
/// Pre-solve methods are called every fixed time step when two bodies are in contact before the physics solver runs.
/// You can call use properties such as friction, restitution, surfaceVelocity on CCPhysicsCollisionPair from a post-solve method.
/// If you return NO from a pre-solve method, the collision will be ignored for the current time step.
-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB;
/// Post-solve methods are called every fixed time step when two bodies are in contact after the physics solver runs.
/// You can call use properties such as totalKineticEnergy and totalImpulse on CCPhysicsCollisionPair from a post-solve method.
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB;
/// Separate methods are called the first fixed time step after two bodies stop colliding.
-(void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB;

@end


@interface CCPhysicsNode : CCNode

/// Should the node draw a debug overlay of the joints and collision shapes?
/// Defaults to NO
@property(nonatomic, assign) BOOL debugDraw;

/// Gravity applied to the dynamic bodies in the world.
/// Defaults to CGPointZero.
@property(nonatomic, assign) CGPoint gravity;

/// Physics bodies fall asleep when a group of them move slowly for longer than the threshold.
/// Sleeping bodies use minimal CPU resources and wake automatically when a collision happens.
/// Defaults to 0.5 seconds.
@property(nonatomic, assign) CCTime sleepTimeThreshold;

/// The delegate that is called when two physics bodies collide.
@property(nonatomic, assign) NSObject<CCPhysicsCollisionDelegate> *collisionDelegate;

/// Find all CCPhysicsShapes within a certain distance of a point.
/// The block is called once for each shape found.
-(void)pointQueryAt:(CGPoint)point within:(CGFloat)radius block:(BOOL (^)(CCPhysicsShape *shape, CGPoint nearest, CGFloat distance))block;

/// Shoot a ray from 'start' to 'end' and find all of the CCPhysicsShapes that it would hit.
/// The block is called once for each shape found.
-(void)rayQueryFirstFrom:(CGPoint)start to:(CGPoint)end block:(BOOL (^)(CCPhysicsShape *shape, CGPoint point, CGPoint normal, CGFloat distance))block;

/// Find all CCPhysicsShapes whose bounding boxes overlap the given CGRect.
/// The block is called once for each shape found.
-(void)rectQuery:(CGRect)rect block:(BOOL (^)(CCPhysicsShape *shape))block;

@end


@interface CCNode(CCPhysics)

/// Nearest CCPhysicsNode ancestor of this node, or nil if none.
/// Unlike CCPhysicsBody.physicsNode, this will return a value before onEnter is called on the node.
-(CCPhysicsNode *)physicsNode;

@end
