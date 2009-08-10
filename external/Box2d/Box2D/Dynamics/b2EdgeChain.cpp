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

#include "b2EdgeChain.h"
#include "b2Body.h"
#include "b2Fixture.h"
#include "../Collision/Shapes/b2EdgeShape.h"

static void b2ConnectEdges(b2EdgeShape* edgeA, b2EdgeShape* edgeB)
{
	b2Vec2 cornerDir = edgeA->GetDirectionVector() + edgeB->GetDirectionVector();
	cornerDir.Normalize();
	bool convex = b2Dot(edgeA->GetDirectionVector(), edgeB->GetNormalVector()) > 0.0f;
	edgeA->SetNextEdge(edgeB, cornerDir, convex);
	edgeB->SetPrevEdge(edgeA, cornerDir, convex);
}

b2Fixture* b2CreateEdgeChain(b2Body* body, const b2EdgeChainDef* def)
{
	b2Vec2 v1, v2;
	int32 i;

	if (def->isLoop)
	{
		v1 = def->vertices[def->vertexCount-1];
		i = 0;
	}
	else
	{
		v1 = def->vertices[0];
		i = 1;
	}

	b2EdgeDef edgeDef;
	edgeDef.userData = def->userData;
	edgeDef.friction = def->friction;
	edgeDef.restitution = def->restitution;
	edgeDef.density = 0.0f;
	edgeDef.filter = def->filter;
	edgeDef.isSensor = def->isSensor;

	b2Fixture* fixture0 = NULL;
	b2Fixture* fixture1 = NULL;
	b2Fixture* fixture2 = NULL;

	for (; i < def->vertexCount; ++i)
	{
		v2 = def->vertices[i];

		edgeDef.vertex1 = v1;
		edgeDef.vertex2 = v2;

		fixture2 = body->CreateFixture(&edgeDef);

		if (fixture1 == NULL)
		{
			fixture0 = fixture2;
		}
		else
		{
			b2EdgeShape* edge1 = (b2EdgeShape*)fixture1->GetShape();
			b2EdgeShape* edge2 = (b2EdgeShape*)fixture2->GetShape();
			b2ConnectEdges(edge1, edge2);
		}

		fixture1 = fixture2;
		v1 = v2;
	}

	if (def->isLoop)
	{
		b2EdgeShape* edge1 = (b2EdgeShape*)fixture1->GetShape();
		b2EdgeShape* edge0 = (b2EdgeShape*)fixture0->GetShape();
		b2ConnectEdges(edge1, edge0);
	}
	
	return fixture0;
}
