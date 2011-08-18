//
// Sprite Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "FullScreenTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {	
	
	@"FullScreenScale",
	@"FullScreenNoScale",
	@"FullScreenIssue1071Test",

};

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark -
#pragma mark FullScreenDemo

@implementation FullScreenDemo
-(id) init
{
	if( (self = [super init]) ) {


		CGSize s = [[CCDirector sharedDirector] winSize];
			
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:26];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];

		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];	
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}

-(NSString*) subtitle
{
	return nil;
}
@end

#pragma mark -
#pragma mark FullScreenScale


@implementation FullScreenScale

-(id) init
{
	if( (self=[super init]) ) {
		
		CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
		[director setResizeMode:kCCDirectorResize_AutoScale];
		
		self.isMouseEnabled = YES;
		
		CGSize s = [director winSize];
		[self addNewSpriteWithCoords:ccp(50,50)];
		
		CCMenuItemFont *item = [CCMenuItemFont itemFromString:@"Toggle Fullscreen" target: self selector:@selector(toggleFullScreen:)];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		
		[menu setPosition:ccp(s.width/2, s.height/2)];
	}	
	return self;
}

-(void) toggleFullScreen:(id)sender
{
	CCDirectorMac *mac = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[mac setFullScreen: ! [mac isFullScreen]];
}
								
-(void) addNewSpriteWithCoords:(CGPoint)p
{
	int idx = CCRANDOM_0_1() * 1400 / 100;
	int x = (idx%5) * 85;
	int y = (idx/5) * 121;
	
	
	CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(x,y,85,121)];
	[self addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	id action;
	float rand = CCRANDOM_0_1();
	
	if( rand < 0.20 )
		action = [CCScaleBy actionWithDuration:3 scale:2];
	else if(rand < 0.40)
		action = [CCRotateBy actionWithDuration:3 angle:360];
	else if( rand < 0.60)
		action = [CCBlink actionWithDuration:1 blinks:3];
	else if( rand < 0.8 )
		action = [CCTintBy actionWithDuration:2 red:0 green:-255 blue:-255];
	else 
		action = [CCFadeOut actionWithDuration:2];
	id action_back = [action reverse];
	id seq = [CCSequence actions:action, action_back, nil];
	
	[sprite runAction: [CCRepeatForever actionWithAction:seq]];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteWithCoords: location];
	}
}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	[self addNewSpriteWithCoords: location];
	
	return YES;
}
#endif

-(NSString *) title
{
	return @"FullScreen Scale (tap screen)";
}

-(NSString *) subtitle
{
	return @"Screen should be scaled";
}

@end

#pragma mark -
#pragma mark FullScreenNoScale


@implementation FullScreenNoScale

-(id) init
{
	if( (self=[super init]) ) {
		
		CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
		[director setResizeMode:kCCDirectorResize_NoScale];

		self.isMouseEnabled = YES;
		
		CGSize s = [director winSize];
		[self addNewSpriteWithCoords:ccp(50,50)];
		
		CCMenuItemFont *item = [CCMenuItemFont itemFromString:@"Toggle Fullscreen" target: self selector:@selector(toggleFullScreen:)];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		
		[menu setPosition:ccp(s.width/2, s.height/2)];
	}	
	return self;
}

-(void) toggleFullScreen:(id)sender
{
	CCDirectorMac *mac = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[mac setFullScreen: ! [mac isFullScreen]];
}

-(void) addNewSpriteWithCoords:(CGPoint)p
{
	int idx = CCRANDOM_0_1() * 1400 / 100;
	int x = (idx%5) * 85;
	int y = (idx/5) * 121;
	
	
	CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(x,y,85,121)];
	[self addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	id action;
	float rand = CCRANDOM_0_1();
	
	if( rand < 0.20 )
		action = [CCScaleBy actionWithDuration:3 scale:2];
	else if(rand < 0.40)
		action = [CCRotateBy actionWithDuration:3 angle:360];
	else if( rand < 0.60)
		action = [CCBlink actionWithDuration:1 blinks:3];
	else if( rand < 0.8 )
		action = [CCTintBy actionWithDuration:2 red:0 green:-255 blue:-255];
	else 
		action = [CCFadeOut actionWithDuration:2];
	id action_back = [action reverse];
	id seq = [CCSequence actions:action, action_back, nil];
	
	[sprite runAction: [CCRepeatForever actionWithAction:seq]];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteWithCoords: location];
	}
}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	[self addNewSpriteWithCoords: location];
	
	return YES;
	
}
#endif

-(NSString *) title
{
	return @"FullScreen No Scale (tap screen)";
}

-(NSString *) subtitle
{
	return @"Screen should not be scaled";
}

@end

#pragma mark -
#pragma mark Issue1071

@implementation FullScreenIssue1071Test

-(id) init
{
	if( (self=[super init]) ) {
		
		CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
		[director setResizeMode:kCCDirectorResize_NoScale];
		
		self.isMouseEnabled = YES;
		
		CGSize s = [director winSize];
		
		CCMenuItemFont *item = [CCMenuItemFont itemFromString:@"Toggle Fullscreen" target: self selector:@selector(toggleFullScreen:)];
		issueTestItem_ = [CCMenuItemFont itemFromString:@"Load something async in Fullscreen" target: self selector:@selector(loadSomethingAsyncInFullscreen:)];
		[issueTestItem_ setIsEnabled:[director isFullScreen]];
		
		CCMenu *menu = [CCMenu menuWithItems:item, issueTestItem_, nil];
		[menu alignItemsVertically];
		[self addChild:menu];
		
		[menu setPosition:ccp(s.width/2, s.height/2)];
	}	
	return self;
}

-(void) toggleFullScreen:(id)sender
{
	CCDirectorMac *mac = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[mac setFullScreen: ! [mac isFullScreen]];
	
	
	[issueTestItem_ setIsEnabled:[mac isFullScreen]];
};

- (void) loadSomethingAsyncInFullscreen: (id) sender
{
	CCDirectorMac *mac = (CCDirectorMac*) [CCDirector sharedDirector];
	if ([mac isFullScreen])
	{
		[[CCTextureCache sharedTextureCache] addImageAsync:@"blocks.png" 
													target:self 
												  selector:@selector(loadedNewTexture:)];
	}	
}

- (void) loadedNewTexture: (CCTexture2D *) aTex
{
	CCSprite *sprite = [CCSprite spriteWithTexture: aTex];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	[sprite setPosition:ccp(s.width/2, 3.0f * s.height / 4.0f)];
	[self addChild:sprite];
}

-(NSString *) title
{
	return @"FullScreen Issue #1071 test";
}

-(NSString *) subtitle
{
	return @"There should be no white squares in any modes.";
}


@end

#pragma mark -
#pragma mark AppDelegate

// CLASS IMPLEMENTATIONS

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// must be called before any othe call to the director
	[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];
//	[CCDirector setDirectorType:kCCDirectorTypeThreadMainLoop];
	
	// before creating any layer, set the landscape mode
	CCDirector *director = [CCDirector sharedDirector];
	
	// landscape orientation
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// set FPS at 60
	[director setAnimationInterval:1.0/60];
	
	// Display FPS: yes
	[director setDisplayFPS:YES];

	// Create an EAGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// attach the openglView to the director
	[director setOpenGLView:glView];

	// 2D projection
//	[director setProjection:kCCDirectorProjection2D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// make the OpenGLView a child of the main window
	[window addSubview:glView];
	
	// make main window visible
	[window makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];	
	
	// create the main scene
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	
	// and run it!
	[director runWithScene: scene];
	
	return YES;
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

- (void)applicationWillTerminate:(UIApplication *)application
{	
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	[director end];
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

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end

#pragma mark -
#pragma mark AppController - Mac

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
	[self toggleFullScreen:self];

	
	//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
//	[director setProjection:kCCDirectorProjection2D];
	
	[director runWithScene:scene];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
#endif
