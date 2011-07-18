//
// Bug-886
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=886
//

#import "Bug-886.h"

#pragma mark -

@implementation Layer1
-(id) init
{
	if( (self=[super init] )) {
		
		// ask director the the window size
		//		CGSize size = [[CCDirector sharedDirector] winSize];
		
		CCSprite* sprite = [CCSprite spriteWithFile:@"bugs/bug886.jpg"];
		sprite.anchorPoint = CGPointZero;
		sprite.position =  CGPointZero;
		sprite.scaleX = 0.6f;
		[self addChild: sprite];
		
		CCSprite* sprite2 = [CCSprite spriteWithFile:@"bugs/bug886.png"];
		sprite2.anchorPoint = CGPointZero;
		sprite2.scaleX = 0.6f;
		sprite2.position =  ccp( [sprite contentSize].width * 0.6f + 10, 0 );
		[self addChild: sprite2];
		
	}
	return self;
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
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
//	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

	CCScene *scene = [CCScene node];	
	[scene addChild:[Layer1 node] z:0];
			
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

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
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
