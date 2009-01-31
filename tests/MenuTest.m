//
// cocos2d for iphone
// Menu test
//


#import "MenuTest.h"

enum {
	kTagMenu = 1,
};

@implementation Layer1
-(id) init
{
	[super init];
	
	[MenuItemFont setFontSize:30];
	[MenuItemFont setFontName: @"Courier New"];
	
	
	MenuItem *item1 = [MenuItemFont itemFromString: @"Start" target:self selector:@selector(menuCallback:)];
	MenuItem *item2 = [MenuItemImage itemFromNormalImage:@"SendScoreButton.png" selectedImage:@"SendScoreButtonPressed.png" target:self selector:@selector(menuCallback2:)];
	MenuItem *item3 = [MenuItemFont itemFromString: @"Disabled Item" target: self selector:@selector(menuCallbackDisabled:)];
	MenuItem *item4 = [MenuItemFont itemFromString: @"I toggle enable items" target: self selector:@selector(menuCallbackEnable:)];
	
	id t1 = [MenuItemFont itemFromString: @"Volume Off"];
	id t2 = [MenuItemFont itemFromString: @"Volume 33%"];
	id t3 = [MenuItemFont itemFromString: @"Volume 66%"];
	id t4 = [MenuItemFont itemFromString: @"Volume 100%"];
	MenuItemToggle *item5 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallbackVolume:) items:t1,t2,t3,t4,nil];

	// you can change the one of the items by doing this
	item5.selectedIndex = 2;

	MenuItemFont *item6 = [MenuItemFont itemFromString: @"Quit" target:self selector:@selector(onQuit:)];
	
	[[item6 label] setRGB:255:0:32];

	Menu *menu = [Menu menuWithItems: item1, item2, item3, item4, item5, item6, nil];
	[menu alignItemsVertically];

	disabledItem = [item3 retain];
	disabledItem.isEnabled = NO;

	[self add: menu];

	return self;
}

-(void) dealloc
{
	[disabledItem release];
	[super dealloc];
}

-(void) menuCallback: (id) sender
{
	[(MultiplexLayer*)parent switchTo:1];
}

-(void) menuCallbackVolume:(id) sender
{

//	if( [sender selectedIndex] == 3 )
//		[sender setIsEnabled:NO];

	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
}

-(void) menuCallbackDisabled:(id) sender {
}

-(void) menuCallbackEnable:(id) sender {
	disabledItem.isEnabled = ~disabledItem.isEnabled;
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
	
	isTouchEnabled = YES;
	
	MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png" target:self selector:@selector(menuCallbackBack:)];
	MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"btn-highscores-normal.png" selectedImage:@"btn-highscores-selected.png" target:self selector:@selector(menuCallbackH:)];
	MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"btn-about-normal.png" selectedImage:@"btn-about-selected.png" target:self selector:@selector(menuCallbackV:)];
	
	Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
	
	menu.tag = kTagMenu;
	[menu alignItemsHorizontally];

	menu.opacity = 128;

	[self add: menu];

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) menuCallbackBack: (id) sender
{
	// One way to obtain the menu is:
	//    [self  getByTag:xxx]
	id menu = [self getByTag:kTagMenu];
	[menu setOpacity: 128];

	[(MultiplexLayer*)parent switchTo:0];
}

-(void) menuCallbackH: (id) sender
{
	// Another way to obtain the menu
	// in this particular case is:
	// self.parent

	id menu = [sender parent];
	[menu setOpacity: 255];
	[menu alignItemsHorizontally];
}
-(void) menuCallbackV: (id) sender
{
	id menu = [self getByTag:kTagMenu];
	[menu alignItemsVertically];

// XXX: this method is deprecated and will be removed in v0.7
//	[menu alignItemsVerticallyOld];

}

-(BOOL) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// you will only receive this message if Menu doesn't handle the touchesBegan event
	// new in v0.6
	NSLog(@"touches received");
	return kEventHandled;
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
	
	Menu *menu = [Menu menuWithItems: item1, item2, nil];	
	menu.position = cpv(0,0);
	
	item1.position = cpv(100,100);
	item2.position = cpv(100,200);
	
	id jump = [JumpBy actionWithDuration:3 position:cpv(400,0) height:50 jumps:4];
	[item2 do: [RepeatForever actionWithAction:
				 [Sequence actions: jump, [jump reverse], nil]
								   ]
	 ];
	
	[self add: menu];
	
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
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

	// show FPS
	[[Director sharedDirector] setDisplayFPS:YES];

	// multiple touches or not ?
//	[[Director sharedDirector] setMultipleTouchEnabled:YES];
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];	
		
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
