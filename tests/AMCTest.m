//
// Sprite Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "AMCTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {	
    @"NodeAMC",
	@"SpriteAMC1",
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

#pragma mark -

enum nodeTags {
    kLayer, //< tag for layer that we will save/load
};

@implementation AMCDemo

- (NSString *) testFilePath
{    
    NSString *filename = [NSString stringWithFormat:@"%@.plist", [self className] ];
    
    NSArray *paths					= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory	= [paths objectAtIndex:0];
	NSString *fullPath				= [documentsDirectory stringByAppendingPathComponent: filename ];
	return fullPath;
}

- (void) save
{
    CCNode *layer = [self getChildByTag: kLayer];
    NSDictionary *dict = [layer dictionaryRepresentation];
    [dict writeToFile:[self testFilePath] atomically:YES];
}

- (void) purge
{
    [self removeChildByTag: kLayer cleanup:YES];
    
    [CCAnimationCache purgeSharedAnimationCache];
    [CCSpriteFrameCache purgeSharedSpriteFrameCache];
    [CCTextureCache purgeSharedTextureCache];    
}

- (void) load
{
    NSString *path = [self testFilePath];
    NSDictionary *aDict = [NSDictionary dictionaryWithContentsOfFile: path];
    CCLayer *layer = [NSObject objectWithDictionaryRepresentation: aDict ];    
    
	[self addChild: layer z: 0 tag: kLayer];
}

- (void) savePurgeLoadCallback: (id) sender
{
    CCMenuItemToggle *toggle = (CCMenuItemToggle *)sender;
    NSUInteger selected = toggle.selectedIndex;
    switch (selected) {
        case 0:
            NSLog(@"Loading...");
            [self load];
            break;
        case 1:
            NSLog(@"Saving...");
            [self save];
            break;
        case 2:
            NSLog(@"Purging...");
            [self purge];
            break;
            
    }

}

-(id) init
{
	if( (self = [super init]) ) {
		CGSize s = [[CCDirector sharedDirector] winSize];
        
        [self addChild: [self insideLayer]  z: 0 tag: kLayer];
			
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:26];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];

		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
        
        CCMenuItemLabel *save = [CCMenuItemLabel itemWithLabel: [CCLabelTTF labelWithString: @"Save" fontName: @"Marker Felt" fontSize:12]];
        CCMenuItemLabel *purge = [CCMenuItemLabel itemWithLabel: [CCLabelTTF labelWithString: @"Purge" fontName: @"Marker Felt" fontSize:12]];
        CCMenuItemLabel *load = [CCMenuItemLabel itemWithLabel: [CCLabelTTF labelWithString: @"Load" fontName: @"Marker Felt" fontSize:12]];
        CCMenuItem *trigger = [CCMenuItemToggle itemWithTarget:self selector: @selector(savePurgeLoadCallback:) items: save, purge, load, nil];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, trigger, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
        trigger.position = ccp( s.width/2, 80);
		[self addChild: menu z:1];	
	}
	return self;
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

-(NSString*) subtitle
{
	return nil;
}

-(CCLayer *) insideLayer
{
    return nil;
}

@end

#pragma mark - Actual AMC Tests

#pragma mark Node + Children

@implementation RectNode

- (void) draw
{
    [super draw];
    
    glColor4f(1.0f, 0.0f, 0.0f, 1.0);
    glLineWidth(2.0f); 
	CGSize s = [self contentSize];
	CGPoint vertices[4]={
		ccp(0,0),ccp(s.width,0),
		ccp(s.width,s.height),ccp(0,s.height),
	};
	ccDrawPoly(vertices, 4, YES);
}

@end

@implementation NodeAMC

-(CCLayer *) insideLayer
{
	CCLayer *layer = [CCLayer node];
    
    CGSize s = [[CCDirector sharedDirector] winSize];
	
    CCNode *node1 = [RectNode node];
    node1.position = ccp(0.5f * s.width, 0.5f * s.height);
    node1.rotation = 15;
    node1.scaleX = 1.0f;
    node1.scaleY = 1.0f;
    node1.skewX = 0;
    node1.skewY = 0;
    node1.anchorPoint = ccp(0.5f, 0.5f);
    node1.isRelativeAnchorPoint = YES;
	node1.contentSize = CGSizeMake(125, 125);    
    [layer addChild:node1 z: 2 tag: 1];
    
    CCNode *node2 = [RectNode node];
    node2.position = ccp(0.0f * s.width, 0.0f * s.height);
    node2.rotation = 50;
    node2.scaleX = 0.24f;
    node2.scaleY = 0.24f;
    node2.skewX = 0;
    node2.skewY = 0;
    node2.anchorPoint = ccp(0.0f, 0.0f);
    node2.isRelativeAnchorPoint = YES;
	node2.contentSize = CGSizeMake(400, 400);    
    [node1 addChild:node2 z: 4 tag: 2];
    
    CCNode *node3 = [RectNode node];
    node3.position = ccp(node1.contentSize.width + 50, -30);
    node3.rotation = -56;
    node3.scaleX = 2.0f;
    node3.scaleY = 2.0f;
    node3.skewX = 15;
    node3.skewY = 5;
    node3.anchorPoint = ccp(0.75f, 0.25f);
    node3.isRelativeAnchorPoint = YES;
	node3.contentSize = CGSizeMake(30, 30);    
    [node1 addChild:node3 z: 6 tag: 3];
    
    CCNode *node4 = [RectNode node];
    node4.position = ccp(0, 0);
    node4.rotation = 15;
    node4.scaleX = 1.0f;
    node4.scaleY = 1.0f;
    node4.skewX = 0;
    node4.skewY = 0;
    node4.anchorPoint = ccp(0.7f, 0.7f);
    node4.isRelativeAnchorPoint = NO;
	node4.contentSize = CGSizeMake(10, 10);    
    [node3 addChild:node4 z: 8 tag: 4];
    
    CCNode *node5 = [RectNode node];
    node5.position = ccp(0.5f * s.width, 0.5f * s.height);
    node5.rotation = 0;
    node5.scaleX = 1.0f;
    node5.scaleY = 1.0f;
    node5.skewX = 0;
    node5.skewY = 0;
    node5.anchorPoint = ccp(0.5f, 0.5f);
    node5.isRelativeAnchorPoint = YES;
	node5.contentSize = CGSizeMake(50, 50);    
    [layer addChild:node5 z: 10 tag: 5];
    
    CCNode *node6 = [RectNode node];
    node6.position = ccp(0.0f * s.width, 0.5f * s.height);
    node6.rotation = 0;
    node6.scaleX = 0.5f;
    node6.scaleY = 0.5f;
    node6.skewX = 0;
    node6.skewY = 0;
    node6.anchorPoint = ccp(0.0f, 0.5f);
    node6.isRelativeAnchorPoint = YES;
	node6.contentSize = CGSizeMake(45, 45);    
    [node5 addChild:node6 z: 12 tag: 6];
    
    CCNode *node7 = [RectNode node];
    node7.position = ccp(0.4f * s.width, 0.3f * s.height);
    node7.rotation = 116;
    node7.scaleX = 0.8f;
    node7.scaleY = 1.4f;
    node7.skewX = 12;
    node7.skewY = 16;
    node7.anchorPoint = ccp(0.5f, 0.5f);
    node7.isRelativeAnchorPoint = NO;
	node7.contentSize = CGSizeMake(15, 35);    
    [layer addChild:node7 z: 14 tag: 7];
    
    CCNode *node8 = [RectNode node];
    node8.position = ccp(0.75f * s.width, 0.25f * s.height);
    node8.rotation = 415;
    node8.scaleX = 1.5f;
    node8.scaleY = 0.8f;
    node8.skewX = 80;
    node8.skewY = 15;
    node8.anchorPoint = ccp(0.6f, 0.1f);
    node8.isRelativeAnchorPoint = YES;
	node8.contentSize = CGSizeMake(50, 45); 
    // Make it blink to test visible property.
    [node8 runAction:[CCBlink actionWithDuration:256.0f blinks:256]];
	[layer addChild:node8 z: 16 tag: 8];
    
	return layer;
}

- (BOOL) isTagAndZOrderCorrectInNode: (CCNode *) node
{
    for (CCNode *child in node.children)
    {
        if (child.zOrder != 2 * child.tag)
            return NO;
    }
    
    return YES;
}


// Removes layer if at least one of it's children doesnt have zOrder = 2 * tag.
// It can be done better with unit tests, but currently there no unit tests for
// cocos2d-iphone, so i will try to avoid them for AMC-for-Cocos2d tests.
- (void) load
{
    [super load];
    
    CCNode *layer = [self getChildByTag: kLayer];
    
    if (![self isTagAndZOrderCorrectInNode: layer])
    {
        NSLog(@"Z & Tag Test Failed.");
        
        [self removeChildByTag: kLayer cleanup:YES];
    }
    
}

-(NSString *) title
{
	return @"Simple Nodes - AMC";
}

- (NSString *) subtitle
{
    return @"8 nodes should load the same as were saved.";
}
@end

#pragma mark Sprite + SpriteFrame + Texture
@implementation SpriteAMC1

-(CCLayer *) insideLayer
{
	CCLayer *layer = [CCLayer node];
		
    CGSize s = [[CCDirector sharedDirector] winSize];
	CCSprite *sprite = [self spriteWithCoords:ccp(s.width/2, s.height/2)];				
	
    [layer addChild:sprite];
    
	return layer;
}

-(CCSprite *) spriteWithCoords:(CGPoint)p
{
	int idx = CCRANDOM_0_1() * 1400 / 100;
	int x = (idx%5) * 85;
	int y = (idx/5) * 121;
	
	
	CCSprite *sprite = [CCSprite spriteWithFile:@"grossini_dance_atlas.png" rect:CGRectMake(x,y,85,121)];	
	sprite.position = ccp( p.x, p.y);
	
	id action;
	float rand = CCRANDOM_0_1();
	
	if( rand < 0.20 )
		action = [CCScaleBy actionWithDuration:3 scale:2];
	else if(rand < 0.40)
		action = [CCRotateBy actionWithDuration:3 angle:360];
	else if( rand < 0.60)
		action = [CCBlink actionWithDuration:1 blinks:3];
	else if( rand < 0.8 )
		action = [CCTintBy actionWithDuration:2 red:0 green:-255 blue:-255];
	else 
		action = [CCFadeOut actionWithDuration:2];
	id action_back = [action reverse];
	id seq = [CCSequence actions:action, action_back, nil];
	
	[sprite runAction: [CCRepeatForever actionWithAction:seq]];
    
    return sprite;
}

-(NSString *) title
{
	return @"Simple Sprite - AMC";
}

- (NSString *) subtitle
{
    return @"It should load the same as was saved.";
}
@end

// TODO: Node + CCCamera (not supported by AMC now)
// TODO: Node + CCGridBase (not supported by AMC now)
// TODO: Node + vertexZ (should work, just got no explicit test)

// TODO: Sprite + Blend Func (should work, just got no explicit test)

// TODO: Sprite + flipX + flipY; (should work, just got no explicit test)
// TODO: SpriteBatchNode + honorParentTransform; (not supported by AMC now)

//  TODO: more to go:
// ---------------------
//
// * CCLayer - currently saved as node - without mouse, keyboard, touch & accelerometer. Add keys to AMCKeys
// * CCLayerColor
// * CCLayerGradient
// * CCLayerMultiplex
//
// * CCAtlasNode - should be pretty easy, but i never used it - dunno if i can provide good test.
//
// * CCLabelAtlas - very easy after supporting CCAtlasNode
//
// * CCTextureAtlas - just save texture & capacity & use initWithFile:capacity: and you should be ok.
//
// * CCSpriteBatchNode - don't save @"descendants" & you'll be cool.
//
// * CCLabelMBFont - some work needed (3 structs, 1 additional class), but should be straight forward after BatchNode.
//
// * CCLabelTTF - hackish stuff - it's subclass of CCSprite & it creates custom texture each time. But i think it's possible
// just don't save the texture =).
//
// * CCAnimation - should work out of the box, cause CCSpriteFrame is ready.
//
// * CCMenu - straight-forward. Only selectedItem should be saved as selectedItemIndex number with dynamic setter.
//
// * CCMenuItems - lot of work, especially for Label menu items, but it should be ok. Will not save invocation & blocks, of course.
// Developer should use CCNode name & CCNodeCache to set blocks/invocations.
//
// * CCParalaxNode - pretty easy, just need to save CGPointObject's in parallaxRatio array & then use it in
// -initWithDictionaryRepresentation: for parallaxRatio argument, when reading childs from loadedChildren.
//
// * CCTMXTiledMap - incomplete support. Save only tmx filename. It's supported by
// cocos2d-iphone. The only issue is that if you're changed something after loading tmx
// - this will not be saved (full support is added in  "Possible future features" section below )
//
// * CCScene - should work without any modifications - cause it's simple CCNode.
// * CCTransition & it's subclasses - should be VERY simple. Should we really support this??????????
//
// * CCProgressTimer - straight-forward.
//
// ====== ACTIONS ======
//
// * CCAction - just save tag. target & original target will be set on runAction.
//    Add -allActionsForTarget: to CCActionManager to retreive all actions.
//    Add dynamic property - array of actions.
//    For getter - use CCActionManager#allActionsForTarget:
//    For setter - use runAction
//
// * CCFiniteTimeAction - save tag & duration.
//
// * CCRepeatForever - save tag & innerAction.
//
// * CCSpeed - save tag speed & innerAction.
//
// * CCFollow - change followedNode to followedNodeName - simple!
//      boundarySet(simple BOOL), boundaryRect (need to calculate it back to rect 
//      from 4 floats on save.)
//      To load CCFollow - just set followedNode on first CCAction#update: call - at this time
//      node should alredy exist in CCNodeCache.
//
// TODO: investigate further.
//
// TODO: Look through cocos2d-iphone documentation for any classes, that i may have
// skipped here & that we need to support.
//
//
// ====== New Cocos2D-iPhone Features & Classes for AMC ======
// 1. CCNodeCache & CCNode.name property
//   * CCNode.name: to use in CCNodeCache, default value is nil.
//       CCNode.name is dynamic property - all CCNodeCache calls must be done only from
//       CCNode#setName setter. If name set to nil - node must be removed from CCNodeCache.
//       If node name is changed  - node should change it's name in CCNodeCache.
//       If node name is set first time - node should register in CCNodeCache.
//       On dealloc node sets it's name to nil - and this removes node from cache.
//   * CCNodeCache SHOULDN'T retain Nodes. 
//
// ====== Possible future features ======
//  * CCTimer & scheduled methods. (Not used by Cocos2D-iPhone classes 
// themselves - should be used by developer expicitly ).
//  * CCParticleBatchNode & other from "Particle Nodes" - OMG, fucking particles! Anyway - it should be possible, just needs time.
//  * Full support for CCTMXLayer, CCTMXObjectGroup, CCTMXTiledMap. That means that you can change something & it will be saved with changes.
//  *
//
// ====== Not to be supported by AMC =====
//
// 1. Can't imagine someone need to save/load this.
//  * CCGrabber, 
//  * CCRenderTexture, 
//  * CCRibbon,
//  * CCMotionStreak
//
// 2. CCTileMapAtlas - DEPRECATED. 
//
//
//




#pragma mark -
#pragma mark AppDelegate

// CLASS IMPLEMENTATIONS

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// must be called before any othe call to the director
	[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];
//	[CCDirector setDirectorType:kCCDirectorTypeThreadMainLoop];
	
	// before creating any layer, set the landscape mode
	CCDirector *director = [CCDirector sharedDirector];
	
	// landscape orientation
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// set FPS at 60
	[director setAnimationInterval:1.0/60];
	
	// Display FPS: yes
	[director setDisplayFPS:YES];

	// Create an EAGLView with a RGB8 color buffer, and a depth buffer of 24-bits
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// attach the openglView to the director
	[director setOpenGLView:glView];

	// 2D projection
//	[director setProjection:kCCDirectorProjection2D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// make the OpenGLView a child of the main window
	[window addSubview:glView];
	
	// make main window visible
	[window makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// create the main scene
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	
	// and run it!
	[director runWithScene: scene];
	
	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
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
	[[director openGLView] removeFromSuperview];
	[director end];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end

#pragma mark -
#pragma mark AppController - Mac

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director setResizeMode:kCCDirectorResize_AutoScale];	
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene:scene];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
#endif
