//
// Font Test
// a cocos2d example
//
// Example by Maarten Billemont (lhunath)

// cocos2d import
#import "cocos2d.h"

// local import
#import "FontTest.h"

#pragma mark Demo - Font

enum {
	kTagLabel1,
	kTagLabel2,
	kTagLabel3,
	kTagLabel4,

};

static int fontIdx=0;
static NSString *fontList[] =
{
	@"American Typewriter",
	@"Marker Felt",
	@"A Damn Mess",
	@"Abberancy",
	@"Abduction",
	@"Paint Boy",
	@"Schwarzwald Regular",
	@"Scissor Cuts",
};


NSString* nextAction(void);
NSString* backAction(void);
NSString* restartAction(void);


NSString* nextAction()
{	
	fontIdx++;
	fontIdx = fontIdx % ( sizeof(fontList) / sizeof(fontList[0]) );
	return fontList[fontIdx];
}

NSString* backAction()
{
	fontIdx--;
	if( fontIdx < 0 )
		fontIdx += ( sizeof(fontList) / sizeof(fontList[0]) );
	return fontList[fontIdx];
}

NSString* restartAction()
{
	return fontList[fontIdx];
}

@implementation FontTest
-(id) init
{
	if((self=[super init] )) {
    
		// menu
		CGSize size = [CCDirector sharedDirector].winSize;
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(size.width/2-100,30);
		item2.position = ccp(size.width/2, 30);
		item3.position = ccp(size.width/2+100,30);
		[self addChild: menu z:1];
		
		[self performSelector:@selector(restartCallback:) withObject:self afterDelay:0.1];
	}
    
	return self;
}

- (void)showFont:(NSString *)aFont
{
	
	[self removeChildByTag:kTagLabel1 cleanup:YES];
	[self removeChildByTag:kTagLabel2 cleanup:YES];
	[self removeChildByTag:kTagLabel3 cleanup:YES];
	[self removeChildByTag:kTagLabel4 cleanup:YES];
    
	
	CCLabelTTF *top = [CCLabelTTF labelWithString:aFont fontName:aFont fontSize:24];
	CCLabelTTF *left = [CCLabelTTF labelWithString:@"alignment left" dimensions:CGSizeMake(480,50) alignment:CCTextAlignmentLeft fontName:aFont fontSize:32];
	CCLabelTTF *center = [CCLabelTTF labelWithString:@"alignment center" dimensions:CGSizeMake(480,50) alignment:CCTextAlignmentCenter fontName:aFont fontSize:32];
	CCLabelTTF *right = [CCLabelTTF labelWithString:@"alignment right" dimensions:CGSizeMake(480,50) alignment:CCTextAlignmentRight fontName:aFont fontSize:32];

	CGSize s = [[CCDirector sharedDirector] winSize];
	
	top.position = ccp(s.width/2,250);
	left.position = ccp(s.width/2,200);
	center.position = ccp(s.width/2,150);
	right.position = ccp(s.width/2,100);
	
	[self addChild:left z:0 tag:kTagLabel1];
	[self addChild:right z:0 tag:kTagLabel2];
	[self addChild:center z:0 tag:kTagLabel3];
	[self addChild:top z:0 tag:kTagLabel4];
	
//    label = [[Label alloc] initWithString:"This is a test: left" fontName:aFont fontSize:30];
//    label.color = ccc3(0xff, 0xff, 0xff);
//    label.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
	
//	NSLog(@"s: %f, t:%f", [[label texture] maxS], [[label texture] maxT]);
//	[[label texture] setMaxS:1];
//	[[label texture] setMaxT:1];	
}

-(void) nextCallback:(id) sender
{
    [self showFont:nextAction()];
}	

-(void) backCallback:(id) sender
{
    [self showFont:backAction()];
}	

-(void) restartCallback:(id) sender
{
    [self showFont:restartAction()];
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
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	CCScene *scene = [CCScene node];
	[scene addChild: [FontTest node]];
	
	[director runWithScene: scene];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
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

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}


// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
