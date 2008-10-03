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
 
// Number of frames that contact information should persist.
extern int cp_contact_persistence;

// User collision pair function.
typedef int (*cpCollFunc)(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data);

// Structure for holding collision pair function information.
// Used internally.
typedef struct cpCollPairFunc {
	unsigned int a;
	unsigned int b;
	cpCollFunc func;
	void *data;
} cpCollPairFunc;

typedef struct cpSpace{
	// *** User definable fields
	
	// Number of iterations to use in the impulse solver to solve contacts.
	int iterations;
	
	// Number of iterations to use in the impulse solver to solve elastic collisions.
	int elasticIterations;
	
	// Default gravity to supply when integrating rigid body motions.
	cpVect gravity;
	
	// Default damping to supply when integrating rigid body motions.
	cpFloat damping;
	
	// *** Internally Used Fields
	
	// Time stamp. Is incremented on every call to cpSpaceStep().
	int stamp;

	// The static and active shape spatial hashes.
	cpSpaceHash *staticShapes;
	cpSpaceHash *activeShapes;
	
	// List of bodies in the system.
	cpArray *bodies;
	// List of active arbiters for the impulse solver.
	cpArray *arbiters;
	// Persistant contact set.
	cpHashSet *contactSet;
	
	// List of joints in the system.
	cpArray *joints;
	
	// Set of collisionpair functions.
	cpHashSet *collFuncSet;
	// Default collision pair function.
	cpCollPairFunc defaultPairFunc;
} cpSpace;

// Basic allocation/destruction functions.
cpSpace* cpSpaceAlloc(void);
cpSpace* cpSpaceInit(cpSpace *space);
cpSpace* cpSpaceNew(void);

void cpSpaceDestroy(cpSpace *space);
void cpSpaceFree(cpSpace *space);

// Convenience function. Frees all referenced entities. (bodies, shapes and joints)
void cpSpaceFreeChildren(cpSpace *space);

// Collision pair function management functions.
void cpSpaceAddCollisionPairFunc(cpSpace *space, unsigned int a, unsigned int b,
                                 cpCollFunc func, void *data);
void cpSpaceRemoveCollisionPairFunc(cpSpace *space, unsigned int a, unsigned int b);
void cpSpaceSetDefaultCollisionPairFunc(cpSpace *space, cpCollFunc func, void *data);

// Add and remove entities from the system.
void cpSpaceAddShape(cpSpace *space, cpShape *shape);
void cpSpaceAddStaticShape(cpSpace *space, cpShape *shape);
void cpSpaceAddBody(cpSpace *space, cpBody *body);
void cpSpaceAddJoint(cpSpace *space, cpJoint *joint);

void cpSpaceRemoveShape(cpSpace *space, cpShape *shape);
void cpSpaceRemoveStaticShape(cpSpace *space, cpShape *shape);
void cpSpaceRemoveBody(cpSpace *space, cpBody *body);
void cpSpaceRemoveJoint(cpSpace *space, cpJoint *joint);

// Point query callback function
typedef void (*cpSpacePointQueryFunc)(cpShape *shape, void *data);
void cpSpaceShapePointQuery(cpSpace *space, cpVect point, cpSpacePointQueryFunc func, void *data);
void cpSpaceStaticShapePointQuery(cpSpace *space, cpVect point, cpSpacePointQueryFunc func, void *data);

// Iterator function for iterating the bodies in a space.
typedef void (*cpSpaceBodyIterator)(cpBody *body, void *data);
void cpSpaceEachBody(cpSpace *space, cpSpaceBodyIterator func, void *data);

// Spatial hash management functions.
void cpSpaceResizeStaticHash(cpSpace *space, cpFloat dim, int count);
void cpSpaceResizeActiveHash(cpSpace *space, cpFloat dim, int count);
void cpSpaceRehashStatic(cpSpace *space);

// Update the space.
void cpSpaceStep(cpSpace *space, cpFloat dt);
