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
typedef NS_ENUM(NSUInteger, CCPhysicsBodyType){
    
	/** A regular rigid body that is affected by gravity, forces and collisions. */
	CCPhysicsBodyTypeDynamic,
	
//	/** A body that is immovable by gravity, forces or collisions, but is moved using code.  */
	CCPhysicsBodyTypeKinematic,
	
	/** A body that is immovable such as a wall or the ground. */
	CCPhysicsBodyTypeStatic,
};

/**
Physics bodies are attached to CCNode objects and contain their physical properties such as mass, shape, friction, etc.

There are two main kinds of bodies, static and dynamic. Static bodies cannot be moved by normal forces, collisions or gravity.
This is the type of body you would use for the ground or wall in a game. Dynamic bodies are just the opposite. They are affected by collisions, friction, gravity, forces, etc.
You can change the type of a body using the CCPhysicsBody.type property.

There are two basic categories of shapes that physics bodies can have. The simplest category are convex shapes such as circles, pills and polygons (in order of efficiency).
These are considered to be solid (not hollow) objects by the physics engine.
Composite bodies, such as those created with the polyline or bodyWithShapes: methods are actually composed of multiple shapes.
Regardless of the type, all shapes can be given a radius value that adds some thickness to them and rounds out their sharp corners.

Many rigid body properties such as the moment of inertia or center of gravity are calculated for you automatically based on the shapes the body is created from.
The exception is the mass of the body which defaults to 1.0. It is the developer's responsibility to set the mass (or density) for the objects.
What units you use for mass is not important as long as they are consistent.

### Collision Filtering:

By default physics bodies collide with all other physics bodies. Since 2D games use a lot of faked perspectives and layering CCPhysics provides you with many options to filter out unwanted collisions.

- collisionGroup: Bodies can be assigned an object pointer that defines a group. Two bodies in the same group will not collide.
- collisionCategory, collisionMask: Bodies can be assigned a list of categories and masks (rules) that define which kinds of bodies they will collide with.
- CCPhysicsJoint.collideBodies: Joints have a flag that allows you to reject a collisions between the bodies they connect.
- CCPhysicsCollisionDelegate methods: You can set up a delegate that responds to collision events between bodies progmatically.

### Tips:

- Use the simplest shape you can. You don't need to be pixel perfect. Collisions with complex shapes are very computationally expensive and will ultimately feel more random and unfair to your players.
- Add radii to your shapes. It will help smooth out collisions between corners of objects and it will allow the collision detection to run more efficiently.
- Avoid very small, thin, or fast moving shapes when possible. The underlying physics engine does not perform continuous collision detection and can miss collisions if they move too much in a single step.
- When possible, try to use groups, categories or joints to filter collisions since they are tried before running the expensive collision detection code. 
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
 *  Creates and returns a convex polygon shaped physics body with rounded corners.
 *  If the points do not form a convex polygon then a convex hull will be created from them automatically.
 *
 *  @param points       Points array pointer.
 *  @param count        Points count.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsBody Object.
 */
+(CCPhysicsBody *)bodyWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a physics body with four pill shapes around the rectangle's perimeter.
 *  Polyline based bodies default to the CCPhysicsBodyTypeStatic body type.
 *
 *  @param rect         Rectangle perimeter.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsBody Object.
 */
+(CCPhysicsBody *)bodyWithPolylineFromRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a physics body with multiple pill shapes attached, one for each segment in the polyline.
 *  Polyline based bodies default to the CCPhysicsBodyTypeStatic body type.
 *
 *  @param points       Points array pointer.
 *  @param count        Points count.
 *  @param cornerRadius Corner radius.
 *  @param looped       Should there be a pill shape that goes from the first to last point or not.
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
 *  Mass of the physics body. The mass of a composite body cannod be changed. 
 *  Defaults to 1.0.
 */
@property(nonatomic, assign) CGFloat mass;

/**
 *  Area of the body in points^2.
 *  Please note that this is relative to the CCPhysicsNode, changing the node or a parent can change the area.
 */
@property(nonatomic, readonly) CGFloat area;

/**
 *  Density of the body in 1/1000 units of mass per point^2. The co-efficent is used to keep the mass of an object a reasonably small value.
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
 *  Velocity of the surface of a physics body relative to it's normal velocity.  This is useful for modelling conveyor belts or the feet of a player avatar.
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
 *  Defaults to NO.
 */
@property(nonatomic, assign) BOOL sensor;

/**
 *  The body's collisionGroup, if two physics bodies share the same group id, they don't collide. Defaults to nil.
 */
@property(nonatomic, assign) id collisionGroup;

/**
 *  A string that identifies the collision pair delegate method that should be called. Default value is @"default".
 */
@property(nonatomic, copy) NSString *collisionType;

/**
 *  An array of NSString category names of which this physics body is a member. Up to 32 unique categories can be used in a single physics node.
 *  A value of nil means that a body exists in all possible collision categories.
 *  The default is nil.
 */
@property(nonatomic, copy) NSArray *collisionCategories;

/**
 *  An array of NSString category names that this physics body wants to collide with.
 *  The categories/masks of both bodies must agree for a collision to occur.
 *  A value of nil means that this body will collide with a body in any category.
 *  The default is nil.
 */
@property(nonatomic, copy) NSArray *collisionMask;

/**
 *  Iterate over all of the CCPhysicsCollisionPairs this body is currently in contact with.
 *  @note The CCPhysicsCollisionPair object is shared so you should not store a reference to it.
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
/// @name Accessing Forces and Torques Attributes
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
/// @name Applying Force and Impulses Methods
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
 * Sleeping bodies use minimal CPU resources as they are removed from the simulation until something collides with them.
 * Normally a body will fall alsleep on it's own, but you can manually force a body to fall a sleep at any time if you desire.
 */
@property(nonatomic, assign) BOOL sleeping;

/** The CCNode to which this physics body is attached. */
@property(nonatomic, readonly, weak) CCNode *node;

@end
