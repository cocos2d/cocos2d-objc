/*
* Copyright (c) 2007-2009 Erin Catto http://www.gphysics.com
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

#include "b2Collision.h"
#include "Shapes/b2CircleShape.h"
#include "Shapes/b2EdgeShape.h"
#include "Shapes/b2PolygonShape.h"


// This implements 2-sided edge vs circle collision.
void b2CollideEdgeAndCircle(b2Manifold* manifold,
							const b2EdgeShape* edge, 
							const b2XForm& transformA,
							const b2CircleShape* circle, 
							const b2XForm& transformB)
{
	manifold->m_pointCount = 0;
	b2Vec2 cLocal = b2MulT(transformA, b2Mul(transformB, circle->m_p));
	b2Vec2 normal = edge->m_normal;
	b2Vec2 v1 = edge->m_v1;
	b2Vec2 v2 = edge->m_v2;
	float32 radius = edge->m_radius + circle->m_radius;

	// Barycentric coordinates
	float32 u1 = b2Dot(cLocal - v1, v2 - v1);
	float32 u2 = b2Dot(cLocal - v2, v1 - v2);

	if (u1 <= 0.0f)
	{
		// Behind v1
		if (b2DistanceSquared(cLocal, v1) > radius * radius)
		{
			return;
		}

		manifold->m_pointCount = 1;
		manifold->m_type = b2Manifold::e_faceA;
		manifold->m_localPlaneNormal = cLocal - v1;
		manifold->m_localPlaneNormal.Normalize();
		manifold->m_localPoint = v1;
		manifold->m_points[0].m_localPoint = circle->m_p;
		manifold->m_points[0].m_id.key = 0;
	}
	else if (u2 <= 0.0f)
	{
		// Ahead of v2
		if (b2DistanceSquared(cLocal, v2) > radius * radius)
		{
			return;
		}

		manifold->m_pointCount = 1;
		manifold->m_type = b2Manifold::e_faceA;
		manifold->m_localPlaneNormal = cLocal - v2;
		manifold->m_localPlaneNormal.Normalize();
		manifold->m_localPoint = v2;
		manifold->m_points[0].m_localPoint = circle->m_p;
		manifold->m_points[0].m_id.key = 0;
	}
	else
	{
		float32 separation = b2Dot(cLocal - v1, normal);
		if (separation < -radius || radius < separation)
		{
			return;
		}
		
		manifold->m_pointCount = 1;
		manifold->m_type = b2Manifold::e_faceA;
		manifold->m_localPlaneNormal = separation < 0.0f ? -normal : normal;
		manifold->m_localPoint = 0.5f * (v1 + v2);
		manifold->m_points[0].m_localPoint = circle->m_p;
		manifold->m_points[0].m_id.key = 0;
	}
}

#if 1

// Polygon versus 2-sided edge.
void b2CollidePolyAndEdge(b2Manifold* manifold,
						  const b2PolygonShape* polygon, 
						  const b2XForm& transformA,
						  const b2EdgeShape* edge, 
						  const b2XForm& transformB)
{
	b2PolygonShape polygonB;
	polygonB.SetAsEdge(edge->m_v1, edge->m_v2);

	b2CollidePolygons(manifold, polygon, transformA, &polygonB, transformB);
}

#else

void b2CollidePolyAndEdge(b2Manifold* manifold,
							const b2PolygonShape* polygon, 
							const b2XForm& transformA,
							const b2EdgeShape* edge, 
							const b2XForm& transformB)
{
	manifold->m_pointCount = 0;
	b2Vec2 v1 = b2Mul(transformB, edge->GetVertex1());
	b2Vec2 v2 = b2Mul(transformB, edge->GetVertex2());
	b2Vec2 n = b2Mul(transformB.R, edge->GetNormalVector());
	b2Vec2 v1Local = b2MulT(transformA, v1);
	b2Vec2 v2Local = b2MulT(transformA, v2);
	b2Vec2 nLocal = b2MulT(transformA.R, n);

	float32 totalRadius = polygon->m_radius + edge->m_radius;

	float32 separation1;
	int32 separationIndex1 = -1;			// which normal on the polygon found the shallowest depth?
	float32 separationMax1 = -B2_FLT_MAX;	// the shallowest depth of edge in polygon
	float32 separation2;
	int32 separationIndex2 = -1;			// which normal on the polygon found the shallowest depth?
	float32 separationMax2 = -B2_FLT_MAX;	// the shallowest depth of edge in polygon
	float32 separationMax = -B2_FLT_MAX;	// the shallowest depth of edge in polygon
	bool separationV1 = false;				// is the shallowest depth from edge's v1 or v2 vertex?
	int32 separationIndex = -1;				 // which normal on the polygon found the shallowest depth?

	int32 vertexCount = polygon->m_vertexCount;
	const b2Vec2* vertices = polygon->m_vertices;
	const b2Vec2* normals = polygon->m_normals;

	int32 enterStartIndex = -1; // the last polygon vertex above the edge
	int32 enterEndIndex = -1;	// the first polygon vertex below the edge
	int32 exitStartIndex = -1;	// the last polygon vertex below the edge
	int32 exitEndIndex = -1;	// the first polygon vertex above the edge
	//int32 deepestIndex;

	// the "N" in the following variables refers to the edge's normal. 
	// these are projections of polygon vertices along the edge's normal, 
	// a.k.a. they are the separation of the polygon from the edge. 
	float32 prevSepN = totalRadius;
	float32 nextSepN = totalRadius;
	float32 enterSepN = totalRadius;	// the depth of enterEndIndex under the edge (stored as a separation, so it's negative)
	float32 exitSepN = totalRadius;	// the depth of exitStartIndex under the edge (stored as a separation, so it's negative)
	float32 deepestSepN = B2_FLT_MAX; // the depth of the deepest polygon vertex under the end (stored as a separation, so it's negative)

	// for each polygon normal, get the edge's depth into the polygon. 
	// for each polygon vertex, get the vertex's depth into the edge. 
	// use these calculations to define the remaining variables declared above.
	prevSepN = b2Dot(vertices[vertexCount-1] - v1Local, nLocal);
	for (int32 i = 0; i < vertexCount; i++)
	{
		// Polygon normal separation.
		separation1 = b2Dot(v1Local - vertices[i], normals[i]);
		separation2 = b2Dot(v2Local - vertices[i], normals[i]);

		if (separation2 < separation1)
		{
			if (separation2 > separationMax)
			{
				separationMax = separation2;
				separationV1 = false;
				separationIndex = i;
			}
		}
		else
		{
			if (separation1 > separationMax)
			{
				separationMax = separation1;
				separationV1 = true;
				separationIndex = i;
			}
		}

		if (separation1 > separationMax1)
		{
			separationMax1 = separation1;
			separationIndex1 = i;
		}

		if (separation2 > separationMax2)
		{
			separationMax2 = separation2;
			separationIndex2 = i;
		}

		// Edge normal separation
		nextSepN = b2Dot(vertices[i] - v1Local, nLocal);
		if (nextSepN >= totalRadius && prevSepN < totalRadius)
		{
			exitStartIndex = (i == 0) ? vertexCount-1 : i-1;
			exitEndIndex = i;
			exitSepN = prevSepN;
		}
		else if (nextSepN < totalRadius && prevSepN >= totalRadius)
		{
			enterStartIndex = (i == 0) ? vertexCount-1 : i-1;
			enterEndIndex = i;
			enterSepN = nextSepN;
		}

		if (nextSepN < deepestSepN)
		{
			deepestSepN = nextSepN;
			//deepestIndex = i;
		}
		prevSepN = nextSepN;
	}

	if (enterStartIndex == -1)
	{
		// Edge normal separation
		// polygon is entirely below or entirely above edge, return with no contact:
		return;
	}

	if (separationMax > totalRadius)
	{
		// Face normal separation
		// polygon is laterally disjoint with edge, return with no contact:
		return;
	}

	// if the polygon is near a convex corner on the edge
	if ((separationV1 && edge->Corner1IsConvex()) || (!separationV1 && edge->Corner2IsConvex()))
	{
		// if shallowest depth was from a polygon normal (meaning the polygon face is longer than the edge shape),
		// use the edge's vertex as the contact point:
		if (separationMax > deepestSepN + b2_linearSlop)
		{
			// if -normal angle is closer to adjacent edge than this edge, 
			// let the adjacent edge handle it and return with no contact:
			if (separationV1)
			{
				if (b2Dot(normals[separationIndex1], b2MulT(transformA.R, b2Mul(transformB.R, edge->GetCorner1Vector()))) >= 0.0f)
				{
					return;
				}
			}
			else
			{
				if (b2Dot(normals[separationIndex2], b2MulT(transformA.R, b2Mul(transformB.R, edge->GetCorner2Vector()))) <= 0.0f)
				{
					return;
				}
			}

			manifold->m_pointCount = 1;
			manifold->m_type = b2Manifold::e_faceA
			manifold->m_localPlaneNormal = normals[separationIndex];
			manifold->m_points[0].m_id.key = 0;
			manifold->m_points[0].m_id.features.incidentEdge = (uint8)separationIndex;
			manifold->m_points[0].m_id.features.incidentVertex = b2_nullFeature;
			manifold->m_points[0].m_id.features.referenceEdge = 0;
			manifold->m_points[0].m_id.features.flip = 0;
			if (separationV1)
			{
				manifold->m_points[0].m_localPoint = edge->GetVertex1();
			}
			else
			{
				manifold->m_points[0].m_localPoint = edge->GetVertex2();
			}
			return;
		}
	}

	// We're going to use the edge's normal now.
	manifold->m_localPlaneNormal = edge->GetNormalVector();
	manifold->m_localPoint = 0.5f * (edge->m_v1 + edge->m_v2);

	// Check whether we only need one contact point.
	if (enterEndIndex == exitStartIndex)
	{
		manifold->m_pointCount = 1;
		manifold->m_points[0].m_id.key = 0;
		manifold->m_points[0].m_id.features.incidentEdge = (uint8)enterEndIndex;
		manifold->m_points[0].m_id.features.incidentVertex = b2_nullFeature;
		manifold->m_points[0].m_id.features.referenceEdge = 0;
		manifold->m_points[0].m_id.features.flip = 0;
		manifold->m_points[0].m_localPoint = vertices[enterEndIndex];
		return;
	}

	manifold->m_pointCount = 2;

	// dirLocal should be the edge's direction vector, but in the frame of the polygon.
	b2Vec2 dirLocal = b2Cross(nLocal, -1.0f); // TODO: figure out why this optimization didn't work
	//b2Vec2 dirLocal = b2MulT(transformA.R, b2Mul(transformB.R, edge->GetDirectionVector()));

	float32 dirProj1 = b2Dot(dirLocal, vertices[enterEndIndex] - v1Local);
	float32 dirProj2;

	// The contact resolution is more robust if the two manifold points are 
	// adjacent to each other on the polygon. So pick the first two polygon
	// vertices that are under the edge:
	exitEndIndex = (enterEndIndex == vertexCount - 1) ? 0 : enterEndIndex + 1;
	if (exitEndIndex != exitStartIndex)
	{
		exitStartIndex = exitEndIndex;
		exitSepN = b2Dot(nLocal, vertices[exitStartIndex] - v1Local);
	}
	dirProj2 = b2Dot(dirLocal, vertices[exitStartIndex] - v1Local);

	manifold->m_points[0].m_id.key = 0;
	manifold->m_points[0].m_id.features.incidentEdge = (uint8)enterEndIndex;
	manifold->m_points[0].m_id.features.incidentVertex = b2_nullFeature;
	manifold->m_points[0].m_id.features.referenceEdge = 0;
	manifold->m_points[0].m_id.features.flip = 0;

	if (dirProj1 > edge->GetLength())
	{
		manifold->m_points[0].localPointA = v2Local;
		manifold->m_points[0].localPointB = edge->GetVertex2();
	}
	else
	{
		manifold->m_points[0].localPointA = vertices[enterEndIndex];
		manifold->m_points[0].localPointB = b2MulT(transformB, b2Mul(transformA, vertices[enterEndIndex]));
	}

	manifold->m_points[1].m_id.key = 0;
	manifold->m_points[1].m_id.features.incidentEdge = (uint8)exitStartIndex;
	manifold->m_points[1].m_id.features.incidentVertex = b2_nullFeature;
	manifold->m_points[1].m_id.features.referenceEdge = 0;
	manifold->m_points[1].m_id.features.flip = 0;

	if (dirProj2 < 0.0f)
	{
		manifold->m_points[1].localPointA = v1Local;
		manifold->m_points[1].localPointB = edge->GetVertex1();
	}
	else
	{
		manifold->m_points[1].localPointA = vertices[exitStartIndex];
		manifold->m_points[1].localPointB = b2MulT(transformB, b2Mul(transformA, vertices[exitStartIndex]));
		manifold->m_points[1].separation = exitSepN - totalRadius;
	}
}

#endif
