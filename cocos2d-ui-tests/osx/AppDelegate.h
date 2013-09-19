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
	NSWindow	*__weak window_;
	CCGLView	*__weak glView_;
}

@property (weak) IBOutlet NSWindow	*window;
@property (weak) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
