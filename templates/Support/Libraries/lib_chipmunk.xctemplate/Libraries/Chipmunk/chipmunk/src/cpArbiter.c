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

// TODO: make this generic so I can reuse it for constraints also.
static inline void
unthreadHelper(cpArbiter *arb, cpBody *body)
{
	struct cpArbiterThread *thread = cpArbiterThreadForBody(arb, body);
	cpArbiter *prev = thread->prev;
	cpArbiter *next = thread->next;
	
	if(prev){
		cpArbiterThreadForBody(prev, body)->next = next;
	} else if(body->arbiterList == arb) {
		// IFF prev is NULL and body->arbiterList == arb, is arb at the head of the list.
		// This function may be called for an arbiter that was never in a list.
		// In that case, we need to protect it from wiping out the body->arbiterList pointer.
		body->arbiterList = next;
	}
	
	if(next) cpArbiterThreadForBody(next, body)->prev = prev;
	
	thread->prev = NULL;
	thread->next = NULL;
}

void
cpArbiterUnthread(cpArbiter *arb)
{
	unthreadHelper(arb, arb->body_a);
	unthreadHelper(arb, arb->body_b);
}

cpBool cpArbiterIsFirstContact(const cpArbiter *arb)
{
	return arb->state == CP_ARBITER_STATE_FIRST_COLLISION;
}

cpBool cpArbiterIsRemoval(const cpArbiter *arb)
{
	return arb->state == CP_ARBITER_STATE_INVALIDATED;
}

int cpArbiterGetCount(const cpArbiter *arb)
{
	// Return 0 contacts if we are in a separate callback.
	return (arb->state < CP_ARBITER_STATE_CACHED ? arb->count : 0);
}

cpVect
cpArbiterGetNormal(const cpArbiter *arb)
{
	return cpvmult(arb->n, arb->swapped ? -1.0f : 1.0);
}

cpVect
cpArbiterGetPointA(const cpArbiter *arb, int i)
{
	cpAssertHard(0 <= i && i < cpArbiterGetCount(arb), "Index error: The specified contact index is invalid for this arbiter");
	return cpvadd(arb->body_a->p, arb->contacts[i].r1);
}

cpVect
cpArbiterGetPointB(const cpArbiter *arb, int i)
{
	cpAssertHard(0 <= i && i < cpArbiterGetCount(arb), "Index error: The specified contact index is invalid for this arbiter");
	return cpvadd(arb->body_b->p, arb->contacts[i].r2);
}

cpFloat
cpArbiterGetDepth(const cpArbiter *arb, int i)
{
	cpAssertHard(0 <= i && i < cpArbiterGetCount(arb), "Index error: The specified contact index is invalid for this arbiter");
	
	struct cpContact *con = &arb->contacts[i];
	return cpvdot(cpvadd(cpvsub(con->r2, con->r1), cpvsub(arb->body_b->p, arb->body_a->p)), arb->n);
}

cpContactPointSet
cpArbiterGetContactPointSet(const cpArbiter *arb)
{
	cpContactPointSet set;
	set.count = cpArbiterGetCount(arb);
	
	cpBool swapped = arb->swapped;
	cpVect n = arb->n;
	set.normal = (swapped ? cpvneg(n) : n);
	
	for(int i=0; i<set.count; i++){
		// Contact points are relative to body CoGs;
		cpVect p1 = cpvadd(arb->body_a->p, arb->contacts[i].r1);
		cpVect p2 = cpvadd(arb->body_b->p, arb->contacts[i].r2);
		
		set.points[i].pointA = (swapped ? p2 : p1);
		set.points[i].pointB = (swapped ? p1 : p2);
		set.points[i].distance = cpvdot(cpvsub(p2, p1), n);
	}
	
	return set;
}

void
cpArbiterSetContactPointSet(cpArbiter *arb, cpContactPointSet *set)
{
	int count = set->count;
	cpAssertHard(count == arb->count, "The number of contact points cannot be changed.");
	
	cpBool swapped = arb->swapped;
	arb->n = (swapped ? cpvneg(set->normal) : set->normal);
	
	for(int i=0; i<count; i++){
		// Convert back to CoG relative offsets.
		cpVect p1 = set->points[i].pointA;
		cpVect p2 = set->points[i].pointB;
		
		arb->contacts[i].r1 = cpvsub(swapped ? p2 : p1, arb->body_a->p);
		arb->contacts[i].r2 = cpvsub(swapped ? p1 : p2, arb->body_b->p);
	}
}

cpVect
cpArbiterTotalImpulse(const cpArbiter *arb)
{
	struct cpContact *contacts = arb->contacts;
	cpVect n = arb->n;
	cpVect sum = cpvzero;
	
	for(int i=0, count=cpArbiterGetCount(arb); i<count; i++){
		struct cpContact *con = &contacts[i];
		sum = cpvadd(sum, cpvrotate(n, cpv(con->jnAcc, con->jtAcc)));
	}
		
	return (arb->swapped ? sum : cpvneg(sum));
	return cpvzero;
}

cpFloat
cpArbiterTotalKE(const cpArbiter *arb)
{
	cpFloat eCoef = (1 - arb->e)/(1 + arb->e);
	cpFloat sum = 0.0;
	
	struct cpContact *contacts = arb->contacts;
	for(int i=0, count=cpArbiterGetCount(arb); i<count; i++){
		struct cpContact *con = &contacts[i];
		cpFloat jnAcc = con->jnAcc;
		cpFloat jtAcc = con->jtAcc;
		
		sum += eCoef*jnAcc*jnAcc/con->nMass + jtAcc*jtAcc/con->tMass;
	}
	
	return sum;
}

cpBool
cpArbiterIgnore(cpArbiter *arb)
{
	arb->state = CP_ARBITER_STATE_IGNORE;
	return cpFalse;
}

cpFloat
cpArbiterGetRestitution(const cpArbiter *arb)
{
	return arb->e;
}

void
cpArbiterSetRestitution(cpArbiter *arb, cpFloat restitution)
{
	arb->e = restitution;
}

cpFloat
cpArbiterGetFriction(const cpArbiter *arb)
{
	return arb->u;
}

void
cpArbiterSetFriction(cpArbiter *arb, cpFloat friction)
{
	arb->u = friction;
}

cpVect
cpArbiterGetSurfaceVelocity(cpArbiter *arb)
{
	return cpvmult(arb->surface_vr, arb->swapped ? -1.0f : 1.0);
}

void
cpArbiterSetSurfaceVelocity(cpArbiter *arb, cpVect vr)
{
	arb->surface_vr = cpvmult(vr, arb->swapped ? -1.0f : 1.0);
}

cpDataPointer
cpArbiterGetUserData(const cpArbiter *arb)
{
	return arb->data;
}

void
cpArbiterSetUserData(cpArbiter *arb, cpDataPointer userData)
{
	arb->data = userData;
}

void
cpArbiterGetShapes(const cpArbiter *arb, cpShape **a, cpShape **b)
{
	if(arb->swapped){
		(*a) = (cpShape *)arb->b, (*b) = (cpShape *)arb->a;
	} else {
		(*a) = (cpShape *)arb->a, (*b) = (cpShape *)arb->b;
	}
}

void cpArbiterGetBodies(const cpArbiter *arb, cpBody **a, cpBody **b)
{
	CP_ARBITER_GET_SHAPES(arb, shape_a, shape_b);
	(*a) = shape_a->body;
	(*b) = shape_b->body;
}

cpBool
cpArbiterCallWildcardBeginA(cpArbiter *arb, cpSpace *space)
{
	cpCollisionHandler *handler = arb->handlerA;
	return handler->beginFunc(arb, space, handler->userData);
}

cpBool
cpArbiterCallWildcardBeginB(cpArbiter *arb, cpSpace *space)
{
	cpCollisionHandler *handler = arb->handlerB;
	arb->swapped = !arb->swapped;
	cpBool retval = handler->beginFunc(arb, space, handler->userData);
	arb->swapped = !arb->swapped;
	return retval;
}

cpBool
cpArbiterCallWildcardPreSolveA(cpArbiter *arb, cpSpace *space)
{
	cpCollisionHandler *handler = arb->handlerA;
	return handler->preSolveFunc(arb, space, handler->userData);
}

cpBool
cpArbiterCallWildcardPreSolveB(cpArbiter *arb, cpSpace *space)
{
	cpCollisionHandler *handler = arb->handlerB;
	arb->swapped = !arb->swapped;
	cpBool retval = handler->preSolveFunc(arb, space, handler->userData);
	arb->swapped = !arb->swapped;
	return retval;
}

void
cpArbiterCallWildcardPostSolveA(cpArbiter *arb, cpSpace *space)
{
	cpCollisionHandler *handler = arb->handlerA;
	handler->postSolveFunc(arb, space, handler->userData);
}

void
cpArbiterCallWildcardPostSolveB(cpArbiter *arb, cpSpace *space)
{
	cpCollisionHandler *handler = arb->handlerB;
	arb->swapped = !arb->swapped;
	handler->postSolveFunc(arb, space, handler->userData);
	arb->swapped = !arb->swapped;
}

void
cpArbiterCallWildcardSeparateA(cpArbiter *arb, cpSpace *space)
{
	cpCollisionHandler *handler = arb->handlerA;
	handler->separateFunc(arb, space, handler->userData);
}

void
cpArbiterCallWildcardSeparateB(cpArbiter *arb, cpSpace *space)
{
	cpCollisionHandler *handler = arb->handlerB;
	arb->swapped = !arb->swapped;
	handler->separateFunc(arb, space, handler->userData);
	arb->swapped = !arb->swapped;
}

cpArbiter*
cpArbiterInit(cpArbiter *arb, cpShape *a, cpShape *b)
{
	arb->handler = NULL;
	arb->swapped = cpFalse;
	
	arb->handler = NULL;
	arb->handlerA = NULL;
	arb->handlerB = NULL;
	
	arb->e = 0.0f;
	arb->u = 0.0f;
	arb->surface_vr = cpvzero;
	
	arb->count = 0;
	arb->contacts = NULL;
	
	arb->a = a; arb->body_a = a->body;
	arb->b = b; arb->body_b = b->body;
	
	arb->thread_a.next = NULL;
	arb->thread_b.next = NULL;
	arb->thread_a.prev = NULL;
	arb->thread_b.prev = NULL;
	
	arb->stamp = 0;
	arb->state = CP_ARBITER_STATE_FIRST_COLLISION;
	
	arb->data = NULL;
	
	return arb;
}

static inline cpCollisionHandler *
cpSpaceLookupHandler(cpSpace *space, cpCollisionType a, cpCollisionType b, cpCollisionHandler *defaultValue)
{
	cpCollisionType types[] = {a, b};
	cpCollisionHandler *handler = (cpCollisionHandler *)cpHashSetFind(space->collisionHandlers, CP_HASH_PAIR(a, b), types);
	return (handler ? handler : defaultValue);
}

void
cpArbiterUpdate(cpArbiter *arb, struct cpCollisionInfo *info, cpSpace *space)
{
	const cpShape *a = info->a, *b = info->b;
	
	// For collisions between two similar primitive types, the order could have been swapped since the last frame.
	arb->a = a; arb->body_a = a->body;
	arb->b = b; arb->body_b = b->body;
	
	// Iterate over the possible pairs to look for hash value matches.
	for(int i=0; i<info->count; i++){
		struct cpContact *con = &info->arr[i];
		
		// r1 and r2 store absolute offsets at init time.
		// Need to convert them to relative offsets.
		con->r1 = cpvsub(con->r1, a->body->p);
		con->r2 = cpvsub(con->r2, b->body->p);
		
		// Cached impulses are not zeroed at init time.
		con->jnAcc = con->jtAcc = 0.0f;
		
		for(int j=0; j<arb->count; j++){
			struct cpContact *old = &arb->contacts[j];
			
			// This could trigger false positives, but is fairly unlikely nor serious if it does.
			if(con->hash == old->hash){
				// Copy the persistant contact information.
				con->jnAcc = old->jnAcc;
				con->jtAcc = old->jtAcc;
			}
		}
	}
	
	arb->contacts = info->arr;
	arb->count = info->count;
	arb->n = info->n;
	
	arb->e = a->e * b->e;
	arb->u = a->u * b->u;
	
	cpVect surface_vr = cpvsub(b->surfaceV, a->surfaceV);
	arb->surface_vr = cpvsub(surface_vr, cpvmult(info->n, cpvdot(surface_vr, info->n)));
	
	cpCollisionType typeA = info->a->type, typeB = info->b->type;
	cpCollisionHandler *defaultHandler = &space->defaultHandler;
	cpCollisionHandler *handler = arb->handler = cpSpaceLookupHandler(space, typeA, typeB, defaultHandler);
	
	// Check if the types match, but don't swap for a default handler which use the wildcard for type A.
	cpBool swapped = arb->swapped = (typeA != handler->typeA && handler->typeA != CP_WILDCARD_COLLISION_TYPE);
	
	if(handler != defaultHandler || space->usesWildcards){
		// The order of the main handler swaps the wildcard handlers too. Uffda.
		arb->handlerA = cpSpaceLookupHandler(space, (swapped ? typeB : typeA), CP_WILDCARD_COLLISION_TYPE, &cpCollisionHandlerDoNothing);
		arb->handlerB = cpSpaceLookupHandler(space, (swapped ? typeA : typeB), CP_WILDCARD_COLLISION_TYPE, &cpCollisionHandlerDoNothing);
	}
		
	// mark it as new if it's been cached
	if(arb->state == CP_ARBITER_STATE_CACHED) arb->state = CP_ARBITER_STATE_FIRST_COLLISION;
}

void
cpArbiterPreStep(cpArbiter *arb, cpFloat dt, cpFloat slop, cpFloat bias)
{
	cpBody *a = arb->body_a;
	cpBody *b = arb->body_b;
	cpVect n = arb->n;
	cpVect body_delta = cpvsub(b->p, a->p);
	
	for(int i=0; i<arb->count; i++){
		struct cpContact *con = &arb->contacts[i];
		
		// Calculate the mass normal and mass tangent.
		con->nMass = 1.0f/k_scalar(a, b, con->r1, con->r2, n);
		con->tMass = 1.0f/k_scalar(a, b, con->r1, con->r2, cpvperp(n));
				
		// Calculate the target bias velocity.
		cpFloat dist = cpvdot(cpvadd(cpvsub(con->r2, con->r1), body_delta), n);
		con->bias = -bias*cpfmin(0.0f, dist + slop)/dt;
		con->jBias = 0.0f;
		
		// Calculate the target bounce velocity.
		con->bounce = normal_relative_velocity(a, b, con->r1, con->r2, n)*arb->e;
	}
}

void
cpArbiterApplyCachedImpulse(cpArbiter *arb, cpFloat dt_coef)
{
	if(cpArbiterIsFirstContact(arb)) return;
	
	cpBody *a = arb->body_a;
	cpBody *b = arb->body_b;
	cpVect n = arb->n;
	
	for(int i=0; i<arb->count; i++){
		struct cpContact *con = &arb->contacts[i];
		cpVect j = cpvrotate(n, cpv(con->jnAcc, con->jtAcc));
		apply_impulses(a, b, con->r1, con->r2, cpvmult(j, dt_coef));
	}
}

// TODO: is it worth splitting velocity/position correction?

void
cpArbiterApplyImpulse(cpArbiter *arb)
{
	cpBody *a = arb->body_a;
	cpBody *b = arb->body_b;
	cpVect n = arb->n;
	cpVect surface_vr = arb->surface_vr;
	cpFloat friction = arb->u;

	for(int i=0; i<arb->count; i++){
		struct cpContact *con = &arb->contacts[i];
		cpFloat nMass = con->nMass;
		cpVect r1 = con->r1;
		cpVect r2 = con->r2;
		
		cpVect vb1 = cpvadd(a->v_bias, cpvmult(cpvperp(r1), a->w_bias));
		cpVect vb2 = cpvadd(b->v_bias, cpvmult(cpvperp(r2), b->w_bias));
		cpVect vr = cpvadd(relative_velocity(a, b, r1, r2), surface_vr);
		
		cpFloat vbn = cpvdot(cpvsub(vb2, vb1), n);
		cpFloat vrn = cpvdot(vr, n);
		cpFloat vrt = cpvdot(vr, cpvperp(n));
		
		cpFloat jbn = (con->bias - vbn)*nMass;
		cpFloat jbnOld = con->jBias;
		con->jBias = cpfmax(jbnOld + jbn, 0.0f);
		
		cpFloat jn = -(con->bounce + vrn)*nMass;
		cpFloat jnOld = con->jnAcc;
		con->jnAcc = cpfmax(jnOld + jn, 0.0f);
		
		cpFloat jtMax = friction*con->jnAcc;
		cpFloat jt = -vrt*con->tMass;
		cpFloat jtOld = con->jtAcc;
		con->jtAcc = cpfclamp(jtOld + jt, -jtMax, jtMax);
		
		apply_bias_impulses(a, b, r1, r2, cpvmult(n, con->jBias - jbnOld));
		apply_impulses(a, b, r1, r2, cpvrotate(n, cpv(con->jnAcc - jnOld, con->jtAcc - jtOld)));
	}
}
