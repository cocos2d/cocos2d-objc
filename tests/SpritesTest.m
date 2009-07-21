//
// Sprites Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "cocos2d.h"
#import "SpritesTest.h"

enum {
	kTagAnimationDance = 1,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
						 @"SpriteManual",
						 @"SpriteMove",
						 @"SpriteRotate",
						 @"SpriteScale",
						 @"SpriteJump",
						 @"SpriteBezier",
						 @"SpriteBlink",
						 @"SpriteFade",
						 @"SpriteTint",
						 @"SpriteAnimate",
						 @"SpriteSequence",
						 @"SpriteSpawn",
						 @"SpriteReverse",
						 @"SpriteDelayTime",
						 @"SpriteRepeat",
						 @"SpriteCallFunc",
						 @"SpriteReverseSequence",
						 @"SpriteReverseSequence2",
						 @"SpriteOrbit" };

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
		// Or you can create an sprite using a filename. PNG, JPEG and BMP files are supported. Probably TIFF too
		tamara = [[Sprite spriteWithFile:@"grossinis_sister1.png"] retain];
		
		[self addChild: grossini z:1];
		[self addChild: tamara z:2];

		CGSize s = [[Director sharedDirector] winSize];
		
		[grossini setPosition: ccp(60, s.height/3)];
		[tamara setPosition: ccp(60, 2*s.height/3)];
		
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


-(void) centerSprites
{
	CGSize s = [[Director sharedDirector] winSize];
	
	[grossini setPosition: ccp(s.width/3, s.height/2)];
	[tamara setPosition: ccp(2*s.width/3, s.height/2)];
}
-(NSString*) title
{
	return @"No title";
}
@end


@implementation SpriteManual
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


@implementation SpriteMove
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[Director sharedDirector] winSize];

	
	id actionTo = [MoveTo actionWithDuration: 2 position:ccp(s.width-40, s.height-40)];
	
	id actionBy = [MoveBy actionWithDuration:2  position: ccp(80,80)];
	id actionByBack = [actionBy reverse];
	
	[tamara runAction: actionTo];
	[grossini runAction: [Sequence actions:actionBy, actionByBack, nil]];
}
-(NSString *) title
{
	return @"MoveTo / MoveBy";
}
@end

@implementation SpriteRotate
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
		
	id actionTo = [RotateTo actionWithDuration: 2 angle:45];
	id actionBy = [RotateBy actionWithDuration:2  angle: 360];
	id actionByBack = [actionBy reverse];

	
	[tamara runAction: actionTo];
	[grossini runAction: [Sequence actions:actionBy, actionByBack, nil]];
}
-(NSString *) title
{
	return @"RotateTo / RotateBy";
}

@end

@implementation SpriteScale
-(void) onEnter
{
	[super onEnter];

	[self centerSprites];
	
	id actionTo = [ScaleTo actionWithDuration: 2 scale:0.5f];
	id actionBy = [ScaleBy actionWithDuration:2  scale: 2];
	id actionByBack = [actionBy reverse];

	[tamara runAction: actionTo];
	[grossini runAction: [Sequence actions:actionBy, actionByBack, nil]];
}
-(NSString *) title
{
	return @"ScaleTo / ScaleBy";
}

@end

@implementation SpriteJump
-(void) onEnter
{
	[super onEnter];
		
	id actionTo = [JumpTo actionWithDuration:2 position:ccp(300,300) height:50 jumps:4];
	id actionBy = [JumpBy actionWithDuration:2 position:ccp(300,0) height:50 jumps:4];
	id actionByBack = [actionBy reverse];
	
	[tamara runAction: actionTo];
	[grossini runAction: [Sequence actions:actionBy, actionByBack, nil]];
}
-(NSString *) title
{
	return @"JumpTo / JumpBy";
}
@end

@implementation SpriteBezier
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[Director sharedDirector] winSize];
	
	//
	// startPosition can be any coordinate, but since the movement
	// is relative to the Bezier curve, make it (0,0)
	//
	
	// sprite 1
	ccBezierConfig bezier;
	bezier.startPosition = ccp(0,0);
	bezier.controlPoint_1 = ccp(0, s.height/2);
	bezier.controlPoint_2 = ccp(300, -s.height/2);
	bezier.endPosition = ccp(300,100);
	
	id bezierForward = [BezierBy actionWithDuration:3 bezier:bezier];
	id bezierBack = [bezierForward reverse];	
	id seq = [Sequence actions: bezierForward, bezierBack, nil];
	id rep = [RepeatForever actionWithAction:seq];
	

	// sprite 2
	ccBezierConfig bezier2;
	bezier2.startPosition = ccp(0,0);
	bezier2.controlPoint_1 = ccp(100, s.height/2);
	bezier2.controlPoint_2 = ccp(200, -s.height/2);
	bezier2.endPosition = ccp(300,0);
	
	id bezierForward2 = [BezierBy actionWithDuration:3 bezier:bezier2];
	id bezierBack2 = [bezierForward2 reverse];	
	id seq2 = [Sequence actions: bezierForward2, bezierBack2, nil];
	id rep2 = [RepeatForever actionWithAction:seq2];
	
	
	[grossini runAction: rep];
	[tamara runAction:rep2];
}
-(NSString *) title
{
	return @"BezierBy";
}
@end


@implementation SpriteBlink
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
	
	id action1 = [Blink actionWithDuration:2 blinks:10];
	id action2 = [Blink actionWithDuration:2 blinks:5];
	
	[tamara runAction: action1];
	[grossini runAction:action2];
}
-(NSString *) title
{
	return @"Blink";
}
@end

@implementation SpriteFade
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
	
	tamara.opacity = 0;
	id action1 = [FadeIn actionWithDuration:1.0f];
	id action1Back = [action1 reverse];
	
	id action2 = [FadeOut actionWithDuration:1.0f];
	id action2Back = [action2 reverse];
	
	[tamara runAction: [Sequence actions: action1, action1Back, nil]];
	[grossini runAction: [Sequence actions: action2, action2Back, nil]];
}
-(NSString *) title
{
	return @"FadeIn / FadeOut";
}
@end

@implementation SpriteTint
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
	
	id action1 = [TintTo actionWithDuration:2 red:255 green:0 blue:255];
	id action2 = [TintBy actionWithDuration:2 red:-127 green:-255 blue:-127];
	id action2Back = [action2 reverse];
	
	[tamara runAction: action1];
	[grossini runAction: [Sequence actions: action2, action2Back, nil]];
}
-(NSString *) title
{
	return @"TintTo / TintBy";
}
@end

@implementation SpriteAnimate
-(void) onEnter
{
	[super onEnter];
	
	[self centerSprites];
	
	[tamara setVisible:NO];
	
	Animation* animation = [Animation animationWithName:@"dance" delay:0.2f];
	for( int i=1;i<15;i++)
		[animation addFrameWithFilename: [NSString stringWithFormat:@"grossini_dance_%02d.png", i]];
	
	id action = [Animate actionWithAnimation: animation];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"Animation";
}
@end


@implementation SpriteSequence
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];

	id action = [Sequence actions:
				 [MoveBy actionWithDuration: 2 position:ccp(240,0)],
				 [RotateBy actionWithDuration: 2 angle: 540],
				 nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"Sequence: Move + Rotate";
}
@end

@implementation SpriteSpawn
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];
	
	id action = [Spawn actions:
				 [JumpBy actionWithDuration:2 position:ccp(300,0) height:50 jumps:4],
				 [RotateBy actionWithDuration: 2 angle: 720],
				 nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"Spawn: Jump + Rotate";
}
@end

@implementation SpriteReverse
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];
	
	id jump = [JumpBy actionWithDuration:2 position:ccp(300,0) height:50 jumps:4];
	id action = [Sequence actions: jump, [jump reverse], nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"Reverse an action";
}
@end

@implementation SpriteDelayTime
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];
	
	id move = [MoveBy actionWithDuration:1 position:ccp(150,0)];
	id action = [Sequence actions: move, [DelayTime actionWithDuration:2], move, nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"DelayTime: m + delay + m";
}
@end

@implementation SpriteReverseSequence
-(void) onEnter
{
	[super onEnter];
	
	[tamara setVisible:NO];

	id move1 = [MoveBy actionWithDuration:1 position:ccp(250,0)];
	id move2 = [MoveBy actionWithDuration:1 position:ccp(0,50)];
	id seq = [Sequence actions: move1, move2, [move1 reverse], nil];
	id action = [Sequence actions: seq, [seq reverse], nil];
	
	[grossini runAction:action];
}
-(NSString *) title
{
	return @"Reverse a sequence";
}
@end

@implementation SpriteReverseSequence2
-(void) onEnter
{
	[super onEnter];
	
	// Test:
	//   Sequence should work both with IntervalAction and InstantActions
	
	id move1 = [MoveBy actionWithDuration:1 position:ccp(250,0)];
	id move2 = [MoveBy actionWithDuration:1 position:ccp(0,50)];
	id tog1 = [ToggleVisibility action];
	id tog2 = [ToggleVisibility action];
	id seq = [Sequence actions: move1, tog1, move2, tog2, [move1 reverse], nil];
	id action = [Repeat actionWithAction:[Sequence actions: seq, [seq reverse], nil]
								   times:3];
				 

	// Test:
	//   Also test that the reverse of Hide is Show, and vice-versa
	[grossini runAction:action];

	id move_tamara = [MoveBy actionWithDuration:1 position:ccp(100,0)];
	id move_tamara2 = [MoveBy actionWithDuration:1 position:ccp(50,0)];
	id hide = [Hide action];
	id seq_tamara = [Sequence actions: move_tamara, hide, move_tamara2, nil];
	id seq_back = [seq_tamara reverse];
	[tamara runAction: [Sequence actions: seq_tamara, seq_back, nil]];
}
-(NSString *) title
{
	return @"Reverse sequence 2";
}
@end


@implementation SpriteRepeat
-(void) onEnter
{
	[super onEnter];
		
	id a1 = [MoveBy actionWithDuration:1 position:ccp(150,0)];
	id action1 = [Repeat actionWithAction:
						[Sequence actions: [Place actionWithPosition:ccp(60,60)], a1, nil]
									times:3];
	id action2 = [RepeatForever actionWithAction:
						[Sequence actions: [[a1 copy] autorelease], [a1 reverse], nil]
					];
	
	[grossini runAction:action1];
	[tamara runAction:action2];
}
-(NSString *) title
{
	return @"Repeat / RepeatForever actions";
}
@end

@implementation SpriteCallFunc
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[Director sharedDirector] winSize];
	Sprite *sprite = [Sprite spriteWithFile:@"grossinis_sister2.png"];
	[self addChild:sprite];
	[sprite setPosition:ccp(s.width-100, s.height/2)];
	
		
	id action = [Sequence actions:
				 [MoveBy actionWithDuration:2 position:ccp(200,0)],
				 [CallFunc actionWithTarget:self selector:@selector(callback1)],
				nil];
	
	id action2 = [Sequence actions:
						[ScaleBy actionWithDuration:2  scale: 2],
						[FadeOut actionWithDuration:2],
						[CallFuncN actionWithTarget:self selector:@selector(callback2:)],
						 nil];
	
	id action3 = [Sequence actions:
				  [RotateBy actionWithDuration:3  angle:360],
				  [FadeOut actionWithDuration:2],
				  [CallFuncND actionWithTarget:self selector:@selector(callback3:data:) data:(void*)0xbebabeba],
				  nil];
	
	[grossini runAction:action];
	[tamara runAction:action2];
	[sprite runAction:action3];
}

-(void) callback1
{
	NSLog(@"callback 1 called");
	CGSize s = [[Director sharedDirector] winSize];
	Label *label = [Label labelWithString:@"callback 1 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*1,s.height/2)];

	[self addChild:label];
}
-(void) callback2:(id)sender
{
	NSLog(@"callback 2 called from:%@", sender);
	CGSize s = [[Director sharedDirector] winSize];
	Label *label = [Label labelWithString:@"callback 2 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*2,s.height/2)];

	[self addChild:label];

}
-(void) callback3:(id)sender data:(void*)data
{
	NSLog(@"callback 3 called from:%@ with data:%x",sender,data);
	CGSize s = [[Director sharedDirector] winSize];
	Label *label = [Label labelWithString:@"callback 3 called" fontName:@"Marker Felt" fontSize:16];
	[label setPosition:ccp( s.width/4*3,s.height/2)];
	[self addChild:label];
}



-(NSString *) title
{
	return @"Callbacks: CallFunc and friends";
}
@end

@implementation SpriteOrbit
-(void) onEnter
{
	[super onEnter];

	[self centerSprites];
	
	id orbit1 = [OrbitCamera actionWithDuration: 2 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:180 angleX:0 deltaAngleX:0];
	id action1 = [Sequence actions:
					orbit1,
					[orbit1 reverse],
					nil ];

	id orbit2 = [OrbitCamera actionWithDuration: 2 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:180 angleX:-45 deltaAngleX:0];
	id action2 = [Sequence actions:
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
	[[Director sharedDirector] attachInWindow:window];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	
	// display FPS (useful when debugging)
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];

	// Make the window visible
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

- (void) dealloc
{
	[window release];
	[super dealloc];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

@end
