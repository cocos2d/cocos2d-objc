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

#include "chipmunk/chipmunk_private.h"

static cpFloat
defaultSpringTorque(cpDampedRotarySpring *spring, cpFloat relativeAngle){
	return (relativeAngle - spring->restAngle)*spring->stiffness;
}

static void
preStep(cpDampedRotarySpring *spring, cpFloat dt)
{
	cpBody *a = spring->constraint.a;
	cpBody *b = spring->constraint.b;
	
	cpFloat moment = a->i_inv + b->i_inv;
	cpAssertSoft(moment != 0.0, "Unsolvable spring.");
	spring->iSum = 1.0f/moment;

	spring->w_coef = 1.0f - cpfexp(-spring->damping*dt*moment);
	spring->target_wrn = 0.0f;

	// apply spring torque
	cpFloat j_spring = spring->springTorqueFunc((cpConstraint *)spring, a->a - b->a)*dt;
	spring->jAcc = j_spring;
	
	a->w -= j_spring*a->i_inv;
	b->w += j_spring*b->i_inv;
}

static void applyCachedImpulse(cpDampedRotarySpring *spring, cpFloat dt_coef){}

static void
applyImpulse(cpDampedRotarySpring *spring, cpFloat dt)
{
	cpBody *a = spring->constraint.a;
	cpBody *b = spring->constraint.b;
	
	// compute relative velocity
	cpFloat wrn = a->w - b->w;//normal_relative_velocity(a, b, r1, r2, n) - spring->target_vrn;
	
	// compute velocity loss from drag
	// not 100% certain this is derived correctly, though it makes sense
	cpFloat w_damp = (spring->target_wrn - wrn)*spring->w_coef;
	spring->target_wrn = wrn + w_damp;
	
	//apply_impulses(a, b, spring->r1, spring->r2, cpvmult(spring->n, v_damp*spring->nMass));
	cpFloat j_damp = w_damp*spring->iSum;
	spring->jAcc += j_damp;
	
	a->w += j_damp*a->i_inv;
	b->w -= j_damp*b->i_inv;
}

static cpFloat
getImpulse(cpDampedRotarySpring *spring)
{
	return spring->jAcc;
}

static const cpConstraintClass klass = {
	(cpConstraintPreStepImpl)preStep,
	(cpConstraintApplyCachedImpulseImpl)applyCachedImpulse,
	(cpConstraintApplyImpulseImpl)applyImpulse,
	(cpConstraintGetImpulseImpl)getImpulse,
};

cpDampedRotarySpring *
cpDampedRotarySpringAlloc(void)
{
	return (cpDampedRotarySpring *)cpcalloc(1, sizeof(cpDampedRotarySpring));
}

cpDampedRotarySpring *
cpDampedRotarySpringInit(cpDampedRotarySpring *spring, cpBody *a, cpBody *b, cpFloat restAngle, cpFloat stiffness, cpFloat damping)
{
	cpConstraintInit((cpConstraint *)spring, &klass, a, b);
	
	spring->restAngle = restAngle;
	spring->stiffness = stiffness;
	spring->damping = damping;
	spring->springTorqueFunc = (cpDampedRotarySpringTorqueFunc)defaultSpringTorque;
	
	spring->jAcc = 0.0f;
	
	return spring;
}

cpConstraint *
cpDampedRotarySpringNew(cpBody *a, cpBody *b, cpFloat restAngle, cpFloat stiffness, cpFloat damping)
{
	return (cpConstraint *)cpDampedRotarySpringInit(cpDampedRotarySpringAlloc(), a, b, restAngle, stiffness, damping);
}

cpBool
cpConstraintIsDampedRotarySpring(const cpConstraint *constraint)
{
	return (constraint->klass == &klass);
}

cpFloat
cpDampedRotarySpringGetRestAngle(const cpConstraint *constraint)
{
	cpAssertHard(cpConstraintIsDampedRotarySpring(constraint), "Constraint is not a damped rotary spring.");
	return ((cpDampedRotarySpring *)constraint)->restAngle;
}

void
cpDampedRotarySpringSetRestAngle(cpConstraint *constraint, cpFloat restAngle)
{
	cpAssertHard(cpConstraintIsDampedRotarySpring(constraint), "Constraint is not a damped rotary spring.");
	cpConstraintActivateBodies(constraint);
	((cpDampedRotarySpring *)constraint)->restAngle = restAngle;
}

cpFloat
cpDampedRotarySpringGetStiffness(const cpConstraint *constraint)
{
	cpAssertHard(cpConstraintIsDampedRotarySpring(constraint), "Constraint is not a damped rotary spring.");
	return ((cpDampedRotarySpring *)constraint)->stiffness;
}

void
cpDampedRotarySpringSetStiffness(cpConstraint *constraint, cpFloat stiffness)
{
	cpAssertHard(cpConstraintIsDampedRotarySpring(constraint), "Constraint is not a damped rotary spring.");
	cpConstraintActivateBodies(constraint);
	((cpDampedRotarySpring *)constraint)->stiffness = stiffness;
}

cpFloat
cpDampedRotarySpringGetDamping(const cpConstraint *constraint)
{
	cpAssertHard(cpConstraintIsDampedRotarySpring(constraint), "Constraint is not a damped rotary spring.");
	return ((cpDampedRotarySpring *)constraint)->damping;
}

void
cpDampedRotarySpringSetDamping(cpConstraint *constraint, cpFloat damping)
{
	cpAssertHard(cpConstraintIsDampedRotarySpring(constraint), "Constraint is not a damped rotary spring.");
	cpConstraintActivateBodies(constraint);
	((cpDampedRotarySpring *)constraint)->damping = damping;
}

cpDampedRotarySpringTorqueFunc
cpDampedRotarySpringGetSpringTorqueFunc(const cpConstraint *constraint)
{
	cpAssertHard(cpConstraintIsDampedRotarySpring(constraint), "Constraint is not a damped rotary spring.");
	return ((cpDampedRotarySpring *)constraint)->springTorqueFunc;
}

void
cpDampedRotarySpringSetSpringTorqueFunc(cpConstraint *constraint, cpDampedRotarySpringTorqueFunc springTorqueFunc)
{
	cpAssertHard(cpConstraintIsDampedRotarySpring(constraint), "Constraint is not a damped rotary spring.");
	cpConstraintActivateBodies(constraint);
	((cpDampedRotarySpring *)constraint)->springTorqueFunc = springTorqueFunc;
}
