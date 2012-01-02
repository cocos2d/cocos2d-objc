#import "cocos2d.h"

@class CCLabel;

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

@interface TextLayer: CCLayer
{}
+(id) nodeWithInsideLayer: (CCLayer *) insideLayer;
-(id) initWithInsideLayer: (CCLayer *) insideLayer;
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface Effect1 : CCLayer
{}
@end

@interface Effect2 : CCLayer
{}
@end

@interface Effect3 : CCLayer
{}
@end

@interface Effect4 : CCLayer
{}
@end

@interface Effect5 : CCLayer
{}
@end

@interface Issue631 : TextLayer
{}
@end

