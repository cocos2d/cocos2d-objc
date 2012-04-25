
#import "BaseAppController.h"
#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface JSTest: CCLayer
{
    CCTextureAtlas	*atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
@end


@interface JSSprite : JSTest
{}
@end
