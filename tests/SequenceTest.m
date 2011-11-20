//
// Actions Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "cocos2d.h"
#import "SequenceTest.h"

enum {
	kTagAnimationDance = 1,
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

static int sceneIdx=-1;
static NSString *transitions[] = {
    @"ActionSequenceTest"
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
	if( sceneIdx < 0 )
		sceneIdx = sizeof(transitions) / sizeof(transitions[0]) -1;	
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





@implementation ActionDemo
-(id) init
{
	if( (self=[super init])) {
        
		grossini = [[CCSprite alloc] initWithFile:@"grossini.png"];
		tamara = [[CCSprite alloc] initWithFile:@"grossinis_sister1.png"];
		kathia = [[CCSprite alloc] initWithFile:@"grossinis_sister2.png"];
		
		[self addChild:grossini z:1];
		[self addChild:tamara z:2];
		[self addChild:kathia z:3];
        
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		[grossini setPosition: ccp(s.width/2, s.height/3)];
		[tamara setPosition: ccp(s.width/2, 2*s.height/3)];
		[kathia setPosition: ccp(s.width/2, s.height/2)];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF* l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
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
	[grossini release];
	[tamara release];
	[kathia release];
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


-(void) alignSpritesLeft:(unsigned int)numberOfSprites
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	if( numberOfSprites == 1 ) {
		tamara.visible = NO;
		kathia.visible = NO;
		[grossini setPosition:ccp(60, s.height/2)];
	} else if( numberOfSprites == 2 ) {		
		[kathia setPosition: ccp(60, s.height/3)];
		[tamara setPosition: ccp(60, 2*s.height/3)];
		grossini.visible = NO;
	} else if( numberOfSprites == 3 ) {
		[grossini setPosition: ccp(60, s.height/2)];
		[tamara setPosition: ccp(60, 2*s.height/3)];
		[kathia setPosition: ccp(60, s.height/3)];
	}
	else {
		CCLOG(@"ActionsTests: Invalid number of Sprites");
	}	
}

-(void) centerSprites:(unsigned int)numberOfSprites
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	if( numberOfSprites == 1 ) {
		tamara.visible = NO;
		kathia.visible = NO;
		[grossini setPosition:ccp(s.width/2, s.height/2)];
	} else if( numberOfSprites == 2 ) {		
		[kathia setPosition: ccp(s.width/3, s.height/2)];
		[tamara setPosition: ccp(2*s.width/3, s.height/2)];
		grossini.visible = NO;
	} else if( numberOfSprites == 3 ) {
		[grossini setPosition: ccp(s.width/2, s.height/2)];
		[tamara setPosition: ccp(2*s.width/3, s.height/2)];
		[kathia setPosition: ccp(s.width/3, s.height/2)];
	}
	else {
		CCLOG(@"ActionsTests: Invalid number of Sprites");
	}
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

@implementation ActionSequenceTest

-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:1];
	
	CCAnimation* animation = [CCAnimation animation];
	for( int i=1;i<15;i++)
		[animation addFrameWithFilename: [NSString stringWithFormat:@"grossini_dance_%02d.png", i]];
	
	id action = [CCAnimate actionWithDuration:3 animation:animation restoreOriginalFrame:NO];
	id action_back = [action reverse];
	
    rotator = [CCRepeatForever 
               actionWithAction:[CCRotateBy
                                 actionWithDuration:1.0 angle:180]];
    
    animated = [CCRepeatForever
                actionWithAction:
                [CCSequence actions: action, action_back, nil]];
    
    stop_rotator = [CCSequence actions:
                    [CCDelayTime actionWithDuration:2.0],
                    [CCCallBlock actionWithBlock:^{
        
        
        [grossini stopAction:rotator];
        
        [grossini runAction:[CCSequence actions:
                             [CCDelayTime actionWithDuration:1.0],
                             [CCCallBlock actionWithBlock:^{
            
            [grossini runAction:rotator];
            [grossini runAction:stop_rotator];
            
        }],nil]];
        
    }], nil];
    
    stop_animation = [CCSequence actions:
                      [CCDelayTime actionWithDuration:3.0],
                      [CCCallBlock actionWithBlock:^{
        
        [grossini stopAction:animated];
        
        [grossini runAction:[CCSequence actions:
                             [CCDelayTime actionWithDuration:1.0],
                             [CCCallBlock actionWithBlock:^{
            
            [grossini runAction:animated];
            [grossini runAction:stop_animation];
            
        }],nil]];
        
        
    }], nil];
    
    
    id pulsate = [CCRepeatForever actionWithAction:
                  [CCSequence actions:
                   [CCTintTo actionWithDuration:0.1 red:255 green:128 blue:128],
                   [CCTintTo actionWithDuration:0.1 red:128 green:128 blue:255], nil]];
    
	[grossini runAction: animated];
    [grossini runAction: rotator];
    [grossini runAction: stop_rotator];
    [grossini runAction: stop_animation];
    [grossini runAction: pulsate];
    
    [animated retain];
    [rotator retain];
    [stop_rotator retain];
    [stop_animation retain];
    
}
-(NSString *) title
{
	return @"Sequence Test";
}
-(void)onExit {
    [animated release];
    [rotator release];
    [stop_rotator release];
    [stop_animation release];
    [super onExit];
}
@end


// CLASS IMPLEMENTATIONS

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#pragma mark AppController - iOS

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

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// sent to background
-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

// sent to foreground
-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#pragma mark AppController - Mac

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

