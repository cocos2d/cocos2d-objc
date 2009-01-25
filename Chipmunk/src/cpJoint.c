/* Copyright (c) 2007 Scott Lembcke
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

#include <stdlib.h>
#include <math.h>

#include "chipmunk.h"

// TODO: Comment me!

cpFloat cp_joint_bias_coef = 0.1f;

void cpJointDestroy(cpJoint *joint){}

void
cpJointFree(cpJoint *joint)
{
	if(joint) cpJointDestroy(joint);
	free(joint);
}

static void
cpJointInit(cpJoint *joint, const cpJointClass *klass, cpBody *a, cpBody *b)
{
	joint->klass = klass;
	joint->a = a;
	joint->b = b;
}


static inline cpVect
relative_velocity(cpVect r1, cpVect v1, cpFloat w1, cpVect r2, cpVect v2, cpFloat w2){
	cpVect v1_sum = cpvadd(v1, cpvmult(cpvperp(r1), w1));
	cpVect v2_sum = cpvadd(v2, cpvmult(cpvperp(r2), w2));
	
	return cpvsub(v2_sum, v1_sum);
}

static inline cpFloat
scalar_k(cpBody *a, cpBody *b, cpVect r1, cpVect r2, cpVect n)
{
	cpFloat mass_sum = a->m_inv + b->m_inv;
	cpFloat r1cn = cpvcross(r1, n);
	cpFloat r2cn = cpvcross(r2, n);

	return mass_sum + a->i_inv*r1cn*r1cn + b->i_inv*r2cn*r2cn;
}

static inline void
apply_impulses(cpBody *a , cpBody *b, cpVect r1, cpVect r2, cpVect j)
{
	cpBodyApplyImpulse(a, cpvneg(j), r1);
	cpBodyApplyImpulse(b, j, r2);
}

static inline void
apply_bias_impulses(cpBody *a , cpBody *b, cpVect r1, cpVect r2, cpVect j)
{
	cpBodyApplyBiasImpulse(a, cpvneg(j), r1);
	cpBodyApplyBiasImpulse(b, j, r2);
}


static void
pinJointPreStep(cpJoint *joint, cpFloat dt_inv)
{
	cpBody *a = joint->a;
	cpBody *b = joint->b;
	cpPinJoint *jnt = (cpPinJoint *)joint;
	
	jnt->r1 = cpvrotate(jnt->anchr1, a->rot);
	jnt->r2 = cpvrotate(jnt->anchr2, b->rot);
	
	cpVect delta = cpvsub(cpvadd(b->p, jnt->r2), cpvadd(a->p, jnt->r1));
	cpFloat dist = cpvlength(delta);
	jnt->n = cpvmult(delta, 1.0f/(dist ? dist : INFINITY));
	
	// calculate mass normal
	jnt->nMass = 1.0f/scalar_k(a, b, jnt->r1, jnt->r2, jnt->n);
	
	// calculate bias velocity
	jnt->bias = -cp_joint_bias_coef*dt_inv*(dist - jnt->dist);
	jnt->jBias = 0.0f;
	
	// apply accumulated impulse
	cpVect j = cpvmult(jnt->n, jnt->jnAcc);
	apply_impulses(a, b, jnt->r1, jnt->r2, j);
}

static void
pinJointApplyImpulse(cpJoint *joint)
{
	cpBody *a = joint->a;
	cpBody *b = joint->b;
	
	cpPinJoint *jnt = (cpPinJoint *)joint;
	cpVect n = jnt->n;
	cpVect r1 = jnt->r1;
	cpVect r2 = jnt->r2;

	//calculate bias impulse
	cpVect vbr = relative_velocity(r1, a->v_bias, a->w_bias, r2, b->v_bias, b->w_bias);
	cpFloat vbn = cpvdot(vbr, n);
	
	cpFloat jbn = (jnt->bias - vbn)*jnt->nMass;
	jnt->jBias += jbn;
	
	cpVect jb = cpvmult(n, jbn);
	apply_bias_impulses(a, b, jnt->r1, jnt->r2, jb);
	
	// compute relative velocity
	cpVect vr = relative_velocity(r1, a->v, a->w, r2, b->v, b->w);
	cpFloat vrn = cpvdot(vr, n);
	
	// compute normal impulse
	cpFloat jn = -vrn*jnt->nMass;
	jnt->jnAcc =+ jn;
	
	// apply impulse
	cpVect j = cpvmult(n, jn);
	apply_impulses(a, b, jnt->r1, jnt->r2, j);
}

static const cpJointClass pinJointClass = {
	CP_PIN_JOINT,
	pinJointPreStep,
	pinJointApplyImpulse,
};

cpPinJoint *
cpPinJointAlloc(void)
{
	return (cpPinJoint *)malloc(sizeof(cpPinJoint));
}

cpPinJoint *
cpPinJointInit(cpPinJoint *joint, cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2)
{
	cpJointInit((cpJoint *)joint, &pinJointClass, a, b);
	
	joint->anchr1 = anchr1;
	joint->anchr2 = anchr2;
	
	cpVect p1 = cpvadd(a->p, cpvrotate(anchr1, a->rot));
	cpVect p2 = cpvadd(b->p, cpvrotate(anchr2, b->rot));
	joint->dist = cpvlength(cpvsub(p2, p1));

	joint->jnAcc = 0.0f;
	
	return joint;
}

cpJoint *
cpPinJointNew(cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2)
{
	return (cpJoint *)cpPinJointInit(cpPinJointAlloc(), a, b, anchr1, anchr2);
}




static void
slideJointPreStep(cpJoint *joint, cpFloat dt_inv)
{
	cpBody *a = joint->a;
	cpBody *b = joint->b;
	cpSlideJoint *jnt = (cpSlideJoint *)joint;
	
	jnt->r1 = cpvrotate(jnt->anchr1, a->rot);
	jnt->r2 = cpvrotate(jnt->anchr2, b->rot);
	
	cpVect delta = cpvsub(cpvadd(b->p, jnt->r2), cpvadd(a->p, jnt->r1));
	cpFloat dist = cpvlength(delta);
	cpFloat pdist = 0.0f;
	if(dist > jnt->max) {
		pdist = dist - jnt->max;
	} else if(dist < jnt->min) {
		pdist = jnt->min - dist;
		dist = -dist;
	}
	jnt->n = cpvmult(delta, 1.0f/(dist ? dist : INFINITY));
	
	// calculate mass normal
	jnt->nMass = 1.0f/scalar_k(a, b, jnt->r1, jnt->r2, jnt->n);
	
	// calculate bias velocity
	jnt->bias = -cp_joint_bias_coef*dt_inv*(pdist);
	jnt->jBias = 0.0f;
	
	// apply accumulated impulse
	if(!jnt->bias) //{
		// if bias is 0, then the joint is not at a limit.
		jnt->jnAcc = 0.0f;
//	} else {
		cpVect j = cpvmult(jnt->n, jnt->jnAcc);
		apply_impulses(a, b, jnt->r1, jnt->r2, j);
//	}
}

static void
slideJointApplyImpulse(cpJoint *joint)
{
	cpSlideJoint *jnt = (cpSlideJoint *)joint;
	if(!jnt->bias) return;  // early exit

	cpBody *a = joint->a;
	cpBody *b = joint->b;
	
	cpVect n = jnt->n;
	cpVect r1 = jnt->r1;
	cpVect r2 = jnt->r2;
	
	//calculate bias impulse
	cpVect vbr = relative_velocity(r1, a->v_bias, a->w_bias, r2, b->v_bias, b->w_bias);
	cpFloat vbn = cpvdot(vbr, n);
	
	cpFloat jbn = (jnt->bias - vbn)*jnt->nMass;
	cpFloat jbnOld = jnt->jBias;
	jnt->jBias = cpfmin(jbnOld + jbn, 0.0f);
	jbn = jnt->jBias - jbnOld;
	
	cpVect jb = cpvmult(n, jbn);
	apply_bias_impulses(a, b, jnt->r1, jnt->r2, jb);
	
	// compute relative velocity
	cpVect vr = relative_velocity(r1, a->v, a->w, r2, b->v, b->w);
	cpFloat vrn = cpvdot(vr, n);
	
	// compute normal impulse
	cpFloat jn = -vrn*jnt->nMass;
	cpFloat jnOld = jnt->jnAcc;
	jnt->jnAcc = cpfmin(jnOld + jn, 0.0f);
	jn = jnt->jnAcc - jnOld;
	
	// apply impulse
	cpVect j = cpvmult(n, jn);
	apply_impulses(a, b, jnt->r1, jnt->r2, j);
}

static const cpJointClass slideJointClass = {
	CP_SLIDE_JOINT,
	slideJointPreStep,
	slideJointApplyImpulse,
};

cpSlideJoint *
cpSlideJointAlloc(void)
{
	return (cpSlideJoint *)malloc(sizeof(cpSlideJoint));
}

cpSlideJoint *
cpSlideJointInit(cpSlideJoint *joint, cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2, cpFloat min, cpFloat max)
{
	cpJointInit((cpJoint *)joint, &slideJointClass, a, b);
	
	joint->anchr1 = anchr1;
	joint->anchr2 = anchr2;
	joint->min = min;
	joint->max = max;
	
	joint->jnAcc = 0.0f;
	
	return joint;
}

cpJoint *
cpSlideJointNew(cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2, cpFloat min, cpFloat max)
{
	return (cpJoint *)cpSlideJointInit(cpSlideJointAlloc(), a, b, anchr1, anchr2, min, max);
}




static void
pivotJointPreStep(cpJoint *joint, cpFloat dt_inv)
{
	cpBody *a = joint->a;
	cpBody *b = joint->b;
	cpPivotJoint *jnt = (cpPivotJoint *)joint;
	
	jnt->r1 = cpvrotate(jnt->anchr1, a->rot);
	jnt->r2 = cpvrotate(jnt->anchr2, b->rot);
	
	// calculate mass matrix
	// If I wasn't lazy, this wouldn't be so gross...
	cpFloat k11, k12, k21, k22;
	
	cpFloat m_sum = a->m_inv + b->m_inv;
	k11 = m_sum; k12 = 0.0f;
	k21 = 0.0f;  k22 = m_sum;
	
	cpFloat r1xsq =  jnt->r1.x * jnt->r1.x * a->i_inv;
	cpFloat r1ysq =  jnt->r1.y * jnt->r1.y * a->i_inv;
	cpFloat r1nxy = -jnt->r1.x * jnt->r1.y * a->i_inv;
	k11 += r1ysq; k12 += r1nxy;
	k21 += r1nxy; k22 += r1xsq;
	
	cpFloat r2xsq =  jnt->r2.x * jnt->r2.x * b->i_inv;
	cpFloat r2ysq =  jnt->r2.y * jnt->r2.y * b->i_inv;
	cpFloat r2nxy = -jnt->r2.x * jnt->r2.y * b->i_inv;
	k11 += r2ysq; k12 += r2nxy;
	k21 += r2nxy; k22 += r2xsq;
	
	cpFloat det_inv = 1.0f/(k11*k22 - k12*k21);
	jnt->k1 = cpv( k22*det_inv, -k12*det_inv);
	jnt->k2 = cpv(-k21*det_inv,  k11*det_inv);
	
	
	// calculate bias velocity
	cpVect delta = cpvsub(cpvadd(b->p, jnt->r2), cpvadd(a->p, jnt->r1));
	jnt->bias = cpvmult(delta, -cp_joint_bias_coef*dt_inv);
	jnt->jBias = cpvzero;
	
	// apply accumulated impulse
	apply_impulses(a, b, jnt->r1, jnt->r2, jnt->jAcc);
}

static void
pivotJointApplyImpulse(cpJoint *joint)
{
	cpBody *a = joint->a;
	cpBody *b = joint->b;
	
	cpPivotJoint *jnt = (cpPivotJoint *)joint;
	cpVect r1 = jnt->r1;
	cpVect r2 = jnt->r2;
	cpVect k1 = jnt->k1;
	cpVect k2 = jnt->k2;
	
	//calculate bias impulse
	cpVect vbr = relative_velocity(r1, a->v_bias, a->w_bias, r2, b->v_bias, b->w_bias);
	vbr = cpvsub(jnt->bias, vbr);
	
	cpVect jb = cpv(cpvdot(vbr, k1), cpvdot(vbr, k2));
	jnt->jBias = cpvadd(jnt->jBias, jb);
	
	apply_bias_impulses(a, b, jnt->r1, jnt->r2, jb);
	
	// compute relative velocity
	cpVect vr = relative_velocity(r1, a->v, a->w, r2, b->v, b->w);
	
	// compute normal impulse
	cpVect j = cpv(-cpvdot(vr, k1), -cpvdot(vr, k2));
	jnt->jAcc = cpvadd(jnt->jAcc, j);
	
	// apply impulse
	apply_impulses(a, b, jnt->r1, jnt->r2, j);
}

static const cpJointClass pivotJointClass = {
	CP_PIVOT_JOINT,
	pivotJointPreStep,
	pivotJointApplyImpulse,
};

cpPivotJoint *
cpPivotJointAlloc(void)
{
	return (cpPivotJoint *)malloc(sizeof(cpPivotJoint));
}

cpPivotJoint *
cpPivotJointInit(cpPivotJoint *joint, cpBody *a, cpBody *b, cpVect pivot)
{
	cpJointInit((cpJoint *)joint, &pivotJointClass, a, b);
	
	joint->anchr1 = cpvunrotate(cpvsub(pivot, a->p), a->rot);
	joint->anchr2 = cpvunrotate(cpvsub(pivot, b->p), b->rot);
	
	joint->jAcc = cpvzero;
	
	return joint;
}

cpJoint *
cpPivotJointNew(cpBody *a, cpBody *b, cpVect pivot)
{
	return (cpJoint *)cpPivotJointInit(cpPivotJointAlloc(), a, b, pivot);
}




static void
grooveJointPreStep(cpJoint *joint, cpFloat dt_inv)
{
	cpBody *a = joint->a;
	cpBody *b = joint->b;
	cpGrooveJoint *jnt = (cpGrooveJoint *)joint;
	
	// calculate endpoints in worldspace
	cpVect ta = cpBodyLocal2World(a, jnt->grv_a);
	cpVect tb = cpBodyLocal2World(a, jnt->grv_b);

	// calculate axis
	cpVect n = cpvrotate(jnt->grv_n, a->rot);
	cpFloat d = cpvdot(ta, n);
	
	jnt->grv_tn = n;
	jnt->r2 = cpvrotate(jnt->anchr2, b->rot);
	
	// calculate tangential distance along the axis of r2
	cpFloat td = cpvcross(cpvadd(b->p, jnt->r2), n);
	// calculate clamping factor and r2
	if(td <= cpvcross(ta, n)){
		jnt->clamp = 1.0f;
		jnt->r1 = cpvsub(ta, a->p);
	} else if(td >= cpvcross(tb, n)){
		jnt->clamp = -1.0f;
		jnt->r1 = cpvsub(tb, a->p);
	} else {
		jnt->clamp = 0.0f;
		jnt->r1 = cpvsub(cpvadd(cpvmult(cpvperp(n), -td), cpvmult(n, d)), a->p);
	}
		
	// calculate mass matrix
	// If I wasn't lazy and wrote a proper matrix class, this wouldn't be so gross...
	cpFloat k11, k12, k21, k22;
	cpFloat m_sum = a->m_inv + b->m_inv;
	
	// start with I*m_sum
	k11 = m_sum; k12 = 0.0f;
	k21 = 0.0f;  k22 = m_sum;
	
	// add the influence from r1
	cpFloat r1xsq =  jnt->r1.x * jnt->r1.x * a->i_inv;
	cpFloat r1ysq =  jnt->r1.y * jnt->r1.y * a->i_inv;
	cpFloat r1nxy = -jnt->r1.x * jnt->r1.y * a->i_inv;
	k11 += r1ysq; k12 += r1nxy;
	k21 += r1nxy; k22 += r1xsq;
	
	// add the influnce from r2
	cpFloat r2xsq =  jnt->r2.x * jnt->r2.x * b->i_inv;
	cpFloat r2ysq =  jnt->r2.y * jnt->r2.y * b->i_inv;
	cpFloat r2nxy = -jnt->r2.x * jnt->r2.y * b->i_inv;
	k11 += r2ysq; k12 += r2nxy;
	k21 += r2nxy; k22 += r2xsq;
	
	// invert
	cpFloat det_inv = 1.0f/(k11*k22 - k12*k21);
	jnt->k1 = cpv( k22*det_inv, -k12*det_inv);
	jnt->k2 = cpv(-k21*det_inv,  k11*det_inv);
	
	
	// calculate bias velocity
	cpVect delta = cpvsub(cpvadd(b->p, jnt->r2), cpvadd(a->p, jnt->r1));
	jnt->bias = cpvmult(delta, -cp_joint_bias_coef*dt_inv);
	jnt->jBias = cpvzero;
	
	// apply accumulated impulse
	apply_impulses(a, b, jnt->r1, jnt->r2, jnt->jAcc);
}

static inline cpVect
grooveConstrain(cpGrooveJoint *jnt, cpVect j){
	cpVect n = jnt->grv_tn;
	cpVect jn = cpvmult(n, cpvdot(j, n));

	cpVect t = cpvperp(n);
	cpFloat coef = (jnt->clamp*cpvcross(j, n) > 0.0f) ? 1.0f : 0.0f;
	cpVect jt = cpvmult(t, cpvdot(j, t)*coef);	
	
	return cpvadd(jn, jt);
}

static void
grooveJointApplyImpulse(cpJoint *joint)
{
	cpBody *a = joint->a;
	cpBody *b = joint->b;
	
	cpGrooveJoint *jnt = (cpGrooveJoint *)joint;
	cpVect r1 = jnt->r1;
	cpVect r2 = jnt->r2;
	cpVect k1 = jnt->k1;
	cpVect k2 = jnt->k2;
	
	//calculate bias impulse
	cpVect vbr = relative_velocity(r1, a->v_bias, a->w_bias, r2, b->v_bias, b->w_bias);
	vbr = cpvsub(jnt->bias, vbr);
	
	cpVect jb = cpv(cpvdot(vbr, k1), cpvdot(vbr, k2));
	cpVect jbOld = jnt->jBias;
	jnt->jBias = grooveConstrain(jnt, cpvadd(jbOld, jb));
	jb = cpvsub(jnt->jBias, jbOld);
	
	apply_bias_impulses(a, b, jnt->r1, jnt->r2, jb);
	
	// compute impulse
	cpVect vr = relative_velocity(r1, a->v, a->w, r2, b->v, b->w);

	cpVect j = cpv(-cpvdot(vr, k1), -cpvdot(vr, k2));
	cpVect jOld = jnt->jAcc;
	jnt->jAcc = grooveConstrain(jnt, cpvadd(jOld, j));
	j = cpvsub(jnt->jAcc, jOld);
	
	// apply impulse
	apply_impulses(a, b, jnt->r1, jnt->r2, j);
}

static const cpJointClass grooveJointClass = {
	CP_GROOVE_JOINT,
	grooveJointPreStep,
	grooveJointApplyImpulse,
};

cpGrooveJoint *
cpGrooveJointAlloc(void)
{
	return (cpGrooveJoint *)malloc(sizeof(cpGrooveJoint));
}

cpGrooveJoint *
cpGrooveJointInit(cpGrooveJoint *joint, cpBody *a, cpBody *b, cpVect groove_a, cpVect groove_b, cpVect anchr2)
{
	cpJointInit((cpJoint *)joint, &grooveJointClass, a, b);
	
	joint->grv_a = groove_a;
	joint->grv_b = groove_b;
	joint->grv_n = cpvperp(cpvnormalize(cpvsub(groove_b, groove_a)));
	joint->anchr2 = anchr2;
	
	joint->jAcc = cpvzero;
	
	return joint;
}

cpJoint *
cpGrooveJointNew(cpBody *a, cpBody *b, cpVect groove_a, cpVect groove_b, cpVect anchr2)
{
	return (cpJoint *)cpGrooveJointInit(cpGrooveJointAlloc(), a, b, groove_a, groove_b, anchr2);
}

