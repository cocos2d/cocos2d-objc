//
// ActionManager Test
// a cocos2d test
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
	kTagSequence,
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

static int sceneIdx=-1;
static NSString *transitions[] = {
			@"CrashTest",
			@"LogicTest",
			@"PauseTest",
			@"RemoveTest",
			@"Issue835",
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
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];
			
		CCLabelTTF* label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF* l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
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
	[parent_ removeChild:self cleanup:YES];
	
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

	//
	// Also, this test MUST be done, after [super onEnter]
	//
	CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
	[self addChild:grossini z:0 tag:kTagGrossini];
	[grossini setPosition:ccp(200,200)];
	
	CCAction *action = [CCMoveBy actionWithDuration:1 position:ccp(150,0)];
	
	[[CCActionManager sharedManager] addAction:action target:grossini paused:YES];

	[self schedule:@selector(unpause:) interval:3];
}

-(void) unpause:(ccTime)dt
{
	[self unschedule:_cmd];
	CCNode *node = [self getChildByTag:kTagGrossini];
	[[CCActionManager sharedManager] resumeTarget:node];
}

-(NSString *) title
{
	return @"Pause Test";
}

-(NSString*) subtitle
{
	return @"After 3 seconds grossini should move";
}
@end

#pragma mark -
#pragma mark RemoveTest

@implementation RemoveTest
-(id) init
{
	if( (self= [super init]) ) {
	
		CCMoveBy* move = [CCMoveBy actionWithDuration:2 
											 position:ccp(200,0)];
		
		CCCallFunc* callback = [CCCallFunc actionWithTarget:self 
												   selector:@selector(stopAction:)];
		
		CCSequence* sequence = [CCSequence actions:move, callback, nil];
		sequence.tag = kTagSequence;
		
		CCSprite *child = [CCSprite spriteWithFile:@"grossini.png"];
		[child setPosition:ccp(200,200)];
		[self addChild:child z:1 tag:kTagGrossini];
		
		[child runAction:sequence];
	}
	
	return self;
}

-(void) stopAction:(id)sender
{
	id sprite = [self getChildByTag:kTagGrossini];
	[sprite stopActionByTag:kTagSequence];
}

-(NSString *) title
{
	return @"Remove Test";
}

-(NSString*) subtitle
{
	return @"Should not crash. Testing issue #841";
}
@end

#pragma mark -
#pragma mark Issue835

@implementation Issue835
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];

	CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
	[self addChild:grossini z:0 tag:kTagGrossini];
	
	[grossini setPosition:ccp(s.width/2, s.height/2)];

	// An action should be scheduled before calling pause, otherwise pause won't pause a non-existang target
	[grossini runAction:[CCScaleBy actionWithDuration:2 scale:2]];

	[[CCActionManager sharedManager] pauseTarget: grossini];
	[grossini runAction:[CCRotateBy actionWithDuration:2 angle:360]];
	
	[self schedule:@selector(resumeGrossini:) interval:3];
}

-(NSString *) title
{
	return @"Issue 835";
}

-(NSString*) subtitle
{
	return @"Grossini only rotate/scale in 3 seconds";
}

-(void) resumeGrossini:(ccTime)dt
{
	[self unschedule:_cmd];
	
	id grossini = [self getChildByTag:kTagGrossini];
	[[CCActionManager sharedManager] resumeTarget:grossini];
}
@end


#pragma mark -
#pragma mark Delegate

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"

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

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// sent to background
-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

// sent to foreground
-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// purge memroy
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
