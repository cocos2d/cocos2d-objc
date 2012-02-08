#import "cocos2d.h"
#import "BaseAppController.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface ZwoptexTest: CCLayer
{
    CCTextureAtlas	*atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
@end


@interface ZwoptexGenericTest : ZwoptexTest
{
	CCSprite *sprite1, *sprite2;
	int counter;
}
@end
