#import "cocos2d.h"

@class CCLabel;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
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
{}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface Effect1 : TextLayer
{}
@end

@interface Effect2 : TextLayer
{}
@end

@interface Effect3 : TextLayer
{}
@end

@interface Effect4 : TextLayer
{}
@end

@interface Effect5 : TextLayer
{}
@end

@interface Issue631 : TextLayer
{}
@end

