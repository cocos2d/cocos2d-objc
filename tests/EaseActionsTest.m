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
				@"SpriteEaseElastic",
				@"SpriteEaseElasticInOut",
				@"SpriteEaseBounce",
				@"SpriteEaseBounceInOut",
				@"SpriteEaseBack",
				@"SpriteEaseBackInOut",
				@"SpeedTest",
				@"SchedulerTest",
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

		grossini = [[CCSprite alloc] initWithFile:@"grossini.png"];
		tamara = [[CCSprite alloc] initWithFile:@"grossinis_sister1.png"];
		kathia = [[CCSprite alloc] initWithFile:@"grossinis_sister2.png"];
		
		[self addChild: grossini z:3];
		[self addChild: kathia z:2];
		[self addChild: tamara z:1];

		CGSize s = [[CCDirector sharedDirector] winSize];
		
		[grossini setPosition: ccp(60, 50)];
		[kathia setPosition: ccp(60, 150)];
		[tamara setPosition: ccp(60, 250)];
		
 		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];

		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		menu.position = CGPointZero;
		item1.position = ccp(s.width/2-100,30);
		item2.position = ccp(s.width/2, 30);
		item3.position = ccp(s.width/2+100,30);
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

#define CCCA(x) [[x copy] autorelease]

@implementation SpriteEase
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];

	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [CCEaseIn actionWithAction:[[move copy] autorelease] rate:3.0f];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [CCEaseOut actionWithAction:[[move copy] autorelease] rate:3.0f];
	id move_ease_out_back = [move_ease_out reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];
	
	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease_in, CCCA(delay), move_ease_in_back, CCCA(delay), nil];
	id seq3 = [CCSequence actions: move_ease_out, CCCA(delay), move_ease_out_back, CCCA(delay), nil];
	
	
	CCAction *a2 = [grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[a2 setTag:1];

	CCAction *a1 =[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
	[a1 setTag:1];

	CCAction *a = [kathia runAction: [CCRepeatForever actionWithAction:seq3]];
	[a setTag:1];
	
	[self schedule:@selector(testStopAction:) interval:6.25f];
}

-(void) testStopAction:(ccTime)dt
{
	[self unschedule:_cmd];
	[tamara stopActionByTag:1];
	[kathia stopActionByTag:1];
	[grossini stopActionByTag:1];
}

-(NSString *) title
{
	return @"EaseIn - EaseOut - Stop";
}
@end

@implementation SpriteEaseInOut
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];

	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
//	id move_back = [move reverse];
	
	id move_ease_inout1 = [CCEaseInOut actionWithAction:[[move copy] autorelease] rate:2.0f];
	id move_ease_inout_back1 = [move_ease_inout1 reverse];
	
	id move_ease_inout2 = [CCEaseInOut actionWithAction:[[move copy] autorelease] rate:3.0f];
	id move_ease_inout_back2 = [move_ease_inout2 reverse];

	id move_ease_inout3 = [CCEaseInOut actionWithAction:[[move copy] autorelease] rate:4.0f];
	id move_ease_inout_back3 = [move_ease_inout3 reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];

	id seq1 = [CCSequence actions: move_ease_inout1, delay, move_ease_inout_back1, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease_inout2, CCCA(delay), move_ease_inout_back2, CCCA(delay), nil];
	id seq3 = [CCSequence actions: move_ease_inout3, CCCA(delay), move_ease_inout_back3, CCCA(delay), nil];
		
	[tamara runAction: [CCRepeatForever actionWithAction:seq1]];
	[kathia runAction: [CCRepeatForever actionWithAction:seq2]];
	[grossini runAction: [CCRepeatForever actionWithAction:seq3]];
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
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [CCEaseSineIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [CCEaseSineOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];

	
	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease_in, CCCA(delay), move_ease_in_back, CCCA(delay), nil];
	id seq3 = [CCSequence actions: move_ease_out, CCCA(delay), move_ease_out_back, CCCA(delay), nil];
	
	
	[grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
	[kathia runAction: [CCRepeatForever actionWithAction:seq3]];
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
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease = [CCEaseSineInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];

	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease, CCCA(delay), move_ease_back, CCCA(delay), nil];

	[self positionForTwo];

	[grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseSineInOut action";
}
@end

#pragma mark SpriteEaseExponential

@implementation SpriteEaseExponential
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [CCEaseExponentialIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [CCEaseExponentialOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];
	
	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease_in, CCCA(delay), move_ease_in_back, CCCA(delay), nil];
	id seq3 = [CCSequence actions: move_ease_out, CCCA(delay), move_ease_out_back, CCCA(delay), nil];
	

	[grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
	[kathia runAction: [CCRepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"ExpIn - ExpOut actions";
}
@end

#pragma mark SpriteEaseExponentialInOut

@implementation SpriteEaseExponentialInOut
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease = [CCEaseExponentialInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];

	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease, CCCA(delay), move_ease_back, CCCA(delay), nil];
	

	[self positionForTwo];
	
	[grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseExponentialInOut action";
}
@end

#pragma mark SpriteEaseElasticInOut

@implementation SpriteEaseElasticInOut
-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	
	id move_ease_inout1 = [CCEaseElasticInOut actionWithAction:[[move copy] autorelease] period:0.3f];
	id move_ease_inout_back1 = [move_ease_inout1 reverse];
	
	id move_ease_inout2 = [CCEaseElasticInOut actionWithAction:[[move copy] autorelease] period:0.45f];
	id move_ease_inout_back2 = [move_ease_inout2 reverse];
	
	id move_ease_inout3 = [CCEaseElasticInOut actionWithAction:[[move copy] autorelease] period:0.6f];
	id move_ease_inout_back3 = [move_ease_inout3 reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];

	
	id seq1 = [CCSequence actions: move_ease_inout1, delay, move_ease_inout_back1, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease_inout2, CCCA(delay), move_ease_inout_back2, CCCA(delay), nil];
	id seq3 = [CCSequence actions: move_ease_inout3, CCCA(delay), move_ease_inout_back3, CCCA(delay), nil];
	
	[tamara runAction: [CCRepeatForever actionWithAction:seq1]];
	[kathia runAction: [CCRepeatForever actionWithAction:seq2]];
	[grossini runAction: [CCRepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"EaseElasticInOut action";
}
@end

#pragma mark SpriteEaseElastic

@implementation SpriteEaseElastic
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [CCEaseElasticIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [CCEaseElasticOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];

	id delay = [CCDelayTime actionWithDuration:0.25f];

	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease_in, CCCA(delay), move_ease_in_back, CCCA(delay), nil];
	id seq3 = [CCSequence actions: move_ease_out, CCCA(delay), move_ease_out_back, CCCA(delay), nil];
	
	[grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
	[kathia runAction: [CCRepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"Elastic In - Out actions";
}
@end

#pragma mark SpriteEaseBounce

@implementation SpriteEaseBounce
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [CCEaseBounceIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [CCEaseBounceOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];

	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease_in, CCCA(delay), move_ease_in_back, CCCA(delay), nil];
	id seq3 = [CCSequence actions: move_ease_out, CCCA(delay), move_ease_out_back, CCCA(delay), nil];
	
	[grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
	[kathia runAction: [CCRepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"Bounce In - Out actions";
}
@end

@implementation SpriteEaseBounceInOut
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease = [CCEaseBounceInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];

	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease, CCCA(delay), move_ease_back, CCCA(delay), nil];
	
	[self positionForTwo];
	
	[grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseBounceInOut action";
}
@end

#pragma mark SpriteEaseBack

@implementation SpriteEaseBack
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease_in = [CCEaseBackIn actionWithAction:[[move copy] autorelease]];
	id move_ease_in_back = [move_ease_in reverse];
	
	id move_ease_out = [CCEaseBackOut actionWithAction:[[move copy] autorelease]];
	id move_ease_out_back = [move_ease_out reverse];
	
	id delay = [CCDelayTime actionWithDuration:0.25f];

	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease_in, CCCA(delay), move_ease_in_back, CCCA(delay), nil];
	id seq3 = [CCSequence actions: move_ease_out, CCCA(delay), move_ease_out_back, CCCA(delay), nil];
	
	[grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
	[kathia runAction: [CCRepeatForever actionWithAction:seq3]];
}
-(NSString *) title
{
	return @"Back In - Out actions";
}
@end

@implementation SpriteEaseBackInOut
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(s.width-130,0)];
	id move_back = [move reverse];
	
	id move_ease = [CCEaseBackInOut actionWithAction:[[move copy] autorelease]];
	id move_ease_back = [move_ease reverse];

	id delay = [CCDelayTime actionWithDuration:0.25f];

	id seq1 = [CCSequence actions: move, delay, move_back, CCCA(delay), nil];
	id seq2 = [CCSequence actions: move_ease, CCCA(delay), move_ease_back, CCCA(delay), nil];
	

	[self positionForTwo];
	
	[grossini runAction: [CCRepeatForever actionWithAction:seq1]];
	[tamara runAction: [CCRepeatForever actionWithAction:seq2]];
}
-(NSString *) title
{
	return @"EaseBackInOut action";
}
@end


#pragma mark SpeedTest

@implementation SpeedTest
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
	id action = [CCSpeed actionWithAction: [CCRepeatForever actionWithAction:spawn] speed:1.0f];
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
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
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
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(NSSlider*) sliderCtl
{
	if( sliderCtl == nil )
	{
		sliderCtl = [[NSSlider alloc] initWithFrame: NSMakeRect (0, 0, 200, 20)];
		[sliderCtl setMinValue: 0];
		[sliderCtl setMaxValue: 3];
		[sliderCtl setFloatValue: 1];
		[sliderCtl setAction: @selector (sliderAction:)];
		[sliderCtl setTarget: self];
		[sliderCtl setContinuous: YES];
	}
	
	return sliderCtl;
}
#endif // Mac

-(void) sliderAction:(id) sender
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	[[CCScheduler sharedScheduler] setTimeScale: sliderCtl.value];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	
	[[CCScheduler sharedScheduler] setTimeScale: [sliderCtl floatValue]];
#endif
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
	id action = [CCRepeatForever actionWithAction:spawn];
	
	id action2 = [[action copy] autorelease];
	id action3 = [[action copy] autorelease];
	
	
	[grossini runAction: [CCSpeed actionWithAction:action speed:0.5f]];
	[tamara runAction: [CCSpeed actionWithAction:action2 speed:1.5f]];
	[kathia runAction: [CCSpeed actionWithAction:action3 speed:1.0f]];
	
	CCParticleSystem *emitter = [CCParticleFireworks node];
	[self addChild:emitter];
	
	sliderCtl = [self sliderCtl];
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	[[[[CCDirector sharedDirector] openGLView] window] addSubview: sliderCtl];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	MacGLView *view = [[CCDirector sharedDirector] openGLView];

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
	[sliderCtl removeFromSuperview];

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	MacGLView *view = [[CCDirector sharedDirector] openGLView];
	[[view window] removeChildWindow:overlayWindow];
	[overlayWindow release];
	overlayWindow = nil;
#endif
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

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

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
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
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

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
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

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@implementation cocos2dmacAppDelegate

@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:YES];
	
	[director setOpenGLView:glView_];
	
	//	[director setProjection:kCCDirectorProjection2D];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene:scene];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
#endif
