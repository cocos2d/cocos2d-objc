//
// Menu Demo
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//


#import "MenuTest.h"

enum {
	kTagMenu = 1,
	kTagMenu0 = 0,
	kTagMenu1 = 1,
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
	BitmapFontAtlas *label = [BitmapFontAtlas bitmapFontAtlasWithString:@"configuration" fntFile:@"bitmapFontTest3.fnt"];
	MenuItemLabel *item5 = [MenuItemLabel itemWithLabel:label target:self selector:@selector(menuCallbackConfig:)];
	
	MenuItemFont *item6 = [MenuItemFont itemFromString: @"Quit" target:self selector:@selector(onQuit:)];
	
	id color_action = [TintBy actionWithDuration:0.5f red:0 green:-255 blue:-255];
	id color_back = [color_action reverse];
	id seq = [Sequence actions:color_action, color_back, nil];
	[item6 runAction:[RepeatForever actionWithAction:seq]];

	Menu *menu = [Menu menuWithItems: item1, item2, item3, item4, item5, item6, nil];
	[menu alignItemsVertically];

	disabledItem = [item3 retain];
	disabledItem.isEnabled = NO;

	[self addChild: menu];

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

-(void) menuCallbackConfig:(id) sender
{
	[(MultiplexLayer*)parent switchTo:3];
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
	
	// HA HA... no more terminate on sdk v3.0
	// http://developer.apple.com/iphone/library/qa/qa2008/qa1561.html
	if( [[UIApplication sharedApplication] respondsToSelector:@selector(terminate)] )
		[[UIApplication sharedApplication] performSelector:@selector(terminate)];
}
@end

@implementation Layer2

-(void) alignMenusH
{
	for(int i=0;i<2;i++) {
		Menu *menu = (Menu*)[self getChildByTag:100+i];
		menu.position = centeredMenu;
		if(i==0) {
			// TIP: if no padding, padding = 5
			[menu alignItemsHorizontally];			
			CGPoint p = menu.position;
			menu.position = ccpAdd(p, ccp(0,30));
			
		} else {
			// TIP: but padding is configurable
			[menu alignItemsHorizontallyWithPadding:40];
			CGPoint p = menu.position;
			menu.position = ccpSub(p, ccp(0,30));
		}		
	}
}

-(void) alignMenusV
{
	for(int i=0;i<2;i++) {
		Menu *menu = (Menu*)[self getChildByTag:100+i];
		menu.position = centeredMenu;
		if(i==0) {
			// TIP: if no padding, padding = 5
			[menu alignItemsVertically];			
			CGPoint p = menu.position;
			menu.position = ccpAdd(p, ccp(100,0));			
		} else {
			// TIP: but padding is configurable
			[menu alignItemsVerticallyWithPadding:40];	
			CGPoint p = menu.position;
			menu.position = ccpSub(p, ccp(100,0));
		}		
	}
}

-(id) init
{
	if( (self=[super init]) ) {
	
		isTouchEnabled = YES;
		
		for( int i=0;i < 2;i++ ) {
			MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png" target:self selector:@selector(menuCallbackBack:)];
			MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"btn-highscores-normal.png" selectedImage:@"btn-highscores-selected.png" target:self selector:@selector(menuCallbackOpacity:)];
			MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"btn-about-normal.png" selectedImage:@"btn-about-selected.png" target:self selector:@selector(menuCallbackAlign:)];
			
			item1.scaleX = 1.5f;
			item2.scaleY = 0.5f;
			item3.scaleX = 0.5f;
			
			Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
			
			menu.tag = kTagMenu;
			
			[self addChild:menu z:0 tag:100+i];
			centeredMenu = menu.position;
		}

		alignedH = YES;
		[self alignMenusH];
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) menuCallbackBack: (id) sender
{
	[(MultiplexLayer*)parent switchTo:0];
}

-(void) menuCallbackOpacity: (id) sender
{
	id menu = [sender parent];
	GLubyte opacity = [menu opacity];
	if( opacity == 128 )
		[menu setOpacity: 255];
	else
		[menu setOpacity: 128];	
}
-(void) menuCallbackAlign: (id) sender
{
	alignedH = ! alignedH;
	
	if( alignedH )
		[self alignMenusH];
	else
		[self alignMenusV];
}

@end

@implementation Layer3
-(id) init
{
	[super init];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:28];

	BitmapFontAtlas *label = [BitmapFontAtlas bitmapFontAtlasWithString:@"another option" fntFile:@"bitmapFontTest3.fnt"];
	MenuItemLabel *item1 = [MenuItemLabel itemWithLabel:label target:self selector:@selector(menuCallback2:)];
	MenuItemFont *item2 = [MenuItemFont itemFromString: @"--- Go Back ---" target:self selector:@selector(menuCallback:)];
	
	Menu *menu = [Menu menuWithItems: item1, item2, nil];	
	menu.position = ccp(0,0);
	
	item1.position = ccp(100,100);
	item2.position = ccp(100,200);
	
	id jump = [JumpBy actionWithDuration:3 position:ccp(400,0) height:50 jumps:4];
	[item2 runAction: [RepeatForever actionWithAction:
				 [Sequence actions: jump, [jump reverse], nil]
								   ]
	 ];
	id spin1 = [RotateBy actionWithDuration:3 angle:360];
	id spin2 = [[spin1 copy] autorelease];
	
	[item1 runAction: [RepeatForever actionWithAction:spin1]];
	[item2 runAction: [RepeatForever actionWithAction:spin2]];
	
	[self addChild: menu];
	
	
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


@implementation Layer4
-(id) init
{
	[super init];

	[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:18];
	MenuItemFont *title1 = [MenuItemFont itemFromString: @"Sound"];
    [title1 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item1 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"On"],
                             [MenuItemFont itemFromString: @"Off"],
                             nil];
    
	[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:18];
	MenuItemFont *title2 = [MenuItemFont itemFromString: @"Music"];
    [title2 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item2 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"On"],
                             [MenuItemFont itemFromString: @"Off"],
                             nil];
    
	[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:18];
	MenuItemFont *title3 = [MenuItemFont itemFromString: @"Quality"];
    [title3 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item3 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"High"],
                             [MenuItemFont itemFromString: @"Low"],
                             nil];
    
	[MenuItemFont setFontName: @"American Typewriter"];
	[MenuItemFont setFontSize:18];
	MenuItemFont *title4 = [MenuItemFont itemFromString: @"Orientation"];
    [title4 setIsEnabled:NO];
	[MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
    MenuItemToggle *item4 = [MenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [MenuItemFont itemFromString: @"Off"], nil];
	
	NSArray *more_items = [NSArray arrayWithObjects:
                             [MenuItemFont itemFromString: @"33%"],
                             [MenuItemFont itemFromString: @"66%"],
                             [MenuItemFont itemFromString: @"100%"],
                             nil];
	// TIP: you can manipulate the items like any other NSMutableArray
	[item4.subItems addObjectsFromArray: more_items];
	
    // you can change the one of the items by doing this
    item4.selectedIndex = 2;
    
    [MenuItemFont setFontName: @"Marker Felt"];
	[MenuItemFont setFontSize:34];
	
	BitmapFontAtlas *label = [BitmapFontAtlas bitmapFontAtlasWithString:@"go back" fntFile:@"bitmapFontTest3.fnt"];
	MenuItemLabel *back = [MenuItemLabel itemWithLabel:label target:self selector:@selector(backCallback:)];
    
	Menu *menu = [Menu menuWithItems:
                  title1, title2,
                  item1, item2,
                  title3, title4,
                  item3, item4,
                  back, nil]; // 9 items.
    [menu alignItemsInColumns:
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:1],
     nil
    ]; // 2 + 2 + 2 + 2 + 1 = total count of 9.
    
	[self addChild: menu];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) menuCallback: (id) sender
{
	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
}

-(void) backCallback: (id) sender
{
	[(MultiplexLayer*)parent switchTo:0];
}

@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation: CCDeviceOrientationLandscapeRight];

	// show FPS
	[[Director sharedDirector] setDisplayFPS:YES];

	// multiple touches or not ?
//	[[Director sharedDirector] setMultipleTouchEnabled:YES];
	
	// frames per second
	[[Director sharedDirector] setAnimationInterval:1.0/60];	

	// attach cocos2d to a window
	[[Director sharedDirector] attachInView:window];

	Scene *scene = [Scene node];

	MultiplexLayer *layer = [MultiplexLayer layerWithLayers: [Layer1 node], [Layer2 node], [Layer3 node], [Layer4 node], nil];
	[scene addChild: layer z:0];

	[window makeKeyAndVisible];
	[[Director sharedDirector] runWithScene: scene];
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

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window dealloc];
	[super dealloc];
}

@end
