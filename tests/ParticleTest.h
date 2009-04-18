
#import "cocos2d.h"

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@class Emitter;

@interface ParticleDemo : Layer
{
}

-(NSString*) title;
@end

@interface BigParticleDemo : ParticleDemo
{
}
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

@interface DemoBigParticle : ParticleDemo
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
