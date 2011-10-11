//
// Actions Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "cocos2d.h"
#import "ActionsTest.h"

enum {
	kTagAnimationDance = 1,
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

static int sceneIdx=-1;
static NSString *transitions[] = {
	@"ActionManual",
	@"ActionMove",
	@"ActionRotate",
	@"ActionScale",
	@"ActionSkew",
	@"ActionSkewRotateScale",
	@"ActionJump",
	@"ActionBezier",
	@"ActionBlink",
	@"ActionFade",
	@"ActionTint",
	@"ActionAnimate",
	@"ActionSequence",
	@"ActionSequence2",
	@"ActionSpawn",
	@"ActionReverse",
	@"ActionDelayTime",
	@"ActionRepeat",
	@"ActionRepeatForever",
	@"ActionRotateToRepeat",
	@"ActionRotateJerk",
	@"ActionCallFunc",
	@"ActionCallFuncND",
	@"ActionCallBlock",
	@"ActionReverseSequence",
	@"ActionReverseSequence2",
	@"ActionOrbit",
	@"ActionFollow",
	@"ActionProperty",
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





@implementation ActionDemo
-(id) init
{
	if( (self=[super init])) {
	
		grossini = [[CCSprite alloc] initWithFile:@"grossini.png"];
		tamara = [[CCSprite alloc] initWithFile:@"grossinis_sister1.png"];
		kathia = [[CCSprite alloc] initWithFile:@"grossinis_sister2.png"];
		
		[self addChild:grossini z:1];
		[self addChild:tamara z:2];
		[self addChild:kathia z:3];

		CGSize s = [[CCDirector sharedDirector] winSize];
		
		[grossini setPosition: ccp(s.width/2, s.height/3)];
		[tamara setPosition: ccp(s.width/2, 2*s.height/3)];
		[kathia setPosition: ccp(s.width/2, s.height/2)];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF* l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
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


-(void) alignSpritesLeft:(unsigned int)numberOfSprites
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	if( numberOfSprites == 1 ) {
		tamara.visible = NO;
		kathia.visible = NO;
		[grossini setPosition:ccp(60, s.height/2)];
	} else if( numberOfSprites == 2 ) {		
		[kathia setPosition: ccp(60, s.height/3)];
		[tamara setPosition: ccp(60, 2*s.height/3)];
		grossini.visible = NO;
	} else if( numberOfSprites == 3 ) {
		[grossini setPosition: ccp(60, s.height/2)];
		[tamara setPosition: ccp(60, 2*s.height/3)];
		[kathia setPosition: ccp(60, s.height/3)];
	}
	else {
		CCLOG(@"ActionsTests: Invalid number of Sprites");
	}	
}

-(void) centerSprites:(unsigned int)numberOfSprites
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	if( numberOfSprites == 1 ) {
		tamara.visible = NO;
		kathia.visible = NO;
		[grossini setPosition:ccp(s.width/2, s.height/2)];
	} else if( numberOfSprites == 2 ) {		
		[kathia setPosition: ccp(s.width/3, s.height/2)];
		[tamara setPosition: ccp(2*s.width/3, s.height/2)];
		grossini.visible = NO;
	} else if( numberOfSprites == 3 ) {
		[grossini setPosition: ccp(s.width/2, s.height/2)];
		[tamara setPosition: ccp(2*s.width/3, s.height/2)];
		[kathia setPosition: ccp(s.width/3, s.height/2)];
	}
	else {
		CCLOG(@"ActionsTests: Invalid number of Sprites");
	}
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


@implementation ActionManual
-(void) onEnter
{
	[super onEnter];

	
	CGSize s = [CCDirector sharedDirector].winSize;

	tamara.scaleX = 2.5f;
	tamara.scaleY = -1.0f;
	tamara.position = ccp(100,70);
	tamara.opacity = 128;
	
	grossini.rotation = 120;
	grossini.position = ccp(s.width/2, s.height/2);
	grossini.color = ccc3( 255,0,0);
	
	
	kathia.position = ccp(s.width-100, s.height/2);
	kathia.color = ccBLUE;
}

-(NSString *) title
{
	return @"Manual Transformation";
}
@end


@implementation ActionMove
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:3];

	CGSize s = [[CCDirector sharedDirector] winSize];

	
	id actionTo = [CCMoveTo actionWithDuration: 2 position:ccp(s.width-40, s.height-40)];
	
	id actionBy = [CCMoveBy actionWithDuration:2  position: ccp(80,80)];
	id actionByBack = [actionBy reverse];
	
	[tamara runAction: actionTo];
	[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];
	[kathia runAction:[ CCMoveTo actionWithDuration:1 position:ccp(40,40)]];
}
-(NSString *) title
{
	return @"MoveTo / MoveBy";
}
@end

@implementation ActionRotate
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:3];
		
	id actionTo = [CCRotateTo actionWithDuration: 2 angle:45];
	id actionTo2 = [CCRotateTo actionWithDuration: 2 angle:-45];
	id actionTo0 = [CCRotateTo actionWithDuration:2  angle:0];
	[tamara runAction: [CCSequence actions:actionTo, actionTo0, nil]];

	id actionBy = [CCRotateBy actionWithDuration:2  angle: 360];
	id actionByBack = [actionBy reverse];
	[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];

	[kathia runAction: [CCSequence actions:actionTo2, [[actionTo0 copy] autorelease], nil]];
	
}
-(NSString *) title
{
	return @"RotateTo / RotateBy";
}

@end

@implementation ActionScale
-(void) onEnter
{
	[super onEnter];

	[self centerSprites:3];
	
	id actionTo = [CCScaleTo actionWithDuration: 2 scale:0.5f];
	id actionBy = [CCScaleBy actionWithDuration:2  scale: 2];
	id actionBy2 = [CCScaleBy actionWithDuration:2 scaleX:0.25f scaleY:4.5f];
	id actionByBack = [actionBy reverse];

	[tamara runAction: actionTo];
	[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];
	
	[kathia runAction: [CCSequence actions:actionBy2, [actionBy2 reverse], nil]];
	
}
-(NSString *) title
{
	return @"ScaleTo / ScaleBy";
}

@end

@implementation ActionSkew
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:3];
	
	id actionTo = [CCSkewTo actionWithDuration:2 skewX:37.2f skewY:-37.2f];
	id actionToBack = [CCSkewTo actionWithDuration:2 skewX:0 skewY:0];
	id actionBy = [CCSkewBy actionWithDuration:2 skewX:0.0f skewY:-90.0f];
	id actionBy2 = [CCSkewBy actionWithDuration:2 skewX:45.0f skewY:45.0f];
	id actionByBack = [actionBy reverse];
			
	[tamara runAction:[CCSequence actions:actionTo, actionToBack, nil]];
	[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];
	
	[kathia runAction: [CCSequence actions:actionBy2, [actionBy2 reverse], nil]];	
}
-(NSString *) title
{
	return @"SkewTo / SkewBy";
}

@end

@implementation ActionSkewRotateScale
-(void) onEnter
{
	[super onEnter];
	
	[tamara removeFromParentAndCleanup:YES];
	[grossini removeFromParentAndCleanup:YES];
	[kathia removeFromParentAndCleanup:YES];
	
	CGSize boxSize = CGSizeMake(100.0f, 100.0f);
	
	CCLayerColor *box = [CCLayerColor layerWithColor:ccc4(255,255,0,255)];
	box.anchorPoint = ccp(0,0);
	box.position = ccp(190,110);
	box.contentSize = boxSize;
	
	static CGFloat markerside = 10.0f;
	CCLayerColor *uL = [CCLayerColor layerWithColor:ccc4(255,0,0,255)];
	[box addChild:uL];
	uL.contentSize = CGSizeMake(markerside, markerside);
	uL.position = ccp(0.f, boxSize.height-markerside);
	uL.anchorPoint = ccp(0,0);
	
	CCLayerColor *uR = [CCLayerColor layerWithColor:ccc4(0,0,255,255)];
	[box addChild:uR];
	uR.contentSize = CGSizeMake(markerside, markerside);
	uR.position = ccp(boxSize.width-markerside, boxSize.height-markerside);
	uR.anchorPoint = ccp(0,0);	
	[self addChild:box];
	
	id actionTo = [CCSkewTo actionWithDuration:2 skewX:0.f skewY:2.f];
	id rotateTo = [CCRotateTo actionWithDuration:2 angle:61.0f];
	id actionScaleTo = [CCScaleTo actionWithDuration:2 scaleX:-0.44f scaleY:0.47f];
	
	id actionScaleToBack = [CCScaleTo actionWithDuration:2 scaleX:1.0f scaleY:1.0f];
	id rotateToBack = [CCRotateTo actionWithDuration:2 angle:0];
	id actionToBack = [CCSkewTo actionWithDuration:2 skewX:0 skewY:0];
	
	[box runAction:[CCSequence actions:actionTo, actionToBack, nil]];
	[box runAction:[CCSequence actions:rotateTo, rotateToBack, nil]];
	[box runAction:[CCSequence actions:actionScaleTo, actionScaleToBack, nil]];
}
-(NSString *) title
{
	return @"Skew + Rotate + Scale";
}

@end


@implementation ActionJump
-(void) onEnter
{
	[super onEnter];
			
	id actionTo = [CCJumpTo actionWithDuration:2 position:ccp(300,300) height:50 jumps:4];
	id actionBy = [CCJumpBy actionWithDuration:2 position:ccp(300,0) height:50 jumps:4];
	id actionUp = [CCJumpBy actionWithDuration:2 position:ccp(0,0) height:80 jumps:4];
	id actionByBack = [actionBy reverse];
	
	[tamara runAction: actionTo];
	[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];
	[kathia runAction: [CCRepeatForever actionWithAction:actionUp]];
}
-(NSString *) title
{
	return @"JumpTo / JumpBy";
}
@end

@implementation ActionBezier
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	//
	// startPosition can be any coordinate, but since the movement
	// is relative to the Bezier curve, make it (0,0)
	//
	
	// sprite 1
	ccBezierConfig bezier;
	bezier.controlPoint_1 = ccp(0, s.height/2);
	bezier.controlPoint_2 = ccp(300, -s.height/2);
	bezier.endPosition = ccp(300,100);
	
	id bezierForward = [CCBezierBy actionWithDuration:3 bezier:bezier];
	id bezierBack = [bezierForward reverse];	
	id seq = [CCSequence actions: bezierForward, bezierBack, nil];
	id rep = [CCRepeatForever actionWithAction:seq];
	

	// sprite 2
	[tamara setPosition:ccp(80,160)];
	ccBezierConfig bezier2;
	bezier2.controlPoint_1 = ccp(100, s.height/2);
	bezier2.controlPoint_2 = ccp(200, -s.height/2);
	bezier2.endPosition = ccp(240,160);
	
	id bezierTo1 = [CCBezierTo actionWithDuration:2 bezier:bezier2];	
	
	// sprite 3
	[kathia setPosition:ccp(400,160)];
	id bezierTo2 = [CCBezierTo actionWithDuration:2 bezier:bezier2];
	
	[grossini runAction: rep];
	[tamara runAction:bezierTo1];
	[kathia runAction:bezierTo2];

}
-(NSString *) title
{
	return @"BezierBy / BezierTo";
}
@end


@implementation ActionBlink
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:3];
	
	id action1 = [CCBlink actionWithDuration:3 blinks:10];
	id action2 = [CCBlink actionWithDuration:3 blinks:5];
	id action3 = [CCBlink actionWithDuration:0.5f blinks:5];
	
	[tamara runAction: action1];
	[kathia runAction:action2];
	[grossini runAction:action3];
}
-(NSString *) title
{
	return @"Blink";
}
@end

@implementation ActionFade
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:2];
	
	tamara.opacity = 0;
	id action1 = [CCFadeIn actionWithDuration:1.0f];
	id action1Back = [action1 reverse];
	
	id action2 = [CCFadeOut actionWithDuration:1.0f];
	id action2Back = [action2 reverse];
	
	[tamara runAction: [CCSequence actions: action1, action1Back, nil]];
	[kathia runAction: [CCSequence actions: action2, action2Back, nil]];
}
-(NSString *) title
{
	return @"FadeIn / FadeOut";
}
@end

@implementation ActionTint
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:2];
	
	id action1 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:255];
	id action2 = [CCTintBy actionWithDuration:2 red:-127 green:-255 blue:-127];
	id action2Back = [action2 reverse];
	
	[tamara runAction: action1];
	[kathia runAction: [CCSequence actions: action2, action2Back, nil]];
}
-(NSString *) title
{
	return @"TintTo / TintBy";
}
@end

@implementation ActionAnimate
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:1];
	
	CCAnimation* animation = [CCAnimation animation];
	for( int i=1;i<15;i++)
		[animation addFrameWithFilename: [NSString stringWithFormat:@"grossini_dance_%02d.png", i]];
	
	id action = [CCAnimate actionWithDuration:3 animation:animation restoreOriginalFrame:NO];
	id action_back = [action reverse];
	
	[grossini runAction: [CCSequence actions: action, action_back, nil]];
}
-(NSString *) title
{
	return @"Animation";
}
@end


@implementation ActionSequence
-(void) onEnter
{
	[super onEnter];
	
	[self alignSpritesLeft:1];

	id action = [CCSequence actions:
				 [CCMoveBy actionWithDuration: 2 position:ccp(240,0)],
				 [CCRotateBy actionWithDuration: 2 angle: 540],
				 nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"Sequence: Move + Rotate";
}
@end

@implementation ActionSequence2
-(void) onEnter
{
	[super onEnter];
	
	[self alignSpritesLeft:1];

	[grossini setVisible:NO];
	
	id action = [CCSequence actions:
				 [CCPlace actionWithPosition:ccp(200,200)],
				 [CCShow action],
				 [CCMoveBy actionWithDuration:1 position:ccp(100,0)],
				 [CCCallFunc actionWithTarget:self selector:@selector(callback1)],
				 [CCCallFuncN actionWithTarget:self selector:@selector(callback2:)],
				 [CCCallFuncND actionWithTarget:self selector:@selector(callback3:data:) data:(void*)0xbebabeba],
				 nil];
	
	[grossini runAction:action];
}

-(void) callback1
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"callback 1 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*1,s.height/2)];
	
	[self addChild:label];
}

-(void) callback2:(id)sender
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"callback 2 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*2,s.height/2)];
	
	[self addChild:label];
}

-(void) callback3:(id)sender data:(void*)data
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"callback 3 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*3,s.height/2)];
	
	[self addChild:label];
}


-(NSString *) title
{
	return @"Sequence of InstantActions";
}
@end

@implementation ActionSpawn
-(void) onEnter
{
	[super onEnter];
	
	[self alignSpritesLeft:1];

	
	id action = [CCSpawn actions:
				 [CCJumpBy actionWithDuration:2 position:ccp(300,0) height:50 jumps:4],
				 [CCRotateBy actionWithDuration: 2 angle: 720],
				 nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"Spawn: Jump + Rotate";
}
@end

@implementation ActionRepeatForever
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:1];
	
	id action = [CCSequence actions:
				 [CCDelayTime actionWithDuration:1],
				 [CCCallFuncN actionWithTarget:self selector:@selector(repeatForever:)],
				 nil];
	
	[grossini runAction:action];
}

-(void) repeatForever:(id)sender
{
	CCRepeatForever *repeat = [CCRepeatForever actionWithAction: [CCRotateBy actionWithDuration:1.0f angle:360]];
//	id repeat = [CCRepeat actionWithAction: [CCRotateBy actionWithDuration:1.0f angle:360] times:10];

	[sender runAction:repeat];
}

-(NSString *) title
{
	return @"CallFuncN + RepeatForever";
}
@end

@implementation ActionRotateToRepeat
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:2];
	
	id act1 = [CCRotateTo actionWithDuration:1 angle:90];
	id act2 = [CCRotateTo actionWithDuration:1 angle:0];
	id seq = [CCSequence actions:act1, act2, nil];
	id rep1 = [CCRepeatForever actionWithAction:seq];
	id rep2 = [CCRepeat actionWithAction:[[seq copy] autorelease] times:10];
	
	[tamara runAction:rep1];
	[kathia runAction:rep2];

}

-(NSString *) title
{
	return @"Repeat/RepeatForever + RotateTo";
}
-(NSString *) subtitle
{
	return @"You should see smooth movements (no jerks). issue #390";
}

@end

@implementation ActionRotateJerk
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:2];
	
	id seq = [CCSequence actions:
				  [CCRotateTo actionWithDuration:0.5f angle:-20],
				  [CCRotateTo actionWithDuration:0.5f angle:20],
			  nil];
	
	id rep1 = [CCRepeat actionWithAction:seq times:10];
	id rep2 = [CCRepeatForever actionWithAction: [[seq copy] autorelease] ];
	
	[tamara runAction:rep1];
	[kathia runAction:rep2];
}

-(NSString *) title
{
	return @"RepeatForever / Repeat + Rotate";
}
-(NSString *) subtitle
{
	return @"You should see smooth movements (no jerks). issue #390";
}
@end


@implementation ActionReverse
-(void) onEnter
{
	[super onEnter];
	
	[self alignSpritesLeft:1];
	
	id jump = [CCJumpBy actionWithDuration:2 position:ccp(300,0) height:50 jumps:4];
	id action = [CCSequence actions: jump, [jump reverse], nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"Reverse an action";
}
@end

@implementation ActionDelayTime
-(void) onEnter
{
	[super onEnter];
	
	[self alignSpritesLeft:1];
	
	id move = [CCMoveBy actionWithDuration:1 position:ccp(150,0)];
	id action = [CCSequence actions: move, [CCDelayTime actionWithDuration:2], move, nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"DelayTime: m + delay + m";
}
@end

@implementation ActionReverseSequence
-(void) onEnter
{
	[super onEnter];
	
	[self alignSpritesLeft:1];

	id move1 = [CCMoveBy actionWithDuration:1 position:ccp(250,0)];
	id move2 = [CCMoveBy actionWithDuration:1 position:ccp(0,50)];
	id seq = [CCSequence actions: move1, move2, [move1 reverse], nil];
	id action = [CCSequence actions: seq, [seq reverse], nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"Reverse a sequence";
}
@end

@implementation ActionReverseSequence2
-(void) onEnter
{
	[super onEnter];
	
	[self alignSpritesLeft:2];


	// Test:
	//   Sequence should work both with IntervalAction and InstantActions
	
	id move1 = [CCMoveBy actionWithDuration:1 position:ccp(250,0)];
	id move2 = [CCMoveBy actionWithDuration:1 position:ccp(0,50)];
	id tog1 = [CCToggleVisibility action];
	id tog2 = [CCToggleVisibility action];
	id seq = [CCSequence actions: move1, tog1, move2, tog2, [move1 reverse], nil];
	id action = [CCRepeat actionWithAction:[CCSequence actions: seq, [seq reverse], nil]
								   times:3];
				 

	// Test:
	//   Also test that the reverse of Hide is Show, and vice-versa
	[kathia runAction:action];

	id move_tamara = [CCMoveBy actionWithDuration:1 position:ccp(100,0)];
	id move_tamara2 = [CCMoveBy actionWithDuration:1 position:ccp(50,0)];
	id hide = [CCHide action];
	id seq_tamara = [CCSequence actions: move_tamara, hide, move_tamara2, nil];
	id seq_back = [seq_tamara reverse];
	[tamara runAction: [CCSequence actions: seq_tamara, seq_back, nil]];
}
-(NSString *) title
{
	return @"Reverse sequence 2";
}
@end


@implementation ActionRepeat
-(void) onEnter
{
	[super onEnter];
	
	[self alignSpritesLeft:2];

		
	id a1 = [CCMoveBy actionWithDuration:1 position:ccp(150,0)];
	id action1 = [CCRepeat actionWithAction:
						[CCSequence actions: [CCPlace actionWithPosition:ccp(60,60)], a1, nil]
									times:3];
	id action2 = [CCRepeatForever actionWithAction:
						[CCSequence actions: [[a1 copy] autorelease], [a1 reverse], nil]
					];
	
	[kathia runAction:action1];
	[tamara runAction:action2];
}
-(NSString *) title
{
	return @"Repeat / RepeatForever actions";
}
@end

@implementation ActionCallFunc
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:3];
		
		
	id action = [CCSequence actions:
				 [CCMoveBy actionWithDuration:2 position:ccp(200,0)],
				 [CCCallFunc actionWithTarget:self selector:@selector(callback1)],
				nil];
	
	id action2 = [CCSequence actions:
						[CCScaleBy actionWithDuration:2  scale: 2],
						[CCFadeOut actionWithDuration:2],
						[CCCallFuncN actionWithTarget:self selector:@selector(callback2:)],
						 nil];
	
	id action3 = [CCSequence actions:
				  [CCRotateBy actionWithDuration:3  angle:360],
				  [CCFadeOut actionWithDuration:2],
				  [CCCallFuncND actionWithTarget:self selector:@selector(callback3:data:) data:(void*)0xbebabeba],
				  nil];
	
	[grossini runAction:action];
	[tamara runAction:action2];
	[kathia runAction:action3];
}

-(void) callback1
{
	NSLog(@"callback 1 called");
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"callback 1 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*1,s.height/2)];

	[self addChild:label];
}
-(void) callback2:(id)sender
{
	NSLog(@"callback 2 called from:%@", sender);
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"callback 2 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*2,s.height/2)];

	[self addChild:label];

}
-(void) callback3:(id)sender data:(void*)data
{
	NSLog(@"callback 3 called from:%@ with data:%x",sender,(unsigned int)data);
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"callback 3 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*3,s.height/2)];
	[self addChild:label];
}



-(NSString *) title
{
	return @"Callbacks: CallFunc and friends";
}
@end

@implementation ActionCallFuncND
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:1];
	
	
	id action = [CCSequence actions:
				 [CCMoveBy actionWithDuration:2 position:ccp(200,0)],
				 [CCCallFuncND actionWithTarget:grossini selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
				 nil];
	[grossini runAction:action];
}

-(NSString *) title
{
	return @"CallFuncND + auto remove";
}

-(NSString *) subtitle
{
	return @"CallFuncND + removeFromParentAndCleanup. Grossini dissapears in 2s";
}

@end

@implementation ActionCallBlock
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:1];
	
	id action = [CCSequence actions:
				 [CCMoveBy actionWithDuration:2 position:ccp(200,0)],
				 [CCCallBlockN actionWithBlock:
				  ^(CCNode *node){
					  CCLOG(@"block called");
					  [node removeFromParentAndCleanup:YES];
				  } ],
				  nil ];
	[grossini runAction:action];
}

-(NSString *) title
{
	return @"CallBlock";
}

-(NSString *) subtitle
{
	return @"CallBlockN test. Grossini should dissaper in 2 seconds";
}

@end


@implementation ActionOrbit
-(void) onEnter
{
	[super onEnter];

	[self centerSprites:3];
	
	id orbit1 = [CCOrbitCamera actionWithDuration:2 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:180 angleX:0 deltaAngleX:0];
	id action1 = [CCSequence actions:
					orbit1,
					[orbit1 reverse],
					nil ];

	id orbit2 = [CCOrbitCamera actionWithDuration:2 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:180 angleX:-45 deltaAngleX:0];
	id action2 = [CCSequence actions:
				  orbit2,
				  [orbit2 reverse],
				  nil ];

	id orbit3 = [CCOrbitCamera actionWithDuration:2 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:180 angleX:90 deltaAngleX:0];
	id action3 = [CCSequence actions:
				  orbit3,
				  [orbit3 reverse],
				  nil ];

	[kathia runAction:[CCRepeatForever actionWithAction:action1]];
	[tamara runAction:[CCRepeatForever actionWithAction:action2]];
	[grossini runAction:[CCRepeatForever actionWithAction:action3]];
	
	id move = [CCMoveBy actionWithDuration:3 position:ccp(100,-100)];
	id move_back = [move reverse];
	id seq = [CCSequence actions:move, move_back, nil];
	id rfe = [CCRepeatForever actionWithAction:seq];
	[kathia runAction:rfe];
	[tamara runAction:[[rfe copy] autorelease]];
	[grossini runAction:[[rfe copy] autorelease]];
}


-(NSString *) title
{
	return @"OrbitCamera action";
}
@end

@implementation ActionFollow
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:1];

	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	grossini.position = ccp(-200, winSize.height/2);
	
	id move = [CCMoveBy actionWithDuration:2 position:ccp(winSize.width*3,0)];
	id move_back = [move reverse];
	id seq = [CCSequence actions:move, move_back, nil];
	id rep = [CCRepeatForever actionWithAction:seq];
	
	
	[grossini runAction:rep];
	
	
	[self runAction:[CCFollow actionWithTarget:grossini worldBoundary:CGRectMake(0, 0, (winSize.width*2)-100, winSize.height)]];
}

-(void) draw
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];

	float x = winSize.width*2 - 100;
	float y = winSize.height;
	
	CGPoint vertices[] = { ccp(5,5), ccp(x-5,5), ccp(x-5,y-5), ccp(5,y-5) };
	ccDrawPoly(vertices, 4, YES);

}

-(NSString *) title
{
	return @"Follow action";
}

-(NSString*) subtitle
{
	return @"The sprite should be centered, even though it is being moved";
}

@end

@implementation ActionProperty
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites:3];

	id rot = [CCActionTween actionWithDuration:2 key:@"rotation" from:0 to:-270];
	id rot_back = [rot reverse];
	id rot_seq = [CCSequence actions:rot, rot_back, nil];
	
	id scale = [CCActionTween actionWithDuration:2 key:@"scale" from:1 to:3];
	id scale_back = [scale reverse];
	id scale_seq = [CCSequence actions:scale, scale_back, nil];
	
	id opacity = [CCActionTween actionWithDuration:2 key:@"opacity" from:255 to:0];
	id opacity_back = [opacity reverse];
	id opacity_seq = [CCSequence actions:opacity, opacity_back, nil];
	
	[grossini runAction:rot_seq];
	[tamara runAction:scale_seq];
	[kathia runAction:opacity_seq];
}

-(NSString *) title
{
	return @"ActionTween";
}

-(NSString*) subtitle
{
	return @"Simulates Rotation, Scale and Opacity using a generic action";
}

@end



// CLASS IMPLEMENTATIONS

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#pragma mark AppController - iOS

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

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// sent to background
-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

// sent to foreground
-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
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

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#pragma mark AppController - Mac

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

