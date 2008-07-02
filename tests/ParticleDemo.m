//
// Sprites Demo
// a cocos2d example
//

// cocos2d imports
#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Label.h"
#import "Particle.h"

// local import
#import "ParticleDemo.h"

Class nextAction();

@implementation ParticleDemo
-(id) init
{
	[super init];

	isEventHandler = YES;

	CGRect s = [[Director sharedDirector] winSize];
	Label* label = [Label labelWithString:[self title] dimensions:CGSizeMake(s.size.width, 40) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	[self add: label];
	[label setPosition: CGPointMake(s.size.width/2, s.size.height-50)];
		
	return self;
}

-(void) onExit
{
	[super onExit];
	[emitter release];
	emitter = nil;
}

-(void) draw
{
	[emitter update];
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

@implementation ParticleFirework
-(void) onEnter
{
	[super onEnter];
	emitter = [[EmitFireworks2 alloc] init];
}
-(NSString *) title
{
	return @"EmitFireworks";
}
@end

@implementation ParticleFire
-(void) onEnter
{
	[super onEnter];
	emitter = [[EmitFire alloc] init];
}
-(NSString *) title
{
	return @"EmitFire";
}
@end

@implementation ParticleSun
-(void) onEnter
{
	[super onEnter];
	emitter = [[EmitSun alloc] init];
}
-(NSString *) title
{
	return @"EmitSun";
}
@end

Class nextAction()
{
	static int i=0;
	
	NSArray *transitions = [[NSArray arrayWithObjects:
								@"ParticleFirework",
								@"ParticleFire",
								@"ParticleSun",
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
	[[Director sharedDirector] setFPS: YES];

	Scene *scene = [Scene node];
	[scene add: [nextAction() node]];
			 
	[[Director sharedDirector] runScene: scene];
}

@end
