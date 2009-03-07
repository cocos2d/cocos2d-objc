//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "MainScene.h"
#import "CocosNodePerformance.h"

enum {
	kMaxNodes = 2000,
	kNodesIncrease = 10,
};

enum {
	kTagInfoLayer = 1,
	kTagMainLayer = 2,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
		@"PerformanceTest1",
		@"PerformanceTest2",
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


@implementation MainScene

- (id)init
{
	if ((self = [super init]) != nil) {
		
		CGSize s = [[Director sharedDirector] winSize];

		lastRenderedCount = 0;
		quantityNodes = 0;
		
		[MenuItemFont setFontSize:65];
		MenuItemFont *decrease = [MenuItemFont itemFromString: @" - " target:self selector:@selector(onDecrease:)];
		[decrease.label setRGB:0 :200 :20];
		MenuItemFont *increase = [MenuItemFont itemFromString: @" + " target:self selector:@selector(onIncrease:)];
		[increase.label setRGB:0 :200 :20];
		
		Menu *menu = [Menu menuWithItems: decrease, increase, nil];
		[menu alignItemsHorizontally];
		menu.position = cpv(s.width/2, s.height-40);
		[self add:menu z:1];
		
		Label *infoLabel = [Label labelWithString:@"" fontName:@"Marker Felt" fontSize:30];
		[infoLabel setRGB:0 :200 :20];
		infoLabel.position = cpv(s.width/2, s.height-80);
		[self add:infoLabel z:1 tag:kTagInfoLayer];
				
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		menu = [Menu menuWithItems:item1, item2, item3, nil];
		

		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self add: label];
		[label setPosition: cpv(s.width/2, s.height-50)];
		
		menu.position = cpvzero;
		item1.position = cpv( s.width/2 - 100,30);
		item2.position = cpv( s.width/2, 30);
		item3.position = cpv( s.width/2 + 100,30);
		[self add: menu z:1];	
		
	}
	
	return self;
}

-(NSString*) title
{
	return @"No title";
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s add: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

- (void)updateNodes
{
	if( quantityNodes != lastRenderedCount ) {

		Label *infoLabel = (Label *) [self getByTag:kTagInfoLayer];
		[infoLabel setString: [NSString stringWithFormat:@"%u nodes", quantityNodes] ];
		
		lastRenderedCount = quantityNodes;
	}
}

@end

#pragma mark PerformanceTest1

@implementation PerformanceTest1

-(NSString*) title
{
	return @"Sprite performance";
}
-(void) onIncrease:(id) sender
{
	if( quantityNodes >= kMaxNodes)
		return;
	
	for( int i=0;i< kNodesIncrease;i++) {
		Sprite *sprite = [Sprite spriteWithFile:@"grossinis_sister1.png"];

		[self add:sprite z:0 tag:quantityNodes + 100];
		[sprite initPerformance];
		
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
		[self removeByTag:quantityNodes + 100];
	}
	
	[self updateNodes];
}
@end

#pragma mark PerformanceTest2
@implementation PerformanceTest2
-(id) init
{
	if( (self=[super init]) )
	{
		spriteManager = [AtlasSpriteManager spriteManagerWithFile:@"grossini_dance_atlas.png"];
		[self add:spriteManager];
	}
	return self;
}

- (void) dealloc
{
	[spriteManager release];
	[super dealloc];
}

-(NSString*) title
{
	return @"AtlasSprite performance";
}
-(void) onIncrease:(id) sender
{
	if( quantityNodes >= kMaxNodes)
		return;
	
	for( int i=0;i< kNodesIncrease;i++) {
		int x = CCRANDOM_0_1() * 70 / 10;
		int y = CCRANDOM_0_1() * 20 / 10;
		x *= 85;
		y *= 121;
		
		AtlasSprite *sprite = [spriteManager createSpriteWithRect:CGRectMake(x,y,85,121)];
		[sprite initPerformance];
		
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
		[spriteManager removeSpriteAtIndex:quantityNodes];
	}
	
	[self updateNodes];
}
@end
