//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___PROJECTNAMEASIDENTIFIER___AppDelegate.h"
#import "HelloWorldScene.h"

@implementation ___PROJECTNAMEASIDENTIFIER___AppDelegate
@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirector *director = [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	
	[director runWithScene:[HelloWorld scene]];
}

- (void)dealloc
{
	[[CCDirector sharedDirector] release];
	[window_ release];
	[super dealloc];
}

@end
