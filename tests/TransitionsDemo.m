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

// local import
#import "TransitionsDemo.h"

id nextTransition()
{
	static int i=0;
	
	// force loading of transitions
	// else NSClassFromString will fail
	[RotoZoomTransition node];
	
	NSArray *transitions = [[NSArray arrayWithObjects:
									@"FadeTransition",
									@"FlipXTransition",
									@"FlipYTransition",
									@"FlipAngularTransition",
									@"ShrinkGrowTransition",
									@"RotoZoomTransition",
									@"JumpZoomTransition",
									@"MoveInLTransition",
									@"MoveInRTransition",
									@"MoveInTTransition",
									@"MoveInBTransition",
									@"SlideInLTransition",
									@"SlideInRTransition",
									@"SlideInTTransition",
									@"SlideInBTransition",
									nil ] retain];
	
	
	NSString *r = [transitions objectAtIndex:i++];
	i = i % [transitions count];
	Class c = NSClassFromString(r);
	return c;
}

@implementation TextLayer
-(id) init
{
	if( ! [super initWithColor: 0x00ff00ff] )
		return nil;

	isEventHandler = YES;

	CGRect size;
	float x,y;
	
	size = [[Director sharedDirector] winSize];
	x = size.size.width;
	y = size.size.height;

	Label* label = [Label labelWithString:@"SCENE 1" dimensions:CGSizeMake(280, 64) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:64];

	[label setPosition: cpv(x/2,y/2)];
	
	[self add: label];
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	Scene *s2 = [Scene node];
	[s2 add: [TextLayer2 node]];
	[[Director sharedDirector] replaceScene: [nextTransition() transitionWithDuration:1.2 scene:s2]];
}	
@end

@implementation TextLayer2
-(id) init
{
	if( ! [super initWithColor: 0xff0000ff] )
		return nil;
	
	isEventHandler = YES;
	
	CGRect size;
	float x,y;
	
	size = [[Director sharedDirector] winSize];
	x = size.size.width;
	y = size.size.height;
	
	Label* label = [Label labelWithString:@"SCENE 2" dimensions:CGSizeMake(280, 64) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:64];
	
	[label setPosition: cpv(x/2,y/2)];
	
	[self add: label];
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	Scene *s2 = [Scene node];
	[s2 add: [TextLayer node]];
	[[Director sharedDirector] replaceScene: [nextTransition() transitionWithDuration:1.2 scene:s2]];
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
