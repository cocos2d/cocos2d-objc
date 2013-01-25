//
// CCNode tests
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "NodeTest.h"


enum {
	kTagSprite1 = 1,
	kTagSprite2 = 2,
	kTagSprite3 = 3,
	kTagSlider,
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

static int sceneIdx=-1;
static NSString *transitions[] = {

	@"Test2",
	@"Test4",
	@"Test5",
	@"Test6",
	@"StressTest1",
	@"StressTest2",
	@"NodeToWorld",
	@"SchedulerTest1",
	@"CameraOrbitTest",
	@"CameraZoomTest",
	@"CameraCenterTest",
	@"ConvertToNode",
	@"CCArrayTest",
	@"NodeOpaqueTest",
	@"NodeNonOpaqueTest",
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

		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:10];
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
		[self addChild: menu z:11];
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

-(NSString*) subtitle
{
	return nil;
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
	[self.parent removeChild:node cleanup:YES];
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
		NSLog(@"retain count after init is %lu", (long)[layer retainCount]);                // 1

		[self addChild:layer z:0];
		NSLog(@"retain count after addChild is %lu", (long)[layer retainCount]);      // 2

		[layer schedule:@selector(doSomething:)];
		NSLog(@"retain count after schedule is %lu", (long)[layer retainCount]);      // 3

		[layer unschedule:@selector(doSomething:)];
		NSLog(@"retain count after unschedule is %lu", (long)[layer retainCount]);		// STILL 3!
	}

	return self;
}

-(NSString *) title
{
	return @"cocosnode scheduler test #1";
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

		CCMenuItem *item = [CCMenuItemImage itemWithNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png"];
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
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
}

-(void) onExit
{
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
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

		s = [p contentSize];
		// LEFT
		sprite = [CCSprite spriteWithFile:@"grossini.png"];
		sprite.scale = 0.5f;
		[p addChild:sprite z:0];
		[sprite setPosition:ccp(s.width/4*1, s.height/2)];
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
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
}

-(void) onExit
{
	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
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
		[cam setEyeX:0 eyeY:0 eyeZ:415/2];
		[cam setCenterX:0 centerY:0 centerZ:0];

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


		z_=0;

		[self scheduleUpdate];
	}

	return self;
}

-(void) update:(ccTime)dt
{
	CCNode *sprite;
	CCCamera *cam;

	z_ += dt * 100;

	sprite = [self getChildByTag:20];
	cam = [sprite camera];
	[cam setEyeX:0 eyeY:0 eyeZ:z_];

	sprite = [self getChildByTag:40];
	cam = [sprite camera];
	[cam setEyeX:0 eyeY:0 eyeZ:-z_];
}

-(NSString *) title
{
	return @"Camera Zoom test";
}
@end

#pragma mark -
#pragma mark CameraCenterTest

@implementation CameraCenterTest
//-(void) onEnter
//{
//	[super onEnter];
//	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
//}
//
//-(void) onExit
//{
//	[[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
//	[super onExit];
//}

-(id) init
{
	if( ( self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

		CCSprite *sprite;
		CCOrbitCamera *orbit;

		// LEFT-TOP
		sprite = [CCSprite spriteWithFile:@"white-512x512.png"];
		[self addChild:sprite z:0];
		[sprite setPosition:ccp(s.width/5*1, s.height/5*1)];
		[sprite setColor:ccRED];
		[sprite setTextureRect:CGRectMake(0, 0, 120, 50)];
		orbit = [CCOrbitCamera actionWithDuration:10 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
		[sprite runAction: [CCRepeatForever actionWithAction:orbit]];
//		[sprite setAnchorPoint: ccp(0,1)];



		// LEFT-BOTTOM
		sprite = [CCSprite spriteWithFile:@"white-512x512.png"];
		[self addChild:sprite z:0 tag:40];
		[sprite setPosition:ccp(s.width/5*1, s.height/5*4)];
		[sprite setColor:ccBLUE];
		[sprite setTextureRect:CGRectMake(0, 0, 120, 50)];
		orbit = [CCOrbitCamera actionWithDuration:10 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
		[sprite runAction: [CCRepeatForever actionWithAction:orbit]];
//		[sprite setAnchorPoint: ccp(0,0)];


		// RIGHT-TOP
		sprite = [CCSprite spriteWithFile:@"white-512x512.png"];
		[self addChild:sprite z:0];
		[sprite setPosition:ccp(s.width/5*4, s.height/5*1)];
		[sprite setColor:ccYELLOW];
		[sprite setTextureRect:CGRectMake(0, 0, 120, 50)];
		orbit = [CCOrbitCamera actionWithDuration:10 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
		[sprite runAction: [CCRepeatForever actionWithAction:orbit]];
//		[sprite setAnchorPoint: ccp(1,1)];


		// RIGHT-BOTTOM
		sprite = [CCSprite spriteWithFile:@"white-512x512.png"];
		[self addChild:sprite z:0 tag:40];
		[sprite setPosition:ccp(s.width/5*4, s.height/5*4)];
		[sprite setColor:ccGREEN];
		[sprite setTextureRect:CGRectMake(0, 0, 120, 50)];
		orbit = [CCOrbitCamera actionWithDuration:10 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
		[sprite runAction: [CCRepeatForever actionWithAction:orbit]];
//		[sprite setAnchorPoint: ccp(1,0)];

		// CENTER
		sprite = [CCSprite spriteWithFile:@"white-512x512.png"];
		[self addChild:sprite z:0 tag:40];
		[sprite setPosition:ccp(s.width/2, s.height/2)];
		[sprite setColor:ccWHITE];
		[sprite setTextureRect:CGRectMake(0, 0, 120, 50)];
		orbit = [CCOrbitCamera actionWithDuration:10 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:360 angleX:0 deltaAngleX:0];
		[sprite runAction: [CCRepeatForever actionWithAction:orbit]];
//		[sprite setAnchorPoint: ccp(0.5f, 0.5f)];

	}

	return self;
}

-(NSString *) title
{
	return @"Camera Center test";
}

-(NSString*) subtitle
{
	return @"Sprites should rotate at the same speed";
}
@end


#pragma mark -
#pragma mark ConvertToNode

@implementation ConvertToNode

-(id) init
{
	if( ( self=[super init]) ) {

#if defined(__CC_PLATFORM_IOS)
		self.touchEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif
		
		CGSize s = [[CCDirector sharedDirector] winSize];

		id rotate = [CCRotateBy actionWithDuration:10 angle:360];
		id action = [CCRepeatForever actionWithAction:rotate];
		for(int i=0;i<3;i++) {
			CCSprite *sprite = [CCSprite spriteWithFile:@"grossini.png"];
			sprite.position = ccp( s.width/4*(i+1), s.height/2);

			CCSprite *point = [CCSprite spriteWithFile:@"r1.png"];
			point.scale = 0.25f;
			point.position = sprite.position;
			[self addChild:point z:10 tag:100+i];

			switch(i) {
				case 0:
					sprite.anchorPoint = CGPointZero;
					break;
				case 1:
					sprite.anchorPoint = ccp(0.5f, 0.5f);
					break;
				case 2:
					sprite.anchorPoint = ccp(1,1);
					break;
			}

			point.position = sprite.position;

			id copy = [[action copy] autorelease];
			[sprite runAction:copy];
			[self addChild:sprite z:i];
		}
	}

	return self;
}

#if defined(__CC_PLATFORM_IOS)
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];

		location = [[CCDirector sharedDirector] convertToGL: location];

		for( int i=0; i<3; i++) {
			CCNode *node = [self getChildByTag:100+i];

			CGPoint p1, p2;

			p1 = [node convertToNodeSpaceAR:location];
			p2 = [node convertToNodeSpace:location];

			NSLog(@"AR: x=%.2f, y=%.2f -- Not AR: x=%.2f, y=%.2f", p1.x, p1.y, p2.x, p2.y);
		}
	}
}
#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGPoint	location = [[CCDirector sharedDirector] convertEventToGL:event];
		
	for( int i=0; i<3; i++) {
		CCNode *node = [self getChildByTag:100+i];
		
		CGPoint p1, p2;
		
		p1 = [node convertToNodeSpaceAR:location];
		p2 = [node convertToNodeSpace:location];
		
		NSLog(@"AR: x=%.2f, y=%.2f -- Not AR: x=%.2f, y=%.2f", p1.x, p1.y, p2.x, p2.y);
	}
	return YES;
}
#endif

-(NSString *) title
{
	return @"Convert To Node Space";
}

-(NSString*) subtitle
{
	return @"testing convertToNodeSpace / AR. Touch and see console";
}
@end

#pragma mark -
#pragma mark CCArrayTest

@implementation CCArrayTest

-(id) init
{
	if( ( self=[super init]) ) {

		NSLog(@"\nTest 1\n");

		NSArray *nsarray = [NSArray arrayWithObjects:@"one", @"two", @"three", nil];
		CCArray *ccarray = [CCArray arrayWithNSArray:nsarray];

		NSLog(@"%@ == %@", nsarray, ccarray);


		NSLog(@"\nTest 2\n");

		CCArray *copy_ccaray = [ccarray copy];
		NSLog(@"copy: %@", copy_ccaray);

		NSLog(@"\nTest 3\n");

		[copy_ccaray addObjectsFromNSArray:nsarray];
		NSLog(@"copy 2: %@", copy_ccaray);


		NSLog(@"\nTest 4\n");

		for( int i=0; i<6;i++)
			NSLog(@"random object: %@", [copy_ccaray randomObject] );


		[copy_ccaray release];


	}
	return self;
}

-(NSString *) title
{
	return @"CCArray Test";
}

-(NSString*) subtitle
{
	return @"See console for possible errors";
}
@end


#pragma mark -
#pragma mark NodeOpaqueTest

@implementation NodeOpaqueTest

-(id) init
{
	if( ( self=[super init]) ) {
		CCSprite *background = nil;

		for( int i=0; i<50; i++) {
			background = [CCSprite spriteWithFile:@"background1.jpg"];
			[background setBlendFunc: kCCBlendFuncDisable];
			[background setAnchorPoint:CGPointZero];
			[self addChild:background];
		}
	}
	return self;
}

-(NSString *) title
{
	return @"Node Opaque Test";
}

-(NSString*) subtitle
{
	return @"Node rendered with GL_BLEND disabled";
}
@end

#pragma mark -
#pragma mark NodeNonOpaqueTest

@implementation NodeNonOpaqueTest

-(id) init
{
	if( ( self=[super init]) ) {
		CCSprite *background = nil;

		for( int i=0; i<50; i++) {
			background = [CCSprite spriteWithFile:@"background1.jpg"];
			[background setBlendFunc: (ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
			[background setAnchorPoint:CGPointZero];
			[self addChild:background];
		}
	}
	return self;
}

-(NSString *) title
{
	return @"Node Non Opaque Test";
}

-(NSString*) subtitle
{
	return @"Node rendered with GL_BLEND enabled";
}
@end


#pragma mark -
#pragma mark AppController

#if defined(__CC_PLATFORM_IOS)

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Set multiple touches on
	UIView *glView = [director_ view];
	[glView setMultipleTouchEnabled:YES];

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
		[scene addChild: [nextAction() node]];
		[director runWithScene: scene];
	}
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

