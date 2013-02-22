//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "HelloWorldScene.h"

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];

	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];

	// add layer as a child to scene
	[scene addChild: layer];

	// return the scene
	return scene;
}

-(void) reset:(id) sender {
	CDLOG(@">> Reset");
	if (audioTests) {
		CDLOG(@">> Releasing audio tests");
		[audioTests release];
		CDLOG(@">> Audio tests released");
	}
	CDLOG(@">> Instantiating audio tests");
	audioTests = [[TheAudioCode alloc] init];
}

-(void) menuHandler:(id) sender {
	int tag = ((CCMenuItem*)sender).tag;
	switch (tag) {
		case 1:
			[audioTests testOne:nil];
			break;
		case 2:
			[audioTests testTwo:nil];
			break;
		case 3:
			[audioTests testThree:nil];
			break;
		case 4:
			[audioTests testFour:nil];
			break;
		case 5:
			[audioTests testFive:nil];
			break;
		case 6:
			[audioTests testSix:nil];
			//[audioTests testSeven:nil];
			break;
		case 8:
			[audioTests testEight:nil];
			break;
		default:
			break;
	}
}

-(void) menuSetup {

	[CCMenuItemFont setFontName: @"Arial"];
	[CCMenuItemFont setFontSize:32];
	CCMenuItemFont *item1 = [CCMenuItemFont itemWithString: @"Harder" target:self selector:@selector(menuHandler:)];
	item1.tag = 1;
	CCMenuItemFont *item2 = [CCMenuItemFont itemWithString: @"Better" target:self selector:@selector(menuHandler:)];
	item2.tag = 2;
	CCMenuItemFont *item3 = [CCMenuItemFont itemWithString: @"Faster" target:self selector:@selector(menuHandler:)];
	item3.tag = 3;
	CCMenuItemFont *item4 = [CCMenuItemFont itemWithString: @"Stronger" target:self selector:@selector(menuHandler:)];
	item4.tag = 4;
	CCMenuItemFont *item5 = [CCMenuItemFont itemWithString: @"Background Music" target:self selector:@selector(menuHandler:)];
	item5.tag = 5;
	CCMenuItemFont *item6 = [CCMenuItemFont itemWithString: @"Sound Effects" target:self selector:@selector(menuHandler:)];
	item6.tag = 6;
	CCMenuItemFont *item7 = [CCMenuItemFont itemWithString: @"Reset" target:self selector:@selector(reset:)];
	CCMenuItemFont *item8 = [CCMenuItemFont itemWithString: @"Background Music switch" target:self selector:@selector(menuHandler:)];
	item8.tag = 8;

	CCMenu *menu = [CCMenu menuWithItems:
					item1, item2,
					item3, item4,
					item7, item8,
					nil];
    [menu alignItemsVerticallyWithPadding:20];
	[self addChild: menu];

}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {

		[self reset:nil];
		[self menuSetup];

	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[audioTests release];

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
