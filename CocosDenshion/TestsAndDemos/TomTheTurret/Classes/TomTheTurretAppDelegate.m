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
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:YES];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:CCDirectorTypeDefault];
	
	// Use RGBA_8888 buffers
	// Default is: RGB_565 buffers
	[[CCDirector sharedDirector] setPixelFormat:kPixelFormatRGBA8888];
	
	// Create a depth buffer of 16 bits
	// Enable it if you are going to use 3D transitions or 3d objects
//	[[CCDirector sharedDirector] setDepthBufferFormat:kDepthBuffer16];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
	[[CCDirector sharedDirector] setDisplayFPS:YES];
	
	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
    
    // Fix for "black flash" issue
    // See http://www.cocos2d-iphone.org/forum/topic/2055 for more info
    CCSprite *sprite = [[CCSprite spriteWithFile:@"Default.png"] retain]; 
    sprite.anchorPoint = CGPointZero; 
    CC_ENABLE_DEFAULT_GL_STATES();
    [sprite draw];   
    CC_DISABLE_DEFAULT_GL_STATES();
    [[[CCDirector sharedDirector] openGLView] swapBuffers]; 
    [sprite release];
		
    self.loadingScene = [[[LoadingScene alloc] init] autorelease];
		
	[[CCDirector sharedDirector] runWithScene: _loadingScene];
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
 
    [[CCDirector sharedDirector] replaceScene:[CCRadialCWTransition transitionWithDuration:0.5f scene:_mainMenuScene]];
    
}

- (void)launchCurLevel {
    Level *curLevel = [[GameState sharedState] curLevel];
    if ([curLevel isKindOfClass:[StoryLevel class]]) {
        [[CCDirector sharedDirector] replaceScene:[CCRadialCWTransition transitionWithDuration:0.5f scene:_storyScene]];
    } else if ([curLevel isKindOfClass:[ActionLevel class]]) {
        [[CCDirector sharedDirector] replaceScene:[CCRadialCWTransition transitionWithDuration:0.5f scene:_actionScene]];
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
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
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
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
