#import "cocos2d.h"

//CLASS INTERFACE
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@interface cocos2dmacAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	MacGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet MacGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
#endif // Mac


@interface JpsardaDemo: CCLayer
{
    CCTextureAtlas	*atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
@end



@interface CCSpriteScale9Demo : JpsardaDemo
{
    CCSpriteScale9	*sprite;
    CGRect screenRect;
    CGSize sizeGoal,sizeCurrent;
}
-(NSString*) title;
-(NSString*) subtitle;
@end



@interface CCSpriteHoleDemo : JpsardaDemo
{
    CCSpriteHole	*sprite;
    CGRect screenRect;
    CGPoint holeCurrent,holeGoal;
}
-(NSString*) title;
-(NSString*) subtitle;
@end



