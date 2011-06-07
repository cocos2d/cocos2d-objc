#import "cocos2d.h"

@class CCLabel;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}

@property (nonatomic, retain) UIWindow *window;

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

