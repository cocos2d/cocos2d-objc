//
// Parallax Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "ActionManagerTest.h"

enum {
	kTagNode,
	kTagGrossini,
	kTagSister,
	kTagSlider,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
			@"CrashTest",
			@"LogicTest",
			@"PauseTest",
			@"ScaleTest",
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

#pragma mark -
#pragma mark ActionManagerTest

@implementation ActionManagerTest
-(id) init
{
	[super init];


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
#pragma mark CrashTest

@implementation CrashTest
-(id) init
{
	if( (self=[super init] )) {
		

		CCSprite *child = [CCSprite spriteWithFile:@"grossini.png"];
		[child setPosition:ccp(200,200)];
		[self addChild:child z:1];

		//Sum of all action's duration is 1.5 second.
		[child runAction:[CCRotateBy actionWithDuration:1.5f angle:90]];
		[child runAction:[CCSequence actions:
						  [CCDelayTime actionWithDuration:1.4f],
						  [CCFadeOut actionWithDuration:1.1f],
						  nil]
		];
		
		//After 1.5 second, self will be removed.
		[self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:1.4f],
						 [CCCallFunc actionWithTarget:self selector:@selector(removeThis)],
						 nil]
		];
	}
	
	return self;
	
}

-(void) removeThis
{
	[parent removeChild:self cleanup:YES];
	
	[self nextCallback:self];
}

-(NSString *) title
{
	return @"Test 1. Should not crash";
}
@end

#pragma mark -
#pragma mark LogicTest

@implementation LogicTest
-(id) init
{
	if( (self=[super init] )) {
		
		CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:grossini];
		[grossini setPosition:ccp(200,200)];

		[grossini runAction: [CCSequence actions: 
							  [CCMoveBy actionWithDuration:1
												position:ccp(150,0)],
							  [CCCallFuncN actionWithTarget:self
												 selector:@selector(bugMe:)],
							  nil]
		];
	}
	
	return self;
}
		
- (void)bugMe:(CCNode *)node
{
	[node stopAllActions]; //After this stop next action not working, if remove this stop everything is working
	[node runAction:[CCScaleTo actionWithDuration:2 scale:2]];
}

-(NSString *) title
{
	return @"Logic test";
}
@end

#pragma mark -
#pragma mark PauseTest

@implementation PauseTest
-(void) onEnter
{
	//
	// This test MUST be done in 'onEnter' and not on 'init'
	// otherwise the paused action will be resumed at 'onEnter' time
	//
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];

	CCLabel* l = [CCLabel labelWithString:@"After 5 seconds grossini should move" fontName:@"Thonburi" fontSize:16];
	[self addChild:l];
	[l setPosition:ccp(s.width/2, 245)];
	
	
	//
	// Also, this test MUST be done, after [super onEnter]
	//
	CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
	[self addChild:grossini z:0 tag:kTagGrossini];
	[grossini setPosition:ccp(200,200)];
	
	CCAction *action = [CCMoveBy actionWithDuration:1 position:ccp(150,0)];
	
	[[CCActionManager sharedManager] addAction:action target:grossini paused:YES];

	[self schedule:@selector(unpause:) interval:3 repeat:1];
}

-(void) unpause:(ccTime)dt
{
	CCNode *node = [self getChildByTag:kTagGrossini];
	[[CCActionManager sharedManager] resumeAllActionsForTarget:node];
}

-(NSString *) title
{
	return @"Pause Test";
}
@end

#pragma mark -
#pragma mark ScaleTest

@implementation ScaleTest
- (UISlider *)sliderCtl
{
    if (sliderCtl == nil) 
    {
        CGRect frame = CGRectMake(174.0f, 12.0f, 120.0f, 7.0f);
        sliderCtl = [[UISlider alloc] initWithFrame:frame];
        [sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        sliderCtl.backgroundColor = [UIColor clearColor];
        
        sliderCtl.minimumValue = 0.0f;
        sliderCtl.maximumValue = 2.0f;
        sliderCtl.continuous = YES;
        sliderCtl.value = 1.0f;
		
		sliderCtl.tag = kTagSlider;	// tag this view for later so we can remove it from recycled table cells
    }
    return [sliderCtl autorelease];
}

-(void) sliderAction:(id) sender
{
	CCNode *node = [self getChildByTag:kTagGrossini];
	[[CCActionManager sharedManager] timeScaleAllActionsForTarget:node scale:sliderCtl.value];
}

-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
		
	CCLabel* l = [CCLabel labelWithString:@"Slider should only alter Grossini." fontName:@"Thonburi" fontSize:16];
	[self addChild:l];
	[l setPosition:ccp(s.width/2, 245)];
	
	// SISTER SHOULD NOT SCALE
	CCSprite *sister = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	[self addChild:sister z:0 tag:kTagSister];
	[sister setPosition:ccp(200,200)];
	
	CCRotateBy *rotate = [CCRotateBy actionWithDuration:2 angle:360];
	CCRepeatForever *repeat = [CCRepeatForever actionWithAction:rotate];
	[sister runAction:repeat];
							
	
	
	//
	// GROSSINI SHOULD SCALE
	//
	CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
	[self addChild:sprite z:0 tag:kTagGrossini];
	[sprite setPosition:ccp(100,100)];
	
	
	// Action 1
	CCIntervalAction *action1 = [CCMoveBy actionWithDuration:2 position:ccp(300,0)];
	CCAction *back1 = [action1 reverse];
	CCSequence *seq1 = [CCSequence actions:action1, back1, nil];
	CCAction *rep1 = [CCRepeatForever actionWithAction:seq1];
	[sprite runAction:rep1];
	
	
	// Action 2
	CCIntervalAction *action2 = [CCRotateBy actionWithDuration:2 angle:180];
	CCAction *back2 = [action2 reverse];
	CCSequence *seq2 = [CCSequence actions:action2, back2, nil];
	CCAction *rep2 = [CCRepeatForever actionWithAction:seq2];
	[sprite runAction:rep2];
	
	sliderCtl = [self sliderCtl];
	[[[[CCDirector sharedDirector] openGLView] window] addSubview: sliderCtl];
}

-(void) onExit
{
	[sliderCtl removeFromSuperview];
	[super onExit];
}

-(NSString *) title
{
	return @"Scale Test";
}
@end

#pragma mark -
#pragma mark Delegate

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
	[CCDirector setDirectorType:CCDirectorTypeDisplayLink];
	
	CCDirector *director = [CCDirector sharedDirector];
	// before creating any layer, set the landscape mode
	[director setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	

	// create an openGL view inside a window
	[director attachInView:window];	
	[window makeKeyAndVisible];	
	
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

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
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
