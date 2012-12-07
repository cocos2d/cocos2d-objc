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
	@"SchedulerTimeScale",
	@"TwoSchedulers",

	@"SchedulerAutoremove",
	@"SchedulerPauseResume",
	@"SchedulerPauseResumeAll",
	@"SchedulerPauseResumeAllUser",
	@"SchedulerUnscheduleAll",
	@"SchedulerUnscheduleAllHard",
	@"SchedulerUnscheduleAllUserLevel",
	@"SchedulerSchedulesAndRemove",
	@"SchedulerUpdate",
	@"SchedulerUpdateAndCustom",
	@"SchedulerUpdateFromCustom",
	@"RescheduleSelector",
	@"SchedulerDelayAndRepeat",
};

Class nextTest(void);
Class prevTest(void);
Class restartTest(void);

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

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
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
	CCDirector *director = [CCDirector sharedDirector];
	[[director scheduler] pauseTarget:self];
}
@end

#pragma mark SchedulerPauseResumeAll
@implementation SchedulerPauseResumeAll

@synthesize pausedTargets = pausedTargets_;

-(id) init
{
	if( (self=[super init]) ) {
        
		CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
        sprite.position = ccp(s.width/2, s.height/2);
        [self addChild:sprite];
        [sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3.0 angle:360]]];
        
		[self scheduleUpdate];
		[self schedule:@selector(tick1:) interval:0.5f];
		[self schedule:@selector(tick2:) interval:1];
		[self schedule:@selector(pause:) interval:3 repeat:NO delay:0];
        [self performSelector:@selector(resume) withObject:nil afterDelay:5];
	}
    
	return self;
}

- (void) dealloc
{
    [pausedTargets_ release];
    [super dealloc];
}

- (void) onExit
{
    if(self.pausedTargets != nil)
        [[CCDirector sharedDirector].scheduler resumeTargets:self.pausedTargets];
}

-(NSString *) title
{
	return @"Pause / Resume";
}

-(NSString *) subtitle
{
	return @"Everything will pause after 3s, then resume at 5s. See console";
}

-(void) update:(ccTime)delta
{
	// do nothing
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
    NSLog(@"Pausing");
	CCDirector *director = [CCDirector sharedDirector];
    self.pausedTargets = [director.scheduler pauseAllTargets];
	
	NSUInteger c = [self.pausedTargets count];
	
	if(c > 2)
	{
		// should have only 2 items: CCActionManager, self
		NSLog(@"Error: pausedTargets should have only 2 items, and not %u", (unsigned int)c);
	}
}

- (void) resume
{
    NSLog(@"Resuming");
	CCDirector *director = [CCDirector sharedDirector];
    [director.scheduler resumeTargets:self.pausedTargets];
    self.pausedTargets = nil;
}

@end

#pragma mark SchedulerPauseResumeAllUser
@implementation SchedulerPauseResumeAllUser

@synthesize pausedTargets = pausedTargets_;

-(id) init
{
	if( (self=[super init]) ) {
        
		CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
        sprite.position = ccp(s.width/2, s.height/2);
        [self addChild:sprite];
        [sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3.0 angle:360]]];
        
		[self schedule:@selector(tick1:) interval:0.5f];
		[self schedule:@selector(tick2:) interval:1];
		[self schedule:@selector(pause:) interval:3 repeat:NO delay:0];
        [self performSelector:@selector(resume) withObject:nil afterDelay:5];
	}
    
	return self;
}

- (void) dealloc
{
    [pausedTargets_ release];
    [super dealloc];
}

- (void) onExit
{
    if(self.pausedTargets != nil)
        [[CCDirector sharedDirector].scheduler resumeTargets:self.pausedTargets];
}

-(NSString *) title
{
	return @"Pause / Resume";
}

-(NSString *) subtitle
{
	return @"Everything except actions will pause after 3s, then resume at 5s. See console";
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
    NSLog(@"Pausing");
	CCDirector *director = [CCDirector sharedDirector];
    self.pausedTargets = [director.scheduler pauseAllTargetsWithMinPriority:kCCPriorityNonSystemMin];
}

- (void) resume
{
    NSLog(@"Resuming");
	CCDirector *director = [CCDirector sharedDirector];
    [director.scheduler resumeTargets:self.pausedTargets];
    self.pausedTargets = nil;
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

		CGSize s = [[CCDirector sharedDirector] winSize];

        CCSprite *sprite = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
        sprite.position = ccp(s.width/2, s.height/2);
        [self addChild:sprite];
        [sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3.0 angle:360]]];

        actionManagerActive = YES;
        
		[self schedule:@selector(tick1:) interval:0.5f];
		[self schedule:@selector(tick2:) interval:1];
		[self schedule:@selector(tick3:) interval:1.5f];
		[self schedule:@selector(tick4:) interval:1.5f];
		[self schedule:@selector(unscheduleAll:) interval:4];
	}

	return self;
}

- (void) onExit
{
    if(!actionManagerActive) {
        // Restore the director's action manager.
        CCDirector* director = [CCDirector sharedDirector];
        [director.scheduler scheduleUpdateForTarget:director.actionManager priority:kCCPrioritySystem paused:NO];
    }
}

-(NSString *) title
{
	return @"Unschedule All selectors (HARD)";
}

-(NSString *) subtitle
{
	return @"Unschedules all user selectors after 4s. Action will stop. See console";
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
	CCDirector *director = [CCDirector sharedDirector];
	[[director scheduler] unscheduleAll];
    actionManagerActive = NO;
}
@end


#pragma mark SchedulerUnscheduleAllUserLevel
@implementation SchedulerUnscheduleAllUserLevel
-(id) init
{
	if( (self=[super init]) ) {
        
		CGSize s = [[CCDirector sharedDirector] winSize];
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
        sprite.position = ccp(s.width/2, s.height/2);
        [self addChild:sprite];
        [sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:3.0 angle:360]]];
        
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
	return @"Unschedule All user selectors";
}

-(NSString *) subtitle
{
	return @"Unschedules all user selectors after 4s. Action should not stop. See console";
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
	CCDirector *director = [CCDirector sharedDirector];
	[[director scheduler] unscheduleAllWithMinPriority:kCCPriorityNonSystemMin];
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

#pragma mark RescheduleSelector
@implementation RescheduleSelector

-(id) init
{
	if( (self=[super init]) ) {

		interval = 1;
		ticks = 0;
		[self schedule:@selector(schedUpdate:) interval:interval];

	}

	return self;
}

-(NSString *) title
{
	return @"Reschedule Selector";
}

-(NSString *) subtitle
{
	return @"Interval is 1 second, then 2, then 3...";
}


-(void) schedUpdate:(ccTime)dt
{
	ticks++;

	NSLog(@"schedUpdate: %.4f", dt);
	if( ticks > 3 ) {
		[self schedule:_cmd interval:++interval];
		ticks = 0;
	}

}

@end

@implementation SchedulerDelayAndRepeat
-(id) init
{
	if( (self=[super init]) ) {

		[self schedule:@selector(update:) interval:0 repeat:4 delay:3.f];
		CCLOG(@"update is scheduled should begin after 3 seconds");
	}

	return self;
}

-(NSString *) title
{
	return @"Schedule with delay of 3 sec, repeat 4 times";
}

-(NSString *) subtitle
{
	return @"After 5 x executed, method unscheduled. See console";
}

-(void) update:(ccTime)dt
{
	NSLog(@"update called:%f", dt);
}

@end

#pragma mark - SchedulerTimeScale

@implementation SchedulerTimeScale
#ifdef __CC_PLATFORM_IOS
- (UISlider *)sliderCtl
{
	UISlider * slider = [[UISlider alloc] initWithFrame:CGRectMake(0,0,120,7)];
	[slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];

	// in case the parent view draws with a custom color or gradient, use a transparent color
	slider.backgroundColor = [UIColor clearColor];

	slider.minimumValue = -3.0f;
	slider.maximumValue = 3.0f;
	slider.continuous = YES;
	slider.value = 1.0f;

    return [slider autorelease];
}
#elif defined(__CC_PLATFORM_MAC)
-(NSSlider*) sliderCtl
{
	NSSlider* slider = [[NSSlider alloc] initWithFrame: NSMakeRect (0, 0, 200, 20)];
	[slider setMinValue: -3];
	[slider setMaxValue: 3];
	[slider setFloatValue: 1];
	[slider setAction: @selector (sliderAction:)];
	[slider setTarget: self];
	[slider setContinuous: YES];

	return [slider autorelease];
}
#endif // Mac

-(void) sliderAction:(id) sender
{
	ccTime scale;

#ifdef __CC_PLATFORM_IOS
	scale = sliderCtl.value;

#elif defined(__CC_PLATFORM_MAC)
	float value = [sliderCtl floatValue];
	scale = value;
#endif

	[[[CCDirector sharedDirector] scheduler] setTimeScale: scale];
}

-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];

	// rotate and jump
	CCActionInterval *jump1 = [CCJumpBy actionWithDuration:4 position:ccp(-s.width+80,0) height:100 jumps:4];
	CCActionInterval *jump2 = [jump1 reverse];
	CCActionInterval *rot1 = [CCRotateBy actionWithDuration:4 angle:360*2];
	CCActionInterval *rot2 = [rot1 reverse];

	id seq3_1 = [CCSequence actions:jump2, jump1, nil];
	id seq3_2 = [CCSequence actions: rot1, rot2, nil];
	id spawn = [CCSpawn actions:seq3_1, seq3_2, nil];
	id action = [CCRepeat  actionWithAction:spawn times:50];

	id action2 = [[action copy] autorelease];
	id action3 = [[action copy] autorelease];

	CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
	CCSprite *tamara = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	CCSprite *kathia = [CCSprite spriteWithFile:@"grossinis_sister2.png"];

	grossini.position = ccp(40,80);
	tamara.position = ccp(40,80);
	kathia.position = ccp(40,80);

	[self addChild:grossini];
	[self addChild:tamara];
	[self addChild:kathia];

	[grossini runAction: [CCSpeed actionWithAction:action speed:0.5f]];
	[tamara runAction: [CCSpeed actionWithAction:action2 speed:1.5f]];
	[kathia runAction: [CCSpeed actionWithAction:action3 speed:1.0f]];

	CCParticleSystem *emitter = [CCParticleFireworks node];
	[self addChild:emitter];

	sliderCtl = [self sliderCtl];

#ifdef __CC_PLATFORM_IOS
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	UIViewController *ctl = [app navController];

	[ctl.view addSubview: sliderCtl];

#elif defined(__CC_PLATFORM_MAC)
	CCGLView *view = (CCGLView*) [[CCDirectorMac sharedDirector] view];

	if( ! overlayWindow ) {
		overlayWindow  = [[NSWindow alloc] initWithContentRect:[[view window] frame]
													 styleMask:NSBorderlessWindowMask
													   backing:NSBackingStoreBuffered
														 defer:NO];

		[overlayWindow setFrame:[[view window] frame] display:NO];

		[[overlayWindow contentView] addSubview:sliderCtl];
		[overlayWindow setParentWindow:[view window]];
		[overlayWindow setOpaque:NO];
		[overlayWindow makeKeyAndOrderFront:nil];
		[overlayWindow setBackgroundColor:[NSColor clearColor]];
		[[overlayWindow contentView] display];
	}

	[[view window] addChildWindow:overlayWindow ordered:NSWindowAbove];
#endif

}

-(void) onExit
{
	// restore scale
	[[[CCDirector sharedDirector] scheduler] setTimeScale:1];

	[sliderCtl removeFromSuperview];

#ifdef __CC_PLATFORM_MAC
	CCGLView *view = (CCGLView*) [[CCDirector sharedDirector] view];
	[[view window] removeChildWindow:overlayWindow];
	[overlayWindow release];
	overlayWindow = nil;
#endif
	[super onExit];
}

-(NSString *) title
{
	return @"Scheduler timeScale Test";
}

-(NSString *) subtitle
{
	return @"Fast-forward and rewind using scheduler.timeScale";
}

@end

#pragma mark - TwoSchedulers

@implementation TwoSchedulers
#ifdef __CC_PLATFORM_IOS
- (UISlider *)sliderCtl
{
	CGRect frame = CGRectMake(12.0f, 12.0f, 120.0f, 7.0f);
	UISlider *slider = [[UISlider alloc] initWithFrame:frame];
	[slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];

	// in case the parent view draws with a custom color or gradient, use a transparent color
	slider.backgroundColor = [UIColor clearColor];

	slider.minimumValue = 0.0f;
	slider.maximumValue = 2.0f;
	slider.continuous = YES;
	slider.value = 1.0f;

    return [slider autorelease];
}

#elif defined(__CC_PLATFORM_MAC)

-(NSSlider*) sliderCtl
{
	NSSlider *slider = [[NSSlider alloc] initWithFrame: NSMakeRect (0, 0, 200, 20)];
	[slider setMinValue: 0];
	[slider setMaxValue: 2];
	[slider setFloatValue: 1];
	[slider setAction: @selector (sliderAction:)];
	[slider setTarget: self];
	[slider setContinuous: YES];

	return [slider autorelease];
}
#endif // Mac

-(void) sliderAction:(id) sender
{
	ccTime scale;

#ifdef __CC_PLATFORM_IOS
	UISlider *slider = (UISlider*) sender;
	scale = slider.value;

#elif defined(__CC_PLATFORM_MAC)
	NSSlider *slider = (NSSlider*) sender;
	float value = [slider floatValue];
	scale = value;
#endif

	if( sender == sliderCtl1 )
		[sched1 setTimeScale: scale];
	else
		[sched2 setTimeScale: scale];
}

-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		// rotate and jump
		CCActionInterval *jump1 = [CCJumpBy actionWithDuration:4 position:ccp(0,0) height:100 jumps:4];
		CCActionInterval *jump2 = [jump1 reverse];

		id seq = [CCSequence actions:jump2, jump1, nil];
		id action = [CCRepeatForever actionWithAction:seq];

		//
		// Center
		//
		CCSprite *grossini = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:grossini];
		[grossini setPosition:ccp(s.width/2,100)];
		[grossini runAction:[[action copy] autorelease]];



		CCScheduler *defaultScheduler = [[CCDirector sharedDirector] scheduler];

		//
		// Left:
		//

		// Create a new scheduler, and link it to the main scheduler
		sched1 = [[CCScheduler alloc] init];
		[defaultScheduler scheduleUpdateForTarget:sched1 priority:0 paused:NO];

		// Create a new ActionManager, and link it to the new scheudler
		actionManager1 = [[CCActionManager alloc] init];
		[sched1 scheduleUpdateForTarget:actionManager1 priority:0 paused:NO];

		for( NSUInteger i=0; i < 10; i++ ) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossinis_sister1.png"];

			// IMPORTANT: Set the actionManager running any action
			[sprite setActionManager:actionManager1];

			[self addChild:sprite];
			[sprite setPosition:ccp(30+15*i,100)];

			[sprite runAction:[[action copy] autorelease]];
		}
		sliderCtl1 = [[self sliderCtl] retain];

		//
		// Right:
		//

		// Create a new scheduler, and link it to the main scheduler
		sched2 = [[CCScheduler alloc] init];
		[defaultScheduler scheduleUpdateForTarget:sched2 priority:0 paused:NO];

		// Create a new ActionManager, and link it to the new scheudler
		actionManager2 = [[CCActionManager alloc] init];
		[sched2 scheduleUpdateForTarget:actionManager2 priority:0 paused:NO];

		for( NSUInteger i=0; i < 10; i++ ) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossinis_sister2.png"];

			// IMPORTANT: Set the actionManager running any action
			[sprite setActionManager:actionManager2];

			[self addChild:sprite];
			[sprite setPosition:ccp(s.width-30-15*i,100)];

			[sprite runAction:[[action copy] autorelease]];
		}
		sliderCtl2 = [[self sliderCtl] retain];

#ifdef __CC_PLATFORM_IOS
		CGRect frame = [sliderCtl2 frame];
#elif defined(__CC_PLATFORM_MAC)
		NSRect frame = [sliderCtl2 frame];
#endif
		frame.origin.x += 300;
		[sliderCtl2 setFrame:frame];

	}

	return self;

}


-(void) onEnter
{
	[super onEnter];

#ifdef __CC_PLATFORM_IOS

	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	UIViewController *ctl = [app navController];

	[ctl.view addSubview: sliderCtl1];
	[ctl.view addSubview: sliderCtl2];

#elif defined(__CC_PLATFORM_MAC)
	CCGLView *view = (CCGLView*) [[CCDirectorMac sharedDirector] view];

	if( ! overlayWindow ) {
		overlayWindow  = [[NSWindow alloc] initWithContentRect:[[view window] frame]
													 styleMask:NSBorderlessWindowMask
													   backing:NSBackingStoreBuffered
														 defer:NO];

		[overlayWindow setFrame:[[view window] frame] display:NO];

		[[overlayWindow contentView] addSubview:sliderCtl1];
		[[overlayWindow contentView] addSubview:sliderCtl2];

		[overlayWindow setParentWindow:[view window]];
		[overlayWindow setOpaque:NO];
		[overlayWindow makeKeyAndOrderFront:nil];
		[overlayWindow setBackgroundColor:[NSColor clearColor]];
		[[overlayWindow contentView] display];
	}

	[[view window] addChildWindow:overlayWindow ordered:NSWindowAbove];
#endif
}

-(void) onExit
{
	[super onExit];

	[sliderCtl1 removeFromSuperview];
	[sliderCtl2 removeFromSuperview];

#ifdef __CC_PLATFORM_MAC
	CCGLView *view = (CCGLView*) [[CCDirector sharedDirector] view];
	[[view window] removeChildWindow:overlayWindow];
	[overlayWindow release];
	overlayWindow = nil;
#endif // MAC
}

-(void) dealloc
{
	CCScheduler *defaultScheduler = [[CCDirector sharedDirector] scheduler];
	[defaultScheduler unscheduleAllForTarget:sched1];
	[defaultScheduler unscheduleAllForTarget:sched2];

	[sliderCtl1 release];
	[sliderCtl2 release];

	[sched1 release];
	[sched2 release];

	[actionManager1 release];
	[actionManager2 release];

	[super dealloc];
}

-(NSString *) title
{
	return @"Two custom schedulers";
}

-(NSString *) subtitle
{
	return @"Three schedulers. 2 custom + 1 default. Two different time scales";
}
@end

#pragma mark - AppController

#ifdef __CC_PLATFORM_IOS

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Turn on display FPS
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

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [nextTest() node]];		
		[director runWithScene:scene];
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
	[scene addChild: [nextTest() node]];

	[director_ runWithScene:scene];
}
@end
#endif


