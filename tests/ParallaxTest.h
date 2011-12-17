#import "cocos2d.h"

//CLASS INTERFACE
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window_;
	
	UINavigationController *rootViewController_;	// weak ref
	CCDirector	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *rootViewController;
@property (readonly) CCDirector *director;

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
