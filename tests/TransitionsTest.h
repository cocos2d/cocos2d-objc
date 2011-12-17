#import "cocos2d.h"

@class CCLabel;

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

@property (readwrite, retain)	NSWindow	*window;
@property (readwrite, retain)	MacGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
#endif // Mac

@interface TextLayer: CCLayer
{
}
@end


@interface TextLayer2: CCLayer
{
}
@end

