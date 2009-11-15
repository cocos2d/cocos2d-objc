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

static int sceneIdx=-1;
static NSString *transitions[] = {
						 @"ActionManual",
						 @"ActionMove",
						 @"ActionRotate",
						 @"ActionScale",
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
						 @"ActionCallFunc",
						 @"ActionReverseSequence",
						 @"ActionReverseSequence2",
						 @"ActionOrbit" };

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
	
		// Example:
		// You can create a sprite using a Texture2D
		CCTexture2D *tex = [ [CCTexture2D alloc] initWithImage: [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"grossini.png" ofType:nil] ] ];
		grossini = [[CCSprite spriteWithTexture:tex] retain];
		[tex release];

		
		// Example:
		// Or you can create an sprite using a filename. PNG, JPEG and BMP files are supported. Probably TIFF too
		tamara = [[CCSprite spriteWithFile:@"grossinis_sister1.png"] retain];
		
		[self addChild: grossini z:1];
		[self addChild: tamara z:2];

		CGSize s = [[CCDirector sharedDirector] winSize];
		
		[grossini setPosition: ccp(60, s.height/3)];
		[tamara setPosition: ccp(60, 2*s.height/3)];
		
		CCLabel* label = [CCLabel labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];

		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
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


-(void) centerSprites
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	[grossini setPosition: ccp(s.width/3, s.height/2)];
	[tamara setPosition: ccp(2*s.width/3, s.height/2)];
}
-(NSString*) title
{
	return @"No title";
}
@end


@implementation ActionManual
-(void) onEnter
{
	[super onEnter];

	
	tamara.scaleX = 2.5f;
	tamara.scaleY = -1.0f;
	tamara.position = ccp(100,70);
	tamara.opacity = 128;
	
	grossini.rotation = 120;
	grossini.opacity = 128;
	grossini.position = ccp(240,160);
	grossini.color = ccc3( 255,0,0);
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
	
	CGSize s = [[CCDirector sharedDirector] winSize];

	
	id actionTo = [CCMoveTo actionWithDuration: 2 position:ccp(s.width-40, s.height-40)];
	
	id actionBy = [CCMoveBy actionWithDuration:2  position: ccp(80,80)];
	id actionByBack = [actionBy reverse];
	
	[tamara runAction: actionTo];
	[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];
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
	
	[self centerSprites];
		
	id actionTo = [CCRotateTo actionWithDuration: 2 angle:45];
	id actionTo2 = [CCRotateTo actionWithDuration: 2 angle:-45];
	id actionTo0 = [CCRotateTo actionWithDuration:2  angle:0];
	[tamara runAction: [CCSequence actions:actionTo, actionTo0, nil]];

	id actionBy = [CCRotateBy actionWithDuration:2  angle: 360];
	id actionByBack = [actionBy reverse];
	[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];

	CCNode *kathia = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	[self addChild:kathia];
	[kathia setPosition:ccp(240,160)];
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

	[self centerSprites];
	
	id actionTo = [CCScaleTo actionWithDuration: 2 scale:0.5f];
	id actionBy = [CCScaleBy actionWithDuration:2  scale: 2];
	id actionBy2 = [CCScaleBy actionWithDuration:2 scaleX:0.25f scaleY:4.5f];
	id actionByBack = [actionBy reverse];

	[tamara runAction: actionTo];
	[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];
	
	CCNode *kathia = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	[self addChild:kathia];
	[kathia setPosition:ccp(240,160)];
	[kathia runAction: [CCSequence actions:actionBy2, [actionBy2 reverse], nil]];
	
}
-(NSString *) title
{
	return @"ScaleTo / ScaleBy";
}

@end

@implementation ActionJump
-(void) onEnter
{
	[super onEnter];
		
	id actionTo = [CCJumpTo actionWithDuration:2 position:ccp(300,300) height:50 jumps:4];
	id actionBy = [CCJumpBy actionWithDuration:2 position:ccp(300,0) height:50 jumps:4];
	id actionByBack = [actionBy reverse];
	
	[tamara runAction: actionTo];
	[grossini runAction: [CCSequence actions:actionBy, actionByBack, nil]];
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
	CCNode *kathia = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	[self addChild:kathia];
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
	
	[self centerSprites];
	
	id action1 = [CCBlink actionWithDuration:2 blinks:10];
	id action2 = [CCBlink actionWithDuration:2 blinks:5];
	
	[tamara runAction: action1];
	[grossini runAction:action2];
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
	
	[self centerSprites];
	
	tamara.opacity = 0;
	id action1 = [CCFadeIn actionWithDuration:1.0f];
	id action1Back = [action1 reverse];
	
	id action2 = [CCFadeOut actionWithDuration:1.0f];
	id action2Back = [action2 reverse];
	
	[tamara runAction: [CCSequence actions: action1, action1Back, nil]];
	[grossini runAction: [CCSequence actions: action2, action2Back, nil]];
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
	
	[self centerSprites];
	
	id action1 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:255];
	id action2 = [CCTintBy actionWithDuration:2 red:-127 green:-255 blue:-127];
	id action2Back = [action2 reverse];
	
	[tamara runAction: action1];
	[grossini runAction: [CCSequence actions: action2, action2Back, nil]];
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
	
	[self centerSprites];
	
	tamara.visible = NO;
	
	CCAnimation* animation = [CCAnimation animationWithName:@"dance" delay:0.2f];
	for( int i=1;i<15;i++)
		[animation addFrameWithFilename: [NSString stringWithFormat:@"grossini_dance_%02d.png", i]];
	
	id action = [CCAnimate actionWithAnimation: animation restoreOriginalFrame:NO];
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
	
	[tamara setVisible:NO];

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
	
	[tamara setVisible:NO];
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
	CCLabel *label = [CCLabel labelWithString:@"callback 1 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*1,s.height/2)];
	
	[self addChild:label];
}

-(void) callback2:(id)sender
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabel *label = [CCLabel labelWithString:@"callback 2 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*2,s.height/2)];
	
	[self addChild:label];
}

-(void) callback3:(id)sender data:(void*)data
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabel *label = [CCLabel labelWithString:@"callback 3 called" fontName:@"Marker Felt" fontSize:16];
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
	
	[tamara setVisible:NO];
	
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

@implementation ActionReverse
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];
	
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
	
	[tamara setVisible:NO];
	
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
	
	[tamara setVisible:NO];

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
	[grossini runAction:action];

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
		
	id a1 = [CCMoveBy actionWithDuration:1 position:ccp(150,0)];
	id action1 = [CCRepeat actionWithAction:
						[CCSequence actions: [CCPlace actionWithPosition:ccp(60,60)], a1, nil]
									times:3];
	id action2 = [CCRepeatForever actionWithAction:
						[CCSequence actions: [[a1 copy] autorelease], [a1 reverse], nil]
					];
	
	[grossini runAction:action1];
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
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCNode *sprite = [CCSprite spriteWithFile:@"grossinis_sister2.png"];
	[self addChild:sprite];
	[sprite setPosition:ccp(s.width-100, s.height/2)];
	
		
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
	[sprite runAction:action3];
}

-(void) callback1
{
	NSLog(@"callback 1 called");
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabel *label = [CCLabel labelWithString:@"callback 1 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*1,s.height/2)];

	[self addChild:label];
}
-(void) callback2:(id)sender
{
	NSLog(@"callback 2 called from:%@", sender);
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabel *label = [CCLabel labelWithString:@"callback 2 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*2,s.height/2)];

	[self addChild:label];

}
-(void) callback3:(id)sender data:(void*)data
{
	NSLog(@"callback 3 called from:%@ with data:%x",sender,data);
	CGSize s = [[CCDirector sharedDirector] winSize];
	CCLabel *label = [CCLabel labelWithString:@"callback 3 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*3,s.height/2)];
	[self addChild:label];
}



-(NSString *) title
{
	return @"Callbacks: CallFunc and friends";
}
@end

@implementation ActionOrbit
-(void) onEnter
{
	[super onEnter];

	[self centerSprites];
	
	id orbit1 = [CCOrbitCamera actionWithDuration: 2 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:180 angleX:0 deltaAngleX:0];
	id action1 = [CCSequence actions:
					orbit1,
					[orbit1 reverse],
					nil ];

	id orbit2 = [CCOrbitCamera actionWithDuration: 2 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:180 angleX:-45 deltaAngleX:0];
	id action2 = [CCSequence actions:
				  orbit2,
				  [orbit2 reverse],
				  nil ];
	
	
	[grossini runAction:action1];
	[tamara runAction:action2];
}


-(NSString *) title
{
	return @"OrbitCamera action";
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
//	[Director useFastDirector];
	
	// Attach cocos2d to the window
	[[CCDirector sharedDirector] attachInWindow:window];
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	
	// display FPS (useful when debugging)
	[[CCDirector sharedDirector] setDisplayFPS:YES];
	
	// frames per second
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];

	// Make the window visible
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
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

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
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
