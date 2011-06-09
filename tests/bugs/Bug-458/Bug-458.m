//
// Bug-458 test case by nedrafehi
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=458
//

#import "Bug-458.h"
#import "QuestionContainerSprite.h"

#pragma mark -
#pragma mark MemBug
@implementation Layer1
-(id) init
{
	if((self=[super init])) {
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        QuestionContainerSprite* question = [[QuestionContainerSprite alloc] init];
        QuestionContainerSprite* question2 = [[QuestionContainerSprite alloc] init];
        
//		[question setContentSize:CGSizeMake(50,50)];
//		[question2 setContentSize:CGSizeMake(50,50)];
		
        CCMenuItemSprite* sprite = [CCMenuItemSprite itemFromNormalSprite:question2 selectedSprite:question target:self selector:@selector(selectAnswer:)];
        
        CCLayerColor* layer = [CCLayerColor layerWithColor:ccc4(0,0,255,255) width:100 height:100];
		
		[question release];
		[question2 release];
	
        CCLayerColor* layer2 = [CCLayerColor layerWithColor:ccc4(255,0,0,255) width:100 height:100];
		
        CCMenuItemSprite* sprite2 = [CCMenuItemSprite itemFromNormalSprite:layer selectedSprite:layer2 target:self selector:@selector(selectAnswer:)];        
        CCMenu* menu = [CCMenu menuWithItems:sprite, sprite2, nil];
        [menu alignItemsVerticallyWithPadding:100];
        
        [menu setPosition:ccp(size.width / 2, size.height / 2)];
		
		// add the label as a child to this Layer
		[self addChild: menu];
	}
	return self;
}

-(void)selectAnswer:(id)sender
{
    CCLOG(@"Selected");
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
	[window dealloc];
	[super dealloc];
}

@end
