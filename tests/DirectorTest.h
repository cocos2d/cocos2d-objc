#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	UIViewController *viewController_;
	UINavigationController *navigationController_;
}
@property (nonatomic, retain) UIWindow *window;
@property (readonly) UIViewController *viewController;
@property (readonly) UINavigationController *navigationController;
@end


@interface DirectorTest: CCLayer
{
    CCTextureAtlas	*atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
-(void) restartCallback: (id) sender;
-(void) nextCallback: (id) sender;
-(void) backCallback: (id) sender;
@end


@interface DirectorViewDidDisappear : DirectorTest
{}
@end


