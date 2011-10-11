//
// Parallax Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "LayerTest.h"

enum {
	kTagLayer = 1,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"LayerTest1",
	@"LayerTest2",
	@"LayerTestBlend",
	@"LayerGradient",

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


@implementation LayerTest
-(id) init
{
	if( (self=[super init])) {
	
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
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
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
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

-(NSString*) subtitle
{
	return nil;
}
@end

#pragma mark -
#pragma mark Example LayerTest1

@implementation LayerTest1
-(id) init
{
	if( (self=[super init] )) {
		
		self.isTouchEnabled = YES;
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer = [CCLayerColor layerWithColor: ccc4(0xFF, 0x00, 0x00, 0x80)
												 width: 200 
												height: 200];
		layer.isRelativeAnchorPoint =  YES;
		layer.position = ccp(s.width/2, s.height/2);
		[self addChild: layer z:1 tag:kTagLayer];
	}
	return self;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority+1 swallowsTouches:YES];
}

-(void) updateSize:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CGSize newSize = CGSizeMake( abs( touchLocation.x - s.width/2)*2, abs(touchLocation.y - s.height/2)*2);
	
	CCLayerColor *l = (CCLayerColor*) [self getChildByTag:kTagLayer];

//	[l changeWidth:newSize.width];
//	[l changeHeight:newSize.height];
//	[l changeWidth:newSize.width height:newSize.height];

	[l setContentSize: newSize];
}
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self updateSize:touch];

	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self updateSize:touch];
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self updateSize:touch];
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self updateSize:touch];
}


-(NSString *) title
{
	return @"LayerColor resize (tap & move)";
}
@end

#pragma mark -
#pragma mark Example LayerTest2

@implementation LayerTest2
-(id) init
{
	if( (self=[super init] )) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer1 = [CCLayerColor layerWithColor: ccc4(255, 255, 0, 80)
												 width: 100 
												height: 300];
		layer1.position = ccp(s.width/3, s.height/2);
		layer1.isRelativeAnchorPoint = YES;
		[self addChild: layer1 z:1];
		
		CCLayerColor* layer2 = [CCLayerColor layerWithColor: ccc4(0, 0, 255, 255)
												 width: 100 
												height: 300];
		layer2.position = ccp((s.width/3)*2, s.height/2);
		layer2.isRelativeAnchorPoint = YES;
		[self addChild: layer2 z:1];
		
		id actionTint = [CCTintBy actionWithDuration:2 red:-255 green:-127 blue:0];
		id actionTintBack = [actionTint reverse];
		id seq1 = [CCSequence actions: actionTint, actionTintBack, nil];
		[layer1 runAction:seq1];


		id actionFade = [CCFadeOut actionWithDuration:2.0f];
		id actionFadeBack = [actionFade reverse];
		id seq2 = [CCSequence actions:actionFade, actionFadeBack, nil];		
		[layer2 runAction:seq2];

	}
	return self;
}

-(NSString *) title
{
	return @"LayerColor: fade and tint";
}
@end

#pragma mark -
#pragma mark Example LayerTestBlend

@implementation LayerTestBlend
-(id) init
{
	if( (self=[super init] )) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLayerColor* layer1 = [CCLayerColor layerWithColor: ccc4(255, 255, 255, 80)];
		
//		id actionTint = [CCTintBy actionWithDuration:0.5f red:-255 green:-127 blue:0];
//		id actionTintBack = [actionTint reverse];
//		id seq1 = [CCSequence actions: actionTint, actionTintBack, nil];
//		[layer1 runAction: [CCRepeatForever actionWithAction:seq1]];
		
		
		CCSprite *sister1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sister2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		
		[self addChild:sister1];
		[self addChild:sister2];
		[self addChild: layer1 z:100 tag:kTagLayer];
		
		sister1.position = ccp( 160, s.height/2);
		sister2.position = ccp( 320, s.height/2);

		[self schedule:@selector(newBlend:) interval:1];
	}
	return self;
}

-(void) newBlend:(ccTime)dt
{
	CCLayerColor *layer = (CCLayerColor*) [self getChildByTag:kTagLayer];
	if( layer.blendFunc.dst == GL_ZERO )
		[layer setBlendFunc: (ccBlendFunc) { CC_BLEND_SRC, CC_BLEND_DST } ];
	else
		[layer setBlendFunc:(ccBlendFunc){GL_ONE_MINUS_DST_COLOR, GL_ZERO}];

}

-(NSString *) title
{
	return @"LayerColor: blend";
}
@end

#pragma mark -
#pragma mark Example LayerGradient

@implementation LayerGradient
-(id) init
{
	if( (self=[super init] )) {
		
		CCLayerGradient* layer1 = [CCLayerGradient layerWithColor:ccc4(255,0,0,255) fadingTo:ccc4(0,255,0,255) alongVector:ccp(0.9f, 0.9f)];

		[self addChild:layer1 z:0 tag:kTagLayer];
		
		self.isTouchEnabled = YES;
		
		CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Compressed Interpolation: Enabled" fontName:@"Marker Felt" fontSize:26];
		CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Compressed Interpolation: Disabled" fontName:@"Marker Felt" fontSize:26];
		CCMenuItemLabel *item1 = [CCMenuItemLabel itemWithLabel:label1];
		CCMenuItemLabel *item2 = [CCMenuItemLabel itemWithLabel:label2];
		CCMenuItemToggle *item = [CCMenuItemToggle itemWithTarget:self selector:@selector(toggleItem:) items:item1, item2, nil];
		
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		CGSize s = [[CCDirector sharedDirector] winSize];
		[menu setPosition:ccp(s.width/2, 100)];
	}
	return self;
}

-(void) toggleItem:(id)sender
{
	CCLayerGradient *gradient = (CCLayerGradient*) [self getChildByTag:kTagLayer];
	[gradient setCompressedInterpolation: ! gradient.compressedInterpolation];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGSize s = [[CCDirector sharedDirector] winSize];

	UITouch *touch = [touches anyObject];
	CGPoint start = [touch locationInView: [touch view]];	
	start = [[CCDirector sharedDirector] convertToGL: start];
	
	CGPoint diff = ccpSub( ccp(s.width/2,s.height/2), start);	
	diff = ccpNormalize(diff);
	
	CCLayerGradient *gradient = (CCLayerGradient*) [self getChildByTag:1];

	[gradient setVector:diff];
}

-(NSString *) title
{
	return @"LayerGradient";
}

-(NSString *) subtitle
{
	return @"Touch the screen and move your finger";
}
@end

#pragma mark -
#pragma mark AppController

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
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
						];
	
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
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	[director runWithScene: scene];
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

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
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
