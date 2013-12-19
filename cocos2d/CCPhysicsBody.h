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

/** The type of physics body to use. */
typedef NS_ENUM(unsigned char, CCPhysicsBodyType){
    
	/** A regular rigid body that is affected by gravity, forces and collisions. */
	CCPhysicsBodyTypeDynamic,
	
//	/** A body that is immovable by gravity, forces or collisions, but is moved using code.  */
//	CCPhysicsBodyTypeKinematic,
	
	/** A body that is immovable such as a wall or the ground. */
	CCPhysicsBodyTypeStatic,
};

/**
 * @todo This needs fleshed out by @slembcke
 */
@interface CCPhysicsBody : NSObject


/// -----------------------------------------------------------------------
/// @name Creating a CCPhysicsBody Object
/// -----------------------------------------------------------------------

/**
*  Creates and retuns a circular physics body using the circle radius and center values specified.
*
*  @param radius Circle radius.
*  @param center Circle center point.
*
*  @return The CCPhysicsBody Object.
*/
+(CCPhysicsBody *)bodyWithCircleOfRadius:(CGFloat)radius andCenter:(CGPoint)center;

/**
 *  Creates and returns a box shaped physics body with rounded corners.
 *
 *  @param rect         Box dimensions.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsBody Object.
 */
+(CCPhysicsBody *)bodyWithRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a pill shaped physics body with rounded corners that stretches from 'start' to 'end'.
 *
 *  @param from         Start point.
 *  @param to           End point.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsBody Object.
 */
+(CCPhysicsBody *)bodyWithPillFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a convex polygon shaped physics body with rounded corners.  If the points do not form a convex polygon then a convex hull will be created from them automatically.
 *
 *  @param points       Points array pointer.
 *  @param count        Points count.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsBody Object.
 */
+(CCPhysicsBody *)bodyWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a physics body with four pill shapes around the rectangle's perimeter, this will also default to being a CCPhysicsBodyTypeStatic type body.
 *
 *  @param rect         Rectangle perimeter.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsBody Object.
 */
+(CCPhysicsBody *)bodyWithPolylineFromRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a physics body with multiple pill shapes attached.  One for each segment in the polyline, this will also default to a CCPhysicsBodyTypeStatic type body.
 *
 *  @param points       Points array pointer.
 *  @param count        Points count.
 *  @param cornerRadius Corner radius.
 *  @param looped       Looped Flag.
 *
 *  @return The CCPhysicsBody Object.
 */
+(CCPhysicsBody *)bodyWithPolylineFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius looped:(bool)looped;

/**
 *  Creates and returns a physics body with multiple shapes.
 *
 *  @param shapes Array of shapes to attach to the body.
 *
 *  @return The CCPhysicsBody Object.
 */
+(CCPhysicsBody *)bodyWithShapes:(NSArray *)shapes;


/// -----------------------------------------------------------------------
/// @name Accessing Basic Body Attributes
/// -----------------------------------------------------------------------

/**
 *  Mass of the physics body, if the body has multiple shapes you cannont change the mass directly.  
 *  Defaults to 1.0
 */
@property(nonatomic, assign) CGFloat mass;

/**
 *  Area of the body in points^2.
 *  Please note that this is relative to the CCPhysicsNode, change the node or a parent can change the area.
 */
@property(nonatomic, readonly) CGFloat area;

/**
 *  Density of the body in 1/1000 units of mass per area in points. Co-efficent is used to keep the mass of an object a resonable value.
 *  If the body has multiple shapes, you cannot change the density directly.
 *  Note that mass and not density will remain constant if an object is rescaled.
 */
@property(nonatomic, assign) CGFloat density;

/**
 *  Surface friction of the physics body, when two objects collide, their friction is multiplied together.
 *  The calculated value can be overridden in a CCCollisionPairDelegate pre-solve method.
 *  Defaults to 0.7
 */
@property(nonatomic, assign) CGFloat friction;

/**
 *  Elasticity of the physics body.
 *  When two objects collide, their elasticity is multiplied together.
 *  The calculated value can be ovrriden in a CCCollisionPairDelegate pre-solve method.
 *  Defaults to 0.2.
 */
@property(nonatomic, assign) CGFloat elasticity;

/**
 *  Velocity of the surface of a physics body relative to it's normal velocity.  This is useful fr modelling convery belts or the feet of a player avatar.
 *  The calculated surface velocity of two colliding shapes by default only affects their friction.
 *  The calculated value can be overriden in a CCCollisionPairDelegate pre-solve method.
 *  Defaults to CGPointZero.
 */
@property(nonatomic, assign) CGPoint surfaceVelocity;


/// -----------------------------------------------------------------------
/// @name Accessing Simulation Attributes
/// -----------------------------------------------------------------------

/**
 *  Affected by gravity flag.  Defaults to Yes.
 */
@property(nonatomic, assign) BOOL affectedByGravity;

/**
 *  Allow body rotation flag.  Defaults to Yes.
 */
@property(nonatomic, assign) BOOL allowsRotation;

/**
 *  Physics body type.  Defaults to CCPhysicsBodyTypeDynamic
 */
@property(nonatomic, assign) CCPhysicsBodyType type;


/// -----------------------------------------------------------------------
/// @name Accessing Collision and Contact Attributes
/// -----------------------------------------------------------------------

/**
 *  Is this body a sensor? A sensor will call a collision delegate but does not physically cause collisions between bodies.
 *  Defaults to NO
 */
@property(nonatomic, assign) BOOL sensor;

/**
 *  The bodies collisionGroup, if two physics bodies share the same group id, they don't collide.  Default nil
 */
@property(nonatomic, assign) id collisionGroup;

/**
 *  An string that identifies the collision pair delegate method that should be called.  Default @"default"
 */
@property(nonatomic, copy) NSString *collisionType;

/**
 *  An array of NSString category names of which this physics body is a member.  Up to 32 categories can be used in a single scene.
 *  Default is nil, which means the physics body exists in all categories.
 */
@property(nonatomic, copy) NSArray *collisionCategories;

/**
 *  An array of NSString category names that this physics body will collide with.
 *  The dedfault is nil, which means the physics body collides with all categories.
 */
@property(nonatomic, copy) NSArray *collisionMask;

/**
 *  Iterate over all of the CCPhysicsCollisionPairs this body is currently in contact with.
 *  @note The CCPhysicsCollisionPair object is shared so you should not store a strong reference to it.
 *
 *  @param block Collision block.
 */
-(void)eachCollisionPair:(void (^)(CCPhysicsCollisionPair *pair))block;


/// -----------------------------------------------------------------------
/// @name Accessing Velocity Attributes
/// -----------------------------------------------------------------------

/**
 *  The velocity of the physics body in absolute coordinates.
 */
@property(nonatomic, assign) CGPoint velocity;

/**
 *  Angular velocity of the physics body in radians per second.
 */
@property(nonatomic, assign) CGFloat angularVelocity;


/// -----------------------------------------------------------------------
/// @name Accessing Forces, Torques and Impulses Attributes
/// -----------------------------------------------------------------------

/**
 *  Linear force applied to the physics body this fixed timestep.
 */
@property(nonatomic, assign) CGPoint force;

/**
 *  Torque applied to this physics body this fixed timestep.
 */
@property(nonatomic, assign) CGFloat torque;


/// -----------------------------------------------------------------------
/// @name Applying Force Methods
/// -----------------------------------------------------------------------

/**
 *  Apply a torque on the physics body.
 *
 *  @param torque Torque.
 */
-(void)applyTorque:(CGFloat)torque;

/**
 *  Apply an angular impulse.
 *
 *  @param impulse Angular impulse.
 */
-(void)applyAngularImpulse:(CGFloat)impulse;

/**
 *  Apply a force to the physics body.
 *
 *  @param force Force vector.
 */
-(void)applyForce:(CGPoint)force;

/**
 *  Apply an impulse on the physics body.
 *
 *  @param impulse Impulse vector.
 */
-(void)applyImpulse:(CGPoint)impulse;

/**
 *  Apply force and torque on the physics body from a force applied at the given point in the parent CCNode's coordinates.
 *  The force will be rotated by, but not scaled by the CCNode's transform.
 *
 *  @param force Force vector.
 *  @param point Point to apply force.
 */
-(void)applyForce:(CGPoint)force atLocalPoint:(CGPoint)point;

/**
 *  Apply an impulse and angular impulse on the physics body at the given point in the parent CCNode's coordinates.
 *  The impulse will be rotated by, but not scaled by the CCNode's transform.
 *
 *  @param impulse Impulse vector.
 *  @param point   Point to apply impulse.
 */
-(void)applyImpulse:(CGPoint)impulse atLocalPoint:(CGPoint)point;

/**
 *  Apply an force and angular torque on the physics body at the given point in absolute coordinates.
 *
 *  @param force Force vector.
 *  @param point Point to apply force.
 */
-(void)applyForce:(CGPoint)force atWorldPoint:(CGPoint)point;

/**
 *  Apply an impulse and angular impulse on the physics body at the given point in absolute coordinates.
 *
 *  @param impulse Impulse vector.
 *  @param point   Point to apply impulse.
 */
-(void)applyImpulse:(CGPoint)impulse atWorldPoint:(CGPoint)point;


/// -----------------------------------------------------------------------
/// @name Accessing Misc Attributes
/// -----------------------------------------------------------------------

/** Joints connected to this body. */
@property(nonatomic, readonly) NSArray *joints;

/** 
 * Sleeping bodies are not simulated and use minimal CPU resources, normally bodies will fall asleep when they stop moving however you can trigger this
 * manually if required. 
 */
@property(nonatomic, assign) BOOL sleeping;

/** The CCNode to which this physics body is attached. */
@property(nonatomic, readonly) CCNode *node;

@end
