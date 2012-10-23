//
// cocos2d
//

#import "cocos2d.h"
#import "chipmunk.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface MainLayer : CCLayer
{
	CCTexture2D *_spriteTexture; // weak ref
	CCPhysicsDebugNode *_debugLayer; // weak ref
	
	cpSpace *_space; // strong ref

	
	cpShape *_walls[4];
}
@end
