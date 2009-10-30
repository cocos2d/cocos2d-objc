#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface ActionManagerTest: CCLayer
{
    CCTextureAtlas *atlas;
}
-(NSString*) title;
@end

@interface Test1 : ActionManagerTest
{
}
@end

@interface Test2 : ActionManagerTest
{
}
@end
