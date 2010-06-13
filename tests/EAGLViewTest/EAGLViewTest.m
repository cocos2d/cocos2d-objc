//
// EAGLViewTest
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
		CCLabel *label;
		
#ifdef __IPHONE_3_2
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			label = [CCLabel labelWithString:@"Hello iPad" fontName:@"Marker Felt" fontSize:40];

		else
#endif
			label = [CCLabel labelWithString:@"Hello iPhone" fontName:@"Marker Felt" fontSize:40];

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
	NSLog(@"options: %@", launchOptions);
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeThreadMainLoop];

	CCDirector *director = [CCDirector sharedDirector];
	[director setDisplayFPS:YES];
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];

	[director setOpenGLView:glView_];

	CCScene *scene = [CCScene node];
	[scene addChild: [LayerExample node]];
	
	[director runWithScene:scene];
	
	return YES;
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}


#pragma mark -
#pragma mark Init
-(void) dealloc
{
	[glView_ release];
	[window_ release];
	[super dealloc];
}
@end
