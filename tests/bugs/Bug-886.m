//
// Bug-886
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=886
//

#import "Bug-886.h"

#pragma mark -

@implementation Layer1
-(id) init
{
	if( (self=[super init] )) {

		// ask director the the window size
		//		CGSize size = [[CCDirector sharedDirector] winSize];

		CCSprite* sprite = [CCSprite spriteWithFile:@"bugs/bug886.jpg"];
		sprite.anchorPoint = CGPointZero;
		sprite.position =  CGPointZero;
		sprite.scaleX = 0.6f;
		[self addChild: sprite];

		CCSprite* sprite2 = [CCSprite spriteWithFile:@"bugs/bug886.png"];
		sprite2.anchorPoint = CGPointZero;
		sprite2.scaleX = 0.6f;
		sprite2.position =  ccp( [sprite contentSize].width * 0.6f + 10, 0 );
		[self addChild: sprite2];

	}
	return self;
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];


	// Turn on display FPS
	[director_ setDisplayStats:YES];

//	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

	CCScene *scene = [CCScene node];
	[scene addChild:[Layer1 node] z:0];

	[director_ pushScene: scene];

	return YES;
}
@end
