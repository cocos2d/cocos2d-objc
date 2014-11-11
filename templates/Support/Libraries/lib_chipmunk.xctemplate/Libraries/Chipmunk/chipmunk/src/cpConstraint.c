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

// TODO: Comment me!

void cpConstraintDestroy(cpConstraint *constraint){}

void
cpConstraintFree(cpConstraint *constraint)
{
	if(constraint){
		cpConstraintDestroy(constraint);
		cpfree(constraint);
	}
}

void
cpConstraintInit(cpConstraint *constraint, const cpConstraintClass *klass, cpBody *a, cpBody *b)
{
	constraint->klass = klass;
	
	constraint->a = a;
	constraint->b = b;
	constraint->space = NULL;
	
	constraint->next_a = NULL;
	constraint->next_b = NULL;
	
	constraint->maxForce = (cpFloat)INFINITY;
	constraint->errorBias = cpfpow(1.0f - 0.1f, 60.0f);
	constraint->maxBias = (cpFloat)INFINITY;
	
	constraint->collideBodies = cpTrue;
	
	constraint->preSolve = NULL;
	constraint->postSolve = NULL;
}

cpSpace *
cpConstraintGetSpace(const cpConstraint *constraint)
{
	return constraint->space;
}

cpBody *
cpConstraintGetBodyA(const cpConstraint *constraint)
{
	return constraint->a;
}

cpBody *
cpConstraintGetBodyB(const cpConstraint *constraint)
{
	return constraint->b;
}

cpFloat
cpConstraintGetMaxForce(const cpConstraint *constraint)
{
	return constraint->maxForce;
}

void
cpConstraintSetMaxForce(cpConstraint *constraint, cpFloat maxForce)
{
	cpAssertHard(maxForce >= 0.0f, "maxForce must be positive.");
	cpConstraintActivateBodies(constraint);
	constraint->maxForce = maxForce;
}

cpFloat
cpConstraintGetErrorBias(const cpConstraint *constraint)
{
	return constraint->errorBias;
}

void
cpConstraintSetErrorBias(cpConstraint *constraint, cpFloat errorBias)
{
	cpAssertHard(errorBias >= 0.0f, "errorBias must be positive.");
	cpConstraintActivateBodies(constraint);
	constraint->errorBias = errorBias;
}

cpFloat
cpConstraintGetMaxBias(const cpConstraint *constraint)
{
	return constraint->maxBias;
}

void
cpConstraintSetMaxBias(cpConstraint *constraint, cpFloat maxBias)
{
	cpAssertHard(maxBias >= 0.0f, "maxBias must be positive.");
	cpConstraintActivateBodies(constraint);
	constraint->maxBias = maxBias;
}

cpBool
cpConstraintGetCollideBodies(const cpConstraint *constraint)
{
	return constraint->collideBodies;
}

void
cpConstraintSetCollideBodies(cpConstraint *constraint, cpBool collideBodies)
{
	cpConstraintActivateBodies(constraint);
	constraint->collideBodies = collideBodies;
}

cpConstraintPreSolveFunc
cpConstraintGetPreSolveFunc(const cpConstraint *constraint)
{
	return constraint->preSolve;
}

void
cpConstraintSetPreSolveFunc(cpConstraint *constraint, cpConstraintPreSolveFunc preSolveFunc)
{
	constraint->preSolve = preSolveFunc;
}

cpConstraintPostSolveFunc
cpConstraintGetPostSolveFunc(const cpConstraint *constraint)
{
	return constraint->postSolve;
}

void
cpConstraintSetPostSolveFunc(cpConstraint *constraint, cpConstraintPostSolveFunc postSolveFunc)
{
	constraint->postSolve = postSolveFunc;
}

cpDataPointer
cpConstraintGetUserData(const cpConstraint *constraint)
{
	return constraint->userData;
}

void
cpConstraintSetUserData(cpConstraint *constraint, cpDataPointer userData)
{
	constraint->userData = userData;
}


cpFloat
cpConstraintGetImpulse(cpConstraint *constraint)
{
	return constraint->klass->getImpulse(constraint);
}
