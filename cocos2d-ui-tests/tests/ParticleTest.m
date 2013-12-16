//
//  ParticleTest
//  cocos2d-ui-tests-ios
//
//  Created by Andy Korth on November 25th, 2013.
//

#import "TestBase.h"
#import "CCTextureCache.h"

@interface ParticleTest : TestBase
@property (readwrite, retain) CCParticleSystemBase *emitter;
@end


@implementation ParticleTest
{
  CCSprite			*background;
}

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupFlower",
            @"setupBigFlower",
            @"setupUpsideDown",
            @"setupTestPremultipliedAlpha",
            @"setupMultipleSystems",
            @"setupCustomSpinTest",
            @"setupRainbowEffect",
            @"setupGalaxy",
            @"setupLavaFlow",
            @"setupComet",

            nil];
}

- (void) setUp
{
	[[CCFileUtils sharedFileUtils] setSearchPath: @[ @"Images", kCCFileUtilsDefaultSearchPath] ];
}

-(void) setupComet
{
	self.emitter = [CCParticleSystem particleWithFile:@"Particles/Comet.plist"];
	[self.contentNode addChild:self.emitter z:10];
  [self createScene: @"Comet Particle System"];
}

-(void) setupFlower
{
	self.emitter = [CCParticleSystem particleWithFile:@"Particles/Flower.plist"];
	self.emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	[self.contentNode addChild:self.emitter z:10];
  [self createScene: @"Flower made of pretty stars. Loaded from plist."];
}

-(void) setupBigFlower
{
  self.emitter = [[CCParticleSystem alloc] initWithTotalParticles:50];
	self.emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
  
	// duration
	self.emitter.duration = CCParticleSystemDurationInfinity;
  
	// Gravity Mode: gravity
	self.emitter.gravity = CGPointZero;
  
	// Set "Gravity" mode (default one)
	self.emitter.emitterMode = CCParticleSystemModeGravity;
  
	// Gravity Mode: speed of particles
	self.emitter.speed = 160;
	self.emitter.speedVar = 20;
  
	// Gravity Mode: radial
	self.emitter.radialAccel = -120;
	self.emitter.radialAccelVar = 0;
  
	// Gravity Mode: tagential
	self.emitter.tangentialAccel = 30;
	self.emitter.tangentialAccelVar = 0;
  
	// angle
	self.emitter.angle = 90;
	self.emitter.angleVar = 360;
  
	// emitter position
	self.emitter.position = ccp(160,240);
	self.emitter.posVar = CGPointZero;
  
	// life of particles
	self.emitter.life = 4;
	self.emitter.lifeVar = 1;
  
	// spin of particles
	self.emitter.startSpin = 0;
	self.emitter.startSpinVar = 0;
	self.emitter.endSpin = 0;
	self.emitter.endSpinVar = 0;
  
	// color of particles
	self.emitter.startColor = [CCColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
	self.emitter.startColorVar = [CCColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
	self.emitter.endColor = [CCColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.2];
	self.emitter.endColorVar = [CCColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.2];
  
	// size, in pixels
	self.emitter.startSize = 80.0f;
	self.emitter.startSizeVar = 40.0f;
	self.emitter.endSize = CCParticleSystemStartSizeEqualToEndSize;
  
	// emits per second
	self.emitter.emissionRate = self.emitter.totalParticles/self.emitter.life;
  
	// additive
	self.emitter.blendAdditive = YES;

	[self.contentNode addChild:self.emitter z:10];

  [self createScene: @"Big Flower, setup without plist"];
}


#ifdef __CC_PLATFORM_IOS
#define PARTICLE_FIRE_NAME @"fire.pvr"
#elif defined(__CC_PLATFORM_MAC)
#define PARTICLE_FIRE_NAME @"fire.png"
#endif

-(void) setupMultipleSystems
{

  CGSize s = [CCDirector sharedDirector].designSize;

  for (int i = 0; i<5; i++) {
    CCParticleSystem *particleSystem = [CCParticleSystem particleWithFile:@"Particles/Flower.plist"];
    particleSystem.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
    
    particleSystem.position = ccp(s.width/2 + i*150 - 300, s.height/2);
    [self.contentNode addChild:particleSystem z:10];
  }

  [self createScene: @"Multiple Particle Systems - There should be 5"];
}



-(void) setupGalaxy
{
  
	self.emitter = [CCParticleSystem particleWithFile:@"Particles/Galaxy.plist"];
  self.emitter.texture = [[CCTextureCache sharedTextureCache] addImage: PARTICLE_FIRE_NAME];
	[self.contentNode addChild:self.emitter z:10];
  [self createScene: @"Galaxy - You should see radial & tangential accel"];
}

-(void) setupLavaFlow
{
	self.emitter = [CCParticleSystem particleWithFile:@"Particles/LavaFlow.plist"];
	[self.contentNode addChild:self.emitter z:10];
  [self createScene: @"Lava Flow"];
}

-(void) setupTestPremultipliedAlpha
{
	self.emitter = [CCParticleSystem particleWithFile:@"Particles/TestPremultipliedAlpha.plist"];
	[self.contentNode addChild:self.emitter z:10];
  [self createScene: @"Test Premultiplied Alpha - Arrows should be faded"];
}

-(void) setupUpsideDown
{
  // Issue 872
	self.emitter = [CCParticleSystem particleWithFile:@"Particles/Upsidedown.plist"];
  
	[self.contentNode addChild:self.emitter z:10];
  [self createScene: @"Particles should NOT be Upside Down. M should appear, not W."];
}


-(void) setupCustomSpinTest
{
	self.emitter = [CCParticleSystem particleWithFile:@"Particles/SpookyPeas.plist"];
  
  self.emitter.startSpin = 0;
  self.emitter.startSpinVar = 360;
  self.emitter.endSpin = 720;
  self.emitter.endSpinVar = 360;
  
	[self.contentNode addChild:self.emitter z:10];
  [self createScene: @"Custom Spin Test"];
}


-(void) setupRainbowEffect
{
  
  self.emitter = [[CCParticleSystem alloc] initWithTotalParticles:50];
  // additive
  self.emitter.blendAdditive = NO;
  
  // duration
  self.emitter.duration = CCParticleSystemDurationInfinity;
  
  // Gravity Mode
  self.emitter.emitterMode = CCParticleSystemModeGravity;
  
  // Gravity Mode: gravity
  self.emitter.gravity = ccp(0,0);
  
  // Gravity mode: radial acceleration
  self.emitter.radialAccel = 0;
  self.emitter.radialAccelVar = 0;
  
  // Gravity mode: speed of particles
  self.emitter.speed = 120;
  self.emitter.speedVar = 0;
  
  
  // angle
  self.emitter.angle = 180;
  self.emitter.angleVar = 0;
  
  // emitter position
  CGSize winSize = [CCDirector sharedDirector].designSize;
  self.emitter.position = ccp(winSize.width/2, winSize.height/2);
  self.emitter.posVar = CGPointZero;
  
  // life of particles
  self.emitter.life = 0.5f;
  self.emitter.lifeVar = 0;
  
  // size, in pixels
  self.emitter.startSize = 25.0f;
  self.emitter.startSizeVar = 0;
  self.emitter.endSize = CCParticleSystemStartSizeEqualToEndSize;
  
  // emits per seconds
  self.emitter.emissionRate = self.emitter.totalParticles/self.emitter.life;
  
  // color of particles
  self.emitter.startColor = [CCColor colorWithRed:1 green:1 blue:1 alpha:1];
  self.emitter.endColor = [CCColor colorWithRed:0 green:0 blue:0 alpha:1];
  
  self.emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"particles.png"];

	[self.contentNode addChild:self.emitter z:10];
  [self createScene: @"Prevent bursts of particles that exceed the emitCounter. You should see a steady line of particles, without jittering bursts."];
}


- (void)createScene:(NSString *) title
{
  self.subTitle = title;
  
  self.userInteractionEnabled = TRUE;
  
  CGSize s = [CCDirector sharedDirector].designSize;
  
  background = [CCSprite spriteWithImageNamed:@"Images/gridBackground.png"];
  [self.contentNode addChild:background z:5];
  background.scale = 1.0f;
  [background setPosition:ccp(s.width/2, s.height/2)];
  
  self.emitter.position = ccp(s.width/2, s.height/2);
  
//  id move = [CCActionMoveBy actionWithDuration:4 position:ccp(300,0)];
//  id move_back = [move reverse];
//  id seq = [CCActionSequence actions: move, move_back, nil];
//  [background runAction:[CCActionRepeatForever actionWithAction:seq]];

}

-(void) update:(CCTime) dt
{
//	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:CCTagParticleCount];
//  
//	NSString *str = [NSString stringWithFormat:@"%4ld", (unsigned long)self.emitter.particleCount];
//	[atlas setString:str];
}
-(void) restartCallback: (id) sender
{
  //	Scene *s = [Scene node];
  //	[s addChild: [restartAction() node]];
  //	[[Director sharedDirector] replaceScene: s];
  
	[_emitter resetSystem];
  [self.contentNode removeAllChildren ];

  //	[self.emitter stopSystem];
}

#ifdef __CC_PLATFORM_IOS

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self touchEnded:touch withEvent:event];
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self touchEnded:touch withEvent:event];
}

- (void)touchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
  
	_emitter.position = convertedLocation;
}

#elif defined(__CC_PLATFORM_MAC)

- (void)mouseDown:(NSEvent *)theEvent
{
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertEventToGL:theEvent];
  
	CGPoint pos = CGPointZero;
  
	if( background )
		pos = [background convertToWorldSpace:CGPointZero];
	self.emitter.position = ccpSub(convertedLocation, pos);
}
#endif // __CC_PLATFORM_MAC


@end
