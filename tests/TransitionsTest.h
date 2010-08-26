#import "cocos2d.h"

@class CCLabel;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}

@property (nonatomic, readonly) UIWindow *window;

@end

#elif __MAC_OS_X_VERSION_MIN_REQUIRED
@interface cocos2dmacAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	MacGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet MacGLView	*glView;

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

