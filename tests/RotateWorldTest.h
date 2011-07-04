#import "cocos2d.h"

@class CCLabel;

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
    UIWindow *window_;
	UIViewController *viewController_;
}
@end

@interface SpriteLayer: CCLayer
{
}
@end

@interface TextLayer: CCLayer
{
}
@end

@interface MainLayer : CCLayer
{
}
@end
