//
// Interval Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//


#import "IntervalTest.h"


@implementation Layer1
-(id) init
{
	if( (self=[super init])) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		// sun
		CCParticleSystem* sun = [CCParticleSun node];
		sun.position = ccp(s.width-32,s.height-32);

		sun.totalParticles = 130;
		sun.life = 0.6f;
		[self addChild:sun];

		// timers
		label0 = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapFontTest4.fnt"];
		label1 = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapFontTest4.fnt"];
		label2 = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapFontTest4.fnt"];
		label3 = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapFontTest4.fnt"];
		label4 = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapFontTest4.fnt"];
		
		[self scheduleUpdate];
		[self schedule: @selector(step1:)];
		[self schedule: @selector(step2:) interval:0];
		[self schedule: @selector(step3:) interval:1.0f];
		[self schedule: @selector(step4:) interval: 2.0f];
		
		label0.position = ccp(s.width*1/6,s.height/2);
		label1.position = ccp(s.width*2/6,s.height/2);
		label2.position = ccp(s.width*3/6,s.height/2);
		label3.position = ccp(s.width*4/6,s.height/2);
		label4.position = ccp(s.width*5/6,s.height/2);

		[self addChild:label0];
		[self addChild:label1];
		[self addChild:label2];
		[self addChild:label3];
		[self addChild:label4];
		
		// Sprite
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		sprite.position = ccp(40,50);
		
		id jump = [CCJumpBy actionWithDuration:3 position:ccp(s.width-80,0) height:50 jumps:4];
		
		[self addChild:sprite];
		[sprite runAction: [CCRepeatForever actionWithAction:
						[CCSequence actions: jump, [jump reverse], nil]
							]
		 ];

		// pause button
		CCMenuItem *item1 = [CCMenuItemFont itemFromString: @"Pause" target:self selector:@selector(pause:)];
		CCMenu *menu = [CCMenu menuWithItems: item1, nil];
		menu.position = ccp(s.width/2, s.height-50);

		[self addChild: menu];
	}
		
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) pause: (id) sender
{
	[[CCDirector sharedDirector] pause];
	
	// Dialog
	UIAlertView* dialog = [[UIAlertView alloc] init];
	[dialog setDelegate:self];
	[dialog setTitle:@"Game Paused"];
	[dialog setMessage:@"Game paused"];
	[dialog addButtonWithTitle:@"Resume"];
	[dialog show];	
	[dialog release];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	[[CCDirector sharedDirector] resume];
}

-(void) update: (ccTime) delta
{
	time0 +=delta;
	[label0 setString: [NSString stringWithFormat:@"%2.1f", time0] ];
}

-(void) step1: (ccTime) delta
{
	time1 +=delta;
	[label1 setString: [NSString stringWithFormat:@"%2.1f", time1] ];
}

-(void) step2: (ccTime) delta
{
	time2 +=delta;
	[label2 setString: [NSString stringWithFormat:@"%2.1f", time2] ];
}

-(void) step3: (ccTime) delta
{
	time3 +=delta;
	[label3 setString: [NSString stringWithFormat:@"%2.1f", time3] ];
}

-(void) step4: (ccTime) delta
{
	time4 +=delta;
	[label4 setString: [NSString stringWithFormat:@"%2.1f", time4] ];
}

@end

// CLASS IMPLEMENTATIONS
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
	
	// run at 30 FPS
	[director setAnimationInterval:1/30.0f];
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	CCScene *scene = [CCScene node];

	[scene addChild: [Layer1 node] z:0];

	[director runWithScene: scene];
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

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
