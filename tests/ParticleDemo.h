#import <UIKit/UIKit.h>
#import "Layer.h"

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@class Emitter;
@interface ParticleDemo : Layer
{
	Emitter *emitter;
}

-(NSString*) title;
@end

@interface ParticleFirework : ParticleDemo
{
}
@end

@interface ParticleFire : ParticleDemo
{
}
@end

@interface ParticleSun : ParticleDemo
{
}
@end

