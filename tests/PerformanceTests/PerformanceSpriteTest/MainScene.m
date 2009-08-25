//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "MainScene.h"
#import "CocosNodePerformance.h"

enum {
	kMaxNodes = 5000,
	kNodesIncrease = 50,
};

enum {
	kTagInfoLayer = 1,
	kTagMainLayer = 2,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
		@"PerformanceTest1",
		@"PerformanceTest2",
		@"PerformanceTest3",
		@"PerformanceTest4",
		@"PerformanceTest5",
		@"PerformanceTest6",
		@"PerformanceTest7",
};

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark SubTest
@implementation SubTest

-(id) initWithSubTest:(int) subtest parent:(id)p
{
	if( (self=[super init]) ) {
		
		subtestNumber = subtest;
		parent = p;
		sheet = nil;
/*
 * Tests:
 * 1: 1 (32-bit) PNG sprite of 52 x 139
 * 2: 1 (32-bit) PNG Atlas sprite using 1 sprite of 52 x 139
 * 3: 1 (16-bit) PNG Atlas sprite using 1 sprite of 52 x 139
 * 4: 1 (4-bit) PVRTC Atlas sprite using 1 sprite of 52 x 139

 * 5: 14 (32-bit) PNG sprites of 85 x 121 each
 * 6: 14 (32-bit) PNG Atlassprites of 85 x 121 each
 * 7: 14 (16-bit) PNG Atlassprites of 85 x 121 each
 * 8: 14 (4-bit) PVRTC Atlassprites of 85 x 121 each
 
 * 9: 64 (32-bit) sprites of 32 x 32 each
 *10: 64 (32-bit) PNG AtlasSprites of 32 x 32 each
 *11: 64 (16-bit) PNG AtlasSprites of 32 x 32 each
 *12: 64 (4-bit) PVRTC AtlasSprites of 32 x 32 each
 */
		
		// purge textures
		TextureMgr *mgr = [TextureMgr sharedTextureMgr];
		[mgr removeTexture: [mgr addImage:@"grossinis_sister1.png"]];
		[mgr removeTexture: [mgr addImage:@"grossini_dance_atlas.png"]];
		[mgr removeTexture: [mgr addImage:@"spritesheet1.png"]];
		
		switch( subtestNumber) {
			case 1:
			case 5:
			case 9:
				break;
				///
			case 2:
				[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
				sheet = [AtlasSpriteManager spriteManagerWithFile:@"grossinis_sister1.png" capacity:100];
				[p addChild:sheet z:0];
				break;
			case 3:
				[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
				sheet = [AtlasSpriteManager spriteManagerWithFile:@"grossinis_sister1.png" capacity:100];
				[p addChild:sheet z:0];
				break;				
			case 4:
				sheet = [AtlasSpriteManager spriteManagerWithFile:@"grossinis_sister1.pvr" capacity:100];
				[p addChild:sheet z:0];
				break;
				
				///
			case 6:
				[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
				sheet = [AtlasSpriteManager spriteManagerWithFile:@"grossini_dance_atlas.png" capacity:100];
				[p addChild:sheet z:0];
				break;				
			case 7:
				[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
				sheet = [AtlasSpriteManager spriteManagerWithFile:@"grossini_dance_atlas.png" capacity:100];
				[p addChild:sheet z:0];
				break;								
			case 8:
				sheet = [AtlasSpriteManager spriteManagerWithFile:@"grossini_dance_atlas.pvr" capacity:100];
				[p addChild:sheet z:0];
				break;

				///
			case 10:
				[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
				sheet = [AtlasSpriteManager spriteManagerWithFile:@"spritesheet1.png" capacity:100];
				[p addChild:sheet z:0];
				break;
			case 11:
				[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA4444];
				sheet = [AtlasSpriteManager spriteManagerWithFile:@"spritesheet1.png" capacity:100];
				[p addChild:sheet z:0];
				break;				
			case 12:
				sheet = [AtlasSpriteManager spriteManagerWithFile:@"spritesheet1.pvr" capacity:100];
				[p addChild:sheet z:0];
				break;
				
			default:
				break;
		}
		
		[sheet retain];

		[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_Default];

	}
	
	return self;
}

- (void) dealloc
{
	[sheet release];
	[super dealloc];
}

-(id) createSpriteWithTag:(int)tag
{
	// create 
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];

	id sprite = nil;
	switch (subtestNumber) {
		case 1: {
			sprite = [Sprite spriteWithFile:@"grossinis_sister1.png"];
			[parent addChild:sprite z:0 tag:tag+100];
			break;
		}
		case 2:
		case 3: 
		case 4: {
			sprite = [AtlasSprite spriteWithRect:CGRectMake(0, 0, 52, 139) spriteManager:sheet];
			[sheet addChild:sprite z:0 tag:tag+100];
			break;
		}

		case 5:
		{
			int idx = (CCRANDOM_0_1() * 1400 / 100) + 1;
			sprite = [Sprite spriteWithFile: [NSString stringWithFormat:@"grossini_dance_%02d.png", idx]];
			[parent addChild:sprite z:0 tag:tag+100];
			break;
		}
		case 6:
		case 7:
		case 8:
		{
			int y,x;
			int r = (CCRANDOM_0_1() * 1400 / 100);
			
			y = r / 5;
			x = r % 5;

			x *= 85;
			y *= 121;
			sprite = [AtlasSprite spriteWithRect:CGRectMake(x,y,85,121) spriteManager:sheet];
			[sheet addChild:sprite z:0 tag:tag+100];
			break;
		}

		case 9:
		{
			int y,x;
			int r = (CCRANDOM_0_1() * 6400 / 100);
			
			y = r / 8;
			x = r % 8;
			
			sprite = [Sprite spriteWithFile: [NSString stringWithFormat:@"sprite-%d-%d.png", x, y]];
			[parent addChild:sprite z:0 tag:tag+100];
			break;
		}
			
		case 10:
		case 11:
		case 12:
		{
			int y,x;
			int r = (CCRANDOM_0_1() * 6400 / 100);
			
			y = r / 8;
			x = r % 8;
			
			x *= 32;
			y *= 32;
			sprite = [AtlasSprite spriteWithRect:CGRectMake(x,y,32,32) spriteManager:sheet];
			[sheet addChild:sprite z:0 tag:tag+100];
			break;
		}
			
		default:
			break;
	}
		
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_Default];

	return sprite;
}

-(void) removeByTag:(int) tag
{
	switch (subtestNumber) {
		case 1:
		case 5:
		case 9:
			[parent removeChildByTag:tag+100 cleanup:YES];
			break;
		case 2:
		case 3:
		case 4:
		case 6:
		case 7:
		case 8:
		case 10:
		case 11:
		case 12:
			[sheet removeChildAtIndex:tag cleanup:YES];
//			[sheet removeChildByTag:tag+100 cleanup:YES];
			break;
		default:
			break;
	}
}
@end


#pragma mark MainScene

@implementation MainScene

+(id) testWithSubTest:(int) subtest nodes:(int)nodes
{
	return [[[self alloc] initWithSubTest:subtest nodes:nodes] autorelease];
}

- (id)initWithSubTest:(int) asubtest nodes:(int)nodes
{
	if ((self = [super init]) != nil) {
		
		srandom(0);
		
		subtestNumber = asubtest;
		subTest = [[SubTest alloc] initWithSubTest:asubtest parent:self];

		CGSize s = [[Director sharedDirector] winSize];

		lastRenderedCount = 0;
		quantityNodes = 0;
		
		[MenuItemFont setFontSize:65];
		MenuItemFont *decrease = [MenuItemFont itemFromString: @" - " target:self selector:@selector(onDecrease:)];
		[decrease.label setColor:ccc3(0,200,20)];
		MenuItemFont *increase = [MenuItemFont itemFromString: @" + " target:self selector:@selector(onIncrease:)];
		[increase.label setColor:ccc3(0,200,20)];
		
		Menu *menu = [Menu menuWithItems: decrease, increase, nil];
		[menu alignItemsHorizontally];
		menu.position = ccp(s.width/2, s.height-65);
		[self addChild:menu z:1];
		
		Label *infoLabel = [Label labelWithString:@"0 nodes" fontName:@"Marker Felt" fontSize:30];
		[infoLabel setColor:ccc3(0,200,20)];
		infoLabel.position = ccp(s.width/2, s.height-90);
		[self addChild:infoLabel z:1 tag:kTagInfoLayer];
				
		
		// Next Prev Test
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		menu = [Menu menuWithItems:item1, item2, item3, nil];
		[menu alignItemsHorizontally];
		menu.position = ccp(s.width/2, 30);
		[self addChild: menu z:1];	
		
		// Sub Tests
		[MenuItemFont setFontSize:32];
		MenuItemFont  *itemF1 = [MenuItemFont itemFromString:@"1 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF2 = [MenuItemFont itemFromString:@"2 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF3 = [MenuItemFont itemFromString:@"3 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF4 = [MenuItemFont itemFromString:@"4 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF5 = [MenuItemFont itemFromString:@"5 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF6 = [MenuItemFont itemFromString:@"6 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF7 = [MenuItemFont itemFromString:@"7 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF8 = [MenuItemFont itemFromString:@"8 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF9 = [MenuItemFont itemFromString:@"9 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF10 = [MenuItemFont itemFromString:@"10 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF11 = [MenuItemFont itemFromString:@"11 " target:self selector:@selector(testNCallback:)];
		MenuItemFont  *itemF12 = [MenuItemFont itemFromString:@"12 " target:self selector:@selector(testNCallback:)];

		itemF1.tag = 1;
		itemF2.tag = 2;
		itemF3.tag = 3;
		itemF4.tag = 4;
		itemF5.tag = 5;
		itemF6.tag = 6;
		itemF7.tag = 7;
		itemF8.tag = 8;
		itemF9.tag = 9;
		itemF10.tag = 10;
		itemF11.tag = 11;
		itemF12.tag = 12;


		menu = [Menu menuWithItems:itemF1, itemF2, itemF3, itemF4, itemF5, itemF6, itemF7, itemF8, itemF9, itemF10, itemF11, itemF12, nil];
		
		int i=0;
		for( id child in [menu children] ) {
			if( i<4)
				[[child label] setColor:ccc3(200,20,20)];
			else if(i<8)
				[[child label] setColor:ccc3(0,200,20)];
			else
				[[child label] setColor:ccc3(0,20,200)];
			i++;
		}
		
		[menu alignItemsHorizontally];
		menu.position = ccp(s.width/2, 80);
		[self addChild:menu z:2];
		

		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:40];
		[self addChild:label z:1];
		[label setPosition: ccp(s.width/2, s.height-32)];
		[label setColor:ccc3(255,255,40)];

		
		while(quantityNodes < nodes )
			[self onIncrease:self];
	}
	
	return self;
}

-(NSString*) title
{
	return @"No title";
}

-(void) dealloc
{
	[subTest release];
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	id scene = [restartAction() testWithSubTest:subtestNumber nodes:quantityNodes];
	[s addChild:scene];

	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	id scene = [nextAction() testWithSubTest:subtestNumber nodes:quantityNodes];
	[s addChild:scene];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	id scene = [backAction() testWithSubTest:subtestNumber nodes:quantityNodes];
	[s addChild:scene];

	[[Director sharedDirector] replaceScene: s];
}

-(void) testNCallback:(id) sender
{
	subtestNumber = [sender tag];
	[self restartCallback:sender];
}

- (void)updateNodes
{
	if( quantityNodes != lastRenderedCount ) {

		Label *infoLabel = (Label *) [self getChildByTag:kTagInfoLayer];
		[infoLabel setString: [NSString stringWithFormat:@"%u nodes", quantityNodes] ];
		
		lastRenderedCount = quantityNodes;
	}
}

-(void) doTest:(id) sprite
{
	// override
}

-(void) onIncrease:(id) sender
{
	if( quantityNodes >= kMaxNodes)
		return;
	
	for( int i=0;i< kNodesIncrease;i++) {
		
		Sprite *sprite = [subTest createSpriteWithTag: quantityNodes];
		[self doTest:sprite];
		
		quantityNodes++;
	}
	
	[self updateNodes];
}

-(void) onDecrease:(id) sender
{
	if( quantityNodes <= 0 )
		return;
	
	for( int i=0;i < kNodesIncrease;i++) {
		quantityNodes--;
		[subTest removeByTag:quantityNodes];
	}
	
	[self updateNodes];
}

@end

#pragma mark Test 1

@implementation PerformanceTest1

-(NSString*) title
{
	return [NSString stringWithFormat:@"A (%d) position", subtestNumber];
}

-(void) doTest:(id) sprite
{
	[sprite performancePosition];
}
@end

#pragma mark Test 2
@implementation PerformanceTest2
-(NSString*) title
{
	return [NSString stringWithFormat:@"B (%d) scale", subtestNumber];
}
-(void) doTest:(id) sprite
{
	[sprite performanceScale];
}
@end

#pragma mark Test 3
@implementation PerformanceTest3
-(NSString*) title
{
	return [NSString stringWithFormat:@"C (%d) scale + rot", subtestNumber];
}

-(void) doTest:(id) sprite
{
	[sprite performanceRotationScale];
}
@end


#pragma mark Test 4
@implementation PerformanceTest4
-(NSString*) title
{
	return [NSString stringWithFormat:@"D (%d) 100%% out", subtestNumber];
}

-(void) doTest:(id) sprite
{
	[sprite performanceOut100];
}
@end

#pragma mark Test 5
@implementation PerformanceTest5
-(NSString*) title
{
	return [NSString stringWithFormat:@"E (%d) 80%% out", subtestNumber];
}

-(void) doTest:(id) sprite
{
	[sprite performanceout20];
}
@end

#pragma mark Test 6
@implementation PerformanceTest6
-(NSString*) title
{
	return [NSString stringWithFormat:@"F (%d) actions", subtestNumber];
}

-(void) doTest:(id) sprite
{
	[sprite performanceActions];
}
@end

#pragma mark Test 7
@implementation PerformanceTest7
-(NSString*) title
{
	return [NSString stringWithFormat:@"G (%d) actions 80%% out", subtestNumber];
}

-(void) doTest:(id) sprite
{
	[sprite performanceActions20];
}
@end


