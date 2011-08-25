//
// Particle Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "ParticleTest.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define PARTICLE_FIRE_NAME @"fire.pvr"
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#define PARTICLE_FIRE_NAME @"fire.png"
#endif
enum {
	kTagLabelAtlas = 1,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	
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

@implementation ParticleDemo

@synthesize emitter=emitter_;
-(id) init
{
	if( (self=[super initWithColor:ccc4(127,127,127,255)] )) {

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
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
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenuItemToggle *item4 = [CCMenuItemToggle itemWithTarget:self selector:@selector(toggleCallback:) items:
								   [CCMenuItemFont itemFromString: @"Free Movement"],
								   [CCMenuItemFont itemFromString: @"Relative Movement"],
								   [CCMenuItemFont itemFromString: @"Grouped Movement"],

								 nil];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, item4, nil];
			
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		item4.position = ccp( 0, 100);
		item4.anchorPoint = ccp(0,0);

		[self addChild: menu z:100];	
		
		CCLabelAtlas *labelAtlas = [CCLabelAtlas labelWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
		[self addChild:labelAtlas z:100 tag:kTagLabelAtlas];
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


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
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
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)


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
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelAtlas];

	NSString *str = [NSString stringWithFormat:@"%4d", emitter_.particleCount];
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

#pragma mark -

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

#pragma mark -

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

#pragma mark -

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

#pragma mark -

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

#pragma mark -

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

#pragma mark -

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

#pragma mark -

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

#pragma mark -

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
	emitter_ = [[CCParticleSystemPoint alloc] initWithTotalParticles:1000];
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



#pragma mark -
#pragma mark App Delegate

// CLASS IMPLEMENTATIONS
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene: scene];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}
@end


#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
	//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene:scene];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
#endif

