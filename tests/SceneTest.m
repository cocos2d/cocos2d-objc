//
// cocos2d for iphone
// main file
//

#import "Scene.h"
#import "Layer.h"
#import "Director.h"
#import "MenuItem.h"
#import "Menu.h"

#import "SceneTest.h"

@implementation Layer1
-(id) init
{
	[super init];
	
	MenuItem *item1 = [MenuItem itemFromString: @"Options" receiver:self selector:@selector(onOptions)];
	MenuItem *item2 = [MenuItem itemFromString: @"Quit" receiver:self selector:@selector(onQuit)];
	
	menu = [Menu menuWithItems: item1, item2, nil];
	
	[self add: menu];

	return self;
}

-(void) onOptions
{
	Scene * scene = [[Scene node] add: [Layer2 node]];
	[[Director sharedDirector] pushScene: scene];
}

-(void) onQuit
{
	[[Director sharedDirector] popScene];
}

-(void) onVoid
{
}

@end

@implementation Layer2
-(id) init
{
	[super init];
	
	MenuItem *item1 = [MenuItem itemFromString: @"Fullscreen" receiver:self selector:@selector(onFullscreen)];
	MenuItem *item2 = [MenuItem itemFromString: @"Go Back" receiver:self selector:@selector(onGoBack)];
	
	menu = [Menu menuWithItems: item1, item2, nil];
	
	[self add: menu];
	
	
	return self;
}

-(void) onGoBack
{
	[[Director sharedDirector] popScene];
}

-(void) onFullscreen
{
	[[Director sharedDirector] replaceScene: [ [Scene node] add: [Layer3 node]] ];
}
@end

@implementation Layer3
-(id) init
{
	[super initWithColor: 0x0000ffff];
	isEventHandler = YES;
	return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[Director sharedDirector] popScene];
}
@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];

		
	Scene *scene = [Scene node];

	[scene add: [Layer1 node] z:0];

	[[Director sharedDirector] runScene: scene];
}

@end