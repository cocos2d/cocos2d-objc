//
//  AppDelegate.m
//  cocos2d-ui-tests-osx
//
//  Created by Viktor on 9/16/13.
//  Copyright Cocos2d 2013. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMenu.h"
#import "CCDirector_Private.h"

@implementation cocos2d_ui_tests_osxAppDelegate
@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) glView_.director;
    
	// connect the OpenGL view with the director
	[director setView:glView_];

    // enable FPS and SPF
    [director setDisplayStats:NO];
    

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_NoScale];
    [CCDirector pushCurrentDirector:director];
    
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// Center main window
	[window_ center];
    
    CCFileUtils* fileUtils = [CCFileUtils sharedFileUtils];
    
    fileUtils.directoriesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 @"resources-tablet", CCFileUtilsSuffixDefault,
                                 nil];
    
    fileUtils.searchPath = @[
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Images"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Fonts"],
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resources-shared"],
        [[NSBundle mainBundle] resourcePath],
    ];
    
    fileUtils.searchMode = CCFileUtilsSearchModeDirectory;
    [fileUtils buildSearchResolutionsOrder];
    
    [fileUtils loadFilenameLookupDictionaryFromFile:@"fileLookup.plist"];
		
    // Register spritesheets.
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Interface.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Sprites.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"TilesAtlassed.plist"];
	
	[director presentScene:[MainMenu scene]];
    [CCDirector popCurrentDirector];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[glView_.director end];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) glView_.director;
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
