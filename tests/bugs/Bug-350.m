//
// Bug-350 
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=350
//

#import "Bug-350.h"

#pragma mark -
#pragma mark MemBug

@implementation Layer1
-(id) init
{
	if((self=[super init])) {
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"Default.png"];
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];
		
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
	// 3. Parents EAGLView to the main window
	// 4. Creates Display Link Director
	// 4a. If it fails, it will use an NSTimer director
	// 5. It will try to run at 60 FPS
	// 6. Display FPS: NO
	// 7. Device orientation: Portrait
	// 8. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	CCScene *scene = [CCScene node];	
	[scene addChild:[Layer1 node] z:0];
		
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.anchorPoint = CGPointZero;
//	CC_ENABLE_DEFAULT_GL_STATES();
//	[sprite draw];
//	CC_DISABLE_DEFAULT_GL_STATES();
//	[[[CCDirector sharedDirector] openGLView] swapBuffers];
	
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
	[window dealloc];
	[super dealloc];
}

@end
