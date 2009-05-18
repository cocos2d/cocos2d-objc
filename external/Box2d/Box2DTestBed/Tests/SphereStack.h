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

#ifndef SPHERE_STACK_H
#define SPHERE_STACK_H

class SphereStack : public Test
{
public:

	enum
	{
		e_count = 10
	};

	SphereStack()
	{
		{
			b2PolygonDef sd;
			sd.SetAsBox(50.0f, 10.0f);

			b2BodyDef bd;
			bd.position.Set(0.0f, -10.0f);

			b2Body* ground = m_world->CreateBody(&bd);
			ground->CreateShape(&sd);
		}

		{
			b2CircleDef sd;
			sd.radius = 1.0f;
			sd.density = 1.0f;

			for (int32 i = 0; i < e_count; ++i)
			{
				b2BodyDef bd;
				bd.position.Set(0.0, 2.0f + 3.0f * i);

				m_bodies[i] = m_world->CreateBody(&bd);

				m_bodies[i]->CreateShape(&sd);
				m_bodies[i]->SetMassFromShapes();
			}
		}
	}

	void Step(Settings* settings)
	{
		Test::Step(settings);

		/*
		for (int32 i = 0; i < e_count; ++i)
		{
			printf("%g ", m_bodies[i]->GetWorldCenter().y);
		}

		for (int32 i = 0; i < e_count; ++i)
		{
			printf("%g ", m_bodies[i]->GetLinearVelocity().y);
		}

		printf("\n");
		*/ 
	}

	static Test* Create()
	{
		return new SphereStack;
	}

	b2Body* m_bodies[e_count];
};

#endif
