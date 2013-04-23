//
// Director Test
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import <GameKit/GameKit.h>

// cocos import
#import "cocos2d.h"

// local import
#import "DirectorTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {

	@"DirectorViewDidDisappear",
	@"DirectorAndGameCenter",
	@"DirectorStartStopAnimating",
	@"DirectorRootToLevel",
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
#pragma mark DirectorTest

@implementation DirectorTest
-(id) init
{
	if( (self = [super init]) ) {


		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:26];
		[self addChild: label z:1];
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

#pragma mark - DirectorViewDidDisappear

@implementation DirectorViewDidDisappear

-(id) init
{
	if( (self=[super init]) ) {

		CCMenuItem *item = [CCMenuItemFont itemWithString:@"Press Me" block:^(id sender) {

			UIViewController *viewController = [[UIViewController alloc] init];

			// view
			UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 240)];
			view.backgroundColor = [UIColor yellowColor];

			// back button
			UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[button addTarget:self
					   action:@selector(buttonBack:)
			 forControlEvents:UIControlEventTouchDown];
			[button setTitle:@"Back" forState:UIControlStateNormal];
			button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
			[view addSubview:button];

			viewController.view = view;
			
			[view release];

			AppController *app = (AppController*)[[UIApplication sharedApplication] delegate];

			UINavigationController *nav = [app navController];
			[nav pushViewController:viewController animated:YES];
			
			[viewController release];
		}
							];

		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];

	}
	return self;
}

-(void) buttonBack:(id)sender
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	UINavigationController *nav = [app navController];
	[nav popViewControllerAnimated:YES];
}

-(NSString *) title
{
	return @"Navigation Controller";
}

-(NSString*) subtitle
{
	return @"Director should be paused when UIKit window appears";
}
@end

#pragma mark - DirectorAndGameCenter

@implementation DirectorAndGameCenter

-(id) init
{
	if( (self=[super init]) ) {

		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {


			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
			achivementViewController.achievementDelegate = self;

			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];

			[[app navController] presentModalViewController:achivementViewController animated:YES];
			
			[achivementViewController release];
		}
							];

		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {


			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = self;

			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];

			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
			
			[leaderboardViewController release];
		}
							];

		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, nil];
		[menu alignItemsVertically];
		[self addChild:menu];

	}
	return self;
}

-(NSString *) title
{
	return @"Game Center";
}

-(NSString*) subtitle
{
	return @"Achievements and Leaderboard";
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end


#pragma mark - DirectorStartStopAnimating

@implementation DirectorStartStopAnimating

-(id) init
{
	if( (self=[super init]) ) {
        
		CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
        sprite.position = ccp(s.width/2, s.height/2);
        [self addChild:sprite];
        [sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3.0 angle:360]]];
        
		[self schedule:@selector(stop:) interval:3 repeat:NO delay:0];
        [self performSelectorOnMainThread:@selector(scheduleRestartTimer) withObject:nil waitUntilDone:NO];
	}
    
	return self;
}

- (void) scheduleRestartTimer
{
    // This timer must run on the main thread since the director thread gets killed (on Mac).
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(restart:) userInfo:nil repeats:NO];
}

- (void) onExit
{
    if(![CCDirector sharedDirector].isAnimating)
        [[CCDirector sharedDirector] startAnimation];
}

-(NSString *) title
{
	return @"Start/Stop Animating";
}

-(NSString *) subtitle
{
	return @"Everything will stop after 3s, then resume at 5s. See console";
}

-(void) stop:(ccTime)dt
{
    NSLog(@"Stopping the director (isAnimating = %d)", [CCDirector sharedDirector].isAnimating);
	[[CCDirector sharedDirector] stopAnimation];
    NSLog(@"Director has stopped (isAnimating = %d)", [CCDirector sharedDirector].isAnimating);
}

- (void) restart:(NSTimer*) timer
{
    NSLog(@"Restarting the director (isAnimating = %d)", [CCDirector sharedDirector].isAnimating);
	[[CCDirector sharedDirector] startAnimation];
    NSLog(@"Director has restarted (isAnimating = %d)", [CCDirector sharedDirector].isAnimating);
}
@end

#pragma mark - DirectorRootToLevel

@implementation DirectorRootToLevel

@synthesize level = _level;

-(id) init
{
	return [self initWithLevel:1];
}

-(id) initWithLevel:(NSUInteger)level
{
	if( (self=[super init]) ) {

		_level = level;
		CGSize s = [[CCDirector sharedDirector] winSize];

		NSString *str = [NSString stringWithFormat:@"Stack Level: %d", level];
		CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:@"Marker Felt" fontSize:32];
		[self addChild:label];
		[label setPosition:ccp(s.width/2, s.height/2)];

		CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Push Scene" target:self selector:@selector(pushScene:)];
		CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Pop To Root" target:self selector:@selector(popToRoot:)];
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, nil];
		[menu alignItemsVertically];
		[self addChild:menu];
	}

	return self;
}

-(void) pushScene:(id)sender
{
	CCScene *scene = [CCScene node];
	CCNode *child = [[[DirectorRootToLevel alloc] initWithLevel:_level+1] autorelease];

	[scene addChild:child];

	[[CCDirector sharedDirector] pushScene:scene];
}

-(void) popToRoot:(id)sender
{
	[[CCDirector sharedDirector] popToSceneStackLevel:1];
}

-(NSString *) title
{
	return @"popToRootStackLevel";
}

-(NSString *) subtitle
{
	return @"Press Add to add a scene. Press Pop to return to root scene";
}
@end



#pragma mark - AppDelegate

// CLASS IMPLEMENTATIONS

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	[director_ setDisplayStats:YES];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	return YES;
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

@end
