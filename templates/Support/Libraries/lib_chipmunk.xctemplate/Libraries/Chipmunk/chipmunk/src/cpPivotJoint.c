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
preStep(cpPivotJoint *joint, cpFloat dt)
{
	cpBody *a = joint->constraint.a;
	cpBody *b = joint->constraint.b;
	
	joint->r1 = cpTransformVect(a->transform, cpvsub(joint->anchorA, a->cog));
	joint->r2 = cpTransformVect(b->transform, cpvsub(joint->anchorB, b->cog));
	
	// Calculate mass tensor
	joint-> k = k_tensor(a, b, joint->r1, joint->r2);
	
	// calculate bias velocity
	cpVect delta = cpvsub(cpvadd(b->p, joint->r2), cpvadd(a->p, joint->r1));
	joint->bias = cpvclamp(cpvmult(delta, -bias_coef(joint->constraint.errorBias, dt)/dt), joint->constraint.maxBias);
}

static void
applyCachedImpulse(cpPivotJoint *joint, cpFloat dt_coef)
{
	cpBody *a = joint->constraint.a;
	cpBody *b = joint->constraint.b;
	
	apply_impulses(a, b, joint->r1, joint->r2, cpvmult(joint->jAcc, dt_coef));
}

static void
applyImpulse(cpPivotJoint *joint, cpFloat dt)
{
	cpBody *a = joint->constraint.a;
	cpBody *b = joint->constraint.b;
	
	cpVect r1 = joint->r1;
	cpVect r2 = joint->r2;
		
	// compute relative velocity
	cpVect vr = relative_velocity(a, b, r1, r2);
	
	// compute normal impulse
	cpVect j = cpMat2x2Transform(joint->k, cpvsub(joint->bias, vr));
	cpVect jOld = joint->jAcc;
	joint->jAcc = cpvclamp(cpvadd(joint->jAcc, j), joint->constraint.maxForce*dt);
	j = cpvsub(joint->jAcc, jOld);
	
	// apply impulse
	apply_impulses(a, b, joint->r1, joint->r2, j);
}

static cpFloat
getImpulse(cpConstraint *joint)
{
	return cpvlength(((cpPivotJoint *)joint)->jAcc);
}

static const cpConstraintClass klass = {
	(cpConstraintPreStepImpl)preStep,
	(cpConstraintApplyCachedImpulseImpl)applyCachedImpulse,
	(cpConstraintApplyImpulseImpl)applyImpulse,
	(cpConstraintGetImpulseImpl)getImpulse,
};

cpPivotJoint *
cpPivotJointAlloc(void)
{
	return (cpPivotJoint *)cpcalloc(1, sizeof(cpPivotJoint));
}

cpPivotJoint *
cpPivotJointInit(cpPivotJoint *joint, cpBody *a, cpBody *b, cpVect anchorA, cpVect anchorB)
{
	cpConstraintInit((cpConstraint *)joint, &klass, a, b);
	
	joint->anchorA = anchorA;
	joint->anchorB = anchorB;
	
	joint->jAcc = cpvzero;
	
	return joint;
}

cpConstraint *
cpPivotJointNew2(cpBody *a, cpBody *b, cpVect anchorA, cpVect anchorB)
{
	return (cpConstraint *)cpPivotJointInit(cpPivotJointAlloc(), a, b, anchorA, anchorB);
}

cpConstraint *
cpPivotJointNew(cpBody *a, cpBody *b, cpVect pivot)
{
	cpVect anchorA = (a ? cpBodyWorldToLocal(a, pivot) : pivot);
	cpVect anchorB = (b ? cpBodyWorldToLocal(b, pivot) : pivot);
	return cpPivotJointNew2(a, b, anchorA, anchorB);
}

cpBool
cpConstraintIsPivotJoint(const cpConstraint *constraint)
{
	return (constraint->klass == &klass);
}

cpVect
cpPivotJointGetAnchorA(const cpConstraint *constraint)
{
	cpAssertHard(cpConstraintIsPivotJoint(constraint), "Constraint is not a pivot joint.");
	return ((cpPivotJoint *)constraint)->anchorA;
}

void
cpPivotJointSetAnchorA(cpConstraint *constraint, cpVect anchorA)
{
	cpAssertHard(cpConstraintIsPivotJoint(constraint), "Constraint is not a pivot joint.");
	cpConstraintActivateBodies(constraint);
	((cpPivotJoint *)constraint)->anchorA = anchorA;
}

cpVect
cpPivotJointGetAnchorB(const cpConstraint *constraint)
{
	cpAssertHard(cpConstraintIsPivotJoint(constraint), "Constraint is not a pivot joint.");
	return ((cpPivotJoint *)constraint)->anchorB;
}

void
cpPivotJointSetAnchorB(cpConstraint *constraint, cpVect anchorB)
{
	cpAssertHard(cpConstraintIsPivotJoint(constraint), "Constraint is not a pivot joint.");
	cpConstraintActivateBodies(constraint);
	((cpPivotJoint *)constraint)->anchorB = anchorB;
}
