//
// Click and Move demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import "ClickAndMoveTest.h"

enum
{
	kTagSprite = 1,
};

@implementation MainLayer
-(id) init
{
	if( ( self=[super init] ))
	{
		self.isTouchEnabled = YES;
		
		Sprite *sprite = [Sprite spriteWithFile: @"grossini.png"];
		
		id layer = [ColorLayer layerWithColor: ccc4(255,255,0,255)];
		[self addChild: layer z:-1];
			
		[self addChild: sprite z:0 tag:kTagSprite];
		[sprite setPosition: ccp(20,150)];
		
		[sprite runAction: [JumpTo actionWithDuration:4 position:ccp(300,48) height:100 jumps:4] ];
		
		[layer runAction: [RepeatForever actionWithAction: 
									[Sequence actions:
									[FadeIn actionWithDuration:1],
									[FadeOut actionWithDuration:1],
									nil]
						] ];
	}	
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

	CocosNode *s = [self getChildByTag:kTagSprite];
	[s stopAllActions];
	[s runAction: [MoveTo actionWithDuration:1 position:ccp(convertedLocation.x, convertedLocation.y)]];
	float o = convertedLocation.x - [s position].x;
	float a = convertedLocation.y - [s position].y;
	float at = (float) CC_RADIANS_TO_DEGREES( atanf( o/a) );
	
	if( a < 0 ) {
		if(  o < 0 )
			at = 180 + abs(at);
		else
			at = 180 - abs(at);	
	}
	
	[s runAction: [RotateTo actionWithDuration:1 angle: at]];
	
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
//	[Director useFastDirector];
	
	// Attach cocos2d to the window
	[[Director sharedDirector] attachInWindow:window];	
	
	// Setup the layout Propertys
//	[[Director sharedDirector] setLandscape:YES];
	
	// Show FPS, useful when debugging performance
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// Make the window visible
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
	Scene *scene = [Scene node];
	MainLayer * mainLayer =[MainLayer node];	
	[scene addChild: mainLayer z:2];
	
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
