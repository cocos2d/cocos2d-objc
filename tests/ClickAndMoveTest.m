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

		CCSprite *sprite = [CCSprite spriteWithFile: @"grossini.png"];

		id layer = [CCLayerColor layerWithColor: ccc4(255,255,0,255)];
		[self addChild: layer z:-1];

		[self addChild: sprite z:0 tag:kTagSprite];
		[sprite setPosition: ccp(20,150)];

		[sprite runAction: [CCJumpTo actionWithDuration:4 position:ccp(300,48) height:100 jumps:4] ];

		[layer runAction: [CCRepeatForever actionWithAction:
									[CCSequence actions:
									[CCFadeIn actionWithDuration:1],
									[CCFadeOut actionWithDuration:1],
									nil]
						] ];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];

	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];

	CCNode *s = [self getChildByTag:kTagSprite];
	[s stopAllActions];
	[s runAction: [CCMoveTo actionWithDuration:1 position:ccp(convertedLocation.x, convertedLocation.y)]];
	float o = convertedLocation.x - [s position].x;
	float a = convertedLocation.y - [s position].y;
	float at = (float) CC_RADIANS_TO_DEGREES( atanf( o/a) );

	if( a < 0 ) {
		if(  o < 0 )
			at = 180 + abs(at);
		else
			at = 180 - abs(at);
	}

	[s runAction: [CCRotateTo actionWithDuration:1 angle: at]];
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	UIAlertView*			alertView;
	alertView = [[UIAlertView alloc] initWithTitle:@"Welcome" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Start", nil];
	[alertView setMessage:[NSString stringWithFormat:@"Click on the screen\nto move and rotate Grossini\n%@", [[UIDevice currentDevice] model]]];
	[alertView show];
	[alertView release];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Set multiple touches on
	[[director_ view] setMultipleTouchEnabled:YES];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	CCScene *scene = [CCScene node];
	MainLayer * mainLayer =[MainLayer node];
	[scene addChild: mainLayer z:2];

	[director_ pushScene: scene];

	return YES;
}
@end
