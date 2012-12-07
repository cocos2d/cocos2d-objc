//
// Parallax Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "ParallaxTest.h"

enum {
	kTagNode,
	kTagGrossini,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Parallax1",
			@"Parallax2",
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

Class nextAction()
{

	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;

	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}


@implementation ParallaxDemo
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];

		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		[self addChild: menu z:1];
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark Example Parallax 1

@implementation Parallax1
-(id) init
{
	if( (self=[super init] ) ) {

		// Top Layer, a simple image
		CCSprite *cocosImage = [CCSprite spriteWithFile:@"powered.png"];
		// scale the image (optional)
		cocosImage.scale = 2.5f;
		// change the transform anchor point to 0,0 (optional)
		cocosImage.anchorPoint = ccp(0,0);


		// Middle layer: a Tile map atlas
		CCTileMapAtlas *tilemap = [CCTileMapAtlas tileMapAtlasWithTileFile:@"TileMaps/tiles.png" mapFile:@"TileMaps/levelmap.tga" tileWidth:16 tileHeight:16];
		[tilemap releaseMap];

		// change the transform anchor to 0,0 (optional)
		tilemap.anchorPoint = ccp(0, 0);

		// Anti Aliased images
		[tilemap.texture setAntiAliasTexParameters];


		// background layer: another image
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
		// scale the image (optional)
		background.scale = 1.5f;
		// change the transform anchor point (optional)
		background.anchorPoint = ccp(0,0);


		// create a void node, a parent node
		CCParallaxNode *voidNode = [CCParallaxNode node];

		// NOW add the 3 layers to the 'void' node

		// background image is moved at a ratio of 0.4x, 0.5y
		[voidNode addChild:background z:-1 parallaxRatio:ccp(0.4f,0.5f) positionOffset:CGPointZero];

		// tiles are moved at a ratio of 2.2x, 1.0y
		[voidNode addChild:tilemap z:1 parallaxRatio:ccp(2.2f,1.0f) positionOffset:ccp(0,-200)];

		// top image is moved at a ratio of 3.0x, 2.5y
		[voidNode addChild:cocosImage z:2 parallaxRatio:ccp(3.0f,2.5f) positionOffset:ccp(200,800)];


		// now create some actions that will move the 'void' node
		// and the children of the 'void' node will move at different
		// speed, thus, simulation the 3D environment
		id goUp = [CCMoveBy actionWithDuration:4 position:ccp(0,-500)];
		id goDown = [goUp reverse];
		id go = [CCMoveBy actionWithDuration:8 position:ccp(-1000,0)];
		id goBack = [go reverse];
		id seq = [CCSequence actions:
				  goUp,
				  go,
				  goDown,
				  goBack,
				  nil];
		[voidNode runAction: [CCRepeatForever actionWithAction:seq ] ];

		[self addChild:voidNode];
	}

	return self;

}

-(NSString *) title
{
	return @"Parallax: parent and 3 children";
}
@end

#pragma mark Example Parallax 2

@implementation Parallax2
-(id) init
{
	if( (self=[super init] )) {

#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif

		// Top Layer, a simple image
		CCSprite *cocosImage = [CCSprite spriteWithFile:@"powered.png"];
		// scale the image (optional)
		cocosImage.scale = 2.5f;
		// change the transform anchor point to 0,0 (optional)
		cocosImage.anchorPoint = ccp(0,0);


		// Middle layer: a Tile map atlas
		CCTileMapAtlas *tilemap = [CCTileMapAtlas tileMapAtlasWithTileFile:@"TileMaps/tiles.png" mapFile:@"TileMaps/levelmap.tga" tileWidth:16 tileHeight:16];
		[tilemap releaseMap];

		// change the transform anchor to 0,0 (optional)
		tilemap.anchorPoint = ccp(0, 0);

		// Anti Aliased images
		[tilemap.texture setAntiAliasTexParameters];



		// background layer: another image
		CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
		// scale the image (optional)
		background.scale = 1.5f;
		// change the transform anchor point (optional)
		background.anchorPoint = ccp(0,0);


		// create a void node, a parent node
		CCParallaxNode *voidNode = [CCParallaxNode node];

		// NOW add the 3 layers to the 'void' node

		// background image is moved at a ratio of 0.4x, 0.5y
		[voidNode addChild:background z:-1 parallaxRatio:ccp(0.4f,0.5f) positionOffset:CGPointZero];

		// tiles are moved at a ratio of 1.0, 1.0y
		[voidNode addChild:tilemap z:1 parallaxRatio:ccp(1.0f,1.0f) positionOffset:ccp(0,-200)];

		// top image is moved at a ratio of 3.0x, 2.5y
		[voidNode addChild:cocosImage z:2 parallaxRatio:ccp(3.0f,2.5f) positionOffset:ccp(200,1000)];
		[self addChild:voidNode z:0 tag:kTagNode];

	}

	return self;
}

#ifdef __CC_PLATFORM_IOS

-(void) ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView: [touch view]];
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];

	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];

	CGPoint diff = ccpSub(touchLocation,prevLocation);

	CCNode *node = [self getChildByTag:kTagNode];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, diff)];
}

#elif defined(__CC_PLATFORM_MAC)

-(BOOL) ccMouseDragged:(NSEvent *)event
{
	CCNode *node = [self getChildByTag:kTagNode];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, CGPointMake( event.deltaX, -event.deltaY) )];

	return YES;
}

#endif


-(NSString *) title
{
	return @"Parallax: drag screen";
}
@end


// CLASS IMPLEMENTATIONS
#ifdef __CC_PLATFORM_IOS

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	return YES;
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [nextAction() node]];
		[director runWithScene: scene];
	}
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director_ runWithScene:scene];
}
@end
#endif

