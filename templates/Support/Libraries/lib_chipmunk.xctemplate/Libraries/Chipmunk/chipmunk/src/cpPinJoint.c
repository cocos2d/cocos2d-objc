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

static void
preStep(cpPinJoint *joint, cpFloat dt)
{
	cpBody *a = joint->constraint.a;
	cpBody *b = joint->constraint.b;
	
	joint->r1 = cpTransformVect(a->transform, cpvsub(joint->anchorA, a->cog));
	joint->r2 = cpTransformVect(b->transform, cpvsub(joint->anchorB, b->cog));
	
	cpVect delta = cpvsub(cpvadd(b->p, joint->r2), cpvadd(a->p, joint->r1));
	cpFloat dist = cpvlength(delta);
	joint->n = cpvmult(delta, 1.0f/(dist ? dist : (cpFloat)INFINITY));
	
	// calculate mass normal
	joint->nMass = 1.0f/k_scalar(a, b, joint->r1, joint->r2, joint->n);
	
	// calculate bias velocity
	cpFloat maxBias = joint->constraint.maxBias;
	joint->bias = cpfclamp(-bias_coef(joint->constraint.errorBias, dt)*(dist - joint->dist)/dt, -maxBias, maxBias);
}

static void
applyCachedImpulse(cpPinJoint *joint, cpFloat dt_coef)
{
	cpBody *a = joint->constraint.a;
	cpBody *b = joint->constraint.b;
	
	cpVect j = cpvmult(joint->n, joint->jnAcc*dt_coef);
	apply_impulses(a, b, joint->r1, joint->r2, j);
}

static void
applyImpulse(cpPinJoint *joint, cpFloat dt)
{
	cpBody *a = joint->constraint.a;
	cpBody *b = joint->constraint.b;
	cpVect n = joint->n;

	// compute relative velocity
	cpFloat vrn = normal_relative_velocity(a, b, joint->r1, joint->r2, n);
	
	cpFloat jnMax = joint->constraint.maxForce*dt;
	
	// compute normal impulse
	cpFloat jn = (joint->bias - vrn)*joint->nMass;
	cpFloat jnOld = joint->jnAcc;
	joint->jnAcc = cpfclamp(jnOld + jn, -jnMax, jnMax);
	jn = joint->jnAcc - jnOld;
	
	// apply impulse
	apply_impulses(a, b, joint->r1, joint->r2, cpvmult(n, jn));
}

static cpFloat
getImpulse(cpPinJoint *joint)
{
	return cpfabs(joint->jnAcc);
}

static const cpConstraintClass klass = {
	(cpConstraintPreStepImpl)preStep,
	(cpConstraintApplyCachedImpulseImpl)applyCachedImpulse,
	(cpConstraintApplyImpulseImpl)applyImpulse,
	(cpConstraintGetImpulseImpl)getImpulse,
};


cpPinJoint *
cpPinJointAlloc(void)
{
	return (cpPinJoint *)cpcalloc(1, sizeof(cpPinJoint));
}

cpPinJoint *
cpPinJointInit(cpPinJoint *joint, cpBody *a, cpBody *b, cpVect anchorA, cpVect anchorB)
{
	cpConstraintInit((cpConstraint *)joint, &klass, a, b);
	
	joint->anchorA = anchorA;
	joint->anchorB = anchorB;
	
	// STATIC_BODY_CHECK
	cpVect p1 = (a ? cpTransformPoint(a->transform, anchorA) : anchorA);
	cpVect p2 = (b ? cpTransformPoint(b->transform, anchorB) : anchorB);
	joint->dist = cpvlength(cpvsub(p2, p1));
	
	cpAssertWarn(joint->dist > 0.0, "You created a 0 length pin joint. A pivot joint will be much more stable.");

	joint->jnAcc = 0.0f;
	
	return joint;
}

cpConstraint *
cpPinJointNew(cpBody *a, cpBody *b, cpVect anchorA, cpVect anchorB)
{
	return (cpConstraint *)cpPinJointInit(cpPinJointAlloc(), a, b, anchorA, anchorB);
}

cpBool
cpConstraintIsPinJoint(const cpConstraint *constraint)
{
	return (constraint->klass == &klass);
}

cpVect
cpPinJointGetAnchorA(const cpConstraint *constraint)
{
	cpAssertHard(cpConstraintIsPinJoint(constraint), "Constraint is not a pin joint.");
	return ((cpPinJoint *)constraint)->anchorA;
}

void
cpPinJointSetAnchorA(cpConstraint *constraint, cpVect anchorA)
{
	cpAssertHard(cpConstraintIsPinJoint(constraint), "Constraint is not a pin joint.");
	cpConstraintActivateBodies(constraint);
	((cpPinJoint *)constraint)->anchorA = anchorA;
}

cpVect
cpPinJointGetAnchorB(const cpConstraint *constraint)
{
	cpAssertHard(cpConstraintIsPinJoint(constraint), "Constraint is not a pin joint.");
	return ((cpPinJoint *)constraint)->anchorB;
}

void
cpPinJointSetAnchorB(cpConstraint *constraint, cpVect anchorB)
{
	cpAssertHard(cpConstraintIsPinJoint(constraint), "Constraint is not a pin joint.");
	cpConstraintActivateBodies(constraint);
	((cpPinJoint *)constraint)->anchorB = anchorB;
}

cpFloat
cpPinJointGetDist(const cpConstraint *constraint)
{
	cpAssertHard(cpConstraintIsPinJoint(constraint), "Constraint is not a pin joint.");
	return ((cpPinJoint *)constraint)->dist;
}

void
cpPinJointSetDist(cpConstraint *constraint, cpFloat dist)
{
	cpAssertHard(cpConstraintIsPinJoint(constraint), "Constraint is not a pin joint.");
	cpConstraintActivateBodies(constraint);
	((cpPinJoint *)constraint)->dist = dist;
}
