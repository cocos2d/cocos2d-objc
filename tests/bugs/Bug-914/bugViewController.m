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

-(void)viewWillAppear:(BOOL)animated {
	
	for (UIView *view in self.view.subviews) {
		if ([view isKindOfClass:[EAGLView class]]) {
			
			// weak reference
			glView = (EAGLView *) view;
			break;
		}
	}
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Return YES for supported orientations
	
	// eg: Only support landscape orientations ?
//	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//			interfaceOrientation == UIInterfaceOrientationLandscapeRight );
	
	// eg: Support 4 orientations
	return YES;
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	CGRect rect = CGRectMake(0,0,0,0);
	if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			rect = CGRectMake(0, 0, 768, 1024);
		else
			rect = CGRectMake(0, 0, 320, 480 );

	} else if( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			rect = CGRectMake(0, 0, 1024, 768);
		else
			rect = CGRectMake(0, 0, 480, 320 );
	} else
		NSAssert(NO, @"Invalid orientation");

	glView.frame = rect;

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    [super viewDidUnload];
	
	// invalidate weak reference
	glView = nil;
}


- (void)dealloc {
	CCLOG(@"deallocing bugViewController: %@", self);
    [super dealloc];
}


@end
