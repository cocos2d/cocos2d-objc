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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Display retina Display
	useRetinaDisplay_ = NO;

	[super application:application didFinishLaunchingWithOptions:launchOptions];

	//Kick off sound initialisation, this will happen in a separate thread
	[[GameSoundManager sharedManager] setup];


	// display FPS (useful when debugging)
	[director_ setDisplayStats:YES];

	// frames per second
	[director_ setAnimationInterval:1.0/60];

	// multiple touches on
	[director_.view setMultipleTouchEnabled:YES];

    self.loadingScene = [[[LoadingScene alloc] init] autorelease];
	[director_ pushScene: _loadingScene];

	return YES;
}

- (void)loadScenes {

    // Create a shared opengl context so any textures we load can be shared with the
    // main content
    // See http://www.cocos2d-iphone.org/forum/topic/363 for more details

	CCGLView *view = (CCGLView*) [[CCDirector sharedDirector] view];
    EAGLContext *k_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2
													sharegroup: [view.context sharegroup]];

    [EAGLContext setCurrentContext:k_context];
	[k_context release];

    self.mainMenuScene = [[[MainMenuScene alloc] init] autorelease];
    self.storyScene = [[[StoryScene alloc] init] autorelease];
    self.actionScene = [[[ActionScene alloc] init] autorelease];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)launchMainMenu {

    [[CCDirector sharedDirector] replaceScene:[CCTransitionProgressRadialCW transitionWithDuration:0.5f scene:_mainMenuScene]];

}

- (void)launchCurLevel {
    Level *curLevel = [[GameState sharedState] curLevel];
    if ([curLevel isKindOfClass:[StoryLevel class]]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionProgressRadialCW transitionWithDuration:0.5f scene:_storyScene]];
    } else if ([curLevel isKindOfClass:[ActionLevel class]]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionProgressRadialCW transitionWithDuration:0.5f scene:_actionScene]];
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

- (void)dealloc {
    self.loadingScene = nil;
    self.mainMenuScene = nil;
    self.storyScene = nil;
    self.actionScene = nil;

	[super dealloc];
}

@end
