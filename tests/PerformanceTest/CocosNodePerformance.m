//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "CocosNodePerformance.h"

enum {
	kScaleFactor = 5
};

//static float actorShape[] = {
//	 kScaleFactor,  kScaleFactor,
//	-kScaleFactor,  kScaleFactor,
//	-kScaleFactor, -kScaleFactor,
//	 kScaleFactor, -kScaleFactor
//};

@implementation CocosNode (PerformanceTest)

- (void)initPerformance
{
	CGSize size = [[Director sharedDirector] winSize];
	self.position = cpv(random() % (int)size.width, random() % (int)size.height);
	
	
	float period = 0.5f + (random() % 1000) / 500.0f;
	float degrees = 360.0f * ((random() % 2) * 2 - 1);
	Action *permanentRotation = [RepeatForever actionWithAction:[RotateBy actionWithDuration:period angle:degrees]];
	[self do:permanentRotation];
	
	float growDuration = 0.5f + (random() % 1000) / 500.0f;
	IntervalAction *grow = [ScaleBy actionWithDuration:growDuration scaleX:0.5f scaleY:0.5f];
	Action *permanentScaleLoop = [RepeatForever actionWithAction:[Sequence actionOne:grow two:[grow reverse]]];
	[self do:permanentScaleLoop];
	
//	float fadeDuration = 0.5f + (random() % 1000) / 500.0f;
//	IntervalAction *fadeOut = [FadeTo actionWithDuration:fadeDuration opacity:255];
//	IntervalAction *fadeIn = [FadeTo actionWithDuration:fadeDuration opacity:50];
//	Action *permanentFadeOutInLoop = [RepeatForever actionWithAction:[Sequence actionOne:fadeOut two:fadeIn]];
//	[self do:permanentFadeOutInLoop];
//	[self setOpacity:0];
	
}

- (void)die
{
	CallFuncN *selfRemovalAction = [CallFuncN actionWithTarget:self.parent selector:@selector(removeAndStop:)];
	[self do: selfRemovalAction];
}
@end
