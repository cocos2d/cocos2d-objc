//
// cocos2d performance particle test
// Based on the test by Valentin Milea
//

#import "MainScene.h"

enum {
	kTagInfoLayer = 1,
	kTagMainLayer = 2,
	kTagParticleSystem = 3,
	kTagLabelAtlas = 4,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
		@"PerformanceTest1",
		@"PerformanceTest2",
		@"PerformanceTest3",
		@"PerformanceTest4",

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


#pragma mark MainScene

@implementation MainScene

+(id) testWithSubTest:(int) subtest particles:(int)particles
{
	return [[[self alloc] initWithSubTest:subtest particles:particles] autorelease];
}

- (id)initWithSubTest:(int) asubtest particles:(int)particles
{
	if ((self = [super init]) != nil) {
		
		srandom(0);
		
		subtestNumber = asubtest;
		CGSize s = [[Director sharedDirector] winSize];

		lastRenderedCount = 0;
		quantityParticles = particles;

		[MenuItemFont setFontSize:65];
		MenuItemFont *decrease = [MenuItemFont itemFromString: @" - " target:self selector:@selector(onDecrease:)];
		[decrease.label setColor:ccc3(0,200,20)];
		MenuItemFont *increase = [MenuItemFont itemFromString: @" + " target:self selector:@selector(onIncrease:)];
		[increase.label setColor:ccc3(0,200,20)];
		
		Menu *menu = [Menu menuWithItems: decrease, increase, nil];
		[menu alignItemsHorizontally];
		menu.position = ccp(s.width/2, s.height-65);
		[self addChild:menu z:1];
		
		Label *infoLabel = [Label labelWithString:@"0 nodes" fontName:@"Marker Felt" fontSize:30];
		[infoLabel setColor:ccc3(0,200,20)];
		infoLabel.position = ccp(s.width/2, s.height-90);
		[self addChild:infoLabel z:1 tag:kTagInfoLayer];
		
		// particles on stage
		LabelAtlas *labelAtlas = [LabelAtlas labelAtlasWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
		[self addChild:labelAtlas z:0 tag:kTagLabelAtlas];
		labelAtlas.position = CGPointMake(254,50);
		
		// Next Prev Test
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		menu = [Menu menuWithItems:item1, item2, item3, nil];
		[menu alignItemsHorizontally];
		menu.position = ccp(s.width/2, 30);
		[self addChild: menu z:1];	
		
		// Sub Tests
		[MenuItemFont setFontSize:40];
		MenuItemFont  *itemF1 = [MenuItemFont itemFromString:@"1 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF2 = [MenuItemFont itemFromString:@"2 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF3 = [MenuItemFont itemFromString:@"3 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF4 = [MenuItemFont itemFromString:@"4 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF5 = [MenuItemFont itemFromString:@"5 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF6 = [MenuItemFont itemFromString:@"6 " target:self selector:@selector(testNCallback:)];

		itemF1.tag = 1;
		itemF2.tag = 2;
		itemF3.tag = 3;
		itemF4.tag = 4;
		itemF5.tag = 5;
		itemF6.tag = 6;

		menu = [Menu menuWithItems:itemF1, itemF2, itemF3, itemF4, itemF5, itemF6, nil];
		
		int i=0;
		for( id child in [menu children] ) {
			if( i<3)
				[[child label] setColor:ccc3(200,20,20)];
			else if(i<6)
				[[child label] setColor:ccc3(0,200,20)];
			i++;
		}
		
		[menu alignItemsHorizontally];
		menu.position = ccp(s.width/2, 80);
		[self addChild:menu z:2];
		

		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:40];
		[self addChild:label z:1];
		[label setPosition: ccp(s.width/2, s.height-32)];
		[label setColor:ccc3(255,255,40)];

		[self updateQuantityLabel];
		[self createParticleSystem];
		
		[self schedule:@selector(step:)];
	}
	
	return self;
}

-(NSString*) title
{
	return @"No title";
}

-(void) dealloc
{
	[super dealloc];
}

-(void) step:(ccTime) dt
{
	LabelAtlas *atlas = (LabelAtlas*) [self getChildByTag:kTagLabelAtlas];
	ParticleSystem *emitter = (ParticleSystem*) [self getChildByTag:kTagParticleSystem];
	
	NSString *str = [NSString stringWithFormat:@"%4d", emitter.particleCount];
	[atlas setString:str];
}

-(void) createParticleSystem
{
	
	ParticleSystem *particleSystem;

	/*
	 * Tests:
	 * 1: Point Particle System using 32-bit textures (PNG)
	 * 2: Point Particle System using 16-bit textures (PNG)
	 * 3: Point Particle System using 4-bit textures (PVRTC)
	 
	 * 4: Quad Particle System using 32-bit textures (PNG)
	 * 5: Quad Particle System using 16-bit textures (PNG)
	 * 6: Quad Particle System using 4-bit textures (PVRTC)
	 */
	

	[self removeChildByTag:kTagParticleSystem cleanup:YES];
	
	// remove the "fire.png" from the TextureMgr cache. 
	Texture2D *texture = [[TextureMgr sharedTextureMgr] addImage:@"fire.png"];
	[[TextureMgr sharedTextureMgr] removeTexture:texture];
	

	switch( subtestNumber) {
		case 1:
			[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
			particleSystem = [[PointParticleSystem alloc] initWithTotalParticles:quantityParticles];
			particleSystem.texture = [[TextureMgr sharedTextureMgr] addImage:@"fire.png"];
			break;
		case 2:
			[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
			particleSystem = [[PointParticleSystem alloc] initWithTotalParticles:quantityParticles];
			particleSystem.texture = [[TextureMgr sharedTextureMgr] addImage:@"fire.png"];
			break;			
		case 3:
			particleSystem = [[PointParticleSystem alloc] initWithTotalParticles:quantityParticles];
			particleSystem.texture = [[TextureMgr sharedTextureMgr] addImage:@"fire.pvr"];
			break;
		case 4:
			[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
			particleSystem = [[QuadParticleSystem alloc] initWithTotalParticles:quantityParticles];
			particleSystem.texture = [[TextureMgr sharedTextureMgr] addImage:@"fire.png"];
			break;
		case 5:
			[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
			particleSystem = [[QuadParticleSystem alloc] initWithTotalParticles:quantityParticles];
			particleSystem.texture = [[TextureMgr sharedTextureMgr] addImage:@"fire.png"];
			break;			
		case 6:
			particleSystem = [[QuadParticleSystem alloc] initWithTotalParticles:quantityParticles];
			particleSystem.texture = [[TextureMgr sharedTextureMgr] addImage:@"fire.pvr"];
			break;
		default:
			particleSystem = nil;
			CCLOG(@"Shall not happen!");
			break;
	}
	[self addChild:particleSystem z:0 tag:kTagParticleSystem];
	[particleSystem release];

	[self doTest];
}


-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	id scene = [restartAction() testWithSubTest:subtestNumber particles:quantityParticles];
	[s addChild:scene];

	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	id scene = [nextAction() testWithSubTest:subtestNumber particles:quantityParticles];
	[s addChild:scene];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	id scene = [backAction() testWithSubTest:subtestNumber particles:quantityParticles];
	[s addChild:scene];

	[[Director sharedDirector] replaceScene: s];
}

-(void) testNCallback:(id) sender
{
	subtestNumber = [sender tag];
	[self restartCallback:sender];
}

-(void) doTest
{
	// override
}

-(void) onIncrease:(id) sender
{
	quantityParticles += kNodesIncrease;
	if( quantityParticles > kMaxParticles )
		quantityParticles = kMaxParticles;

	[self updateQuantityLabel];
	[self createParticleSystem];
}

-(void) onDecrease:(id) sender
{
	quantityParticles -= kNodesIncrease;
	if( quantityParticles < 0 )
		quantityParticles = 0;
	
	[self updateQuantityLabel];
	[self createParticleSystem];
}

- (void)updateQuantityLabel
{
	if( quantityParticles != lastRenderedCount ) {
		
		Label *infoLabel = (Label *) [self getChildByTag:kTagInfoLayer];
		[infoLabel setString: [NSString stringWithFormat:@"%u particles", quantityParticles] ];
		
		lastRenderedCount = quantityParticles;
	}
}


@end

#pragma mark Test 1

@implementation PerformanceTest1

-(NSString*) title
{
	return [NSString stringWithFormat:@"A (%d) size=4", subtestNumber];
}

-(void) doTest
{
	CGSize s = [[Director sharedDirector] winSize];
	ParticleSystem *particleSystem = (ParticleSystem*) [self getChildByTag:kTagParticleSystem];
	
	// duration
	particleSystem.duration = -1;
	
	// gravity
	particleSystem.gravity = ccp(0,-90);
	
	// angle
	particleSystem.angle = 90;
	particleSystem.angleVar = 0;
	
	// radial
	particleSystem.radialAccel = 0;
	particleSystem.radialAccelVar = 0;
	
	// speed of particles
	particleSystem.speed = 180;
	particleSystem.speedVar = 50;
	
	// emitter position
	particleSystem.position = ccp(s.width/2, 100);
	particleSystem.posVar = ccp(s.width/2,0);
	
	// life of particles
	particleSystem.life = 2.0f;
	particleSystem.lifeVar = 1;
	
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
	particleSystem.endSize = particleSystem.startSize = 4.0f;
	particleSystem.endSizeVar =particleSystem.startSizeVar = 0;
	
	// additive
	particleSystem.blendAdditive = NO;
}
@end

#pragma mark Test 2

@implementation PerformanceTest2

-(NSString*) title
{
	return [NSString stringWithFormat:@"B (%d) size=8", subtestNumber];
}

-(void) doTest
{
	CGSize s = [[Director sharedDirector] winSize];
	ParticleSystem *particleSystem = (ParticleSystem*) [self getChildByTag:kTagParticleSystem];

	// duration
	particleSystem.duration = -1;
	
	// gravity
	particleSystem.gravity = ccp(0,-90);
	
	// angle
	particleSystem.angle = 90;
	particleSystem.angleVar = 0;
	
	// radial
	particleSystem.radialAccel = 0;
	particleSystem.radialAccelVar = 0;
	
	// speed of particles
	particleSystem.speed = 180;
	particleSystem.speedVar = 50;
	
	// emitter position
	particleSystem.position = ccp(s.width/2, 100);
	particleSystem.posVar = ccp(s.width/2,0);
	
	// life of particles
	particleSystem.life = 2.0f;
	particleSystem.lifeVar = 1;
	
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
	particleSystem.endSize = particleSystem.startSize = 8.0f;
	particleSystem.endSizeVar =particleSystem.startSizeVar = 0;
	
	// additive
	particleSystem.blendAdditive = NO;
}
@end

#pragma mark Test 3
@implementation PerformanceTest3
-(NSString*) title
{
	return [NSString stringWithFormat:@"C (%d) size=32", subtestNumber];
}
-(void) doTest
{
	CGSize s = [[Director sharedDirector] winSize];
	ParticleSystem *particleSystem = (ParticleSystem*) [self getChildByTag:kTagParticleSystem];
	
	// duration
	particleSystem.duration = -1;
	
	// gravity
	particleSystem.gravity = ccp(0,-90);
	
	// angle
	particleSystem.angle = 90;
	particleSystem.angleVar = 0;
	
	// radial
	particleSystem.radialAccel = 0;
	particleSystem.radialAccelVar = 0;
	
	// speed of particles
	particleSystem.speed = 180;
	particleSystem.speedVar = 50;
	
	// emitter position
	particleSystem.position = ccp(s.width/2, 100);
	particleSystem.posVar = ccp(s.width/2,0);
	
	// life of particles
	particleSystem.life = 2.0f;
	particleSystem.lifeVar = 1;
	
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
	particleSystem.endSize = particleSystem.startSize = 32.0f;
	particleSystem.endSizeVar = particleSystem.startSizeVar = 0;
	
	// additive
	particleSystem.blendAdditive = NO;
	
}
@end

#pragma mark Test 4
@implementation PerformanceTest4
-(NSString*) title
{
	return [NSString stringWithFormat:@"D (%d) size=64", subtestNumber];
}
-(void) doTest
{
	CGSize s = [[Director sharedDirector] winSize];
	ParticleSystem *particleSystem = (ParticleSystem*) [self getChildByTag:kTagParticleSystem];
	
	// duration
	particleSystem.duration = -1;
	
	// gravity
	particleSystem.gravity = ccp(0,-90);
	
	// angle
	particleSystem.angle = 90;
	particleSystem.angleVar = 0;
	
	// radial
	particleSystem.radialAccel = 0;
	particleSystem.radialAccelVar = 0;
	
	// speed of particles
	particleSystem.speed = 180;
	particleSystem.speedVar = 50;
	
	// emitter position
	particleSystem.position = ccp(s.width/2, 100);
	particleSystem.posVar = ccp(s.width/2,0);
	
	// life of particles
	particleSystem.life = 2.0f;
	particleSystem.lifeVar = 1;
	
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
	particleSystem.endSize = particleSystem.startSize = 64.0f;
	particleSystem.endSizeVar =particleSystem.startSizeVar = 0;
	
	// additive
	particleSystem.blendAdditive = NO;
	
}
@end

