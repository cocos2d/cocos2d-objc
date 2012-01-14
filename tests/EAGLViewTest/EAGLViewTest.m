//
// CCGLViewTest
// This sample/test shows how to create an CCGLView using Interface Builder
//
// http://www.cocos2d-iphone.org
//

#import <UIKit/UIKit.h>

// cocos2d import
#import "cocos2d.h"

// local import
#import "EAGLViewTest.h"

@interface LayerExample : CCLayer
{}
@end

@implementation LayerExample
-(id) init
{
	if( (self=[super init] ) )
	{
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label;

#ifdef __IPHONE_3_2
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			label = [CCLabelTTF labelWithString:@"Hello iPad" fontName:@"Marker Felt" fontSize:40];

		else
#endif
			label = [CCLabelTTF labelWithString:@"Hello iPhone" fontName:@"Marker Felt" fontSize:40];

		label.position = ccp(s.width/2, s.height/2);
		[self addChild:label];

	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

@end


// CLASS IMPLEMENTATIONS
@implementation EAGLViewTestDelegate

@synthesize window=window_;
@synthesize glView=glView_;

#pragma mark -
#pragma mark Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	CCDirector *director = [CCDirector sharedDirector];
	[director setDisplayStats:YES];

	[director setView:glView_];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// turn on multiple touches
	[glView_ setMultipleTouchEnabled:YES];

	CCScene *scene = [CCScene node];
	[scene addChild: [LayerExample node]];

	[director pushScene:scene];

	[director startAnimation];

	return YES;
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
	CCDirector *director = [CCDirector sharedDirector];
	[director.view removeFromSuperview];
	[director end];

	// release glView here, else it won't be dealloced
	[glView_ release];
	glView_ = nil;
}

#pragma mark -
#pragma mark Init
-(void) dealloc
{
//	[glView_ release];
	[window_ release];
	[super dealloc];
}
@end
