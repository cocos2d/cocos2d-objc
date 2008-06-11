//
// cocos2d for iphone
// main file
//

#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "Sprite.h"
#import "IntervalAction.h"
#import "InstantAction.h"
#import "Label.h"
#import "Texture2D.h"

#import "Playground.h"

@implementation MainLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	Sprite *sprite = [Sprite spriteFromFile: @"grossini.png"];
		
	[self add: sprite z:0];
	[sprite setPosition: CGPointMake(20,150)];
	
	[sprite do: [JumpTo actionWithDuration:4 position:CGPointMake(300,0) height:100 jumps:4] ];
	
	return self;
}

-(void) onEnter
{
	[super onEnter];
	[[Director sharedDirector] setEventHandler:self];
}
-(void) onExit
{
	[super onExit];
	[[Director sharedDirector] setEventHandler:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];
	
	Sprite *sprite = [Sprite spriteFromFile:@"grossini.png"];
	[sprite setPosition: CGPointMake(location.x, 480-location.y)];
	[sprite do: [RotateBy actionWithDuration:2 angle:360]];
	[self add: sprite];

}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];

	UIAlertView*			alertView;

	alertView = [[UIAlertView alloc] initWithTitle:@"Welcome to Crash Landing!" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Start", nil];
	[alertView setMessage:[NSString stringWithFormat:@"Control the ship by gently\ntilting the %@:\n- Left / Right for orientation\n- Backward / Forward for thrust", [[UIDevice currentDevice] model]]];
	[alertView show];
	[alertView release];
		
	Scene *scene = [Scene node];

	MainLayer * mainLayer =[MainLayer node];
	
	[scene add: mainLayer z:2];

	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	[[Director sharedDirector] runScene: scene];
}

- (void)handleTap
{
	[[Director sharedDirector] popScene];
}

- (void)modalView:(UIAlertView *)modalView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	//Start a new game after the user has dismissed the welcome dialog
	[[Director sharedDirector] popScene];
}

@end