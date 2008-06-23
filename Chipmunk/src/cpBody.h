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
 
typedef struct cpBody{
	// Mass and it's inverse.
	cpFloat m, m_inv;
	// Moment of inertia and it's inverse.
	cpFloat i, i_inv;
	
	// NOTE: v_bias and w_bias are used internally for penetration/joint correction.
	// Linear components of motion (position, velocity, and force)
	cpVect p, v, f, v_bias;
	// Angular components of motion (angle, angular velocity, and torque)
	cpFloat a, w, t, w_bias;
	// Unit length 
	cpVect rot; 
	
//	int active;
} cpBody;

// Basic allocation/destruction functions
cpBody *cpBodyAlloc(void);
cpBody *cpBodyInit(cpBody *body, cpFloat m, cpFloat i);
cpBody *cpBodyNew(cpFloat m, cpFloat i);

void cpBodyDestroy(cpBody *body);
void cpBodyFree(cpBody *body);

// Setters for some of the special properties (mandatory!)
void cpBodySetMass(cpBody *body, cpFloat m);
void cpBodySetMoment(cpBody *body, cpFloat i);
void cpBodySetAngle(cpBody *body, cpFloat a);

// Modify the velocity of an object so that it will 
void cpBodySlew(cpBody *body, cpVect pos, cpFloat dt);

// Integration functions.
void cpBodyUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt);
void cpBodyUpdatePosition(cpBody *body, cpFloat dt);

// Convert body local to world coordinates
static inline cpVect
cpBodyLocal2World(cpBody *body, cpVect v)
{
	return cpvadd(body->p, cpvrotate(v, body->rot));
}

// Convert world to body local coordinates
static inline cpVect
cpBodyWorld2Local(cpBody *body, cpVect v)
{
	return cpvunrotate(cpvsub(v, body->p), body->rot);
}

// Apply an impulse (in world coordinates) to the body.
static inline void
cpBodyApplyImpulse(cpBody *body, cpVect j, cpVect r)
{
	body->v = cpvadd(body->v, cpvmult(j, body->m_inv));
	body->w += body->i_inv*cpvcross(r, j);
}

// Not intended for external use. Used by cpArbiter.c and cpJoint.c.
static inline void
cpBodyApplyBiasImpulse(cpBody *body, cpVect j, cpVect r)
{
	body->v_bias = cpvadd(body->v_bias, cpvmult(j, body->m_inv));
	body->w_bias += body->i_inv*cpvcross(r, j);
}

// Zero the forces on a body.
void cpBodyResetForces(cpBody *body);
// Apply a force (in world coordinates) to a body.
void cpBodyApplyForce(cpBody *body, cpVect f, cpVect r);

// Apply a damped spring force between two bodies.
void cpDampedSpring(cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2, cpFloat rlen, cpFloat k, cpFloat dmp, cpFloat dt);

//int cpBodyMarkLowEnergy(cpBody *body, cpFloat dvsq, int max);
