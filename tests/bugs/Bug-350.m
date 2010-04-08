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
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];

	CCDirector *director = [CCDirector sharedDirector];
	
	// before creating any layer, set the landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
	
	// show FPS
	[director setDisplayFPS:YES];
	
	// frames per second
	[director setAnimationInterval:1.0/60];	
	
	// attach cocos2d to a window
	[director attachInView:window];
	
	CCScene *scene = [CCScene node];	
	[scene addChild:[Layer1 node] z:0];
	
	[window makeKeyAndVisible];
	
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.anchorPoint = CGPointZero;
//	CC_ENABLE_DEFAULT_GL_STATES();
//	[sprite draw];
//	CC_DISABLE_DEFAULT_GL_STATES();
//	[[[CCDirector sharedDirector] openGLView] swapBuffers];
	
	[[CCDirector sharedDirector] runWithScene: scene];
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
