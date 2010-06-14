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
	
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLabel* label = [CCLabel labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
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
@end

#pragma mark -
#pragma mark Example LayerTest1

@implementation LayerTest1
-(id) init
{
	if( (self=[super init] )) {
		
		self.isTouchEnabled = YES;
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCColorLayer* layer = [CCColorLayer layerWithColor: ccc4(0xFF, 0x00, 0x00, 0x80)
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
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

-(void) updateSize:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CGSize newSize = CGSizeMake( abs( touchLocation.x - s.width/2)*2, abs(touchLocation.y - s.height/2)*2);
	
	CCColorLayer *l = (CCColorLayer*) [self getChildByTag:kTagLayer];

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

#pragma mark -
#pragma mark Example LayerTest2

@implementation LayerTest2
-(id) init
{
	if( (self=[super init] )) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCColorLayer* layer1 = [CCColorLayer layerWithColor: ccc4(255, 255, 0, 80)
												 width: 100 
												height: 300];
		layer1.position = ccp(s.width/3, s.height/2);
		layer1.isRelativeAnchorPoint = YES;
		[self addChild: layer1 z:1];
		
		CCColorLayer* layer2 = [CCColorLayer layerWithColor: ccc4(0, 0, 255, 255)
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
	return @"ColorLayer: fade and tint";
}
@end

#pragma mark -
#pragma mark Example LayerTestBlend

@implementation LayerTestBlend
-(id) init
{
	if( (self=[super init] )) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCColorLayer* layer1 = [CCColorLayer layerWithColor: ccc4(255, 255, 255, 80)];
		
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
	CCColorLayer *layer = (CCColorLayer*) [self getChildByTag:kTagLayer];
	if( layer.blendFunc.dst == GL_ZERO )
		[layer setBlendFunc: (ccBlendFunc) { CC_BLEND_SRC, CC_BLEND_DST } ];
	else
		[layer setBlendFunc:(ccBlendFunc){GL_ONE_MINUS_DST_COLOR, GL_ZERO}];

}

-(NSString *) title
{
	return @"ColorLayer: blend";
}
@end


#pragma mark -
#pragma mark AppController

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. Attaches to the main window
	// 3. Creates Display Link Director
	// 3a. If it fails, it will use an NSTimer director
	// 4. It will try to run at 60 FPS
	// 4. Display FPS: NO
	// 5. Device orientation: Portrait
	// 6. Connect the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
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
