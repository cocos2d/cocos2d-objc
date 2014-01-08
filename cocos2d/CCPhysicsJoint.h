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

#import "CCPhysicsBody.h"

/**
CCPhysicsJoints hold two CCPhysicsBodies together in some way like a joint between bones or a hinge on a door. Joints work in a fairly automatic fashion.
They are active from the moment they are created. When you are done with a joint you invalidate it in order to disable it.
Joints cannot be reactivated once they are invalidated.
 */
@interface CCPhysicsJoint : NSObject


/// -----------------------------------------------------------------------
/// @name Creating a CCPhysicsJoint Object
/// -----------------------------------------------------------------------

/**
*  Creates and returns a pivot joint object between the two bodies specified. The pivot point is specified in the coordinates of the node that bodyA is attached to.
*
*  @param bodyA   Body A.
*  @param bodyB   Body B.
*  @param anchorA Anchor point A.
*
*  @return The CCPhysicsJoint Object.
*/
+(CCPhysicsJoint *)connectedPivotJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA;

/**
 *  Creates and returns a pivot joint between the two bodies and keeps the distance of the two anchor points constant.
 *  The anchor points are specified in the coordinates of the node that the bodies are attached to.
 *  The distance between the anchor points will be calculated when the joint first becomes active.
 *
 *  @param bodyA   Body A.
 *  @param bodyB   Body B.
 *  @param anchorA Anchor point A.
 *  @param anchorB Anchor point B.
 *
 *  @return The CCPhysicsJoint Object.
 */
+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
	anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB;

/**
 *  Creates and returns a pivot joint between the two bodies and keeps the distance of the two anchor points within the range.
 *  The anchor points are specified in the coordinates of the node that the bodies are attached to.
 *
 *  @param bodyA   Body A.
 *  @param bodyB   Body B.
 *  @param anchorA Anchor point A.
 *  @param anchorB Anchor point B.
 *  @param min     The minimum distance to allow between the anchor points.
 *  @param max     The maximum distance to allow between the anchor points.
 *
 *  @return The CCPhysicsJoint Object.
 */
+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
	anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
	minDistance:(CGFloat)min maxDistance:(CGFloat)max;

/**
 *  Creates and returns a spring joint between the two bodies at the specified anchor points.  The anchor points are specicied in the coordinates of the node that he bodies are attached to.
 *
 *  @param bodyA   Body A.
 *  @param bodyB   Body B.
 *  @param anchorA Anchor point A.
 *  @param anchorB Anchor point B.
 *  @param restLength Rest Length.
 *  @param stiffness  Spring stiffness.
 *  @param damping    Sprin damping.
 *
 *  @return The CCPhysicsJoint Object.
 */
+(CCPhysicsJoint *)connectedSpringJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
	anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
	restLength:(CGFloat)restLength stiffness:(CGFloat)stiffness damping:(CGFloat)damping;

/// -----------------------------------------------------------------------
/// @name Accessing Physics Joint Attributes
/// -----------------------------------------------------------------------

/** The first body this joint is attached to. */
@property(nonatomic, readonly) CCPhysicsBody *bodyA;

/** The second body this joint is attached to. */
@property(nonatomic, readonly) CCPhysicsBody *bodyB;

/** Maxium foce this joint is allowed to use. Defaults to INFINITY. */
@property(nonatomic, assign) CGFloat maxForce;

/** Whether or not the connected bodies are allowed to collide with each other. Defaults to YES. */
@property(nonatomic, assign) BOOL collideBodies;

/** Depending on the joint, either the magnitude of the linear or angular impulse that this joint applied on the previous fixed time step. */
@property(nonatomic, readonly) CGFloat impulse;

/**
 *  Maximum force that can be applied before the joint disables itself. Defaults to INFINITY
 *  To avoid problems with solver accuracy, make sure that this value is lower than CCPhysicsJoint.maxForce.
 */
@property(nonatomic, assign) CGFloat breakingForce;

/** Check if the joint is still valid and active. */
@property(nonatomic, readonly) BOOL valid;

/** Disable the joint and remove it from the simulation. */
-(void)invalidate;

@end
