//
// Sprites Demo
// a cocos2d example
//

// local import
#import "ParticleDemo.h"

#define kTagLabelAtlas	0xAABBCCDD
#define kTagEmitter		0xAABBCCDE

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
	[super init];

	CGRect s = [[Director sharedDirector] winSize];
	Label* label = [Label labelWithString:[self title] dimensions:CGSizeMake(s.size.width, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: cpv(s.size.width/2, s.size.height-50)];
	
	MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
	MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
	MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
	
	Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		
	menu.position = cpvzero;
	item1.position = cpv( s.size.width/2 - 100,30);
	item2.position = cpv( s.size.width/2, 30);
	item3.position = cpv( s.size.width/2 + 100,30);
	[self add: menu z:-1];	
	
	LabelAtlas *labelAtlas = [LabelAtlas labelAtlasWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
	[self add:labelAtlas z:0 tag:kTagLabelAtlas];
	labelAtlas.position = cpv(254,50);
		
	[self schedule:@selector(step:)];
	return self;
}

-(void) step:(ccTime) dt
{
	LabelAtlas *atlas = (LabelAtlas*) [self getByTag:kTagLabelAtlas];
	ParticleSystem *emitter = (ParticleSystem*) [self getByTag:kTagEmitter];

	NSString *str = [NSString stringWithFormat:@"%4d", emitter.particleCount];
	[atlas setString:str];
}

-(NSString*) title
{
	return @"No title";
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];	
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

@end

@implementation DemoFirework
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleFireworks node];
	[self add: emitter z:0 tag:kTagEmitter];
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
	[self add: emitter z:0 tag:kTagEmitter];
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
	[self add: emitter z:0 tag:kTagEmitter];
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
	[self add: emitter z:0 tag:kTagEmitter];
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
	[self add: emitter z:0 tag:kTagEmitter];
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
	[self add: emitter z:0 tag:kTagEmitter];
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
	[self add: emitter z:0 tag:kTagEmitter];
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
	[self add: emitter z:0 tag:kTagEmitter];
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
	[self add: emitter z:0 tag:kTagEmitter];
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
	[self add: emitter z:0 tag:kTagEmitter];
}
-(NSString *) title
{
	return @"ParticleSnow";
}
@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: NO];
	[[Director sharedDirector] setDisplayFPS: YES];
	[[Director sharedDirector] setAnimationInterval: 1.0/30];

	Scene *scene = [Scene node];
	[scene add: [nextAction() node]];
			 
	[[Director sharedDirector] runScene: scene];
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

@end
