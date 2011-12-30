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
	CCTexture2D *spriteTexture_; // weak ref

	cpSpace *space_; // strong ref

	cpShape *walls_[4];
}
@end


@interface PhysicsSprite : CCSprite
{
	cpBody *body_;	// strong ref
}

-(void) setPhysicsBody:(cpBody*)body;

@end
