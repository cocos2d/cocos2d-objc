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

cpFloat cp_bias_coef = 0.1f;
cpFloat cp_collision_slop = 0.1f;

cpContact*
cpContactInit(cpContact *con, cpVect p, cpVect n, cpFloat dist, unsigned int hash)
{
	con->p = p;
	con->n = n;
	con->dist = dist;
	
	con->jnAcc = 0.0f;
	con->jtAcc = 0.0f;
	con->jBias = 0.0f;
	
	con->hash = hash;
		
	return con;
}

cpVect
cpContactsSumImpulses(cpContact *contacts, int numContacts)
{
	cpVect sum = cpvzero;
	
	for(int i=0; i<numContacts; i++){
		cpContact *con = &contacts[i];
		cpVect j = cpvmult(con->n, con->jnAcc);
		sum = cpvadd(sum, j);
	}
		
	return sum;
}

cpVect
cpContactsSumImpulsesWithFriction(cpContact *contacts, int numContacts)
{
	cpVect sum = cpvzero;
	
	for(int i=0; i<numContacts; i++){
		cpContact *con = &contacts[i];
		cpVect t = cpvperp(con->n);
		cpVect j = cpvadd(cpvmult(con->n, con->jnAcc), cpvmult(t, con->jtAcc));
		sum = cpvadd(sum, j);
	}
		
	return sum;
}

cpArbiter*
cpArbiterAlloc(void)
{
	return (cpArbiter *)calloc(1, sizeof(cpArbiter));
}

cpArbiter*
cpArbiterInit(cpArbiter *arb, cpShape *a, cpShape *b, int stamp)
{
	arb->numContacts = 0;
	arb->contacts = NULL;
	
	arb->a = a;
	arb->b = b;
	
	arb->stamp = stamp;
		
	return arb;
}

cpArbiter*
cpArbiterNew(cpShape *a, cpShape *b, int stamp)
{
	return cpArbiterInit(cpArbiterAlloc(), a, b, stamp);
}

void
cpArbiterDestroy(cpArbiter *arb)
{
	free(arb->contacts);
}

void
cpArbiterFree(cpArbiter *arb)
{
	if(arb) cpArbiterDestroy(arb);
	free(arb);
}

void
cpArbiterInject(cpArbiter *arb, cpContact *contacts, int numContacts)
{
	// Iterate over the possible pairs to look for hash value matches.
	for(int i=0; i<arb->numContacts; i++){
		cpContact *old = &arb->contacts[i];
		
		for(int j=0; j<numContacts; j++){
			cpContact *new_contact = &contacts[j];
			
			// This could trigger false possitives.
			if(new_contact->hash == old->hash){
				// Copy the persistant contact information.
				new_contact->jnAcc = old->jnAcc;
				new_contact->jtAcc = old->jtAcc;
			}
		}
	}

	free(arb->contacts);
	
	arb->contacts = contacts;
	arb->numContacts = numContacts;
}

void
cpArbiterPreStep(cpArbiter *arb, cpFloat dt_inv)
{
	cpShape *shapea = arb->a;
	cpShape *shapeb = arb->b;
		
	cpFloat e = shapea->e * shapeb->e;
	arb->u = shapea->u * shapeb->u;
	arb->target_v = cpvsub(shapeb->surface_v, shapea->surface_v);

	cpBody *a = shapea->body;
	cpBody *b = shapeb->body;
	
	for(int i=0; i<arb->numContacts; i++){
		cpContact *con = &arb->contacts[i];
		
		// Calculate the offsets.
		con->r1 = cpvsub(con->p, a->p);
		con->r2 = cpvsub(con->p, b->p);
		
		// Calculate the mass normal.
		cpFloat mass_sum = a->m_inv + b->m_inv;
		
		cpFloat r1cn = cpvcross(con->r1, con->n);
		cpFloat r2cn = cpvcross(con->r2, con->n);
		cpFloat kn = mass_sum + a->i_inv*r1cn*r1cn + b->i_inv*r2cn*r2cn;
		con->nMass = 1.0f/kn;
		
		// Calculate the mass tangent.
		cpVect t = cpvperp(con->n);
		cpFloat r1ct = cpvcross(con->r1, t);
		cpFloat r2ct = cpvcross(con->r2, t);
		cpFloat kt = mass_sum + a->i_inv*r1ct*r1ct + b->i_inv*r2ct*r2ct;
		con->tMass = 1.0f/kt;
				
		// Calculate the target bias velocity.
		con->bias = -cp_bias_coef*dt_inv*cpfmin(0.0f, con->dist + cp_collision_slop);
		con->jBias = 0.0f;
		
		// Calculate the target bounce velocity.
		cpVect v1 = cpvadd(a->v, cpvmult(cpvperp(con->r1), a->w));
		cpVect v2 = cpvadd(b->v, cpvmult(cpvperp(con->r2), b->w));
		con->bounce = cpvdot(con->n, cpvsub(v2, v1))*e;
	}
}

void
cpArbiterApplyCachedImpulse(cpArbiter *arb)
{
	cpShape *shapea = arb->a;
	cpShape *shapeb = arb->b;
		
	arb->u = shapea->u * shapeb->u;
	arb->target_v = cpvsub(shapeb->surface_v, shapea->surface_v);

	cpBody *a = shapea->body;
	cpBody *b = shapeb->body;
	
	for(int i=0; i<arb->numContacts; i++){
		cpContact *con = &arb->contacts[i];
		
		cpVect t = cpvperp(con->n);
		cpVect j = cpvadd(cpvmult(con->n, con->jnAcc), cpvmult(t, con->jtAcc));
		cpBodyApplyImpulse(a, cpvneg(j), con->r1);
		cpBodyApplyImpulse(b, j, con->r2);
	}
}

void
cpArbiterApplyImpulse(cpArbiter *arb, cpFloat eCoef)
{
	cpBody *a = arb->a->body;
	cpBody *b = arb->b->body;

	for(int i=0; i<arb->numContacts; i++){
		cpContact *con = &arb->contacts[i];
		cpVect n = con->n;
		cpVect r1 = con->r1;
		cpVect r2 = con->r2;
		
		// Calculate the relative bias velocities.
		cpVect vb1 = cpvadd(a->v_bias, cpvmult(cpvperp(r1), a->w_bias));
		cpVect vb2 = cpvadd(b->v_bias, cpvmult(cpvperp(r2), b->w_bias));
		cpFloat vbn = cpvdot(cpvsub(vb2, vb1), n);
		
		// Calculate and clamp the bias impulse.
		cpFloat jbn = (con->bias - vbn)*con->nMass;
		cpFloat jbnOld = con->jBias;
		con->jBias = cpfmax(jbnOld + jbn, 0.0f);
		jbn = con->jBias - jbnOld;
		
		// Apply the bias impulse.
		cpVect jb = cpvmult(n, jbn);
		cpBodyApplyBiasImpulse(a, cpvneg(jb), r1);
		cpBodyApplyBiasImpulse(b, jb, r2);

		// Calculate the relative velocity.
		cpVect v1 = cpvadd(a->v, cpvmult(cpvperp(r1), a->w));
		cpVect v2 = cpvadd(b->v, cpvmult(cpvperp(r2), b->w));
		cpVect vr = cpvsub(v2, v1);
		cpFloat vrn = cpvdot(vr, n);
		
		// Calculate and clamp the normal impulse.
		cpFloat jn = -(con->bounce*eCoef + vrn)*con->nMass;
		cpFloat jnOld = con->jnAcc;
		con->jnAcc = cpfmax(jnOld + jn, 0.0f);
		jn = con->jnAcc - jnOld;
		
		// Calculate the relative tangent velocity.
		cpVect t = cpvperp(n);
		cpFloat vrt = cpvdot(cpvadd(vr, arb->target_v), t);
		
		// Calculate and clamp the friction impulse.
		cpFloat jtMax = arb->u*con->jnAcc;
		cpFloat jt = -vrt*con->tMass;
		cpFloat jtOld = con->jtAcc;
		con->jtAcc = cpfclamp(jtOld + jt, -jtMax, jtMax);
		jt = con->jtAcc - jtOld;
		
		// Apply the final impulse.
		cpVect j = cpvadd(cpvmult(n, jn), cpvmult(t, jt));
		cpBodyApplyImpulse(a, cpvneg(j), r1);
		cpBodyApplyImpulse(b, j, r2);
	}
}
