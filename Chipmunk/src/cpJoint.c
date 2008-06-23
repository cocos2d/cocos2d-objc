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
pinJointPreStep(cpJoint *joint, cpFloat dt_inv)
{
	cpBody *a = joint->a;
	cpBody *b = joint->b;
	cpPinJoint *jnt = (cpPinJoint *)joint;
	
	cpFloat mass_sum = a->m_inv + b->m_inv;
	
	jnt->r1 = cpvrotate(jnt->anchr1, a->rot);
	jnt->r2 = cpvrotate(jnt->anchr2, b->rot);
	
	cpVect delta = cpvsub(cpvadd(b->p, jnt->r2), cpvadd(a->p, jnt->r1));
	cpFloat dist = cpvlength(delta);
	jnt->n = cpvmult(delta, 1.0f/(dist ? dist : INFINITY));
	
	// calculate mass normal
	cpFloat r1cn = cpvcross(jnt->r1, jnt->n);
	cpFloat r2cn = cpvcross(jnt->r2, jnt->n);
	cpFloat kn = mass_sum + a->i_inv*r1cn*r1cn + b->i_inv*r2cn*r2cn;
	jnt->nMass = 1.0f/kn;
	
	// calculate bias velocity
	jnt->bias = -cp_joint_bias_coef*dt_inv*(dist - jnt->dist);
	jnt->jBias = 0.0f;
	
	// apply accumulated impulse
	cpVect j = cpvmult(jnt->n, jnt->jnAcc);
	cpBodyApplyImpulse(a, cpvneg(j), jnt->r1);
	cpBodyApplyImpulse(b, j, jnt->r2);
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
	cpVect vb1 = cpvadd(a->v_bias, cpvmult(cpvperp(r1), a->w_bias));
	cpVect vb2 = cpvadd(b->v_bias, cpvmult(cpvperp(r2), b->w_bias));
	cpFloat vbn = cpvdot(cpvsub(vb2, vb1), n);
	
	cpFloat jbn = (jnt->bias - vbn)*jnt->nMass;
	jnt->jBias += jbn;
	
	cpVect jb = cpvmult(n, jbn);
	cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
	cpBodyApplyBiasImpulse(b, jb, r2);
	
	// compute relative velocity
	cpVect v1 = cpvadd(a->v, cpvmult(cpvperp(r1), a->w));
	cpVect v2 = cpvadd(b->v, cpvmult(cpvperp(r2), b->w));
	cpFloat vrn = cpvdot(cpvsub(v2, v1), n);
	
	// compute normal impulse
	cpFloat jn = -vrn*jnt->nMass;
	jnt->jnAcc =+ jn;
	
	// apply impulse
	cpVect j = cpvmult(n, jn);
	cpBodyApplyImpulse(a, cpvneg(j), r1);
	cpBodyApplyImpulse(b, j, r2);
}

cpPinJoint *
cpPinJointAlloc(void)
{
	return (cpPinJoint *)malloc(sizeof(cpPinJoint));
}

cpPinJoint *
cpPinJointInit(cpPinJoint *joint, cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2)
{
	joint->joint.preStep = &pinJointPreStep;
	joint->joint.applyImpulse = &pinJointApplyImpulse;
	
	joint->joint.a = a;
	joint->joint.b = b;
	
	joint->anchr1 = anchr1;
	joint->anchr2 = anchr2;
	
	cpVect p1 = cpvadd(a->p, cpvrotate(anchr1, a->rot));
	cpVect p2 = cpvadd(b->p, cpvrotate(anchr2, b->rot));
	joint->dist = cpvlength(cpvsub(p2, p1));

	joint->jnAcc = 0.0;
	
	return joint;
}

cpJoint *
cpPinJointNew(cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2)
{
	return (cpJoint *)cpPinJointInit(cpPinJointAlloc(), a, b, anchr1, anchr2);
}




static void
SlideJointPreStep(cpJoint *joint, cpFloat dt_inv)
{
	cpBody *a = joint->a;
	cpBody *b = joint->b;
	cpSlideJoint *jnt = (cpSlideJoint *)joint;
	
	cpFloat mass_sum = a->m_inv + b->m_inv;
	
	jnt->r1 = cpvrotate(jnt->anchr1, a->rot);
	jnt->r2 = cpvrotate(jnt->anchr2, b->rot);
	
	cpVect delta = cpvsub(cpvadd(b->p, jnt->r2), cpvadd(a->p, jnt->r1));
	cpFloat dist = cpvlength(delta);
	cpFloat pdist = 0.0;
	if(dist > jnt->max) {
		pdist = dist - jnt->max;
	} else if(dist < jnt->min) {
		pdist = jnt->min - dist;
		dist = -dist;
	}
	jnt->n = cpvmult(delta, 1.0f/(dist ? dist : INFINITY));
	
	// calculate mass normal
	cpFloat r1cn = cpvcross(jnt->r1, jnt->n);
	cpFloat r2cn = cpvcross(jnt->r2, jnt->n);
	cpFloat kn = mass_sum + a->i_inv*r1cn*r1cn + b->i_inv*r2cn*r2cn;
	jnt->nMass = 1.0f/kn;
	
	// calculate bias velocity
	jnt->bias = -cp_joint_bias_coef*dt_inv*(pdist);
	jnt->jBias = 0.0f;
	
	// apply accumulated impulse
	if(!jnt->bias) jnt->jnAcc = 0.0f;
	cpVect j = cpvmult(jnt->n, jnt->jnAcc);
	cpBodyApplyImpulse(a, cpvneg(j), jnt->r1);
	cpBodyApplyImpulse(b, j, jnt->r2);
}

static void
SlideJointApplyImpulse(cpJoint *joint)
{
	cpSlideJoint *jnt = (cpSlideJoint *)joint;
	if(!jnt->bias) return;

	cpBody *a = joint->a;
	cpBody *b = joint->b;
	
	cpVect n = jnt->n;
	cpVect r1 = jnt->r1;
	cpVect r2 = jnt->r2;
	
	//calculate bias impulse
	cpVect vb1 = cpvadd(a->v_bias, cpvmult(cpvperp(r1), a->w_bias));
	cpVect vb2 = cpvadd(b->v_bias, cpvmult(cpvperp(r2), b->w_bias));
	cpFloat vbn = cpvdot(cpvsub(vb2, vb1), n);
	
	cpFloat jbn = (jnt->bias - vbn)*jnt->nMass;
	cpFloat jbnOld = jnt->jBias;
	jnt->jBias = cpfmin(jbnOld + jbn, 0.0f);
	jbn = jnt->jBias - jbnOld;
	
	cpVect jb = cpvmult(n, jbn);
	cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
	cpBodyApplyBiasImpulse(b, jb, r2);
	
	// compute relative velocity
	cpVect v1 = cpvadd(a->v, cpvmult(cpvperp(r1), a->w));
	cpVect v2 = cpvadd(b->v, cpvmult(cpvperp(r2), b->w));
	cpFloat vrn = cpvdot(cpvsub(v2, v1), n);
	
	// compute normal impulse
	cpFloat jn = -vrn*jnt->nMass;
	cpFloat jnOld = jnt->jnAcc;
	jnt->jnAcc = cpfmin(jnOld + jn, 0.0f);
	jn = jnt->jnAcc - jnOld;
	
	// apply impulse
	cpVect j = cpvmult(n, jn);
	cpBodyApplyImpulse(a, cpvneg(j), r1);
	cpBodyApplyImpulse(b, j, r2);
}

cpSlideJoint *
cpSlideJointAlloc(void)
{
	return (cpSlideJoint *)malloc(sizeof(cpSlideJoint));
}

cpSlideJoint *
cpSlideJointInit(cpSlideJoint *joint, cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2, cpFloat min, cpFloat max)
{
	joint->joint.preStep = &SlideJointPreStep;
	joint->joint.applyImpulse = &SlideJointApplyImpulse;
	
	joint->joint.a = a;
	joint->joint.b = b;
	
	joint->anchr1 = anchr1;
	joint->anchr2 = anchr2;
	joint->min = min;
	joint->max = max;
	
	joint->jnAcc = 0.0;
	
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
	cpBodyApplyImpulse(a, cpvneg(jnt->jAcc), jnt->r1);
	cpBodyApplyImpulse(b, jnt->jAcc, jnt->r2);
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
	cpVect vb1 = cpvadd(a->v_bias, cpvmult(cpvperp(r1), a->w_bias));
	cpVect vb2 = cpvadd(b->v_bias, cpvmult(cpvperp(r2), b->w_bias));
	cpVect vbr = cpvsub(jnt->bias, cpvsub(vb2, vb1));
	
	cpVect jb = cpv(cpvdot(vbr, k1), cpvdot(vbr, k2));
	jnt->jBias = cpvadd(jnt->jBias, jb);
	
	cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
	cpBodyApplyBiasImpulse(b, jb, r2);
	
	// compute relative velocity
	cpVect v1 = cpvadd(a->v, cpvmult(cpvperp(r1), a->w));
	cpVect v2 = cpvadd(b->v, cpvmult(cpvperp(r2), b->w));
	cpVect vr = cpvsub(v2, v1);
	
	// compute normal impulse
	cpVect j = cpv(-cpvdot(vr, k1), -cpvdot(vr, k2));
	jnt->jAcc = cpvadd(jnt->jAcc, j);
	
	// apply impulse
	cpBodyApplyImpulse(a, cpvneg(j), r1);
	cpBodyApplyImpulse(b, j, r2);
}

cpPivotJoint *
cpPivotJointAlloc(void)
{
	return (cpPivotJoint *)malloc(sizeof(cpPivotJoint));
}

cpPivotJoint *
cpPivotJointInit(cpPivotJoint *joint, cpBody *a, cpBody *b, cpVect pivot)
{
	joint->joint.preStep = &pivotJointPreStep;
	joint->joint.applyImpulse = &pivotJointApplyImpulse;
	
	joint->joint.a = a;
	joint->joint.b = b;
	
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
	if(td < cpvcross(ta, n)){
		jnt->clamp = 1.0f;
		jnt->r1 = cpvsub(ta, a->p);
	} else if(td > cpvcross(tb, n)){
		jnt->clamp = -1.0f;
		jnt->r1 = cpvsub(tb, a->p);
	} else {
		jnt->clamp = 0.0f;
		jnt->r1 = cpvadd(cpvmult(cpvperp(n), -td), cpvmult(n, d));
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
	cpBodyApplyImpulse(a, cpvneg(jnt->jAcc), jnt->r1);
	cpBodyApplyImpulse(b, jnt->jAcc, jnt->r2);
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
	cpVect vb1 = cpvadd(a->v_bias, cpvmult(cpvperp(r1), a->w_bias));
	cpVect vb2 = cpvadd(b->v_bias, cpvmult(cpvperp(r2), b->w_bias));
	cpVect vbr = cpvsub(jnt->bias, cpvsub(vb2, vb1));
	
	cpVect jb = cpv(cpvdot(vbr, k1), cpvdot(vbr, k2));
	cpVect jbOld = jnt->jBias;
	jnt->jBias = grooveConstrain(jnt, cpvadd(jbOld, jb));
	jb = cpvsub(jnt->jBias, jbOld);
	
	cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
	cpBodyApplyBiasImpulse(b, jb, r2);
	
	// compute relative velocity
	cpVect v1 = cpvadd(a->v, cpvmult(cpvperp(r1), a->w));
	cpVect v2 = cpvadd(b->v, cpvmult(cpvperp(r2), b->w));
	cpVect vr = cpvsub(v2, v1);
	
	// compute impulse
	cpVect j = cpv(-cpvdot(vr, k1), -cpvdot(vr, k2));
	cpVect jOld = jnt->jAcc;
	jnt->jAcc = grooveConstrain(jnt, cpvadd(jOld, j));
	j = cpvsub(jnt->jAcc, jOld);
	
	// apply impulse
	cpBodyApplyImpulse(a, cpvneg(j), r1);
	cpBodyApplyImpulse(b, j, r2);
}

cpGrooveJoint *
cpGrooveJointAlloc(void)
{
	return (cpGrooveJoint *)malloc(sizeof(cpGrooveJoint));
}

cpGrooveJoint *
cpGrooveJointInit(cpGrooveJoint *joint, cpBody *a, cpBody *b, cpVect groove_a, cpVect groove_b, cpVect anchr2)
{
	joint->joint.preStep = &grooveJointPreStep;
	joint->joint.applyImpulse = &grooveJointApplyImpulse;
	
	joint->joint.a = a;
	joint->joint.b = b;
	
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

