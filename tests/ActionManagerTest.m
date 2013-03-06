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
	[self.parent removeChild:self cleanup:YES];

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

	CCDirector *director = [CCDirector sharedDirector];
	[[director actionManager] addAction:action target:grossini paused:YES];

	[self schedule:@selector(unpause:) interval:3];
}

-(void) unpause:(ccTime)dt
{
	[self unschedule:_cmd];

	CCNode *node = [self getChildByTag:kTagGrossini];

	CCDirector *director = [CCDirector sharedDirector];
	[[director actionManager] resumeTarget:node];
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

	CCDirector *director = [CCDirector sharedDirector];
	CGSize s = [director winSize];

	CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
	[self addChild:grossini z:0 tag:kTagGrossini];

	[grossini setPosition:ccp(s.width/2, s.height/2)];

	// An action should be scheduled before calling pause, otherwise pause won't pause a non-existang target
	[grossini runAction:[CCScaleBy actionWithDuration:2 scale:2]];

	[[director actionManager] pauseTarget: grossini];
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

	CCDirector *director = [CCDirector sharedDirector];

	id grossini = [self getChildByTag:kTagGrossini];
	[[director actionManager] resumeTarget:grossini];
}
@end


#pragma mark -
#pragma mark Delegate

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];

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

-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [nextAction() node]];
		[director runWithScene: scene];
	}
}
@end
