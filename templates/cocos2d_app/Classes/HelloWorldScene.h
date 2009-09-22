
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

// HelloWorld Layer
@interface HelloWorld : Layer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
