//
// RotateWorld
// a cocos2d example
//

// cocos2d imports
#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Sprite.h"
#import "IntervalAction.h"
#import "InstantAction.h"
#import "CameraAction.h"
#import "Label.h"


// local import
#import "RotateWorld.h"

@implementation TextLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	CGRect size;
	float x,y;
	
	size = [[Director sharedDirector] winSize];
	x = size.size.width;
	y = size.size.height;

	NSArray *array = [UIFont familyNames];
	for( NSString *s in array )
		NSLog( s );
	Label* label = [Label labelWithString:@"cocos2d" dimensions:CGSizeMake(280, 64) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:64];

	[label setPosition: CGPointMake(x/2,y/2)];
	
	[self add: label];
	return self;
}
@end

@implementation SpriteLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	CGRect size;
	float x,y;
	
	size = [[Director sharedDirector] winSize];
	x = size.size.width;
	y = size.size.height;
	
	Sprite *sprite = [Sprite spriteFromFile: @"grossini.png"];
	Sprite *spriteSister1 = [Sprite spriteFromFile: @"grossinis_sister1.png"];
	Sprite *spriteSister2 = [Sprite spriteFromFile: @"grossinis_sister2.png"];
	
	[sprite setScale: 1.5];
	[spriteSister1 setScale: 1.5];
	[spriteSister2 setScale: 1.5];
	
	[sprite setPosition: CGPointMake(x/2,y/2)];
	[spriteSister1 setPosition: CGPointMake(40,y/2)];
	[spriteSister2 setPosition: CGPointMake(x-40,y/2)];

	Action *rot = [RotateBy actionWithDuration:16 angle:-3600];
	
	[self add: sprite];
	[self add: spriteSister1];
	[self add: spriteSister2];
	
	[sprite do: rot];

	IntervalAction *jump1 = [JumpBy actionWithDuration:4 position:CGPointMake(-400,0) height:100 jumps:4];
	IntervalAction *jump2 = [jump1 reverse];
	
	IntervalAction *rot1 = [RotateBy actionWithDuration:4 angle:360*2];
	IntervalAction *rot2 = [rot1 reverse];
	
	[spriteSister1 do: [Repeat actionWithAction: [Sequence actions:jump2, jump1, nil] times:5 ] ];
	[spriteSister2 do: [Repeat actionWithAction: [Sequence actions:jump1, jump2, nil] times:5 ] ];
	
	[spriteSister1 do: [Repeat actionWithAction: [Sequence actions: rot1, rot2, nil] times:5 ] ];
	[spriteSister2 do: [Repeat actionWithAction: [Sequence actions: rot2, rot1, nil] times:5 ] ];
	
	
	return self;
}
@end

@implementation MainLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	CGRect size;
	float x,y;
	
	size = [[Director sharedDirector] winSize];
	x = size.size.width;
	y = size.size.height;
	
	id blue =  [ColorLayer layerWithColor: 0x0000ffff];
	id red =   [ColorLayer layerWithColor: 0xff0000ff];
	id green = [ColorLayer layerWithColor: 0x00ff00ff];
	id white = [ColorLayer layerWithColor: 0xffffffff];

	[blue setScale: 0.5];
	[blue setPosition: CGPointMake(-x/4,-y/4)];
	[blue add: [SpriteLayer node]];
	
	[red setScale: 0.5];
	[red setPosition: CGPointMake(x/4,-y/4)];

	[green setScale: 0.5];
	[green setPosition: CGPointMake(-x/4,y/4)];
	[green add: [TextLayer node]];

	[white setScale: 0.5];
	[white setPosition: CGPointMake(x/4,y/4)];

	[self add: blue z:-1];
	[self add: white];
	[self add: green];
	[self add: red];

	Action * rot = [RotateBy actionWithDuration:8 angle:720];
	
	[blue do: rot];
	[red do: rot];
	[green do: rot];
	[white do: rot];
	
	return self;
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];

	Scene *scene = [Scene node];

	MainLayer * mainLayer =[MainLayer node];
	
	[scene add: mainLayer];
	
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	[scene do: [OrbitCamera actionWithDuration:4 radius:1 deltaRadius:2 angleZ:NAN deltaAngleZ:180 angleX:NAN deltaAngleX:0]];
	 
	[[Director sharedDirector] runScene: scene];
}

@end
