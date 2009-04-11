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
		[label setPosition: cpv(s.width/2, s.height-50)];
		
		Label *tapScreen = [Label labelWithString:@"(Tap the Screen)" fontName:@"Arial" fontSize:20];
		[tapScreen setPosition: cpv(s.width/2, s.height-80)];
		[self addChild:tapScreen];
		
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
			
		menu.position = cpvzero;
		item1.position = cpv( s.width/2 - 100,30);
		item2.position = cpv( s.width/2, 30);
		item3.position = cpv( s.width/2 + 100,30);
		[self addChild: menu z:-1];	
		
		LabelAtlas *labelAtlas = [LabelAtlas labelAtlasWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
		[self addChild:labelAtlas z:0 tag:kTagLabelAtlas];
		labelAtlas.position = cpv(254,50);
			
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
	
	cpVect source = cpvsub( convertedLocation, s.position );
	s.source = source;
	
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
	emitter.position = CGPointMake(p.x, 100);
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
	emitter.position = CGPointMake( p.x, 100);
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
	emitter.position = CGPointMake( p.x, p.y-110);
	emitter.life = 25;
	
	ccColorF startColor = emitter.startColor;
	startColor.r = 0.9f;
	startColor.g = 0.9f;
	startColor.b = 0.9f;
	emitter.startColor = startColor;
	
	ccColorF startColorVar = emitter.startColorVar;
	startColorVar.b = 0.1f;
	emitter.startColorVar = startColorVar;
	
	ccColorF endColor = emitter.endColor;
	endColor.r = 0.9f;
	endColor.g = 0.9f;
	endColor.b = 0.9f;
	emitter.endColor = endColor;
	
	ccColorF endColorVar = emitter.endColorVar;
	endColorVar.b = 0.1f;
	endColorVar.a = 0.5f;
	emitter.endColorVar = endColorVar;
	
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
	emitter.position = CGPointMake( p.x, p.y-100);
	emitter.life = 25;	
	
	emitter.texture = [[TextureMgr sharedTextureMgr] addImage: @"fire.pvr"];

}
-(NSString *) title
{
	return @"ParticleRain";
}
@end



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
	[[Director sharedDirector] setLandscape: NO];
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
