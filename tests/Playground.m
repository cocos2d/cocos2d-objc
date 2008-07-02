//
// a cocos2d-iphone example
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
#import "Transition.h"
#import "Primitives.h"
#import "Particle.h"

// local import
#import "Playground.h"


@implementation TextLayer
-(id) init
{
	[super init];
	emitter1 = [[EmitFireworks alloc] init];
	emitter2 = [[EmitFireworks2 alloc] init];
	emitter3 = [[EmitFire alloc] init];
	
	cpVect v;
	v.x=160;
	v.y=20;
	[emitter2 setPos:v];
	
//	emitter2 = [[EmitFire alloc] init];
	return self;
}

-(void) draw
{
	[emitter1 update];
	[emitter2 update];
	[emitter3 update];
}
@end


// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];

	[[Director sharedDirector] setFPS: YES];
	

	Scene *scene = [Scene node];
	[scene add: [TextLayer node]];
			 
	[[Director sharedDirector] runScene: scene];
}

@end
