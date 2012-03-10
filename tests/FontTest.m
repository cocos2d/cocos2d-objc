//
// Font Test
// a cocos2d example
//
// Example by Maarten Billemont (lhunath)

// cocos2d import
#import "cocos2d.h"

// local import
#import "FontTest.h"

#pragma mark Demo - Font

enum {
	kTagLabel1,
	kTagLabel2,
	kTagLabel3,
	kTagLabel4,

};

static int fontIdx=0;
static NSString *fontList[] =
{
	@"American Typewriter",
	@"Marker Felt",
	@"A Damn Mess",
	@"Abberancy",
	@"Abduction",
	@"Paint Boy",
	@"Schwarzwald",
	@"Scissor Cuts",
};


NSString* nextAction(void);
NSString* backAction(void);
NSString* restartAction(void);


NSString* nextAction()
{
	fontIdx++;
	fontIdx = fontIdx % ( sizeof(fontList) / sizeof(fontList[0]) );
	return fontList[fontIdx];
}

NSString* backAction()
{
	fontIdx--;
	if( fontIdx < 0 )
		fontIdx += ( sizeof(fontList) / sizeof(fontList[0]) );
	return fontList[fontIdx];
}

NSString* restartAction()
{
	return fontList[fontIdx];
}

@implementation FontTest
-(id) init
{
	if((self=[super init] )) {

		// menu
		CGSize size = [CCDirector sharedDirector].winSize;
		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(size.width/2-100,30);
		item2.position = ccp(size.width/2, 30);
		item3.position = ccp(size.width/2+100,30);
		[self addChild: menu z:1];

		[self performSelector:@selector(restartCallback:) withObject:self afterDelay:0.1];
	}

	return self;
}

- (void)showFont:(NSString *)aFont
{

	[self removeChildByTag:kTagLabel1 cleanup:YES];
	[self removeChildByTag:kTagLabel2 cleanup:YES];
	[self removeChildByTag:kTagLabel3 cleanup:YES];
	[self removeChildByTag:kTagLabel4 cleanup:YES];


	CCLabelTTF *top = [CCLabelTTF labelWithString:aFont fontName:aFont fontSize:24];
	CCLabelTTF *left = [CCLabelTTF labelWithString:@"alignment left" dimensions:CGSizeMake(480,50) alignment:CCTextAlignmentLeft fontName:aFont fontSize:32];
	CCLabelTTF *center = [CCLabelTTF labelWithString:@"alignment center" dimensions:CGSizeMake(480,50) alignment:CCTextAlignmentCenter fontName:aFont fontSize:32];
	CCLabelTTF *right = [CCLabelTTF labelWithString:@"alignment right" dimensions:CGSizeMake(480,50) alignment:CCTextAlignmentRight fontName:aFont fontSize:32];

	CGSize s = [[CCDirector sharedDirector] winSize];

	top.position = ccp(s.width/2,250);
	left.position = ccp(s.width/2,200);
	center.position = ccp(s.width/2,150);
	right.position = ccp(s.width/2,100);

	[self addChild:left z:0 tag:kTagLabel1];
	[self addChild:right z:0 tag:kTagLabel2];
	[self addChild:center z:0 tag:kTagLabel3];
	[self addChild:top z:0 tag:kTagLabel4];

//    label = [[Label alloc] initWithString:"This is a test: left" fontName:aFont fontSize:30];
//    label.color = ccc3(0xff, 0xff, 0xff);
//    label.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);

//	NSLog(@"s: %f, t:%f", [[label texture] maxS], [[label texture] maxT]);
//	[[label texture] setMaxS:1];
//	[[label texture] setMaxT:1];
}

-(void) nextCallback:(id) sender
{
    [self showFont:nextAction()];
}

-(void) backCallback:(id) sender
{
    [self showFont:backAction()];
}

-(void) restartCallback:(id) sender
{
    [self showFont:restartAction()];
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// When in iPhone RetinaDisplay, iPad, iPad RetinaDisplay mode, CCFileUtils will append the "-hd", "-ipad", "-ipadhd" to all loaded files
	// If the -hd, -ipad, -ipadhd files are not found, it will load the non-suffixed version
	[CCFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[CCFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "" (empty string)
	[CCFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipad-hd"

	CCScene *scene = [CCScene node];
	[scene addChild: [FontTest node]];

	[director_ pushScene: scene];

	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end
