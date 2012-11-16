
#import "BaseAppController.h"
#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface FileUtilsDemo : CCLayer
{
    CCTextureAtlas	*atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
@end


@interface Issue1344 : FileUtilsDemo
{}
@end

@interface Test1 : FileUtilsDemo
{}
@end

@interface TestResolutionDirectories : FileUtilsDemo
{}
@end

@interface TestSearchPath : FileUtilsDemo
{}
@end
