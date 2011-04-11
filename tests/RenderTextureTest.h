#import "Cocos2d.h"

@class Sprite;

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

@interface RenderTextureTest : CCLayer
{}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface RenderTextureSave : RenderTextureTest
{
	CCRenderTexture* target;
	CCSprite* brush;
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	CGPoint		lastLocation;
#endif
}
@end

@interface RenderTextureIssue937 : RenderTextureTest
{}
@end


