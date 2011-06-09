
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

@class Emitter;

@interface ParticleDemo : CCLayerColor
{
	CCParticleSystem	*emitter_;
	CCSprite			*background;
}

@property (readwrite,retain) CCParticleSystem *emitter;

-(NSString*) title;
-(NSString*) subtitle;

@end

@interface DemoFirework : ParticleDemo
{}
@end

@interface DemoFire : ParticleDemo
{}
@end

@interface DemoSun : ParticleDemo
{}
@end

@interface DemoGalaxy : ParticleDemo
{}
@end

@interface DemoFlower : ParticleDemo
{}
@end

@interface DemoBigFlower : ParticleDemo
{}
@end

@interface DemoRotFlower : ParticleDemo
{}
@end

@interface DemoMeteor : ParticleDemo
{}
@end

@interface DemoSpiral : ParticleDemo
{}
@end

@interface DemoExplosion : ParticleDemo
{}
@end

@interface DemoSmoke : ParticleDemo
{}
@end

@interface DemoSnow : ParticleDemo
{}
@end

@interface DemoRain : ParticleDemo
{}
@end

@interface DemoModernArt : ParticleDemo
{}
@end

@interface DemoRing : ParticleDemo
{}
@end

@interface ParallaxParticle : ParticleDemo
{}
@end

@interface ParticleDesigner1 : ParticleDemo
{}
@end

@interface ParticleDesigner2 : ParticleDemo
{}
@end

@interface ParticleDesigner3 : ParticleDemo
{}
@end

@interface ParticleDesigner4 : ParticleDemo
{}
@end

@interface ParticleDesigner5 : ParticleDemo
{}
@end

@interface ParticleDesigner6 : ParticleDemo
{}
@end

@interface ParticleDesigner7 : ParticleDemo
{}
@end

@interface ParticleDesigner8 : ParticleDemo
{}
@end

@interface ParticleDesigner9 : ParticleDemo
{}
@end

@interface ParticleDesigner10 : ParticleDemo
{}
@end

@interface ParticleDesigner11 : ParticleDemo
{}
@end

@interface ParticleDesigner12 : ParticleDemo
{}
@end

@interface RadiusMode1 : ParticleDemo
{}
@end

@interface RadiusMode2 : ParticleDemo
{}
@end

@interface Issue704 : ParticleDemo
{}
@end

@interface Issue872 : ParticleDemo
{}
@end

@interface Issue870 : ParticleDemo
{
	int index;
}
@end


