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
	CocosNode *node = [self getChildByTag:localtag-1];
	NSLog(@"Menu: %@", node);
	[self removeChild:node cleanup:NO];
//	[self removeChildByTag:localtag-1 cleanup:NO];
	
    MenuItem *item1 = [MenuItemFont itemFromString: @"One"
                                            target: self selector:@selector(menuCallback:)];
	NSLog(@"MenuItemFont: %@", item1);
    MenuItem *item2 = [MenuItemFont itemFromString: @"Two"
                                            target: self selector:@selector(menuCallback:)];
    
    Menu *menu = [Menu menuWithItems: item1, item2, nil];
	[menu alignItemsVertically];
	
	float x = CCRANDOM_0_1() * 50;
	float y = CCRANDOM_0_1() * 50;

	menu.position = ccpAdd( menu.position, ccp(x,y));
	
	
    [self addChild: menu z:0 tag:localtag];	
	
    //[self check:self];
}

-(void) check:(CocosNode *)t {
	
	NSArray *array = [t children];
    for (CocosNode *node in array) {
        NSLog(@"0x%x, rc: %d", node, [node retainCount]);
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
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
	//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeRight];
	
	// show FPS
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// multiple touches or not ?
	//	[[Director sharedDirector] setMultipleTouchEnabled:YES];
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];	
	
	// attach cocos2d to a window
	[[Director sharedDirector] attachInView:window];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
	Scene *scene = [Scene node];
	
	[scene addChild:[Layer1 node] z:0];
	
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
	[window dealloc];
	[super dealloc];
}

@end
