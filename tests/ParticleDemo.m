//
// Sprites Demo
// a cocos2d example
//

// local import
#import "ParticleDemo.h"

Class nextAction();

@implementation ParticleDemo
-(id) init
{
	[super init];

	isTouchEnabled = YES;

	CGRect s = [[Director sharedDirector] winSize];
	Label* label = [Label labelWithString:[self title] dimensions:CGSizeMake(s.size.width, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: cpv(s.size.width/2, s.size.height-50)];
		
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	Scene *s = [Scene node];
	[s add: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

@implementation DemoFirework
-(void) onEnter
{
	[super onEnter];
	ParticleSystem *emitter = [ParticleFireworks node];
	[self add: emitter];	
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
	[self add: emitter];
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
	[self add: emitter];
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
	[self add: emitter];
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
	[self add: emitter];
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
	[self add: emitter];
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
	[self add: emitter];
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
	[self add: emitter];
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
	[self add: emitter];
}
-(NSString *) title
{
	return @"ParticleSmoke";
}
@end
Class nextAction()
{
	static int i=0;
	
	NSArray *transitions = [[NSArray arrayWithObjects:
								@"DemoFlower",
								@"DemoGalaxy",
								@"DemoFirework",
								@"DemoSpiral",
								@"DemoSun",
								@"DemoMeteor",
								@"DemoFire",
								@"DemoSmoke",
								@"DemoExplosion",
									nil ] retain];
	
	
	NSString *r = [transitions objectAtIndex:i++];
	i = i % [transitions count];
	Class c = NSClassFromString(r);
	return c;
}


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


@end
