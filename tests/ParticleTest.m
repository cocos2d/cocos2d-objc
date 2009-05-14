//
// Particle Demo
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//

// local import
#import "ParticleTest.h"

enum {
	kTagLabelAtlas = 1,
	kTagEmitter	= 2,
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
-(id) init
{
	if( (self=[super init]) ) {

		isTouchEnabled = YES;

		CGSize s = [[Director sharedDirector] winSize];
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		Label *tapScreen = [Label labelWithString:@"(Tap the Screen)" fontName:@"Arial" fontSize:20];
		[tapScreen setPosition: ccp(s.width/2, s.height-80)];
		[self addChild:tapScreen];
		
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
			
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:-1];	
		
		LabelAtlas *labelAtlas = [LabelAtlas labelAtlasWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
		[self addChild:labelAtlas z:0 tag:kTagLabelAtlas];
		labelAtlas.position = ccp(254,50);
			
		[self schedule:@selector(step:)];
	}

	return self;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	return [self ccTouchesEnded:touches withEvent:event];
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];
	
	ParticleSystem *s = (ParticleSystem*) [self getChildByTag:kTagEmitter];
	
//	CGPoint source = ccpSub( convertedLocation, s.position );
//	s.source = source;
	s.position = convertedLocation;
	
	return kEventHandled;
}

-(void) step:(ccTime) dt
{
	LabelAtlas *atlas = (LabelAtlas*) [self getChildByTag:kTagLabelAtlas];
	ParticleSystem *emitter = (ParticleSystem*) [self getChildByTag:kTagEmitter];

	NSString *str = [NSString stringWithFormat:@"%4d", emitter.particleCount];
	[atlas setString:str];
}

-(NSString*) title
{
	return @"No title";
}

-(void) restartCallback: (id) sender
{
//	Scene *s = [Scene node];
//	[s addChild: [restartAction() node]];
//	[[Director sharedDirector] replaceScene: s];
	
	ParticleSystem *emitter = (ParticleSystem*) [self getChildByTag:kTagEmitter];
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

@end

@implementation BigParticleDemo

-(id) init
{
	if( (self=[super init]) ) {
		
		isTouchEnabled = YES;
		
		CGSize s = [[Director sharedDirector] winSize];
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: CGPointMake(s.width/2, s.height-50)];
		
		Label *tapScreen = [Label labelWithString:@"(Tap the Screen)" fontName:@"Arial" fontSize:20];
		[tapScreen setPosition: CGPointMake(s.width/2, s.height-80)];
		[self addChild:tapScreen];
		
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = CGPointMake( s.width/2 - 100,30);
		item2.position = CGPointMake( s.width/2, 30);
		item3.position = CGPointMake( s.width/2 + 100,30);
		[self addChild: menu z:-1];	
		
		LabelAtlas *labelAtlas = [LabelAtlas labelAtlasWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
		[self addChild:labelAtlas z:0 tag:kTagLabelAtlas];
		labelAtlas.position = CGPointMake(254,50);
		
		[self schedule:@selector(step:)];
	}
	
	return self;
}

-(void) restartCallback: (id) sender
{
	ParticleSystem *emitter = (ParticleSystem*) [self getChildByTag:kTagEmitter];
	[emitter resetSystem];
}

@end


@implementation DemoFirework
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleFireworks node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"stars.png"];

}
-(NSString *) title
{
	return @"ParticleFireworks";
}
@end

@implementation DemoFire
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleFire node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
	CGPoint p = emitter.position;
	emitter.position = ccp(p.x, 100);
}
-(NSString *) title
{
	return @"ParticleFire";
}
@end

@implementation DemoSun
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleSun node];
	[self addChild: emitter z:0 tag:kTagEmitter];

	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
}
-(NSString *) title
{
	return @"ParticleSun";
}
@end

@implementation DemoGalaxy
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleGalaxy node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
}
-(NSString *) title
{
	return @"ParticleGalaxy";
}
@end

@implementation DemoFlower
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleFlower node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"stars.png"];
}
-(NSString *) title
{
	return @"ParticleFlower";
}
@end

@implementation DemoBigFlower
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [[QuadParticleSystem alloc] initWithTotalParticles:50];
	[self addChild: emitter z:0 tag:kTagEmitter];
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
	
}
-(NSString *) title
{
	return @"Big Particles";
}
@end

@implementation DemoRotFlower
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [[QuadParticleSystem alloc] initWithTotalParticles:300];
	[self addChild: emitter z:0 tag:kTagEmitter];
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
	
}
-(NSString *) title
{
	return @"Spinning Particles";
}
@end


@implementation DemoMeteor
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleMeteor node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
}
-(NSString *) title
{
	return @"ParticleMeteor";
}
@end

@implementation DemoSpiral
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleSpiral node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];
}
-(NSString *) title
{
	return @"ParticleSpiral";
}
@end

@implementation DemoExplosion
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleExplosion node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"stars.png"];
}
-(NSString *) title
{
	return @"ParticleExplosion";
}
@end

@implementation DemoSmoke
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleSmoke node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	
	CGPoint p = emitter.position;
	emitter.position = ccp( p.x, 100);
}
-(NSString *) title
{
	return @"ParticleSmoke";
}
@end

@implementation DemoSnow
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleSnow node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	
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

}
-(NSString *) title
{
	return @"ParticleSnow";
}
@end

@implementation DemoRain
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleRain node];
	[self addChild: emitter z:0 tag:kTagEmitter];
	
	CGPoint p = emitter.position;
	emitter.position = ccp( p.x, p.y-100);
	emitter.life = 4;
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];

}
-(NSString *) title
{
	return @"ParticleRain";
}
@end

@implementation DemoModernArt
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *particleSystem = [[PointParticleSystem alloc] initWithTotalParticles:1000];
	[self addChild: particleSystem z:0 tag:kTagEmitter];
	[particleSystem release];
	
	CGSize s = [[Director sharedDirector] winSize];
	
	// duration
	particleSystem.duration = -1;
	
	// gravity
	particleSystem.gravity = ccp(0,0);
	
	// angle
	particleSystem.angle = 0;
	particleSystem.angleVar = 360;
	
	// radial
	particleSystem.radialAccel = 70;
	particleSystem.radialAccelVar = 10;
	
	// tagential
	particleSystem.tangentialAccel = 80;
	particleSystem.tangentialAccelVar = 0;
	
	// speed of particles
	particleSystem.speed = 50;
	particleSystem.speedVar = 10;
	
	// emitter position
	particleSystem.position = ccp( s.width/2, s.height/2);
	particleSystem.posVar = CGPointZero;
	
	// life of particles
	particleSystem.life = 2.0f;
	particleSystem.lifeVar = 0.3f;
	
	// emits per frame
	particleSystem.emissionRate = particleSystem.totalParticles/particleSystem.life;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	particleSystem.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	particleSystem.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	particleSystem.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	particleSystem.endColorVar = endColorVar;
	
	// size, in pixels
	particleSystem.startSize = 1.0f;
	particleSystem.startSizeVar = 1.0f;
	particleSystem.endSize = 32.0f;
	particleSystem.endSizeVar = 8.0f;
	
	// texture
//	particleSystem.texture = [[TextureMgr sharedTextureMgr] addImage:@"fire.png"];
	
	// additive
	particleSystem.blendAdditive = NO;	
}
-(NSString *) title
{
	return @"Varying size";
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
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationPortrait];
	[[Director sharedDirector] setDisplayFPS: YES];

	// AnimationInterval doesn't work with FastDirector, yet
//	[[Director sharedDirector] setAnimationInterval: 1.0/60];

	// create OpenGL view and attach it to a window
	[[Director sharedDirector] attachInView:window];

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
