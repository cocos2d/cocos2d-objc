//
// cocos2d
//

#import "cocos2d.h"
#import "Box2d/Box2D.h"
#import "GLES-Render.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface MainLayer : CCLayer {

	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
}
@end

@interface PhysicsSprite : CCSprite
{
	b2Body *body_;	// strong ref
}

-(void) setPhysicsBody:(b2Body*)body;

@end
