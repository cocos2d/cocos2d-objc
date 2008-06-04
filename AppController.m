

#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Sprite.h"
#import "AppController.h"
#import "Action.h"

// CLASS IMPLEMENTATIONS
@implementation AppController


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	Scene *scene = [[Scene alloc]init];
	ColorLayer *layer = [[ColorLayer alloc] initWithColor: 0xff0000ff];
	Sprite *sprite = [[Sprite alloc] initFromFile: @"Ship.png"];
	
	RotateBy *rot = [[RotateBy alloc] initWithDuration: 4 angle:360];
//	ScaleBy *scale = [[ScaleBy alloc] initWithDuration: 4 scale:2];
	MoveBy *move = [[MoveBy alloc] initWithDuration: 1 delta: CGPointMake(0,-200) ];
	
	[scene add: layer];
	[layer add: sprite];
	
	[sprite setPosition:  CGPointMake( [[Director sharedDirector] winSize].size.width / 2,
									  [[Director sharedDirector] winSize].size.height / 2 )  ];
	
	[sprite do: rot];
//	[sprite do: scale];
	[sprite do: move];
	
	[[Director sharedDirector] runScene: scene];
}

@end
