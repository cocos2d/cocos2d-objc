//
// Particle Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "ParticleTest.h"

#ifdef __CC_PLATFORM_IOS
#define PARTICLE_FIRE_NAME @"fire.pvr"
#elif defined(__CC_PLATFORM_MAC)
#define PARTICLE_FIRE_NAME @"fire.png"
#endif
enum {
	kTagParticleCount = 1,
};

static int sceneIdx=-1;
static NSString *transitions[] = {

	@"ParticleReorder",
	@"ParticleBatchHybrid",
	@"ParticleBatchMultipleEmitters",

	@"DemoFlower",
	@"DemoGalaxy",
	@"DemoFirework",
	@"DemoSpiral",
	@"DemoSun",
	@"DemoMeteor",
	@"DemoFire",
	@"DemoSmoke",
	@"DemoExplosion",
	@"DemoSnow",
	@"DemoRain",
	@"DemoBigFlower",
	@"DemoRotFlower",
	@"DemoModernArt",
	@"DemoRing",

	@"ParallaxParticle",

	@"ParticleDesigner1",
	@"ParticleDesigner2",
	@"ParticleDesigner3",
	@"ParticleDesigner4",
	@"ParticleDesigner5",
	@"ParticleDesigner6",
	@"ParticleDesigner7",
	@"ParticleDesigner8",
	@"ParticleDesigner9",
	@"ParticleDesigner10",
	@"ParticleDesigner11",
	@"ParticleDesigner12",

	@"RadiusMode1",
	@"RadiusMode2",
	@"Issue704",
	@"Issue872",
	@"Issue870",
	@"Issue1201",
	
	// v1.1 tests
	@"MultipleParticleSystems",
	@"MultipleParticleSystemsBatched",	
	@"AddAndDeleteParticleSystems",
	@"ReorderParticleSystems",

	@"PremultipliedAlphaTest",
	@"PremultipliedAlphaTest2",
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{

	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;

	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark - ParticleDemo

@implementation ParticleDemo

@synthesize emitter=emitter_;
-(id) init
{
	if( (self=[super initWithColor:ccc4(127,127,127,255)] )) {

#ifdef __CC_PLATFORM_IOS
		self.isTouchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.isMouseEnabled = YES;
#endif


		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:100];
		[label setPosition: ccp(s.width/2, s.height-50)];

		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:100];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenuItemToggle *item4 = [CCMenuItemToggle itemWithTarget:self selector:@selector(toggleCallback:) items:
								   [CCMenuItemFont itemWithString: @"Free Movement"],
								   [CCMenuItemFont itemWithString: @"Relative Movement"],
								   [CCMenuItemFont itemWithString: @"Grouped Movement"],

								 nil];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, item4, nil];

		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		item4.position = ccp( 0, 100);
		item4.anchorPoint = ccp(0,0);

		[self addChild: menu z:100];

		CCLabelAtlas *labelAtlas = [CCLabelAtlas labelWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
		[self addChild:labelAtlas z:100 tag:kTagParticleCount];
		labelAtlas.position = ccp(s.width-66,50);

		// moving background
		background = [CCSprite spriteWithFile:@"background3.png"];
		[self addChild:background z:5];
		[background setPosition:ccp(s.width/2, s.height-180)];

		id move = [CCMoveBy actionWithDuration:4 position:ccp(300,0)];
		id move_back = [move reverse];
		id seq = [CCSequence actions: move, move_back, nil];
		[background runAction:[CCRepeatForever actionWithAction:seq]];


		[self scheduleUpdate];
	}

	return self;
}

- (void) dealloc
{
	[emitter_ release];
	[super dealloc];
}


#ifdef __CC_PLATFORM_IOS
-(void) registerWithTouchDispatcher
{
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	[self ccTouchEnded:touch withEvent:event];

	// claim the touch
	return YES;
}
- (void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}

- (void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];

	CGPoint pos = CGPointZero;

	if( background )
		pos = [background convertToWorldSpace:CGPointZero];
	emitter_.position = ccpSub(convertedLocation, pos);
}
#elif defined(__CC_PLATFORM_MAC)


-(BOOL) ccMouseDragged:(NSEvent *)event
{
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertEventToGL:event];

	CGPoint pos = CGPointZero;

	if( background )
		pos = [background convertToWorldSpace:CGPointZero];
	emitter_.position = ccpSub(convertedLocation, pos);
	// swallow the event. Don't propagate it
	return YES;
}
#endif // __CC_PLATFORM_MAC

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagParticleCount];

	NSString *str = [NSString stringWithFormat:@"%4ld", (unsigned long)emitter_.particleCount];
	[atlas setString:str];
}

-(NSString*) title
{
	return @"No title";
}
-(NSString*) subtitle
{
	return @"Tap the screen";
}

-(void) toggleCallback: (id) sender
{
	if( emitter_.positionType == kCCPositionTypeGrouped )
		emitter_.positionType = kCCPositionTypeFree;
	else if( emitter_.positionType == kCCPositionTypeFree )
		emitter_.positionType = kCCPositionTypeRelative;
	else if( emitter_.positionType == kCCPositionTypeRelative )
		emitter_.positionType = kCCPositionTypeGrouped;
}

-(void) restartCallback: (id) sender
{
//	Scene *s = [Scene node];
//	[s addChild: [restartAction() node]];
//	[[Director sharedDirector] replaceScene: s];

	[emitter_ resetSystem];
//	[emitter_ stopSystem];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) setEmitterPosition
{
	if( CGPointEqualToPoint( emitter_.sourcePosition, CGPointZero ) )
		emitter_.position = ccp(200, 70);
}

@end

#pragma mark - ParticleBatchHybrid

@implementation ParticleBatchHybrid
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/LavaFlow.plist"];
	CCParticleBatchNode *batch = [CCParticleBatchNode batchNodeWithTexture:[self.emitter texture]];

	[batch addChild:self.emitter];

	[self addChild:batch z:10];

	[self schedule:@selector(switchRender:) interval:2];

	CCNode *node = [CCNode node];
	[self addChild:node];

	parent1 = batch;
	parent2 = node;
}

-(void) switchRender:(ccTime)dt
{
	BOOL usingBatch = ( [self.emitter batchNode] != nil );
	[self.emitter removeFromParentAndCleanup:NO];

	CCNode *newParent = (usingBatch ? parent2  : parent1 );
	[newParent addChild:self.emitter];

	NSLog(@"Particle: Using new parent: %@", newParent);
}

-(NSString *) title
{
	return @"Paticle Batch";
}

-(NSString *) subtitle
{
	return @"Hybrid: batched and non batched every 2 seconds";
}

@end

#pragma mark - ParticleBatchMultipleEmitters

@implementation ParticleBatchMultipleEmitters
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	CCParticleSystemQuad *emitter1 = [CCParticleSystemQuad particleWithFile:@"Particles/LavaFlow.plist"];
	emitter1.startColor = (ccColor4F) {1,0,0,1};
	CCParticleSystemQuad *emitter2 = [CCParticleSystemQuad particleWithFile:@"Particles/LavaFlow.plist"];
	emitter2.startColor = (ccColor4F) {0,1,0,1};
	CCParticleSystemQuad *emitter3 = [CCParticleSystemQuad particleWithFile:@"Particles/LavaFlow.plist"];
	emitter3.startColor = (ccColor4F) {0,0,1,1};

	CGSize s = [[CCDirector sharedDirector] winSize];

	emitter1.position = ccp( s.width/1.25f, s.height/1.25f);
	emitter2.position = ccp( s.width/2, s.height/2);
	emitter3.position = ccp( s.width/4, s.height/4);

	CCParticleBatchNode *batch = [CCParticleBatchNode batchNodeWithTexture:[emitter1 texture]];

	[batch addChild:emitter1 z:0];
	[batch addChild:emitter2 z:0];
	[batch addChild:emitter3 z:0];

	[self addChild:batch z:10];
}

-(NSString *) title
{
	return @"Paticle Batch";
}

-(NSString *) subtitle
{
	return @"Multiple emitters. One Batch";
}

@end

#pragma mark - ParticleReorder

@implementation ParticleReorder
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	CCParticleSystem *ignore = [CCParticleSystemQuad particleWithFile:@"Particles/SmallSun.plist"];
	CCNode *parent1 = [CCNode node];
	CCNode *parent2 = [CCParticleBatchNode batchNodeWithTexture:[ignore texture]];

	for( NSUInteger i=0; i<2;i++) {
		CCNode *parent = ( i==0 ? parent1 : parent2 );

		CCParticleSystemQuad *emitter1 = [CCParticleSystemQuad particleWithFile:@"Particles/SmallSun.plist"];
		emitter1.startColor = (ccColor4F) {1,0,0,1};
		emitter1.blendAdditive = NO;
		CCParticleSystemQuad *emitter2 = [CCParticleSystemQuad particleWithFile:@"Particles/SmallSun.plist"];
		emitter2.startColor = (ccColor4F) {0,1,0,1};
		emitter2.blendAdditive = NO;
		CCParticleSystemQuad *emitter3 = [CCParticleSystemQuad particleWithFile:@"Particles/SmallSun.plist"];
		emitter3.startColor = (ccColor4F) {0,0,1,1};
		emitter3.blendAdditive = NO;

		CGSize s = [[CCDirector sharedDirector] winSize];

		int neg = (i==0 ? 1 : -1 );

		emitter1.position = ccp( s.width/2-30,	s.height/2+60*neg);
		emitter2.position = ccp( s.width/2,		s.height/2+60*neg);
		emitter3.position = ccp( s.width/2+30,	s.height/2+60*neg);

		[parent addChild:emitter1 z:0 tag:1];
		[parent addChild:emitter2 z:0 tag:2];
		[parent addChild:emitter3 z:0 tag:3];

		[self addChild:parent z:10 tag:1000+i];
	}

	[self schedule:@selector(reorderParticles:) interval:1];
}

-(NSString *) title
{
	return @"Reordering particles";
}

-(NSString *) subtitle
{
	return @"Reordering particles with and without batches batches";
}

-(void) reorderParticles:(ccTime)dt
{
	for( int i=0; i<2;i++) {
		CCNode *parent = [self getChildByTag:1000+i];

		CCNode *child1 = [parent getChildByTag:1];
		CCNode *child2 = [parent getChildByTag:2];
		CCNode *child3 = [parent getChildByTag:3];

		if( order % 3 == 0 ) {
			[parent reorderChild:child1 z:1];
			[parent reorderChild:child2 z:2];
			[parent reorderChild:child3 z:3];

		} else if (order % 3 == 1 ) {
			[parent reorderChild:child1 z:3];
			[parent reorderChild:child2 z:1];
			[parent reorderChild:child3 z:2];

		} else if (order % 3 == 2 ) {
			[parent reorderChild:child1 z:2];
			[parent reorderChild:child2 z:3];
			[parent reorderChild:child3 z:1];
		}
	}

	order++;
}
@end

#pragma mark - DemoFirework

@implementation DemoFirework
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleFireworks node];
	[background addChild:emitter_ z:10];

	// testing "alpha" blending in premultiplied images
//	emitter_.blendFunc = (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars.png"];
	emitter_.blendAdditive = YES;

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleFireworks";
}
@end

#pragma mark - DemoFire

@implementation DemoFire
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleFire node];
	[background addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
	CGPoint p = emitter_.position;
	emitter_.position = ccp(p.x, 100);

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleFire";
}
@end

#pragma mark - DemoSun

@implementation DemoSun
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSun node];
	[background addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleSun";
}
@end

#pragma mark - DemoGalaxy

@implementation DemoGalaxy
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleGalaxy node];
	[background addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleGalaxy";
}
@end

#pragma mark - DemoFlower

@implementation DemoFlower
-(void) onEnter
{
	[super onEnter];

	self.emitter = [CCParticleFlower node];
	[background addChild:emitter_ z:10];
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleFlower";
}
@end

#pragma mark - DemoBigFlower

@implementation DemoBigFlower
-(void) onEnter
{
	[super onEnter];
	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:50];

	[background addChild:emitter_ z:10];
	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];

	// duration
	emitter_.duration = kCCParticleDurationInfinity;

	// Gravity Mode: gravity
	emitter_.gravity = CGPointZero;

	// Set "Gravity" mode (default one)
	emitter_.emitterMode = kCCParticleModeGravity;

	// Gravity Mode: speed of particles
	emitter_.speed = 160;
	emitter_.speedVar = 20;

	// Gravity Mode: radial
	emitter_.radialAccel = -120;
	emitter_.radialAccelVar = 0;

	// Gravity Mode: tagential
	emitter_.tangentialAccel = 30;
	emitter_.tangentialAccelVar = 0;

	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 360;

	// emitter position
	emitter_.position = ccp(160,240);
	emitter_.posVar = CGPointZero;

	// life of particles
	emitter_.life = 4;
	emitter_.lifeVar = 1;

	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 0;

	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;

	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;

	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;

	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColorVar = endColorVar;

	// size, in pixels
	emitter_.startSize = 80.0f;
	emitter_.startSizeVar = 40.0f;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;

	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;

	// additive
	emitter_.blendAdditive = YES;

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"Big Particles";
}
@end

#pragma mark - DemoRotFlower

@implementation DemoRotFlower
-(void) onEnter
{
	[super onEnter];
	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:300];
	[background addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars2-grayscale.png"];

	// duration
	emitter_.duration = kCCParticleDurationInfinity;

	// Set "Gravity" mode (default one)
	emitter_.emitterMode = kCCParticleModeGravity;

	// Gravity mode: gravity
	emitter_.gravity = CGPointZero;

	// Gravity mode: speed of particles
	emitter_.speed = 160;
	emitter_.speedVar = 20;

	// Gravity mode: radial
	emitter_.radialAccel = -120;
	emitter_.radialAccelVar = 0;

	// Gravity mode: tagential
	emitter_.tangentialAccel = 30;
	emitter_.tangentialAccelVar = 0;

	// emitter position
	emitter_.position = ccp(160,240);
	emitter_.posVar = CGPointZero;

	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 360;

	// life of particles
	emitter_.life = 3;
	emitter_.lifeVar = 1;

	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 2000;

	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;

	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;

	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;

	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColorVar = endColorVar;

	// size, in pixels
	emitter_.startSize = 30.0f;
	emitter_.startSizeVar = 00.0f;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;

	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;

	// additive
	emitter_.blendAdditive = NO;

	[self setEmitterPosition];

}
-(NSString *) title
{
	return @"Spinning Particles";
}
@end

#pragma mark - DemoMeteor

@implementation DemoMeteor
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleMeteor node];
	[background addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleMeteor";
}
@end

#pragma mark -

@implementation DemoSpiral
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSpiral node];
	[background addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleSpiral";
}
@end

#pragma mark -

@implementation DemoExplosion
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleExplosion node];
	[background addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];

	emitter_.autoRemoveOnFinish = YES;

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleExplosion";
}
@end

#pragma mark -

@implementation DemoSmoke
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSmoke node];
	[background addChild:emitter_ z:10];

	CGPoint p = emitter_.position;
	emitter_.position = ccp( p.x, 100);

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleSmoke";
}
@end

#pragma mark -

@implementation DemoSnow
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSnow node];
	[background addChild:emitter_ z:10];

	CGPoint p = emitter_.position;
	emitter_.position = ccp( p.x, p.y-110);
	emitter_.life = 3;
	emitter_.lifeVar = 1;

	// gravity
	emitter_.gravity = ccp(0,-10);

	// speed of particles
	emitter_.speed = 130;
	emitter_.speedVar = 30;


	ccColor4F startColor = emitter_.startColor;
	startColor.r = 0.9f;
	startColor.g = 0.9f;
	startColor.b = 0.9f;
	emitter_.startColor = startColor;

	ccColor4F startColorVar = emitter_.startColorVar;
	startColorVar.b = 0.1f;
	emitter_.startColorVar = startColorVar;

	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"snow.png"];

	[self setEmitterPosition];

}
-(NSString *) title
{
	return @"ParticleSnow";
}
@end

#pragma mark -

@implementation DemoRain
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleRain node];
	[background addChild:emitter_ z:10];

	CGPoint p = emitter_.position;
	emitter_.position = ccp( p.x, p.y-100);
	emitter_.life = 4;

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];

	[self setEmitterPosition];

}
-(NSString *) title
{
	return @"ParticleRain";
}
@end

#pragma mark -

@implementation DemoModernArt
-(void) onEnter
{
	[super onEnter];
	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:1000];
	[background addChild:emitter_ z:10];

	CGSize s = [[CCDirector sharedDirector] winSize];

	// duration
	emitter_.duration = kCCParticleDurationInfinity;

	// Gravity mode
	emitter_.emitterMode = kCCParticleModeGravity;

	// Gravity mode: gravity
	emitter_.gravity = ccp(0,0);

	// Gravity mode: radial
	emitter_.radialAccel = 70;
	emitter_.radialAccelVar = 10;

	// Gravity mode: tagential
	emitter_.tangentialAccel = 80;
	emitter_.tangentialAccelVar = 0;

	// Gravity mode: speed of particles
	emitter_.speed = 50;
	emitter_.speedVar = 10;

	// angle
	emitter_.angle = 0;
	emitter_.angleVar = 360;

	// emitter position
	emitter_.position = ccp( s.width/2, s.height/2);
	emitter_.posVar = CGPointZero;

	// life of particles
	emitter_.life = 2.0f;
	emitter_.lifeVar = 0.3f;

	// emits per frame
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;

	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;

	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;

	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;

	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColorVar = endColorVar;

	// size, in pixels
	emitter_.startSize = 1.0f;
	emitter_.startSizeVar = 1.0f;
	emitter_.endSize = 32.0f;
	emitter_.endSizeVar = 8.0f;

	// texture
//	emitter_.texture = [[TextureCache sharedTextureCache] addImage:@"fire-grayscale.png"];

	// additive
	emitter_.blendAdditive = NO;

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"Varying size";
}
@end

#pragma mark -

@implementation DemoRing
-(void) onEnter
{
	[super onEnter];
	emitter_ = [[CCParticleFlower alloc] initWithTotalParticles:500];
	[background addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	emitter_.lifeVar = 0;
	emitter_.life = 10;
	emitter_.speed = 100;
	emitter_.speedVar = 0;
	emitter_.emissionRate = 10000;

	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"Ring Demo";
}
@end

#pragma mark -

@implementation ParallaxParticle
-(void) onEnter
{
	[super onEnter];

	[[background parent] removeChild:background cleanup:YES];
	background = nil;

	CCParallaxNode *p = [CCParallaxNode node];
	[self addChild:p z:5];

	CCSprite *p1 = [CCSprite spriteWithFile:@"background3.png"];
	background = p1;

	CCSprite *p2 = [CCSprite spriteWithFile:@"background3.png"];

	[p addChild:p1 z:1 parallaxRatio:ccp(0.5f,1) positionOffset:ccp(0,250)];
	[p addChild:p2 z:2 parallaxRatio:ccp(1.5f,1) positionOffset:ccp(0,50)];


	emitter_ = [[CCParticleFlower alloc] initWithTotalParticles:500];
	[p1 addChild:emitter_ z:10];
	[emitter_ setPosition:ccp(250,200)];

	id par = [[CCParticleSun alloc] initWithTotalParticles:250];
	[p2 addChild:par z:10];
	[par release];


	id move = [CCMoveBy actionWithDuration:4 position:ccp(300,0)];
	id move_back = [move reverse];
	id seq = [CCSequence actions: move, move_back, nil];
	[p runAction:[CCRepeatForever actionWithAction:seq]];
}

-(NSString *) title
{
	return @"Parallax + Particles";
}
@end

#pragma mark -

@implementation ParticleDesigner1
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;


	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/SpookyPeas.plist"];
	[self addChild:emitter_ z:10];

	// custom spinning
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 360;
	emitter_.endSpin = 720;
	emitter_.endSpinVar = 360;
}

-(NSString *) title
{
	return @"PD: Spooky Peas";
}
@end

#pragma mark -

@implementation ParticleDesigner2
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/SpinningPeas.plist"];

	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"PD: Spinning Peas";
}
@end


#pragma mark -

@implementation ParticleDesigner3
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/LavaFlow.plist"];
	[self addChild:emitter_ z:10];

}

-(NSString *) title
{
	return @"PD: Lava Flow";
}
@end

#pragma mark -

@implementation ParticleDesigner4
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/ExplodingRing.plist"];
	[self addChild:emitter_ z:10];

	[self removeChild:background cleanup:YES];
	background = nil;
}

-(NSString *) title
{
	return @"PD: Exploding Ring";
}
@end

#pragma mark -

@implementation ParticleDesigner5
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Comet.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"PD: Comet";
}
@end

#pragma mark -

@implementation ParticleDesigner6
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/BurstPipe.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"PD: Burst Pipe";
}
@end

#pragma mark -

@implementation ParticleDesigner7
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/BoilingFoam.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"PD: Boiling Foam";
}
@end

#pragma mark -

@implementation ParticleDesigner8
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Flower.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"PD: Flower";
}

-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}

@end

#pragma mark -

@implementation ParticleDesigner9
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Spiral.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"PD: Blur Spiral";
}

-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}

@end

#pragma mark -

@implementation ParticleDesigner10
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Galaxy.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"PD: Galaxy";
}
-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}
@end

#pragma mark -

@implementation ParticleDesigner11
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/debian.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"PD: Debian";
}
-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}
@end

#pragma mark -

@implementation ParticleDesigner12
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Phoenix.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"PD: Phoenix";
}
-(NSString*) subtitle
{
	return @"Testing radial and duration";
}
@end

#pragma mark -

@implementation RadiusMode1
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:200];
	[self addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];

	// duration
	emitter_.duration = kCCParticleDurationInfinity;

	// radius mode
	emitter_.emitterMode = kCCParticleModeRadius;

	// radius mode: start and end radius in pixels
	emitter_.startRadius = 0;
	emitter_.startRadiusVar = 0;
	emitter_.endRadius = 160;
	emitter_.endRadiusVar = 0;

	// radius mode: degrees per second
	emitter_.rotatePerSecond = 180;
	emitter_.rotatePerSecondVar = 0;


	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 0;

	// emitter position
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter_.position = ccp( size.width/2, size.height/2);
	emitter_.posVar = CGPointZero;

	// life of particles
	emitter_.life = 5;
	emitter_.lifeVar = 0;

	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 0;

	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;

	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;

	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;

	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColorVar = endColorVar;

	// size, in pixels
	emitter_.startSize = 32;
	emitter_.startSizeVar = 0;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;

	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;

	// additive
	emitter_.blendAdditive = NO;
}


-(NSString *) title
{
	return @"Radius Mode: Spiral";
}
@end

#pragma mark -

@implementation RadiusMode2
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:200];
	[self addChild:emitter_ z:10];

	emitter_.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];

	// duration
	emitter_.duration = kCCParticleDurationInfinity;

	// radius mode
	emitter_.emitterMode = kCCParticleModeRadius;

	// radius mode: 100 pixels from center
	emitter_.startRadius = 100;
	emitter_.startRadiusVar = 0;
	emitter_.endRadius = kCCParticleStartRadiusEqualToEndRadius;
	emitter_.endRadiusVar = 0;	// not used when start == end

	// radius mode: degrees per second
	// 45 * 4 seconds of life = 180 degrees
	emitter_.rotatePerSecond = 45;
	emitter_.rotatePerSecondVar = 0;


	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 0;

	// emitter position
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter_.position = ccp( size.width/2, size.height/2);
	emitter_.posVar = CGPointZero;

	// life of particles
	emitter_.life = 4;
	emitter_.lifeVar = 0;

	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 0;

	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;

	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;

	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;

	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColorVar = endColorVar;

	// size, in pixels
	emitter_.startSize = 32;
	emitter_.startSizeVar = 0;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;

	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;

	// additive
	emitter_.blendAdditive = NO;

}

-(NSString *) title
{
	return @"Radius Mode: Semi Circle";
}
@end

#pragma mark -

@implementation Issue704
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	emitter_ = [[CCParticleSystemQuad alloc] initWithTotalParticles:100];
	[self addChild:emitter_ z:10];
	emitter_.duration = kCCParticleDurationInfinity;

	// radius mode
	emitter_.emitterMode = kCCParticleModeRadius;

	// radius mode: 50 pixels from center
	emitter_.startRadius = 50;
	emitter_.startRadiusVar = 0;
	emitter_.endRadius = kCCParticleStartRadiusEqualToEndRadius;
	emitter_.endRadiusVar = 0;	// not used when start == end

	// radius mode: degrees per second
	// 45 * 4 seconds of life = 180 degrees
	emitter_.rotatePerSecond = 0;
	emitter_.rotatePerSecondVar = 0;


	// angle
	emitter_.angle = 90;
	emitter_.angleVar = 0;

	// emitter position
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter_.position = ccp( size.width/2, size.height/2);
	emitter_.posVar = CGPointZero;

	// life of particles
	emitter_.life = 5;
	emitter_.lifeVar = 0;

	// spin of particles
	emitter_.startSpin = 0;
	emitter_.startSpinVar = 0;
	emitter_.endSpin = 0;
	emitter_.endSpinVar = 0;

	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColor = startColor;

	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter_.startColorVar = startColorVar;

	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColor = endColor;

	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter_.endColorVar = endColorVar;

	// size, in pixels
	emitter_.startSize = 16;
	emitter_.startSizeVar = 0;
	emitter_.endSize = kCCParticleStartSizeEqualToEndSize;

	// emits per second
	emitter_.emissionRate = emitter_.totalParticles/emitter_.life;

	// additive
	emitter_.blendAdditive = NO;

	id rot = [CCRotateBy actionWithDuration:16 angle:360];
	[emitter_ runAction: [CCRepeatForever actionWithAction:rot] ];

}

-(NSString *) title
{
	return @"Issue 704. Free + Rot";
}

-(NSString*) subtitle
{
	return @"Emitted particles should not rotate";
}
@end

#pragma mark -

@implementation Issue872
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	emitter_ = [[CCParticleSystemQuad alloc] initWithFile:@"Particles/Upsidedown.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"Issue 872. UpsideDown";
}

-(NSString*) subtitle
{
	return @"Particles should NOT be Upside Down. M should appear, not W.";
}
@end

#pragma mark -

@implementation Issue870
-(void) onEnter
{
	[super onEnter];

	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	CCParticleSystemQuad *system = [[CCParticleSystemQuad alloc] initWithFile:@"Particles/SpinningPeas.plist"];

	[system setTexture: [[CCTextureCache sharedTextureCache] addImage:@"particles.png"] withRect:CGRectMake(0,0,32,32)];
	[self addChild: system z:10];

	emitter_ = system;

	index = 0;

	[self schedule:@selector(updateQuads:) interval:2];
}

-(void) updateQuads:(ccTime)dt
{
	index = (index + 1) % 4;
	CGRect rect = CGRectMake(index*32, 0,32,32);

	CCParticleSystemQuad *system = (CCParticleSystemQuad*) emitter_;
	[system setTexture:[emitter_ texture] withRect:rect];
}

-(NSString *) title
{
	return @"Issue 870. SubRect";
}

-(NSString*) subtitle
{
	return @"Every 2 seconds the particle should change";
}
@end

#pragma mark - Issue #1201

@interface RainbowEffect : CCParticleSystemQuad
@end

@implementation RainbowEffect
-(id) init
{
	return [self initWithTotalParticles:150];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {
        
		// additive
		self.blendAdditive = NO;
        
		// duration
		duration = kCCParticleDurationInfinity;
		
		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
		
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
		
		// Gravity mode: radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// Gravity mode: speed of particles
		self.speed = 120;
		self.speedVar = 0;
        
		
		// angle
		angle = 180;
		angleVar = 0;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, winSize.height/2);
		posVar = CGPointZero;
		
		// life of particles
		life = 0.5f;
		lifeVar = 0;
		
		// size, in pixels
		startSize = 25.0f;
		startSizeVar = 0;
		endSize = kCCParticleStartSizeEqualToEndSize;
        
		// emits per seconds
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor = ccc4FFromccc4B(ccc4(50, 50, 50, 50));
        endColor = ccc4FFromccc4B(ccc4(0, 0, 0, 0));
        
        startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"particles.png"];
	}
    
	return self;
}

-(void) update: (ccTime) dt
{
    emitCounter = 0;
    [super update: dt];
}
@end


@implementation Issue1201
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	RainbowEffect *particle = [[RainbowEffect alloc] initWithTotalParticles:150];
	
	[self addChild:particle];

	CGSize s = [[CCDirector sharedDirector] winSize];
	
	[particle setPosition:ccp(s.width/2, s.height/2)];
	
	emitter_ = particle;
}

-(NSString *) title
{
	return @"Issue 1201. Unfinished";
}

-(NSString*) subtitle
{
	return @"Unfinished test. Ignore it";
}

@end




#pragma mark - MultipleParticleSystems
@implementation MultipleParticleSystems

-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	[[CCTextureCache sharedTextureCache] addImage:@"particles.png"]; 
	
	for (int i = 0; i<5; i++) {
		CCParticleSystemQuad *particleSystem = [CCParticleSystemQuad particleWithFile:@"Particles/SpinningPeas.plist"];
		
		particleSystem.position = ccp(i*50 ,i*50);
		
		particleSystem.positionType = kCCPositionTypeGrouped;
		[self addChild:particleSystem];
	}
	
	emitter_ = nil;
	
}

-(NSString *) title
{
	return @"Multiple particle systems";
}

-(NSString*) subtitle
{
	return @"v1.1 test: FPS should be lower than next test";
}

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagParticleCount];
	
	uint count = 0; 
	CCNode* item;
	CCARRAY_FOREACH(children_, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}

@end

@implementation MultipleParticleSystemsBatched

-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	CCParticleBatchNode *batchNode = [[CCParticleBatchNode alloc] initWithTexture:nil capacity:3000];
	
	[self addChild:batchNode z:1 tag:2];
	
	for (int i = 0; i<5; i++) {
		
		CCParticleSystemQuad *particleSystem = [CCParticleSystemQuad particleWithFile:@"Particles/SpinningPeas.plist"];
		
		particleSystem.positionType = kCCPositionTypeGrouped;		 
		particleSystem.position = ccp(i*50 ,i*50);
		
		[batchNode setTexture:particleSystem.texture];
		[batchNode addChild:particleSystem];
	}
	
	[batchNode release];
	
	emitter_ = nil;
}

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagParticleCount];
	
	uint count = 0; 
	CCNode* item;
	CCNode* batchNode = [self getChildByTag:2];
	CCARRAY_FOREACH(batchNode.children, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}

-(NSString *) title
{
	return @"Multiple particle systems batched";
}

-(NSString*) subtitle
{
	return @"v1.1 test: should perform better than previous test";
}
@end

@implementation AddAndDeleteParticleSystems

-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	//adds the texture inside the plist to the texture cache
	batchNode_ = [CCParticleBatchNode batchNodeWithTexture:nil capacity:16000];
	
	[self addChild:batchNode_ z:1 tag:2];
	
	for (int i = 0; i<6; i++) {
		
		CCParticleSystemQuad *particleSystem = [CCParticleSystemQuad particleWithFile:@"Particles/Spiral.plist"];
		[batchNode_ setTexture:particleSystem.texture];
		
		particleSystem.positionType = kCCPositionTypeGrouped;		 
		particleSystem.totalParticles = 200;
		
		particleSystem.position = ccp(i*15 +100,i*15+100);
		
		uint randZ = arc4random() % 100; 
		[batchNode_ addChild:particleSystem z:randZ tag:-1];
		
	}
	
	[self schedule:@selector(removeSystem) interval:0.5];
	emitter_ = nil;
	
}

- (void) removeSystem
{
	if ([[batchNode_ children] count] > 0) 
	{
		
		CCLOG(@"remove random system");
		NSUInteger rand = arc4random() % ([[batchNode_ children] count] - 1);
		[batchNode_ removeChild:[[batchNode_ children] objectAtIndex:rand] cleanup:YES];
		
		CCParticleSystemQuad *particleSystem = [CCParticleSystemQuad particleWithFile:@"Particles/Spiral.plist"];
		//add new
		
		particleSystem.positionType = kCCPositionTypeGrouped;		 
		particleSystem.totalParticles = 200;
		
		particleSystem.position = ccp(arc4random() % 300 ,arc4random() % 400);
		
		CCLOG(@"add a new system");
		uint randZ = arc4random() % 100; 
		[batchNode_ addChild:particleSystem z:randZ tag:-1];
	}
}

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagParticleCount];
	
	uint count = 0; 
	CCNode* item;
	CCNode* batchNode = [self getChildByTag:2];
	CCARRAY_FOREACH(batchNode.children, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}

-(NSString *) title
{
	return @"Add and remove Particle System";
}

-(NSString*) subtitle
{
	return @"v1.1 test: every 2 sec 1 system disappear, 1 appears";
}
@end



@implementation ReorderParticleSystems

-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	batchNode_ = [CCParticleBatchNode  batchNodeWithFile:@"stars-grayscale.png" capacity:3000];
	
	[self addChild:batchNode_ z:1 tag:2];
	
	
	for (int i = 0; i<3; i++) {
		
		CCParticleSystemQuad* particleSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:200];
		[particleSystem setTexture:batchNode_.texture];
		
		// duration
		particleSystem.duration = kCCParticleDurationInfinity;
		
		// radius mode
		particleSystem.emitterMode = kCCParticleModeRadius;
		
		// radius mode: 100 pixels from center
		particleSystem.startRadius = 100;
		particleSystem.startRadiusVar = 0;
		particleSystem.endRadius = kCCParticleStartRadiusEqualToEndRadius;
		particleSystem.endRadiusVar = 0;	// not used when start == end
		
		// radius mode: degrees per second
		// 45 * 4 seconds of life = 180 degrees
		particleSystem.rotatePerSecond = 45;
		particleSystem.rotatePerSecondVar = 0;
		
		
		// angle
		particleSystem.angle = 90;
		particleSystem.angleVar = 0;
		
		// emitter position
		particleSystem.posVar = CGPointZero;
		
		// life of particles
		particleSystem.life = 4;
		particleSystem.lifeVar = 0;
		
		// spin of particles
		particleSystem.startSpin = 0;
		particleSystem.startSpinVar = 0;
		particleSystem.endSpin = 0;
		particleSystem.endSpinVar = 0;
		
		// color of particles
		float color[3] = {0,0,0};
		color[i] = 1;
		ccColor4F startColor = {color[0], color[1], color[2], 1.0f};
		particleSystem.startColor = startColor;
		
		ccColor4F startColorVar = {0, 0, 0, 0};
		particleSystem.startColorVar = startColorVar;
		
		ccColor4F endColor = startColor;
		particleSystem.endColor = endColor;
		
		ccColor4F endColorVar = startColorVar;
		particleSystem.endColorVar = endColorVar;
		
		// size, in pixels
		particleSystem.startSize = 32;
		particleSystem.startSizeVar = 0;
		particleSystem.endSize = kCCParticleStartSizeEqualToEndSize;
		
		// emits per second
		particleSystem.emissionRate = particleSystem.totalParticles/particleSystem.life;
		
		// additive
		
		particleSystem.position = ccp(i*10+120 ,200);
		
		
		[batchNode_ addChild:particleSystem];
		[particleSystem setPositionType:kCCPositionTypeFree];
		
		[particleSystem release];
		
		//[pBNode addChild:particleSystem z:10 tag:0];
		
	}
	
	[self schedule:@selector(reorderSystem:) interval:2];
	emitter_ = nil;
	
}

- (void) reorderSystem:(ccTime) time
{
	CCParticleSystem* system = [[batchNode_ children] objectAtIndex:1];
	[batchNode_ reorderChild:system z:[system zOrder] - 1]; 	
}


-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagParticleCount];
	
	uint count = 0; 
	CCNode* item;
	CCNode* batchNode = [self getChildByTag:2];
	CCARRAY_FOREACH(batchNode.children, item)
	{
		if ([item isKindOfClass:[CCParticleSystem class]])
		{
			count += [(CCParticleSystem*) item particleCount];	
		}
	}
	NSString *str = [NSString stringWithFormat:@"%4d", count];
	[atlas setString:str];
}

-(NSString *) title
{
	return @"reorder systems";
}

-(NSString*) subtitle
{
	return @"changes every 2 seconds";
}
@end

#pragma mark -

@implementation PremultipliedAlphaTest

-(NSString *) title
{
	return @"premultiplied alpha";
}

-(NSString*) subtitle
{
	return @"no black halo, particles should fade out";
}

- (void)onEnter
{
	[super onEnter];

	[self setColor:ccBLUE];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/BoilingFoam.plist"];

	// Particle Designer "normal" blend func causes black halo on premul textures (ignores multiplication)
	//self.emitter.blendFunc = (ccBlendFunc){ GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };

	// Cocos2d "normal" blend func for premul causes alpha to be ignored (oversaturates colors)
	self.emitter.blendFunc = (ccBlendFunc) { GL_ONE, GL_ONE_MINUS_SRC_ALPHA };

	NSAssert([self.emitter doesOpacityModifyRGB], @"Particle texture does not have premultiplied alpha, test is useless");

	// Toggle next line to see old behavior
//	self.emitter.opacityModifyRGB = NO;

	self.emitter.startColor = ccc4f(1, 1, 1, 1);
	self.emitter.endColor   = ccc4f(1, 1, 1, 0);
	self.emitter.startColorVar = self.emitter.endColorVar = ccc4f(0, 0, 0, 0);

	[self addChild:emitter_ z:10];
}

@end

#pragma mark -

@implementation PremultipliedAlphaTest2
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/TestPremultipliedAlpha.plist"];
	[self addChild:emitter_ z:10];
}

-(NSString *) title
{
	return @"premultiplied alpha 2";
}
-(NSString*) subtitle
{
	return @"Arrows should be faded";
}
@end


#pragma mark -
#pragma mark App Delegate

// CLASS IMPLEMENTATIONS
#ifdef __CC_PLATFORM_IOS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director_ pushScene: scene];

	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
//	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end


#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

	[super applicationDidFinishLaunching:aNotification];

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director_ runWithScene:scene];
}
@end
#endif

