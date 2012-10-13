/*
     File: MyViewController.m
 Abstract: The main view controller of this app.
  Version: 1.0

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2010 Apple Inc. All Rights Reserved.

 */

#include "cocos2d.h"

#import "ScrollViewController.h"

@implementation ScrollViewController

@synthesize scrollView1 = scrollView1_;

const CGFloat kScrollObjHeight	= 121.0;
const CGFloat kScrollObjWidth	= 85.0;
const NSUInteger kNumImages		= 9;


- (void)layoutScrollImages
{
	UIImageView *view = nil;
	NSArray *subviews = [scrollView1_ subviews];

	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;

			curXLoc += (kScrollObjWidth);
		}
	}

	// set the content size so it can be scrollable
	[scrollView1_ setContentSize:CGSizeMake((kNumImages * kScrollObjWidth), kScrollObjHeight)];
}

- (void)viewDidLoad
{
	//self.view.backgroundColor = [UIColor blueColor];//[UIColor viewFlipsideBackgroundColor];

	// 1. setup the scrollview for multiple images and add it to the view controller
	//
	// note: the following can be done in Interface Builder, but we show this in code for clarity
    customScrollView* scrollView = [[customScrollView alloc] initWithFrame:CGRectMake(0.f,100.f,320.f,120.f)];
    self.scrollView1 = scrollView;
    
    [scrollView release];
    
	[scrollView1_ setBackgroundColor:[UIColor blackColor]];

    [scrollView1_ setCanCancelContentTouches:NO];
	scrollView1_.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView1_.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	scrollView1_.scrollEnabled = YES;

	// pagingEnabled property default is NO, if set the scroller will stop or snap at each photo
	// if you want free-flowing scroll, don't set this property.
	scrollView1_.pagingEnabled = NO;

	// load all the images from our bundle and add them to the scroll view
	NSUInteger i;
	for (i = 1; i <= kNumImages; i++)
	{
		//NSString *imageName = [NSString stringWithFormat:@"Resources/Images/grossini_images/grossini_dance_%d.png", i];
        NSString *imageName = [NSString stringWithFormat:@"grossini_dance_0%d.png", i];
      	UIImage *image = [UIImage imageNamed:imageName];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

        if (image != nil)
        {
            // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
            CGRect rect = imageView.frame;
            rect.size.height = kScrollObjHeight;
            rect.size.width = kScrollObjWidth;
            imageView.frame = rect;
            imageView.tag = i;	// tag our images for later use when we place them in serial fashion
            [scrollView1_ addSubview:imageView];

        }
        else NSLog(@"image not found");
        [imageView release];
	}

	[self layoutScrollImages];	// now place the photos in serial layout within the scrollview

   	[self setView:scrollView1_];


}

- (void)dealloc
{
    CCLOG(@"cocos2d: deallocing scrollViewController: %@\n", self);
	[scrollView1_ release];

	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// invoke super's implementation to do the Right Thing, but also release the input controller since we can do that
	// In practice this is unlikely to be used in this application, and it would be of little benefit,
	// but the principle is the important thing.
	//
	[super didReceiveMemoryWarning];
}

@end

@implementation customScrollView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.delegate = self;
    }
    return self;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[CCDirector sharedDirector] setAnimationInterval:1/30.0];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [[CCDirector sharedDirector] setAnimationInterval:1/60.0];
}

- (void) dealloc
{
    CCLOG(@"cocos2d: deallocing customScrollView: %@\n", self);
    self.delegate = nil;
    [super dealloc];
}
@end

@implementation MasterViewController

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
    	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
    			interfaceOrientation == UIInterfaceOrientationLandscapeRight );

	// eg: Support 4 orientations
	//return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

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
	CCLOG(@"cocos2d: deallocing masterViewController: %@\n", self);
    [super dealloc];
}


@end


