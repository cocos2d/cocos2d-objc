

#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Sprite.h"
#import "AppController.h"
#import "Action.h"
#import "Label.h"
#import "Texture2D.h"

@implementation MainLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	hello = [[Label alloc] initWithString:@"Hello" dimensions:CGSizeMake(64, 32) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:14];

	[self add: hello z:0];
	[hello setPosition: CGPointMake(200,200)];
	return self;
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	Scene *scene = [[Scene alloc]init];
	ColorLayer *layer = [[ColorLayer alloc] initWithColor: 0x00ff0080];
	Sprite *sprite = [[Sprite alloc] initFromFile: @"Ship.png"];
	MainLayer * mainLayer =[[MainLayer alloc] init];
	
	id rot = [[RotateBy alloc] initWithDuration: 4 angle:360];
	id scale = [[ScaleTo alloc] initWithDuration: 4 scale:0.2];
	id move = [[MoveBy alloc] initWithDuration: 1 delta: CGPointMake(0,-200) ];
	
	[scene add: mainLayer z:1];
	[scene add: layer z:2];
	[layer add: sprite];
	
	[sprite setPosition:  CGPointMake( [[Director sharedDirector] winSize].size.width / 2,
									  [[Director sharedDirector] winSize].size.height / 2 )  ];
	
	[sprite do: [[Sequence alloc] initOne: rot two: [rot reverse] ] ];
	[sprite do: [[Accelerate alloc] initWithAction: scale rate:4 ]];
	[sprite do: move];
	
	[[Director sharedDirector] runScene: scene];
}

@end
