//
// Ease Demo
// a cocos2d example
//

// local import
#import "cocos2d.h"
#import "EaseActionsTest.h"


static int sceneIdx=-1;
static NSString *transitions[] = {
				@"SpriteEase",
				@"SpriteEaseInOut",
				@"SpriteEaseExponential",
				@"SpriteEaseExponentialInOut",
				@"SpriteEaseSine",
				@"SpriteEaseSineInOut",
				@"SpeedTest",
				@"SchedulerTest",
};

enum {
	kTagAction1 = 1,
	kTagAction2 = 2,
	kTagSlider = 1,
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

		// Example:
		// You can create a sprite using a Texture2D
		Texture2D *tex = [ [Texture2D alloc] initWithImage: [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"grossini.png" ofType:nil] ] ];
		grossini = [[Sprite spriteWithTexture:tex] retain];
		[tex release];
		
		// Example:
		// Or you can create an sprite using a filename. PNG and BMP files are supported. Probably TIFF too
		tamara = [[Sprite spriteWithFile:@"grossinis_sister1.png"] retain];
		kathia = [[Sprite spriteWithFile:@"grossinis_sister2.png"] retain];
		
		[self addChild: grossini z:3];
		[self addChild: kathia z:2];
		[self addChild: tamara z:1];

		CGSize s = [[Director sharedDirector] winSize];
		
		[grossini setPosition: ccp(60, 50)];
		[kathia setPosition: ccp(60, 150)];
		[tamara setPosition: ccp(60, 250)];
		
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];

		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(480/2-100,30);
		item2.position = ccp(480/2, 30);
		item3.position = ccp(480/2+100,30);
		[self addChild: menu z:1];
	}

	return self;
}

-(void) dealloc
{
	[grossini release];
	[tamara release];
	[kathia release];
	[super dealloc];
}


-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}


-(void) positionForTwo
{	
	grossini.position = ccp( 60, 120 );
	tamara.position = ccp( 60, 220);
	kathia.visible = NO;
}
-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark -
#pragma mark Ease Actions

@implementation SpriteEase
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:ccp(350,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [EaseIn actionWithAction:[[move copy] autorelease] rate:3.0f];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [EaseOut actionWithAction:[[move copy] autorelease] rate:3.0f];
	id move_ease_out_back = [move_ease_out reverse];
	
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease_in, move_ease_in_back, nil];
	id seq3 = [Sequence actions: move_ease_out, move_ease_out_back, nil];
	
	
	[grossini runAction: [RepeatForever actionWithAction:seq1]];
	[tamara runAction: [RepeatForever actionWithAction:seq2]];
	[kathia runAction: [RepeatForever actionWithAction:seq3]];
}

-(NSString *) title
{
	return @"EaseIn - EaseOut";
}
@end

@implementation SpriteEaseInOut
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:ccp(350,0)];
//	id move_back = [move reverse];
	
	id move_ease_inout1 = [EaseInOut actionWithAction:[[move copy] autorelease] rate:2.0f];
	id move_ease_inout_back1 = [move_ease_inout1 reverse];
	
	id move_ease_inout2 = [EaseInOut actionWithAction:[[move copy] autorelease] rate:3.0f];
	id move_ease_inout_back2 = [move_ease_inout2 reverse];

	id move_ease_inout3 = [EaseInOut actionWithAction:[[move copy] autorelease] rate:4.0f];
	id move_ease_inout_back3 = [move_ease_inout3 reverse];

	
	id seq1 = [Sequence actions: move_ease_inout1, move_ease_inout_back1, nil];
	id seq2 = [Sequence actions: move_ease_inout2, move_ease_inout_back2, nil];
	id seq3 = [Sequence actions: move_ease_inout3, move_ease_inout_back3, nil];
		
	[tamara runAction: [RepeatForever actionWithAction:seq1]];
	[kathia runAction: [RepeatForever actionWithAction:seq2]];
	[grossini runAction: [RepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"EaseInOut and rates";
}
@end


@implementation SpriteEaseSine
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:ccp(350,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [EaseSineIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [EaseSineOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];
	
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease_in, move_ease_in_back, nil];
	id seq3 = [Sequence actions: move_ease_out, move_ease_out_back, nil];
	
	
	[grossini runAction: [RepeatForever actionWithAction:seq1]];
	[tamara runAction: [RepeatForever actionWithAction:seq2]];
	[kathia runAction: [RepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"EaseSineIn - EaseSineOut";
}
@end

@implementation SpriteEaseSineInOut
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:ccp(350,0)];
	id move_back = [move reverse];
	
	id move_ease = [EaseSineInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease, move_ease_back, nil];

	[self positionForTwo];

	[grossini runAction: [RepeatForever actionWithAction:seq1]];
	[tamara runAction: [RepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseSineInOut action";
}
@end


@implementation SpriteEaseExponential
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:ccp(350,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [EaseExponentialIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [EaseExponentialOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];
	
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease_in, move_ease_in_back, nil];
	id seq3 = [Sequence actions: move_ease_out, move_ease_out_back, nil];
	

	[grossini runAction: [RepeatForever actionWithAction:seq1]];
	[tamara runAction: [RepeatForever actionWithAction:seq2]];
	[kathia runAction: [RepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"ExpIn - ExpOut actions";
}
@end

@implementation SpriteEaseExponentialInOut
-(void) onEnter
{
	[super onEnter];
	
	id move = [MoveBy actionWithDuration:3 position:ccp(350,0)];
	id move_back = [move reverse];
	
	id move_ease = [EaseExponentialInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];
	
	id seq1 = [Sequence actions: move, move_back, nil];
	id seq2 = [Sequence actions: move_ease, move_ease_back, nil];
	
	[self positionForTwo];
	
	[grossini runAction: [RepeatForever actionWithAction:seq1]];
	[tamara runAction: [RepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseExponentialInOut action";
}
@end

@implementation SpeedTest
-(void) onEnter
{
	[super onEnter];
	

	// rotate and jump
	IntervalAction *jump1 = [JumpBy actionWithDuration:4 position:ccp(-400,0) height:100 jumps:4];
	IntervalAction *jump2 = [jump1 reverse];
	IntervalAction *rot1 = [RotateBy actionWithDuration:4 angle:360*2];
	IntervalAction *rot2 = [rot1 reverse];
	
	id seq3_1 = [Sequence actions:jump2, jump1, nil];
	id seq3_2 = [Sequence actions: rot1, rot2, nil];
	id spawn = [Spawn actions:seq3_1, seq3_2, nil];
	id action = [Speed actionWithAction: [RepeatForever actionWithAction:spawn] speed:1.0f];
	[action setTag: kTagAction1];
	
	id action2 = [[action copy] autorelease];
	id action3 = [[action copy] autorelease];

	[action2 setTag:kTagAction1];
	[action3 setTag:kTagAction1];
	
	[grossini runAction: action2 ];
	[tamara runAction: action3];
	[kathia runAction:action];
	
	
	[self schedule:@selector(altertime:) interval:1.0f];
}

-(void) altertime:(ccTime)dt
{	
	id action1 = [grossini getActionByTag:kTagAction1];
	id action2 = [tamara getActionByTag:kTagAction1];
	id action3 = [kathia getActionByTag:kTagAction1];
	
	[action1 setSpeed: CCRANDOM_0_1() * 2];
	[action2 setSpeed: CCRANDOM_0_1() * 2];
	[action3 setSpeed: CCRANDOM_0_1() * 2];

}

-(NSString *) title
{
	return @"Speed action";
}
@end

@implementation SchedulerTest
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
	[[Scheduler sharedScheduler] setTimeScale: sliderCtl.value];
}

-(void) onEnter
{
	[super onEnter];
	
	
	// rotate and jump
	IntervalAction *jump1 = [JumpBy actionWithDuration:4 position:ccp(-400,0) height:100 jumps:4];
	IntervalAction *jump2 = [jump1 reverse];
	IntervalAction *rot1 = [RotateBy actionWithDuration:4 angle:360*2];
	IntervalAction *rot2 = [rot1 reverse];
	
	id seq3_1 = [Sequence actions:jump2, jump1, nil];
	id seq3_2 = [Sequence actions: rot1, rot2, nil];
	id spawn = [Spawn actions:seq3_1, seq3_2, nil];
	id action = [RepeatForever actionWithAction:spawn];
	
	id action2 = [[action copy] autorelease];
	id action3 = [[action copy] autorelease];
	
	
	[grossini runAction: [Speed actionWithAction:action speed:0.5f]];
	[tamara runAction: [Speed actionWithAction:action2 speed:1.5f]];
	[kathia runAction: [Speed actionWithAction:action3 speed:1.0f]];
	
	ParticleSystem *emitter = [ParticleFireworks node];
	[self addChild:emitter];
	
	sliderCtl = [self sliderCtl];
	[[[[Director sharedDirector] openGLView] window] addSubview: sliderCtl];
}

-(void) onExit
{
	[sliderCtl removeFromSuperview];
	[super onExit];
}

-(NSString *) title
{
	return @"Scheduler scaleTime Test";
}
@end


#pragma mark -
#pragma mark AppController

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
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	Scene *scene = [Scene node];
	[scene addChild: [nextAction() node]];	
	
	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
