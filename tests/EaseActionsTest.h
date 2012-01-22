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

@interface ActionEaseTestInsideLayer : CCLayer {

    CCSprite *grossini;
	CCSprite *tamara;
	CCSprite *kathia;
}

-(void) positionForTwo;

@end

@interface SpriteDemo : CCLayer
{
}

+(id) nodeWithInsideLayer: (CCLayer *) insideLayer;
-(id) initWithInsideLayer: (CCLayer *) insideLayer;

-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface SpriteEase : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseInOut : ActionEaseTestInsideLayer
{}
@end


@interface SpriteEaseExponential : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseExponentialInOut : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseSine : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseSineInOut : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseElastic : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseElasticInOut : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseBounce : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseBounceInOut : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseBack : ActionEaseTestInsideLayer
{}
@end

@interface SpriteEaseBackInOut : ActionEaseTestInsideLayer
{}
@end


@interface SpeedTest : ActionEaseTestInsideLayer
{}
@end

@interface SchedulerTest : ActionEaseTestInsideLayer
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	UISlider	*sliderCtl;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	NSSlider	*sliderCtl;
	NSWindow	*overlayWindow;
#endif
}
@end

