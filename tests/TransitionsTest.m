//
// Transitions Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "cocos2d.h"
#import "TransitionsTest.h"

@interface FadeWhiteTransition : FadeTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipXLeftOver : FlipXTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipXRightOver : FlipXTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipYUpOver : FlipYTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipYDownOver : FlipYTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipAngularLeftOver : FlipAngularTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface FlipAngularRightOver : FlipAngularTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipXLeftOver : ZoomFlipXTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipXRightOver : ZoomFlipXTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipYUpOver : ZoomFlipYTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipYDownOver : ZoomFlipYTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipAngularLeftOver : ZoomFlipAngularTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end
@interface ZoomFlipAngularRightOver : ZoomFlipAngularTransition 
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
@end

@implementation FlipXLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationLeftOver];
}
@end
@implementation FadeWhiteTransition
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s withColor:ccWHITE];
}
@end

@implementation FlipXRightOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationRightOver];
}
@end
@implementation FlipYUpOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationUpOver];
}
@end
@implementation FlipYDownOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationDownOver];
}
@end
@implementation FlipAngularLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationLeftOver];
}
@end
@implementation FlipAngularRightOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationRightOver];
}
@end
@implementation ZoomFlipXLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationLeftOver];
}
@end
@implementation ZoomFlipXRightOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationRightOver];
}
@end
@implementation ZoomFlipYUpOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationUpOver];
}
@end
@implementation ZoomFlipYDownOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationDownOver];
}
@end
@implementation ZoomFlipAngularLeftOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationLeftOver];
}
@end
@implementation ZoomFlipAngularRightOver
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s {
	return [self transitionWithDuration:t scene:s orientation:kOrientationRightOver];
}
@end



static int sceneIdx=0;
static NSString *transitions[] = {
						@"JumpZoomTransition",
						@"FadeTRTransition",
						@"FadeBLTransition",
						@"FadeUpTransition",
						@"FadeDownTransition",
						@"TurnOffTilesTransition",
						@"SplitRowsTransition",
						@"SplitColsTransition",
						@"FadeTransition",
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
						@"ShrinkGrowTransition",
						@"RotoZoomTransition",
						@"MoveInLTransition",
						@"MoveInRTransition",
						@"MoveInTTransition",
						@"MoveInBTransition",
						@"SlideInLTransition",
						@"SlideInRTransition",
						@"SlideInTTransition",
						@"SlideInBTransition",
};

Class nextTransition()
{	
	// HACK: else NSClassFromString will fail
//	[FadeTransition node];
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backTransition()
{
	// HACK: else NSClassFromString will fail
	[FadeTransition node];

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
	[FadeTransition node];

	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

@implementation TextLayer
-(id) init
{
	if( (self=[super init]) ) {

		float x,y;
		
		CGSize size = [[Director sharedDirector] winSize];
		x = size.width;
		y = size.height;

		Sprite *bg1 = [Sprite spriteWithFile:@"background1.jpg"];
		bg1.anchorPoint = CGPointZero;
		[self addChild:bg1 z:-1];

		Label* title = [Label labelWithString:transitions[sceneIdx] fontName:@"Thonburi" fontSize:40];
		[self addChild:title];
		[title setColor:ccc3(255,32,32)];
		[title setPosition: ccp(x/2, y-100)];

		Label* label = [Label labelWithString:@"SCENE 1" fontName:@"Marker Felt" fontSize:64];
		[label setColor:ccc3(16,16,255)];
		[label setPosition: ccp(x/2,y/2)];	
		[self addChild: label];
		
		// menu
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(480/2-100,30);
		item2.position = ccp(480/2, 30);
		item3.position = ccp(480/2+100,30);
		[self addChild: menu z:1];
		
		[self schedule:@selector(step:) interval:1.0f];
	}
	
	return self;
}

-(void) step:(ccTime)dt
{
	NSLog(@"Scene1#step called");
}
-(void) nextCallback:(id) sender
{
	Class transition = nextTransition();
	Scene *s2 = [Scene node];
	[s2 addChild: [TextLayer2 node]];
	[[Director sharedDirector] replaceScene: [transition transitionWithDuration:1.2f scene:s2]];

}	

-(void) backCallback:(id) sender
{
	Class transition = backTransition();
	Scene *s2 = [Scene node];
	[s2 addChild: [TextLayer2 node]];
	[[Director sharedDirector] replaceScene: [transition transitionWithDuration:1.2f scene:s2]];
}	

-(void) restartCallback:(id) sender
{
	Class transition = restartTransition();
	Scene *s2 = [Scene node];
	[s2 addChild: [TextLayer2 node]];
	[[Director sharedDirector] replaceScene: [transition transitionWithDuration:1.2f scene:s2]];
}	
-(void) onEnter
{
	[super onEnter];
	NSLog(@"Scene 1 onEnter");
}

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
	NSLog(@"Scene 1: transition did finish");
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
			
		float x,y;
		
		CGSize size = [[Director sharedDirector] winSize];
		x = size.width;
		y = size.height;
		
		Sprite *bg2 = [Sprite spriteWithFile:@"background2.jpg"];
		bg2.anchorPoint = CGPointZero;
		[self addChild:bg2 z:-1];
		
		Label* title = [Label labelWithString:transitions[sceneIdx] fontName:@"Thonburi" fontSize:40];
		[self addChild:title];
		[title setColor:ccc3(255,32,32)];
		[title setPosition: ccp(x/2, y-100)];		
		
		Label* label = [Label labelWithString:@"SCENE 2" fontName:@"Marker Felt" fontSize:64];
		[label setColor:ccc3(16,16,255)];
		[label setPosition: ccp(x/2,y/2)];
		[self addChild: label];
		
		// menu
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(480/2-100,30);
		item2.position = ccp(480/2, 30);
		item3.position = ccp(480/2+100,30);
		[self addChild: menu z:1];
		
		[self schedule:@selector(step:) interval:1.0f];
	}
	
	return self;
}

-(void) nextCallback:(id) sender
{
	Class transition = nextTransition();
	Scene *s2 = [Scene node];
	[s2 addChild: [TextLayer node]];
	[[Director sharedDirector] replaceScene: [transition transitionWithDuration:1.2f scene:s2]];
}	

-(void) backCallback:(id) sender
{
	Class transition = backTransition();
	Scene *s2 = [Scene node];
	[s2 addChild: [TextLayer node]];
	[[Director sharedDirector] replaceScene: [transition transitionWithDuration:1.2f scene:s2]];
}	

-(void) restartCallback:(id) sender
{
	Class transition = restartTransition();
	Scene *s2 = [Scene node];
	[s2 addChild: [TextLayer node]];
	[[Director sharedDirector] replaceScene: [transition transitionWithDuration:1.2f scene:s2]];
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
	NSLog(@"Scene 2: transition did finish");
}

-(void) onExit
{
	[super onExit];
	NSLog(@"Scene 2 onExit");
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] setDisplayFPS:YES];

	[[Director sharedDirector] attachInView:window];
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];

	Scene *scene = [Scene node];
	[scene addChild: [TextLayer node]];
	
	[window makeKeyAndVisible];
			 
	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window dealloc];
	[super dealloc];
}

@end
