//
// cocos2d for iphone
// main file
//


#import "IntervalDemo.h"


@implementation Layer1
-(id) init
{
	[super init];
		
	// sun
	ParticleSystem* sun = [ParticleSun node];
	sun.position = cpv(480-32,320-32);

	sun.totalParticles = 130;
	sun.life = 0.6;
	[self add:sun];

	// timers
	label1 = [Label labelWithString:@"0" dimensions:CGSizeMake(120,32) alignment:UITextAlignmentCenter fontName:@"Courier" fontSize:32];
	label2 = [Label labelWithString:@"0" dimensions:CGSizeMake(120,32) alignment:UITextAlignmentCenter fontName:@"Courier" fontSize:32];
	label3 = [Label labelWithString:@"0" dimensions:CGSizeMake(120,32) alignment:UITextAlignmentCenter fontName:@"Courier" fontSize:32];
	
	[self schedule: @selector(step1:) interval: 0.5];
	[self schedule: @selector(step2:) interval:1.0];
	[self schedule: @selector(step3:) interval: 1.5];
	
	label1.position = cpv(80,160);
	label2.position = cpv(240,160);
	label3.position = cpv(400,160);
	
	[self add:label1];
	[self add:label2];
	[self add:label3];
	
	// Sprite
	Sprite *sprite = [Sprite spriteFromFile:@"grossini.png"];
	sprite.position = cpv(40,50);
	
	id jump = [JumpBy actionWithDuration:3 position:cpv(400,0) height:50 jumps:4];
	
	[self add:sprite];
	[sprite do: [Repeat actionWithAction:
					[Sequence actions: jump, [jump reverse], nil]
						times:-1]
	 ];

	// pause button
	MenuItem *item1 = [MenuItemFont itemFromString: @"Pause" target:self selector:@selector(pause:)];
	Menu *menu = [Menu menuWithItems: item1, nil];
	menu.position = cpv(480/2, 270);

	[self add: menu];
		
	return self;
}

-(void) pause: (id) sender
{
	[[Director sharedDirector] pause];
	
	// Dialog
	UIAlertView* dialog = [[[UIAlertView alloc] init] retain];
	[dialog setDelegate:self];
	[dialog setTitle:@"Game Paused"];
	[dialog setMessage:@"Game paused"];
	[dialog addButtonWithTitle:@"Resume"];
	[dialog show];	
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	[[Director sharedDirector] resume];
}

-(void) step1: (ccTime) delta
{
//	time1 +=delta;
	time1 +=1;
	[label1 setString: [NSString stringWithFormat:@"%2.1f", time1] ];
}

-(void) step2: (ccTime) delta
{
//	time2 +=delta;
	time2 +=1;
	[label2 setString: [NSString stringWithFormat:@"%2.1f", time2] ];
}

-(void) step3: (ccTime) delta
{
//	time3 +=delta;
	time3 +=1;
	[label3 setString: [NSString stringWithFormat:@"%2.1f", time3] ];
}

@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setDisplayFPS:YES];
		
	Scene *scene = [Scene node];

	[scene add: [Layer1 node] z:0];

	
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
