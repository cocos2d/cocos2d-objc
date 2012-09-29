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


@implementation bugViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Return YES for supported orientations

	// eg: Only support landscape orientations ?
//	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//			interfaceOrientation == UIInterfaceOrientationLandscapeRight );

	// eg: Support 4 orientations
	return YES;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

-(NSUInteger)supportedInterfaceOrientations{
    //Modify for supported orientations, put your masks here
    return UIInterfaceOrientationMaskLandscape;
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
