//
// attach demo
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//

#import <UIKit/UIKit.h>
#include <sys/time.h>

// cocos2d import
#import "cocos2d.h"

// local import
#import "attachDemo.h"


enum {
	kStateRun,
	kStateEnd,
	kStateAttach,
	kStateDetach,
};

@interface AppController (Private)
-(void) attachView;
-(void) detachView;
-(void) runCocos2d;
-(void) endCocos2d;
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

@synthesize window, mainView;

enum {
	kTagAttach = 1,
	kTagDettach = 2,
};

//
// Use runWithScene / end
// to remove /add the cocos2d view
// This is the recommended way since it removes the Scenes from memory
//
-(void) runCocos2d
{
	if( state == kStateEnd ) {
		[[Director sharedDirector] attachInView:mainView withFrame:CGRectMake(0, 0, 200,200)];
		CGSize s = [[Director sharedDirector] winSize];
		
		Scene *scene = [Scene node];
		Sprite *grossini = [Sprite spriteWithFile:@"grossini.png"];
		Label *label = [Label labelWithString:[NSString stringWithFormat:@"%dx%d",(int)s.width, (int)s.height] fontName:@"Marker Felt" fontSize:28];
		
		[scene add:label];
		[scene add:grossini];
		
		grossini.position = cpv( s.width/2, s.height/2);
		label.position = cpv( s.width/2, s.height-40);
		
		[grossini do: [RepeatForever actionWithAction: [RotateBy actionWithDuration:2 angle:360]]];
		
		[[Director sharedDirector] runWithScene:scene];	
		
		state = kStateRun;
	}
	else {
		NSLog(@"End the view before running it");
	}
}

-(void) endCocos2d
{
	if( state == kStateRun || state == kStateAttach) {
		[[Director sharedDirector] end];
		state = kStateEnd;
	}
	else
		NSLog(@"Run or Attach the view before calling end");
}

//
// Use attach / detach
// To hide / unhide the cocos2d view.
// If you want to remove them, use runWithScene / end
// IMPORTANT: Memory is not released if you use attach / detach
//
-(void) attachView
{
	if( state == kStateDetach ) {
		[[Director sharedDirector] attachInView:mainView withFrame:CGRectMake(0, 0, 200,200)];
		[[Director sharedDirector] startAnimation];

		state = kStateAttach;
	}
	else
		NSLog(@"Dettach the view before attaching it");
}

-(void) detachView
{
	if( state == kStateRun || state == kStateAttach ) {
		[[Director sharedDirector] detach];
		[[Director sharedDirector] stopAnimation];
		state = kStateDetach;
	} else {
		NSLog(@"Run or Attach the view before calling detach");
	}
}

#pragma mark -
#pragma mark Segment Delegate
- (void)segmentAction:(id)sender
{	
	int idx = [sender selectedSegmentIndex];
	// category 
	if( [sender tag] == 0 ) {	// attach / detach
		if( idx == 0)
			[self attachView];
		else if( idx == 1 )
			[self detachView];
	} else if( [sender tag] == 1 ) { // run / end
		if( idx == 0 )
			[self runCocos2d];
		else if(idx == 1)
			[self endCocos2d];
	}
}

#pragma mark -
#pragma mark Application Delegate

-(void) applicationDidFinishLaunching:(UIApplication*)application
{	
	//
	// XXX BUG: Important: DONT use Fast Director
	// XXX BUG: If you are going to attach / detach / end / run the application
	// XXX BUG: Your application might crash
	//
	[[Director sharedDirector] setDisplayFPS:YES];


	[window makeKeyAndVisible];	
	
	state = kStateEnd;

	[self runCocos2d];
}

#pragma mark -
#pragma mark Init
-(void) dealloc
{
	[mainView release];
	[window release];
	[super dealloc];
}
@end
