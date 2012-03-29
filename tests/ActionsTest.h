#import "cocos2d.h"
#import "BaseAppController.h"

@class CCSprite;

@interface AppController : BaseAppController
@end

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

@interface ActionSkew : ActionDemo
{}
@end

@interface ActionSkewRotateScale : ActionDemo
{}
@end

@interface ActionJump : ActionDemo
{}
@end

@interface ActionBlink : ActionDemo
{}
@end

@interface ActionAnimate : ActionDemo
{
	id observer_;
}
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

@interface ActionCallFuncND : ActionDemo
{}
@end

@interface ActionCallBlock : ActionDemo
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

@interface ActionCatmullRom : ActionDemo
{
	CCPointArray *array1_;
	CCPointArray *array2_;
}
@end

@interface ActionCardinalSpline : ActionDemo
{
	CCPointArray *array_;
}
@end

@interface ActionRepeatForever : ActionDemo
{}
@end

@interface ActionRotateToRepeat : ActionDemo
{}
@end

@interface ActionRotateJerk : ActionDemo
{}
@end
@interface ActionFollow : ActionDemo
{}
@end

@interface ActionProperty : ActionDemo
{}
@end

@interface ActionTargeted : ActionDemo
{}
@end

@interface PauseResumeActions : ActionDemo
{
    NSSet* pausedTargets_;
}
@property(readwrite,retain) NSSet* pausedTargets;
@end

@interface Issue1305 : ActionDemo
{
	CCSprite *spriteTmp_;
}
@end

@interface Issue1305_2 : ActionDemo
{}
@end

@interface Issue1288 : ActionDemo
{}
@end

@interface Issue1288_2 : ActionDemo
{}
@end

@interface Issue1327 : ActionDemo
{}
@end
