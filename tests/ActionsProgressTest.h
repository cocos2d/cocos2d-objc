#import "cocos2d.h"
#import "BaseAppController.h"

@class CCSprite;

//CLASS INTERFACE
@interface AppController : BaseAppController
{
}
@end

@interface SpriteDemo : CCLayer
{
}
-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface SpriteProgressToRadial : SpriteDemo
{}
@end

@interface SpriteProgressToRadialMidpointChanged : SpriteDemo
{}
@end

@interface SpriteProgressToHorizontal : SpriteDemo
{}
@end

@interface SpriteProgressToVertical : SpriteDemo
{}
@end

@interface SpriteProgressBarVarious : SpriteDemo
{}
@end

@interface SpriteProgressBarTintAndFade : SpriteDemo
{}
@end

@interface SpriteProgressWithSpriteFrame : SpriteDemo
{}
@end
