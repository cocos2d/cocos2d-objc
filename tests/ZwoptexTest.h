#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	
	UIViewController *viewController_;		// weak ref
	UINavigationController *navigationController_;	// weak ref
}
@property (nonatomic, retain) UIWindow *window;
@property (readonly) UIViewController *viewController;
@property (readonly) UINavigationController *navigationController;
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
