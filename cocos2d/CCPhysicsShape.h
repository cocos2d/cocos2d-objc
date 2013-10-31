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

@interface CCPhysicsShape : NSObject

/// Create a circular shape.
+(CCPhysicsShape *)circleShapeWithRadius:(CGFloat)radius center:(CGPoint)center;
/// Create a box shape with rounded corners.
+(CCPhysicsShape *)rectShape:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
/// Create a pill shape with rounded corners that stretches from 'start' to 'end'.
+(CCPhysicsShape *)pillShapeFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius;
/// Create a convex polygon shape with rounded corners.
/// If the points do not form a convex polygon, then a convex hull will be created for them automatically.
+(CCPhysicsShape *)polygonShapeWithPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;

//MARK: Basic Properties:

/// Mass of this individual shape.
@property(nonatomic, assign) CGFloat mass;
/// Surface friction of the shape.
/// When two objects collide, their friction is multiplied together.
/// The calculated value can be overriden in a CCCollisionPairDelegate pre-solve method.
/// Defaults to 0.7.
@property(nonatomic, assign) CGFloat friction;
/// Surface friction of the shape.
/// When two objects collide, their elaticity is multiplied together.
/// The calculated value can be ovrriden in a CCCollisionPairDelegate pre-solve method.
/// Defaults to 0.2.
@property(nonatomic, assign) CGFloat elasticity;
/// Velocity of the surface of the shape relative to its normal velocity.
/// This is useful for modeling conveyor belts or the feet of a player character.
/// The calculated surface velocity of two colliding shapes by default only affects their friction.
/// The calculated value can be overriden in a CCCollisionPairDelegate pre-solve method.
/// Defaults to CGPointZero.
@property(nonatomic, assign) CGPoint surfaceVelocity;

//MARK: Collision and Contact:

/// Sensors call collision delegate methods, but don't cause collisions between bodies.
/// Defaults to NO.
@property(nonatomic, assign) BOOL sensor;
/// If two shapes share the same group identifier, then they don't collide.
/// Defaults to nil.
@property(nonatomic, assign) id collisionGroup;
/// A string that identifies which collision pair delegate method should be called when this shape collides.
/// Defaults to @"default".
@property(nonatomic, copy) NSString *collisionType;
/// An array of NSStrings of category names of which this shape is a member of.
/// Up to 32 categories can be used in a single scene.
/// The default value is nil, which means the shape exists in all categories.
@property(nonatomic, copy) NSArray *collisionCategories;
/// An array of NSStrings of category names this shape will collide with.
/// The default value is nil, which means the shape collides with all categories.
@property(nonatomic, copy) NSArray *collisionMask;

/// The CCNode this shape is attached to.
@property(nonatomic, readonly) CCNode *node;

@end
