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
A CCPhysicsJoint connects two CCPhysicsBody objects together, like a joint between bones or a hinge on a door. 
 
 Joints work in a fairly automatic fashion. They are active from the moment they are created. 
 
 When you are done with a joint you invalidate it in order to disable it. This will automatically remove it from the physics simulation.

 @note A joint cannot be reused once it has been invalidated. But you can hold on to it to store its most recent properties which
 you can then use to create a new joint based on the invalidated joint's properties.
 */
@interface CCPhysicsJoint : NSObject


/// -----------------------------------------------------------------------
/// @name Creating Pivot Joints
/// -----------------------------------------------------------------------

/**
*  Creates and returns a pivot joint object between the two bodies specified. The pivot point is specified in the coordinates of the node that bodyA is attached to.
*
*  @param bodyA   One of the two bodies to link together.
*  @param bodyB   One of the two bodies to link together.
*  @param anchorA Joint anchor point is where the two bodies pivot around (center point of rotation). Anchor is relative to bodyA.
*
*  @return The CCPhysicsJoint Object.
*  @see CCPhysicsBody
*/
+(CCPhysicsJoint *)connectedPivotJointWithBodyA:(CCPhysicsBody *)bodyA
                                          bodyB:(CCPhysicsBody *)bodyB
                                        anchorA:(CGPoint)anchorA;
// needed for Swift
-(CCPhysicsJoint *)initWithPivotJointWithBodyA:(CCPhysicsBody *)bodyA
                                         bodyB:(CCPhysicsBody *)bodyB
                                       anchorA:(CGPoint)anchorA;

/// -----------------------------------------------------------------------
/// @name Creating Distance Joints
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a pivot joint between the two bodies and keeps the distance of the two anchor points constant.
 *  The anchor points are specified in the coordinates of the node that the bodies are attached to.
 *  The distance between the anchor points will be calculated when the joint first becomes active.
 *
 *  @param bodyA   One of the two bodies to link together.
 *  @param bodyB   One of the two bodies to link together.
 *  @param anchorA Joint anchor point, relative to bodyA.
 *  @param anchorB Joint anchor point, relative to bodyB.
 *
 *  @return The CCPhysicsJoint Object.
 *  @see CCPhysicsBody
 */
+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA
                                             bodyB:(CCPhysicsBody *)bodyB
                                           anchorA:(CGPoint)anchorA
                                           anchorB:(CGPoint)anchorB;
// needed for Swift
-(CCPhysicsJoint *)initWithDistanceJointWithBodyA:(CCPhysicsBody *)bodyA
                                            bodyB:(CCPhysicsBody *)bodyB
                                          anchorA:(CGPoint)anchorA
                                          anchorB:(CGPoint)anchorB;

/**
 *  Creates and returns a pivot joint between the two bodies and keeps the distance of the two anchor points within the range.
 *  The anchor points are specified in the coordinates of the node that the bodies are attached to.
 *
 *  @param bodyA   One of the two bodies to link together.
 *  @param bodyB   One of the two bodies to link together.
 *  @param anchorA Joint anchor point, relative to bodyA.
 *  @param anchorB Joint anchor point, relative to bodyB.
 *  @param min     The minimum distance to allow between the anchor points.
 *  @param max     The maximum distance to allow between the anchor points.
 *
 *  @return The CCPhysicsJoint Object.
 *  @see CCPhysicsBody
 */
+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA
                                             bodyB:(CCPhysicsBody *)bodyB
                                           anchorA:(CGPoint)anchorA
                                           anchorB:(CGPoint)anchorB
                                       minDistance:(CGFloat)min
                                       maxDistance:(CGFloat)max;
// needed for Swift
-(CCPhysicsJoint *)initWithDistanceJointWithBodyA:(CCPhysicsBody *)bodyA
                                            bodyB:(CCPhysicsBody *)bodyB
                                          anchorA:(CGPoint)anchorA
                                          anchorB:(CGPoint)anchorB
                                      minDistance:(CGFloat)min
                                      maxDistance:(CGFloat)max;

/// -----------------------------------------------------------------------
/// @name Creating Spring Joints
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a spring joint between the two bodies at the specified anchor points. 
 *  The anchor points are specicied in the coordinates of the node that he bodies are attached to.
 *
 *  @param bodyA   One of the two bodies to link together.
 *  @param bodyB   One of the two bodies to link together.
 *  @param anchorA Joint anchor point, relative to bodyA.
 *  @param anchorB Joint anchor point, relative to bodyB.
 *  @param restLength Rest Length.
 *  @param stiffness  Spring stiffness.
 *  @param damping    Sprin damping.
 *
 *  @return The CCPhysicsJoint Object.
 *  @see CCPhysicsBody
 */
+(CCPhysicsJoint *)connectedSpringJointWithBodyA:(CCPhysicsBody *)bodyA
                                           bodyB:(CCPhysicsBody *)bodyB
                                         anchorA:(CGPoint)anchorA
                                         anchorB:(CGPoint)anchorB
                                      restLength:(CGFloat)restLength
                                       stiffness:(CGFloat)stiffness
                                         damping:(CGFloat)damping;
// needed for Swift
-(CCPhysicsJoint *)initWithSpringJointWithBodyA:(CCPhysicsBody *)bodyA
                                          bodyB:(CCPhysicsBody *)bodyB
                                        anchorA:(CGPoint)anchorA
                                        anchorB:(CGPoint)anchorB
                                     restLength:(CGFloat)restLength
                                      stiffness:(CGFloat)stiffness
                                        damping:(CGFloat)damping;

/**
 *  Creates and returns a rotary spring joint between the two bodies. 
 *  No anchor points are specified as this joint can be used in conjunction with a pivot joint to make a springing pivot joint.
 *
 *  @param bodyA   One of the two bodies to link together.
 *  @param bodyB   One of the two bodies to link together.
 *  @param restAngle Rest angle.
 *  @param stiffness  Spring stiffness.
 *  @param damping    Sprin damping.
 *
 *  @return The CCPhysicsJoint Object.
 *  @see CCPhysicsBody
 */
+(CCPhysicsJoint *)connectedRotarySpringJointWithBodyA:(CCPhysicsBody *)bodyA
                                                 bodyB:(CCPhysicsBody *)bodyB
                                             restAngle:(CGFloat)restAngle
                                             stiffness:(CGFloat)stiffness
                                               damping:(CGFloat)damping;
// needed for Swift
-(CCPhysicsJoint *)initWithRotarySpringJointWithBodyA:(CCPhysicsBody *)bodyA
                                                bodyB:(CCPhysicsBody *)bodyB
                                            restAngle:(CGFloat)restAngle
                                            stiffness:(CGFloat)stiffness
                                              damping:(CGFloat)damping;


// This method was misspelled. Please change "stifness" to "stiffness".
+(CCPhysicsJoint *)connectedRotarySpringJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB restAngle:(CGFloat)restAngle stifness:(CGFloat)stiffness damping:(CGFloat)damping __attribute__((deprecated));


/// -----------------------------------------------------------------------
/// @name Creating Motor Joints
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a Motor joint between the two bodies. 
 *  No anchor points are specified as this joint can be used in conjunction with a pivot joint to make a motor around a pivot point.
 *
 *  @param bodyA   One of the two bodies to link together.
 *  @param bodyB   One of the two bodies to link together.
 *  @param rate    Rate at which the rotate relative to each other. Negative values to reverse direction.
 *
 *  @return The CCPhysicsJoint Object.
 *  @see CCPhysicsBody
 */
+(CCPhysicsJoint *)connectedMotorJointWithBodyA:(CCPhysicsBody *)bodyA
                                          bodyB:(CCPhysicsBody *)bodyB
                                           rate:(CGFloat)rate;
// needed for Swift
-(CCPhysicsJoint *)initWithMotorJointWithBodyA:(CCPhysicsBody *)bodyA
                                         bodyB:(CCPhysicsBody *)bodyB
                                          rate:(CGFloat)rate;


/// -----------------------------------------------------------------------
/// @name Creating Rotary Limit Joints
/// -----------------------------------------------------------------------

/**
 *  Creates and returns joint whereby the angle of rotation between too bodies is limited. 
 *  No anchor points are specified as this joint can be used in conjunction with a pivot joint to make the pivots range of motion limited.
 *
 *  @param bodyA   One of the two bodies to link together.
 *  @param bodyB   One of the two bodies to link together.
 *  @param min     Minimum angle in radians.
 *  @param max     Maximum angle in radians.
 *
 *  @return The CCPhysicsJoint Object.
 *  @see CCPhysicsBody
 */
+(CCPhysicsJoint *)connectedRotaryLimitJointWithBodyA:(CCPhysicsBody *)bodyA
                                                bodyB:(CCPhysicsBody *)bodyB
                                                  min:(CGFloat)min
                                                  max:(CGFloat)max;
// needed for Swift
-(CCPhysicsJoint *)initWithRotaryLimitJointWithBodyA:(CCPhysicsBody *)bodyA
                                               bodyB:(CCPhysicsBody *)bodyB
                                                 min:(CGFloat)min
                                                 max:(CGFloat)max;


/// -----------------------------------------------------------------------
/// @name Creating Ratchet Joints
/// -----------------------------------------------------------------------

/**
 *  Creates and returns [ratchet](http://en.wikipedia.org/wiki/Ratchet_%28device%29) joint whereby the angle of rotation between too bodies can go forward smoothly,
 *  but the backwards motion is clipped at 'ratchet' intervals (crrnk-crrnk-crrnk). 
 *  No anchor points are specified as this joint can be used in conjunction with a pivot joint to ratchet its range of motion.
 *
 *  @param bodyA   One of the two bodies to link together.
 *  @param bodyB   One of the two bodies to link together.
 *  @param phase   Phase angle in Radians [0, 2 PI] describing where within the rathet interval the joint is located.
 *  @param ratchet Ratchet interval angle in radians.
 *
 *  @return The CCPhysicsJoint Object.
 *  @see CCPhysicsBody
 */
+(CCPhysicsJoint *)connectedRatchetJointWithBodyA:(CCPhysicsBody *)bodyA
                                            bodyB:(CCPhysicsBody *)bodyB
                                            phase:(CGFloat)phase
                                          ratchet:(CGFloat)ratchet;
// needed for Swift
-(CCPhysicsJoint *)initWithRatchetJointWithBodyA:(CCPhysicsBody *)bodyA
                                           bodyB:(CCPhysicsBody *)bodyB
                                           phase:(CGFloat)phase
                                         ratchet:(CGFloat)ratchet;

/// -----------------------------------------------------------------------
/// @name Removing a Physics Joint
/// -----------------------------------------------------------------------

/** Disable the joint and remove it from the simulation. */
-(void)invalidate;

/// -----------------------------------------------------------------------
/// @name Accessing Connected Physics Bodies
/// -----------------------------------------------------------------------

/** The first body this joint is attached to.
 @see CCPhysicsBody */
@property(nonatomic, readonly) CCPhysicsBody *bodyA;

/** The second body this joint is attached to.
  @see CCPhysicsBody */
@property(nonatomic, readonly) CCPhysicsBody *bodyB;

/// -----------------------------------------------------------------------
/// @name Force and Impulse Settings
/// -----------------------------------------------------------------------

/** Maxium foce this joint is allowed to use. Defaults to INFINITY. */
@property(nonatomic, assign) CGFloat maxForce;

/** Depending on the joint, either the magnitude of the linear or the angular impulse that this joint applied on the previous fixed time step. */
@property(nonatomic, readonly) CGFloat impulse;

/**
 *  Maximum force that can be applied before the joint invalidates (removes) itself. Defaults to INFINITY.
 *
 *  @note To avoid problems with solver accuracy, make sure that breakingForce is lower than [CCPhysicsJoint maxForce].
 */
@property(nonatomic, assign) CGFloat breakingForce;

/// -----------------------------------------------------------------------
/// @name Joint Properties
/// -----------------------------------------------------------------------

/** Whether the connected bodies are allowed to collide with each other. Defaults to YES. */
@property(nonatomic, assign) BOOL collideBodies;

/** Check if the joint is still valid and active. */
@property(nonatomic, readonly) BOOL valid;

@end
