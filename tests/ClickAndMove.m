//
// cocos2d for iphone
// main file
//

#import "ClickAndMove.h"

#import "OpenGL_Internal.h"

@implementation MainLayer
-(id) init
{
	if( ! [super init] )
		return nil;
	
	isTouchEnabled = YES;
	
	Sprite *sprite = [Sprite spriteFromFile: @"grossini.png"];
	
	id layer = [ColorLayer layerWithColor: 0xffff00ff];
	[self add: layer];
		
	[self add: sprite z:0 name:@"sprite"];
	[sprite setPosition: cpv(20,150)];
	
	[sprite do: [JumpTo actionWithDuration:4 position:cpv(300,48) height:100 jumps:4] ];
	
	[layer do: [Repeat actionWithAction: 
								[Sequence actions:
								[FadeIn actionWithDuration:1],
								[FadeOut actionWithDuration:1],
								nil]
					times: 0]
					];
	
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];

/*
	Sprite *sprite = [Sprite spriteFromFile:@"grossini.png"];
	[sprite setPosition: CGPointMake(location.x, 480-location.y)];
	[sprite do: [RotateBy actionWithDuration:2*4 angle:360*4]];
	[self add: sprite];
 */
	CocosNode *s = [self get: @"sprite"];
	[s stop];
	[s do: [MoveTo actionWithDuration:1 position:cpv(location.x, 480-location.y)]];
	double o = location.x - [s position].x;
	double a = (480-location.y) - [s position].y;
	double at = RADIANS_TO_DEGREES( atan(o/a) );
	
	if( a < 0 )
		if(  o < 0 )
			at = 180 + abs(at);
		else
			at = 180 - abs(at);	
	
	[s do: [RotateTo actionWithDuration:1 angle: at]];
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];

	UIAlertView*			alertView;

	alertView = [[UIAlertView alloc] initWithTitle:@"Welcome" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Start", nil];
	[alertView setMessage:[NSString stringWithFormat:@"Click on the screen\nto move and rotate Grossini", [[UIDevice currentDevice] model]]];
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

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}
@end
