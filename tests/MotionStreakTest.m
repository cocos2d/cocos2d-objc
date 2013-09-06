//
// MotionStreak Demo
// a cocos2d example
//
// Example by Jason Booth (slipster216)

// cocos import
#import "cocos2d.h"
#import "MotionStreakTest.h"
#import "BaseAppController.h"

enum {
	kTagLabel = 1,
	kTagSprite1 = 2,
	kTagSprite2 = 3,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"Issue1358",
	@"Test1",
	@"Test2",
};

#pragma mark Callbacks

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
	if( sceneIdx < 0 )
		sceneIdx = sizeof(transitions) / sizeof(transitions[0]) -1;
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

#pragma mark Demo examples start here

@implementation MotionStreakTest
-(id) init
{
	if( (self = [super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:0 tag:kTagLabel];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
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


		CCMenuItemToggle *itemMode = [CCMenuItemToggle itemWithTarget:self
														  selector:@selector(modeCallback:)
															 items: [CCMenuItemFont itemWithString: @"Use High Quality Mode"], [CCMenuItemFont itemWithString: @"Use Fast Mode"], nil];

		CCMenu *menuMode = [CCMenu menuWithItems:itemMode, nil];
		[self addChild:menuMode];

		[menuMode setPosition:ccp(s.width/2,s.height/4)];

	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(void) modeCallback: (id) sender
{
	BOOL fastMode = [streak_ isFastMode];
	[streak_ setFastMode: ! fastMode];
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
	return @"";
}

@end


#pragma mark Test1

@implementation Test1
-(NSString*) title
{
	return @"MotionStreak test 1";
}
-(void) dealloc
{
	[super dealloc];
}

-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];

	// the root object just rotates around
	root = [CCSprite spriteWithFile:@"r1.png"];
	[self addChild: root z:1];
	[root setPosition: ccp(s.width/2, s.height/2)];

	// the target object is offset from root, and the streak is moved to follow it
	target = [CCSprite spriteWithFile:@"r1.png"];
	[root addChild:target];
	[target setPosition:ccp(s.width/4,0)];

	// create the streak object and add it to the scene
	streak_ = [CCMotionStreak streakWithFade:2 minSeg:3 width:32 color:ccGREEN textureFilename:@"streak.png"];
	[self addChild:streak_];

	// schedule an update on each frame so we can syncronize the streak with the target
	[self schedule:@selector(onUpdate:)];

	id a1 = [CCRotateBy actionWithDuration:2 angle:360];

	id action1 = [CCRepeatForever actionWithAction:a1];
	id motion = [CCMoveBy actionWithDuration:2 position:ccp(100,0)];
	[root runAction:[CCRepeatForever actionWithAction:[CCSequence actions:motion, [motion reverse], nil]]];
	[root runAction:action1];


    CCActionInterval *colorAction = [CCRepeatForever actionWithAction:[CCSequence actions:
                                                                  [CCTintTo actionWithDuration:0.2f red:255 green:0 blue:0],
                                                                  [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:0],
                                                                  [CCTintTo actionWithDuration:0.2f red:0 green:0 blue:255],
                                                                  [CCTintTo actionWithDuration:0.2f red:0 green:255 blue:255],
                                                                  [CCTintTo actionWithDuration:0.2f red:255 green:255 blue:0],
                                                                  [CCTintTo actionWithDuration:0.2f red:255 green:0 blue:255],
                                                                  [CCTintTo actionWithDuration:0.2f red:255 green:255 blue:255],nil
                                                                  ]
                                ];
    [streak_ runAction:colorAction];
}

-(void)onUpdate:(ccTime)delta
{
	[streak_ setPosition:[target convertToWorldSpace:CGPointZero]];
}
@end

#pragma mark Test2

@implementation Test2
-(NSString*) title
{
	return @"MotionStreak test (tap screen)";
}
-(void) dealloc
{
	[super dealloc];
}

-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];

	// create the streak object and add it to the scene
	streak_ = [CCMotionStreak streakWithFade:3 minSeg:3 width:64 color:ccWHITE textureFilename:@"streak.png"];
	[self addChild:streak_];

	streak_.position = ccp(s.width/2, s.height/2);
}

#ifdef __CC_PLATFORM_IOS

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [ touches anyObject ];
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];

	[streak_ setPosition:touchLocation];
}

#elif defined(__CC_PLATFORM_MAC)

- (void)mouseDown:(NSEvent *)theEvent
{
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	CGPoint touchLocation = [[CCDirector sharedDirector] convertEventToGL:theEvent];
	[streak_ setPosition:touchLocation];
}
#endif

@end


#pragma mark - Issue1358
// always call "super" init
// Apple recommends to re-assign "self" with the "super's" return value
@implementation Issue1358

-(id) init
{
	if( (self=[super init])) {
		
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
				
		streak_ = [CCMotionStreak streakWithFade:2.0f minSeg:1.0f width:50.0f color:ccc3(255, 255, 0) textureFilename:@"Icon-Small-50.png"];
		[self addChild:streak_];
		
		
		_center  = ccp(size.width/2, size.height/2);
		_radius = size.width/3;
		_angle = 0.0f;

		[self schedule:@selector(update:) interval:0];
	}
	
	return self;
}


- (void)update:(ccTime)time
{
	_angle += 1.0f;
	streak_.position = ccp( _center.x + cosf(_angle/180 * M_PI)*_radius,
						 _center.y + sinf(_angle/ 180 * M_PI)*_radius);
}

-(NSString*) title
{
	return @"Issue 1358";
}

-(NSString*) subtitle
{
	return @"The tail should use the texture";
}

@end


#pragma mark - AppDelegate

#if defined(__CC_PLATFORM_IOS)

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

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	return  YES;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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

