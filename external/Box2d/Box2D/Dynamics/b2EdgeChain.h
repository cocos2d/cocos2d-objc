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

#ifndef B2_EDGE_CHAIN_H
#define B2_EDGE_CHAIN_H

#include "b2Fixture.h"

class b2Body;

/// This structure is used to build circle shapes.
struct b2EdgeChainDef
{
	b2EdgeChainDef()
	{
		userData = NULL;
		friction = 0.2f;
		restitution = 0.0f;
		isSensor = false;
		filter.categoryBits = 0x0001;
		filter.maskBits = 0xFFFF;
		filter.groupIndex = 0;
		vertices = NULL;
		vertexCount = 0;
		isLoop = true;
	}

	/// Use this to store application specific fixture data. This is assigned
	/// to each fixture in the chain.
	void* userData;

	/// The friction coefficient, usually in the range [0,1].
	float32 friction;

	/// The restitution (elasticity) usually in the range [0,1].
	float32 restitution;

	/// A sensor shape collects contact information but never generates a collision
	/// response.
	bool isSensor;

	/// Contact filtering data.
	b2FilterData filter;

	/// The vertices in local coordinates. You must manage the memory
	/// of this array on your own, outside of Box2D. 
	b2Vec2* vertices;

	/// The number of vertices in the chain. 
	int32 vertexCount;

	/// Whether to create an extra edge between the first and last vertices:
	bool isLoop;
};

/// Create a chain of edges on the provided body. The edge chain does not alter the mass
/// of the body, this must be done manually through b2Body::SetMassData.
/// @return the first fixture of the chain.
b2Fixture* b2CreateEdgeChain(b2Body* body, const b2EdgeChainDef* def);

/// Destroy an edge chain provided the first edge fixture.
void b2DestroyEdgeChain(b2Body* body, b2Fixture* firstEdge);

#endif
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

#ifndef B2_EDGE_CHAIN_H
#define B2_EDGE_CHAIN_H

#include "b2Fixture.h"

class b2Body;

/// This structure is used to build circle shapes.
struct b2EdgeChainDef
{
	b2EdgeChainDef()
	{
		userData = NULL;
		friction = 0.2f;
		restitution = 0.0f;
		vertexCount = 0;
		isLoop = true;
		vertices = NULL;
	}

	/// Use this to store application specific fixture data. This is assigned
	/// to each fixture in the chain.
	void* userData;

	/// The friction coefficient, usually in the range [0,1].
	float32 friction;

	/// The restitution (elasticity) usually in the range [0,1].
	float32 restitution;

	/// A sensor shape collects contact information but never generates a collision
	/// response.
	bool isSensor;

	/// Contact filtering data.
	b2FilterData filter;

	/// The vertices in local coordinates. You must manage the memory
	/// of this array on your own, outside of Box2D. 
	b2Vec2* vertices;

	/// The number of vertices in the chain. 
	int32 vertexCount;

	/// Whether to create an extra edge between the first and last vertices:
	bool isLoop;
};

/// Create a chain of edges on the provided body. The edge chain does not alter the mass
/// of the body, this must be done manually through b2Body::SetMassData.
/// @return the first fixture of the chain.
b2Fixture* b2CreateEdgeChain(b2Body* body, const b2EdgeChainDef* def);

/// Destroy an edge chain provided the first edge fixture.
void b2DestroyEdgeChain(b2Body* body, b2Fixture* firstEdge);

#endif
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

#ifndef B2_EDGE_CHAIN_H
#define B2_EDGE_CHAIN_H

#include "b2Fixture.h"

class b2Body;

/// This structure is used to build circle shapes.
struct b2EdgeChainDef
{
	b2EdgeChainDef()
	{
		userData = NULL;
		friction = 0.2f;
		restitution = 0.0f;
		vertexCount = 0;
		isLoop = true;
		vertices = NULL;
	}

	/// Use this to store application specific fixture data. This is assigned
	/// to each fixture in the chain.
	void* userData;

	/// The friction coefficient, usually in the range [0,1].
	float32 friction;

	/// The restitution (elasticity) usually in the range [0,1].
	float32 restitution;

	/// A sensor shape collects contact information but never generates a collision
	/// response.
	bool isSensor;

	/// Contact filtering data.
	b2FilterData filter;

	/// The vertices in local coordinates. You must manage the memory
	/// of this array on your own, outside of Box2D. 
	b2Vec2* vertices;

	/// The number of vertices in the chain. 
	int32 vertexCount;

	/// Whether to create an extra edge between the first and last vertices:
	bool isLoop;
};

/// Create a chain of edges on the provided body. The edge chain does not alter the mass
/// of the body, this must be done manually through b2Body::SetMassData.
/// @return the first fixture of the chain.
b2Fixture* b2CreateEdgeChain(b2Body* body, const b2EdgeChainDef* def);

/// Destroy an edge chain provided the first edge fixture.
void b2DestroyEdgeChain(b2Body* body, b2Fixture* firstEdge);

#endif
