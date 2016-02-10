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

/**
Every CCPhysicsBody has at least one shape attached to it. Normally the shape is created for you when creating the body.
 
If you wish to create a composite body that is composed of multiple shapes, you can create the shapes yourself and then initialize a body using
 [CCPhysicsBody bodyWithShapes:]. This gives you extra flexibility in designing a complex shape or setting up different physics properties on
 different parts of the body.

Another thing to keep in mind is that the collision detection of the underlying physics library (Chipmunk2D) is based around shapes, not bodies.
The CCPhysicsCollisionDelegate methods will be invoked based on specific shapes colliding and not the physics bodies or nodes that own them.
Using simple shapes instead of composite ones can make collision handling code simpler depending on what you need to do.
 */
@interface CCPhysicsShape : NSObject

/// -----------------------------------------------------------------------
/// @name Creating a Physics Shape
/// -----------------------------------------------------------------------

/**
*  Creates and retuns a circular physics shape using the circle radius and center values specified.
*
*  @param radius Circle radius.
*  @param center Circle center point, in world coordinates.
*
*  @return The CCPhysicsShape Object.
*/
+(CCPhysicsShape *)circleShapeWithRadius:(CGFloat)radius center:(CGPoint)center;
// needed for Swift
-(CCPhysicsShape *)initWithCircleShapeWithRadius:(CGFloat)radius center:(CGPoint)center;

/**
 *  Creates and returns a physics box shape with rounded corners.
 *
 *  @param rect         Box dimensions, origin in world coordinates.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsShape Object.
 */
+(CCPhysicsShape *)rectShape:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
// needed for Swift
-(CCPhysicsShape *)initWithRectShape:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a pill shaped physics shape with rounded corners that stretches from 'start' to 'end'.
 *
 *  @param from         Start point, in world coordinates.
 *  @param to           End point, in world coordinates.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsShape Object.
 */
+(CCPhysicsShape *)pillShapeFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius;
// needed for Swift
-(CCPhysicsShape *)initWithPillShapeFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a convex polygon physics shape with rounded corners. 
 *  If the points do not form a convex polygon then a convex hull will be created from them automatically.
 *
 *  @warning Prefer convex shapes or concave shapes that can be represented by as few convex shapes as possible. 
 *  Breaking up a concave shape into convex polygons creates more collision shapes internally, and depending on the original shape
 *  the number of additional shapes could be much larger than you might anticipate.
 *  Enable [CCPhysicsNode debugDraw] to see if and how a shape is broken up into individual convex shapes.
 *
 *  @param points       Points buffer. All points in world coordinates. You are responsible for freeing the buffer's memory.
 *  @param count        Number of points in the points buffer.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsShape Object.
 *  @see [Definition: Convex vs Concave](http://en.wikipedia.org/wiki/Convex_and_concave_polygons)
 */
+(CCPhysicsShape *)polygonShapeWithPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;
// needed for Swift
-(CCPhysicsShape *)initWithPolygonShapeWithPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;


/// -----------------------------------------------------------------------
/// @name Basic Shape Properties
/// -----------------------------------------------------------------------

/**
 *  Mass of the physics shape.
 */
@property(nonatomic, assign) CGFloat mass;

/**
 *  Area of the shape in points^2.
 *  @note Area is relative to the CCPhysicsNode the shape is attached to, changing the node or a parent can change the area.
 */
@property(nonatomic, readonly) CGFloat area;

/**
 *  Density of the shape in 1/1000 units of mass per points^2. The co-efficent is used to keep the mass of an object a reasonably small value.
 *  @note Mass will remain constant if an object is rescaled, but density will change.
 */
@property(nonatomic, assign) CGFloat density;

/**
 *  Surface friction of the shape, when two objects collide, their friction is multiplied together.
 *  The calculated value can be overridden in a CCPhysicsCollisionDelegate pre-solve method.
 *  Defaults to 0.7
 */
@property(nonatomic, assign) CGFloat friction;

/**
 *  Elasticity of the physics shape. When two objects collide, their elasticity is multiplied together.
 *  The calculated value can be ovrriden in a CCPhysicsCollisionDelegate pre-solve method.
 *  Defaults to 0.2.
 */
@property(nonatomic, assign) CGFloat elasticity;

/**
 *  Velocity of the surface of a shape relative to it's normal velocity.  This is useful for modelling conveyor belts or the feet of a player's avatar.
 *
 *  The calculated surface velocity of two colliding shapes by default only affects their friction.
 *  The value can be overriden in a CCPhysicsCollisionDelegate pre-solve method.
 *  Defaults to CGPointZero.
 */
@property(nonatomic, assign) CGPoint surfaceVelocity;


/// -----------------------------------------------------------------------
/// @name Collision and Contact Properties
/// -----------------------------------------------------------------------

/**
 *  A sensor shape will run collision callback methods but does not physically cause collisions between bodies.
 *  Mainly used to create trigger areas.
 *  Defaults to NO
 */
@property(nonatomic, assign) BOOL sensor;

/**
 *  The shape's collisionGroup, if two physics bodies share the same group id, they don't collide. Defaults to nil.
 */
@property(nonatomic, assign) id collisionGroup;

/**
 *  A string that identifies the collision pair delegate method that should be called. Default value is @"default".
 */
@property(nonatomic, copy) NSString *collisionType;

/**
 *  An array of NSString category names of which this shape is a member. Up to 32 unique categories can be used in a single physics node.
 *  A value of nil means that a shape exists in all possible collision categories.
 *  The default is nil.
 */
@property(nonatomic, copy) NSArray *collisionCategories;

/**
 *  An array of NSString category names that this shape wants to collide with.
 *  The categories/masks of both shapes must match for a collision to occur.
 *  A value of nil means that this body will collide with a shape in any category.
 *  The default is nil.
 */
@property(nonatomic, copy) NSArray *collisionMask;


/// -----------------------------------------------------------------------
/// @name Accessing the Shape's Node
/// -----------------------------------------------------------------------

/** The CCNode to which this physics shape is attached.
 @see CCNode */
@property(nonatomic, readonly) CCNode *node;

@end
