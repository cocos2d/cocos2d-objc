#import "cocos2d.h"

@class CCSprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface ActionDemo : CCLayer
{
	CCSprite * grossini;
	CCSprite *tamara;
}
-(void) centerSprites;
-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface ActionManual : ActionDemo
{}
@end

@interface ActionMove : ActionDemo
{}
@end

@interface ActionRotate : ActionDemo
{}
@end

@interface ActionScale : ActionDemo
{}
@end

@interface ActionJump : ActionDemo
{}
@end

@interface ActionBlink : ActionDemo
{}
@end

@interface ActionAnimate : ActionDemo
{}
@end

@interface ActionSequence : ActionDemo
{}
@end

@interface ActionSequence2 : ActionDemo
{}
@end

@interface ActionSpawn : ActionDemo
{}
@end

@interface ActionReverse : ActionDemo
{}
@end

@interface ActionRepeat : ActionDemo
{}
@end

@interface ActionDelayTime : ActionDemo
{}
@end

@interface ActionReverseSequence : ActionDemo
{}
@end

@interface ActionReverseSequence2 : ActionDemo
{}
@end

@interface ActionCallFunc : ActionDemo
{}
@end

@interface ActionFade : ActionDemo
{}
@end

@interface ActionTint : ActionDemo
{}
@end

@interface ActionOrbit : ActionDemo
{}
@end

@interface ActionBezier : ActionDemo
{}
@end

@interface ActionRepeatForever : ActionDemo
{}
@end

