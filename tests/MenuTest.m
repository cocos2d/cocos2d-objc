//
// Menu Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//


#import "MenuTest.h"

enum {
	kTagMenu = 1,
	kTagMenu0 = 0,
	kTagMenu1 = 1,
};

#pragma mark - MainMenu

@implementation LayerMainMenu
-(id) init
{
	if( (self=[super init])) {

#ifdef __CC_PLATFORM_IOS
        self.isTouchEnabled = YES;
#endif
		// Font Item

		CCSprite *spriteNormal = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*2,115,23)];
		CCSprite *spriteSelected = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*1,115,23)];
		CCSprite *spriteDisabled = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*0,115,23)];
		CCMenuItemSprite *item1 = [CCMenuItemSprite itemWithNormalSprite:spriteNormal selectedSprite:spriteSelected disabledSprite:spriteDisabled block:^(id sender) {
				CCScene *scene = [CCScene node];
				[scene addChild:[Layer2 node]];
				[[CCDirector sharedDirector] replaceScene:scene];
		}];

		// Image Item
		CCMenuItem *item2 = [CCMenuItemImage itemWithNormalImage:@"SendScoreButton.png" selectedImage:@"SendScoreButtonPressed.png" block:^(id sender) {
				CCScene *scene = [CCScene node];
				[scene addChild:[Layer3 node]];
				[[CCDirector sharedDirector] replaceScene:scene];
		}];

		// Label Item (LabelAtlas)
		CCLabelAtlas *labelAtlas = [CCLabelAtlas labelWithString:@"0123456789" charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
		CCMenuItemLabel *item3 = [CCMenuItemLabel itemWithLabel:labelAtlas block:^(id sender) {
			// hijack all touch events for 5 seconds
			CCDirector *director = [CCDirector sharedDirector];
#ifdef __CC_PLATFORM_IOS
			[[director touchDispatcher] setPriority:kCCMenuHandlerPriority-1 forDelegate:self];
			[self schedule:@selector(allowTouches) interval:5.0f repeat:0 delay:0];
#elif defined(__CC_PLATFORM_MAC)
			[[director eventDispatcher] addMouseDelegate:self priority:kCCMenuHandlerPriority-1];
			[self schedule:@selector(allowTouches) interval:5.0f];
#endif
				NSLog(@"TOUCHES DISABLED FOR 5 SECONDS");
		}];

		item3.disabledColor = ccc3(32,32,64);
		item3.color = ccc3(200,200,255);


		// Font Item
		CCMenuItemFont *item4 = [CCMenuItemFont itemWithString: @"I toggle enable items" block:^(id sender) {
			// IMPORTANT: It is safe to use "self" because CCMenuItem#cleanup will break any possible circular reference.
			self->disabledItem.isEnabled = ~self->disabledItem.isEnabled;
		}];

		[item4 setFontSize:20];
		[item4 setFontName:@"Marker Felt"];

		// Label Item (CCLabelBMFont)
		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"configuration" fntFile:@"bitmapFontTest3.fnt"];
		CCMenuItemLabel *item5 = [CCMenuItemLabel itemWithLabel:label block:^(id sender) {
			CCScene *scene = [CCScene node];
			[scene addChild:[Layer4 node]];
			[[CCDirector sharedDirector] replaceScene:scene];
		}];

		// Testing issue #500
		item5.scale = 0.8f;

		// Events
		[CCMenuItemFont setFontName: @"Marker Felt"];
		CCMenuItemFont *item6 = [CCMenuItemFont itemWithString:@"Priority Test" block:^(id sender) {
			CCScene *scene = [CCScene node];
			[scene addChild:[LayerPriorityTest node]];
			[[CCDirector sharedDirector] pushScene:scene];			
		}];
		
		// Font Item
		[CCMenuItemFont setFontSize:30];
		[CCMenuItemFont setFontName: @"Courier New"];
		CCMenuItemFont *item7 = [CCMenuItemFont itemWithString: @"Quit" block:^(id sender){
			CC_DIRECTOR_END();
		}];

		id color_action = [CCTintBy actionWithDuration:0.5f red:0 green:-255 blue:-255];
		id color_back = [color_action reverse];
		id seq = [CCSequence actions:color_action, color_back, nil];
		[item7 runAction:[CCRepeatForever actionWithAction:seq]];

		CCMenu *menu = [CCMenu menuWithItems: item1, item2, item3, item4, item5, item6, item7, nil];
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
		[menu setPosition:ccp(s.width/2, s.height/2)];
	}

	return self;
}

#ifdef __CC_PLATFORM_IOS
-(void) registerWithTouchDispatcher
{
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:kCCMenuHandlerPriority+1 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

#elif defined(__CC_PLATFORM_MAC)
-(BOOL) ccMouseDown:(NSEvent *)event
{
	return YES;
}
-(BOOL) ccMouseUp:(NSEvent *)event
{
	return YES;
}

-(BOOL) ccMouseMoved:(NSEvent *)event
{
	return YES;
}
-(BOOL) ccMouseDragged:(NSEvent *)event
{
	return YES;
}
#endif // __CC_PLATFORM_MAC

-(void) dealloc
{
	[disabledItem release];
	[super dealloc];
}

-(void) allowTouches
{
	CCDirector *director = [CCDirector sharedDirector];
#ifdef __CC_PLATFORM_IOS
    [[director touchDispatcher] setPriority:kCCMenuHandlerPriority+1 forDelegate:self];
    [self unscheduleAllSelectors];

#elif defined(__CC_PLATFORM_MAC)
    [[director eventDispatcher] removeMouseDelegate:self];
#endif

	NSLog(@"TOUCHES ALLOWED AGAIN");
}
@end

#pragma mark - StartMenu

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

	}

	return self;
}

// Testing issue #1018 and #1021
-(void) onEnter
{
	[super onEnter];

	// remove previously added children
	[self removeAllChildrenWithCleanup:YES];

	for( int i=0;i < 2;i++ ) {
		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"btn-play-normal.png" selectedImage:@"btn-play-selected.png" target:self selector:@selector(menuCallbackBack:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"btn-highscores-normal.png" selectedImage:@"btn-highscores-selected.png" target:self selector:@selector(menuCallbackOpacity:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"btn-about-normal.png" selectedImage:@"btn-about-selected.png" target:self selector:@selector(menuCallbackAlign:)];

		item1.scaleX = 1.5f;
		item2.scaleY = 0.5f;
		item3.scaleX = 0.5f;

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];

		CGSize s = [[CCDirector sharedDirector] winSize];
		[menu setPosition:ccp(s.width/2, s.height/2)];

		menu.tag = kTagMenu;

		[self addChild:menu z:0 tag:100+i];
		centeredMenu = menu.position;
	}

	alignedH = YES;
	[self alignMenusH];
}

-(void) dealloc
{
	[super dealloc];
}

-(void) menuCallbackBack: (id) sender
{
	CCScene *scene = [CCScene node];
	[scene addChild:[LayerMainMenu node]];
	[[CCDirector sharedDirector] replaceScene:scene];
}

-(void) menuCallbackOpacity: (id) sender
{
	CCMenu *menu = (CCMenu*) [sender parent];
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

#pragma mark - SendScores

@implementation Layer3
-(id) init
{
	if( (self=[super init]) ) {
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:28];

		CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Enable AtlasItem" fntFile:@"bitmapFontTest3.fnt"];
		CCMenuItemLabel *item1 = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(menuCallback2:)];
		CCMenuItemFont *item2 = [CCMenuItemFont itemWithString: @"--- Go Back ---" target:self selector:@selector(menuCallback:)];

		CCSprite *spriteNormal = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*2,115,23)];
		CCSprite *spriteSelected = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*1,115,23)];
		CCSprite *spriteDisabled = [CCSprite spriteWithFile:@"menuitemsprite.png" rect:CGRectMake(0,23*0,115,23)];

		CCMenuItemSprite *item3 = [CCMenuItemSprite itemWithNormalSprite:spriteNormal selectedSprite:spriteSelected disabledSprite:spriteDisabled target:self selector:@selector(menuCallback3:)];
		disabledItem = item3;
		disabledItem.isEnabled = NO;

		CCMenu *menu = [CCMenu menuWithItems: item1, item2, item3, nil];

		CGSize s = [[CCDirector sharedDirector] winSize];

		item1.position = ccp(s.width/2 - 150, s.height/2);
		item2.position = ccp(s.width/2 - 200, s.height/2);
		item3.position = ccp(s.width/2, s.height/2 - 100);

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
		[menu setPosition:ccp(0,0)];

	}

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) menuCallback: (id) sender
{
	CCScene *scene = [CCScene node];
	[scene addChild:[LayerMainMenu node]];
	[[CCDirector sharedDirector] replaceScene:scene];
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

#pragma mark - Layer4

@implementation Layer4
-(id) init
{
	if( (self = [super init] ) ) {

		[CCMenuItemFont setFontName: @"American Typewriter"];
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *title1 = [CCMenuItemFont itemWithString: @"Sound"];
		[title1 setIsEnabled:NO];
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		CCMenuItemToggle *item1 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
								 [CCMenuItemFont itemWithString: @"On"],
								 [CCMenuItemFont itemWithString: @"Off"],
								 nil];

		[CCMenuItemFont setFontName: @"American Typewriter"];
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *title2 = [CCMenuItemFont itemWithString: @"Music"];
		[title2 setIsEnabled:NO];
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		CCMenuItemToggle *item2 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
								 [CCMenuItemFont itemWithString: @"On"],
								 [CCMenuItemFont itemWithString: @"Off"],
								 nil];

		[CCMenuItemFont setFontName: @"American Typewriter"];
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *title3 = [CCMenuItemFont itemWithString: @"Quality"];
		[title3 setIsEnabled:NO];
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		CCMenuItemToggle *item3 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
								 [CCMenuItemFont itemWithString: @"High"],
								 [CCMenuItemFont itemWithString: @"Low"],
								 nil];

		[CCMenuItemFont setFontName: @"American Typewriter"];
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *title4 = [CCMenuItemFont itemWithString: @"Orientation"];
		[title4 setIsEnabled:NO];
		[CCMenuItemFont setFontName: @"Marker Felt"];
		[CCMenuItemFont setFontSize:34];
		CCMenuItemToggle *item4 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
								 [CCMenuItemFont itemWithString: @"Off"], nil];

		NSArray *more_items = [NSArray arrayWithObjects:
								 [CCMenuItemFont itemWithString: @"33%"],
								 [CCMenuItemFont itemWithString: @"66%"],
								 [CCMenuItemFont itemWithString: @"100%"],
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
		CGSize s = [[CCDirector sharedDirector] winSize];
		[menu setPosition:ccp(s.width/2, s.height/2)];
	}

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) menuCallback: (id) sender
{
	NSLog(@"selected item: %@ index:%u", [sender selectedItem], (unsigned int) [sender selectedIndex] );
}

-(void) backCallback: (id) sender
{
	CCScene *scene = [CCScene node];
	[scene addChild:[LayerMainMenu node]];
	[[CCDirector sharedDirector] replaceScene:scene];
}

@end

#pragma mark - LayerPriorityTest

@implementation LayerPriorityTest
-(id) init
{
	if( (self = [super init] ) ) {
		
		// Testing empty menu
		CCMenu *menu1 = [CCMenu node];
		CCMenu *menu2 = [CCMenu node];
		
		
		// Menu 1
		[CCMenuItemFont setFontName:@"Marker Felt"];
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Return to Main Menu" block:^(id sender) {
			[[CCDirector sharedDirector] popScene];
		}];

		CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Disable menu for 5 seconds" block:^(id sender) {
			[menu1 setEnabled:NO];
			CCDelayTime *wait = [CCDelayTime actionWithDuration:5];
			CCCallBlockO *enable = [CCCallBlockO actionWithBlock:^(id object) {
				[object setEnabled:YES];
			}object:menu1];
			CCSequence *seq = [CCSequence actions:wait, enable, nil];
			[menu1 runAction:seq];
		}];

		
		[menu1 addChild:item1];
		[menu1 addChild:item2];
		
		[menu1 alignItemsVerticallyWithPadding:2];
		
		[self addChild:menu1];
		
		
		// Menu 2
		static BOOL priority = 1;
		[CCMenuItemFont setFontSize:48];
		item1 = [CCMenuItemFont itemWithString:@"Toggle priority" block:^(id sender) {
			if( priority == 1) {
				[menu2 setHandlerPriority:kCCMenuHandlerPriority + 20];
				priority = 0;
			} else {
				[menu2 setHandlerPriority:kCCMenuHandlerPriority - 20];
				priority = 1;
			}
		}];
		[item1 setColor:ccc3(0,0,255)];
		[menu2 addChild:item1];
		[self addChild:menu2];
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

@end





// CLASS IMPLEMENTATIONS

#pragma mark - AppController - iOS

#ifdef __CC_PLATFORM_IOS

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// display FPS (useful when debugging)
	[director_ setDisplayStats:YES];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found, then the fallback suffixes are going to used. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];			// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	CCScene *scene = [CCScene node];

	[scene addChild: [LayerMainMenu node]];
	[director_ pushScene: scene];

	return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// supports all 4 orientations
	return YES;
}
@end

#pragma mark - AppController - Mac

#elif defined(__CC_PLATFORM_MAC)

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];

	CCScene *scene = [[CCScene alloc] init];
	
	id layer = [[LayerMainMenu alloc] init];
	[scene addChild:layer];
	[layer release];

	[director_ runWithScene:scene];	
	[scene release];
}
@end
#endif
