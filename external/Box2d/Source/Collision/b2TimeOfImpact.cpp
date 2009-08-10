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
#include "b2Distance.h"
#include "b2TimeOfImpact.h"
#include "Shapes/b2CircleShape.h"
#include "Shapes/b2PolygonShape.h"
#include "Shapes/b2EdgeShape.h"

#include <stdio.h>

int32 b2_maxToiIters = 0;
int32 b2_maxToiRootIters = 0;

#if 0
// This algorithm uses conservative advancement to compute the time of
// impact (TOI) of two shapes.
// Refs: Bullet, Young Kim
template <typename TA, typename TB>
float32 b2TimeOfImpact(const b2TOIInput* input, const TA* shapeA, const TB* shapeB)
{
	b2Sweep sweepA = input->sweepA;
	b2Sweep sweepB = input->sweepB;

	float32 r1 = input->sweepRadiusA;
	float32 r2 = input->sweepRadiusB;

	float32 tolerance = input->tolerance;

	float32 radius = shapeA->m_radius + shapeB->m_radius;

	b2Assert(sweepA.t0 == sweepB.t0);
	b2Assert(1.0f - sweepA.t0 > B2_FLT_EPSILON);

	b2Vec2 v1 = sweepA.c - sweepA.c0;
	b2Vec2 v2 = sweepB.c - sweepB.c0;
	float32 omega1 = sweepA.a - sweepA.a0;
	float32 omega2 = sweepB.a - sweepB.a0;

	float32 alpha = 0.0f;

	b2DistanceInput distanceInput;
	distanceInput.useRadii = false;
	b2SimplexCache cache;
	cache.count = 0;

	b2Vec2 p1, p2;
	const int32 k_maxIterations = 1000;	// TODO_ERIN b2Settings
	int32 iter = 0;
	b2Vec2 normal = b2Vec2_zero;
	float32 distance = 0.0f;
	float32 targetDistance = 0.0f;
	for(;;)
	{
		b2XForm xf1, xf2;
		sweepA.GetTransform(&xf1, alpha);
		sweepB.GetTransform(&xf2, alpha);

		// Get the distance between shapes.
		distanceInput.transformA = xf1;
		distanceInput.transformB = xf2;
		b2DistanceOutput distanceOutput;
		b2Distance(&distanceOutput, &cache, &distanceInput, shapeA, shapeB);
		distance = distanceOutput.distance;
		p1 = distanceOutput.pointA;
		p2 = distanceOutput.pointB;

		if (iter == 0)
		{
			// Compute a reasonable target distance to give some breathing room
			// for conservative advancement.
			if (distance > radius)
			{
				targetDistance = b2Max(radius - tolerance, 0.75f * radius);
			}
			else
			{
				targetDistance = b2Max(distance - tolerance, 0.02f * radius);
			}
		}

		if (distance - targetDistance < 0.5f * tolerance || iter == k_maxIterations)
		{
			break;
		}

		normal = p2 - p1;
		normal.Normalize();

		// Compute upper bound on remaining movement.
		float32 approachVelocityBound = b2Dot(normal, v1 - v2) + b2Abs(omega1) * r1 + b2Abs(omega2) * r2;
		if (b2Abs(approachVelocityBound) < B2_FLT_EPSILON)
		{
			alpha = 1.0f;
			break;
		}

		// Get the conservative time increment. Don't advance all the way.
		float32 dAlpha = (distance - targetDistance) / approachVelocityBound;
		//float32 dt = (distance - 0.5f * b2_linearSlop) / approachVelocityBound;
		float32 newAlpha = alpha + dAlpha;

		// The shapes may be moving apart or a safe distance apart.
		if (newAlpha < 0.0f || 1.0f < newAlpha)
		{
			alpha = 1.0f;
			break;
		}

		// Ensure significant advancement.
		if (newAlpha < (1.0f + 100.0f * B2_FLT_EPSILON) * alpha)
		{
			break;
		}

		alpha = newAlpha;

		++iter;
	}

	b2_maxToiIters = b2Max(iter, b2_maxToiIters);

	return alpha;
}

#else


template <typename TA, typename TB>
struct b2SeparationFunction
{
	enum Type
	{
		e_points,
		e_faceA,
		e_faceB
	};

	void Initialize(const b2SimplexCache* cache,
		const TA* shapeA, const b2XForm& transformA,
		const TB* shapeB, const b2XForm& transformB)
	{
		m_shapeA = shapeA;
		m_shapeB = shapeB;
		int32 count = cache->count;
		b2Assert(0 < count && count < 3);

		if (count == 1)
		{
			m_type = e_points;
			b2Vec2 localPointA = m_shapeA->GetVertex(cache->indexA[0]);
			b2Vec2 localPointB = m_shapeB->GetVertex(cache->indexB[0]);
			b2Vec2 pointA = b2Mul(transformA, localPointA);
			b2Vec2 pointB = b2Mul(transformB, localPointB);
			m_axis = pointB - pointA;
			m_axis.Normalize();
		}
		else if (cache->indexB[0] == cache->indexB[1])
		{
			// Two points on A and one on B
			m_type = e_faceA;
			b2Vec2 localPointA1 = m_shapeA->GetVertex(cache->indexA[0]);
			b2Vec2 localPointA2 = m_shapeA->GetVertex(cache->indexA[1]);
			b2Vec2 localPointB = m_shapeB->GetVertex(cache->indexB[0]);
			m_localPoint = 0.5f * (localPointA1 + localPointA2);
			m_axis = b2Cross(localPointA2 - localPointA1, 1.0f);
			m_axis.Normalize();

			b2Vec2 normal = b2Mul(transformA.R, m_axis);
			b2Vec2 pointA = b2Mul(transformA, m_localPoint);
			b2Vec2 pointB = b2Mul(transformB, localPointB);

			float32 s = b2Dot(pointB - pointA, normal);
			if (s < 0.0f)
			{
				m_axis = -m_axis;
			}
		}
		else
		{
			// Two points on B and one or two points on A.
			// We ignore the second point on A.
			m_type = e_faceB;
			b2Vec2 localPointA = shapeA->GetVertex(cache->indexA[0]);
			b2Vec2 localPointB1 = shapeB->GetVertex(cache->indexB[0]);
			b2Vec2 localPointB2 = shapeB->GetVertex(cache->indexB[1]);
			m_localPoint = 0.5f * (localPointB1 + localPointB2);
			m_axis = b2Cross(localPointB2 - localPointB1, 1.0f);
			m_axis.Normalize();

			b2Vec2 normal = b2Mul(transformB.R, m_axis);
			b2Vec2 pointB = b2Mul(transformB, m_localPoint);
			b2Vec2 pointA = b2Mul(transformA, localPointA);

			float32 s = b2Dot(pointA - pointB, normal);
			if (s < 0.0f)
			{
				m_axis = -m_axis;
			}
		}
	}

	float32 Evaluate(const b2XForm& transformA, const b2XForm& transformB)
	{
		switch (m_type)
		{
		case e_points:
			{
				b2Vec2 axisA = b2MulT(transformA.R,  m_axis);
				b2Vec2 axisB = b2MulT(transformB.R, -m_axis);
				b2Vec2 localPointA = m_shapeA->GetSupportVertex(axisA);
				b2Vec2 localPointB = m_shapeB->GetSupportVertex(axisB);
				b2Vec2 pointA = b2Mul(transformA, localPointA);
				b2Vec2 pointB = b2Mul(transformB, localPointB);
				float32 separation = b2Dot(pointB - pointA, m_axis);
				return separation;
			}

		case e_faceA:
			{
				b2Vec2 normal = b2Mul(transformA.R, m_axis);
				b2Vec2 pointA = b2Mul(transformA, m_localPoint);

				b2Vec2 axisB = b2MulT(transformB.R, -normal);

				b2Vec2 localPointB = m_shapeB->GetSupportVertex(axisB);
				b2Vec2 pointB = b2Mul(transformB, localPointB);

				float32 separation = b2Dot(pointB - pointA, normal);
				return separation;
			}

		case e_faceB:
			{
				b2Vec2 normal = b2Mul(transformB.R, m_axis);
				b2Vec2 pointB = b2Mul(transformB, m_localPoint);

				b2Vec2 axisA = b2MulT(transformA.R, -normal);

				b2Vec2 localPointA = m_shapeA->GetSupportVertex(axisA);
				b2Vec2 pointA = b2Mul(transformA, localPointA);

				float32 separation = b2Dot(pointA - pointB, normal);
				return separation;
			}

		default:
			b2Assert(false);
			return 0.0f;
		}
	}

	const TA* m_shapeA;
	const TB* m_shapeB;
	Type m_type;
	b2Vec2 m_localPoint;
	b2Vec2 m_axis;
};

// CCD via the secant method.
template <typename TA, typename TB>
float32 b2TimeOfImpact(const b2TOIInput* input, const TA* shapeA, const TB* shapeB)
{
	b2Sweep sweepA = input->sweepA;
	b2Sweep sweepB = input->sweepB;

	b2Assert(sweepA.t0 == sweepB.t0);
	b2Assert(1.0f - sweepA.t0 > B2_FLT_EPSILON);

	float32 radius = shapeA->m_radius + shapeB->m_radius;
	float32 tolerance = input->tolerance;

	float32 alpha = 0.0f;

	const int32 k_maxIterations = 1000;	// TODO_ERIN b2Settings
	int32 iter = 0;
	float32 target = 0.0f;

	// Prepare input for distance query.
	b2SimplexCache cache;
	cache.count = 0;
	b2DistanceInput distanceInput;
	distanceInput.useRadii = false;

	for(;;)
	{
		b2XForm xfA, xfB;
		sweepA.GetTransform(&xfA, alpha);
		sweepB.GetTransform(&xfB, alpha);

		// Get the distance between shapes.
		distanceInput.transformA = xfA;
		distanceInput.transformB = xfB;
		b2DistanceOutput distanceOutput;
		b2Distance(&distanceOutput, &cache, &distanceInput, shapeA, shapeB);

		if (distanceOutput.distance <= 0.0f)
		{
			alpha = 1.0f;
			break;
		}

		b2SeparationFunction<TA, TB> fcn;
		fcn.Initialize(&cache, shapeA, xfA, shapeB, xfB);

		float32 separation = fcn.Evaluate(xfA, xfB);
		if (separation <= 0.0f)
		{
			alpha = 1.0f;
			break;
		}

		if (iter == 0)
		{
			// Compute a reasonable target distance to give some breathing room
			// for conservative advancement. We take advantage of the shape radii
			// to create additional clearance.
			if (separation > radius)
			{
				target = b2Max(radius - tolerance, 0.75f * radius);
			}
			else
			{
				target = b2Max(separation - tolerance, 0.02f * radius);
			}
		}

		if (separation - target < 0.5f * tolerance)
		{
			if (iter == 0)
			{
				alpha = 1.0f;
				break;
			}

			break;
		}

#if 0
		// Dump the curve seen by the root finder
		{
			const int32 N = 100;
			float32 dx = 1.0f / N;
			float32 xs[N+1];
			float32 fs[N+1];

			float32 x = 0.0f;

			for (int32 i = 0; i <= N; ++i)
			{
				sweepA.GetTransform(&xfA, x);
				sweepB.GetTransform(&xfB, x);
				float32 f = fcn.Evaluate(xfA, xfB) - target;

				printf("%g %g\n", x, f);

				xs[i] = x;
				fs[i] = f;

				x += dx;
			}
		}
#endif

		// Compute 1D root of: f(x) - target = 0
		float32 newAlpha = alpha;
		{
			float32 x1 = alpha, x2 = 1.0f;

			float32 f1 = separation;

			sweepA.GetTransform(&xfA, x2);
			sweepB.GetTransform(&xfB, x2);
			float32 f2 = fcn.Evaluate(xfA, xfB);

			// If intervals don't overlap at t2, then we are done.
			if (f2 >= target)
			{
				alpha = 1.0f;
				break;
			}

			// Determine when intervals intersect.
			int32 rootIterCount = 0;
			for (;;)
			{
				// Use a mix of the secant rule and bisection.
				float32 x;
				if (rootIterCount & 1)
				{
					// Secant rule to improve convergence.
					x = x1 + (target - f1) * (x2 - x1) / (f2 - f1);
				}
				else
				{
					// Bisection to guarantee progress.
					x = 0.5f * (x1 + x2);
				}

				sweepA.GetTransform(&xfA, x);
				sweepB.GetTransform(&xfB, x);

				float32 f = fcn.Evaluate(xfA, xfB);

				if (b2Abs(f - target) < 0.025f * tolerance)
				{
					newAlpha = x;
					break;
				}

				// Ensure we continue to bracket the root.
				if (f > target)
				{
					x1 = x;
					f1 = f;
				}
				else
				{
					x2 = x;
					f2 = f;
				}

				++rootIterCount;

				b2Assert(rootIterCount < 50);
			}

			b2_maxToiRootIters = b2Max(b2_maxToiRootIters, rootIterCount);
		}

		// Ensure significant advancement.
		if (newAlpha < (1.0f + 100.0f * B2_FLT_EPSILON) * alpha)
		{
			break;
		}

		alpha = newAlpha;

		++iter;

		if (iter == k_maxIterations)
		{
			break;
		}
	}

	b2_maxToiIters = b2Max(b2_maxToiIters, iter);

	return alpha;
}

#endif

template float32
b2TimeOfImpact(const b2TOIInput* input, const b2CircleShape* shapeA, const b2CircleShape* shapeB);

template float32
b2TimeOfImpact(const b2TOIInput* input, const b2CircleShape* shapeA, const b2EdgeShape* shapeB);

template float32
b2TimeOfImpact(const b2TOIInput* input, const b2CircleShape* shapeA, const b2PolygonShape* shapeB);

template float32
b2TimeOfImpact(const b2TOIInput* input,	const b2EdgeShape* shapeA, const b2CircleShape* shapeB);

template float32
b2TimeOfImpact(const b2TOIInput* input,	const b2EdgeShape* shapeA, const b2EdgeShape* shapeB);

template float32
b2TimeOfImpact(const b2TOIInput* input,	const b2EdgeShape* shapeA, const b2PolygonShape* shapeB);

template float32
b2TimeOfImpact(const b2TOIInput* input,	const b2PolygonShape* shapeA, const b2CircleShape* shapeB);

template float32
b2TimeOfImpact(const b2TOIInput* input,	const b2PolygonShape* shapeA, const b2EdgeShape* shapeB);

template float32
b2TimeOfImpact(const b2TOIInput* input,	const b2PolygonShape* shapeA, const b2PolygonShape* shapeB);

