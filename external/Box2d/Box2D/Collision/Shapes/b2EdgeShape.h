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

#ifndef B2_EDGE_SHAPE_H
#define B2_EDGE_SHAPE_H

#include "b2Shape.h"

/// A circle shape.
class b2EdgeShape : public b2Shape
{
public:
	b2EdgeShape();
	~b2EdgeShape();

	/// Initialize this edge using the two vertices.
	void Set(const b2Vec2& v1, const b2Vec2& v2);

	/// @see b2Shape::TestPoint
	bool TestPoint(const b2XForm& transform, const b2Vec2& p) const;

	/// @see b2Shape::TestSegment
	b2SegmentCollide TestSegment(	const b2XForm& transform,
						float32* lambda,
						b2Vec2* normal,
						const b2Segment& segment,
						float32 maxLambda) const;

	/// @see b2Shape::ComputeAABB
	void ComputeAABB(b2AABB* aabb, const b2XForm& transform) const;

	/// @see b2Shape::ComputeMass
	void ComputeMass(b2MassData* massData, float32 density) const;

	/// @warning This only gives a consistent and sensible answer when when summed over a body only contains loops of edges
	/// @see b2Shape::ComputeSubmergedArea
	float32 ComputeSubmergedArea(	const b2Vec2& normal,
									float32 offset,
									const b2XForm& xf, 
									b2Vec2* c) const;
	
	/// @see b2Shape::ComputeSweepRadius
	float32 ComputeSweepRadius(const b2Vec2& pivot) const;

	/// Linear distance from vertex1 to vertex2:
	float32 GetLength() const;

	/// Local position of vertex in parent body
	const b2Vec2& GetVertex1() const;

	/// Local position of vertex in parent body
	const b2Vec2& GetVertex2() const;

	/// Perpendicular unit vector point, pointing from the solid side to the empty side: 
	const b2Vec2& GetNormalVector() const;
	
	/// Parallel unit vector, pointing from vertex1 to vertex2:
	const b2Vec2& GetDirectionVector() const;
	
	const b2Vec2& GetCorner1Vector() const;
	
	const b2Vec2& GetCorner2Vector() const;
	
	bool Corner1IsConvex() const;
	
	bool Corner2IsConvex() const;

	/// Get the supporting vertex index in the given direction.
	int32 GetSupport(const b2Vec2& d) const;

	/// Get the supporting vertex in the given direction.
	const b2Vec2& GetSupportVertex(const b2Vec2& d) const;

	/// Get the vertex count.
	int32 GetVertexCount() const { return 2; }

	/// Get a vertex by index. Used by b2Distance.
	const b2Vec2& GetVertex(int32 index) const;

	/// Get the next edge in the chain.
	b2EdgeShape* GetNextEdge() const;
	
	/// Get the previous edge in the chain.
	b2EdgeShape* GetPrevEdge() const;

	void SetPrevEdge(b2EdgeShape* edge, const b2Vec2& cornerDir, bool convex);
	void SetNextEdge(b2EdgeShape* edge, const b2Vec2& cornerDir, bool convex);
	
	b2Vec2 m_v1;
	b2Vec2 m_v2;
	
	float32 m_length;
	
	b2Vec2 m_normal;
	
	b2Vec2 m_direction;
	
	// Unit vector halfway between m_direction and m_prevEdge.m_direction:
	b2Vec2 m_cornerDir1;
	
	// Unit vector halfway between m_direction and m_nextEdge.m_direction:
	b2Vec2 m_cornerDir2;
	
	bool m_cornerConvex1;
	bool m_cornerConvex2;
	
	b2EdgeShape* m_nextEdge;
	b2EdgeShape* m_prevEdge;
};

inline float32 b2EdgeShape::GetLength() const
{
	return m_length;
}

inline const b2Vec2& b2EdgeShape::GetVertex1() const
{
	return m_v1;
}

inline const b2Vec2& b2EdgeShape::GetVertex2() const
{
	return m_v2;
}

inline const b2Vec2& b2EdgeShape::GetNormalVector() const
{
	return m_normal;
}

inline const b2Vec2& b2EdgeShape::GetDirectionVector() const
{
	return m_direction;
}

inline const b2Vec2& b2EdgeShape::GetCorner1Vector() const
{
	return m_cornerDir1;
}

inline const b2Vec2& b2EdgeShape::GetCorner2Vector() const
{
	return m_cornerDir2;
}

inline int32 b2EdgeShape::GetSupport(const b2Vec2& d) const
{
	return b2Dot(m_v1, d) > b2Dot(m_v2, d) ? 0 : 1;
}

inline const b2Vec2& b2EdgeShape::GetSupportVertex(const b2Vec2& d) const
{
	return b2Dot(m_v1, d) > b2Dot(m_v2, d) ? m_v1 : m_v2;
}

inline const b2Vec2& b2EdgeShape::GetVertex(int32 index) const
{
	b2Assert(0 <= index && index < 2);
	return (&m_v1)[index];
}

inline bool b2EdgeShape::Corner1IsConvex() const
{
	return m_cornerConvex1;
}

inline bool b2EdgeShape::Corner2IsConvex() const
{
	return m_cornerConvex2;
}

inline float32 b2EdgeShape::ComputeSweepRadius(const b2Vec2& pivot) const
{
	float32 ds1 = b2DistanceSquared(m_v1, pivot);
	float32 ds2 = b2DistanceSquared(m_v2, pivot);
	return b2Sqrt(b2Max(ds1, ds2));
}

#endif
