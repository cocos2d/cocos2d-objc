//
// Bug-422 test case by lhunath
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=422
//

#import "Bug-422.h"

#pragma mark -
#pragma mark MemBug
@implementation Layer1
-(id) init
{
	if((self=[super init])) {
		[self reset];
	}
    
	return self;
}


-(void) reset {
	
	static int localtag = 0;
	localtag++;
	
	// TO TRIGGER THE BUG:
	// remove the itself from parent from an action
	// The menu will be removed, but the instance will be alive
	// and then a new node will be allocated occupying the memory.
	// => CRASH BOOM BANG
	CCNode *node = [self getChildByTag:localtag-1];
	NSLog(@"Menu: %@", node);
	[self removeChild:node cleanup:NO];
//	[self removeChildByTag:localtag-1 cleanup:NO];
	
	CCMenuItem *item1 = [CCMenuItemFont itemFromString: @"One"
                                            target: self selector:@selector(menuCallback:)];
	NSLog(@"MenuItemFont: %@", item1);
    CCMenuItem *item2 = [CCMenuItemFont itemFromString: @"Two"
                                            target: self selector:@selector(menuCallback:)];
    
    CCMenu *menu = [CCMenu menuWithItems: item1, item2, nil];
	[menu alignItemsVertically];
	
	float x = CCRANDOM_0_1() * 50;
	float y = CCRANDOM_0_1() * 50;

	menu.position = ccpAdd( menu.position, ccp(x,y));
	
	
    [self addChild: menu z:0 tag:localtag];	
	
    //[self check:self];
}

-(void) check:(CCNode *)t {
	
	CCArray *array = [t children];
    for (CCNode *node in array) {
        NSLog(@"0x%x, rc: %d", (unsigned int)node, [node retainCount]);
        [self check:node];
    }
}

-(void) menuCallback: (id) sender
{
	[self reset];
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
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];	
	
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
