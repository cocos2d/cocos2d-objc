//
//  bugViewController.m
//  EAGLViewBug
//
//  Created by Wylan Werth on 7/5/10.
//  Copyright 2010 BanditBear Games. All rights reserved.
//

#import "bugViewController.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

//to support both landscape and portrait, apple recommends using two viewcontrollers
//http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/RespondingtoDeviceOrientationChanges/RespondingtoDeviceOrientationChanges.html#//apple_ref/doc/uid/TP40007457-CH7-SW1
//this example shows how to start-up the app succesfully in landscape modes, while still supporting portrait. 

@implementation bugViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/*
- (void)viewDidLoad {

    [super viewDidLoad];
}
*/

- (void) loadView
{
    EAGLView *glView = [EAGLView viewWithFrame:[[UIScreen mainScreen] bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    self.view = glView;
    firstTime_ = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableFirstTime) name:@"sceneStarted" object:nil];
}

- (void) disableFirstTime
{
    firstTime_ = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sceneStarted" object:nil];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    //this contruction is workaround for issue #1433, when supporting all orientations and holding the device in landscape when starting up results in portrait view size in iOS4 and iOS5.
    if (firstTime_ && interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        return NO;
    }
    
	return YES;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

-(NSUInteger)supportedInterfaceOrientations{
    //Modify for supported orientations, put your masks here
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

#endif
#endif

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    [super viewDidUnload];
}


- (void)dealloc {
	CCLOG(@"deallocing bugViewController: %@", self);
    [super dealloc];
}


@end
