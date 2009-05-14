//
// Scene demo
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//

#import "SceneTest.h"

@implementation Layer1
-(id) init
{
	[super init];
	
	MenuItemFont *item1 = [MenuItemFont itemFromString: @"Test pushScene" target:self selector:@selector(onPushScene:)];
	MenuItemFont *item2 = [MenuItemFont itemFromString: @"Test pushScene w/transition" target:self selector:@selector(onPushSceneTran:)];
	MenuItemFont *item3 = [MenuItemFont itemFromString: @"Quit" target:self selector:@selector(onQuit:)];
	
	Menu *menu = [Menu menuWithItems: item1, item2, item3, nil];
	[menu alignItemsVertically];
	
	[self addChild: menu];

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) onPushScene: (id) sender
{
	Scene * scene = [[Scene node] addChild: [Layer2 node] z:0];
	[[Director sharedDirector] pushScene: scene];
}

-(void) onPushSceneTran: (id) sender
{
	Scene * scene = [[Scene node] addChild: [Layer2 node] z:0];
	[[Director sharedDirector] pushScene: [SlideInTTransition transitionWithDuration:1 scene:scene]];
}


-(void) onQuit: (id) sender
{
	[[Director sharedDirector] popScene];
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
	[super init];
	
	MenuItemFont *item1 = [MenuItemFont itemFromString: @"replaceScene" target:self selector:@selector(onReplaceScene:)];
	MenuItemFont *item2 = [MenuItemFont itemFromString: @"replaceScene w/transition" target:self selector:@selector(onReplaceSceneTran:)];
	MenuItemFont *item3 = [MenuItemFont itemFromString: @"Go Back" target:self selector:@selector(onGoBack:)];
	
	Menu *menu = [Menu menuWithItems: item1, item2, item3, nil];
	[menu alignItemsVertically];
	
	[self addChild: menu];
	
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
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
	if( (self=[super initWithColor: 0x0000ffff]) ) {
		isTouchEnabled = YES;
		id label = [Label labelWithString:@"Touch to popScene" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label];
		CGSize s = [[Director sharedDirector] winSize];
		[label setPosition:ccp(s.width/2, s.height/2)];
	}
	return self;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[Director sharedDirector] popScene];
	return kEventIgnored;
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
//	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeRight];

	// attach the OpenGL view to a window
	[[Director sharedDirector] attachInView:window];
	
	// show FPS
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];	
	
	
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
