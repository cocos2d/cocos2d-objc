//
// Transitions Demo
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
#import "Transition.h"
#import "Primitives.h"

// local import
#import "Playground.h"


@implementation TextLayer
-(void) draw
{
	drawPoint(200, 200);
	drawLine(0,0, 320,480);
	drawCircle( 160, 300, 150, 0, 100);
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
