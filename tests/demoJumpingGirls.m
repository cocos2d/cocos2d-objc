//
//	demoJumpingGirls.m
//	cocos2d
//

#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Sprite.h"
#import "IntervalAction.h"
#import "InstantAction.h"
#import "Label.h"
#import "Texture2D.h"

#import "demoJumpingGirls.h"

@implementation MainLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	hello = [Label labelWithString:@"cocos2d in iphone" dimensions:CGSizeMake(280, 32) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:32];
	
	[self add: hello z:0];
	[hello setPosition: cpv(200,200)];
	
	[hello do: [Sequence actions:
				[MoveBy actionWithDuration: 2 position: cpv(-100,-100)],
				[CallFunc actionWithTarget: self selector: @selector(testCB)],
				nil ] ];
	[hello do: [Spawn actions:
				[RotateBy actionWithDuration: 2 angle: 360],
				[ScaleBy actionWithDuration: 3 scale:1.5],
				nil] ];
	return self;
}

-(void) testCB
{
	[hello setPosition: cpv(200,200)];
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];

	Scene *scene = [Scene node];
	ColorLayer *layer = [ColorLayer layerWithColor: 0x00ff00ff];
	Sprite *sprite = [Sprite spriteFromFile: @"grossini.png"];
	Sprite *spriteSister1 = [Sprite spriteFromFile: @"grossinis_sister1.png"];
	Sprite *spriteSister2 = [Sprite spriteFromFile: @"grossinis_sister2.png"];
							 
	MainLayer * mainLayer =[MainLayer node];
	
	id rotby = [RotateBy actionWithDuration: 1.5 angle:360+90];
	id rotto = [RotateTo actionWithDuration: 1.5 angle:270];
	id scaleby = [ScaleBy actionWithDuration: 2 scale:0.2];
	id moveby =	[MoveBy actionWithDuration: 2 position: cpv(0,100) ];
	id moveto =	[Speed actionWithAction: [MoveTo actionWithDuration: 8 position: cpv(20,20) ] speed:2 ];
	
	[scene add: mainLayer z:2];
	[scene add: layer z:1];
	[layer add: sprite];
	[layer add: spriteSister1];
	[layer add: spriteSister2];
	
	spriteSister1.position = cpv(40,100);
	spriteSister2.position = cpv(440,100);
	
	IntervalAction *jump1 = [JumpBy actionWithDuration:4 position:cpv(-400,0) height:100 jumps:4];
	IntervalAction *jump2 = [jump1 reverse];
	
	IntervalAction *rot1 = [RotateBy actionWithDuration:4 angle:360*2];
	IntervalAction *rot2 = [rot1 reverse];
	
	[spriteSister1 do: [Repeat actionWithAction: [Sequence actions:jump2, jump1, nil] times:5 ] ];
	[spriteSister2 do: [Repeat actionWithAction: [Sequence actions:[jump1 copy], [jump2 copy], nil] times:5 ] ];

	[spriteSister1 do: [Repeat actionWithAction: [Sequence actions: rot1, rot2, nil] times:5 ] ];
	[spriteSister2 do: [Repeat actionWithAction: [Sequence actions: [rot2 copy], [rot1 copy], nil] times:5 ] ];

	
	[sprite setPosition:  cpv( [[Director sharedDirector] winSize].size.width / 2,
									  [[Director sharedDirector] winSize].size.height / 2 )  ];
	
	[sprite do: [Blink actionWithDuration: 2 blinks: 10]];
	[sprite do: [AccelDeccel actionWithAction: [Sequence actions: rotby, rotto, nil ] ] ];
	[sprite do: [Accelerate actionWithAction: [Sequence actions: scaleby, [scaleby reverse], nil] rate:4] ];
	[sprite do: [Sequence actions: moveby, [DelayTime actionWithDuration:2], moveto, nil] ];

	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	[[Director sharedDirector] runScene: scene];
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
@end
