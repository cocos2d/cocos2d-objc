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

#ifndef VERTICAL_STACK_H
#define VERTICAL_STACK_H

//Added by me (SO)
#define COL_COUNT 5
#define ROW_COUNT 12
#define BULLET_Y 2.0f

class VerticalStack : public Test
{
public:

	VerticalStack()
	{
		{
			b2PolygonDef sd;
			sd.SetAsBox(50.0f, 10.0f, b2Vec2(0.0f, -10.0f), 0.0f);

			b2BodyDef bd;
			bd.position.Set(0.0f, 0.0f);
			b2Body* ground = m_world->CreateBody(&bd);
			ground->CreateShape(&sd);

			sd.SetAsBox(0.1f, 10.0f, b2Vec2(20.0f, 10.0f), 0.0f);
			ground->CreateShape(&sd);
		}

		float32 xs[COL_COUNT] = {0.0f, -10.0f, -5.0f, 5.0f, 10.0f};

		for (int32 j = 0; j < COL_COUNT; ++j)
		{
			b2PolygonDef sd;
			sd.SetAsBox(0.5f, 0.5f);
			sd.density = 1.0f;
			sd.friction = 0.3f;

			for (int i = 0; i < ROW_COUNT; ++i)
			{
				b2BodyDef bd;

				float32 x = 0.0f;
				//float32 x = RandomFloat(-0.02f, 0.02f);
				//float32 x = i % 2 == 0 ? -0.025f : 0.025f;
				bd.position.Set(xs[j] + x, 0.752f + 1.54f * i);
				b2Body* body = m_world->CreateBody(&bd);

				body->CreateShape(&sd);
				body->SetMassFromShapes();
			}
		}

		m_bullet = NULL;
	}

	void Keyboard(unsigned char key)
	{
		switch (key)
		{
		case ',':
			if (m_bullet != NULL)
			{
				m_world->DestroyBody(m_bullet);
				m_bullet = NULL;
			}

			{
				b2CircleDef sd;
				sd.density = 20.0f;
				sd.radius = 0.25f;
				sd.restitution = 0.05f;

				b2BodyDef bd;
				bd.isBullet = true;
				bd.position.Set(-31.0f, BULLET_Y);

				m_bullet = m_world->CreateBody(&bd);
				m_bullet->CreateShape(&sd);
				m_bullet->SetMassFromShapes();

				m_bullet->SetLinearVelocity(b2Vec2(400.0f, 0.0f));
			}
			break;
		}
	}

	void Step(Settings* settings)
	{
		Test::Step(settings);
		m_debugDraw.DrawString(5, m_textLine, "Press: (,) to launch a bullet.");
		m_textLine += 15;
	}

	static Test* Create()
	{
		return new VerticalStack;
	}

	b2Body* m_bullet;
};

#endif
