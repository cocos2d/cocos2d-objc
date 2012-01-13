//
// Sprite Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "JpsardaTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {	
	
	@"CCSpriteScale9Demo",
    @"CCProgressBarDemo",
	@"CCSpriteHoleDemo",
};

enum {
	kTagTileMap = 1,
	kTagSpriteBatchNode = 1,
	kTagNode = 2,
	kTagAnimation1 = 1,
	kTagSpriteLeft,
	kTagSpriteRight,
};

enum {
	kTagSprite1,
	kTagSprite2,
	kTagSprite3,
	kTagSprite4,
	kTagSprite5,
	kTagSprite6,
	kTagSprite7,
	kTagSprite8,
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

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

























#pragma mark JpsardaDemo

@implementation JpsardaDemo
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

















#pragma mark CCSpriteScale9Demo

@implementation CCSpriteScale9Demo
-(void)newSize:(CGPoint)p {
    //sizeGoal=CGSizeMake(screenRect.size.width*rand()/RAND_MAX, screenRect.size.height*rand()/RAND_MAX);
    sizeGoal=CGSizeMake(fabsf(p.x-screenRect.size
                              .width*0.5f)*2, fabsf(p.y-screenRect.size
                                                  .height*0.5f)*2);
}
-(id) init
{
	if( (self=[super init]) ) {
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
        
        screenRect.origin=CGPointZero;
        screenRect.size=[[CCDirector sharedDirector] winSize];

        CCSprite *bg=[CCSprite spriteWithFile:@"background2.jpg"];
        bg.position=ccp(screenRect.size
                        .width*0.5f, screenRect.size.height*0.5f);
        bg.color=ccc3(100, 255, 100);
        [self addChild:bg];
        
        
		
		sprite=[CCSpriteScale9 spriteWithFile:@"scale9.png" andLeftCapWidth:32 andTopCapHeight:32];
        //sprite.color=ccc3(255, 100, 100);
        
        [self addChild:sprite];
        sprite.position=ccp(screenRect.size
                          .width*0.5f, screenRect.size.height*0.5f);
        
        sizeCurrent=sizeGoal=CGSizeMake(100, 100);
        [sprite adaptiveScale9:sizeCurrent];

        [self schedule:@selector(tick:)];
	}	
	return self;
}

-(void)tick:(ccTime)dt {
    sizeCurrent.width+=(sizeGoal.width-sizeCurrent.width)*0.1f;
    sizeCurrent.height+=(sizeGoal.height-sizeCurrent.height)*0.1f;
    [sprite adaptiveScale9:sizeCurrent];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
        [self newSize:location];
	}
}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGPoint *location = [[CCDirector sharedDirector] convertEventToGL:event];
    [self newSize:location];
	return YES;
    
}
#endif

-(NSString *) title
{
	return @"CCSpriteScale9 (tap screen)";
}
-(NSString *) subtitle
{
	return @"Scale and preserve corners";
}
@end
#pragma mark -



#pragma mark CCSpriteHoleDemo


#define CCPROGRESSBAR_DEFAULT_BG_FILENAME @"progressbarbg.png"
#define CCPROGRESSBAR_DEFAULT_BG_CAP_WIDTH 8.0f
#define CCPROGRESSBAR_DEFAULT_BG_CAP_HEIGHT 8.0f


#define CCPROGRESSBAR_DEFAULT_FG_FILENAME @"progressbarfg.png"
#define CCPROGRESSBAR_DEFAULT_FG_CAP_WIDTH 8.0f
#define CCPROGRESSBAR_DEFAULT_FG_CAP_HEIGHT 8.0f

@implementation CCProgressBarDemo
-(void)setProgress:(float)progress {
    [bar0 setProgress:progress];
    [bar1 setProgress:progress];
    [bar2 setProgress:progress];
}
-(id) init
{
	if( (self=[super init]) ) {
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
        
        screenRect.origin=CGPointZero;
        screenRect.size=[[CCDirector sharedDirector] winSize];
        
        
        
        CCSprite *bg=[CCSprite spriteWithFile:@"background2.jpg"];
        bg.position=ccp(screenRect.size
                        .width*0.5f, screenRect.size.height*0.5f);
        bg.color=ccc3(100, 255, 100);
        [self addChild:bg];
        

        
        CCSpriteScale9 *b,*f;
  
        // Background sprite (scale9)
        b=[CCSpriteScale9 spriteWithFile:CCPROGRESSBAR_DEFAULT_BG_FILENAME andLeftCapWidth:CCPROGRESSBAR_DEFAULT_BG_CAP_WIDTH andTopCapHeight:CCPROGRESSBAR_DEFAULT_BG_CAP_HEIGHT];
        [b setColor:ccc3(255, 255, 255)];
        // Foreground sprite (scale9)
        f=[CCSpriteScale9 spriteWithFile:CCPROGRESSBAR_DEFAULT_FG_FILENAME andLeftCapWidth:CCPROGRESSBAR_DEFAULT_FG_CAP_WIDTH andTopCapHeight:CCPROGRESSBAR_DEFAULT_FG_CAP_HEIGHT];
        [f setColor:ccc3(255, 255, 255)];
		bar0=[CCProgressBar progressBarWithBgSprite:b andFgSprite:f andSize:CGSizeMake(300, 16) andMargin:CGSizeMake(0, 0)];
        
        bar0.position=ccp(screenRect.size.width*0.5f,screenRect.size.height*4/6);
        [self addChild:bar0];
        
        
        // Background sprite (scale9)
        b=[CCSpriteScale9 spriteWithFile:CCPROGRESSBAR_DEFAULT_BG_FILENAME andLeftCapWidth:CCPROGRESSBAR_DEFAULT_BG_CAP_WIDTH andTopCapHeight:CCPROGRESSBAR_DEFAULT_BG_CAP_HEIGHT];
        [b setColor:ccc3(255, 0, 255)];
        // Foreground sprite (scale9)
        f=[CCSpriteScale9 spriteWithFile:CCPROGRESSBAR_DEFAULT_FG_FILENAME andLeftCapWidth:CCPROGRESSBAR_DEFAULT_FG_CAP_WIDTH andTopCapHeight:CCPROGRESSBAR_DEFAULT_FG_CAP_HEIGHT];
        [f setColor:ccc3(255,200,0)];
		bar1=[CCProgressBar progressBarWithBgSprite:b andFgSprite:f andSize:CGSizeMake(300, 30) andMargin:CGSizeMake(2, 2)];
        
        bar1.position=ccp(screenRect.size.width*0.5f,screenRect.size.height*3/6);
        [self addChild:bar1];
        
        
        // Background sprite (scale9)
        b=[CCSpriteScale9 spriteWithFile:CCPROGRESSBAR_DEFAULT_BG_FILENAME andLeftCapWidth:CCPROGRESSBAR_DEFAULT_BG_CAP_WIDTH andTopCapHeight:CCPROGRESSBAR_DEFAULT_BG_CAP_HEIGHT];
        [b setColor:ccc3(255, 255, 255)];
        // Foreground sprite (scale9)
        f=[CCSpriteScale9 spriteWithFile:CCPROGRESSBAR_DEFAULT_FG_FILENAME andLeftCapWidth:CCPROGRESSBAR_DEFAULT_FG_CAP_WIDTH andTopCapHeight:CCPROGRESSBAR_DEFAULT_FG_CAP_HEIGHT];
        [f setColor:ccc3(255, 0, 0)];
		bar2=[CCProgressBar progressBarWithBgSprite:b andFgSprite:f andSize:CGSizeMake(300, 40) andMargin:CGSizeMake(5, 10)];
        // Waiting bar mode (useful if you don't know the progress)
        [bar2 startAnimation];
        
        bar2.position=ccp(screenRect.size.width*0.5f,screenRect.size.height*2/6);
        [self addChild:bar2];
        
        //sprite.opacity=200;
        progressGoal=progressCurrent=0;
        [self setProgress:progressCurrent];
        
        [self schedule:@selector(tick:)];
	}	
	return self;
}

-(void)tick:(ccTime)dt {
    progressCurrent+=(progressGoal-progressCurrent)*0.1f;
    [self setProgress:progressCurrent];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
        progressGoal=location.x/screenRect.size.width;
	}
}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGPoint *location = [[CCDirector sharedDirector] convertEventToGL:event];
    progressGoal=location.x/screenRect.size.width;
	return YES;
    
}
#endif

-(NSString *) title
{
	return @"CCProgressBar (tap screen)";
}
-(NSString *) subtitle
{
	return @"Based on 2 CCSpriteScale9";
}
@end
#pragma mark -

#pragma mark CCSpriteHoleDemo

#define CCSPRITEHOLEDEMO_HOLE_SIZE 200
@implementation CCSpriteHoleDemo
-(void)setHole:(CGPoint)pos {
    [sprite setHole:CGRectMake(pos.x-CCSPRITEHOLEDEMO_HOLE_SIZE*0.5f,pos.y-CCSPRITEHOLEDEMO_HOLE_SIZE*0.5f, CCSPRITEHOLEDEMO_HOLE_SIZE, CCSPRITEHOLEDEMO_HOLE_SIZE) inRect:screenRect];
    sprite.position=pos;
}
-(id) init
{
	if( (self=[super init]) ) {
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
        
        screenRect.origin=CGPointZero;
        screenRect.size=[[CCDirector sharedDirector] winSize];
        
        
        
        CCSprite *bg=[CCSprite spriteWithFile:@"background2.jpg"];
        bg.position=ccp(screenRect.size
                        .width*0.5f, screenRect.size.height*0.5f);
        bg.color=ccc3(100, 255, 100);
        [self addChild:bg];
        
		sprite=[CCSpriteHole spriteWithFile:@"hole.png"];
        
        [self addChild:sprite];
        //sprite.opacity=200;
        holeCurrent=holeGoal=ccp(screenRect.size
                                 .width*0.5f, screenRect.size.height*0.5f);
        [self setHole:holeCurrent];
        
        [self schedule:@selector(tick:)];
	}	
	return self;
}

-(void)tick:(ccTime)dt {
    holeCurrent.x+=(holeGoal.x-holeCurrent.x)*0.1f;
    holeCurrent.y+=(holeGoal.y-holeCurrent.y)*0.1f;
    [self setHole:holeCurrent];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		holeGoal = [[CCDirector sharedDirector] convertToGL: location];
	}
}
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(BOOL) ccMouseUp:(NSEvent *)event
{
	holeGoal = [[CCDirector sharedDirector] convertEventToGL:event];
    
	return YES;
    
}
#endif

-(NSString *) title
{
	return @"CCSpriteHole (tap screen)";
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
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
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
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

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
