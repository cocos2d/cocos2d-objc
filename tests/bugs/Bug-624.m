//
// Bug-624
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=624
//

#import "Bug-624.h"

#pragma mark -
#pragma mark MemBug

@implementation Layer1
-(id) init
{
	if((self=[super init])) {
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Layer1" fontName:@"Marker Felt" fontSize:36];

		label.position = ccp(size.width/2, size.height/2);
		[self addChild:label];

		[self schedule:@selector(switchLayer:) interval:5];

	}

	return self;
}

-(void) switchLayer:(ccTime)dt
{
	[self unschedule:_cmd];

	CCScene *scene = [CCScene node];
	[scene addChild:[Layer2 node] z:0];

	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:2 scene:scene withColor:ccWHITE]];
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	NSLog(@"Layer1 accel");
}


@end

@implementation Layer2
-(id) init
{
	if((self=[super init])) {
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Layer2" fontName:@"Marker Felt" fontSize:36];

		label.position = ccp(size.width/2, size.height/2);
		[self addChild:label];

		[self schedule:@selector(switchLayer:) interval:5];

	}

	return self;
}

-(void) switchLayer:(ccTime)dt
{
	[self unschedule:_cmd];

	CCScene *scene = [CCScene node];
	[scene addChild:[Layer1 node] z:0];

	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:2 scene:scene withColor:ccRED]];
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	NSLog(@"Layer2 accel");
}
@end


// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	CCScene *scene = [CCScene node];
	[scene addChild:[Layer1 node] z:0];

	[director_ pushScene: scene];

	return YES;
}
@end
