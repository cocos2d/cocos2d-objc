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
-(NSString*) subtitle;

@end

@interface CrashTest : ActionManagerTest
{
}
@end

@interface LogicTest : ActionManagerTest
{
}
@end


@interface PauseTest : ActionManagerTest
{
}
@end

@interface RemoveTest : ActionManagerTest
{
}
@end

@interface Issue835 : ActionManagerTest
{
}
@end

