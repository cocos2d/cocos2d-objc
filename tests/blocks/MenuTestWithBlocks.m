//
// Menu Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//


#import "MenuTestWithBlocks.h"

enum {
	kTagMenu = 1,
	kTagMenu0 = 0,
	kTagMenu1 = 1,
};

#pragma mark -
#pragma mark MainMenu
@implementation Layer1
-(id) init
{
	if( (self=[super init])) {
		[CCMenuItemFont setFontSize:30];
		[CCMenuItemFont setFontName: @"Courier New"];
		
		// Font Item
		
		CCSprite *spriteNormal = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*2,115,23)];
		CCSprite *spriteSelected = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*1,115,23)];
		CCSprite *spriteDisabled = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*0,115,23)];
		
		// Demonstrates reusing a block for multiple menu items, when it's using the CCLayerMultiplex to switch views.
		__block Layer1* _self = self;
		void (^reusableBlock)(id) = ^(id sender) {
			[(CCLayerMultiplex*)_self->parent_ switchTo:[sender tag]];
		};
		
		CCMenuItemSprite *item1 = [CCMenuItemSprite itemFromNormalSprite:spriteNormal selectedSprite:spriteSelected disabledSprite:spriteDisabled block:reusableBlock];
		item1.tag = 1;
		// Image Item
		CCMenuItem *item2 = [CCMenuItemImage itemFromNormalImage:@"SendScoreButton.png" selectedImage:@"SendScoreButtonPressed.png" block:reusableBlock];
		item2.tag = 2;
		
		// Label Item (LabelAtlas)
		CCLabelAtlas *labelAtlas = [CCLabelAtlas labelWithString:@"0123456789" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
		CCMenuItemLabel *item3 = [CCMenuItemLabel itemWithLabel:labelAtlas target:self selector:@selector(menuCallbackDisabled:)];
		item3.disabledColor = ccc3(32,32,64);
		item3.color = ccc3(200,200,255);
		
		
		// Font Item
		CCMenuItem *item4 = [CCMenuItemFont itemFromString: @"I toggle enable items" block:^(id sender){
			_self->disabledItem.isEnabled = ~_self->disabledItem.isEnabled;
		}];
		
		// Label Item (CCLabelBMFont)
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"configuration" fntFile:@"bitmapFontTest3.fnt"];
		CCMenuItemLabel *item5 = [CCMenuItemLabel itemWithLabel:label block:reusableBlock];
		item5.tag = 3;
		
		// Font Item
		CCMenuItemFont *item6 = [CCMenuItemFont itemFromString: @"Quit" block:^(id sender){
			[[CCDirector sharedDirector] end];
			
			// HA HA... no more terminate on sdk v3.0
			// http://developer.apple.com/iphone/library/qa/qa2008/qa1561.html
			if( [[UIApplication sharedApplication] respondsToSelector:@selector(terminate)] )
				[[UIApplication sharedApplication] performSelector:@selector(terminate)];
			else
				NSLog(@"YOU CAN'T TERMINATE YOUR APPLICATION PROGRAMATICALLY in SDK 3.0+");
		}];
		
		id color_action = [CCTintBy actionWithDuration:0.5f red:0 green:-255 blue:-255];
		id color_back = [color_action reverse];
		id seq = [CCSequence actions:color_action, color_back, nil];
		[item6 runAction:[CCRepeatForever actionWithAction:seq]];
		
		CCMenu *menu = [CCMenu menuWithItems: item1, item2, item3, item4, item5, item6, nil];
		[menu alignItemsVertically];
		
		
		// elastic effect
		CGSize s = [[CCDirector sharedDirector] winSize];
		int i=0;
		for( CCNode *child in [menu children] ) {
			CGPoint dstPoint = child.position;
			int offset = s.width/2 + 50;
			if( i % 2 == 0)
				offset = -offset;
			child.position = ccp( dstPoint.x + offset, dstPoint.y);
			[child runAction: 
			 [CCEaseElasticOut actionWithAction:
			  [CCMoveBy actionWithDuration:2 position:ccp(dstPoint.x - offset,0)]
										 period: 0.35f]
			 ];
			i++;
		}
		
		disabledItem = [item3 retain];
		disabledItem.isEnabled = NO;
		
		[self addChild: menu];
	}
	
	return self;
}

-(void) dealloc
{
	[disabledItem release];
	[super dealloc];
}

-(void) menuCallbackDisabled:(id) sender {
}

@end

#pragma mark -
#pragma mark StartMenu

@implementation Layer2

-(void) alignMenusH
{
	for(int i=0;i<2;i++) {
		CCMenu *menu = (CCMenu*)[self getChildByTag:100+i];
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
		CCMenu *menu = (CCMenu*)[self getChildByTag:100+i];
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
		
		for( int i=0;i < 2;i++ ) {
			CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png" block:^(id sender){
				[(CCLayerMultiplex*)parent_ switchTo:0];
			}];
			
			CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"btn-highscores-normal.png" selectedImage:@"btn-highscores-selected.png" block:^(id sender){
				CCMenu *menu = (CCMenu*)[sender parent];
				GLubyte opacity = [menu opacity];
				if( opacity == 128 )
					[menu setOpacity: 255];
				else
					[menu setOpacity: 128];
			}];

			CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"btn-about-normal.png" selectedImage:@"btn-about-selected.png" block:^(id sender){
				alignedH = ! alignedH;
				
				if( alignedH )
					[self alignMenusH];
				else
					[self alignMenusV];
			}];
			
			item1.scaleX = 1.5f;
			item2.scaleY = 0.5f;
			item3.scaleX = 0.5f;
			
			CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
			
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

@end

#pragma mark -
#pragma mark SendScores

@implementation Layer3
-(id) init
{
	if( (self=[super init])) {
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:28];
		
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Enable AtlasItem" fntFile:@"bitmapFontTest3.fnt"];
		CCMenuItemLabel *item1 = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(menuCallback2:)];
		CCMenuItemFont *item2 = [CCMenuItemFont itemFromString: @"--- Go Back ---" target:self selector:@selector(menuCallback:)];
		
		CCSprite *spriteNormal = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*2,115,23)];
		CCSprite *spriteSelected = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*1,115,23)];
		CCSprite *spriteDisabled = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*0,115,23)];
		
		CCMenuItemSprite *item3 = [CCMenuItemSprite itemFromNormalSprite:spriteNormal selectedSprite:spriteSelected disabledSprite:spriteDisabled target:self selector:@selector(menuCallback3:)];
		disabledItem = item3;
		disabledItem.isEnabled = NO;
		
		CCMenu *menu = [CCMenu menuWithItems: item1, item2, item3, nil];	
		menu.position = ccp(0,0);
		
		item1.position = ccp(100,100);
		item2.position = ccp(100,200);
		item3.position = ccp(350,100);
		
		id jump = [CCJumpBy actionWithDuration:3 position:ccp(400,0) height:50 jumps:4];
		[item2 runAction: [CCRepeatForever actionWithAction:
						   [CCSequence actions: jump, [jump reverse], nil]
						   ]
		 ];
		id spin1 = [CCRotateBy actionWithDuration:3 angle:360];
		id spin2 = [[spin1 copy] autorelease];
		id spin3 = [[spin1 copy] autorelease];
		
		[item1 runAction: [CCRepeatForever actionWithAction:spin1]];
		[item2 runAction: [CCRepeatForever actionWithAction:spin2]];
		[item3 runAction: [CCRepeatForever actionWithAction:spin3]];
		
		[self addChild: menu];
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) menuCallback: (id) sender
{
	[(CCLayerMultiplex*)parent_ switchTo:0];
}

-(void) menuCallback2: (id) sender
{
	NSLog(@"Label clicked. Toogling Sprite");
	disabledItem.isEnabled = ~disabledItem.isEnabled;
	[disabledItem stopAllActions];
}
-(void) menuCallback3:(id) sender
{
	NSLog(@"MenuItemSprite clicked");
}

@end


@implementation Layer4
-(id) init
{
	if ( (self=[super init]) ) {
	
		[CCMenuItemFont setFontName: @"American Typewriter"];
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *title1 = [CCMenuItemFont itemFromString: @"Sound"];
		[title1 setIsEnabled:NO];
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		CCMenuItemToggle *item1 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
								   [CCMenuItemFont itemFromString: @"On"],
								   [CCMenuItemFont itemFromString: @"Off"],
								   nil];
		
		[CCMenuItemFont setFontName: @"American Typewriter"];
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *title2 = [CCMenuItemFont itemFromString: @"Music"];
		[title2 setIsEnabled:NO];
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		CCMenuItemToggle *item2 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
								   [CCMenuItemFont itemFromString: @"On"],
								   [CCMenuItemFont itemFromString: @"Off"],
								   nil];
		
		[CCMenuItemFont setFontName: @"American Typewriter"];
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *title3 = [CCMenuItemFont itemFromString: @"Quality"];
		[title3 setIsEnabled:NO];
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		CCMenuItemToggle *item3 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
								   [CCMenuItemFont itemFromString: @"High"],
								   [CCMenuItemFont itemFromString: @"Low"],
								   nil];
		
		[CCMenuItemFont setFontName: @"American Typewriter"];
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *title4 = [CCMenuItemFont itemFromString: @"Orientation"];
		[title4 setIsEnabled:NO];
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		CCMenuItemToggle *item4 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
								   [CCMenuItemFont itemFromString: @"Off"], nil];
		
		NSArray *more_items = [NSArray arrayWithObjects:
							   [CCMenuItemFont itemFromString: @"33%"],
							   [CCMenuItemFont itemFromString: @"66%"],
							   [CCMenuItemFont itemFromString: @"100%"],
							   nil];
		// TIP: you can manipulate the items like any other NSMutableArray
		[item4.subItems addObjectsFromArray: more_items];
		
		// you can change the one of the items by doing this
		item4.selectedIndex = 2;
		
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"go back" fntFile:@"bitmapFontTest3.fnt"];
		CCMenuItemLabel *back = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(backCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:
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
	}
	
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
	[(CCLayerMultiplex*)parent_ switchTo:0];
}

@end



// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// must be called before any othe call to the director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeMainLoop];
	
	// get instance of the shared director
	CCDirector *director = [CCDirector sharedDirector];
	
	// before creating any layer, set the landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// display FPS (useful when debugging)
	[director setDisplayFPS:YES];
	
	// frames per second
	[director setAnimationInterval:1.0/60];
	
	// create an OpenGL view
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]];
	
	// enable multiple touches
//	[glView setMultipleTouchEnabled:YES];
	
	// connect it to the director
	[director setOpenGLView:glView];
	
	// glview is a child of the main window
	[window addSubview:glView];
	
	// Make the window visible
	[window makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];	
	
	CCScene *scene = [CCScene node];
	
	CCLayerMultiplex *layer = [CCLayerMultiplex layerWithLayers: [Layer1 node], [Layer2 node], [Layer3 node], [Layer4 node], nil];
	[scene addChild: layer z:0];
	
	[director runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{	
	[[CCDirector sharedDirector] end];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
