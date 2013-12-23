//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "CocosNodePerformance.h"

@implementation CCNode (PerformanceTest)

- (void)performanceMoveByActions
{
	CGSize size = [[CCDirector sharedDirector] viewSize];
	self.position = ccp(random() % (int)size.width, random() % (int)size.height);

	float moveDuration = 0.5f + (random() % 1000) / 500.0f;
    CGPoint moveDestination = ccp(-100 + random()%200, -100 + random()%200);

	CCActionInterval *move = [CCMoveBy actionWithDuration:moveDuration position:moveDestination];
	CCAction *permanentMove = [CCRepeatForever actionWithAction:[CCSequence actionOne:move two:[move reverse]]];
	[self runAction:permanentMove];
}

- (void)performanceMoveToActions
{
	CGSize size = [[CCDirector sharedDirector] viewSize];
	self.position = ccp(random() % (int)size.width, random() % (int)size.height);
    CGPoint moveDestination = ccp(random() % (int)size.width, random() % (int)size.height);

	float moveDuration = 0.5f + (random() % 1000) / 500.0f;
	CCActionInterval *move = [CCMoveTo actionWithDuration:moveDuration
                                                 position:moveDestination];
	CCActionInterval *moveBack = [CCMoveTo actionWithDuration:moveDuration
                                                     position:self.position];
	CCAction *permanentMove = [CCRepeatForever actionWithAction:
                               [CCSequence actionOne:move
                                                 two:moveBack]];
	[self runAction:permanentMove];
}

- (void)performanceActions
{
	CGSize size = [[CCDirector sharedDirector] viewSize];
	self.position = ccp(random() % (int)size.width, random() % (int)size.height);

	float period = 0.5f + (random() % 1000) / 500.0f;
	id rot = [CCRotateBy actionWithDuration:period angle: 360.0f * CCRANDOM_0_1()];
	id rot_back = [rot reverse];
	CCAction *permanentRotation = [CCRepeatForever actionWithAction:[CCSequence actions: rot, rot_back, nil]];
	[self runAction:permanentRotation];

	float growDuration = 0.5f + (random() % 1000) / 500.0f;
	CCActionInterval *grow = [CCScaleBy actionWithDuration:growDuration scaleX:0.5f scaleY:0.5f];
	CCAction *permanentScaleLoop = [CCRepeatForever actionWithAction:[CCSequence actionOne:grow two:[grow reverse]]];
	[self runAction:permanentScaleLoop];
}

- (void)performanceActions20
{
	CGSize size = [[CCDirector sharedDirector] viewSize];
	if( CCRANDOM_0_1() < 0.2f )
		self.position = ccp(random() % (int)size.width, random() % (int)size.height);
	else
		self.position = ccp( -1000, -1000);

	float period = 0.5f + (random() % 1000) / 500.0f;
	id rot = [CCRotateBy actionWithDuration:period angle: 360.0f * CCRANDOM_0_1()];
	id rot_back = [rot reverse];
	CCAction *permanentRotation = [CCRepeatForever actionWithAction:[CCSequence actions: rot, rot_back, nil]];
	[self runAction:permanentRotation];

	float growDuration = 0.5f + (random() % 1000) / 500.0f;
	CCActionInterval *grow = [CCScaleBy actionWithDuration:growDuration scaleX:0.5f scaleY:0.5f];
	CCAction *permanentScaleLoop = [CCRepeatForever actionWithAction:[CCSequence actionOne:grow two:[grow reverse]]];
	[self runAction:permanentScaleLoop];
}

- (void)performanceRotationScale
{
	CGSize size = [[CCDirector sharedDirector] viewSize];
	self.position = ccp(random() % (int)size.width, random() % (int)size.height);
	self.rotation = CCRANDOM_0_1() * 360;
	self.scale = CCRANDOM_0_1() * 2;
}

- (void)performancePosition
{
	CGSize size = [[CCDirector sharedDirector] viewSize];
	self.position = ccp(random() % (int)size.width, random() % (int)size.height);
}

- (void)performanceout20
{
	CGSize size = [[CCDirector sharedDirector] viewSize];

	if( CCRANDOM_0_1() < 0.2f )
		self.position = ccp(random() % (int)size.width, random() % (int)size.height);
	else
		self.position = ccp( -1000, -1000);
}

- (void)performanceOut100
{

	self.position = ccp( -1000, -1000);
}


- (void)performanceScale
{
	CGSize size = [[CCDirector sharedDirector] viewSize];
	self.position = ccp(random() % (int)size.width, random() % (int)size.height);
	self.scale = CCRANDOM_0_1() * 100 / 50;
}
@end
