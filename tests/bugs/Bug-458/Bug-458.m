//
// Bug-458 test case by nedrafehi
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=458
//

#import "Bug-458.h"
#import "QuestionContainerSprite.h"

#pragma mark -
#pragma mark MemBug
@implementation Layer1
-(id) init
{
	if((self=[super init])) {
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

        QuestionContainerSprite* question = [[QuestionContainerSprite alloc] init];
        QuestionContainerSprite* question2 = [[QuestionContainerSprite alloc] init];

//		[question setContentSize:CGSizeMake(50,50)];
//		[question2 setContentSize:CGSizeMake(50,50)];

        CCMenuItemSprite* sprite = [CCMenuItemSprite itemWithNormalSprite:question2 selectedSprite:question target:self selector:@selector(selectAnswer:)];

        CCLayerColor* layer = [CCLayerColor layerWithColor:ccc4(0,0,255,255) width:100 height:100];

		[question release];
		[question2 release];

        CCLayerColor* layer2 = [CCLayerColor layerWithColor:ccc4(255,0,0,255) width:100 height:100];

        CCMenuItemSprite* sprite2 = [CCMenuItemSprite itemWithNormalSprite:layer selectedSprite:layer2 target:self selector:@selector(selectAnswer:)];
        CCMenu* menu = [CCMenu menuWithItems:sprite, sprite2, nil];
        [menu alignItemsVerticallyWithPadding:100];

        [menu setPosition:ccp(size.width / 2, size.height / 2)];

		// add the label as a child to this Layer
		[self addChild: menu];
	}
	return self;
}

-(void)selectAnswer:(id)sender
{
    CCLOG(@"Selected");
}
@end


// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	CCScene *scene = [CCScene node];

	[scene addChild:[Layer1 node] z:0];

	[director_ pushScene: scene];

	return YES;
}
@end
