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

#include "b2ContactManager.h"
#include "b2World.h"
#include "b2Body.h"
#include "b2Fixture.h"

// This is a callback from the broad-phase when two AABB proxies begin
// to overlap. We create a b2Contact to manage the narrow phase.
void* b2ContactManager::PairAdded(void* proxyUserDataA, void* proxyUserDataB)
{
	b2Fixture* fixtureA = (b2Fixture*)proxyUserDataA;
	b2Fixture* fixtureB = (b2Fixture*)proxyUserDataB;

	b2Body* bodyA = fixtureA->GetBody();
	b2Body* bodyB = fixtureB->GetBody();

	if (bodyA->IsStatic() && bodyB->IsStatic())
	{
		return &m_nullContact;
	}

	if (fixtureA->GetBody() == fixtureB->GetBody())
	{
		return &m_nullContact;
	}

	if (bodyB->IsConnected(bodyA))
	{
		return &m_nullContact;
	}

	if (m_world->m_contactFilter != NULL && m_world->m_contactFilter->ShouldCollide(fixtureA, fixtureB) == false)
	{
		return &m_nullContact;
	}

	// Call the factory.
	b2Contact* c = b2Contact::Create(fixtureA, fixtureB, &m_world->m_blockAllocator);

	if (c == NULL)
	{
		return &m_nullContact;
	}

	// Contact creation may swap shapes.
	fixtureA = c->GetFixtureA();
	fixtureB = c->GetFixtureB();
	bodyA = fixtureA->GetBody();
	bodyB = fixtureB->GetBody();

	// Insert into the world.
	c->m_prev = NULL;
	c->m_next = m_world->m_contactList;
	if (m_world->m_contactList != NULL)
	{
		m_world->m_contactList->m_prev = c;
	}
	m_world->m_contactList = c;

	// Connect to island graph.

	// Connect to body A
	c->m_nodeA.contact = c;
	c->m_nodeA.other = bodyB;

	c->m_nodeA.prev = NULL;
	c->m_nodeA.next = bodyA->m_contactList;
	if (bodyA->m_contactList != NULL)
	{
		bodyA->m_contactList->prev = &c->m_nodeA;
	}
	bodyA->m_contactList = &c->m_nodeA;

	// Connect to body B
	c->m_nodeB.contact = c;
	c->m_nodeB.other = bodyA;

	c->m_nodeB.prev = NULL;
	c->m_nodeB.next = bodyB->m_contactList;
	if (bodyB->m_contactList != NULL)
	{
		bodyB->m_contactList->prev = &c->m_nodeB;
	}
	bodyB->m_contactList = &c->m_nodeB;

	++m_world->m_contactCount;
	return c;
}

// This is a callback from the broad-phase when two AABB proxies cease
// to overlap. We retire the b2Contact.
void b2ContactManager::PairRemoved(void* proxyUserDataA, void* proxyUserDataB, void* pairUserData)
{
	B2_NOT_USED(proxyUserDataA);
	B2_NOT_USED(proxyUserDataB);

	if (pairUserData == NULL)
	{
		return;
	}

	b2Contact* c = (b2Contact*)pairUserData;
	if (c == &m_nullContact)
	{
		return;
	}

	// An attached body is being destroyed, we must destroy this contact
	// immediately to avoid orphaned shape pointers.
	Destroy(c);
}

void b2ContactManager::Destroy(b2Contact* c)
{
	b2Fixture* fixtureA = c->GetFixtureA();
	b2Fixture* fixtureB = c->GetFixtureB();
	b2Body* bodyA = fixtureA->GetBody();
	b2Body* bodyB = fixtureB->GetBody();

	if (c->m_manifold.m_pointCount > 0)
	{
		m_world->m_contactListener->EndContact(c);
	}

	// Remove from the world.
	if (c->m_prev)
	{
		c->m_prev->m_next = c->m_next;
	}

	if (c->m_next)
	{
		c->m_next->m_prev = c->m_prev;
	}

	if (c == m_world->m_contactList)
	{
		m_world->m_contactList = c->m_next;
	}

	// Remove from body 1
	if (c->m_nodeA.prev)
	{
		c->m_nodeA.prev->next = c->m_nodeA.next;
	}

	if (c->m_nodeA.next)
	{
		c->m_nodeA.next->prev = c->m_nodeA.prev;
	}

	if (&c->m_nodeA == bodyA->m_contactList)
	{
		bodyA->m_contactList = c->m_nodeA.next;
	}

	// Remove from body 2
	if (c->m_nodeB.prev)
	{
		c->m_nodeB.prev->next = c->m_nodeB.next;
	}

	if (c->m_nodeB.next)
	{
		c->m_nodeB.next->prev = c->m_nodeB.prev;
	}

	if (&c->m_nodeB == bodyB->m_contactList)
	{
		bodyB->m_contactList = c->m_nodeB.next;
	}

	if (m_nextContact == c)
	{
		m_nextContact = c->GetNext();
	}
	// Call the factory.
	if( c->m_flags & b2Contact::e_lockedFlag)
	{
		// We cannot destroy the current contact - it's being worked on.
		// Instead mark it for deferred destruction.
		// Collide() will handle calling Destroy slightly later
		c->m_flags |= b2Contact::e_destroyFlag;

		// Also do some cleaning up so that people don't accidentally do stupid things.
        // TODO: Is this necessary or wise?
		//c->m_fixtureA = NULL;
		//c->m_fixtureB = NULL;
		c->m_next = NULL;
		c->m_prev = NULL;
	}else{
		b2Contact::Destroy(c, &m_world->m_blockAllocator);
	}
	--m_world->m_contactCount;
}

// This is the top level collision call for the time step. Here
// all the narrow phase collision is processed for the world
// contact list.
void b2ContactManager::Collide()
{
	// Update awake contacts.
	// Note the use of a accessible iterator, m_nextContact, this can be updated elsewhere
	// should that contact get deleted inside the call to m_nextContact
	m_nextContact = m_world->m_contactList;
	while(m_nextContact)
	{
		b2Contact* c  = m_nextContact;
		m_nextContact = c->GetNext();
		b2Body* bodyA = c->GetFixtureA()->GetBody();
		b2Body* bodyB = c->GetFixtureB()->GetBody();
		if (bodyA->IsSleeping() && bodyB->IsSleeping())
		{
			continue;
		}

		Update(c);
	}
    m_nextContact = NULL;
}

bool b2ContactManager::Update(b2Contact* contact)
{
	b2ContactListener* listener = m_world->m_contactListener;
    
	b2Body* bodyA = contact->m_fixtureA->GetBody();
	b2Body* bodyB = contact->m_fixtureB->GetBody();
    
	b2ShapeType shapeAType = contact->m_fixtureA->GetType();
	b2ShapeType shapeBType = contact->m_fixtureB->GetType();
    
    b2Manifold oldManifold = contact->m_manifold;
    
	uint32 oldLock = contact->m_flags & b2Contact::e_lockedFlag ;

	contact->m_flags |= b2Contact::e_lockedFlag;

	contact->Evaluate();
	
	contact->m_flags &= ~b2Contact::e_invalidFlag;

	if(contact->m_flags & b2Contact::e_destroyFlag)
	{     
		b2Contact::Destroy(contact, shapeAType, shapeBType, &m_world->m_blockAllocator);
        return true;
	}

	if(!oldLock)
		contact->m_flags &= ~b2Contact::e_lockedFlag;
    
	int32 oldCount = oldManifold.m_pointCount;
	int32 newCount = contact->m_manifold.m_pointCount;
    
	if (newCount == 0 && oldCount > 0)
	{
		bodyA->WakeUp();
		bodyB->WakeUp();
	}

	// Slow contacts don't generate TOI events.
	if (bodyA->IsStatic() || bodyA->IsBullet() || bodyB->IsStatic() || bodyB->IsBullet())
	{
		contact->m_flags &= ~b2Contact::e_slowFlag;
	}
	else
	{
		contact->m_flags |= b2Contact::e_slowFlag;
	}
    
	// Match old contact ids to new contact ids and copy the
	// stored impulses to warm start the solver.
	for (int32 i = 0; i < contact->m_manifold.m_pointCount; ++i)
	{
		b2ManifoldPoint* mp2 = contact->m_manifold.m_points + i;
		mp2->m_normalImpulse = 0.0f;
		mp2->m_tangentImpulse = 0.0f;
		b2ContactID id2 = mp2->m_id;

		for (int32 j = 0; j < oldManifold.m_pointCount; ++j)
		{
			b2ManifoldPoint* mp1 = oldManifold.m_points + j;

			if (mp1->m_id.key == id2.key)
			{
				mp2->m_normalImpulse = mp1->m_normalImpulse;
				mp2->m_tangentImpulse = mp1->m_tangentImpulse;
				break;
			}
		}
	}

	if (oldCount == 0 && newCount > 0)
	{
		contact->m_flags |= b2Contact::e_touchFlag;
		listener->BeginContact(contact);
	}

	if (oldCount > 0 && newCount == 0)
	{
		contact->m_flags &= ~b2Contact::e_touchFlag;
		listener->EndContact(contact);
	}

	if ((contact->m_flags & b2Contact::e_nonSolidFlag) == 0)
	{
		listener->PreSolve(contact, &oldManifold);

		// The user may have disabled contact.
		if (contact->m_manifold.m_pointCount == 0)
		{
			contact->m_flags &= ~b2Contact::e_touchFlag;
		}
	}
	
	return false;
}
