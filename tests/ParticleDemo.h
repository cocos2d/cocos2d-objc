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
}

-(NSString*) title;
@end

@interface DemoFirework : ParticleDemo
{
}
@end

@interface DemoFire : ParticleDemo
{
}
@end

@interface DemoSun : ParticleDemo
{
}
@end

@interface DemoGalaxy : ParticleDemo
{
}
@end

