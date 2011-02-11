//
// Shader Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "ShaderTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
			@"ShaderSprite",
			@"ShaderSpriteBatch",
			@"ShaderBMFont",

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
@implementation ShaderTest
-(id) init
{
	if( (self = [super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:26];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		[label setColor:ccRED];
		
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
#pragma mark Example ShaderSprite

@implementation ShaderSprite
-(id) init
{
	if( (self=[super init] ) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Test" fontName:@"Marker Felt" fontSize:36];
		label.position = ccp(s.width/2, s.height-200);
		[self addChild:label];
		
		CCSprite *node = [[CCSprite alloc] initWithFile:@"grossini.png"];
		[self addChild:node];
		
		CCMoveBy *action = [CCMoveBy actionWithDuration:2 position:ccp(200,200)];
		[node runAction:action];
		
		CCRotateBy *rot = [CCRotateBy actionWithDuration:2 angle:360];
		[node runAction:rot];
		
		CCScaleBy *scale = [CCScaleBy actionWithDuration:2 scale:2];
		[node runAction:scale];
		
		CCSprite *node2 = [[CCSprite alloc] initWithFile:@"grossinis_sister1.png"];
		[self addChild:node2 z:1];
		[node2 setPosition:ccp(200,200)];
		
		CCFadeOut *fade = [CCFadeOut actionWithDuration:2];
		id fade_back = [fade reverse];
		id seq = [CCSequence actions:fade, fade_back, nil];
		[node2 runAction: [CCRepeatForever actionWithAction:seq]];
		
		CCSprite *node3 = [[CCSprite alloc] initWithFile:@"grossinis_sister2.png"];
		[self addChild:node3 z:-1];
		[node3 setPosition:ccp(100,200)];
		
		id moveup = [CCMoveBy actionWithDuration:2 position:ccp(0,200)];
		id movedown = [moveup reverse];
		id seq2 = [CCSequence actions:moveup, movedown, nil];
		[node3 runAction:[CCRepeatForever actionWithAction:seq2]];
		
		CCSprite *node3_b = [[CCSprite alloc] initWithFile:@"grossinis_sister2.png"];
		[node3 addChild:node3_b z:1];
		[node3_b setPosition:ccp(10,10)];
		[node3_b setScale:0.5f];
		
		id rot2 = [CCRotateBy actionWithDuration:2 angle:360];
		[node3_b runAction:[CCRepeatForever actionWithAction:rot2]];
				
	}
	
	return self;
	
}

-(NSString *) title
{
	return @"Shader: Sprites";
}

-(NSString *) subtitle
{
	return @"Testing Sprites";
}
@end

#pragma mark -
#pragma mark Example ShaderSpriteBatch

@implementation ShaderSpriteBatch
-(id) init
{
	if( (self=[super init] ) ) {

		
		CGSize s = [[CCDirector sharedDirector] winSize];

		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"animations/ghosts.plist" textureFile:@"animations/ghosts.png"];
		
		CCNode *aParent;
		CCSprite *l1, *l2a, *l2b, *l3a1, *l3a2, *l3b1, *l3b2;
		
		//
		// SpriteBatchNode: 3 levels of children
		//
		
		aParent = [CCSpriteBatchNode batchNodeWithFile:@"animations/ghosts.png"];
		[self addChild:aParent z:0];
		
		// parent
		l1 = [CCSprite spriteWithSpriteFrameName:@"father.gif"];
		l1.position = ccp( s.width/2, s.height/2);
		[aParent addChild:l1 z:0];
		CGSize l1Size = [l1 contentSize];
		
		// child left
		l2a = [CCSprite spriteWithSpriteFrameName:@"sister1.gif"];
		l2a.position = ccp( -25 + l1Size.width/2, 0 + l1Size.height/2);
		[l1 addChild:l2a z:-1];
		CGSize l2aSize = [l2a contentSize];		
		
		
		// child right
		l2b = [CCSprite spriteWithSpriteFrameName:@"sister2.gif"];
		l2b.position = ccp( +25 + l1Size.width/2, 0 + l1Size.height/2);
		[l1 addChild:l2b z:1];
		CGSize l2bSize = [l2a contentSize];	
		
		// child left bottom
		l3a1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a1.scale = 0.65f;
		l3a1.position = ccp(0+l2aSize.width/2,-50+l2aSize.height/2);
		[l2a addChild:l3a1 z:-1];
		
		// child left top
		l3a2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3a2.scale = 0.65f;
		l3a2.position = ccp(0+l2aSize.width/2,+50+l2aSize.height/2);
		[l2a addChild:l3a2 z:1];
		
		// child right bottom
		l3b1 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b1.scale = 0.65f;
		l3b1.position = ccp(0+l2bSize.width/2,-50+l2bSize.height/2);
		[l2b addChild:l3b1 z:-1];
		
		// child right top
		l3b2 = [CCSprite spriteWithSpriteFrameName:@"child1.gif"];
		l3b2.scale = 0.65f;
		l3b2.position = ccp(0+l2bSize.width/2,+50+l2bSize.height/2);
		[l2b addChild:l3b2 z:1];
				
	}
	
	return self;
	
}

-(NSString *) title
{
	return @"Batch Sprites";
}

-(NSString *) subtitle
{
	return @"Testing Batched sprites with shaders";
}
@end

#pragma mark Example ShaderBMFont

@implementation ShaderBMFont
-(id) init
{
	if( (self=[super init] ) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLabelBMFont *label1 = [CCLabelBMFont labelWithString:@"Testing" fntFile:@"futura-48.fnt"];
		[self addChild:label1];
		[label1 setPosition: ccp(s.width/2, s.height/2)];
	}
	
	return self;
	
}

-(NSString *) title
{
	return @"Shader: BMFont";
}

-(NSString *) subtitle
{
	return @"Testing BMFont";
}
@end

// CLASS IMPLEMENTATIONS
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

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
//	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
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
