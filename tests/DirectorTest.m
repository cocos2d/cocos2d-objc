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
			
			AppController *app = (AppController*)[[UIApplication sharedApplication] delegate];

			UINavigationController *nav = [app navController];
			[nav pushViewController:viewController animated:YES];
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
		}
							];

		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
			
			
			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
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

#pragma mark -
#pragma mark AppDelegate

// CLASS IMPLEMENTATIONS

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	
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
	[director_ pushScene: scene];
	
	return YES;
}

@end
