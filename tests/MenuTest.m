//
// cocos2d for iphone
// main file
//


#import "MenuTest.h"

@implementation Layer1
-(id) init
{
	[super init];
	
	[MenuItem setFontSize:30];
	[MenuItem setFontName: @"Courier New"];
	
	
	MenuItem *item1 = [MenuItem itemFromString: @"Start" receiver:self selector:@selector(menuCallback2)];
	MenuItem *item2 = [MenuItem itemFromString: @"Options" receiver:self selector:@selector(menuCallback)];
	MenuItem *item3 = [MenuItem itemFromString: @"Scores" receiver:self selector:@selector(menuCallback2)];
	MenuItem *item4 = [MenuItem itemFromString: @"Help" receiver:self selector:@selector(menuCallback2)];
	MenuItem *item5 = [MenuItem itemFromString: @"Quit" receiver:self selector:@selector(onQuit)];
	
	[[item5 label] setR:255 g:0 b:32];
	
	[Menu setOffsetY:-40];
	
	menu = [Menu menuWithItems: item1, item2, item3, item4, item5, nil];
	
	[self add: menu];

	return self;
}

-(void) menuCallback
{
	[(MultiplexLayer*)parent switchTo:1];
}

-(void) menuCallback2
{
}

-(void) onQuit
{
	[[Director sharedDirector] end];
}
@end

@implementation Layer2
-(id) init
{
	[super init];
	
	MenuItem *item1 = [MenuItem itemFromString: @"Fullscreen" receiver:self selector:@selector(menuCallback2)];
	MenuItem *item2 = [MenuItem itemFromString: @"Go Back" receiver:self selector:@selector(menuCallback)];
	
	menu = [Menu menuWithItems: item1, item2, nil];
	
	[self add: menu];
	
	
	return self;
}

-(void) menuCallback
{
	[(MultiplexLayer*)parent switchTo:0];
}

-(void) menuCallback2
{
}

@end


// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];

		
	Scene *scene = [Scene node];

	MultiplexLayer *layer = [MultiplexLayer layerWithLayers: [Layer1 node], [Layer2 node], nil];
	[scene add: layer z:0];

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
