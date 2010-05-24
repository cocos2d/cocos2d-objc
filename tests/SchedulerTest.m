//
// Scheduler Test
// http://www.cocos2d-iphone.org
//

// local import
#import "cocos2d.h"
#import "SchedulerTest.h"

enum {
	kTagAnimationDance = 1,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"SchedulerAutoremove",
	@"SchedulerPauseResume",
	@"SchedulerUnscheduleAll",
	@"SchedulerUnscheduleAllHard",
	@"SchedulerSchedulesAndRemove",
	@"SchedulerUpdate",
	@"SchedulerUpdateAndCustom",
	@"SchedulerUpdateFromCustom",
};

Class nextTest()
{

	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class prevTest()
{
	sceneIdx--;
	if( sceneIdx < 0 )
		sceneIdx = sizeof(transitions) / sizeof(transitions[0]) -1;	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartTest()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}


#pragma mark SchedulerTest
@implementation SchedulerTest
-(id) init
{
	if( (self=[super init])) {
	
		
		CGSize s = [[CCDirector sharedDirector] winSize];
				
		CCLabel* label = [CCLabel labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabel* l = [CCLabel labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
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
	[s addChild: [restartTest() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextTest() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [prevTest() node]];
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

#pragma mark SchedulerAutoremove
@implementation SchedulerAutoremove
-(id) init
{
	if( (self=[super init]) ) {
		
		[self schedule:@selector(autoremove:) interval:0.5f];
		[self schedule:@selector(tick:) interval:0.5f];
		accum = 0;
	}
	
	return self;
}

-(NSString *) title
{
	return @"Self-remove an scheduler";
}

-(NSString *) subtitle
{
	return @"1 scheduler will be autoremoved in 3 seconds. See console";
}								 

-(void) tick:(ccTime)dt
{
	NSLog(@"This scheduler should not be removed");
}
-(void) autoremove:(ccTime)dt
{
	accum += dt;
	NSLog(@"Time: %f", accum);
	
	if( accum > 3 ) {
		[self unschedule:_cmd];
		NSLog(@"scheduler removed");
	}
}
@end

#pragma mark SchedulerPauseResume
@implementation SchedulerPauseResume
-(id) init
{
	if( (self=[super init]) ) {

		[self schedule:@selector(tick1:) interval:0.5f];
		[self schedule:@selector(tick2:) interval:1];
		[self schedule:@selector(pause:) interval:3];
	}
	
	return self;
}

-(NSString *) title
{
	return @"Pause / Resume";
}

-(NSString *) subtitle
{
	return @"Scheduler should be paused after 3 seconds. See console";
}								 

-(void) tick1:(ccTime)dt
{
	NSLog(@"tick1");
}

-(void) tick2:(ccTime)dt
{
	NSLog(@"tick2");
}

-(void) pause:(ccTime)dt
{
	[[CCScheduler sharedScheduler] pauseTarget:self];
}
@end

#pragma mark SchedulerUnscheduleAll
@implementation SchedulerUnscheduleAll
-(id) init
{
	if( (self=[super init]) ) {
		
		[self schedule:@selector(tick1:) interval:0.5f];
		[self schedule:@selector(tick2:) interval:1];
		[self schedule:@selector(tick3:) interval:1.5f];
		[self schedule:@selector(tick4:) interval:1.5f];
		[self schedule:@selector(unscheduleAll:) interval:4];
	}
	
	return self;
}

-(NSString *) title
{
	return @"Unschedule All selectors";
}

-(NSString *) subtitle
{
	return @"All scheduled selectors will be unscheduled in 4 seconds. See console";
}								 

-(void) tick1:(ccTime)dt
{
	NSLog(@"tick1");
}

-(void) tick2:(ccTime)dt
{
	NSLog(@"tick2");
}

-(void) tick3:(ccTime)dt
{
	NSLog(@"tick3");
}

-(void) tick4:(ccTime)dt
{
	NSLog(@"tick4");
}

-(void) unscheduleAll:(ccTime)dt
{
	[self unscheduleAllSelectors];
}
@end

#pragma mark SchedulerUnscheduleAllHard
@implementation SchedulerUnscheduleAllHard
-(id) init
{
	if( (self=[super init]) ) {
		
		[self schedule:@selector(tick1:) interval:0.5f];
		[self schedule:@selector(tick2:) interval:1];
		[self schedule:@selector(tick3:) interval:1.5f];
		[self schedule:@selector(tick4:) interval:1.5f];
		[self schedule:@selector(unscheduleAll:) interval:4];
	}
	
	return self;
}

-(NSString *) title
{
	return @"Unschedule All selectors #2";
}

-(NSString *) subtitle
{
	return @"Unschedules all selectors after 4s. Uses CCScheduler. See console";
}								 

-(void) tick1:(ccTime)dt
{
	NSLog(@"tick1");
}

-(void) tick2:(ccTime)dt
{
	NSLog(@"tick2");
}

-(void) tick3:(ccTime)dt
{
	NSLog(@"tick3");
}

-(void) tick4:(ccTime)dt
{
	NSLog(@"tick4");
}

-(void) unscheduleAll:(ccTime)dt
{
	[[CCScheduler sharedScheduler] unscheduleAllSelectors];
}
@end


#pragma mark SchedulerSchedulesAndRemove
@implementation SchedulerSchedulesAndRemove
-(id) init
{
	if( (self=[super init]) ) {
		
		[self schedule:@selector(tick1:) interval:0.5f];
		[self schedule:@selector(tick2:) interval:1];
		[self schedule:@selector(scheduleAndUnschedule:) interval:4];
	}
	
	return self;
}

-(NSString *) title
{
	return @"Schedule from Schedule";
}

-(NSString *) subtitle
{
	return @"Will unschedule and schedule selectors in 4s. See console";
}								 

-(void) tick1:(ccTime)dt
{
	NSLog(@"tick1");
}

-(void) tick2:(ccTime)dt
{
	NSLog(@"tick2");
}

-(void) tick3:(ccTime)dt
{
	NSLog(@"tick3");
}

-(void) tick4:(ccTime)dt
{
	NSLog(@"tick4");
}

-(void) scheduleAndUnschedule:(ccTime)dt
{
	[self unschedule:_cmd];
	[self unschedule:@selector(tick1:)];
	[self unschedule:@selector(tick2:)];
	[self schedule:@selector(tick3:) interval:1];
	[self schedule:@selector(tick4:) interval:1];
}
@end


@interface TestNode : CCNode
{
	NSString *string_;
}
@end

#pragma mark SchedulerUpdate

@implementation TestNode
-(id) initWithString:(NSString*)string priority:(int)priority
{
	if( (self = [super init] ) ) {
		
		string_ = [string retain];
		
		[self scheduleUpdateWithPriority:priority];
		
	}
	
	return self;
}

- (void) dealloc
{
	[string_ release];
	[super dealloc];
}

-(void) update:(ccTime)dt
{
	NSLog(@"%@", string_ );
}

@end

@implementation SchedulerUpdate
-(id) init
{
	if( (self=[super init]) ) {

		// schedule in different order... just another test
		TestNode *d = [[TestNode alloc] initWithString:@"---" priority:50];
		[self addChild:d];
		[d release];
		
		TestNode *b = [[TestNode alloc] initWithString:@"3rd" priority:0];
		[self addChild:b];
		[b release];

		TestNode *a = [[TestNode alloc] initWithString:@"1st" priority:-10];
		[self addChild:a];
		[a release];

		TestNode *c = [[TestNode alloc] initWithString:@"4th" priority:10];
		[self addChild:c];
		[c release];

		TestNode *e = [[TestNode alloc] initWithString:@"5th" priority:20];
		[self addChild:e];
		[e release];

		TestNode *f = [[TestNode alloc] initWithString:@"2nd" priority:-5];
		[self addChild:f];
		[f release];
		
		
		[self schedule:@selector(removeUpdates:) interval:4];
	}
	
	return self;
}

-(NSString *) title
{
	return @"Schedule update with priority";
}

-(NSString *) subtitle
{
	return @"3 scheduled updates. Priority should work. Stops in 4s. See console";
}								 

-(void) removeUpdates:(ccTime)dt
{
	for( CCNode *node in children_)
		[node unscheduleAllSelectors];
}
@end


#pragma mark SchedulerUpdateAndCustom
@implementation SchedulerUpdateAndCustom
-(id) init
{
	if( (self=[super init]) ) {
	
		[self scheduleUpdate];
		[self schedule:@selector(tick:)];
		[self schedule:@selector(stopSelectors:) interval:4];
		
	}
	
	return self;
}

-(NSString *) title
{
	return @"Schedule Update + custom selector";
}

-(NSString *) subtitle
{
	return @"Update + custom selector at the same time. Stops in 4s. See console";
}								 

-(void) update:(ccTime)dt
{
	NSLog(@"update called:%f", dt);
}

-(void) tick:(ccTime)dt
{
	NSLog(@"custom selector called:%f",dt);
}

-(void) stopSelectors:(ccTime)dt
{
	[self unscheduleAllSelectors];
}
@end

#pragma mark SchedulerUpdateFromCustomcle
@implementation SchedulerUpdateFromCustom
-(id) init
{
	if( (self=[super init]) ) {
		
		[self schedule:@selector(schedUpdate:) interval:2];
		
	}
	
	return self;
}

-(NSString *) title
{
	return @"Schedule Update in 2 sec";
}

-(NSString *) subtitle
{
	return @"Update schedules in 2 secs. Stops 2 sec later. See console";
}								 

-(void) update:(ccTime)dt
{
	NSLog(@"update called:%f", dt);
}

-(void) stopUpdate:(ccTime)dt
{
	[self unscheduleUpdate];
	[self unschedule:_cmd];
}

-(void) schedUpdate:(ccTime)dt
{
	[self unschedule:_cmd];
	[self scheduleUpdate];
	[self schedule:@selector(stopUpdate:) interval:2];
}

@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
	
	// must be called before any othe call to the director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeMainLoop];
	
	// Attach cocos2d to the window
	[[CCDirector sharedDirector] attachInWindow:window];
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// display FPS (useful when debugging)
	[[CCDirector sharedDirector] setDisplayFPS:YES];
	
	// frames per second
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];

	// Make the window visible
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextTest() node]];
	
	[[CCDirector sharedDirector] runWithScene: scene];
		
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

- (void) dealloc
{
	[window release];
	[super dealloc];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
