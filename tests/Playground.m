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
//	emitter = [[EmitFireworks alloc] init];
	emitter = [[EmitFire alloc] init];
	for( int i=0; i < emitter.totalParticles;i++ )
		[emitter addParticle];
	return self;
}

-(void) draw
{
	[emitter update];
}
@end


// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];

	Scene *scene = [Scene node];
	[scene add: [TextLayer node]];
			 
	[[Director sharedDirector] runScene: scene];
}

@end
