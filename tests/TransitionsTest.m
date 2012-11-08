//
// Transitions Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "cocos2d.h"
#import "TransitionsTest.h"

#define TRANSITION_DURATION (1.2f)

@interface FadeWhiteTransition : CCTransitionFade
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface FlipXLeftOver : CCTransitionFlipX
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface FlipXRightOver : CCTransitionFlipX
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface FlipYUpOver : CCTransitionFlipY
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface FlipYDownOver : CCTransitionFlipY
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface FlipAngularLeftOver : CCTransitionFlipAngular
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface FlipAngularRightOver : CCTransitionFlipAngular
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface ZoomFlipXLeftOver : CCTransitionZoomFlipX
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface ZoomFlipXRightOver : CCTransitionZoomFlipX
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface ZoomFlipYUpOver : CCTransitionZoomFlipY
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface ZoomFlipYDownOver : CCTransitionZoomFlipY
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface ZoomFlipAngularLeftOver : CCTransitionZoomFlipAngular
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface ZoomFlipAngularRightOver : CCTransitionZoomFlipAngular
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface TransitionPageForward : CCTransitionPageTurn
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end
@interface TransitionPageBackward : CCTransitionPageTurn
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
@end


@implementation FlipXLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationLeftOver];
}
@end
@implementation FadeWhiteTransition
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s withColor:ccWHITE];
}
@end

@implementation FlipXRightOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationRightOver];
}
@end
@implementation FlipYUpOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationUpOver];
}
@end
@implementation FlipYDownOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationDownOver];
}
@end
@implementation FlipAngularLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationLeftOver];
}
@end
@implementation FlipAngularRightOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationRightOver];
}
@end
@implementation ZoomFlipXLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationLeftOver];
}
@end
@implementation ZoomFlipXRightOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationRightOver];
}
@end
@implementation ZoomFlipYUpOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationUpOver];
}
@end
@implementation ZoomFlipYDownOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationDownOver];
}
@end
@implementation ZoomFlipAngularLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationLeftOver];
}
@end
@implementation ZoomFlipAngularRightOver
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s orientation:kCCTransitionOrientationRightOver];
}
@end

@implementation TransitionPageForward
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s backwards:NO];
}
@end

@implementation TransitionPageBackward
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s {
	return [self transitionWithDuration:t scene:s backwards:YES];
}
@end

static int sceneIdx=0;
static NSString *transitions[] =
{
	@"CCTransitionJumpZoom",

	@"CCTransitionProgressRadialCCW",
	@"CCTransitionProgressRadialCW",
	@"CCTransitionProgressHorizontal",
	@"CCTransitionProgressVertical",
	@"CCTransitionProgressInOut",
	@"CCTransitionProgressOutIn",

	@"CCTransitionCrossFade",

	@"TransitionPageForward",
	@"TransitionPageBackward",

	@"CCTransitionFadeTR",
	@"CCTransitionFadeBL",
	@"CCTransitionFadeUp",
	@"CCTransitionFadeDown",

	@"CCTransitionTurnOffTiles",

	@"CCTransitionSplitRows",
	@"CCTransitionSplitCols",

	@"CCTransitionFade",
	@"FadeWhiteTransition",

	@"FlipXLeftOver",
	@"FlipXRightOver",
	@"FlipYUpOver",
	@"FlipYDownOver",
	@"FlipAngularLeftOver",
	@"FlipAngularRightOver",

	@"ZoomFlipXLeftOver",
	@"ZoomFlipXRightOver",
	@"ZoomFlipYUpOver",
	@"ZoomFlipYDownOver",
	@"ZoomFlipAngularLeftOver",
	@"ZoomFlipAngularRightOver",

	@"CCTransitionShrinkGrow",
	@"CCTransitionRotoZoom",
	
	@"CCTransitionMoveInL",
	@"CCTransitionMoveInR",
	@"CCTransitionMoveInT",
	@"CCTransitionMoveInB",

	@"CCTransitionSlideInL",
	@"CCTransitionSlideInR",
	@"CCTransitionSlideInT",
	@"CCTransitionSlideInB",
};

Class nextTransition(void);
Class backTransition(void);
Class restartTransition(void);

Class nextTransition()
{
	// HACK: else NSClassFromString will fail
	[CCTransitionProgressRadialCCW node];

	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backTransition()
{
	// HACK: else NSClassFromString will fail
	[CCTransitionFade node];

	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartTransition()
{
	// HACK: else NSClassFromString will fail
	[CCTransitionFade node];

	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

@implementation TextLayer
-(id) init
{
	if( (self=[super init]) ) {

		float x,y;

		CGSize s = [[CCDirector sharedDirector] winSize];
		x = s.width;
		y = s.height;

		CCSprite *bg1 = [CCSprite spriteWithFile:@"background1.jpg"];

		bg1.position = ccp(s.width/2, s.height/2);
		[self addChild:bg1 z:-1];

		CCLabelTTF *title = [CCLabelTTF labelWithString:transitions[sceneIdx] fontName:@"Thonburi" fontSize:40];
		[self addChild:title];
		[title setColor:ccc3(255,32,32)];
		[title setPosition: ccp(x/2, y-100)];

		CCLabelTTF *label = [CCLabelTTF labelWithString:@"SCENE 1" fontName:@"Marker Felt" fontSize:64];
		[label setColor:ccc3(16,16,255)];
		[label setPosition: ccp(x/2,y/2)];
		[self addChild: label];

		// menu
		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		[self addChild: menu z:1];

		[self schedule:@selector(step:) interval:1.0f];
	}

	return self;
}

- (void) dealloc
{
	NSLog(@"------> Scene#1 dealloc!");
	[super dealloc];
}

-(void) step:(ccTime)dt
{
	NSLog(@"Scene1#step called");
}
-(void) nextCallback:(id) sender
{
	Class transition = nextTransition();
//	CCScene *s2 = [CCScene node];
//	[s2 addChild: [TextLayer2 node]];
	CCScene *s2 = [TextLayer2 node];
	[[CCDirector sharedDirector] replaceScene: [transition transitionWithDuration:TRANSITION_DURATION scene:s2]];

}

-(void) backCallback:(id) sender
{
	Class transition = backTransition();
//	CCScene *s2 = [CCScene node];
//	[s2 addChild: [TextLayer2 node]];
	CCScene *s2 = [TextLayer2 node];
	[[CCDirector sharedDirector] replaceScene: [transition transitionWithDuration:TRANSITION_DURATION scene:s2]];
}

-(void) restartCallback:(id) sender
{
	Class transition = restartTransition();
//	CCScene *s2 = [CCScene node];
//	[s2 addChild: [TextLayer2 node]];
	CCScene *s2 = [TextLayer2 node];
	[[CCDirector sharedDirector] replaceScene: [transition transitionWithDuration:TRANSITION_DURATION scene:s2]];
}
-(void) onEnter
{
	[super onEnter];
	NSLog(@"Scene 1 onEnter");
}

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	NSLog(@"Scene 1: onEnterTransitionDidFinish");
}

-(void) onExitTransitionDidStart
{
	[super onExitTransitionDidStart];
	NSLog(@"Scene 1: onExitTransitionDidStart");
}

-(void) onExit
{
	[super onExit];
	NSLog(@"Scene 1 onExit");
}
@end

@implementation TextLayer2
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		float x,y;

		CGSize size = [[CCDirector sharedDirector] winSize];
		x = size.width;
		y = size.height;

		CCSprite *bg2 = [CCSprite spriteWithFile:@"background2.jpg"];

		bg2.position = ccp(size.width/2, size.height/2);
		[self addChild:bg2 z:-1];

		CCLabelTTF *title = [CCLabelTTF labelWithString:transitions[sceneIdx] fontName:@"Thonburi" fontSize:40];
		[self addChild:title];
		[title setColor:ccc3(255,32,32)];
		[title setPosition: ccp(x/2, y-100)];

		CCLabelTTF *label = [CCLabelTTF labelWithString:@"SCENE 2" fontName:@"Marker Felt" fontSize:64];
		[label setColor:ccc3(16,16,255)];
		[label setPosition: ccp(x/2,y/2)];
		[self addChild: label];

		// menu
		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		[self addChild: menu z:1];

		[self schedule:@selector(step:) interval:1.0f];
	}

	return self;
}

- (void) dealloc
{
	NSLog(@"------> Scene#2 dealloc!");
	[super dealloc];
}


-(void) nextCallback:(id) sender
{
	Class transition = nextTransition();
	CCScene *s2 = [CCScene node];
	[s2 addChild: [TextLayer node]];
	[[CCDirector sharedDirector] replaceScene: [transition transitionWithDuration:TRANSITION_DURATION scene:s2]];
}

-(void) backCallback:(id) sender
{
	Class transition = backTransition();
	CCScene *s2 = [CCScene node];
	[s2 addChild: [TextLayer node]];
	[[CCDirector sharedDirector] replaceScene: [transition transitionWithDuration:TRANSITION_DURATION scene:s2]];
}

-(void) restartCallback:(id) sender
{
	Class transition = restartTransition();
	CCScene *s2 = [CCScene node];
	[s2 addChild: [TextLayer node]];
	[[CCDirector sharedDirector] replaceScene: [transition transitionWithDuration:TRANSITION_DURATION scene:s2]];
}
-(void) step:(ccTime)dt
{
	NSLog(@"Scene2#step called");
}


/// callbacks
-(void) onEnter
{
	[super onEnter];
	NSLog(@"Scene 2 onEnter");
}

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	NSLog(@"Scene 2: onEnterTransitionDidFinish");
}

-(void) onExitTransitionDidStart
{
	[super onExitTransitionDidStart];
	NSLog(@"Scene 2: onExitTransitionDidStart");
}

-(void) onExit
{
	[super onExit];
	NSLog(@"Scene 2 onExit");
}
@end

// CLASS IMPLEMENTATIONS

#ifdef __CC_PLATFORM_IOS

#pragma mark -
#pragma mark AppController - iPhone

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	[director_ setDisplayStats:YES];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// 2D on transitions only for debugging purposes
//	[director_ setProjection:kCCDirectorProjection2D];
	
	return YES;
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [TextLayer node]];
		[director runWithScene:scene];
	}
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return  YES;
//	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

#pragma mark -
#pragma mark AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// don't call super. Window is created manually
//	[super applicationDidFinishLaunching:aNotification];

	CGSize winSize = CGSizeMake(480,320);

	//
	// CC_DIRECTOR_INIT:
	// 1. It will create an NSWindow with a given size
	// 2. It will create a CCGLView and it will associate it with the NSWindow
	// 3. It will register the CCGLView to the CCDirector
	//
	// If you want to create a fullscreen window, you should do it AFTER calling this macro
	//

	CC_DIRECTOR_INIT(winSize);

	[director_ setDisplayStats:YES];

	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director_ setResizeMode:kCCDirectorResize_AutoScale];

	// 2D on transitions only for debugging purposes
//	[director_ setProjection:kCCDirectorProjection2D];

	
	CCScene *scene = [CCScene node];
	[scene addChild: [TextLayer node]];

	[director_ runWithScene:scene];
}
@end
#endif
