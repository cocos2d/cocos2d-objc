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

// Determines how fast penetrations resolve themselves.
extern cpFloat cp_bias_coef;
// Amount of allowed penetration. Used to reduce vibrating contacts.
extern cpFloat cp_collision_slop;

// Data structure for contact points.
typedef struct cpContact{
	// Contact point and normal.
	cpVect p, n;
	// Penetration distance.
	cpFloat dist;
	
	// Calculated by cpArbiterPreStep().
	cpVect r1, r2;
	cpFloat nMass, tMass, bounce;

	// Persistant contact information.
	cpFloat jnAcc, jtAcc, jBias;
	cpFloat bias;
	
	// Hash value used to (mostly) uniquely identify a contact.
	unsigned int hash;
} cpContact;

// Contacts are always allocated in groups.
cpContact* cpContactInit(cpContact *con, cpVect p, cpVect n, cpFloat dist, unsigned int hash);

// Sum the contact impulses. (Can be used after cpSpaceStep() returns)
cpVect cpContactsSumImpulses(cpContact *contacts, int numContacts);
cpVect cpContactsSumImpulsesWithFriction(cpContact *contacts, int numContacts);

// Data structure for tracking collisions between shapes.
typedef struct cpArbiter{
	// Information on the contact points between the objects.
	int numContacts;
	cpContact *contacts;
	
	// The two shapes involved in the collision.
	cpShape *a, *b;
	
	// Calculated by cpArbiterPreStep().
	cpFloat u;
	cpVect target_v;
	
	// Time stamp of the arbiter. (from cpSpace)
	int stamp;
} cpArbiter;

// Basic allocation/destruction functions.
cpArbiter* cpArbiterAlloc(void);
cpArbiter* cpArbiterInit(cpArbiter *arb, cpShape *a, cpShape *b, int stamp);
cpArbiter* cpArbiterNew(cpShape *a, cpShape *b, int stamp);

void cpArbiterDestroy(cpArbiter *arb);
void cpArbiterFree(cpArbiter *arb);

// These functions are all intended to be used internally.
// Inject new contact points into the arbiter while preserving contact history.
void cpArbiterInject(cpArbiter *arb, cpContact *contacts, int numContacts);
// Precalculate values used by the solver.
void cpArbiterPreStep(cpArbiter *arb, cpFloat dt_inv);
void cpArbiterApplyCachedImpulse(cpArbiter *arb);
// Run an iteration of the solver on the arbiter.
void cpArbiterApplyImpulse(cpArbiter *arb, cpFloat eCoef);
