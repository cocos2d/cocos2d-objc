/*
* Copyright (c) 2006-2009 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

#include "b2World.h"
#include "b2Body.h"
#include "b2Fixture.h"
#include "b2Island.h"
#include "Joints/b2PulleyJoint.h"
#include "Contacts/b2Contact.h"
#include "Contacts/b2ContactSolver.h"
#include "Controllers/b2Controller.h"
#include "../Collision/b2Collision.h"
#include "../Collision/Shapes/b2CircleShape.h"
#include "../Collision/Shapes/b2PolygonShape.h"
#include "../Collision/Shapes/b2EdgeShape.h"
#include <new>

b2ContactFilter b2_defaultFilter;
b2ContactListener b2_defaultListener;

b2World::b2World(const b2AABB& worldAABB, const b2Vec2& gravity, bool doSleep)
{
	m_destructionListener = NULL;
	m_boundaryListener = NULL;
	m_contactFilter = &b2_defaultFilter;
	m_contactListener = &b2_defaultListener;
	m_debugDraw = NULL;

	m_bodyList = NULL;
	m_contactList = NULL;
	m_jointList = NULL;
	m_controllerList = NULL;

	m_bodyCount = 0;
	m_contactCount = 0;
	m_jointCount = 0;
	m_controllerCount = 0;

	m_warmStarting = true;
	m_continuousPhysics = true;

	m_allowSleep = doSleep;
	m_gravity = gravity;

	m_lock = false;

	m_inv_dt0 = 0.0f;

	m_contactManager.m_world = this;
	void* mem = b2Alloc(sizeof(b2BroadPhase));
	m_broadPhase = new (mem) b2BroadPhase(worldAABB, &m_contactManager);

	b2BodyDef bd;
	m_groundBody = CreateBody(&bd);
}

b2World::~b2World()
{
	DestroyBody(m_groundBody);
	m_broadPhase->~b2BroadPhase();
	b2Free(m_broadPhase);
}

void b2World::SetDestructionListener(b2DestructionListener* listener)
{
	m_destructionListener = listener;
}

void b2World::SetBoundaryListener(b2BoundaryListener* listener)
{
	m_boundaryListener = listener;
}

void b2World::SetContactFilter(b2ContactFilter* filter)
{
	m_contactFilter = filter;
}

void b2World::SetContactListener(b2ContactListener* listener)
{
	m_contactListener = listener;
}

void b2World::SetDebugDraw(b2DebugDraw* debugDraw)
{
	m_debugDraw = debugDraw;
}

b2Body* b2World::CreateBody(const b2BodyDef* def)
{
	void* mem = m_blockAllocator.Allocate(sizeof(b2Body));
	b2Body* b = new (mem) b2Body(def, this);

	// Add to world doubly linked list.
	b->m_prev = NULL;
	b->m_next = m_bodyList;
	if (m_bodyList)
	{
		m_bodyList->m_prev = b;
	}
	m_bodyList = b;
	++m_bodyCount;

	return b;
}

void b2World::DestroyBody(b2Body* b)
{
	b2Assert(m_bodyCount > 0);

	// Delete the attached joints.
	b2JointEdge* jn = b->m_jointList;
	while (jn)
	{
		b2JointEdge* jn0 = jn;
		jn = jn->next;

		if (m_destructionListener)
		{
			m_destructionListener->SayGoodbye(jn0->joint);
		}

		DestroyJoint(jn0->joint);
	}

	//Detach controllers attached to this body
	b2ControllerEdge* ce = b->m_controllerList;
	while(ce)
	{
		b2ControllerEdge* ce0 = ce;
		ce = ce->nextController;

		ce0->controller->RemoveBody(b);
	}

	// Delete the attached fixtures. This destroys broad-phase
	// proxies and pairs, leading to the destruction of contacts.
	b2Fixture* f = b->m_fixtureList;
	while (f)
	{
		b2Fixture* f0 = f;
		f = f->m_next;

		if (m_destructionListener)
		{
			m_destructionListener->SayGoodbye(f0);
		}

		f0->Destroy(&m_blockAllocator, m_broadPhase);
		f0->~b2Fixture();
		m_blockAllocator.Free(f0, sizeof(b2Fixture));
	}

	// Remove world body list.
	if (b->m_prev)
	{
		b->m_prev->m_next = b->m_next;
	}

	if (b->m_next)
	{
		b->m_next->m_prev = b->m_prev;
	}

	if (b == m_bodyList)
	{
		m_bodyList = b->m_next;
	}

	--m_bodyCount;
	b->~b2Body();
	m_blockAllocator.Free(b, sizeof(b2Body));
}

b2Joint* b2World::CreateJoint(const b2JointDef* def)
{
	b2Joint* j = b2Joint::Create(def, &m_blockAllocator);

	// Connect to the world list.
	j->m_prev = NULL;
	j->m_next = m_jointList;
	if (m_jointList)
	{
		m_jointList->m_prev = j;
	}
	m_jointList = j;
	++m_jointCount;

	// Connect to the bodies' doubly linked lists.
	j->m_node1.joint = j;
	j->m_node1.other = j->m_body2;
	j->m_node1.prev = NULL;
	j->m_node1.next = j->m_body1->m_jointList;
	if (j->m_body1->m_jointList) j->m_body1->m_jointList->prev = &j->m_node1;
	j->m_body1->m_jointList = &j->m_node1;

	j->m_node2.joint = j;
	j->m_node2.other = j->m_body1;
	j->m_node2.prev = NULL;
	j->m_node2.next = j->m_body2->m_jointList;
	if (j->m_body2->m_jointList) j->m_body2->m_jointList->prev = &j->m_node2;
	j->m_body2->m_jointList = &j->m_node2;

	// If the joint prevents collisions, then reset collision filtering.
	if (def->collideConnected == false)
	{
		// Reset the proxies on the body with the minimum number of fixtures.
		b2Body* b = def->body1->m_fixtureCount < def->body2->m_fixtureCount ? def->body1 : def->body2;
		for (b2Fixture* f = b->m_fixtureList; f; f = f->m_next)
		{
			f->RefilterProxy(m_broadPhase, b->GetXForm());
		}
	}

	return j;
}

void b2World::DestroyJoint(b2Joint* j)
{
	bool collideConnected = j->m_collideConnected;

	// Remove from the doubly linked list.
	if (j->m_prev)
	{
		j->m_prev->m_next = j->m_next;
	}

	if (j->m_next)
	{
		j->m_next->m_prev = j->m_prev;
	}

	if (j == m_jointList)
	{
		m_jointList = j->m_next;
	}

	// Disconnect from island graph.
	b2Body* body1 = j->m_body1;
	b2Body* body2 = j->m_body2;

	// Wake up connected bodies.
	body1->WakeUp();
	body2->WakeUp();

	// Remove from body 1.
	if (j->m_node1.prev)
	{
		j->m_node1.prev->next = j->m_node1.next;
	}

	if (j->m_node1.next)
	{
		j->m_node1.next->prev = j->m_node1.prev;
	}

	if (&j->m_node1 == body1->m_jointList)
	{
		body1->m_jointList = j->m_node1.next;
	}

	j->m_node1.prev = NULL;
	j->m_node1.next = NULL;

	// Remove from body 2
	if (j->m_node2.prev)
	{
		j->m_node2.prev->next = j->m_node2.next;
	}

	if (j->m_node2.next)
	{
		j->m_node2.next->prev = j->m_node2.prev;
	}

	if (&j->m_node2 == body2->m_jointList)
	{
		body2->m_jointList = j->m_node2.next;
	}

	j->m_node2.prev = NULL;
	j->m_node2.next = NULL;

	b2Joint::Destroy(j, &m_blockAllocator);

	b2Assert(m_jointCount > 0);
	--m_jointCount;

	// If the joint prevents collisions, then reset collision filtering.
	if (collideConnected == false)
	{
		// Reset the proxies on the body with the minimum number of fixtures.
		b2Body* b = body1->m_fixtureCount < body2->m_fixtureCount ? body1 : body2;
		for (b2Fixture* f = b->m_fixtureList; f; f = f->m_next)
		{
			f->RefilterProxy(m_broadPhase, b->GetXForm());
		}
	}
}

b2Controller* b2World::CreateController( const b2ControllerDef* def)
{
	b2Controller* controller = def->Create(&m_blockAllocator);

	controller->m_next = m_controllerList;
	controller->m_prev = NULL;

	if (m_controllerList)
	{
		m_controllerList->m_prev = controller;
	}
	
	m_controllerList = controller;
	++m_controllerCount;

	controller->m_world = this;

	return controller;
}

void b2World::DestroyController(b2Controller* controller)
{
	b2Assert(m_controllerCount>0);
	
	if(controller->m_next)
	{
		controller->m_next->m_prev = controller->m_prev;
	}

	if(controller->m_prev)
	{
		controller->m_prev->m_next = controller->m_next;
	}

	if(controller == m_controllerList)
	{
		m_controllerList = controller->m_next;
	}

	--m_controllerCount;

	b2Controller::Destroy(controller, &m_blockAllocator);
}

void b2World::Refilter(b2Fixture* fixture)
{
	fixture->RefilterProxy(m_broadPhase, fixture->GetBody()->GetXForm());
}

// Find islands, integrate and solve constraints, solve position constraints
void b2World::Solve(const b2TimeStep& step)
{
	// Step all controllers
	for(b2Controller* controller = m_controllerList; controller; controller = controller->m_next)
	{
		controller->Step(step);
	}

	// Size the island for the worst case.
	b2Island island(m_bodyCount, m_contactCount, m_jointCount, &m_stackAllocator, m_contactListener);

	// Clear all the island flags.
	for (b2Body* b = m_bodyList; b; b = b->m_next)
	{
		b->m_flags &= ~b2Body::e_islandFlag;
	}
	for (b2Contact* c = m_contactList; c; c = c->m_next)
	{
		c->m_flags &= ~b2Contact::e_islandFlag;
	}
	for (b2Joint* j = m_jointList; j; j = j->m_next)
	{
		j->m_islandFlag = false;
	}

	// Build and simulate all awake islands.
	int32 stackSize = m_bodyCount;
	b2Body** stack = (b2Body**)m_stackAllocator.Allocate(stackSize * sizeof(b2Body*));
	for (b2Body* seed = m_bodyList; seed; seed = seed->m_next)
	{
		if (seed->m_flags & (b2Body::e_islandFlag | b2Body::e_sleepFlag | b2Body::e_frozenFlag))
		{
			continue;
		}

		if (seed->IsStatic())
		{
			continue;
		}

		// Reset island and stack.
		island.Clear();
		int32 stackCount = 0;
		stack[stackCount++] = seed;
		seed->m_flags |= b2Body::e_islandFlag;

		// Perform a depth first search (DFS) on the constraint graph.
		while (stackCount > 0)
		{
			// Grab the next body off the stack and add it to the island.
			b2Body* b = stack[--stackCount];
			island.Add(b);

			// Make sure the body is awake.
			b->m_flags &= ~b2Body::e_sleepFlag;

			// To keep islands as small as possible, we don't
			// propagate islands across static bodies.
			if (b->IsStatic())
			{
				continue;
			}

			// Search all contacts connected to this body.
			for (b2ContactEdge* cn = b->m_contactList; cn; cn = cn->next)
			{
				// Has this contact already been added to an island?
				// Is this contact non-solid (involves a sensor).
				if (cn->contact->m_flags & (b2Contact::e_islandFlag | b2Contact::e_nonSolidFlag | b2Contact::e_invalidFlag | b2Contact::e_destroyFlag))
				{
					continue;
				}

				// Is this contact touching?
				if ((cn->contact->m_flags & b2Contact::e_touchFlag) == 0)
				{
					continue;
				}

				island.Add(cn->contact);
				cn->contact->m_flags |= b2Contact::e_islandFlag;

				b2Body* other = cn->other;

				// Was the other body already added to this island?
				if (other->m_flags & b2Body::e_islandFlag)
				{
					continue;
				}

				b2Assert(stackCount < stackSize);
				stack[stackCount++] = other;
				other->m_flags |= b2Body::e_islandFlag;
			}

			// Search all joints connect to this body.
			for (b2JointEdge* jn = b->m_jointList; jn; jn = jn->next)
			{
				if (jn->joint->m_islandFlag == true)
				{
					continue;
				}

				island.Add(jn->joint);
				jn->joint->m_islandFlag = true;

				b2Body* other = jn->other;
				if (other->m_flags & b2Body::e_islandFlag)
				{
					continue;
				}

				b2Assert(stackCount < stackSize);
				stack[stackCount++] = other;
				other->m_flags |= b2Body::e_islandFlag;
			}
		}

		island.Solve(step, m_gravity, m_allowSleep);

		// Post solve cleanup.
		for (int32 i = 0; i < island.m_bodyCount; ++i)
		{
			// Allow static bodies to participate in other islands.
			b2Body* b = island.m_bodies[i];
			if (b->IsStatic())
			{
				b->m_flags &= ~b2Body::e_islandFlag;
			}
		}
	}

	m_stackAllocator.Free(stack);

	// Synchronize fixtures, check for out of range bodies.
	for (b2Body* b = m_bodyList; b; b = b->GetNext())
	{
		if (b->m_flags & (b2Body::e_sleepFlag | b2Body::e_frozenFlag))
		{
			continue;
		}

		if (b->IsStatic())
		{
			continue;
		}
		
		// Update fixtures (for broad-phase). If the fixtures go out of
		// the world AABB then fixtures and contacts may be destroyed,
		// including contacts that are
		bool inRange = b->SynchronizeFixtures();

		// Did the body's fixtures leave the world?
		if (inRange == false && m_boundaryListener != NULL)
		{
			m_boundaryListener->Violation(b);
		}
	}

	// Commit fixture proxy movements to the broad-phase so that new contacts are created.
	// Also, some contacts can be destroyed.
	m_broadPhase->Commit();
}

// Find TOI contacts and solve them.
void b2World::SolveTOI(const b2TimeStep& step)
{
	// Reserve an island and a queue for TOI island solution.
	b2Island island(m_bodyCount, b2_maxTOIContactsPerIsland, b2_maxTOIJointsPerIsland, &m_stackAllocator, m_contactListener);
	
	//Simple one pass queue
	//Relies on the fact that we're only making one pass
	//through and each body can only be pushed/popped once.
	//To push: 
	//  queue[queueStart+queueSize++] = newElement;
	//To pop: 
	//	poppedElement = queue[queueStart++];
	//  --queueSize;
	int32 queueCapacity = m_bodyCount;
	b2Body** queue = (b2Body**)m_stackAllocator.Allocate(queueCapacity* sizeof(b2Body*));

	for (b2Body* b = m_bodyList; b; b = b->m_next)
	{
		b->m_flags &= ~b2Body::e_islandFlag;
		b->m_sweep.t0 = 0.0f;
	}

	for (b2Contact* c = m_contactList; c; c = c->m_next)
	{
		// Invalidate TOI
		c->m_flags &= ~(b2Contact::e_toiFlag | b2Contact::e_islandFlag);
	}

	for (b2Joint* j = m_jointList; j; j = j->m_next)
	{
            j->m_islandFlag = false;
	}

	// Find TOI events and solve them.
	for (;;)
	{
		// Find the first TOI.
		b2Contact* minContact = NULL;
		float32 minTOI = 1.0f;

		for (b2Contact* c = m_contactList; c; c = c->m_next)
		{
			if (c->m_flags & (b2Contact::e_slowFlag | b2Contact::e_nonSolidFlag | b2Contact::e_invalidFlag | b2Contact::e_destroyFlag))
			{
				continue;
			}

			// TODO_ERIN keep a counter on the contact, only respond to M TOIs per contact.

			float32 toi = 1.0f;
			if (c->m_flags & b2Contact::e_toiFlag)
			{
				// This contact has a valid cached TOI.
				toi = c->m_toi;
			}
			else
			{
				// Compute the TOI for this contact.
				b2Fixture* s1 = c->GetFixtureA();
				b2Fixture* s2 = c->GetFixtureB();
				b2Body* b1 = s1->GetBody();
				b2Body* b2 = s2->GetBody();

				if ((b1->IsStatic() || b1->IsSleeping()) && (b2->IsStatic() || b2->IsSleeping()))
				{
					continue;
				}

				// Put the sweeps onto the same time interval.
				float32 t0 = b1->m_sweep.t0;
				
				if (b1->m_sweep.t0 < b2->m_sweep.t0)
				{
					t0 = b2->m_sweep.t0;
					b1->m_sweep.Advance(t0);
				}
				else if (b2->m_sweep.t0 < b1->m_sweep.t0)
				{
					t0 = b1->m_sweep.t0;
					b2->m_sweep.Advance(t0);
				}

				b2Assert(t0 < 1.0f);

				// Compute the time of impact.
				toi = c->ComputeTOI(b1->m_sweep, b2->m_sweep);
				//b2TimeOfImpact(c->m_fixtureA->GetShape(), b1->m_sweep, c->m_fixtureB->GetShape(), b2->m_sweep);

				b2Assert(0.0f <= toi && toi <= 1.0f);

				// If the TOI is in range ...
				if (0.0f < toi && toi < 1.0f)
				{
					// Interpolate on the actual range.
					toi = b2Min((1.0f - toi) * t0 + toi, 1.0f);
				}


				c->m_toi = toi;
				c->m_flags |= b2Contact::e_toiFlag;
			}

			if (B2_FLT_EPSILON < toi && toi < minTOI)
			{
				// This is the minimum TOI found so far.
				minContact = c;
				minTOI = toi;
			}
		}

		if (minContact == NULL || 1.0f - 100.0f * B2_FLT_EPSILON < minTOI)
		{
			// No more TOI events. Done!
			break;
		}

		// Advance the bodies to the TOI.
		b2Fixture* s1 = minContact->GetFixtureA();
		b2Fixture* s2 = minContact->GetFixtureB();
		b2Body* b1 = s1->GetBody();
		b2Body* b2 = s2->GetBody();
		b1->Advance(minTOI);
		b2->Advance(minTOI);

		// The TOI contact likely has some new contact points.
		bool destroyed = m_contactManager.Update(minContact);
		if (destroyed)
			continue;
        
		minContact->m_flags &= ~b2Contact::e_toiFlag;
        
		// Check if some flags have changed in the user callback
		// Any of these mean we should now ignore the collision
		if (minContact->m_flags & (b2Contact::e_slowFlag | b2Contact::e_nonSolidFlag | b2Contact::e_invalidFlag | b2Contact::e_destroyFlag))
		{
			continue;
		}

		if ((minContact->m_flags & b2Contact::e_touchFlag) == 0)
		{
			// This shouldn't happen. Numerical error?
			//b2Assert(false);
			continue;
		}

		// Build the TOI island. We need a dynamic seed.
		b2Body* seed = b1;
		if (seed->IsStatic())
		{
			seed = b2;
		}
		if (seed->IsStatic())
		{
			continue;
		}

		// Reset island and queue.
		island.Clear();
		
		int32 queueStart = 0; // starting index for queue
		int32 queueSize = 0;  // elements in queue
		queue[queueStart + queueSize++] = seed;
		seed->m_flags |= b2Body::e_islandFlag;

		// Perform a breadth first search (BFS) on the contact/joint graph.
		while (queueSize > 0)
		{
			// Grab the next body off the stack and add it to the island.
			b2Body* b = queue[queueStart++];
			--queueSize;
			
			island.Add(b);

			// Make sure the body is awake.
			b->m_flags &= ~b2Body::e_sleepFlag;

			// To keep islands as small as possible, we don't
			// propagate islands across static bodies.
			if (b->IsStatic())
			{
				continue;
			}

			// Search all contacts connected to this body.
			for (b2ContactEdge* cEdge = b->m_contactList; cEdge; cEdge = cEdge->next)
			{
				// Does the TOI island still have space for contacts?
				if (island.m_contactCount == island.m_contactCapacity)
				{
					continue;
				}

				// Has this contact already been added to an island? Skip slow or non-solid contacts.
				if (cEdge->contact->m_flags & (b2Contact::e_islandFlag | b2Contact::e_slowFlag | b2Contact::e_nonSolidFlag))
				{
					continue;
				}

				// Is this contact touching? For performance we are not updating this contact.
				if ((cEdge->contact->m_flags & b2Contact::e_touchFlag) == 0)
				{
					continue;
				}

				island.Add(cEdge->contact);
				cEdge->contact->m_flags |= b2Contact::e_islandFlag;

				// Update other body.
				b2Body* other = cEdge->other;

				// Was the other body already added to this island?
				if (other->m_flags & b2Body::e_islandFlag)
				{
					continue;
				}

				// March forward, this can do no harm since this is the min TOI.
				if (other->IsStatic() == false)
				{
					other->Advance(minTOI);
					other->WakeUp();
				}

				b2Assert(queueStart + queueSize < queueCapacity);
				queue[queueStart + queueSize] = other;
				++queueSize;
				other->m_flags |= b2Body::e_islandFlag;
			}
			
			for (b2JointEdge* jEdge = b->m_jointList; jEdge; jEdge = jEdge->next)
			{
				if (island.m_jointCount == island.m_jointCapacity)
				{
					continue;
				}
				
				if (jEdge->joint->m_islandFlag == true)
				{
					continue;
				}
				
				island.Add(jEdge->joint);
				
				jEdge->joint->m_islandFlag = true;
				
				b2Body* other = jEdge->other;
				
				if (other->m_flags & b2Body::e_islandFlag)
				{
					continue;
				}
				
				if (!other->IsStatic())
				{
					other->Advance(minTOI);
					other->WakeUp();
				}
				
				b2Assert(queueStart + queueSize < queueCapacity);
				queue[queueStart + queueSize] = other;
				++queueSize;
				other->m_flags |= b2Body::e_islandFlag;
			}
		}

		b2TimeStep subStep;
		subStep.warmStarting = false;
		subStep.dt = (1.0f - minTOI) * step.dt;
		subStep.inv_dt = 1.0f / subStep.dt;
		subStep.dtRatio = 0.0f;
		subStep.velocityIterations = step.velocityIterations;
		subStep.positionIterations = step.positionIterations;

		island.SolveTOI(subStep);

		// Post solve cleanup.
		for (int32 i = 0; i < island.m_bodyCount; ++i)
		{
			// Allow bodies to participate in future TOI islands.
			b2Body* b = island.m_bodies[i];
			b->m_flags &= ~b2Body::e_islandFlag;

			if (b->m_flags & (b2Body::e_sleepFlag | b2Body::e_frozenFlag))
			{
				continue;
			}

			if (b->IsStatic())
			{
				continue;
			}

			// Update fixtures (for broad-phase). If the fixtures go out of
			// the world AABB then fixtures and contacts may be destroyed,
			// including contacts that are
			bool inRange = b->SynchronizeFixtures();

			// Did the body's fixtures leave the world?
			if (inRange == false && m_boundaryListener != NULL)
			{
				m_boundaryListener->Violation(b);
			}

			// Invalidate all contact TOIs associated with this body. Some of these
			// may not be in the island because they were not touching.
			for (b2ContactEdge* cn = b->m_contactList; cn; cn = cn->next)
			{
				cn->contact->m_flags &= ~b2Contact::e_toiFlag;
			}
		}

		for (int32 i = 0; i < island.m_contactCount; ++i)
		{
			// Allow contacts to participate in future TOI islands.
			b2Contact* c = island.m_contacts[i];
			c->m_flags &= ~(b2Contact::e_toiFlag | b2Contact::e_islandFlag);
		}

		for (int32 i = 0; i < island.m_jointCount; ++i)
		{
			// Allow joints to participate in future TOI islands.
			b2Joint* j = island.m_joints[i];
			j->m_islandFlag = false;
		}
		
		// Commit fixture proxy movements to the broad-phase so that new contacts are created.
		// Also, some contacts can be destroyed.
		m_broadPhase->Commit();
	}

	m_stackAllocator.Free(queue);
}

void b2World::Step(float32 dt, int32 velocityIterations, int32 positionIterations)
{
	m_lock = true;

	b2TimeStep step;
	step.dt = dt;
	step.velocityIterations	= velocityIterations;
	step.positionIterations = positionIterations;
	if (dt > 0.0f)
	{
		step.inv_dt = 1.0f / dt;
	}
	else
	{
		step.inv_dt = 0.0f;
	}

	step.dtRatio = m_inv_dt0 * dt;

	step.warmStarting = m_warmStarting;
	
	// Update contacts.
	m_contactManager.Collide();

	// Integrate velocities, solve velocity constraints, and integrate positions.
	if (step.dt > 0.0f)
	{
		Solve(step);
	}

	// Handle TOI events.
	if (m_continuousPhysics && step.dt > 0.0f)
	{
		SolveTOI(step);
	}

	// Draw debug information.
	DrawDebugData();

	if (step.dt > 0.0f)
	{
		m_inv_dt0 = step.inv_dt;
	}

	m_lock = false;
}

int32 b2World::Query(const b2AABB& aabb, b2Fixture** fixtures, int32 maxCount)
{
	void** results = (void**)m_stackAllocator.Allocate(maxCount * sizeof(void*));

	int32 count = m_broadPhase->Query(aabb, results, maxCount);

	for (int32 i = 0; i < count; ++i)
	{
		fixtures[i] = (b2Fixture*)results[i];
	}

	m_stackAllocator.Free(results);
	return count;
}

int32 b2World::Raycast(const b2Segment& segment, b2Fixture** fixtures, int32 maxCount, bool solidShapes, void* userData)
{
	m_raycastSegment = &segment;
	m_raycastUserData = userData;
	m_raycastSolidShape = solidShapes;

	void** results = (void**)m_stackAllocator.Allocate(maxCount * sizeof(void*));

	int32 count = m_broadPhase->QuerySegment(segment,results,maxCount, &RaycastSortKey);

	for (int32 i = 0; i < count; ++i)
	{
		fixtures[i] = (b2Fixture*)results[i];
	}

	m_stackAllocator.Free(results);
	return count;
}

b2Fixture* b2World::RaycastOne(const b2Segment& segment, float32* lambda, b2Vec2* normal, bool solidShapes, void* userData)
{
	int32 maxCount = 1;
	b2Fixture* fixture;

	int32 count = Raycast(segment, &fixture, maxCount, solidShapes, userData);

	if(count==0)
		return NULL;

	b2Assert(count==1);

	//Redundantly do TestSegment a second time, as the previous one's results are inaccessible

	fixture->TestSegment(lambda, normal,segment,1);
	//We already know it returns true
	return fixture;
}

void b2World::DrawShape(b2Fixture* fixture, const b2XForm& xf, const b2Color& color)
{
	b2Color coreColor(0.9f, 0.6f, 0.6f);

	switch (fixture->GetType())
	{
	case b2_circleShape:
		{
			b2CircleShape* circle = (b2CircleShape*)fixture->GetShape();

			b2Vec2 center = b2Mul(xf, circle->m_p);
			float32 radius = circle->m_radius;
			b2Vec2 axis = xf.R.col1;

			m_debugDraw->DrawSolidCircle(center, radius, axis, color);
		}
		break;

	case b2_polygonShape:
		{
			b2PolygonShape* poly = (b2PolygonShape*)fixture->GetShape();
			int32 vertexCount = poly->m_vertexCount;
			b2Assert(vertexCount <= b2_maxPolygonVertices);
			b2Vec2 vertices[b2_maxPolygonVertices];

			for (int32 i = 0; i < vertexCount; ++i)
			{
				vertices[i] = b2Mul(xf, poly->m_vertices[i]);
			}

			m_debugDraw->DrawSolidPolygon(vertices, vertexCount, color);
		}
		break;
		
	case b2_edgeShape:
		{
			b2EdgeShape* edge = (b2EdgeShape*)fixture->GetShape();
			
			m_debugDraw->DrawSegment(b2Mul(xf, edge->GetVertex1()), b2Mul(xf, edge->GetVertex2()), color);
		}
		break;
	}
}

void b2World::DrawJoint(b2Joint* joint)
{
	b2Body* b1 = joint->GetBody1();
	b2Body* b2 = joint->GetBody2();
	const b2XForm& xf1 = b1->GetXForm();
	const b2XForm& xf2 = b2->GetXForm();
	b2Vec2 x1 = xf1.position;
	b2Vec2 x2 = xf2.position;
	b2Vec2 p1 = joint->GetAnchor1();
	b2Vec2 p2 = joint->GetAnchor2();

	b2Color color(0.5f, 0.8f, 0.8f);

	switch (joint->GetType())
	{
	case e_distanceJoint:
		m_debugDraw->DrawSegment(p1, p2, color);
		break;

	case e_pulleyJoint:
		{
			b2PulleyJoint* pulley = (b2PulleyJoint*)joint;
			b2Vec2 s1 = pulley->GetGroundAnchor1();
			b2Vec2 s2 = pulley->GetGroundAnchor2();
			m_debugDraw->DrawSegment(s1, p1, color);
			m_debugDraw->DrawSegment(s2, p2, color);
			m_debugDraw->DrawSegment(s1, s2, color);
		}
		break;

	case e_fixedJoint:
		{
			m_debugDraw->DrawSegment(p1, p2, color);
        }
		break;

	case e_mouseJoint:
		// don't draw this
		break;

	default:
		m_debugDraw->DrawSegment(x1, p1, color);
		m_debugDraw->DrawSegment(p1, p2, color);
		m_debugDraw->DrawSegment(x2, p2, color);
	}
}

void b2World::DrawDebugData()
{
	if (m_debugDraw == NULL)
	{
		return;
	}

	uint32 flags = m_debugDraw->GetFlags();

	if (flags & b2DebugDraw::e_shapeBit)
	{
		for (b2Body* b = m_bodyList; b; b = b->GetNext())
		{
			const b2XForm& xf = b->GetXForm();
			for (b2Fixture* f = b->GetFixtureList(); f; f = f->GetNext())
			{
				if (b->IsStatic())
				{
					DrawShape(f, xf, b2Color(0.5f, 0.9f, 0.5f));
				}
				else if (b->IsSleeping())
				{
					DrawShape(f, xf, b2Color(0.5f, 0.5f, 0.9f));
				}
				else
				{
					DrawShape(f, xf, b2Color(0.9f, 0.9f, 0.9f));
				}
			}
		}
	}

	if (flags & b2DebugDraw::e_jointBit)
	{
		for (b2Joint* j = m_jointList; j; j = j->GetNext())
		{
			if (j->GetType() != e_mouseJoint)
			{
				DrawJoint(j);
			}
		}
	}

	if (flags & b2DebugDraw::e_controllerBit)
	{
		for (b2Controller* c = m_controllerList; c; c= c->GetNext())
		{
			c->Draw(m_debugDraw);
		}
	}

	if (flags & b2DebugDraw::e_pairBit)
	{
		b2BroadPhase* bp = m_broadPhase;
		b2Vec2 invQ;
		invQ.Set(1.0f / bp->m_quantizationFactor.x, 1.0f / bp->m_quantizationFactor.y);
		b2Color color(0.9f, 0.9f, 0.3f);

		for (int32 i = 0; i < b2_tableCapacity; ++i)
		{
			uint16 index = bp->m_pairManager.m_hashTable[i];
			while (index != b2_nullPair)
			{
				b2Pair* pair = bp->m_pairManager.m_pairs + index;
				b2Proxy* p1 = bp->m_proxyPool + pair->proxyId1;
				b2Proxy* p2 = bp->m_proxyPool + pair->proxyId2;

				b2AABB b1, b2;
				b1.lowerBound.x = bp->m_worldAABB.lowerBound.x + invQ.x * bp->m_bounds[0][p1->lowerBounds[0]].value;
				b1.lowerBound.y = bp->m_worldAABB.lowerBound.y + invQ.y * bp->m_bounds[1][p1->lowerBounds[1]].value;
				b1.upperBound.x = bp->m_worldAABB.lowerBound.x + invQ.x * bp->m_bounds[0][p1->upperBounds[0]].value;
				b1.upperBound.y = bp->m_worldAABB.lowerBound.y + invQ.y * bp->m_bounds[1][p1->upperBounds[1]].value;
				b2.lowerBound.x = bp->m_worldAABB.lowerBound.x + invQ.x * bp->m_bounds[0][p2->lowerBounds[0]].value;
				b2.lowerBound.y = bp->m_worldAABB.lowerBound.y + invQ.y * bp->m_bounds[1][p2->lowerBounds[1]].value;
				b2.upperBound.x = bp->m_worldAABB.lowerBound.x + invQ.x * bp->m_bounds[0][p2->upperBounds[0]].value;
				b2.upperBound.y = bp->m_worldAABB.lowerBound.y + invQ.y * bp->m_bounds[1][p2->upperBounds[1]].value;

				b2Vec2 x1 = 0.5f * (b1.lowerBound + b1.upperBound);
				b2Vec2 x2 = 0.5f * (b2.lowerBound + b2.upperBound);

				m_debugDraw->DrawSegment(x1, x2, color);

				index = pair->next;
			}
		}
	}

	if (flags & b2DebugDraw::e_aabbBit)
	{
		b2BroadPhase* bp = m_broadPhase;
		b2Vec2 worldLower = bp->m_worldAABB.lowerBound;
		b2Vec2 worldUpper = bp->m_worldAABB.upperBound;

		b2Vec2 invQ;
		invQ.Set(1.0f / bp->m_quantizationFactor.x, 1.0f / bp->m_quantizationFactor.y);
		b2Color color(0.9f, 0.3f, 0.9f);
		for (int32 i = 0; i < b2_maxProxies; ++i)
		{
			b2Proxy* p = bp->m_proxyPool + i;
			if (p->IsValid() == false)
			{
				continue;
			}

			b2AABB b;
			b.lowerBound.x = worldLower.x + invQ.x * bp->m_bounds[0][p->lowerBounds[0]].value;
			b.lowerBound.y = worldLower.y + invQ.y * bp->m_bounds[1][p->lowerBounds[1]].value;
			b.upperBound.x = worldLower.x + invQ.x * bp->m_bounds[0][p->upperBounds[0]].value;
			b.upperBound.y = worldLower.y + invQ.y * bp->m_bounds[1][p->upperBounds[1]].value;

			b2Vec2 vs[4];
			vs[0].Set(b.lowerBound.x, b.lowerBound.y);
			vs[1].Set(b.upperBound.x, b.lowerBound.y);
			vs[2].Set(b.upperBound.x, b.upperBound.y);
			vs[3].Set(b.lowerBound.x, b.upperBound.y);

			m_debugDraw->DrawPolygon(vs, 4, color);
		}

		b2Vec2 vs[4];
		vs[0].Set(worldLower.x, worldLower.y);
		vs[1].Set(worldUpper.x, worldLower.y);
		vs[2].Set(worldUpper.x, worldUpper.y);
		vs[3].Set(worldLower.x, worldUpper.y);
		m_debugDraw->DrawPolygon(vs, 4, b2Color(0.3f, 0.9f, 0.9f));
	}

	if (flags & b2DebugDraw::e_centerOfMassBit)
	{
		for (b2Body* b = m_bodyList; b; b = b->GetNext())
		{
			b2XForm xf = b->GetXForm();
			xf.position = b->GetWorldCenter();
			m_debugDraw->DrawXForm(xf);
		}
	}
}

void b2World::Validate()
{
	m_broadPhase->Validate();
}

int32 b2World::GetProxyCount() const
{
	return m_broadPhase->m_proxyCount;
}

int32 b2World::GetPairCount() const
{
	return m_broadPhase->m_pairManager.m_pairCount;
}

bool b2World::InRange(const b2AABB& aabb) const
{
	return m_broadPhase->InRange(aabb);
}

float32 b2World::RaycastSortKey(void* data)
{
	b2Fixture* fixture = (b2Fixture*)data;
	b2Body* body = fixture->GetBody();
	b2World* world = body->GetWorld();

	if (world->m_contactFilter && !world->m_contactFilter->RayCollide(world->m_raycastUserData,fixture))
	{
		return -1;
	}

	float32 lambda;
	b2SegmentCollide collide = fixture->TestSegment(&lambda, &world->m_raycastNormal, *world->m_raycastSegment, 1);

	if (world->m_raycastSolidShape && collide == b2_missCollide)
	{
		return -1;
	}

	if (!world->m_raycastSolidShape && collide != b2_hitCollide)
	{
		return -1;
	}

	return lambda;
}
