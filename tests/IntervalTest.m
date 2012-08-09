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
		CCMenuItem *item1 = [CCMenuItemFont itemWithString: @"Pause" target:self selector:@selector(pause:)];
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// run at 30 FPS
	[director_ setAnimationInterval:1/30.0f];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	return YES;
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [Layer1 node] z:0];		
		[director runWithScene: scene];
	}
}

@end
