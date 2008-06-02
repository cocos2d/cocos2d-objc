

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
	
//	RotateBy *rot = [[RotateBy alloc] initWithDuration: 4 angle:360];
//	ScaleBy *scale = [[MoveBy alloc] initWithDuration:4 scale:2];
	
	[scene add: layer];
	[layer add: sprite];
	
	sprite.position_x = [[Director sharedDirector] winSize].size.width / 2;
	sprite.position_y = [[Director sharedDirector] winSize].size.height / 2;
	
//	[sprite do: rot];
//	[sprite do: scale];
	
	
	[[Director sharedDirector] runScene: scene];
}

@end
