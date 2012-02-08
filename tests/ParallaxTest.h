#import "cocos2d.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface ParallaxDemo: CCLayer
{
    CCTextureAtlas *atlas;
}
-(NSString*) title;
@end

@interface Parallax1 : ParallaxDemo
{
}
@end

@interface Parallax2 : ParallaxDemo
{
}
@end
