//
// attach demo
// a cocos2d example
// http://www.cocos2d-iphone.org
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

enum {
	kTagSprite = 1,
};

@interface LayerExample : CCLayer
{}
@end

@implementation LayerExample
-(id) init
{
	if( (self=[super init] ) )
	{
		self.isTouchEnabled = YES;
		
		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
		CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%dx%d",(int)s.width, (int)s.height] fontName:@"Marker Felt" fontSize:28];
		
		[self addChild:label];
		[self addChild:grossini z:0 tag:kTagSprite];
		
		grossini.position = ccp( s.width/2, s.height/2);
		label.position = ccp( s.width/2, s.height-40);
		
		id sc = [CCScaleBy actionWithDuration:2 scale:1.5f];
		id sc_back = [sc reverse];
		[grossini runAction: [CCRepeatForever actionWithAction:
					   [CCSequence actions: sc, sc_back, nil]]];
		
		[self schedule:@selector(printFrames:) interval:2];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) printFrames:(ccTime)dt
{
	NSLog(@"total frames:%d", [[CCDirector sharedDirector] totalFrames] );
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
	
	CCNode *s = [self getChildByTag:kTagSprite];
	[s stopAllActions];
	[s runAction: [CCMoveTo actionWithDuration:1 position:ccp(convertedLocation.x, convertedLocation.y)]];
	float o = convertedLocation.x - [s position].x;
	float a = convertedLocation.y - [s position].y;
	float at = (float) CC_RADIANS_TO_DEGREES( atanf( o/a) );
	
	if( a < 0 ) {
		if(  o < 0 )
			at = 180 + abs(at);
		else
			at = 180 - abs(at);	
	}
	
	[s runAction: [CCRotateTo actionWithDuration:1 angle: at]];	
}
@end


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
		
		EAGLView *glview = [EAGLView viewWithFrame:CGRectMake(0, 0, 250,350)];
		[mainView addSubview:glview];
		
		CCDirector *director = [CCDirector sharedDirector];
		[director setOpenGLView:glview];
		
		CCScene *scene = [CCScene node];
		id node = [LayerExample node];
		[scene addChild: node];
		
		[director runWithScene:scene];
		
		state = kStateRun;
	}
	else {
		NSLog(@"End the view before running it");
	}
}

-(void) endCocos2d
{
	if( state == kStateRun || state == kStateAttach) {

		CCDirector *director = [CCDirector sharedDirector];

		// Since v0.99.4 you have to remove the OpenGL View manually
		EAGLView *view = [director openGLView];
		[view removeFromSuperview];
		
		// kill the director
		[director end];
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
		CCDirector *director = [CCDirector sharedDirector];

		// attach to super view
		EAGLView *glview = [director openGLView];
		[mainView addSubview:glview];
		
		// start the animation again
		[director startAnimation];

		state = kStateAttach;
	}
	else
		NSLog(@"Dettach the view before attaching it");
}

-(void) detachView
{
	if( state == kStateRun || state == kStateAttach ) {
		
		CCDirector *director = [CCDirector sharedDirector];

		// remove the OpenGL view from the superview
		EAGLView *view = [director openGLView];
		[view removeFromSuperview];
		
		// Stop animation
		[director stopAnimation];


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
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeThreadMainLoop];

	CCDirector *director = [CCDirector sharedDirector];
	[director setDisplayFPS:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	[window makeKeyAndVisible];
	
	state = kStateEnd;

	[self runCocos2d];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{	
	[[CCDirector sharedDirector] end];
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
