//
// cocos node tests
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "cocosnodeTest.h"


enum {
	kTagSprite1 = 1,
	kTagSprite2 = 2,
	kTagSprite3 = 3,
	kTagSlider,
};


static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Test2",
			@"Test4",
			@"Test5",
			@"Test6",
			@"StressTest1",
			@"StressTest2",
			@"NodeToWorld",
			@"CameraOrbitTest",
			@"CameraZoomTest",	
			@"SchedulerTest1",
			@"SchedulerTest2",
			@"SchedulerTest3",
			@"SchedulerTest4",
			@"SchedulerTest5",
			@"SchedulerScaleTest",
			@"TimerScaleTest",
			@"TimerScaleWithChildrenTest",
			@"PerFrameUpdateTest",
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
#pragma mark TestDemo

@implementation TestDemo
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];
	
		CCLabel* label = [CCLabel labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:-1];	
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	// Don't create void root scene. Testing issue #709
	CCScene *s = [restartAction() node];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	// Don't create void root scene. Testing issue #709
	CCScene *s = [nextAction() node];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	// Don't create void root scene. Testing issue #709
	CCScene *s = [backAction() node];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark -
#pragma mark Test2

@implementation Test2
-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	CCSprite *sp3 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	CCSprite *sp4 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	
	sp1.position = ccp(100, s.height /2 );
	sp2.position = ccp(380, s.height /2 );
	[self addChild: sp1];
	[self addChild: sp2];
	
	sp3.scale = 0.25f;
	sp4.scale = 0.25f;
	
	[sp1 addChild:sp3];
	[sp2 addChild:sp4];
	
	id a1 = [CCRotateBy actionWithDuration:2 angle:360];
	id a2 = [CCScaleBy actionWithDuration:2 scale:2];
	
	id action1 = [CCRepeatForever actionWithAction:
				  [CCSequence actions: a1, a2, [a2 reverse], nil]
									];
	id action2 = [CCRepeatForever actionWithAction:
				  [CCSequence actions: [[a1 copy] autorelease], [[a2 copy] autorelease], [a2 reverse], nil]
									];
	
	sp2.anchorPoint = ccp(0,0);
	
	[sp1 runAction:action1];
	[sp2 runAction:action2];	
}
-(NSString *) title
{
	return @"anchorPoint and children";
}
@end

#pragma mark -
#pragma mark Test4

@implementation Test4
-(id) init
{
	if( !( self=[super init]) )
		return nil;
		
	CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	
	sp1.position = ccp(100,160);
	sp2.position = ccp(380,160);
	
	[self addChild:sp1 z:0 tag:2];
	[self addChild:sp2 z:0 tag:3];
	
	[self schedule:@selector(delay2:) interval:2.0f];
	[self schedule:@selector(delay4:) interval:4.0f];
	
	return self;
}

-(void) delay2:(ccTime) dt
{
	id node = [self getChildByTag:2];
	id action1 = [CCRotateBy actionWithDuration:1 angle:360];
	[node runAction:action1];
}

-(void) delay4:(ccTime) dt
{
	[self unschedule:_cmd];
	[self removeChildByTag:3 cleanup:NO];
}


-(NSString *) title
{
	return @"tags";
}
@end

#pragma mark -
#pragma mark Test5

@implementation Test5
-(id) init
{
	if( ( self=[super init]) ) {

		CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		
		sp1.position = ccp(100,160);
		sp2.position = ccp(380,160);

		id rot = [CCRotateBy actionWithDuration:2 angle:360];
		id rot_back = [rot reverse];
		id forever = [CCRepeatForever actionWithAction:
						[CCSequence actions:rot, rot_back, nil]];
		id forever2 = [[forever copy] autorelease];
		[forever setTag:101];
		[forever2 setTag:102];
													  
		[self addChild:sp1 z:0 tag:kTagSprite1];
		[self addChild:sp2 z:0 tag:kTagSprite2];
				
		[sp1 runAction:forever];
		[sp2 runAction:forever2];
		
		[self schedule:@selector(addAndRemove:) interval:2.0f];
	}
	
	return self;
}

-(void) addAndRemove:(ccTime) dt
{
	CCNode *sp1 = [self getChildByTag:kTagSprite1];
	CCNode *sp2 = [self getChildByTag:kTagSprite2];

	[sp1 retain];
	[sp2 retain];
	
	[self removeChild:sp1 cleanup:NO];
	[self removeChild:sp2 cleanup:YES];
	
	[self addChild:sp1 z:0 tag:kTagSprite1];
	[self addChild:sp2 z:0 tag:kTagSprite2];
	
	[sp1 release];
	[sp2 release];

}


-(NSString *) title
{
	return @"remove and cleanup";
}
@end

#pragma mark -
#pragma mark Test6

@implementation Test6
-(id) init
{
	if( ( self=[super init]) ) {
		
		CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		CCSprite *sp11 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];

		CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		CCSprite *sp21 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
		
		sp1.position = ccp(100,160);
		sp2.position = ccp(380,160);
		
		
		id rot = [CCRotateBy actionWithDuration:2 angle:360];
		id rot_back = [rot reverse];
		id forever1 = [CCRepeatForever actionWithAction:
					  [CCSequence actions:rot, rot_back, nil]];
		id forever11 = [[forever1 copy] autorelease];

		id forever2 = [[forever1 copy] autorelease];
		id forever21 = [[forever1 copy] autorelease];
		
		[self addChild:sp1 z:0 tag:kTagSprite1];
		[sp1 addChild:sp11];
		[self addChild:sp2 z:0 tag:kTagSprite2];
		[sp2 addChild:sp21];
		
		[sp1 runAction:forever1];
		[sp11 runAction:forever11];
		[sp2 runAction:forever2];
		[sp21 runAction:forever21];
		
		[self schedule:@selector(addAndRemove:) interval:2.0f];
	}
	
	return self;
}

-(void) addAndRemove:(ccTime) dt
{
	CCNode *sp1 = [self getChildByTag:kTagSprite1];
	CCNode *sp2 = [self getChildByTag:kTagSprite2];
	
	[sp1 retain];
	[sp2 retain];
	
	[self removeChild:sp1 cleanup:NO];
	[self removeChild:sp2 cleanup:YES];
	
	[self addChild:sp1 z:0 tag:kTagSprite1];
	[self addChild:sp2 z:0 tag:kTagSprite2];
	
	[sp1 release];
	[sp2 release];
}


-(NSString *) title
{
	return @"remove/cleanup with children";
}
@end

#pragma mark -
#pragma mark StressTest1

@implementation StressTest1
-(id) init
{
	if( ( self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[self addChild:sp1 z:0 tag:kTagSprite1];
		
		sp1.position = ccp(s.width/2, s.height/2);		

		[self schedule:@selector(shouldNotCrash:) interval:1.0f];
	}
	
	return self;
}

- (void) shouldNotCrash:(ccTime) delta
{	
	[self unschedule:_cmd];

	CGSize s = [[CCDirector sharedDirector] winSize];

	// if the node has timers, it crashes
	CCNode *explosion = [CCParticleSun node];
	
	// if it doesn't, it works Ok.
//	CocosNode *explosion = [Sprite spriteWithFile:@"grossinis_sister2.png"];

	explosion.position = ccp(s.width/2, s.height/2);
	
	[self runAction:[CCSequence actions:
						[CCRotateBy actionWithDuration:2 angle:360],
						[CCCallFuncN actionWithTarget:self selector:@selector(removeMe:)],
						nil]];
	
	[self addChild:explosion];
}

// remove
- (void) removeMe: (id)node
{	
	[parent removeChild:node cleanup:YES];
	[self nextCallback:self];
}


-(NSString *) title
{
	return @"stress test #1: no crashes";
}
@end

#pragma mark -
#pragma mark StressTest2

@implementation StressTest2
-(id) init
{
	// 
	// Purpose of this test:
	// Objects should be released when a layer is removed
	//
	
	if( ( self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		CCLayer *sublayer = [CCLayer node];
		
		CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		sp1.position = ccp(80, s.height/2);
		
		id move = [CCMoveBy actionWithDuration:3 position:ccp(350,0)];
		id move_ease_inout3 = [CCEaseInOut actionWithAction:[[move copy] autorelease] rate:2.0f];
		id move_ease_inout_back3 = [move_ease_inout3 reverse];
		id seq3 = [CCSequence actions: move_ease_inout3, move_ease_inout_back3, nil];
		[sp1 runAction: [CCRepeatForever actionWithAction:seq3]];
		[sublayer addChild:sp1 z:1];
		
		CCParticleFire *fire = [CCParticleFire node];
		fire.position = ccp(80, s.height/2-50);
		id copy_seq3 = [[seq3 copy] autorelease];
		[fire runAction:[CCRepeatForever actionWithAction:copy_seq3]];
		[sublayer addChild:fire z:2];
				
		[self schedule:@selector(shouldNotLeak:) interval:6.0f];
		
		[self addChild:sublayer z:0 tag:kTagSprite1];
	}
	
	return self;
}

- (void) shouldNotLeak:(ccTime)dt
{	
	[self unschedule:_cmd];
	id sublayer = [self getChildByTag:kTagSprite1];
	[sublayer removeAllChildrenWithCleanup:YES];
}

-(NSString *) title
{
	return @"stress test #2: no leaks";
}
@end

#pragma mark -
#pragma mark SchedulerTest1

@interface CustomNode : CCNode
{
}
@end
@implementation CustomNode
-(void) doSomething:(ccTime)dt
{
	NSLog(@"do something...");
}
@end


@implementation SchedulerTest1
-(id) init
{
	// 
	// Purpose of this test:
	// Scheduler should be released
	//
	
	if( ( self=[super init]) ) {
		CCLayer *layer = [CustomNode node];
		NSLog(@"retain count after init is %d", [layer retainCount]);                // 1
		
		[self addChild:layer z:0];
		NSLog(@"retain count after addChild is %d", [layer retainCount]);      // 2
		
		[layer schedule:@selector(doSomething:)];
		NSLog(@"retain count after schedule is %d", [layer retainCount]);      // 3
		
		[layer unschedule:@selector(doSomething:)];
		NSLog(@"retain count after unschedule is %d", [layer retainCount]);		// STILL 3!
	}
	
	return self;
}

-(NSString *) title
{
	return @"cocosnode scheduler test #1";
}
@end

#pragma mark -
#pragma mark SchedulerTest2

@implementation SchedulerTest2
-(id) init
{
	if( !( self=[super init]) )
		return nil;
	
	CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	
	sp1.position = ccp(100,160);
	sp2.position = ccp(380,160);
	
	[self addChild:sp1 z:0 tag:2];
	[self addChild:sp2 z:0 tag:3];
	
	[self schedule:@selector(doRotate:) interval:2.0f repeat:4];  // sister1 should rotate 4 times only
	[self schedule:@selector(doRotate2:) interval:2.0f];					// sister2 should keep rotating

	return self;
}

-(void) doRotate:(ccTime) dt
{
	id node = [self getChildByTag:2];
	id action1 = [CCRotateBy actionWithDuration:1 angle:360];
	[node runAction:action1];
}

-(void) doRotate2:(ccTime) dt
{
	id node = [self getChildByTag:3];
	id action1 = [CCRotateBy actionWithDuration:1 angle:360];
	[node runAction:action1];
}

-(NSString *) title
{
	return @"schedule repeat limit";
}
@end

#pragma mark -
#pragma mark SchedulerTest3

@implementation SchedulerTest3
//
// This class tests that the scheduled methods are correctly dealloced
// Otherwise the whole scene will be leaked.
//
- (id) init
{
	if( (self=[super init])) {
		[self schedule: @selector(slowStep:) interval:0.5f];
		[self schedule: @selector(test:) interval:2 repeat:1];
	}
	return self;
}

- (void) test:(ccTime)d
{
	// will replace the current scene
	[self nextCallback:self];
}

- (void) slowStep:(ccTime)dt
{
	NSLog(@"slowStep: %f", dt);
}

- (void) dealloc
{
	NSLog(@"SchedulerTest3: Test passed");
	[super dealloc];
}
		
-(NSString *) title
{
	return @"schedule auto dealloc";
}
		
@end


#pragma mark -
#pragma mark SchedulerTest4


// Issue 714
@implementation SchedulerTest4
-(id) init
{
	if( !( self=[super init]) )
		return nil;
	
	CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
	
	sp1.position = ccp(320,160);
	
	[self addChild:sp1 z:0 tag:2];
	
	CCLabel* l = [CCLabel labelWithString:@"Sister should rotate after random interval (and repeat)" fontName:@"Thonburi" fontSize:16];
	[self addChild:l];
	[l setPosition:ccp(480/2, 245)];	
	
	ccTime t = 1 + CCRANDOM_0_1() * 3;
	[self schedule:@selector(doRotate:) interval:t repeat:1];
	
	return self;
}

-(void) doRotate:(ccTime) dt
{
	id node = [self getChildByTag:2];
	id action1 = [CCRotateBy actionWithDuration:0.25f angle:360];
	[node runAction:action1];
	ccTime t = 1 + CCRANDOM_0_1() * 3;
	[self schedule:@selector(doRotate:) interval:t repeat:1];
	
}

-(NSString *) title
{
	return @"schedule repeat limit restart";
}
@end


#pragma mark -
#pragma mark SchedulerTest5

@implementation SchedulerTest5
-(id) init
{
	if( ( self=[super init]) ) {

		// testing delta time.
		// 1st delta time should be 0, right ???
		[self schedule:@selector(test1:) repeat:5];
		[self schedule:@selector(test2:) interval:1 repeat:5];
		[self schedule:@selector(test3:) interval:5 repeat:2];
	}
	
	return self;
}

-(void) test1:(ccTime)dt
{
	NSLog(@"test1: dt=%f",dt);
}

-(void) test2:(ccTime)dt
{
	NSLog(@"test2: dt=%f",dt);
}

-(void) test3:(ccTime)dt
{
	NSLog(@"test3: dt=%f",dt);
}

-(NSString *) title
{
	return @"schedule: testing delta times";
}
@end

#pragma mark -
#pragma mark SchedulerScaleTest

@implementation SchedulerScaleTest
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

	[self scaleAllTimers:sliderCtl.value withChildren:YES];
}

-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCLabel* l = [CCLabel labelWithString:@"Move the slider" fontName:@"Thonburi" fontSize:16];
	[self addChild:l];
	[l setPosition:ccp(s.width/2, 245)];


	// timers
	label1 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"0" fntFile:@"bitmapFontTest4.fnt"];
	label2 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"0" fntFile:@"bitmapFontTest4.fnt"];
	label3 = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"0" fntFile:@"bitmapFontTest4.fnt"];
	
	[self schedule: @selector(step1:) interval: 0.25f];
	[self schedule: @selector(step2:) interval: 0.5f];
	[self schedule: @selector(step3:) interval: 1.0f];
	
	label1.position = ccp(80,s.height/2);
	label2.position = ccp(240,s.height/2);
	label3.position = ccp(400,s.height/2);
	
	[self addChild:label1];
	[self addChild:label2];
	[self addChild:label3];	
	
	// actions
	CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
	[self addChild:sprite z:0];
	[sprite setPosition:ccp(100,100)];
	
	// particle (uses timer)
	id particle = [CCParticleFlower node];
	[self addChild:particle];
	[particle setPosition:ccp(s.width-80,80)];
	
	// Action 1
	CCIntervalAction *action1 = [CCMoveBy actionWithDuration:2 position:ccp(300,0)];
	CCAction *back1 = [action1 reverse];
	CCSequence *seq1 = [CCSequence actions:action1, back1, nil];
	CCAction *rep1 = [CCRepeatForever actionWithAction:seq1];
	[sprite runAction:rep1];
	
	
	// Action 2
	CCIntervalAction *action2 = [CCRotateBy actionWithDuration:2 angle:180];
	CCAction *back2 = [action2 reverse];
	CCSequence *seq2 = [CCSequence actions:action2, back2, nil];
	CCAction *rep2 = [CCRepeatForever actionWithAction:seq2];
	[sprite runAction:rep2];
	
	CCSprite *child = [CCSprite spriteWithFile:@"grossini.png"];
	[sprite addChild:child z:0];
	[child setScale:0.5f];
	
	// Action 2
	id rot = [CCRotateBy actionWithDuration:2 angle:180];
	id rep = [CCRepeatForever actionWithAction:rot];
	[child runAction:rep];	
	

	sliderCtl = [self sliderCtl];
	[[[[CCDirector sharedDirector] openGLView] window] addSubview: sliderCtl];
}

-(void) onExit
{
	[sliderCtl removeFromSuperview];
	[super onExit];
}

-(void) step1: (ccTime) delta
{
	//	time1 +=delta;
	time1 +=1;
	[label1 setString: [NSString stringWithFormat:@"%2.1f", time1] ];
}

-(void) step2: (ccTime) delta
{
	//	time2 +=delta;
	time2 +=1;
	[label2 setString: [NSString stringWithFormat:@"%2.1f", time2] ];
}

-(void) step3: (ccTime) delta
{
	//	time3 +=delta;
	time3 +=1;
	[label3 setString: [NSString stringWithFormat:@"%2.1f", time3] ];
}

-(NSString*) title
{
	return @"Actions & Timer with Slider";
}
@end


#pragma mark -
#pragma mark NodeToWorld

@implementation NodeToWorld
-(id) init
{
	if( ( self=[super init]) ) {

		//
		// This code tests that nodeToParent works OK:
		//  - It tests different anchor Points
		//  - It tests different children anchor points

		CCSprite *back = [CCSprite spriteWithFile:@"background3.png"];
		[self addChild:back z:-10];
		[back setAnchorPoint:ccp(0,0)];
		CGSize backSize = [back contentSize];
		
		CCMenuItem *item = [CCMenuItemImage itemFromNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png"];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[menu alignItemsVertically];
		[menu setPosition:ccp(backSize.width/2, backSize.height/2)];
		[back addChild:menu];
		
		id rot = [CCRotateBy actionWithDuration:5 angle:360];
		id fe = [CCRepeatForever actionWithAction:rot];
		[item runAction: fe];
		
		id move = [CCMoveBy actionWithDuration:3 position:ccp(200,0)];
		id move_back = [move reverse];
		id seq = [CCSequence actions:move, move_back, nil];
		id fe2 = [CCRepeatForever actionWithAction:seq];
		[back runAction:fe2];
	}
	
	return self;
}

-(NSString *) title
{
	return @"nodeToParent transform";
}
@end


#pragma mark -
#pragma mark CameraOrbitTest

@implementation CameraOrbitTest
-(void) onEnter
{
	[super onEnter];
	[[CCDirector sharedDirector] setProjection:CCDirectorProjection3D];
}

-(void) onExit
{
	[[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
	[super onExit];
}

-(id) init
{
	if( ( self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *p = [CCSprite spriteWithFile:@"background3.png"];
		[self addChild:p z:0];
		p.position = ccp(s.width/2, s.height/2);
		p.opacity = 128;
		
		CCSprite *sprite;
		CCOrbitCamera *orbit;
		CCCamera *cam;
		CGSize ss;

		// LEFT
		sprite = [CCSprite spriteWithFile:@"grossini.png"];
		sprite.scale = 0.5f;
		[p addChild:sprite z:0];		
		[sprite setPosition:ccp(s.width/4*1, s.height/2)];
		cam = [sprite camera];
		orbit = [CCOrbitCamera actionWithDuration:2 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
		[sprite runAction: [CCRepeatForever actionWithAction:orbit]];
		
		// CENTER
		sprite = [CCSprite spriteWithFile:@"grossini.png"];
		sprite.scale = 1.0f;
		[p addChild:sprite z:0];		
		[sprite setPosition:ccp(s.width/4*2, s.height/2)];
		orbit = [CCOrbitCamera actionWithDuration:2 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:45 deltaAngleX:0];
		[sprite runAction: [CCRepeatForever actionWithAction:orbit]];
		
		
		// RIGHT
		sprite = [CCSprite spriteWithFile:@"grossini.png"];
		sprite.scale = 2.0f;
		[p addChild:sprite z:0];		
		[sprite setPosition:ccp(s.width/4*3, s.height/2)];
		ss = [sprite contentSize];		
		orbit = [CCOrbitCamera actionWithDuration:2 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:90 deltaAngleX:-45],
		[sprite runAction: [CCRepeatForever actionWithAction:orbit]];
				
		
		// PARENT
		orbit = [CCOrbitCamera actionWithDuration:10 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:90];
		[p runAction: [CCRepeatForever actionWithAction:orbit]];

		
		self.scale = 1;
	}
	
	return self;
}

-(NSString *) title
{
	return @"Camera Orbit test";
}
@end

#pragma mark -
#pragma mark CameraZoomTest



@implementation CameraZoomTest
-(void) onEnter
{
	[super onEnter];
	[[CCDirector sharedDirector] setProjection:CCDirectorProjection3D];
}

-(void) onExit
{
	[[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
	[super onExit];
}

-(id) init
{
	if( ( self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		
		CCSprite *sprite;
		CCCamera *cam;
		
		// LEFT
		sprite = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:sprite z:0];		
		[sprite setPosition:ccp(s.width/4*1, s.height/2)];
		cam = [sprite camera];
		[cam setEyeX:0 eyeY:0 eyeZ:415];
		
		// CENTER
		sprite = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:sprite z:0 tag:40];
		[sprite setPosition:ccp(s.width/4*2, s.height/2)];
//		cam = [sprite camera];
//		[cam setEyeX:0 eyeY:0 eyeZ:415/2];
		
		// RIGHT
		sprite = [CCSprite spriteWithFile:@"grossini.png"];
		[self addChild:sprite z:0 tag:20];
		[sprite setPosition:ccp(s.width/4*3, s.height/2)];
//		cam = [sprite camera];
//		[cam setEyeX:0 eyeY:0 eyeZ:-485];
//		[cam setCenterX:0 centerY:0 centerZ:0];
	

		[self schedule:@selector(updateEye:)];
	}
	
	return self;
}

-(void) updateEye:(ccTime)dt
{
	static float z = 0;

	CCNode *sprite;
	CCCamera *cam;
	
	z += dt * 100;
	
	sprite = [self getChildByTag:20];
	cam = [sprite camera];
	[cam setEyeX:0 eyeY:0 eyeZ:z];
	
	sprite = [self getChildByTag:40];
	cam = [sprite camera];
	[cam setEyeX:0 eyeY:0 eyeZ:z];	
}

-(NSString *) title
{
	return @"Camera Zoom test";
}
@end


#pragma mark -
#pragma mark TimerScaleTest

@interface TimeScaleSprite : CCSprite {
	
	BOOL flip;
	
}


@end

@implementation TimeScaleSprite 

-(id)initTSS {
	self = [super initWithFile:@"grossini.png"];
	flip = NO;
	[self schedule:@selector(updateTSSprite:) interval:1];
	return self;
}

-(void) updateTSSprite:(ccTime)dt {
	self.position = ccp(self.position.x,(flip) ? 100 : 200);
	flip = !flip;
}


@end

@implementation TimerScaleTest

-(id) init
{
	if( ( self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		
		CCLabel* l = [CCLabel labelWithString:@"Right is double speed of left" fontName:@"Thonburi" fontSize:16];
		[self addChild:l];
		[l setPosition:ccp(s.width/2, 245)];
		
		CCSprite *sprite;
		
		// LEFT
		sprite = [[TimeScaleSprite alloc] initTSS];
		[self addChild:sprite z:0 tag:10];		
		[sprite setPosition:ccp(s.width/4*1, s.height/2)];
		[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:4 angle:360]]];
		
		// RIGHT
		sprite = [[TimeScaleSprite alloc] initTSS];
		[self addChild:sprite z:0 tag:20];
		[sprite setPosition:ccp(s.width/4*3, s.height/2)];
		[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:4 angle:360]]];

		[sprite scaleAllTimers:2.0f withChildren:NO];
		
		[self schedule:@selector(switchToHalfSpeed:) interval:5.0f repeat:1];
		
	}
	
	return self;
}


-(void) switchToHalfSpeed:(ccTime) dt {
	CCSprite* sprite = (CCSprite*)[self getChildByTag:10];	
	[sprite scaleAllTimers:0.25f];
	sprite = (CCSprite*)[self getChildByTag:20];	
	[sprite scaleAllTimers:0.5f];
	
	CCLabel* l = [CCLabel labelWithString:@"Slower than Normal" fontName:@"Thonburi" fontSize:16];
	[self addChild:l];
	[l setPosition:ccp(480/2, 230)];	
	
}




-(NSString *) title
{
	return @"Timer Scale Test";
}
@end


@implementation TimerScaleWithChildrenTest

-(id) init
{
	if( ( self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		
		CCSprite *sp1 = [CCSprite spriteWithFile:@"grossinis_sister1.png"];
		[sp1 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:4 angle:360]]];		
		CCSprite *sp2 = [CCSprite spriteWithFile:@"grossinis_sister2.png"];		
		[sp2 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:4 angle:360]]];
		
		CCLabel* l = [CCLabel labelWithString:@"Left sister is not time scales, right sister is" fontName:@"Thonburi" fontSize:16];
		[self addChild:l];
		[l setPosition:ccp(s.width/2, 245)];
		
		CCSprite *sprite;
		
		// LEFT
		sprite = [[TimeScaleSprite alloc] initTSS];
		[self addChild:sprite z:0];		
		[sprite setPosition:ccp(s.width/4*1, s.height/2)];
		[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:4 angle:360]]];
		[sprite addChild:sp1];
		[sp1 setPosition:ccp(0,0)];
		[sp1 setScale:0.5f];
		
		[sprite scaleAllTimers:0.5f withChildren:NO];
		
		
		// RIGHT
		sprite = [[TimeScaleSprite alloc] initTSS];
		[self addChild:sprite z:0 tag:20];
		[sprite setPosition:ccp(s.width/4*3, s.height/2)];
		[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:4 angle:360]]];
		[sprite addChild:sp2];
		[sp2 setPosition:ccp(0,0)];
		[sp2 setScale:0.5f];
		
		[sprite scaleAllTimers:0.5f withChildren:YES];
		
	}
	
	return self;
}




-(NSString *) title
{
	return @"Timer Scale w/Children Test";
}
@end




#pragma mark -
#pragma mark PerFrameUpdateTest

@interface PFSprite : CCSprite {
	
	int c;
	int totalFrames;
	PFSprite* slave;
}

@property (readonly) int totalFrames;

@end

@implementation PFSprite 
@synthesize totalFrames;

-(id)initWithUpdatePriority:(NSInteger) aPriority File:(NSString*)aFile Slave:(PFSprite*) anotehrSprite {
	self = [super initWithFile:aFile];
	c = 0;
	totalFrames = 0;
	slave = anotehrSprite;
	[self scheduleForPerFrameUpdatesWithPriority:aPriority];
	return self;
}

-(void) perFrameUpdate:(ccTime)dt {
	++totalFrames;
	if(slave == nil) {
		c = ++c % (200*8);
		self.position = ccp(self.position.x,50+(c/8));
	}
	else {
		if(slave.totalFrames == totalFrames)
			self.position = slave.position;
		else {
			self.position = ccp(slave.position.x,320-slave.position.y);
		}

	}
}


@end

@implementation PerFrameUpdateTest

-(id) init
{
	if( ( self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		
		//		CCLabel* l = [CCLabel labelWithString:@"Right is double speed of left" fontName:@"Thonburi" fontSize:16];
		//		[self addChild:l];
		//		[l setPosition:ccp(s.width/2, 245)];
		
		PFSprite *sprite;
		PFSprite* slave;
		
		// LEFT
		sprite = [[PFSprite alloc] initWithUpdatePriority:0 File:@"grossini.png" Slave:nil];
		[self addChild:sprite z:0 tag:10];		
		[sprite setPosition:ccp(s.width/4*1, s.height/2)];
		[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:4 angle:360]]];

		slave = [[PFSprite alloc] initWithUpdatePriority:0 File:@"grossinis_sister1.png" Slave:sprite];
		[self addChild:slave z:0 tag:15];
		
		// RIGHT
		sprite = [[PFSprite alloc] initWithUpdatePriority:0 File:@"grossini.png" Slave:nil];
		[self addChild:sprite z:0 tag:20];
		[sprite setPosition:ccp(s.width/4*3, s.height/2)];
		[sprite runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:4 angle:360]]];
		
		[sprite scaleAllTimers:2.0f];
		
		slave = [[PFSprite alloc] initWithUpdatePriority:10 File:@"grossinis_sister1.png" Slave:sprite];
		[self addChild:slave z:0 tag:30];		
		
		[self schedule:@selector(removeOne:) interval:5.0f repeat:1];		
	}
	
	return self;
}


-(void) removeOne:(ccTime) dt {
	// Should not crash
	[self removeChildByTag:20 cleanup:YES];
	[self removeChildByTag:30 cleanup:YES];
	CCLabel* l = [CCLabel labelWithString:@"Removed Sprite / canceled updates for 1 other" fontName:@"Thonburi" fontSize:16];
	[self addChild:l];
	[l setPosition:ccp(480/2, 230)];
	
	CCSprite* sprite = (CCSprite*)[self getChildByTag:15];	
	[sprite cancelPerFrameUpdates];
		
}




-(NSString *) title
{
	return @"Per Frame Update Test";
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
	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:CCDirectorTypeMainLoop];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	// before creating any layer, set the landscape mode
	[director setDeviceOrientation: CCDeviceOrientationLandscapeLeft];
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];

	// Create a depth buffer of 16 bits
	// Needed for the orbit + lens + waves examples
	// These means that openGL z-order will be taken into account
//	[director setDepthBufferFormat:kDepthBuffer16];
//	[director setPixelFormat:kPixelFormatRGBA8888];
	
	// create an openGL view inside a window
	[director attachInView:window];	
	[window makeKeyAndVisible];		
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
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

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
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
