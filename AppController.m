//
// cocos2d for iphone
// IntervalAction
//

#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Sprite.h"
#import "AppController.h"
#import "IntervalAction.h"
#import "InstantAction.h"
#import "Label.h"
#import "Texture2D.h"

@implementation MainLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	hello = [[Label alloc] initWithString:@"Hello" dimensions:CGSizeMake(64, 32) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:14];

	[hello autorelease];
	
	[self add: hello z:0];
	[hello setPosition: CGPointMake(200,200)];
	
	[hello do: [Sequence actions:
				[MoveBy actionWithDuration: 2 delta: CGPointMake(-100,-100)],
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
	[hello setPosition: CGPointMake(200,200)];
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: NO];

	Scene *scene = [Scene node];
	ColorLayer *layer = [ColorLayer layerWithColor: 0x00ff0080];
	Sprite *sprite = [Sprite spriteFromFile: @"Ship.png"];
	MainLayer * mainLayer =[MainLayer node];
	
	id rotby = [RotateBy actionWithDuration: 1.5 angle:360+90];
	id rotto = [RotateTo actionWithDuration: 1.5 angle:270];
	id scaleby = [ScaleBy actionWithDuration: 2 scale:0.2];
	id moveby =	[MoveBy actionWithDuration: 2 delta: CGPointMake(0,100) ];
	id moveto =	[Speed actionWithAction: [MoveTo actionWithDuration: 8 position: CGPointMake(20,20) ] speed:2 ];
	
	[scene add: mainLayer z:1];
	[scene add: layer z:2];
	[layer add: sprite];
	
	[sprite setPosition:  CGPointMake( [[Director sharedDirector] winSize].size.width / 2,
									  [[Director sharedDirector] winSize].size.height / 2 )  ];
	
	[sprite do: [Blink actionWithDuration: 2 blinks: 10]];
	[sprite do: [AccelDeccel actionWithAction: [Sequence actions: rotby, rotto, nil ] ] ];
	[sprite do: [Accelerate actionWithAction: [Sequence actions: scaleby, [scaleby reverse], nil] rate:4] ];
	[sprite do: [Sequence actions: moveby, [DelayTime actionWithDuration:2], moveto, nil] ];
	
	[[Director sharedDirector] runScene: scene];
}

@end
