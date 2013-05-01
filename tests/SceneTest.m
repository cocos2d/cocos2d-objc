//
// Scene demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import "SceneTest.h"

#pragma mark -
#pragma mark Layer1

@implementation Layer1
-(id) init
{
	if( (self=[super initWithColor: ccc4(0,255,0,255)]) ) {


		CCMenuItemFont *item1 = [CCMenuItemFont itemWithString: @"Test pushScene" target:self selector:@selector(onPushScene:)];
		CCMenuItemFont *item2 = [CCMenuItemFont itemWithString: @"Test pushScene w/transition" target:self selector:@selector(onPushSceneTran:)];
		CCMenuItemFont *item3 = [CCMenuItemFont itemWithString: @"Quit" target:self selector:@selector(onQuit:)];

		CCMenu *menu = [CCMenu menuWithItems: item1, item2, item3, nil];
		[menu alignItemsVertically];

		[self addChild: menu];

		CGSize s = [CCDirector sharedDirector].winSize;
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:sprite];
		sprite.position = ccp(s.width-40, s.height/2);
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id repeat = [CCRepeatForever actionWithAction:rotate];
		[sprite runAction:repeat];


		[self schedule:@selector(testDealloc:)];
	}

	return self;
}

-(void) onEnter
{
	NSLog(@"Layer1#onEnter");
	[super onEnter];
}

-(void) onEnterTransitionDidFinish
{
	NSLog(@"Layer1#onEnterTransitionDidFinish");
	[super onEnterTransitionDidFinish];
}

-(void) cleanup
{
	NSLog(@"Layer1#cleanup");
	[super cleanup];
}

-(void) testDealloc:(ccTime) dt
{
	NSLog(@"Layer1:testDealloc");
}

-(void) dealloc
{
	NSLog(@"Layer1 - dealloc");
	[super dealloc];
}

-(void) onPushScene: (id) sender
{
	CCScene * scene = [CCScene node];
	[scene addChild: [Layer2 node] z:0];
	[[CCDirector sharedDirector] pushScene: scene];
//	[[Director sharedDirector] replaceScene:scene];
}

-(void) onPushSceneTran: (id) sender
{
	CCScene * scene = [CCScene node];
	[scene addChild: [Layer2 node] z:0];
	[[CCDirector sharedDirector] pushScene: [CCTransitionSlideInT transitionWithDuration:1 scene:scene]];
}


-(void) onQuit: (id) sender
{
	// since there are no more scenes on the stack, popScene will call CCDirector#end
	[[CCDirector sharedDirector] popScene];
}

-(void) onVoid: (id) sender
{
}
@end

#pragma mark -
#pragma mark Layer2

@implementation Layer2
-(id) init
{
	if( (self=[super initWithColor: ccc4(255,0,0,255)]) ) {

		timeCounter = 0;

		CCMenuItemFont *item1 = [CCMenuItemFont itemWithString: @"replaceScene" target:self selector:@selector(onReplaceScene:)];
		CCMenuItemFont *item2 = [CCMenuItemFont itemWithString: @"replaceScene w/transition" target:self selector:@selector(onReplaceSceneTran:)];
		CCMenuItemFont *item3 = [CCMenuItemFont itemWithString: @"Go Back" target:self selector:@selector(onGoBack:)];

		CCMenu *menu = [CCMenu menuWithItems: item1, item2, item3, nil];
		[menu alignItemsVertically];

		[self addChild: menu];

		[self schedule:@selector(testDealloc:)];

		CGSize s = [CCDirector sharedDirector].winSize;
		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:sprite];
		sprite.position = ccp(40, s.height/2);
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id repeat = [CCRepeatForever actionWithAction:rotate];
		[sprite runAction:repeat];
	}

	return self;
}

-(void) dealloc
{
	NSLog(@"Layer2 - dealloc");
	[super dealloc];
}

-(void) testDealloc:(ccTime) dt
{
	NSLog(@"Layer2:testDealloc");

	timeCounter += dt;
	if( timeCounter > 10 )
		[self onReplaceScene:self];
}

-(void) onGoBack:(id) sender
{
	[[CCDirector sharedDirector] popScene];
}

-(void) onReplaceScene:(id) sender
{
	CCScene *scene = [CCScene node];
	[scene addChild: [Layer3 node] z:0];
	[[CCDirector sharedDirector] replaceScene: scene];
}
-(void) onReplaceSceneTran:(id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [Layer3 node] z:0];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFlipX transitionWithDuration:2 scene:s]];
}
@end

#pragma mark -
#pragma mark Layer3

@implementation Layer3
-(id) init
{
	if( (self=[super initWithColor: ccc4(0,0,255,255)]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCMenuItemFont *item0 = [CCMenuItemFont itemWithString:@"Touch to pushScene (self)" block:^(id sender) {
			CCScene *new = [CCScene node];
			[new addChild:[Layer3 node]];
			[[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.5 scene:new withColor:ccc3(0,255,255)] ];
		}];

		
		CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Touch to popScene" block:^(id sender) {
			[[CCDirector sharedDirector] popScene];
		}];
		
		CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Touch to popToRootScene" block:^(id sender) {
			[[CCDirector sharedDirector] popToRootScene];
		}];

		CCMenu *menu = [CCMenu menuWithItems:item0, item1, item2, nil ];
		[self addChild:menu];
		[menu alignItemsVertically];
								 
		[self schedule:@selector(testDealloc:)];

		CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:sprite];
		sprite.position = ccp(s.width/2, 40);
		id rotate = [CCRotateBy actionWithDuration:2 angle:360];
		id repeat = [CCRepeatForever actionWithAction:rotate];
		[sprite runAction:repeat];

	}
	return self;
}

- (void) dealloc
{
	NSLog(@"Layer3 - dealloc");
	[super dealloc];
}

-(void) testDealloc:(ccTime)dt
{
	NSLog(@"Layer3:testDealloc");
}
@end


#pragma mark - AppController - iOS

#if defined(__CC_PLATFORM_IOS)

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Turn on display FPS
	[director_ setDisplayStats:YES];


	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

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
		[director runWithScene:scene];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

#pragma mark - AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];
	
	CCScene *scene = [CCScene node];
	
	[scene addChild: [Layer1 node] z:0];
	
	[director_ runWithScene:scene];
}
@end
#endif

