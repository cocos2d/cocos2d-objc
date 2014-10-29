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

/**
 *  A set of contact points returned by CCPhysicsCollisionPair.contacts.
 */
typedef struct CCContactSet {
	// The number of contact points in the set.
	// The count will always be 1 or 2.
	int count;
	
	// The normal of the contact points.
	CGPoint normal;
	
	// The array of contact points.
	struct {
		// The absolute position of the contact on the surface of each shape.
		CGPoint pointA, pointB;
		
		// Penetration distance of the two shapes.
		// The value will always be negative.
		CGFloat distance;
	} points[2];
} CCContactSet;


@class CCPhysicsBody;
@class CCPhysicsShape;

/**
 *  Contains information about two colliding physics objects. See CCPhysicsCollisionDelegate for more information.
 *  
 *  ### Notes
 *  - There is only one CCPhysicsCollisionPair object per CCPhysicsNode and it's reused so don't store a reference to it.
 *  - You must copy any information you use from this struct if you want to use it later.
 */
@interface CCPhysicsCollisionPair : NSObject

/** The contact information from the two colliding bodies. */
@property(nonatomic, readonly) CCContactSet contacts;

/**
 *  The friction coefficient for this pair of colliding shapes.
 *  The default value is pair.bodyA.friction*pair.bodyB.friction.
 *  Can be overriden in a CCCollisionPairDelegate pre-solve method to change the collision.
 */
@property(nonatomic, assign) CGFloat friction;

/**
 *  The restitution coefficient for this pair of colliding shapes.
 *  The default value is "pair.bodyA.elasticity*pair.bodyB.elasticity".
 *  Can be overriden in a CCCollisionPairDelegate pre-solve method to change the collision.
 */
@property(nonatomic, assign) CGFloat restitution;

/**
 *  The relative surface velocities of the two colliding shapes. See CCPhysicsBody.surfaceVelocity for more information.
 *  The default value is the surface velocity of the first body subtracted from the second, then clamped to the collision tangent.
 *  Can be overriden in a CCCollisionPairDelegate pre-solve method to change the collision.
 */
@property(nonatomic, assign) CGPoint surfaceVelocity;

/**
 *  The amount of kinetic energy dissipated by the last collision of the two shapes.
 *  This is roughly equivalent to the idea of damage.
 *  @note By definition, fully elastic collisions do not lose any energy or cause any permanent damage.
 */
@property(nonatomic, readonly) CGFloat totalKineticEnergy;

/** The total impulse applied by this collision to the colliding shapes. */
@property(nonatomic, readonly) CGPoint totalImpulse;

/**
 *  A persistent object reference associated with these two colliding objects.
 *  If you want to store some information about a collision from time step to time step, store it here.
 *  @todo Possible to add a default to release it automatically?
 */
@property(nonatomic, assign) id userData;

/**
 *  Retrive the specific physics shapes that were involved in the collision.
 *
 *  @param shapeA Shape A.
 *  @param shapeB Shape B.
 */
-(void)shapeA:(__autoreleasing CCPhysicsShape **)shapeA shapeB:(__autoreleasing CCPhysicsShape **)shapeB;

/**
 *  Ignore the collision between these two shapes bodies until they stop colliding.
 *  It's idomatic to write "return [pair ignore];" if using this method from a CCCollisionPairDelegate pre-solve method.
 *
 *  @return FALSE
 */
-(BOOL)ignore;

/**
 *  Returns true if called on the first fixed timestep of a collision.
 *  Normally you would use a ccPhysicsCollisionBegin method to check for this, but firstContact can be used in combination with the pre/postSolve methods.
 *  For instance, you might want to play a sound from the postSolve callback only if it's the first step of a collision and the impact was hard enough.
 *
 *  @return FALSE
 */
-(BOOL)firstContact;

@end


/**
 Delegate type called when two physics bodies collide.
 
 The final two parameter names (typeA/typeB) should be replaced with names used with CCPhysicsBody.collisionType or CCPhysicsShape.collisionType.
If both final parameter names are "default" then the collision method is called when a more specific method isn't found.
 
 ### Wildcard Collisions:
 "wildcard" can be used as the final parameter name to mean "collides with anything".
When using wildcard methods, it's possible for up to three methods to be called (ex: bullet/monster, bullet/wildcard, monster/wildcard).
The most specific method (bullet/monster) will be called first, and then the wildcard handlers will be called in a somewhat random order.
Begin and PreSolve methods return a boolean. If multiple methods are called, their return values are combined with a logical AND.
 
 ### Collision Sequence:
 On the first fixed time step (not necessarily frame) that two physics shapes collide for the first time, a ccPhysicsCollisionBegin method will be called.
As long as those objects stay in contact, a ccPhysicsCollisionPreSolve and ccPhysicsCollisionPostSolve method will be called before and after the physics solver runs.
The pre-solve method gives you a chance to modify the outcome of the collision, and the post-solve method lets you find out what the outcome was.
This means you cannot use the outcome of the collision to modify itself. (ex: discard or undo a collision only if it will cause enough damage)
Finally, when two physics objects stop touching for the very first fixed time step, the ccPhysicsCollisionSeparate method is called.
 
 ### CCPhysicsShape vs. CCPhysicsBody:
 Though CCPhysics concentrates mostly on physics bodies, the underlying physics engine (Chipmunk2D) operates collision callbacks on the level of individual shapes.
CCPhysicsBody objects can have multiple shapes such as polyline bodies or those created with [CCPhysicsBody bodyWithShapes:].
In those cases, its possible to have have multiple active collisions between two CCPhysicsBody objects. This is something to keep in mind.
 */
@protocol CCPhysicsCollisionDelegate

@optional

/**
 *  Begin methods are called on the first fixed time step when two bodies begin colliding.
 *  If you return NO from a begin method, the collision between the two bodies will be ignored.
 *
 *  @param pair  Collision pair.
 *  @param nodeA Node A.
 *  @param nodeB Node B.
 *
 *  @return BOOL
 */
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB;

/**
 *  Pre-solve methods are called every fixed time step when two bodies are in contact before the physics solver runs.
 *  This gives you a chance to modify the collision's outcome by setting properties such as friction, restitution, or surfaceVelocity on CCPhysicsCollisionPair
 *  Since the collisions have not been solved yet, you cannot access the outcome by using properties such as totalKineticEnergy or totalImpulse.
 *  If you return NO from a pre-solve method, the collision will be ignored for the current time step.
 *
 *  @param pair  Collision pair.
 *  @param nodeA Node A.
 *  @param nodeB Node B.
 *
 *  @return BOOL
 */
-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB;

/**
 *  Post-solve methods are called every fixed time step when two bodies are in contact after the physics solver runs.
 *  You can call use properties such as totalKineticEnergy and totalImpulse on CCPhysicsCollisionPair from a post-solve method.
 *
 *  @param pair  Collision pair.
 *  @param nodeA Node A.
 *  @param nodeB Node B.
 */
-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB;

/**
 *  Separate methods are called the first fixed time step after two bodies stop colliding.
 *
 *  @param pair  Collision pair.
 *  @param nodeA Node A.
 *  @param nodeB Node B.
 */
-(void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB;

@end


/**
A CCNode that enables physics simulation in it's children.
To use CCPhysics, you create a physics node, and then attach CCPhysicsBody objects to any child node that you want to have gravity or collisions applied to.
Physics nodes are also where you set up a delegate object that can tell you about collision events.
Lastly, you can query for physics objects near a point, along a ray, or within a certain bounding box.

### Units:
For simplicity, CCPhysics does not use SI units, and the performance is not tuned to any particular scale.
Positions and distances are expressed in regular Cocos2D points relative to whatever node is most relevant.
For example, positions are in the same coordinates as the physics node.
Shapes and joint anchors use the local coordinates of the node their body is attached to so that they properly respect it's transform.
Mass has no particular units. I personally find it intuitive to use 1.0 as the main player's mass and set everything else based on that. Time is expressed in seconds.
 */
@interface CCPhysicsNode : CCNode

/** Should the node draw a debug overlay of the joints and collision shapes? Defaults to NO. */
@property(nonatomic, assign) BOOL debugDraw;

/** Gravity applied to the dynamic bodies in the world. Defaults to CGPointZero. */
@property(nonatomic, assign) CGPoint gravity;

/**
 *  The number of solver iterations the underlying physics engine should run.
 *  This allows you to tune the performance and quality of the physics.
 *  Low numbers will improve performance, but make the physics spongy or rubbery.
 *  High numbers will use more CPU time, but make the physics look more solid.
 *  The default value is 10.
 */
@property(nonatomic, assign) int iterations;

/**
 *  Physics bodies fall asleep when a group of them move slowly for longer than the threshold.
 *  Sleeping bodies use minimal CPU resources and wake automatically when a collision happens.
 *  Defaults to 0.5 seconds.
 */
@property(nonatomic, assign) CCTime sleepTimeThreshold;

/** The delegate that is called when two physics bodies collide. */
@property(nonatomic, assign) NSObject<CCPhysicsCollisionDelegate> *collisionDelegate;

/**
 *  Find all CCPhysicsShapes within a certain distance of a point. The block is called once for each shape found.
 *
 *  @param point  Center point of query.
 *  @param radius Radius to sweep.
 *  @param block  Block to execute per result.
 */
-(void)pointQueryAt:(CGPoint)point within:(CGFloat)radius block:(void (^)(CCPhysicsShape *shape, CGPoint nearest, CGFloat distance))block;

/**
 *  Shoot a ray from 'start' to 'end' and find all of the CCPhysicsShapes that it would hit.
 *  The block is called once for each shape found.
 *
 *  @param start Start point.
 *  @param end   End point.
 *  @param block Block to execute per result.
 */
-(void)rayQueryFirstFrom:(CGPoint)start to:(CGPoint)end block:(void (^)(CCPhysicsShape *shape, CGPoint point, CGPoint normal, CGFloat distance))block;

/**
 *  Find all CCPhysicsShapes whose bounding boxes overlap the given CGRect.
 *  The block is called once for each shape found.
 *
 *  @param rect  Rectangle area to check.
 *  @param block The block is called once for each shape found.
 */
-(void)rectQuery:(CGRect)rect block:(void (^)(CCPhysicsShape *shape))block;

@end


@interface CCNode(CCPhysics)

/** Nearest CCPhysicsNode ancestor of this node, or nil if none. 
 *  Unlike CCPhysicsBody.physicsNode, this will return a value before onEnter is called on the node.
 */
-(CCPhysicsNode *)physicsNode;

@end
