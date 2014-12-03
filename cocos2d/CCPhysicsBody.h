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

/** The type of physics body to use, used by CCPhysicsBody.
 
 The type affects a body's influence by gravity, whether it can collide with other bodies,
 whether it is affected by forces, and whether it can be moved/rotated via move/rotate actions. */
typedef NS_ENUM(NSUInteger, CCPhysicsBodyType){
    
	/** A regular rigid body that is affected by gravity, forces and collisions.<p/> **WARNING:** Using move or rotate actions on dynamic bodies is **strongly discouraged** as these actions will be in conflict with physics movement/rotation and collision detection/feedback. */
	CCPhysicsBodyTypeDynamic,
	
	/** A body that is immovable by gravity, forces or collisions. It is supposed to be moved/rotated manually by code or by using move/rotate actions.  */
	CCPhysicsBodyTypeKinematic,
	
	/** A body that is immovable such as a wall or the ground. */
	CCPhysicsBodyTypeStatic,
};

/**
Physics bodies can be attached to a [CCNode physicsBody] property to have the node participate in the physics simulation.
 Bodies contain the physical properties such as mass, shape, friction, etc. and alter the node's position and rotation properties
 whenever the physics simulation causes the body to move or rotate.

### Body Types
 
There are three main kinds of bodies: static, dynamic and kinematic. You can change the type of a body using the [CCPhysicsBody type] property.
 
 - Static bodies cannot be moved by normal forces, collisions or gravity. This is the type of body you would use for the ground or wall in a game.
 - Dynamic bodies are just the opposite. They are affected by collisions, friction, gravity, forces, etc.
 - Kinematic bodies behave like static bodies, except that they don't collide. Kinematic bodies are supposed to be moved by code or via actions running on the node.

### Shape Types

There are two basic categories of shapes that physics bodies can have. The simplest category are convex shapes (in order of efficiency):
 
 - circles
 - pills
 - convex polygons
 
These are considered to be solid (not hollow) objects by the physics engine. The number of vertices in a polygon affects its collision handling efficiency,
 the fewer vertices the better. Prefer to model objects coarsely, modelling fine collision details is often counterproductive not just in terms of efficiency
 but also stability, reliability and gameplay (no one likes to get held up or hit by an antenna or a character's hair).
 
Composite bodies, such as those created with the polyline or bodyWithShapes: methods are actually composed of multiple convex shapes.
Regardless of the type, all shapes can be given a radius value that adds some thickness to them and rounds out their sharp corners.

Many rigid body properties such as the moment of inertia or center of gravity are calculated for you automatically based on the shapes the body is created from.
The exception is the mass of the body which defaults to 1.0. It is the developer's responsibility to set the mass (or density) for the objects.
What units you use for mass is not important as long as they are consistent.

### Collision Filtering:

By default physics bodies collide with all other physics bodies. Since 2D games use a lot of fake perspectives. Grouping physics bodies provides you with many
 options to filter out unwanted collisions.

- collisionGroup: Bodies can be assigned an object pointer that defines a group. Two bodies in the same group will not collide.
- collisionCategory, collisionMask: Bodies can be assigned a list of categories and masks (rules) that define which kinds of bodies they will collide with.
- [CCPhysicsJoint collideBodies]: Joints have a flag that allows you to reject a collisions between the bodies they connect.
- CCPhysicsCollisionDelegate: You can set up a delegate that responds to collision events between bodies progmatically.

### Tips:

- Use the simplest shape you can. You don't need to be pixel perfect. Collisions with complex shapes are very computationally expensive and will ultimately feel more random and unfair to your players.
- Add radii to your shapes. It will help smooth out collisions between corners of objects and it will allow the collision detection to run more efficiently.
- Avoid very small, thin, or fast moving shapes when possible. The underlying physics engine does not perform continuous collision detection and can miss collisions if they move too much in a single step.
- When possible, try to use groups, categories or joints to filter collisions since they are tried before running the expensive collision detection code. 
 */
@interface CCPhysicsBody : NSObject


/// -----------------------------------------------------------------------
/// @name Creating a Physics Body
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
 *  @see bodyWithPolylineFromPoints:count:cornerRadius:looped:
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
 *  @see bodyWithPolylineFromRect:cornerRadius:
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
/// @name Basic Body Properties
/// -----------------------------------------------------------------------

/**
 *  Mass of the physics body. The mass of a composite body cannod be changed. 
 *  @note If a node's scale is changed, mass remains constant by altering the body's density.
 *  Defaults to 1.0.
 */
@property(nonatomic, assign) CGFloat mass;

/**
 *  Area of the body in points^2.
 *  @note Area is relative to the CCPhysicsNode, changing the node or a parent can change the area.
 */
@property(nonatomic, readonly) CGFloat area;

/**
 *  Density of the body in 1/1000 units of mass per point^2. The co-efficent is used to keep the mass of an object a reasonably small value.
 *  If the body has multiple shapes, you cannot change the density directly.
 *  @note If a node's scale is changed, density will change too in order to keep mass constant.
 */
@property(nonatomic, assign) CGFloat density;

/**
 *  Surface friction of the physics body, when two objects collide, their friction is multiplied together.
 *  The calculated value can be overridden in a CCPhysicsCollisionDelegate pre-solve method.
 *  Defaults to 0.7
 */
@property(nonatomic, assign) CGFloat friction;

/**
 *  Elasticity of the physics body.
 *  When two objects collide, their elasticity is multiplied together.
 *  The calculated value can be overriden in a CCPhysicsCollisionDelegate pre-solve method.
 *  Defaults to 0.2.
 */
@property(nonatomic, assign) CGFloat elasticity;

/**
 *  Velocity of the surface of a physics body relative to it's normal velocity.  This is useful for modelling conveyor belts or the feet of a player avatar.
 *  The calculated surface velocity of two colliding shapes by default only affects their friction.
 *  The calculated value can be overriden in a CCPhysicsCollisionDelegate pre-solve method.
 *  Defaults to CGPointZero.
 */
@property(nonatomic, assign) CGPoint surfaceVelocity;


/// -----------------------------------------------------------------------
/// @name Simulation Settings
/// -----------------------------------------------------------------------

/**
 *  Affected by gravity flag.  Defaults to Yes. If set to NO, the body will not feel the force of gravity.
 */
@property(nonatomic, assign) BOOL affectedByGravity;

/**
 *  Allow body rotation flag.  Defaults to Yes. If set to NO, the body is not allowed to rotate or have rotational force (torque).
 */
@property(nonatomic, assign) BOOL allowsRotation;

/**
 *  Physics body type.  Defaults to `CCPhysicsBodyTypeDynamic`.
 *  @see CCPhysicsBodyType
 */
@property(nonatomic, assign) CCPhysicsBodyType type;

/**
 * Sleeping bodies use minimal CPU resources as they are removed from the simulation until something collides with them.
 * Normally a body will fall asleep on its own, but you can manually force a body to fall a sleep at any time if you desire.
 *
 * @note Bodies wake up automatically when receiving forces (colliding). Depending on the situation setting the sleeping flag to YES may see it being reset back to NO almost instantly.
 * If you need to remove a body from the simulation, you can (temporarily) alter its collisionGroup, collisionCategories or collisionMask, or enable its sensor flag,
 * or change its type to `CCPhysicsBodyTypeKinematic`, or ultimately setting the node's physicsBody property to nil. Which solution works best depends on the situation and intended behavior.
 */
@property(nonatomic, assign) BOOL sleeping;

/// -----------------------------------------------------------------------
/// @name Collision and Contact Properties
/// -----------------------------------------------------------------------

/**
 *  Is this body a sensor? A sensor will call a collision delegate but does not physically cause collisions between bodies.
 *  Defaults to NO.
 */
@property(nonatomic, assign) BOOL sensor;

/**
 *  A string that identifies the collision pair delegate method that should be called. Default value is `@"default"`.
 *  @note This method does not affect whether or how bodies collide, it only changes the signature of the collision delegate method to be called.
 */
@property(nonatomic, copy) NSString *collisionType;

/**
 *  The body's collisionGroup, if two physics bodies share the same group id, they don't collide. Defaults to `nil`.
 *  @see collisionCategories <br/> collisionMask
 */
@property(nonatomic, assign) id collisionGroup;

/**
 *  An array of NSString category names of which this physics body is a member. Up to 32 unique categories can be used in a single physics node.
 *  The default is `nil`.
 *  @note A value of `nil` means that a body exists in all possible collision categories. As soon as you assign an array, the body will stop colliding
 *  with all other bodies except those whose collisionMask matches at least one item in the array.
 *  @see collisionGroup <br/> collisionMask
 */
@property(nonatomic, copy) NSArray *collisionCategories;

/**
 *  An array of NSString category names that this physics body wants to collide with.
 *  The categories/masks of both bodies must match for a collision to occur.
 *  The default is nil.
 *  @note A value of `nil` means that this body will collide with all bodies. As soon as you assign an array, the body will stop colliding
 *  with all other bodies except those whose collisionCategories include at least one of the items in the array.
 *  @see collisionGroup <br/> collisionCategories
 */
@property(nonatomic, copy) NSArray *collisionMask;

/**
 *  Iterate over all of the CCPhysicsCollisionPairs this body is currently in contact with.
 *  @note The CCPhysicsCollisionPair object is shared so you should not store a reference to it.
 *
 *  @param block Collision block.
 *  @see CCPhysicsCollisionPair
 */
-(void)eachCollisionPair:(void (^)(CCPhysicsCollisionPair *pair))block;


/// -----------------------------------------------------------------------
/// @name Velocity
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
/// @name Force and Torque
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
/// @name Applying Forces and Impulses
/// -----------------------------------------------------------------------

/**
 *  Apply a torque on the physics body.
 *
 *  @param torque Torque.
 *  @see applyAngularImpulse:
 */
-(void)applyTorque:(CGFloat)torque;

/**
 *  Apply an angular impulse.
 *
 *  @param impulse Angular impulse.
 *  @see applyTorque:
 */
-(void)applyAngularImpulse:(CGFloat)impulse;

/**
 *  Apply a force to the physics body.
 *
 *  @param force Force vector.
 *  @see applyImpulse:
 */
-(void)applyForce:(CGPoint)force;

/**
 *  Apply an impulse on the physics body.
 *
 *  @param impulse Impulse vector.
 *  @see applyForce:
 */
-(void)applyImpulse:(CGPoint)impulse;

/**
 *  Apply force and torque on the physics body from a force applied at the given point in the parent CCNode's coordinates.
 *  The force will be rotated by, but not scaled by the CCNode's transform.
 *
 *  @param force Force vector.
 *  @param point Point to apply force.
 *  @see applyImpulse:atLocalPoint:
 *  @see applyForce:atWorldPoint:
 */
-(void)applyForce:(CGPoint)force atLocalPoint:(CGPoint)point;

/**
 *  Apply an impulse and angular impulse on the physics body at the given point in the parent CCNode's coordinates.
 *  The impulse will be rotated by, but not scaled by the CCNode's transform.
 *
 *  @param impulse Impulse vector.
 *  @param point   Point to apply impulse.
 *  @see applyForce:atLocalPoint:
 *  @see applyImpulse:atWorldPoint:
 */
-(void)applyImpulse:(CGPoint)impulse atLocalPoint:(CGPoint)point;

/**
 *  Apply an force and angular torque on the physics body at the given point in absolute coordinates.
 *
 *  @param force Force vector.
 *  @param point Point to apply force.
 *  @see applyImpulse:atWorldPoint:
 *  @see applyForce:atLocalPoint:
 */
-(void)applyForce:(CGPoint)force atWorldPoint:(CGPoint)point;

/**
 *  Apply an impulse and angular impulse on the physics body at the given point in absolute coordinates.
 *
 *  @param impulse Impulse vector.
 *  @param point   Point to apply impulse.
 *  @see applyForce:atWorldPoint:
 *  @see applyImpulse:atLocalPoint:
 */
-(void)applyImpulse:(CGPoint)impulse atWorldPoint:(CGPoint)point;


/// -----------------------------------------------------------------------
/// @name Accessing Connected Joints
/// -----------------------------------------------------------------------

/** All joints connected to this body.
 */
@property(nonatomic, readonly) NSArray *joints;

/// -----------------------------------------------------------------------
/// @name Accessing the body's CCNode
/// -----------------------------------------------------------------------

/** The CCNode to which this physics body is attached. Is nil until the body was assigned to the physicsBody property of a node.
 @see CCNode
 */
@property(nonatomic, readonly, weak) CCNode *node;

@end
