//
// Scene demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import "SceneTest.h"

@implementation Layer1
-(id) init
{
	if((self=[super init])) {
	
		MenuItemFont *item1 = [MenuItemFont itemFromString: @"Test pushScene" target:self selector:@selector(onPushScene:)];
		MenuItemFont *item2 = [MenuItemFont itemFromString: @"Test pushScene w/transition" target:self selector:@selector(onPushSceneTran:)];
		MenuItemFont *item3 = [MenuItemFont itemFromString: @"Quit" target:self selector:@selector(onQuit:)];
		
		Menu *menu = [Menu menuWithItems: item1, item2, item3, nil];
		[menu alignItemsVertically];
		
		[self addChild: menu];
		
		[self schedule:@selector(testDealloc:)];
	}

	return self;
}

-(void) testDealloc:(ccTime) dt
{
//	[self unschedule:_cmd];
}

-(void) dealloc
{
	NSLog(@"Layer1 - dealloc");
	[super dealloc];
}

-(void) onPushScene: (id) sender
{
	Scene * scene = [[Scene node] addChild: [Layer2 node] z:0];
	[[Director sharedDirector] pushScene: scene];
//	[[Director sharedDirector] replaceScene:scene];
}

-(void) onPushSceneTran: (id) sender
{
	Scene * scene = [[Scene node] addChild: [Layer2 node] z:0];
	[[Director sharedDirector] pushScene: [SlideInTTransition transitionWithDuration:1 scene:scene]];
}


-(void) onQuit: (id) sender
{
	[[Director sharedDirector] popScene];

	// HA HA... no more terminate on sdk v3.0
	// http://developer.apple.com/iphone/library/qa/qa2008/qa1561.html
	if( [[UIApplication sharedApplication] respondsToSelector:@selector(terminate)] )
		[[UIApplication sharedApplication] performSelector:@selector(terminate)];
}

-(void) onVoid: (id) sender
{
}
@end

@implementation Layer2
-(id) init
{
	if((self=[super init])) {
	
		timeCounter = 0;

		MenuItemFont *item1 = [MenuItemFont itemFromString: @"replaceScene" target:self selector:@selector(onReplaceScene:)];
		MenuItemFont *item2 = [MenuItemFont itemFromString: @"replaceScene w/transition" target:self selector:@selector(onReplaceSceneTran:)];
		MenuItemFont *item3 = [MenuItemFont itemFromString: @"Go Back" target:self selector:@selector(onGoBack:)];
		
		Menu *menu = [Menu menuWithItems: item1, item2, item3, nil];
		[menu alignItemsVertically];
		
		[self addChild: menu];
		
		[self schedule:@selector(testDealloc:)];
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
	timeCounter += dt;
	if( timeCounter > 10 )
		[self onReplaceScene:self];
}

-(void) onGoBack:(id) sender
{
	[[Director sharedDirector] popScene];
}

-(void) onReplaceScene:(id) sender
{
	[[Director sharedDirector] replaceScene: [ [Scene node] addChild: [Layer3 node] z:0] ];
}
-(void) onReplaceSceneTran:(id) sender
{
	Scene *s = [[Scene node] addChild: [Layer3 node] z:0];
	[[Director sharedDirector] replaceScene: [FlipXTransition transitionWithDuration:2 scene:s]];
}
@end

@implementation Layer3
-(id) init
{
	if( (self=[super initWithColor: ccc4(0,0,255,255)]) ) {
		self.isTouchEnabled = YES;
		id label = [Label labelWithString:@"Touch to popScene" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label];
		CGSize s = [[Director sharedDirector] winSize];
		[label setPosition:ccp(s.width/2, s.height/2)];
		
		[self schedule:@selector(testDealloc:)];
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
}
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[Director sharedDirector] popScene];
	return kEventHandled;
}
@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeRight];

	// attach the OpenGL view to a window
	[[Director sharedDirector] attachInView:window];
	
	// show FPS
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];	
	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	Scene *scene = [Scene node];

	[scene addChild: [Layer1 node] z:0];
	
	[window makeKeyAndVisible];

	[[Director sharedDirector] runWithScene: scene];
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

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
