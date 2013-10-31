//
//  AppDelegate.m
//  cocos2d-ui-tests-osx
//
//  Created by Viktor on 9/16/13.
//  Copyright Cocos2d 2013. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMenu.h"

@implementation cocos2d_ui_tests_osxAppDelegate
@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];

	// enable FPS and SPF
	[director setDisplayStats:YES];
	
	// connect the OpenGL view with the director
	[director setView:glView_];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// Center main window
	[window_ center];
    
    CCFileUtils* fileUtils = [CCFileUtils sharedFileUtils];
    
    fileUtils.directoriesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 @"resources-tablet", CCFileUtilsSuffixDefault,
                                 nil];
    fileUtils.searchPath = [NSArray arrayWithObjects:
                            [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resources-shared"],
                            [[NSBundle mainBundle] resourcePath],
                            nil];
    
    fileUtils.searchMode = CCFileUtilsSearchModeDirectory;
    [fileUtils buildSearchResolutionsOrder];
    
    [fileUtils loadFilenameLookupDictionaryFromFile:@"fileLookup.plist"];
    
	
	[director runWithScene:[MainMenu scene]];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
