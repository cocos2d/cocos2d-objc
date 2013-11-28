#import "cocos2d.h"
#import "BaseAppController.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface ActionManagerTest: CCNode
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

