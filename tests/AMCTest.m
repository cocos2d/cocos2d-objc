//
// AutoMagicCoding Additonal Tests/Demo
// (For other AMC tests - see other Cocos2D-iPhone demos)
//
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
    @"LayersAMC",
    @"ParallaxAMC",
    @"ProgessTimerAMC",
    @"SceneAMC",
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
    kParallax, //< parallax node in Parallax test.
    
    kAMCTestMenu,
    kSavePurgeLoadToggle,
};

static NSString *const kAMCTestLayerName = @"curAMCTestLayer";

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
        trigger.tag = kSavePurgeLoadToggle;
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, trigger, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
        trigger.position = ccp( s.width/2, 80);
		[self addChild: menu z:1 tag: kAMCTestMenu];	
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

#pragma mark -

@interface CCLayerMultiplex(flipFlop)
- (void) flip;
@end

@implementation CCLayerMultiplex(flipFlop)
- (void) flip
{
    static unsigned int l = 0;
    
    [self switchTo: l];
    
    l++;
    if (l>1)
        l = 0;
}
@end


@implementation LayersAMC

- (CCAction *) flipFlopActionForMulti: (CCLayerMultiplex *) multi
{
    return [CCRepeatForever actionWithAction: 
            [CCSequence actions: 
             [CCDelayTime actionWithDuration:0.5f],
             [CCCallFunc actionWithTarget: multi selector:@selector(flip)],
             [CCDelayTime actionWithDuration:0.5f],
             [CCCallFunc actionWithTarget: multi selector:@selector(flip)],
             nil]
            ];
}

- (void) load
{
    [super load];
    
    // Start CCLayerMultiplex flipFlop action after loading to demonstrate, that
    // it saves/loads as expected.
    CCLayerMultiplex *layer = (CCLayerMultiplex *)[self getChildByTag:kLayer];
    [layer runAction:[self flipFlopActionForMulti: layer]];
}

-(CCLayer *) insideLayer
{    
	CCLayer *layer = [CCLayer node];
    
    CGSize s = [[CCDirector sharedDirector] winSize];
	CCLayerColor *color1 = [CCLayerColor layerWithColor:ccc4(0x96, 0x51, 0x17, 0xFF) width: s.width/2 height:s.height/2];		
    CCLayerColor *color2 = [CCLayerColor layerWithColor:ccc4(0xFF, 0x51, 0x17, 0xAA) width: s.width/4 height:s.height/4];
    CCLayerGradient *grad1 = [CCLayerGradient layerWithColor: ccc4(0xFF, 0x17, 0x17, 0xFF)
                                                    fadingTo: ccc4(0x11, 0xFF, 0x17, 0xCC) 
                                                 alongVector: ccp(0.5f, 1.0f)];
    CCLayerGradient *grad2 = [CCLayerGradient layerWithColor: ccc4(0xAA, 0x51, 0xFF, 0xDD)
                                                    fadingTo: ccc4(0x0F, 0x51, 0xFF, 0xCC) 
                                                 alongVector: ccp(0.3f, 1.0f)];
    grad2.contentSize = CGSizeMake(s.width/6, s.height/6);
    grad2.rotation = 45;
    
    color1.position = ccp(s.width/2, s.height/2);
    color2.position = ccp(s.width/4, s.height/2);
    color1.anchorPoint = ccp(0.5f, 0.5f);
    color2.anchorPoint = ccp(0.5f, 0.5f);
    color2.rotation = 45;
    color1.isRelativeAnchorPoint = YES;
    color2.isRelativeAnchorPoint = YES;
    grad2.isRelativeAnchorPoint = YES;
    grad2.anchorPoint = ccp(0.5f, 0.5f);
    grad2.position = ccp(s.width/4, s.height/4);
	
    [layer addChild:grad1];
    [layer addChild:color1];
    [layer addChild:color2];
    [layer addChild:grad2];
    
    CCLayerColor *anotherLayer = [CCLayerColor layerWithColor: ccc4(255, 0, 0, 255)];
    CCLayerMultiplex *multi = [CCLayerMultiplex layerWithLayers: layer, anotherLayer, nil];
    [multi runAction:[self flipFlopActionForMulti: multi]];
	return multi;
}

-(NSString *) title
{
	return @"CCLayer (Color, Gradient & Multiplex)";
}

- (NSString *) subtitle
{
    return @"They should load the same as were saved.";
}

@end

#pragma mark -

@interface ParallaxAMCInsideLayer : CCLayer
@end

@implementation ParallaxAMCInsideLayer

-(id) init
{
	if( (self=[super init] )) {
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
		
		// Top Layer, a simple image
		CCSprite *cocosImage = [CCSprite spriteWithFile:@"powered.png"];
		// scale the image (optional)
		cocosImage.scale = 2.5f;
		// change the transform anchor point to 0,0 (optional)
		cocosImage.anchorPoint = ccp(0,0);
		
		
		// Middle layer: a Tile map atlas
		CCSprite *tilesImage =  [CCSprite spriteWithFile: @"TileMaps/tiles.png" ];
		
		// change the transform anchor to 0,0 (optional)
		tilesImage.anchorPoint = ccp(0, 0);        
		
		
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
		[voidNode addChild:tilesImage z:1 parallaxRatio:ccp(1.0f,1.0f) positionOffset:ccp(0,-200)];
		
		// top image is moved at a ratio of 3.0x, 2.5y
		[voidNode addChild:cocosImage z:2 parallaxRatio:ccp(3.0f,2.5f) positionOffset:ccp(200,500)];
		[self addChild:voidNode z:0 tag:kParallax];
        
	}
	
	return self;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
    
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
    
	CGPoint diff = ccpSub(touchLocation,prevLocation);
	
	CCNode *node = [self getChildByTag:kParallax];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, diff)];
}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

-(BOOL) ccMouseDragged:(NSEvent *)event
{
	CCNode *node = [self getChildByTag:kParallax];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, CGPointMake( event.deltaX, -event.deltaY) )];
	
	return YES;
}

#endif

@end

@implementation ParallaxAMC

- (CCLayer *) insideLayer
{
    return [ParallaxAMCInsideLayer node];
}

-(NSString *) title
{
	return @"Parallax: drag screen";
}

@end

@implementation ProgessTimerAMC

- (CCLayer *) insideLayer
{
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    CCLayer *layer = [CCLayer node];
    
    CCProgressTimer *timer1 = [CCProgressTimer progressWithFile:@"blocks.png"];
    CCProgressTimer *timer2 = [CCProgressTimer progressWithFile:@"grossini.png"];
    CCProgressTimer *timer3 = [CCProgressTimer progressWithFile:@"b1.png"];
    CCProgressTimer *timer4 = [CCProgressTimer progressWithFile:@"b1.png"];
    CCProgressTimer *timer5 = [CCProgressTimer progressWithFile:@"grossini.png"];
    CCProgressTimer *timer6 = [CCProgressTimer progressWithFile:@"grossini.png"];
    
    timer1.type = kCCProgressTimerTypeVerticalBarTB;
    timer2.type = kCCProgressTimerTypeRadialCW;
    timer3.type = kCCProgressTimerTypeHorizontalBarLR;
    timer4.type = kCCProgressTimerTypeHorizontalBarRL;
    timer5.type = kCCProgressTimerTypeVerticalBarBT;
    timer6.type = kCCProgressTimerTypeRadialCCW;
    
    // TODO: looks like progressTimers (especially radial) don't like anchorPoint,
    // other than default one. Report a bug.
    
    timer1.position = ccp(120, s.height - 120);
    timer2.position = ccp(0.5f * s.width, s.height - 120);
    timer3.position = ccp(s.width - 120, s.height - 120);
    timer4.position = ccp(120, 120);
    timer5.position = ccp(0.5f * s.width, 120);
    timer6.position = ccp(s.width - 120, 120);
    
    CCProgressFromTo *percentsAction = [CCProgressFromTo actionWithDuration:3.0f from: 0 to: 100];
    
    [timer1 runAction:[CCRepeatForever actionWithAction: [percentsAction copy]]];
    [timer2 runAction:[CCRepeatForever actionWithAction: [percentsAction copy]]];
    [timer3 runAction:[CCRepeatForever actionWithAction: [percentsAction copy]]];
    [timer4 runAction:[CCRepeatForever actionWithAction: [percentsAction copy]]];
    [timer5 runAction:[CCRepeatForever actionWithAction: [percentsAction copy]]];
    [timer6 runAction:[CCRepeatForever actionWithAction: [percentsAction copy]]];
    
    [layer addChild: [CCLayerColor layerWithColor: ccc4(0xFF, 0xFF, 0xFF, 0x40)]];
    [layer addChild:timer1];
    [layer addChild:timer2];
    [layer addChild:timer3];
    [layer addChild:timer4];
    [layer addChild:timer5];
    [layer addChild:timer6];
    
    return layer;
}

- (NSString *) title
{
    return @"CCProgressTimer";
}

- (NSString *) subtitle
{
    return @"All timers should load the same as was saved.";
}


@end


@implementation SceneAMC

- (id) init
{
    [super init];
    if (self)
    {
        // Set name to make it possible to load target/selector for CCMenuItems.
        self.name = kAMCTestLayerName;
        
        // Remove standard save/purge/load.
        CCNode *menu = [self getChildByTag: kAMCTestMenu];
        [menu removeChildByTag:kSavePurgeLoadToggle cleanup:YES];
    }
    
    return self;
}

- (CCLayer *) insideLayer
{
    CGSize s = [CCDirector sharedDirector].winSize;
    
    CCLayer *layer = [CCLayer node];
    
    CCMenuItemLabel *load = [CCMenuItemLabel itemWithLabel: [CCLabelTTF labelWithString: @"Load" fontName: @"Marker Felt" fontSize:48]];
    [load setTarget:self selector:@selector(loadScene:)];
    
    CCMenu *menu = [CCMenu menuWithItems:load, nil];
    
    menu.position = CGPointZero;
    load.position = ccp( s.width/2, 160);
    [layer addChild: menu];
    
    return layer;
}

- (NSString *) sceneFilePath
{
    NSString *filename = [NSString stringWithFormat:@"SceneAMC.plist", [self className] ];
    
    NSArray *paths					= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory	= [paths objectAtIndex:0];
	NSString *path                  = [documentsDirectory stringByAppendingPathComponent: filename ];
    
    return path;
}

- (void) saveScene
{
    NSDictionary *dict = [self.parent dictionaryRepresentation];
    [dict writeToFile:[self sceneFilePath] atomically:YES];
}

- (void) loadScene: (id) sender
{
    NSString *path = [self sceneFilePath];    
    
    NSDictionary *aDict = [NSDictionary dictionaryWithContentsOfFile: path];
    CCScene *scene = [NSObject objectWithDictionaryRepresentation: aDict ];    
    
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1.0f scene:scene backwards:NO]];
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    [self saveScene];
}

- (NSString *) title
{
    return @"Load CCScene";
}

- (NSString *) subtitle
{
    return @"Press load to reload cur scene from AMC.";
}
@end

//
// TODO: Use these notes for pull request info.
// Update them regularly.
//

//
// ====== Supported by AMC =====
//
// 1. Basic Nodes
//      * CCNode - FULL SUPPORT
//          * Children & all properties except for Camera & Grid ( tested in AMCTest.m in NodeAMC )
//          * CCCamera ( tested in SpriteTest.m in SpriteZVertex )
//          * CCGrid ( tested in EffectsAdvancedTest.m in Effect1, Effect2, etc... )
//          * Name & CCNodeRegistry (tested in MenuTest - weak links to children & targets for menuItems)
//      * CCLayer - FULL SUPPORT ( tested in AMCTest.m LayersAMC )
//          * CCLayerColor ( tested in AMCTest.m LayersAMC )
//          * CCLayerGradient ( tested in AMCTest.m LayersAMC )
//          * CCLayerMultiplex 
//
// 2. Sprites - FULL SUPPORT (tested in SpriteTest.m - AMCTest functionality added to existing test)
//      * CCSprite
//      * CCSpriteFrame (key for CCSpriteFrameCache not saved yet - all SpriteFrames will be independent after loading).
//      * CCSpriteBatchNode
//
// 3. Textures - ALL NEEDED SUPPORT
//      * CCTexture2D - only key for CCTextureCache saved (no custom texture support).
//          As Riq said on forums: "serializing the TextureCache is sort of hackish." 
//          ( http://www.cocos2d-iphone.org/forum/topic/16980#post-95815 )
//          So we will save only key (filepath) for Texture, making developer responsible 
//          for creating custom texture on deserialization 
//          (-initWithDictionaryRepresentation: method) or saving generated texture to
//          documents or cache folder & setting it's key to that path, so next time it could 
//          be loaded from there.
//      * CCTextureAtlas - Saves CCTexture2D (via key) & capacity (Tested in SpriteTest.m).
//          (Used by CCSpriteBatchNode, so tested everywhere where BatchNode is tested.)
//      * CCTextureCache - not supported - not needed. 
//          (Can be saved as array of texture keys - can be useful for preloading all
//          needed for scene textures)
//
// 4. Labels - FULL SUPPORT (Tested in LabelTest.m)
//      * CCAtlasNode - FULL SUPPORT (not tested independently, but used only by CCLabelAtlas)
//      * CCLabelAtlas - FULL SUPPORT
//      * CCLabelTTF - MAC SUPPORT (iOS also should work, but i tested only on a Mac)
//      * CCLabelMBFont - FULL SUPPORT by Magic. True magic... Tested only on a Mac, but...
//          You know - i'll better just trust the Magic, cause Magic is VERY powerfull!
//
// 5. Menus - FULL POSSIBLE SUPPORT
//      * CCMenu - FULL SUPORT
//      * CCMenuItem - ALL SUBCLASSES SUPPORTED:
//          * CCMenuItemLabel
//          * CCMenuItemAtlasFont
//          * CCMenuItemFont
//          * CCMenuItemSprite
//          * CCMenuItemImage
//          * CCMenuItemToggle
//
//        Target saved as name of CCNode in CCNodeRegistry, selecter saved as 
//        NSString. It's impossible to save Blocks - user should manually restore
//        them after loading 
//              (CCNodeRegistry can be used to obtain target nodes).
//
// 6. More Nodes
//      * CCParallaxNode - FULL SUPPORT (tested in AMCTest.m ParallaxAMC)
//      * CCProgressTimer - FULL SUPPORT (tested in AMCTest.m ProgressTimerAMC)
//        (btw found a bug - different acnhorPoints for radial timers aren't supported)
//

//
//
// What's new
// ===========
//
// 1. Cocos2D-iPhone Sources:
//      1. ADDED: cocos2d/AutoMagicCoding - AMC submodule
//          TODO: remove submodule, use easier path, update all files , that uses that path.
//
//      2. CHANGED: Many cocos2d classes, that now have AMC Support (see notes above).
//
//      3. ADDED: CCNodeRegistry - central key-value (by name string) for nodes, that
//              doesn't retain nodes (Used for restoring links after loading, such as
//              CCMenuItem target & other).
//
//      4. REMOVED: CCBlocksAdditions category & CCBlockSupport.m (only implementation file
//              header is still used) - CCMenuItem was refactored a little for
//              better AMC support, now blocks used directly, but it's still 
//              backward compatible with old iOS versions & now you can set
//              target/selector or block after creating CCMenuItem (or it's subclasses).
//
// 2. Tests:
//      1. ADDED: New test target: AMCTest - includes additional tests for AMC:
//          * NodeAMC - Simple node properties/hierarchy test.
//          * LayersAMC - Test for CCLayer, CCLayerColor, CCLayerGradient & CCLayerMultiplex.
//              (There was no Layers test before - so added new one).
//          * ParallaxAMC - Test for AMC-Support CCParallaxNode with AMC-Supported children.
//              (Used instead of existing test, cause it includes deprecated class children,
//              that will not be supported by AMC).
//          * ProgressTimerAMC - Test for CCProgressTimer AMC Support (there was no test for
//              progressTimer before).
//          * SceneAMC - explicit test for whole CCScene test.
//
//      2. CHANGED: Existing tests - added save/purge/load toggle menu item. 
//

//
// ====== Not Supported =====
//
// 1. Possible in the future releases:
//
//    * CCParticleBatchNode & other from "Particle Nodes" - OMG, lot of iVars & structs! 
//      Anyway - it should be possible, just needs time.
//
//    * CCTMXLayer, CCTMXObjectGroup, CCTMXTiledMap. With ability to change something & it will be saved with changes.
//
//    * CCTransitions - Low priority feature. Easy to save, hard to test.
//      Only if do first ammount of tests that saves transition & 2nd - that loads it.
//
//    * CCRibbon  - probably hard to support
//
//    * CCMotionStreak - uses CCRibon.
//
//
// 2. Probably not to be supported by AMC
//
//  * CCTimer & scheduled methods. (Not used by Cocos2D-iPhone classes 
//      themselves - should be used by developer expicitly ).
//   * CCGrabber (helper class), 
//   * CCRenderTexture (helper class), 
//   * CCTileMapAtlas (DEPRECATED (Will be removed from Cocos2D-iPhone in 1.0+ )). 
//
//


//
//
//
// DON'T MESS WITH 
//     .___  ___.      ___       _______  __    ______ 
//     |   \/   |     /   \     /  _____||  |  /      |
//     |  \  /  |    /  ^  \   |  |  __  |  | |  ,----'
//     |  |\/|  |   /  /_\  \  |  | |_ | |  | |  |     
//     |  |  |  |  /  _____  \ |  |__| | |  | |  `----.
//     |__|  |__| /__/     \__\ \______| |__|  \______|
//
//

// ====== Current TODO: =======
//

//
// TODO: Look through cocos2d-iphone documentation & sources carefully for any 
// classes, that i may have skipped here & that we need to support.
//

// Right after that:
//
// 1. Update iOS project, test & fix if needed.
//
// 2. Check issues & TODOs in code - try to close them.
//
// 3. Think what to do NeXT ;)
//    * Start developing an editor without actions support. 
//  OR
//    * ADD actions support. 
//  OR
//    * Start doing a pull-request and:
//      * Add actions support.
//     OR
//      * Start developing an editor without actions support. 
//
//      Mmmmm.... Sweet time to make a decision... 
//      Take your time. Feeeeeeeeel it. Enjoy it.
//

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
//

//
// ======= TODO: Animation =====
//
// * CCAnimation - should work out of the box, cause CCSpriteFrame is ready.
// Just some additional logic must be added to recache used animations & spriteFrames.
// Look for TODOs for Issue #9.
//      
//
// Для того чтобы экономить память и хранить Анимации И Кадры в едином месте 
// удобном для редактирования - необходимо ввести понятие key в CCSpriteFrame
// и в CCAnimation.
//
// CCAnimation использует те же самые кадры, которые ей дали.
// ССAnimate использует ту же самую анимацию, что ей дали.
//
// Обычно CCAnimation & CCSpriteFrame поступают из одного места и сохранены по 
// каким-то ключам в своих кешах.
// Так что делаем следующим образом:
// 1. Когда сохраняем анимацию в кеше - задаем ей имя. Когда выкидываем - убираем ей имя.
// 2. Когда сохраняем анимацию - сохраняем ее имя (не проверяем закешировано ли 
//    - для того, чтобы можно было сохранить анимацию на будущее для шары с другими, 
//    даже если она не в кеше) и все данные - всегда.
// 3. Когда грузим - проверяем есть ли в кеше уже с таким именем
//   * Если нет - добавляем
//   * Если есть - используем повторно всегда, но проверяем равны ли,
//   * Не равны - говорим об этом
//   * Равны - все ок.
//

//
// ====== TODO: More Tests =====
//
// TODO: Sprite + Blend Func (should work, just got no explicit test)
// TODO: Animation key (Issue #9) test. 




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
