/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
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

#include "b2Body.h"
#include "b2Fixture.h"
#include "b2World.h"
#include "Controllers/b2Controller.h"
#include "Joints/b2Joint.h"

b2Body::b2Body(const b2BodyDef* bd, b2World* world)
{
	m_flags = 0;

	if (bd->isBullet)
	{
		m_flags |= e_bulletFlag;
	}
	if (bd->fixedRotation)
	{
		m_flags |= e_fixedRotationFlag;
	}
	if (bd->allowSleep)
	{
		m_flags |= e_allowSleepFlag;
	}
	if (bd->isSleeping)
	{
		m_flags |= e_sleepFlag;
	}

	m_world = world;

	m_xf.position = bd->position;
	m_xf.R.Set(bd->angle);

	m_sweep.localCenter = bd->massData.center;
	m_sweep.t0 = 1.0f;
	m_sweep.a0 = m_sweep.a = bd->angle;
	m_sweep.c0 = m_sweep.c = b2Mul(m_xf, m_sweep.localCenter);

	m_jointList = NULL;
	m_contactList = NULL;
	m_controllerList = NULL;
	m_prev = NULL;
	m_next = NULL;

	m_linearVelocity = bd->linearVelocity;
	m_angularVelocity = bd->angularVelocity;

	m_linearDamping = bd->linearDamping;
	m_angularDamping = bd->angularDamping;

	m_force.Set(0.0f, 0.0f);
	m_torque = 0.0f;

	m_linearVelocity.SetZero();
	m_angularVelocity = 0.0f;

	m_sleepTime = 0.0f;

	m_invMass = 0.0f;
	m_I = 0.0f;
	m_invI = 0.0f;

	m_mass = bd->massData.mass;

	if (m_mass > 0.0f)
	{
		m_invMass = 1.0f / m_mass;
	}

	m_I = bd->massData.I;
	
	if (m_I > 0.0f && (m_flags & b2Body::e_fixedRotationFlag) == 0)
	{
		m_invI = 1.0f / m_I;
	}

	if (m_invMass == 0.0f && m_invI == 0.0f)
	{
		m_type = e_staticType;
	}
	else
	{
		m_type = e_dynamicType;
	}

	m_userData = bd->userData;

	m_fixtureList = NULL;
	m_fixtureCount = 0;
}

b2Body::~b2Body()
{
	// shapes and joints are destroyed in b2World::Destroy
}

b2Fixture* b2Body::CreateFixture(const b2FixtureDef* def)
{
	b2BlockAllocator* allocator = &m_world->m_blockAllocator;
	b2BroadPhase* broadPhase = m_world->m_broadPhase;

	void* mem = allocator->Allocate(sizeof(b2Fixture));
	b2Fixture* fixture = new (mem) b2Fixture;
	fixture->Create(allocator, broadPhase, this, m_xf, def);

	fixture->m_next = m_fixtureList;
	m_fixtureList = fixture;
	++m_fixtureCount;

	fixture->m_body = this;

	return fixture;
}

void b2Body::DestroyFixture(b2Fixture* fixture)
{
	b2Assert(fixture->m_body == this);

	// Remove the fixture from this body's singly linked list.
	b2Assert(m_fixtureCount > 0);
	b2Fixture** node = &m_fixtureList;
	bool found = false;
	while (*node != NULL)
	{
		if (*node == fixture)
		{
			*node = fixture->m_next;
			found = true;
			break;
		}

		node = &(*node)->m_next;
	}

	// You tried to remove a shape that is not attached to this body.
	b2Assert(found);

	b2BlockAllocator* allocator = &m_world->m_blockAllocator;
	b2BroadPhase* broadPhase = m_world->m_broadPhase;

	fixture->Destroy(allocator, broadPhase);
	fixture->m_body = NULL;
	fixture->m_next = NULL;
	fixture->~b2Fixture();
	allocator->Free(fixture, sizeof(b2Fixture));

	--m_fixtureCount;
}

// TODO_ERIN adjust linear velocity and torque to account for movement of center.
void b2Body::SetMassData(const b2MassData* massData)
{
	m_invMass = 0.0f;
	m_I = 0.0f;
	m_invI = 0.0f;

	m_mass = massData->mass;

	if (m_mass > 0.0f)
	{
		m_invMass = 1.0f / m_mass;
	}

	m_I = massData->I;

	if (m_I > 0.0f && (m_flags & b2Body::e_fixedRotationFlag) == 0)
	{
		m_invI = 1.0f / m_I;
	}

	// Move center of mass.
	m_sweep.localCenter = massData->center;
	m_sweep.c0 = m_sweep.c = b2Mul(m_xf, m_sweep.localCenter);

	int16 oldType = m_type;
	if (m_invMass == 0.0f && m_invI == 0.0f)
	{
		m_type = e_staticType;
	}
	else
	{
		m_type = e_dynamicType;
	}

	// If the body type changed, we need to refilter the broad-phase proxies.
	if (oldType != m_type)
	{
		for (b2Fixture* f = m_fixtureList; f; f = f->m_next)
		{
			f->RefilterProxy(m_world->m_broadPhase, m_xf);
		}
	}
}

// TODO_ERIN adjust linear velocity and torque to account for movement of center.
void b2Body::SetMassFromShapes()
{
	// Compute mass data from shapes. Each shape has its own density.
	m_mass = 0.0f;
	m_invMass = 0.0f;
	m_I = 0.0f;
	m_invI = 0.0f;

	b2Vec2 center = b2Vec2_zero;
	for (b2Fixture* f = m_fixtureList; f; f = f->m_next)
	{
		b2MassData massData;
		f->ComputeMass(&massData);
		m_mass += massData.mass;
		center += massData.mass * massData.center;
		m_I += massData.I;
	}

	// Compute center of mass, and shift the origin to the COM.
	if (m_mass > 0.0f)
	{
		m_invMass = 1.0f / m_mass;
		center *= m_invMass;
	}

	if (m_I > 0.0f && (m_flags & e_fixedRotationFlag) == 0)
	{
		// Center the inertia about the center of mass.
		m_I -= m_mass * b2Dot(center, center);
		b2Assert(m_I > 0.0f);
		m_invI = 1.0f / m_I;
	}
	else
	{
		m_I = 0.0f;
		m_invI = 0.0f;
	}

	// Move center of mass.
	m_sweep.localCenter = center;
	m_sweep.c0 = m_sweep.c = b2Mul(m_xf, m_sweep.localCenter);

	int16 oldType = m_type;
	if (m_invMass == 0.0f && m_invI == 0.0f)
	{
		m_type = e_staticType;
	}
	else
	{
		m_type = e_dynamicType;
	}

	// If the body type changed, we need to refilter the broad-phase proxies.
	if (oldType != m_type)
	{
		for (b2Fixture* f = m_fixtureList; f; f = f->m_next)
		{
			f->RefilterProxy(m_world->m_broadPhase, m_xf);
		}
	}
}

void b2Body::SetStatic()
{
	if (m_type == e_staticType)
	{
		return;
	}

	m_mass = 0.0;
	m_invMass = 0.0f;
	m_I = 0.0f;
	m_invI = 0.0f;
	m_type = e_staticType;
	
	for (b2Fixture* f = m_fixtureList; f; f = f->m_next)
	{
		f->RefilterProxy(m_world->m_broadPhase, m_xf);
	}
}

bool b2Body::IsConnected(const b2Body* other) const
{
	for (b2JointEdge* jn = m_jointList; jn; jn = jn->next)
	{
		if (jn->other == other)
		{
			return jn->joint->m_collideConnected == false;
		}
	}

	return false;
}

bool b2Body::SetXForm(const b2Vec2& position, float32 angle)
{
	if (IsFrozen())
	{
		return false;
	}

	m_xf.R.Set(angle);
	m_xf.position = position;

	m_sweep.c0 = m_sweep.c = b2Mul(m_xf, m_sweep.localCenter);
	m_sweep.a0 = m_sweep.a = angle;

	bool freeze = false;
	for (b2Fixture* f = m_fixtureList; f; f = f->m_next)
	{
		bool inRange = f->Synchronize(m_world->m_broadPhase, m_xf, m_xf);

		if (inRange == false)
		{
			freeze = true;
			break;
		}
	}

	if (freeze == true)
	{
		m_flags |= e_frozenFlag;
		m_linearVelocity.SetZero();
		m_angularVelocity = 0.0f;

		// Failure
		return false;
	}

	// Success
	m_world->m_broadPhase->Commit();
	return true;
}

bool b2Body::SynchronizeFixtures()
{
	b2XForm xf1;
	xf1.R.Set(m_sweep.a0);
	xf1.position = m_sweep.c0 - b2Mul(xf1.R, m_sweep.localCenter);

	bool inRange = true;
	for (b2Fixture* f = m_fixtureList; f; f = f->m_next)
	{
		inRange = f->Synchronize(m_world->m_broadPhase, xf1, m_xf);
		if (inRange == false)
		{
			break;
		}
	}

	if (inRange == false)
	{
		m_flags |= e_frozenFlag;
		m_linearVelocity.SetZero();
		m_angularVelocity = 0.0f;

		// Failure
		return false;
	}

	// Success
	return true;
}
