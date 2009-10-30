#import "cocos2d.h"

@class CCSprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
	UIWindow	*window;
}
@end

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
	UISlider	*sliderCtl;
}
@end

