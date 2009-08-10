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

#include "b2EdgeAndCircleContact.h"
#include "../b2Body.h"
#include "../b2Fixture.h"
#include "../b2WorldCallbacks.h"
#include "../../Collision/b2TimeOfImpact.h"
#include "../../Collision/Shapes/b2EdgeShape.h"
#include "../../Collision/Shapes/b2CircleShape.h"
#include "../../Common/b2BlockAllocator.h"

#include <new>
#include <string.h>

b2Contact* b2EdgeAndCircleContact::Create(b2Fixture* fixtureA, b2Fixture* fixtureB, b2BlockAllocator* allocator)
{
	void* mem = allocator->Allocate(sizeof(b2EdgeAndCircleContact));
	return new (mem) b2EdgeAndCircleContact(fixtureA, fixtureB);
}

void b2EdgeAndCircleContact::Destroy(b2Contact* contact, b2BlockAllocator* allocator)
{
	((b2EdgeAndCircleContact*)contact)->~b2EdgeAndCircleContact();
	allocator->Free(contact, sizeof(b2EdgeAndCircleContact));
}

b2EdgeAndCircleContact::b2EdgeAndCircleContact(b2Fixture* fixtureA, b2Fixture* fixtureB)
: b2Contact(fixtureA, fixtureB)
{
	b2Assert(m_fixtureA->GetType() == b2_edgeShape);
	b2Assert(m_fixtureB->GetType() == b2_circleShape);
	m_manifold.m_pointCount = 0;
	m_manifold.m_points[0].m_normalImpulse = 0.0f;
	m_manifold.m_points[0].m_tangentImpulse = 0.0f;
}

void b2EdgeAndCircleContact::Evaluate()
{
	b2Body* bodyA = m_fixtureA->GetBody();
	b2Body* bodyB = m_fixtureB->GetBody();

	b2CollideEdgeAndCircle(	&m_manifold,
							(b2EdgeShape*)m_fixtureA->GetShape(), bodyA->GetXForm(),
							(b2CircleShape*)m_fixtureB->GetShape(), bodyB->GetXForm());
}

float32 b2EdgeAndCircleContact::ComputeTOI(const b2Sweep& sweepA, const b2Sweep& sweepB) const
{
	b2TOIInput input;
	input.sweepA = sweepA;
	input.sweepB = sweepB;
	input.sweepRadiusA = m_fixtureA->ComputeSweepRadius(sweepA.localCenter);
	input.sweepRadiusB = m_fixtureB->ComputeSweepRadius(sweepB.localCenter);
	input.tolerance = b2_linearSlop;

	return b2TimeOfImpact(&input, (const b2EdgeShape*)m_fixtureA->GetShape(), (const b2CircleShape*)m_fixtureB->GetShape());
}
