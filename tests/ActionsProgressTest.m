//
// Ease Demo
// a cocos2d example
//

// local import
#import "ActionsProgressTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"SpriteProgressToRadial",
  @"SpriteProgressToRadialMidpointChanged",
	@"SpriteProgressToHorizontal",
	@"SpriteProgressToVertical",
	@"SpriteProgressBarVarious",
	@"SpriteProgressBarTintAndFade",
  @"SpriteProgressWithSpriteFrame",

};

enum {
	kTagAction1 = 1,
	kTagAction2 = 2,
	kTagSlider = 1,
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



@implementation SpriteDemo
-(id) init
{
	if( (self=[super init])) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
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


		CCLayerColor *background = [CCLayerColor layerWithColor:(ccColor4B){255,0,0,255}];
		[self addChild:background z:-10];
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
#pragma mark SpriteProgressToRadial

@implementation SpriteProgressToRadial
-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];

	CCProgressTo *to1 = [CCProgressTo actionWithDuration:2 percent:100];
	CCProgressTo *to2 = [CCProgressTo actionWithDuration:2 percent:100];

	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeRadial;
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction: [CCRepeatForever actionWithAction:to1]];

	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"blocks.png"]];
	right.type = kCCProgressTimerTypeRadial;
	//	Makes the radial CCW
	right.reverseDirection = YES;
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction: [CCRepeatForever actionWithAction:to2]];
}

-(NSString *) title
{
	return @"ProgressTo Radial";
}
@end

@implementation SpriteProgressToRadialMidpointChanged
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
  
	CCProgressTo *action = [CCProgressTo actionWithDuration:2 percent:100];
  
  /**
   *  Our image on the left should be a radial progress indicator, clockwise
   */
	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"blocks.png"]];
	left.type = kCCProgressTimerTypeRadial;
	[self addChild:left];
  left.midpoint = ccp(.25,.75);
	[left setPosition:ccp(100, s.height/2)];
	[left runAction: [CCRepeatForever actionWithAction:[[action copy]autorelease]]];
	
  /**
   *  Our image on the left should be a radial progress indicator, counter clockwise
   */
	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"blocks.png"]];
	right.type = kCCProgressTimerTypeRadial;
  right.midpoint = ccp(.75,.25);
  
  /**
   *  Note the reverse property (default=NO) is only added to the right image. That's how
   *  we get a counter clockwise progress.
   */
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction: [CCRepeatForever actionWithAction:[[action copy]autorelease]]];
}

-(NSString *) title
{
	return @"Radial w/ Different Midpoints";
}
@end

#pragma mark -
#pragma mark SpriteProgressToHorizontal

@implementation SpriteProgressToHorizontal
-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];

	CCProgressTo *to1 = [CCProgressTo actionWithDuration:2 percent:100];
	CCProgressTo *to2 = [CCProgressTo actionWithDuration:2 percent:100];

	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the left since the midpoint is 0 for the x
	left.midpoint = ccp(0, 0);
	//	Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
	left.barChangeRate = ccp(1,0);
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction: [CCRepeatForever actionWithAction:to1]];

	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	right.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the left since the midpoint is 1 for the x
	right.midpoint = ccp(1,0);
	//	Setup for a horizontal bar since the bar change rate is 0 for y meaning no vertical change
	right.barChangeRate = ccp(1,0);
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction: [CCRepeatForever actionWithAction:to2]];
}

-(NSString *) title
{
	return @"ProgressTo Horizontal";
}
@end

#pragma mark -
#pragma mark SpriteProgressToVertical

@implementation SpriteProgressToVertical
-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];

	CCProgressTo *to1 = [CCProgressTo actionWithDuration:2 percent:100];
	CCProgressTo *to2 = [CCProgressTo actionWithDuration:2 percent:100];

	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeBar;

	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	left.midpoint = ccp(0,0);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	left.barChangeRate = ccp(0,1);
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction: [CCRepeatForever actionWithAction:to1]];

	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	right.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	right.midpoint = ccp(0,1);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	right.barChangeRate = ccp(0,1);
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction: [CCRepeatForever actionWithAction:to2]];
}

-(NSString *) title
{
	return @"ProgressTo Vertical";
}
@end


@implementation SpriteProgressBarVarious
-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];

	CCProgressTo *to = [CCProgressTo actionWithDuration:2 percent:100];

	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeBar;

	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	left.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	left.barChangeRate = ccp(1,0);
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];

	CCProgressTimer *middle = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	middle.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	middle.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	middle.barChangeRate = ccp(1, 1);
	[self addChild:middle];
	[middle setPosition:ccp(s.width/2, s.height/2)];
	[middle runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];

	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	right.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	right.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	right.barChangeRate = ccp(0, 1);
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
}

-(NSString *) title
{
	return @"ProgressTo Bar Mid";
}
@end

@implementation SpriteProgressBarTintAndFade
-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];

	CCProgressTo *to = [CCProgressTo actionWithDuration:6 percent:100];
    CCAction *tint = [CCSequence actions:[CCTintTo actionWithDuration:1 red:255 green:0 blue:0],
                      [CCTintTo actionWithDuration:1 red:0 green:255 blue:0],
                      [CCTintTo actionWithDuration:1 red:0 green:0 blue:255], nil];
    CCAction *fade = [CCSequence actions:[CCFadeTo actionWithDuration:1.f opacity:0],
                      [CCFadeTo actionWithDuration:1.f opacity:255], nil];

	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister1.png"]];
	left.type = kCCProgressTimerTypeBar;

	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	left.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	left.barChangeRate = ccp(1,0);
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
	[left runAction:[CCRepeatForever actionWithAction:[[tint copy]autorelease]]];

    [left addChild:[CCLabelTTF labelWithString:@"Tint" fontName:@"Marker Felt" fontSize:20.f]];

	CCProgressTimer *middle = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	middle.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	middle.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	middle.barChangeRate = ccp(1, 1);
	[self addChild:middle];
	[middle setPosition:ccp(s.width/2, s.height/2)];
	[middle runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
	[middle runAction:[CCRepeatForever actionWithAction:[[fade copy]autorelease]]];

    [middle addChild:[CCLabelTTF labelWithString:@"Fade" fontName:@"Marker Felt" fontSize:20.f]];
	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"grossinis_sister2.png"]];
	right.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	right.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	right.barChangeRate = ccp(0, 1);
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
	[right runAction:[CCRepeatForever actionWithAction:[[tint copy]autorelease]]];
	[right runAction:[CCRepeatForever actionWithAction:[[fade copy]autorelease]]];

    [right addChild:[CCLabelTTF labelWithString:@"Tint and Fade" fontName:@"Marker Felt" fontSize:20.f]];
}

-(NSString *) title
{
	return @"ProgressTo Bar Mid";
}
@end

@implementation SpriteProgressWithSpriteFrame
-(void) onEnter
{
	[super onEnter];
  
	CGSize s = [[CCDirector sharedDirector] winSize];
  
	CCProgressTo *to = [CCProgressTo actionWithDuration:6 percent:100];
  
  [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"zwoptex/grossini.plist"];
  
	CCProgressTimer *left = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrameName:@"grossini_dance_01.png"]];
	left.type = kCCProgressTimerTypeBar;
  
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	left.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	left.barChangeRate = ccp(1,0);
	[self addChild:left];
	[left setPosition:ccp(100, s.height/2)];
	[left runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
  
  
	CCProgressTimer *middle = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrameName:@"grossini_dance_02.png"]];
	middle.type = kCCProgressTimerTypeBar;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	middle.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	middle.barChangeRate = ccp(1, 1);
	[self addChild:middle];
	[middle setPosition:ccp(s.width/2, s.height/2)];
	[middle runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
  
  
	CCProgressTimer *right = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrameName:@"grossini_dance_03.png"]];
	right.type = kCCProgressTimerTypeRadial;
	//	Setup for a bar starting from the bottom since the midpoint is 0 for the y
	right.midpoint = ccp(.5f, .5f);
	//	Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
	right.barChangeRate = ccp(0, 1);
	[self addChild:right];
	[right setPosition:ccp(s.width-100, s.height/2)];
	[right runAction:[CCRepeatForever actionWithAction:[[to copy]autorelease]]];
}

-(NSString *) title
{
	return @"Progress With Sprite Frame";
}
@end

#pragma mark -
#pragma mark AppController

#if defined(__CC_PLATFORM_IOS)

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Turn on display statistics
	[director_ setDisplayStats:YES];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

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
