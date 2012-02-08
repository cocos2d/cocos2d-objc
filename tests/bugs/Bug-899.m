//
// Bug-899
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=899
//
// Test coded by: JohnnyFlash
//

#import "Bug-899.h"

#pragma mark -

@implementation Layer1
-(id) init
{
	if( (self=[super init] )) {

		CCSprite *bg = [CCSprite spriteWithFile:@"bugs/RetinaDisplay.jpg"];
		[self addChild:bg z:0];
		bg.anchorPoint = CGPointZero;
	}
	return self;
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	[director_ setProjection:kCCDirectorProjection2D];

	[director_ setAnimationInterval:1.0/60];


	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// create scene
	CCScene *scene = [CCScene node];
	CCLayer *layer = [Layer1 node];
	[scene addChild:layer];

	[director_ pushScene:scene];

	return YES;
}
@end
