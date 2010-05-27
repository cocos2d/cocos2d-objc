
#import "cocos2d.h"

@class CCSprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@class Emitter;

@interface ParticleDemo : CCColorLayer
{
	CCParticleSystem	*emitter;
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


