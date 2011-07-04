#import "cocos2d.h"

@class CCSprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow	*window_;
	UIViewController	*viewController_;
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


