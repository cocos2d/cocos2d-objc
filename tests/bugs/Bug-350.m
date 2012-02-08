//
// Bug-350
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=350
//

#import "Bug-350.h"

#pragma mark -
#pragma mark MemBug

@implementation Layer1
-(id) init
{
	if((self=[super init])) {
		CGSize size = [[CCDirector sharedDirector] winSize];
		CCSprite *background = [CCSprite spriteWithFile:@"Default.png"];
		background.position = ccp(size.width/2, size.height/2);
		[self addChild:background];

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

	CCScene *scene = [CCScene node];
	[scene addChild:[Layer1 node] z:0];

//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.anchorPoint = CGPointZero;
//	CC_ENABLE_DEFAULT_GL_STATES();
//	[sprite draw];
//	CC_DISABLE_DEFAULT_GL_STATES();
//	[[[CCDirector sharedDirector] openGLView] swapBuffers];

	[director_ pushScene: scene];

	return YES;
}
@end
