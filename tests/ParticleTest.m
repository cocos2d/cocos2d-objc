//
// Particle Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "ParticleTest.h"

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
};

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

@synthesize emitter;
-(id) init
{
	if( (self=[super initWithColor:ccc4(127,127,127,255)] )) {

		self.isTouchEnabled = YES;
		
		CGSize s = [[Director sharedDirector] winSize];
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:100];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		Label *tapScreen = [Label labelWithString:@"(Tap the Screen)" fontName:@"Arial" fontSize:20];
		[tapScreen setPosition: ccp(s.width/2, s.height-80)];
		[self addChild:tapScreen z:100];
		
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		MenuItemToggle *item4 = [MenuItemToggle itemWithTarget:self selector:@selector(toggleCallback:) items:
								 [MenuItemFont itemFromString: @"Free Movement"],
								 [MenuItemFont itemFromString: @"Grouped Movement"],
								 nil];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, item4, nil];
			
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		item4.position = ccp( 0, 100);
		item4.anchorPoint = ccp(0,0);

		[self addChild: menu z:100];	
		
		LabelAtlas *labelAtlas = [LabelAtlas labelAtlasWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
		[self addChild:labelAtlas z:100 tag:kTagLabelAtlas];
		labelAtlas.position = ccp(254,50);
		
		// moving background
		background = [Sprite spriteWithFile:@"background3.png"];
		[self addChild:background z:5];
		[background setPosition:ccp(s.width/2, s.height-180)];

		id move = [MoveBy actionWithDuration:4 position:ccp(300,0)];
		id move_back = [move reverse];
		id seq = [Sequence actions: move, move_back, nil];
		[background runAction:[RepeatForever actionWithAction:seq]];
		
		
		[self schedule:@selector(step:)];
	}

	return self;
}

- (void) dealloc
{
	[emitter release];
	[super dealloc];
}


-(void) registerWithTouchDispatcher
{
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	return YES;
}
- (void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
	return [self ccTouchEnded:touch withEvent:event];
}

- (void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
	
	CGPoint	pos = [background convertToWorldSpace:CGPointZero];
	emitter.position = ccpSub(convertedLocation, pos);	
}

-(void) step:(ccTime) dt
{
	LabelAtlas *atlas = (LabelAtlas*) [self getChildByTag:kTagLabelAtlas];

	NSString *str = [NSString stringWithFormat:@"%4d", emitter.particleCount];
	[atlas setString:str];
}

-(NSString*) title
{
	return @"No title";
}

-(void) toggleCallback: (id) sender
{
	if( emitter.positionType == kPositionTypeGrouped )
		emitter.positionType = kPositionTypeFree;
	else
		emitter.positionType = kPositionTypeGrouped;
}

-(void) restartCallback: (id) sender
{
//	Scene *s = [Scene node];
//	[s addChild: [restartAction() node]];
//	[[Director sharedDirector] replaceScene: s];
	
	[emitter resetSystem];
//	[emitter stopSystem];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) setEmitterPosition
{
	emitter.position = ccp(200, 70);
}

@end

#pragma mark -

@implementation DemoFirework
-(void) onEnter
{
	[super onEnter];
	self.emitter = [ParticleFireworks node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"stars.png"];
	
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
	self.emitter = [ParticleFire node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
	CGPoint p = emitter.position;
	emitter.position = ccp(p.x, 100);
	
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
	self.emitter = [ParticleSun node];
	[background addChild: emitter z:10];

	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
	
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
	self.emitter = [ParticleGalaxy node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
	
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

	self.emitter = [ParticleFlower node];
	[background addChild: emitter z:10];
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"stars.png"];
	
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
	self.emitter = [[QuadParticleSystem alloc] initWithTotalParticles:50];
	[background addChild: emitter z:10];
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"stars.png"];
	
	// duration
	emitter.duration = -1;
	
	// gravity
	emitter.gravity = CGPointZero;
	
	// angle
	emitter.angle = 90;
	emitter.angleVar = 360;
	
	// speed of particles
	emitter.speed = 160;
	emitter.speedVar = 20;
	
	// radial
	emitter.radialAccel = -120;
	emitter.radialAccelVar = 0;
	
	// tagential
	emitter.tangentialAccel = 30;
	emitter.tangentialAccelVar = 0;
	
	// emitter position
	emitter.position = ccp(160,240);
	emitter.posVar = CGPointZero;
	
	// life of particles
	emitter.life = 4;
	emitter.lifeVar = 1;
	
	// spin of particles
	emitter.startSpin = 0;
	emitter.startSpinVar = 0;
	emitter.endSpin = 0;
	emitter.endSpinVar = 0;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter.endColorVar = endColorVar;
	
	// size, in pixels
	emitter.startSize = 80.0f;
	emitter.startSizeVar = 40.0f;
	emitter.endSize = kParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter.emissionRate = emitter.totalParticles/emitter.life;
	
	// additive
	emitter.blendAdditive = YES;
	
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
	self.emitter = [[QuadParticleSystem alloc] initWithTotalParticles:300];
	[background addChild: emitter z:10];
	[emitter release];
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"stars2.png"];
	
	// duration
	emitter.duration = -1;
	
	// gravity
	emitter.gravity = CGPointZero;
	
	// angle
	emitter.angle = 90;
	emitter.angleVar = 360;
	
	// speed of particles
	emitter.speed = 160;
	emitter.speedVar = 20;
	
	// radial
	emitter.radialAccel = -120;
	emitter.radialAccelVar = 0;
	
	// tagential
	emitter.tangentialAccel = 30;
	emitter.tangentialAccelVar = 0;
	
	// emitter position
	emitter.position = ccp(160,240);
	emitter.posVar = CGPointZero;
	
	// life of particles
	emitter.life = 3;
	emitter.lifeVar = 1;

	// spin of particles
	emitter.startSpin = 0;
	emitter.startSpinVar = 0;
	emitter.endSpin = 0;
	emitter.endSpinVar = 2000;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter.endColorVar = endColorVar;

	// size, in pixels
	emitter.startSize = 30.0f;
	emitter.startSizeVar = 00.0f;
	emitter.endSize = kParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter.emissionRate = emitter.totalParticles/emitter.life;

	// additive
	emitter.blendAdditive = NO;
	
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
	self.emitter = [ParticleMeteor node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
	
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
	self.emitter = [ParticleSpiral node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
	
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
	self.emitter = [ParticleExplosion node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"stars.png"];
	
	emitter.autoRemoveOnFinish = YES;
	
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
	self.emitter = [ParticleSmoke node];
	[background addChild: emitter z:10];
	
	CGPoint p = emitter.position;
	emitter.position = ccp( p.x, 100);
	
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
	self.emitter = [ParticleSnow node];
	[background addChild: emitter z:10];
	
	CGPoint p = emitter.position;
	emitter.position = ccp( p.x, p.y-110);
	emitter.life = 3;
	emitter.lifeVar = 1;
	
	// gravity
	emitter.gravity = ccp(0,-10);
		
	// speed of particles
	emitter.speed = 130;
	emitter.speedVar = 30;
	
	
	ccColor4F startColor = emitter.startColor;
	startColor.r = 0.9f;
	startColor.g = 0.9f;
	startColor.b = 0.9f;
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = emitter.startColorVar;
	startColorVar.b = 0.1f;
	emitter.startColorVar = startColorVar;
	
	emitter.emissionRate = emitter.totalParticles/emitter.life;
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"snow.png"];
	
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
	self.emitter = [ParticleRain node];
	[background addChild: emitter z:10];
	
	CGPoint p = emitter.position;
	emitter.position = ccp( p.x, p.y-100);
	emitter.life = 4;
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
	
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
	self.emitter = [[PointParticleSystem alloc] initWithTotalParticles:1000];
	[background addChild: emitter z:10];
	[emitter release];
	
	CGSize s = [[Director sharedDirector] winSize];
	
	// duration
	emitter.duration = -1;
	
	// gravity
	emitter.gravity = ccp(0,0);
	
	// angle
	emitter.angle = 0;
	emitter.angleVar = 360;
	
	// radial
	emitter.radialAccel = 70;
	emitter.radialAccelVar = 10;
	
	// tagential
	emitter.tangentialAccel = 80;
	emitter.tangentialAccelVar = 0;
	
	// speed of particles
	emitter.speed = 50;
	emitter.speedVar = 10;
	
	// emitter position
	emitter.position = ccp( s.width/2, s.height/2);
	emitter.posVar = CGPointZero;
	
	// life of particles
	emitter.life = 2.0f;
	emitter.lifeVar = 0.3f;
	
	// emits per frame
	emitter.emissionRate = emitter.totalParticles/emitter.life;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter.endColorVar = endColorVar;
	
	// size, in pixels
	emitter.startSize = 1.0f;
	emitter.startSizeVar = 1.0f;
	emitter.endSize = 32.0f;
	emitter.endSizeVar = 8.0f;
	
	// texture
//	emitter.texture = [[TextureMgr sharedTextureMgr] addImage:@"fire.png"];
	
	// additive
	emitter.blendAdditive = NO;
	
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
	self.emitter = [[ParticleFlower alloc] initWithTotalParticles:500];
	[background addChild: emitter z:10];
	[emitter release];

	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"stars.png"];
	emitter.lifeVar = 0;
	emitter.life = 10;
	emitter.speed = 100;
	emitter.speedVar = 0;
	emitter.emissionRate = 10000;
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"Ring Demo";
}
@end

#pragma mark -
#pragma mark App Delegate

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:YES];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationPortrait];
	[[Director sharedDirector] setDisplayFPS: YES];

	// AnimationInterval doesn't work with FastDirector, yet
//	[[Director sharedDirector] setAnimationInterval: 1.0/60];

	// create OpenGL view and attach it to a window
	[[Director sharedDirector] attachInView:window];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	

	Scene *scene = [Scene node];
	[scene addChild: [nextAction() node]];
	
	[window makeKeyAndVisible];
			 
	[[Director sharedDirector] runWithScene: scene];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

@end
