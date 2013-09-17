//
//  AppDelegate.h
//  cocos2d-ui-tests-osx
//
//  Created by Viktor on 9/16/13.
//  Copyright Cocos2d 2013. All rights reserved.
//

#import "cocos2d.h"

@interface cocos2d_ui_tests_osxAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
