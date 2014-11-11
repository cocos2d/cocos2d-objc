/* Copyright (c) 2013 Scott Lembcke and Howling Moon Software
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/**
	Constraints connect two ChipmunkBody objects together. Most often constraints are simple joints, but can also be things like motors, friction generators or servos.
	
	@htmlonly
	<object width="425" height="344">
		<param name="movie" value="http://www.youtube.com/v/ZgJJZTS0aMM?fs=1&amp;hl=en_US&amp;rel=0"></param>
		<param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param>
		<embed src="http://www.youtube.com/v/ZgJJZTS0aMM?fs=1&amp;hl=en_US&amp;rel=0" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed>
	</object>
	@endhtmlonly
*/
@interface ChipmunkConstraint : NSObject <ChipmunkBaseObject> {
@private
	id _userData;
}

/// Returns a pointer to the underlying cpConstraint C struct.
@property(nonatomic, readonly) cpConstraint *constraint;

/// The first ChipmunkBody the constraint controls.
@property(nonatomic, readonly) ChipmunkBody *bodyA;

/// The second ChipmunkBody the constraint controls.
@property(nonatomic, readonly) ChipmunkBody *bodyB;

/// Get the ChipmunkConstraint object associciated with a cpConstraint pointer.
/// Undefined if the cpConstraint wasn't created using Objective-Chipmunk.
+(ChipmunkConstraint *)constraintFromCPConstraint:(cpConstraint *)constraint;

/**
	Maximum force this constraint is allowed to use (defalts to infinity).
	This allows joints to be pulled apart if too much force is applied to them.
	It also allows you to use constraints as force or friction generators for controlling bodies.
*/
@property(nonatomic, assign) cpFloat maxForce;

/**
	The rate at which joint error is corrected.
	Defaults to pow(1.0 - 0.1, 60.0) meaning that it will correct 10% of the error every 1/60th of a second.
*/
@property(nonatomic, assign) cpFloat errorBias;

/**
	Maximum rate (speed) that a joint can be corrected at (defaults to infinity).
	Setting this value to a finite value allows you to control a joint like a servo motor.
*/
@property(nonatomic, assign) cpFloat maxBias;

/**
	Whether or not the connected bodies should checked for collisions.
	Collisions are filtered before calling callbacks.
	Defaults to TRUE.
*/
@property(nonatomic, assign) BOOL collideBodies;

/// Get the most recent impulse applied by this constraint.
@property(nonatomic, readonly) cpFloat impulse;

/// Get the space the body is added to.
@property(nonatomic, readonly) ChipmunkSpace *space;

/**
	An object that this constraint is associated with. You can use this get a reference to your game object or controller object from within callbacks.
	@attention Like most @c delegate properties this is a weak reference and does not call @c retain. This prevents reference cycles from occuring.
*/
@property(nonatomic, assign) id userData;

/// Override this method to update a constraints parameters just before running the physics each step.
-(void)preSolve:(ChipmunkSpace *)space;

/// Override this method to poll values from a constraint each frame after the physics runs.
/// This can be used to implement breakable joints for instance.
-(void)postSolve:(ChipmunkSpace *)space;

@end


/**
	Pin joints hold a set distance between points on two bodies.
	Think of them as connecting a solid pin or rod between the two anchor points.
*/
@interface ChipmunkPinJoint : ChipmunkConstraint

/**
	Create an autoreleased pin joint between the two bodies with the given anchor points.
	The distance is calculated when the joint is initialized. It can be set explicitly using the property.
*/
+ (ChipmunkPinJoint *)pinJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB;

/**
	Initialize a pin joint between the two bodies with the given anchor points.
	The distance is calculated when the joint is initialized. It can be set explicitly using the property.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB;

/// The anchor point on the first body.
@property(nonatomic, assign) cpVect anchorA;

/// The anchor point on the second body.
@property(nonatomic, assign) cpVect anchorB;

/// The distance between the two anchor points that the joint keeps.
@property(nonatomic, assign) cpFloat dist;

@end


/**
	Slide joints hold the distance between points on two bodies between a minimum and a maximum.
	Think of them as a telescoping ChipmunkPinJoint.
*/
@interface ChipmunkSlideJoint : ChipmunkConstraint

/**
	Create an autoreleased slide joint between the two bodies with the given anchor points and distance range.
*/
+ (ChipmunkSlideJoint *)slideJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB min:(cpFloat)min max:(cpFloat)max;

/**
	Initialize a slide joint between the two bodies with the given anchor points and distance range.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB min:(cpFloat)min max:(cpFloat)max;

/// The anchor point on the first body.
@property(nonatomic, assign) cpVect anchorA;

/// The anchor point on the second body.
@property(nonatomic, assign) cpVect anchorB;

/// The minimum allowed distance between anchor points.
@property(nonatomic, assign) cpFloat min;

/// The maximum allowed distance between anchor points.
@property(nonatomic, assign) cpFloat max;

@end


/**
	Pivot joints hold two points on two bodies together allowing them to rotate freely around the pivot.
*/
@interface ChipmunkPivotJoint : ChipmunkConstraint

/**
	Create an autoreleased pivot joint between the two bodies with the two anchor points.
	Make sure you have the bodies in the right place as the joint will fix itself as soon as you start simulating the space.
*/
+ (ChipmunkPivotJoint *)pivotJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB;

/**
	Create an autoreleased pivot joint between the two bodies by calculating the anchor points from the pivot point given in absolute coordinates.
*/
+ (ChipmunkPivotJoint *)pivotJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b pivot:(cpVect)pivot;

/**
	Initialize a pivot joint between the two bodies with the two anchor points.
	Make sure you have the bodies in the right place as the joint will fix itself as soon as you start simulating the space.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB;

/**
	Initialize a pivot joint between the two bodies by calculating the anchor points from the pivot point given in absolute coordinates.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b pivot:(cpVect)pivot;

/// The anchor point on the first body.
@property(nonatomic, assign) cpVect anchorA;

/// The anchor point on the second body.
@property(nonatomic, assign) cpVect anchorB;

@end


/**
	Groove joints hold a pivot point on one body to line along a line segment on another like a pin in a groove.
*/
@interface ChipmunkGrooveJoint : ChipmunkConstraint

/**
	Create an autoreleased groove joint between the two bodies.
	Make sure you have the bodies in the right place as the joint will snap into shape as soon as you start simulating the space.
	@param grooveA The start of the line segment on the first body.
	@param grooveB The end of the line segment on the first body.
	@param anchorB The anchor point on the second body that is held to the line segment on the first.
*/
+ (ChipmunkGrooveJoint *)grooveJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b grooveA:(cpVect)grooveA grooveB:(cpVect)grooveB anchorB:(cpVect)anchorB;

/**
	Initialize a groove joint between the two bodies.
	Make sure you have the bodies in the right place as the joint will snap into shape as soon as you start simulating the space.
	@param grooveA The start of the line segment on the first body.
	@param grooveB The end of the line segment on the first body.
	@param anchorB The anchor point on the second body that is held to the line segment on the first.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b grooveA:(cpVect)grooveA grooveB:(cpVect)grooveB anchorB:(cpVect)anchorB;

/// The start point of the groove on the first body.
@property(nonatomic, assign) cpVect grooveA;
/// The end point of the groove on the first body.
@property(nonatomic, assign) cpVect grooveB;

/// The anchor point on the second body.
@property(nonatomic, assign) cpVect anchorB;

@end


/**
	A spring with a damper.
	While a spring is not technically a constraint, the damper is. The spring forces are simply a convenience.
*/
@interface ChipmunkDampedSpring : ChipmunkConstraint

/**
	Create an autoreleased damped spring between two bodies at the given anchor points.
	@param restLength The length the spring wants to contract or expand to.
	@param stiffness The <a href="http://en.wikipedia.org/wiki/Young's_modulus">young's modulus</a> of the spring.
	@param damping The amount of viscous damping to apply.
*/
+ (ChipmunkDampedSpring *)dampedSpringWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB restLength:(cpFloat)restLength stiffness:(cpFloat)stiffness damping:(cpFloat)damping;

/**
	Initialize a damped spring between two bodies at the given anchor points.
	@param restLength The length the spring wants to contract or expand to.
	@param stiffness The <a href="http://en.wikipedia.org/wiki/Young's_modulus">young's modulus</a> of the spring.
	@param damping The amount of viscous damping to apply.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b anchorA:(cpVect)anchorA anchorB:(cpVect)anchorB restLength:(cpFloat)restLength stiffness:(cpFloat)stiffness damping:(cpFloat)damping;

/// The anchor point on the first body.
@property(nonatomic, assign) cpVect anchorA;

/// The anchor point on the second body.
@property(nonatomic, assign) cpVect anchorB;

/// The length the spring wants to contract or expand to.
@property(nonatomic, assign) cpFloat restLength;

/// The <a href="http://en.wikipedia.org/wiki/Young's_modulus">young's modulus</a> of the spring.
@property(nonatomic, assign) cpFloat stiffness;

/// The amount of viscous damping to apply.
@property(nonatomic, assign) cpFloat damping;

@end


/**
	Like a ChipmunkDampedSpring, but operates in a rotational fashion.
*/
@interface ChipmunkDampedRotarySpring : ChipmunkConstraint


/**
	Create an autoreleased damped rotary spring between the given bodies.
	@param restAngle The angular offset in radians the spring attempts to keep between the two bodies.
	@param stiffness The <a href="http://en.wikipedia.org/wiki/Young's_modulus">young's modulus</a> of the spring.
	@param damping The amount of viscous damping to apply.
*/
+ (ChipmunkDampedRotarySpring *)dampedRotarySpringWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiffness damping:(cpFloat)damping;

/**
	Initialize a damped rotary spring between the given bodies.
	@param restAngle The angular offset in radians the spring attempts to keep between the two bodies.
	@param stiffness The <a href="http://en.wikipedia.org/wiki/Young's_modulus">young's modulus</a> of the spring.
	@param damping The amount of viscous damping to apply.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiffness damping:(cpFloat)damping;

/// The angular offset the spring attempts to keep between the two bodies.
@property(nonatomic, assign) cpFloat restAngle;

/// The <a href="http://en.wikipedia.org/wiki/Young's_modulus">young's modulus</a> of the spring.
@property(nonatomic, assign) cpFloat stiffness;

/// The amount of viscous damping to apply.
@property(nonatomic, assign) cpFloat damping;

@end


/**
	Constrains the angle between two bodies.
	This joint is often used in conjuction with a separate ChipmunkPivotJoint in order to limit the rotation around the pivot.
*/
@interface ChipmunkRotaryLimitJoint : ChipmunkConstraint

/**
	Create an autoreleased rotary limit joint between the two bodies and angular range in radians.
	Make sure you have the bodies in the right place as the joint will snap into shape as soon as you start simulating the space.
*/
+ (ChipmunkRotaryLimitJoint *)rotaryLimitJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b min:(cpFloat)min max:(cpFloat)max;

/**
	Create an autoreleased rotary limit joint between the two bodies and angular range in radians.
	Make sure you have the bodies in the right place as the joint will snap into shape as soon as you start simulating the space.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b min:(cpFloat)min max:(cpFloat)max;

/// The minimum angular delta of the joint in radians.
@property(nonatomic, assign) cpFloat min;

/// The maximum angular delta of the joint in radians.
@property(nonatomic, assign) cpFloat max;

@end


/**
	Simple motors make two objects spin relative to each other.
	They are most often used with the ChipmunkConstraint.maxForce property set to a finite value.
*/
@interface ChipmunkSimpleMotor : ChipmunkConstraint

/// Create an autoreleased simple motor between the given bodies and relative rotation rate in radians per second.
+ (ChipmunkSimpleMotor *)simpleMotorWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b rate:(cpFloat)rate;

/// Initialize a simple motor between the given bodies and relative rotation rate in radians per second.
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b rate:(cpFloat)rate;

/// The relative rotation speed of the two bodies in radians per second.
@property(nonatomic, assign) cpFloat rate;

@end


/**
	Gear joints constrain the rotational speed of one body to another.
	A ratio of 1.0 will lock the rotation of two bodies together, and negative ratios will cause them to spin in opposite directions.
	You can also use gear joints as rotary servos by setting ChipmunkConstraint.maxForce and ChipmunkConstraint.maxBias to finite values and changing the ChipmunkGearJoint.phase property.
*/
@interface ChipmunkGearJoint : ChipmunkConstraint

/**
	Create an autoreleased gear joint between the given bodies.
	@param phase The angular offset.
	@param ratio The ratio of the rotational speeds.
*/
+ (ChipmunkGearJoint *)gearJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratio:(cpFloat)ratio;

/**
	Initialize a gear joint between the given bodies.
	@param phase The angular offset in radians.
	@param ratio The ratio of the rotational speeds.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratio:(cpFloat)ratio;

/// The angular offset in radians.
@property(nonatomic, assign) cpFloat phase;
/// The ratio of the rotational speeds.
@property(nonatomic, assign) cpFloat ratio;

@end

/**
	Ratchet joints create rotary ratches similar to a socket wrench.
*/
@interface ChipmunkRatchetJoint : ChipmunkConstraint

/**
	Create an autoreleased ratchet joint between the given bodies.
	@param phase The angular offset of the ratchet positions in radians.
	@param ratchet The angle in radians of each ratchet position. Negative values cause the ratchet to operate in the opposite direction.
*/
+ (ChipmunkRatchetJoint *)ratchetJointWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratchet:(cpFloat)ratchet;

/**
	Initialize a ratchet joint between the given bodies.
	@param phase The angular offset of the ratchet positions in radians.
	@param ratchet The angle in radians of each ratchet position. Negative values cause the ratchet to operate in the opposite direction.
*/
- (id)initWithBodyA:(ChipmunkBody *)a bodyB:(ChipmunkBody *)b phase:(cpFloat)phase ratchet:(cpFloat)ratchet;

/// The current ratchet position in radians.
@property(nonatomic, assign) cpFloat angle;

/// The angular offset of the ratchet positions in radians
@property(nonatomic, assign) cpFloat phase;

/// The angle in radians of each ratchet position. Negative values cause the ratchet to operate in the opposite direction.
@property(nonatomic, assign) cpFloat ratchet;

@end
