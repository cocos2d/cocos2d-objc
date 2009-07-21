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
};

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
	
		CGSize s = [[Director sharedDirector] winSize];
		
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		
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
	Scene *s = [Scene node];
	[s addChild: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark Example LayerTest1

@implementation LayerTest1
-(id) init
{
	if( (self=[super init] )) {
		
		self.isTouchEnabled = YES;
		
		CGSize s = [[Director sharedDirector] winSize];
		ColorLayer* layer = [ColorLayer layerWithColor: ccc4(0xFF, 0x00, 0x00, 0x80)
												 width: 200 
												height: 200];
		layer.relativeAnchorPoint =  YES;
		layer.position = ccp(s.width/2, s.height/2);
		[self addChild: layer z:1 tag:kTagLayer];
	}
	return self;
}

-(void) registerWithTouchDispatcher
{
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

-(void) updateSize:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[Director sharedDirector] convertCoordinate: touchLocation];
	
	CGSize s = [[Director sharedDirector] winSize];
	
	CGSize newSize = CGSizeMake( abs( touchLocation.x - s.width/2)*2, abs(touchLocation.y - s.height/2)*2);
	
	ColorLayer *l = (ColorLayer*) [self getChildByTag:kTagLayer];

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
	return @"ColorLayer resize (tap & move)";
}
@end

#pragma mark Example LayerTest2

@implementation LayerTest2
-(id) init
{
	if( (self=[super init] )) {
		
		CGSize s = [[Director sharedDirector] winSize];
		ColorLayer* layer1 = [ColorLayer layerWithColor: ccc4(255, 255, 0, 80)
												 width: 100 
												height: 300];
		layer1.position = ccp(s.width/3, s.height/2);
		layer1.relativeAnchorPoint = YES;
		[self addChild: layer1 z:1];
		
		ColorLayer* layer2 = [ColorLayer layerWithColor: ccc4(0, 0, 255, 255)
												 width: 100 
												height: 300];
		layer2.position = ccp((s.width/3)*2, s.height/2);
		layer2.relativeAnchorPoint = YES;
		[self addChild: layer2 z:1];
		
		id actionTint = [TintBy actionWithDuration:2 red:-255 green:-127 blue:0];
		id actionTintBack = [actionTint reverse];
		id seq1 = [Sequence actions: actionTint, actionTintBack, nil];
		[layer1 runAction:seq1];


		id actionFade = [FadeOut actionWithDuration:2.0f];
		id actionFadeBack = [actionFade reverse];
		id seq2 = [Sequence actions:actionFade, actionFadeBack, nil];		
		[layer2 runAction:seq2];

	}
	return self;
}

-(NSString *) title
{
	return @"ColorLayer: fade and tint";
}
@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];	
	
	Scene *scene = [Scene node];
	[scene addChild: [nextAction() node]];
	
	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end
