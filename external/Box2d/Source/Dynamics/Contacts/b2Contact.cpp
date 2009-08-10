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

#include "b2Contact.h"
#include "b2CircleContact.h"
#include "b2PolyAndCircleContact.h"
#include "b2PolyContact.h"
#include "b2EdgeAndCircleContact.h"
#include "b2PolyAndEdgeContact.h"
#include "b2ContactSolver.h"
#include "../../Collision/b2Collision.h"
#include "../../Collision/Shapes/b2Shape.h"
#include "../../Common/b2BlockAllocator.h"
#include "../b2World.h"
#include "../b2Body.h"
#include "../b2Fixture.h"

b2ContactRegister b2Contact::s_registers[b2_shapeTypeCount][b2_shapeTypeCount];
bool b2Contact::s_initialized = false;

void b2Contact::InitializeRegisters()
{
	AddType(b2CircleContact::Create, b2CircleContact::Destroy, b2_circleShape, b2_circleShape);
	AddType(b2PolyAndCircleContact::Create, b2PolyAndCircleContact::Destroy, b2_polygonShape, b2_circleShape);
	AddType(b2PolygonContact::Create, b2PolygonContact::Destroy, b2_polygonShape, b2_polygonShape);
	
	AddType(b2EdgeAndCircleContact::Create, b2EdgeAndCircleContact::Destroy, b2_edgeShape, b2_circleShape);
	AddType(b2PolyAndEdgeContact::Create, b2PolyAndEdgeContact::Destroy, b2_polygonShape, b2_edgeShape);
}

void b2Contact::AddType(b2ContactCreateFcn* createFcn, b2ContactDestroyFcn* destoryFcn,
					  b2ShapeType type1, b2ShapeType type2)
{
	b2Assert(b2_unknownShape < type1 && type1 < b2_shapeTypeCount);
	b2Assert(b2_unknownShape < type2 && type2 < b2_shapeTypeCount);
	
	s_registers[type1][type2].createFcn = createFcn;
	s_registers[type1][type2].destroyFcn = destoryFcn;
	s_registers[type1][type2].primary = true;

	if (type1 != type2)
	{
		s_registers[type2][type1].createFcn = createFcn;
		s_registers[type2][type1].destroyFcn = destoryFcn;
		s_registers[type2][type1].primary = false;
	}
}

b2Contact* b2Contact::Create(b2Fixture* fixtureA, b2Fixture* fixtureB, b2BlockAllocator* allocator)
{
	if (s_initialized == false)
	{
		InitializeRegisters();
		s_initialized = true;
	}

	b2ShapeType type1 = fixtureA->GetType();
	b2ShapeType type2 = fixtureB->GetType();

	b2Assert(b2_unknownShape < type1 && type1 < b2_shapeTypeCount);
	b2Assert(b2_unknownShape < type2 && type2 < b2_shapeTypeCount);
	
	b2ContactCreateFcn* createFcn = s_registers[type1][type2].createFcn;
	if (createFcn)
	{
		if (s_registers[type1][type2].primary)
		{
			return createFcn(fixtureA, fixtureB, allocator);
		}
		else
		{
			return createFcn(fixtureB, fixtureA, allocator);
		}
	}
	else
	{
		return NULL;
	}
}

void b2Contact::Destroy(b2Contact* contact, b2BlockAllocator* allocator)
{
	Destroy(contact, contact->GetFixtureA()->GetType(), contact->GetFixtureB()->GetType(), allocator);
}
void b2Contact::Destroy(b2Contact* contact, b2ShapeType typeA, b2ShapeType typeB, b2BlockAllocator* allocator)
{
	b2Assert(s_initialized == true);

	if (contact->m_manifold.m_pointCount > 0)
	{
		contact->GetFixtureA()->GetBody()->WakeUp();
		contact->GetFixtureB()->GetBody()->WakeUp();
	}

	b2Assert(b2_unknownShape < typeA && typeB < b2_shapeTypeCount);
	b2Assert(b2_unknownShape < typeA && typeB < b2_shapeTypeCount);

	b2ContactDestroyFcn* destroyFcn = s_registers[typeA][typeB].destroyFcn;
	destroyFcn(contact, allocator);
}

b2Contact::b2Contact(b2Fixture* fA, b2Fixture* fB)
{
	m_flags = 0;

	if (fA->IsSensor() || fB->IsSensor())
	{
		m_flags |= e_nonSolidFlag;
	}

	m_fixtureA = fA;
	m_fixtureB = fB;

	m_manifold.m_pointCount = 0;

	m_prev = NULL;
	m_next = NULL;

	m_nodeA.contact = NULL;
	m_nodeA.prev = NULL;
	m_nodeA.next = NULL;
	m_nodeA.other = NULL;

	m_nodeB.contact = NULL;
	m_nodeB.prev = NULL;
	m_nodeB.next = NULL;
	m_nodeB.other = NULL;
}