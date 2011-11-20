#import "cocos2d.h"

@class CCSprite;

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

@interface ActionDemo : CCLayer
{
	CCSprite * grossini;
	CCSprite *tamara;
	CCSprite *kathia;
}
-(void) centerSprites:(unsigned int)numberOfSprites;
-(NSString*) title;
-(NSString*) subtitle;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface ActionSequenceTest : ActionDemo
{
    id animated;
    id rotator;
    id stop_rotator;
    id stop_animation;


}
@end

