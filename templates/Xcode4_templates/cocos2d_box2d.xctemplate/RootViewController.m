//
//  RootViewController.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

//
// RootViewController
//
// Use this class to control rotation and integtration with iAd and any other View Controller
//

#import "cocos2d.h"

#import "RootViewController.h"

@implementation RootViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
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
	
	// EAGLView will be rotated by the UIViewController
	//
	// return YES for the supported orientations
	
	
	// For landscape only, uncomment the following line
	//	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
	
	
	// For portrait only, uncomment the following line
	//	return ( ! UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
	
	// To support all oritentatiosn return YES
	return YES;
}

//
// Device will be rotated
//
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//
	// XXX: Is this code needed ????
	//
#if 0
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGRect rect = CGRectZero;
	
	
	if( UIInterfaceOrientationIsLandscape( toInterfaceOrientation ) )
		rect = screenRect;
	
	else
		rect.size = CGSizeMake( screenRect.size.height, screenRect.size.width );
	
	CCDirector *director = [CCDirector sharedDirector];
	EAGLView *glView = [director openGLView];
	float contentScaleFactor = [director contentScaleFactor];
	
	if( contentScaleFactor != 1 ) {
		
		rect.size.width *= contentScaleFactor;
		rect.size.width *= contentScaleFactor;
		
	}
	
	glView.frame = rect;
#endif
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end


