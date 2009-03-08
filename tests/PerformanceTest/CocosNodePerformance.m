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

- (void)performanceActions
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
}

- (void)performanceRotationScale
{
	CGSize size = [[Director sharedDirector] winSize];
	self.position = cpv(random() % (int)size.width, random() % (int)size.height);
	self.rotation = CCRANDOM_0_1() * 360;
	self.scale = CCRANDOM_0_1() * 100 / 50;
}

- (void)performancePosition
{
	CGSize size = [[Director sharedDirector] winSize];
	self.position = cpv(random() % (int)size.width, random() % (int)size.height);	
}

- (void)performanceScale
{
	CGSize size = [[Director sharedDirector] winSize];
	self.position = cpv(random() % (int)size.width, random() % (int)size.height);	
	self.scale = CCRANDOM_0_1() * 100 / 50;
}


- (void)die
{
	CallFuncN *selfRemovalAction = [CallFuncN actionWithTarget:self.parent selector:@selector(removeAndStop:)];
	[self do: selfRemovalAction];
}
@end
