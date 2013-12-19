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
 * @todo This needs fleshed out by @slembcke
 */
@interface CCPhysicsShape : NSObject

/// -----------------------------------------------------------------------
/// @name Creating a CCPhysicsShape Object
/// -----------------------------------------------------------------------

/**
*  Creates and retuns a circular physics shape using the circle radius and center values specified.
*
*  @param radius Circle radius.
*  @param center Circle center point.
*
*  @return The CCPhysicsShape Object.
*/
+(CCPhysicsShape *)circleShapeWithRadius:(CGFloat)radius center:(CGPoint)center;

/**
 *  Creates and returns a physics box shape with rounded corners.
 *
 *  @param rect         Box dimensions.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsShape Object.
 */
+(CCPhysicsShape *)rectShape:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a pill shaped physics shape with rounded corners that stretches from 'start' to 'end'.
 *
 *  @param from         Start point.
 *  @param to           End point.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsShape Object.
 */
+(CCPhysicsShape *)pillShapeFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius;

/**
 *  Creates and returns a convex polygon physics shape with rounded corners.  If the points do not form a convex polygon then a convex hull will be created from them automatically.
 *
 *  @param points       Points array pointer.
 *  @param count        Points count.
 *  @param cornerRadius Corner radius.
 *
 *  @return The CCPhysicsShape Object.
 */
+(CCPhysicsShape *)polygonShapeWithPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;


/// -----------------------------------------------------------------------
/// @name Accessing Basic Shape Attributes
/// -----------------------------------------------------------------------

/**
 *  Mass of the physics shapes.
 */
@property(nonatomic, assign) CGFloat mass;

/**
 *  Area of the shape in points^2.
 *  Please note that this is relative to the CCPhysicsNode, change the node or a parent can change the area.
 */
@property(nonatomic, readonly) CGFloat area;

/**
 *  Density of the shape in 1/1000 units of mass per area in points. Co-efficent is used to keep the mass of an object a resonable value.
 *  Note that mass and not density will remain constant if an object is rescaled.
 */
@property(nonatomic, assign) CGFloat density;

/**
 *  Surface friction of the shape, when two objects collide, their friction is multiplied together.
 *  The calculated value can be overridden in a CCCollisionPairDelegate pre-solve method.
 *  Defaults to 0.7
 */
@property(nonatomic, assign) CGFloat friction;

/**
 *  Elasticity of the physics shape.
 *  When two objects collide, their elasticity is multiplied together.
 *  The calculated value can be ovrriden in a CCCollisionPairDelegate pre-solve method.
 *  Defaults to 0.2.
 */
@property(nonatomic, assign) CGFloat elasticity;

/**
 *  Velocity of the surface of a shaperelative to it's normal velocity.  This is useful fr modelling convery belts or the feet of a player avatar.
 *  The calculated surface velocity of two colliding shapes by default only affects their friction.
 *  The calculated value can be overriden in a CCCollisionPairDelegate pre-solve method.
 *  Defaults to CGPointZero.
 */
@property(nonatomic, assign) CGPoint surfaceVelocity;


/// -----------------------------------------------------------------------
/// @name Accessing Collision and Contact Attributes
/// -----------------------------------------------------------------------

/**
 *  Is this shape a sensor? A sensor will call a collision delegate but does not physically cause collisions between bodies.
 *  Defaults to NO
 */
@property(nonatomic, assign) BOOL sensor;

/**
 *  The shapes collisionGroup, if two shapes share the same group id, they don't collide.  Default nil
 */
@property(nonatomic, assign) id collisionGroup;

/**
 *  An string that identifies the collision pair delegate method that should be called.  Default @"default"
 */
@property(nonatomic, copy) NSString *collisionType;

/**
 *  An array of NSString category names of which this sahpe is a member.  Up to 32 categories can be used in a single scene.
 *  Default is nil, which means the shape exists in all categories.
 */
@property(nonatomic, copy) NSArray *collisionCategories;

/**
 *  An array of NSString category names that this shape will collide with.
 *  The dedfault is nil, which means the shape collides with all categories.
 */
@property(nonatomic, copy) NSArray *collisionMask;


/// -----------------------------------------------------------------------
/// @name Accessing Misc Attributes
/// -----------------------------------------------------------------------

/** The CCNode to which this physics shape is attached. */
@property(nonatomic, readonly) CCNode *node;

@end
