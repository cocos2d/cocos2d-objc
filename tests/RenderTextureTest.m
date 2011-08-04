//
// RenderTexture Demo
// a cocos2d example
//
// Test #1 by Jason Booth (slipster216)
// Test #3 by David Deaco (ddeaco)

// cocos import
#import "RenderTextureTest.h"

static int sceneIdx=-1;
static NSString *tests[] = {	
	@"RenderTextureSave",
	@"RenderTextureIssue937",
	@"RenderTextureZbuffer",
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(tests) / sizeof(tests[0]) );
	NSString *r = tests[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(tests) / sizeof(tests[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = tests[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = tests[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}


#pragma mark -
#pragma mark RenderTextureTest

@implementation RenderTextureTest
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
	return @"";
}
@end

#pragma mark -
#pragma mark RenderTextureSave

@implementation RenderTextureSave
-(id) init
{
	if( (self = [super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];	
		
		// create a render texture, this is what we're going to draw into
		target = [[CCRenderTexture renderTextureWithWidth:s.width height:s.height] retain];
		[target setPosition:ccp(s.width/2, s.height/2)];
		
		
		// It's possible to modify the RenderTexture blending function by
//		[[target sprite] setBlendFunc:(ccBlendFunc) {GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
		
		// note that the render texture is a CCNode, and contains a sprite of its texture for convience,
		// so we can just parent it to the scene like any other CCNode
		[self addChild:target z:-1];
		
		// create a brush image to draw into the texture with
		brush = [[CCSprite spriteWithFile:@"fire.png"] retain];
		[brush setOpacity:20];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
		lastLocation = CGPointMake( s.width/2, s.height/2);
#endif
		
		// Save Image menu
		[CCMenuItemFont setFontSize:16];
		CCMenuItem *item1 = [CCMenuItemFont itemFromString:@"Save Image" target:self selector:@selector(saveImage:)];
		CCMenuItem *item2 = [CCMenuItemFont itemFromString:@"Clear" target:self selector:@selector(clearImage:)];
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, nil];
		[self addChild:menu];
		[menu alignItemsVertically];
		[menu setPosition:ccp(s.width-80, s.height-30)];
	}
	return self;
}

-(NSString*) title
{
	return @"Touch the screen";
}

-(NSString*) subtitle
{
	return @"Press 'Save Image' to create an snapshot of the render texture";
}

-(void) clearImage:(id)sender
{
	[target clear:CCRANDOM_0_1() g:CCRANDOM_0_1() b:CCRANDOM_0_1() a:CCRANDOM_0_1()];
}

-(void) saveImage:(id)sender
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	static int counter=0;
	
	NSString *str = [NSString stringWithFormat:@"image-%d.png", counter];
	[target saveBuffer:str format:kCCImageFormatPNG];
	NSLog(@"Image saved: %@", str);
	
	counter++;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	NSLog(@"CCRenderTexture Save is not supported yet");
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED
}

-(void) dealloc
{
	[brush release];
	[target release];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[super dealloc];	
}


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint start = [touch locationInView: [touch view]];	
	start = [[CCDirector sharedDirector] convertToGL: start];
	CGPoint end = [touch previousLocationInView:[touch view]];
	end = [[CCDirector sharedDirector] convertToGL:end];
	
	// begin drawing to the render texture
	[target begin];
	
	// for extra points, we'll draw this smoothly from the last position and vary the sprite's
	// scale/rotation/offset
	float distance = ccpDistance(start, end);
	if (distance > 1)
	{
		int d = (int)distance;
		for (int i = 0; i < d; i++)
		{
			float difx = end.x - start.x;
			float dify = end.y - start.y;
			float delta = (float)i / distance;
			[brush setPosition:ccp(start.x + (difx * delta), start.y + (dify * delta))];
			[brush setRotation:rand()%360];
			float r = ((float)(rand()%50)/50.f) + 0.25f;
			[brush setScale:r];
			[brush setColor:ccc3(CCRANDOM_0_1()*127+128, 255, 255) ];
			// Call visit to draw the brush, don't call draw..
			[brush visit];
		}
	}
	// finish drawing and return context back to the screen
	[target end];	
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

-(BOOL) ccMouseDown:(NSEvent *)event
{
	lastLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	return YES;
}

-(BOOL) ccMouseDragged:(NSEvent *)event
{
	CGPoint currentLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	
	CGPoint start = currentLocation;
	CGPoint end = lastLocation;
	
	// begin drawing to the render texture
	[target begin];
	
	// for extra points, we'll draw this smoothly from the last position and vary the sprite's
	// scale/rotation/offset
	float distance = ccpDistance(start, end);
	if (distance > 1)
	{
		int d = (int)distance;
		for (int i = 0; i < d; i++)
		{
			float difx = end.x - start.x;
			float dify = end.y - start.y;
			float delta = (float)i / distance;
			[brush setPosition:ccp(start.x + (difx * delta), start.y + (dify * delta))];
			[brush setRotation:rand()%360];
			float r = ((float)(rand()%50)/50.f) + 0.25f;
			[brush setScale:r];

			// Call visit to draw the brush, don't call draw..
			[brush visit];
		}
	}
	// finish drawing and return context back to the screen
	[target end];
	
	lastLocation = currentLocation;
	
	// swallow the event. Don't propagate it
	return YES;
	
}
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED
@end

#pragma mark -
#pragma mark RenderTextureIssue937

@implementation RenderTextureIssue937

-(id) init
{
	/*
	 *     1    2
	 * A: A1   A2
	 *
	 * B: B1   B2
	 *
	 *  A1: premulti sprite
	 *  A2: premulti render
	 *
	 *  B1: non-premulti sprite
	 *  B2: non-premulti render
	 */
	if( (self=[super init]) ) {
		
		CCLayerColor *background = [CCLayerColor layerWithColor:ccc4(200,200,200,255)];
		[self addChild:background];
		
		// A1
		CCSprite *spr_premulti = [CCSprite spriteWithFile:@"fire.png"];
		[spr_premulti setPosition:ccp(16,48)];

		// B1
		CCSprite *spr_nonpremulti = [CCSprite spriteWithFile:@"fire_rgba8888.pvr"];
		[spr_nonpremulti setPosition:ccp(16,16)];


		/* A2 & B2 setup */
		CCRenderTexture *rend = [CCRenderTexture renderTextureWithWidth:32 height:64];
		
		// It's possible to modify the RenderTexture blending function by
//		[[rend sprite] setBlendFunc:(ccBlendFunc) {GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];

		[rend begin];
		
		// A2
		[spr_premulti visit];
		
		// B2
		[spr_nonpremulti visit];
		[rend end]; 
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		/* A1: setup */
		[spr_premulti setPosition:ccp(s.width/2-16, s.height/2+16)];
		/* B1: setup */
		[spr_nonpremulti setPosition:ccp(s.width/2-16, s.height/2-16)];
		
		[rend setPosition:ccp(s.width/2+16, s.height/2)];
		
		[self addChild:spr_nonpremulti];
		[self addChild:spr_premulti];
		[self addChild:rend];
	}
	
	return self;
}
-(NSString*) title
{
	return @"Testing issue #937";
}

-(NSString*) subtitle
{
	return @"All images should be equal...";
}
@end

#pragma mark -
#pragma mark RenderTextureZbuffer

@implementation RenderTextureZbuffer

-(id) init
{
	if( (self=[super init] )) {
		self.isTouchEnabled = YES;
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"vertexZ = 50" fontName:@"Marker Felt" fontSize:64];
		label.position =  ccp( size.width /2 , size.height*0.25f );
		[self addChild: label];
		
		CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"vertexZ = 0" fontName:@"Marker Felt" fontSize:64];
		label2.position =  ccp( size.width /2 , size.height*0.5f );
		[self addChild: label2];
		
		CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"vertexZ = -50" fontName:@"Marker Felt" fontSize:64];
		label3.position =  ccp( size.width /2 , size.height*0.75f );
		[self addChild: label3];
		
		label.vertexZ = 50;
		label2.vertexZ = 0;
		label3.vertexZ = -50;
		
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bugs/circle.plist"];
		mgr = [CCSpriteBatchNode batchNodeWithFile:@"bugs/circle.png" capacity:9];
		[self addChild:mgr];
		sp1 = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
		sp2 = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
		sp3 = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
		sp4 = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
		sp5 = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
		sp6 = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
		sp7 = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
		sp8 = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
		sp9 = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
		
		[mgr addChild:sp1 z:9];
		[mgr addChild:sp2 z:8];
		[mgr addChild:sp3 z:7];
		[mgr addChild:sp4 z:6];
		[mgr addChild:sp5 z:5];
		[mgr addChild:sp6 z:4];
		[mgr addChild:sp7 z:3];
		[mgr addChild:sp8 z:2];
		[mgr addChild:sp9 z:1];
		
		sp1.vertexZ = 400;
		sp2.vertexZ = 300;
		sp3.vertexZ = 200;
		sp4.vertexZ = 100;
		sp5.vertexZ = 0;
		sp6.vertexZ = -100;
		sp7.vertexZ = -200;
		sp8.vertexZ = -300;
		sp9.vertexZ = -400;
		
		sp9.scale = 2;
		sp9.color = ccYELLOW;
	}
	return self;
}
-(NSString*) title
{
	return @"Testing Z Buffer in Render Texture";
}

-(NSString*) subtitle
{
	return @"Touch screen. It should be green";
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		sp1.position = location;
		sp2.position = location;
		sp3.position = location;
		sp4.position = location;
		sp5.position = location;
		sp6.position = location;
		sp7.position = location;
		sp8.position = location;
		sp9.position = location;
	}
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		sp1.position = location;
		sp2.position = location;
		sp3.position = location;
		sp4.position = location;
		sp5.position = location;
		sp6.position = location;
		sp7.position = location;
		sp8.position = location;
		sp9.position = location;
	}
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self renderScreenShot];
}
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED

-(void)renderScreenShot
{
	//NSLog(@"RENDER ");
	
	CCRenderTexture *texture = [CCRenderTexture renderTextureWithWidth:512 height:512];
	texture.anchorPoint = ccp(0,0);
	[texture begin];
	
	[self visit];
	
	[texture end];
	
	CCSprite *sprite = [CCSprite spriteWithTexture:[[texture sprite] texture]];
	
	sprite.position = ccp(256,256);
	sprite.opacity = 182;
	sprite.flipY = 1;
	[self addChild:sprite z:999999];
	sprite.color = ccGREEN;
	
	[sprite runAction:[CCSequence actions:[CCFadeTo actionWithDuration:2 opacity:0],
					   [CCHide action],
					   nil
					   ]
	 ];
	
}
@end



#pragma mark -
#pragma mark AppDelegate (iOS)

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
	[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];
	
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
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0];
	
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
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
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

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#pragma mark -
#pragma mark AppDelegate (Mac)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
	//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
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
