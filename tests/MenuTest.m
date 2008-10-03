//
// cocos2d for iphone
// Menu test
//


#import "MenuTest.h"

@implementation Layer1
-(id) init
{
	[super init];
	
	[MenuItemFont setFontSize:30];
	[MenuItemFont setFontName: @"Courier New"];
	
	
	MenuItem *item1 = [MenuItemFont itemFromString: @"Start" target:self selector:@selector(menuCallback:)];
	MenuItem *item2 = [MenuItemImage itemFromNormalImage:@"SendScoreButton.png" selectedImage:@"SendScoreButtonPressed.png" target:self selector:@selector(menuCallback2:)];
	MenuItemFont *item3 = [MenuItemFont itemFromString: @"Quit" target:self selector:@selector(onQuit:)];
	
	[[item3 label] setRGB:255:0:32];

	menu = [Menu menuWithItems: item1, item2, item3, nil];
	
	[self add: menu];

	return self;
}

-(void) menuCallback: (id) sender
{
	[(MultiplexLayer*)parent switchTo:1];
}

-(void) menuCallback2: (id) sender
{
	[(MultiplexLayer*)parent switchTo:2];
}

-(void) onQuit: (id) sender
{
	[[Director sharedDirector] end];
}
@end

@implementation Layer2
-(id) init
{
	[super init];
	
	[MenuItemFont setFontSize:48];
	[MenuItemFont setFontName: @"Marker Felt"];

	
	MenuItemFont *item1 = [MenuItemFont itemFromString: @"Option 1" target:self selector:@selector(menuCallback2:)];
	MenuItemFont *item2 = [MenuItemFont itemFromString: @"Go Back" target:self selector:@selector(menuCallback:)];
	
	menu = [Menu menuWithItems: item1, item2, nil];

	CGRect s = [[Director sharedDirector] winSize];
	menu.position = cpv( s.size.width -100, s.size.height-100);
	
	[self add: menu];
	
	
	return self;
}

-(void) menuCallback: (id) sender
{
	[(MultiplexLayer*)parent switchTo:0];
}

-(void) menuCallback2: (id) sender
{
}
@end

@implementation Layer3
-(id) init
{
	[super init];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:28];

	MenuItemFont *item1 = [MenuItemFont itemFromString: @"Option 1" target:self selector:@selector(menuCallback2:)];
	MenuItemFont *item2 = [MenuItemFont itemFromString: @"Go Back" target:self selector:@selector(menuCallback:)];
	
	menu = [Menu menuWithItems: item1, item2, nil];	
	menu.position = cpv(0,0);
	
	item1.position = cpv(100,100);
	item2.position = cpv(100,200);
	
	id jump = [JumpBy actionWithDuration:3 position:cpv(400,0) height:50 jumps:4];
	[item2 do: [Repeat actionWithAction:
				 [Sequence actions: jump, [jump reverse], nil]
								   times:-1]
	 ];
	
	[self add: menu];
	
	
	return self;
}

-(void) menuCallback: (id) sender
{
	[(MultiplexLayer*)parent switchTo:0];
}

-(void) menuCallback2: (id) sender
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

	MultiplexLayer *layer = [MultiplexLayer layerWithLayers: [Layer1 node], [Layer2 node], [Layer3 node], nil];
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

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

@end
