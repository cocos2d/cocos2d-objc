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

#include "b2Fixture.h"
#include "../Collision/Shapes/b2CircleShape.h"
#include "../Collision/Shapes/b2PolygonShape.h"
#include "../Collision/Shapes/b2EdgeShape.h"
#include "../Collision/b2Collision.h"
#include "../Collision/b2BroadPhase.h"
#include "../Common/b2BlockAllocator.h"

#include <new>

void b2PolygonDef::SetAsBox(float32 hx, float32 hy)
{
	vertexCount = 4;
	vertices[0].Set(-hx, -hy);
	vertices[1].Set( hx, -hy);
	vertices[2].Set( hx,  hy);
	vertices[3].Set(-hx,  hy);
}

void b2PolygonDef::SetAsBox(float32 hx, float32 hy, const b2Vec2& center, float32 angle)
{
	vertexCount = 4;
	vertices[0].Set(-hx, -hy);
	vertices[1].Set( hx, -hy);
	vertices[2].Set( hx,  hy);
	vertices[3].Set(-hx,  hy);

	b2XForm xf;
	xf.position = center;
	xf.R.Set(angle);

	vertices[0] = b2Mul(xf, vertices[0]);
	vertices[1] = b2Mul(xf, vertices[1]);
	vertices[2] = b2Mul(xf, vertices[2]);
	vertices[3] = b2Mul(xf, vertices[3]);
}

b2Fixture::b2Fixture()
{
	m_userData = NULL;
	m_body = NULL;
	m_next = NULL;
	m_proxyId = b2_nullProxy;
	m_shape = NULL;
}

b2Fixture::~b2Fixture()
{
	b2Assert(m_shape == NULL);
	b2Assert(m_proxyId == b2_nullProxy);
}

void b2Fixture::Create(b2BlockAllocator* allocator, b2BroadPhase* broadPhase, b2Body* body, const b2XForm& xf, const b2FixtureDef* def)
{
	m_userData = def->userData;
	m_friction = def->friction;
	m_restitution = def->restitution;
	m_density = def->density;

	m_body = body;
	m_next = NULL;

	m_filter = def->filter;

	m_isSensor = def->isSensor;

	m_type = def->type;

	// Allocate and initialize the child shape.
	switch (m_type)
	{
	case b2_circleShape:
		{
			void* mem = allocator->Allocate(sizeof(b2CircleShape));
			b2CircleShape* circle = new (mem) b2CircleShape;
			b2CircleDef* circleDef = (b2CircleDef*)def;
			circle->m_p = circleDef->localPosition;
			circle->m_radius = circleDef->radius;
			m_shape = circle;
		}
		break;

	case b2_polygonShape:
		{
			void* mem = allocator->Allocate(sizeof(b2PolygonShape));
			b2PolygonShape* polygon = new (mem) b2PolygonShape;
			b2PolygonDef* polygonDef = (b2PolygonDef*)def;
			polygon->Set(polygonDef->vertices, polygonDef->vertexCount);
			m_shape = polygon;
		}
		break;

	case b2_edgeShape:
		{
			void* mem = allocator->Allocate(sizeof(b2EdgeShape));
			b2EdgeShape* edge = new (mem) b2EdgeShape;
			b2EdgeDef* edgeDef = (b2EdgeDef*)def;
			edge->Set(edgeDef->vertex1, edgeDef->vertex2);
			m_shape = edge;
		}
		break;

	default:
		b2Assert(false);
		break;
	}

	// Create proxy in the broad-phase.
	b2AABB aabb;
	m_shape->ComputeAABB(&aabb, xf);

	bool inRange = broadPhase->InRange(aabb);

	// You are creating a shape outside the world box.
	b2Assert(inRange);

	if (inRange)
	{
		m_proxyId = broadPhase->CreateProxy(aabb, this);
	}
	else
	{
		m_proxyId = b2_nullProxy;
	}
}

void b2Fixture::Destroy(b2BlockAllocator* allocator, b2BroadPhase* broadPhase)
{
	// Remove proxy from the broad-phase.
	if (m_proxyId != b2_nullProxy)
	{
		broadPhase->DestroyProxy(m_proxyId);
		m_proxyId = b2_nullProxy;
	}

	// Free the child shape.
	switch (m_type)
	{
	case b2_circleShape:
		{
			b2CircleShape* s = (b2CircleShape*)m_shape;
			s->~b2CircleShape();
			allocator->Free(s, sizeof(b2CircleShape));
		}
		break;

	case b2_polygonShape:
		{
			b2PolygonShape* s = (b2PolygonShape*)m_shape;
			s->~b2PolygonShape();
			allocator->Free(s, sizeof(b2PolygonShape));
		}
		break;

	case b2_edgeShape:
		{
			b2EdgeShape* s = (b2EdgeShape*)m_shape;
			s->~b2EdgeShape();
			allocator->Free(s, sizeof(b2EdgeShape));
		}
		break;

	default:
		b2Assert(false);
		break;
	}

	m_shape = NULL;
}

bool b2Fixture::Synchronize(b2BroadPhase* broadPhase, const b2XForm& transform1, const b2XForm& transform2)
{
	if (m_proxyId == b2_nullProxy)
	{	
		return false;
	}

	// Compute an AABB that covers the swept shape (may miss some rotation effect).
	b2AABB aabb1, aabb2;
	m_shape->ComputeAABB(&aabb1, transform1);
	m_shape->ComputeAABB(&aabb2, transform2);
	
	b2AABB aabb;
	aabb.Combine(aabb1, aabb2);

	if (broadPhase->InRange(aabb))
	{
		broadPhase->MoveProxy(m_proxyId, aabb);
		return true;
	}
	else
	{
		return false;
	}
}

void b2Fixture::RefilterProxy(b2BroadPhase* broadPhase, const b2XForm& transform)
{
	if (m_proxyId == b2_nullProxy)
	{	
		return;
	}

	broadPhase->DestroyProxy(m_proxyId);

	b2AABB aabb;
	m_shape->ComputeAABB(&aabb, transform);

	bool inRange = broadPhase->InRange(aabb);

	if (inRange)
	{
		m_proxyId = broadPhase->CreateProxy(aabb, this);
	}
	else
	{
		m_proxyId = b2_nullProxy;
	}
}
