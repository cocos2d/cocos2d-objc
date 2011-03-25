//
//  TomTheTurretAppDelegate.m
//  TomTheTurret
//
//  Created by Ray Wenderlich on 3/24/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//

#import "TomTheTurretAppDelegate.h"
#import "cocos2d.h"
#import "LoadingScene.h"
#import "CDAudioManager.h"
#import "MainMenuScene.h"
#import "StoryScene.h"
#import "ActionScene.h"
#import "GameState.h"
#import "Level.h"
#import "GameSoundManager.h"

@implementation TomTheTurretAppDelegate

@synthesize loadingScene = _loadingScene;
@synthesize mainMenuScene = _mainMenuScene;
@synthesize storyScene = _storyScene;
@synthesize actionScene = _actionScene;
@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	//Kick off sound initialisation, this will happen in a separate thread
	[[GameSoundManager sharedManager] setup];
	
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeMainLoop];
	
	// get instance of the shared director
	CCDirector *director = [CCDirector sharedDirector];
	
	// before creating any layer, set the landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// display FPS (useful when debugging)
	[director setDisplayFPS:YES];
	
	// frames per second
	[director setAnimationInterval:1.0/60];
	
	// create an OpenGL view
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]];
	[glView setMultipleTouchEnabled:YES];
	
	// connect it to the director
	[director setOpenGLView:glView];
	
	// glview is a child of the main window
	[window addSubview:glView];
	
	// Make the window visible
	[window makeKeyAndVisible];

    self.loadingScene = [[[LoadingScene alloc] init] autorelease];		
	[director runWithScene: _loadingScene];
}

- (void)loadScenes {
   
    // Create a shared opengl context so any textures we load can be shared with the
    // main content
    // See http://www.cocos2d-iphone.org/forum/topic/363 for more details
    EAGLContext *k_context = [[[EAGLContext alloc]
                               initWithAPI:kEAGLRenderingAPIOpenGLES1
                               sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];    
    [EAGLContext setCurrentContext:k_context];
    
    self.mainMenuScene = [[[MainMenuScene alloc] init] autorelease];    
    self.storyScene = [[[StoryScene alloc] init] autorelease];
    self.actionScene = [[[ActionScene alloc] init] autorelease];
 
}

- (void)launchMainMenu {
 
    [[CCDirector sharedDirector] replaceScene:[CCTransitionRadialCW transitionWithDuration:0.5f scene:_mainMenuScene]];
    
}

- (void)launchCurLevel {
    Level *curLevel = [[GameState sharedState] curLevel];
    if ([curLevel isKindOfClass:[StoryLevel class]]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionRadialCW transitionWithDuration:0.5f scene:_storyScene]];
    } else if ([curLevel isKindOfClass:[ActionLevel class]]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionRadialCW transitionWithDuration:0.5f scene:_actionScene]];
    }
}

- (void)launchNextLevel {
    [[GameState sharedState] nextLevel];
    [self launchCurLevel];
}

- (void)launchNewGame { 
    [[GameState sharedState] reset];
    [self launchCurLevel];    
}

- (void)launchKillEnding {
    [GameState sharedState].curLevel = [GameState sharedState].killEnding;
    [self launchCurLevel];
}

- (void)launchSuicideEnding {
    [GameState sharedState].curLevel = [GameState sharedState].suicideEnding;
    [self launchCurLevel];
}

- (void)launchLoseEnding {
    [GameState sharedState].curLevel = [GameState sharedState].loseEnding;
    [self launchCurLevel];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
    self.loadingScene = nil;
    self.mainMenuScene = nil;
    self.storyScene = nil;
    self.actionScene = nil;
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
