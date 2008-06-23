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

// For determinism, you can reset the shape id counter.
void cpResetShapeIdCounter(void);

// Enumeration of shape types.
typedef enum cpShapeType{
	CP_CIRCLE_SHAPE,
	CP_SEGMENT_SHAPE,
	CP_POLY_SHAPE,
	CP_NUM_SHAPES
} cpShapeType;

// Basic shape struct that the others inherit from.
typedef struct cpShape{
	cpShapeType type;

	// Called by cpShapeCacheBB().
	cpBB (*cacheData)(struct cpShape *shape, cpVect p, cpVect rot);
	// Called to by cpShapeDestroy().
	void (*destroy)(struct cpShape *shape);
	
	// Unique id used as the hash value.
	unsigned int id;
	// Cached BBox for the shape.
	cpBB bb;
	
	// User defined collision type for the shape.
	unsigned int collision_type;
	// User defined collision group for the shape.
	unsigned int group;
	// User defined layer bitmask for the shape.
	unsigned int layers;
	
	// User defined data pointer for the shape.
	void *data;
	
	// cpBody that the shape is attached to.
	cpBody *body;
	
	// Coefficient of restitution. (elasticity)
	cpFloat e;
	// Coefficient of friction.
	cpFloat u;
	// Surface velocity used when solving for friction.
	cpVect surface_v;
} cpShape;

// Low level shape initialization func.
cpShape* cpShapeInit(cpShape *shape, cpShapeType type, cpBody *body);

// Basic destructor functions. (allocation functions are not shared)
void cpShapeDestroy(cpShape *shape);
void cpShapeFree(cpShape *shape);

// Cache the BBox of the shape.
cpBB cpShapeCacheBB(cpShape *shape);


// Circle shape structure.
typedef struct cpCircleShape{
	cpShape shape;
	
	// Center. (body space coordinates)
	cpVect c;
	// Radius.
	cpFloat r;
	
	// Transformed center. (world space coordinates)
	cpVect tc;
} cpCircleShape;

// Basic allocation functions for cpCircleShape.
cpCircleShape *cpCircleShapeAlloc(void);
cpCircleShape *cpCircleShapeInit(cpCircleShape *circle, cpBody *body, cpFloat radius, cpVect offset);
cpShape *cpCircleShapeNew(cpBody *body, cpFloat radius, cpVect offset);

// Segment shape structure.
typedef struct cpSegmentShape{
	cpShape shape;
	
	// Endpoints and normal of the segment. (body space coordinates)
	cpVect a, b, n;
	// Radius of the segment. (Thickness)
	cpFloat r;

	// Transformed endpoints and normal. (world space coordinates)
	cpVect ta, tb, tn;
} cpSegmentShape;

// Basic allocation functions for cpSegmentShape.
cpSegmentShape* cpSegmentShapeAlloc(void);
cpSegmentShape* cpSegmentShapeInit(cpSegmentShape *seg, cpBody *body, cpVect a, cpVect b, cpFloat r);
cpShape* cpSegmentShapeNew(cpBody *body, cpVect a, cpVect b, cpFloat r);
