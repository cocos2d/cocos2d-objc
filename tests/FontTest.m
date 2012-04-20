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
static int fontCount = sizeof(fontList) / sizeof(*fontList);

static int vAlignIdx = 0;
static CCVerticalTextAlignment verticalAlignment[] =
{
    kCCVerticalTextAlignmentTop,
    kCCVerticalTextAlignmentCenter,
    kCCVerticalTextAlignmentBottom,
};
static int vAlignCount = sizeof(verticalAlignment) / sizeof(*verticalAlignment);


NSString* nextAction(void);
NSString* backAction(void);
NSString* restartAction(void);


NSString* nextAction()
{
	fontIdx++;
    if(fontIdx >= fontCount) {
        fontIdx = 0;
        vAlignIdx = (vAlignIdx + 1) % vAlignCount;
    }
	return fontList[fontIdx];
}

NSString* backAction()
{
	fontIdx--;
	if( fontIdx < 0 ) {
        fontIdx = fontCount - 1;
        vAlignIdx--;
        if(vAlignIdx < 0)
            vAlignIdx = vAlignCount - 1;
    }
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
		CGSize s = [CCDirector sharedDirector].winSize;
		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		[self addChild: menu z:1];

		[self performSelector:@selector(restartCallback:) withObject:self afterDelay:0.1];
	}

	return self;
}

- (void)showFont:(NSString *)aFont
{
	CGSize s = [[CCDirector sharedDirector] winSize];

    CGSize blockSize = CGSizeMake(s.width/3, 200);
    CGFloat fontSize = 26;

	[self removeChildByTag:kTagLabel1 cleanup:YES];
	[self removeChildByTag:kTagLabel2 cleanup:YES];
	[self removeChildByTag:kTagLabel3 cleanup:YES];
	[self removeChildByTag:kTagLabel4 cleanup:YES];


	CCLabelTTF *top = [CCLabelTTF labelWithString:aFont fontName:aFont fontSize:24];
	CCLabelTTF *left = [CCLabelTTF labelWithString:@"alignment left" dimensions:blockSize hAlignment:kCCTextAlignmentLeft vAlignment:verticalAlignment[vAlignIdx] fontName:aFont fontSize:fontSize];
	CCLabelTTF *center = [CCLabelTTF labelWithString:@"alignment center" dimensions:blockSize hAlignment:kCCTextAlignmentCenter vAlignment:verticalAlignment[vAlignIdx] fontName:aFont fontSize:fontSize];
	CCLabelTTF *right = [CCLabelTTF labelWithString:@"alignment right" dimensions:blockSize hAlignment:kCCTextAlignmentRight vAlignment:verticalAlignment[vAlignIdx] fontName:aFont fontSize:fontSize];

    CCLayerColor *leftColor = [CCLayerColor layerWithColor:ccc4(100, 100, 100, 255) width:blockSize.width height:blockSize.height];
    CCLayerColor *centerColor = [CCLayerColor layerWithColor:ccc4(200, 100, 100, 255) width:blockSize.width height:blockSize.height];
    CCLayerColor *rightColor = [CCLayerColor layerWithColor:ccc4(100, 100, 200, 255) width:blockSize.width height:blockSize.height];
	
	leftColor.ignoreAnchorPointForPosition = NO;
	centerColor.ignoreAnchorPointForPosition = NO;
	rightColor.ignoreAnchorPointForPosition = NO;
	
    
    top.anchorPoint = ccp(0.5, 1);
    left.anchorPoint = leftColor.anchorPoint = ccp(0,0.5);
    center.anchorPoint = centerColor.anchorPoint = ccp(0,0.5);
    right.anchorPoint = rightColor.anchorPoint = ccp(0,0.5);

	top.position = ccp(s.width/2,s.height-20);
	left.position = leftColor.position = ccp(0,s.height/2);
	center.position = centerColor.position = ccp(blockSize.width, s.height/2);
	right.position = rightColor.position = ccp(blockSize.width*2, s.height/2);

    [self addChild:leftColor z:-1];
	[self addChild:left z:0 tag:kTagLabel1];
    [self addChild:rightColor z:-1];
	[self addChild:right z:0 tag:kTagLabel2];
	[self addChild:centerColor z:-1];
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

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

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
