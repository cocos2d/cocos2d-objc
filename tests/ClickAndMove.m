//
// cocos2d for iphone
// main file
//

#import "ClickAndMove.h"

#import "OpenGL_Internal.h"

enum
{
	kTagSprite = 0xaabbccdd,
};

@implementation MainLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	
	isTouchEnabled = YES;
	
	Sprite *sprite = [Sprite spriteWithFile: @"grossini.png"];
	
	id layer = [ColorLayer layerWithColor: 0xffff00ff];
	[self add: layer z:-1];
		
	[self add: sprite z:0 tag:kTagSprite];
	[sprite setPosition: cpv(20,150)];
	
	[sprite do: [JumpTo actionWithDuration:4 position:cpv(300,48) height:100 jumps:4] ];
	
	[layer do: [RepeatForever actionWithAction: 
								[Sequence actions:
								[FadeIn actionWithDuration:1],
								[FadeOut actionWithDuration:1],
								nil]
					] ];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[Director sharedDirector] convertCoordinate:location];

	CocosNode *s = [self getByTag:kTagSprite];
	[s stopAllActions];
	[s do: [MoveTo actionWithDuration:1 position:cpv(convertedLocation.x, convertedLocation.y)]];
	float o = convertedLocation.x - [s position].x;
	float a = convertedLocation.y - [s position].y;
	float at = RADIANS_TO_DEGREES( atan(o/a) );
	
	if( a < 0 )
		if(  o < 0 )
			at = 180 + abs(at);
		else
			at = 180 - abs(at);	
	
	[s do: [RotateTo actionWithDuration:1 angle: at]];
	
	return kEventHandled;
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	
	UIAlertView*			alertView;
	alertView = [[UIAlertView alloc] initWithTitle:@"Welcome" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Start", nil];
	[alertView setMessage:[NSString stringWithFormat:@"Click on the screen\nto move and rotate Grossini", [[UIDevice currentDevice] model]]];
	[alertView show];
	[alertView release];

	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
	
	// must be called before any othe call to the director
	// FastDirector is faster, but consumes more battery
//	[Director useFastDirector];
	
	// Attach cocos2d to the window
	[[Director sharedDirector] attachInWindow:window];	
	
	// Setup the layout Propertys
//	[[Director sharedDirector] setLandscape:YES];
	
	// Show FPS, useful when debugging performance
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// Make the window visible
	[window makeKeyAndVisible];
	
	Scene *scene = [Scene node];
	MainLayer * mainLayer =[MainLayer node];	
	[scene add: mainLayer z:2];
	
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

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
