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

@interface SpriteDemo : CCLayer
{
	CCSprite * grossini;
	CCSprite *tamara;
	CCSprite *kathia;
}
-(void) positionForTwo;
-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface SpriteEase : SpriteDemo
{}
@end

@interface SpriteEaseInOut : SpriteDemo
{}
@end


@interface SpriteEaseExponential : SpriteDemo
{}
@end

@interface SpriteEaseExponentialInOut : SpriteDemo
{}
@end

@interface SpriteEaseSine : SpriteDemo
{}
@end

@interface SpriteEaseSineInOut : SpriteDemo
{}
@end

@interface SpriteEaseElastic : SpriteDemo
{}
@end

@interface SpriteEaseElasticInOut : SpriteDemo
{}
@end

@interface SpriteEaseBounce : SpriteDemo
{}
@end

@interface SpriteEaseBounceInOut : SpriteDemo
{}
@end

@interface SpriteEaseBack : SpriteDemo
{}
@end

@interface SpriteEaseBackInOut : SpriteDemo
{}
@end


@interface SpeedTest : SpriteDemo
{}
@end

@interface SchedulerTest : SpriteDemo
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	UISlider	*sliderCtl;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	NSSlider	*sliderCtl;
	NSWindow	*overlayWindow;
#endif
}
@end

