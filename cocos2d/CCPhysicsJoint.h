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


@interface CCPhysicsJoint : NSObject

/// Connect a pivot joint between the two bodies.
/// The pivot point is specified in the coordinates of the node that bodyA is attached to.
+(CCPhysicsJoint *)connectedPivotJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA;

/// Connect a joint between the two bodies that keeps the distance of the two anchor points constant.
/// The anchor points are specified in the coordinates of the node that the bodies are attached to.
/// The distance is calculated when the joint becomes active.
+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
	anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB;

/// Connect a joint between the two bodies that keeps the distance of the two anchor points within a range.
/// The anchor points are specified in the coordinates of the node that the bodies are attached to.
+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
	anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
	minDistance:(CGFloat)min maxDistance:(CGFloat)max;

/// Connect a spring between the two bodies at the specified anchor points.
/// The anchor points are specified in the coordinates of the node that the bodies are attached to.
+(CCPhysicsJoint *)connectedSpringJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
	anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
	restLength:(CGFloat)restLength stiffness:(CGFloat)stiffness damping:(CGFloat)damping;

/// The first body this joint is attached to.
@property(nonatomic, strong) CCPhysicsBody *bodyA;
/// The second body this joint is attached to.
@property(nonatomic, strong) CCPhysicsBody *bodyB;

/// The maximum force this joint is allowed to use.
/// Defaults to INFINITY.
@property(nonatomic, assign) CGFloat maxForce;

/// Whether not the connected bodies are allowed to collide with one another.
/// Defaults to YES.
@property(nonatomic, assign) BOOL collideBodies;

/// Depending on the joint, either the magnitude of the linear or angular impulse that this joint applied on the previous fixed time step.
@property(nonatomic, readonly) CGFloat impulse;

// Removed due to lack of time before the 3.0 release.
///// Maximum force that can be applied before the joint disables itself.
///// To avoid problems with round-off errors, make sure that this value is lower than CCPhysicsJoint.maxForce.
///// Defaults to INFINITY.
//@property(nonatomic, assign) CGFloat breakingForce;

/// Disable the joint and remove it from the simulation.
-(void)invalidate;

@end
