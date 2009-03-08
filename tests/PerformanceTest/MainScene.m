//
// cocos2d performance test
// Based on the test by Valentin Milea
//

#import "MainScene.h"
#import "CocosNodePerformance.h"

enum {
	kMaxNodes = 2000,
	kNodesIncrease = 30,
};

enum {
	kTagInfoLayer = 1,
	kTagMainLayer = 2,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
		@"PerformanceSprite1",
		@"PerformanceAtlasSprite1",
		@"PerformanceSprite2",
		@"PerformanceAtlasSprite2",
		@"PerformanceSprite3",
		@"PerformanceAtlasSprite3",
		@"PerformanceSprite4",
		@"PerformanceAtlasSprite4",
		@"PerformanceSprite5",
		@"PerformanceAtlasSprite5",
		@"PerformanceSprite6",
		@"PerformanceAtlasSprite6",
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
		
		srandom(0);
		
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

-(void) doTest:(id) sprite
{
	// override
}

-(id) createSprite
{
	// override
	return nil;
}
@end

#pragma mark Sprite 1

@implementation PerformanceSprite1

-(NSString*) title
{
	return @"Sprite position";
}
-(void) onIncrease:(id) sender
{
	if( quantityNodes >= kMaxNodes)
		return;
	
	for( int i=0;i< kNodesIncrease;i++) {
		
		Sprite *sprite = [self createSprite];

		[self add:sprite z:0 tag:quantityNodes + 100];

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
		[self removeByTag:quantityNodes + 100];
	}
	
	[self updateNodes];
}
-(void) doTest:(id) sprite
{
	[sprite performancePosition];
}

-(id) createSprite
{
	return [Sprite spriteWithFile:@"grossinis_sister1.png"];
}
@end

#pragma mark Sprite 2
@implementation PerformanceSprite2
-(NSString*) title
{
	return @"Sprite scale";
}
-(void) doTest:(id) sprite
{
	[sprite performanceScale];
}
@end

#pragma mark Sprite 3
@implementation PerformanceSprite3
-(NSString*) title
{
	return @"Sprite scale + rotation";
}

-(void) doTest:(id) sprite
{
	[sprite performanceRotationScale];
}
@end

#pragma mark Sprite 4
@implementation PerformanceSprite4
-(NSString*) title
{
	return @"Sprite Textures";
}
-(void) doTest:(id) sprite
{
	[sprite performancePosition];
}
-(id) createSprite
{
	int idx = (CCRANDOM_0_1() * 1400 / 100) + 1;
	return [Sprite spriteWithFile: [NSString stringWithFormat:@"grossini_dance_%02d.png", idx]];
}
@end

#pragma mark Sprite 5
@implementation PerformanceSprite5
-(NSString*) title
{
	return @"Sprite Textures + scale";
}
-(void) doTest:(id) sprite
{
	[sprite performanceScale];
}
@end

#pragma mark Sprite 6
@implementation PerformanceSprite6
-(NSString*) title
{
	return @"Sprite tex + scale + rotation";
}

-(void) doTest:(id) sprite
{
	[sprite performanceRotationScale];
}
@end


#pragma mark AtlasSprite 1
@implementation PerformanceAtlasSprite1
-(id) init
{
	if( (self=[super init]) )
	{
		spriteManager = [self createSpriteManager];
		[self add:spriteManager];
	}
	return self;
}

-(id) createSpriteManager
{
	return [AtlasSpriteManager spriteManagerWithFile:@"grossinis_sister1.png" capacity:250];
}

- (void) dealloc
{
	[super dealloc];
}

-(NSString*) title
{
	return @"AtlasSprite position";
}

-(void) onIncrease:(id) sender
{
	if( quantityNodes >= kMaxNodes)
		return;
	
	for( int i=0;i< kNodesIncrease;i++) {

		AtlasSprite *sprite = [self createSprite];		
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
		[spriteManager removeSpriteAtIndex:quantityNodes];
	}
	
	[self updateNodes];
}
-(void) doTest:(id) sprite
{
	[sprite performancePosition];
}
-(id) createSprite
{
	return [spriteManager createSpriteWithRect:CGRectMake(0,0,52,139)];
}
@end

#pragma mark AtlasSprite 2
@implementation PerformanceAtlasSprite2
-(NSString*) title
{
	return @"AtlasSprite scale";
}
-(void) doTest:(id) sprite
{
	[sprite performanceScale];
}
@end

#pragma mark AtlasSprite 3
@implementation PerformanceAtlasSprite3
-(NSString*) title
{
	return @"AtlasSprite rotation + scale";
}

-(void) doTest:(id) sprite
{
	[sprite performanceRotationScale];
}
@end

#pragma mark AtlasSprite 4
@implementation PerformanceAtlasSprite4
-(NSString*) title
{
	return @"AtlasSprite Textures";
}
-(void) doTest:(id) sprite
{
	[sprite performancePosition];
}

-(id) createSpriteManager
{
	return [AtlasSpriteManager spriteManagerWithFile:@"grossini_dance_atlas.png" capacity:250];
}

-(id) createSprite
{
	int y = 0;
	int x = (CCRANDOM_0_1() * 1400 / 100);
	
	if( x > 6 ) {
		x %= 7;
		y = 1;
	}
	x *= 85;
	y *= 121;
	return [spriteManager createSpriteWithRect:CGRectMake(x,y,85,121)];
}
@end

#pragma mark AtlasSprite 5
@implementation PerformanceAtlasSprite5
-(NSString*) title
{
	return @"AtlasSprite textures + scale";
}
-(void) doTest:(id) sprite
{
	[sprite performanceScale];
}
@end

#pragma mark AtlasSprite 6
@implementation PerformanceAtlasSprite6
-(NSString*) title
{
	return @"AtlasSprite tex + rotation + scale";
}

-(void) doTest:(id) sprite
{
	[sprite performanceRotationScale];
}
@end



