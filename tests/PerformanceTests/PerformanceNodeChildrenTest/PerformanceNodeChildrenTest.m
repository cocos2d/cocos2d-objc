//
// cocos2d node-children performance test
//


#import "PerformanceNodeChildrenTest.h"

enum {
	kTagInfoLayer = 1,
	kTagMainLayer = 2,
	kTagLabelAtlas = 3,

	kTagBase = 20000,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
		@"IterateSpriteSheetFastEnum",
		@"IterateSpriteSheetCArray",
		@"AddSpriteSheet",
		@"RemoveSpriteSheet",
		@"ReorderSpriteSheet",
		@"ReorderSpriteSheetInOrder",
		@"ReorderSpriteSheetInReverseOrder",
		@"AddSpriteSheetInOrder",
		@"AddSpriteSheetInReverseOrder",
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


#pragma mark MainScene

@implementation MainScene

+(id) testWithQuantityOfNodes:(unsigned int)nodes
{
	return [[[self alloc] initWithQuantityOfNodes:nodes] autorelease];
}

- (id)initWithQuantityOfNodes:(unsigned int)nodes
{
	if ((self = [super init])) {

		srandom(0);

		CGSize s = [[CCDirector sharedDirector] winSize];

		// Title
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:40];
		[self addChild:label z:1];
		[label setPosition: ccp(s.width/2, s.height-32)];
		[label setColor:ccc3(255,255,40)];

		// Subtitle
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}

		lastRenderedCount = 0;
		currentQuantityOfNodes = 0;
		quantityOfNodes = nodes;

		[CCMenuItemFont setFontSize:65];
		CCMenuItemFont *decrease = [CCMenuItemFont itemWithString: @" - " target:self selector:@selector(onDecrease:)];
		[decrease.label setColor:ccc3(0,200,20)];
		CCMenuItemFont *increase = [CCMenuItemFont itemWithString: @" + " target:self selector:@selector(onIncrease:)];
		[increase.label setColor:ccc3(0,200,20)];

		CCMenu *menu = [CCMenu menuWithItems: decrease, increase, nil];
		[menu alignItemsHorizontally];
		menu.position = ccp(s.width/2, s.height/2+15);
		[self addChild:menu z:1];

		CCLabelTTF *infoLabel = [CCLabelTTF labelWithString:@"0 nodes" fontName:@"Marker Felt" fontSize:30];
		[infoLabel setColor:ccc3(0,200,20)];
		infoLabel.position = ccp(s.width/2, s.height/2-15);
		[self addChild:infoLabel z:1 tag:kTagInfoLayer];


		// Next Prev Test
		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		[menu alignItemsHorizontally];
		menu.position = ccp(s.width/2, 30);
		[self addChild: menu z:1];


		[self updateQuantityLabel];
		[self updateQuantityOfNodes];
	}

	return self;
}

-(NSString*) title
{
	return @"No title";
}

-(NSString*) subtitle
{
	return @"No subtitle";
}

-(void) dealloc
{
	CC_PROFILER_PURGE_ALL();

	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	id scene = [restartAction() testWithQuantityOfNodes:quantityOfNodes];
	[s addChild:scene];

	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	id scene = [nextAction() testWithQuantityOfNodes:quantityOfNodes];
	[s addChild:scene];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	id scene = [backAction() testWithQuantityOfNodes:quantityOfNodes];
	[s addChild:scene];

	[[CCDirector sharedDirector] replaceScene: s];
}


-(void) onIncrease:(id) sender
{
	quantityOfNodes += kNodesIncrease;
	if( quantityOfNodes > kMaxNodes )
		quantityOfNodes = kMaxNodes;

	[self updateQuantityLabel];
	[self updateQuantityOfNodes];
}

-(void) onDecrease:(id) sender
{
	quantityOfNodes -= kNodesIncrease;
	if( quantityOfNodes < 0 )
		quantityOfNodes = 0;

	[self updateQuantityLabel];
	[self updateQuantityOfNodes];
}

- (void)updateQuantityLabel
{
	if( quantityOfNodes != lastRenderedCount ) {

		CCLabelTTF *infoLabel = (CCLabelTTF *) [self getChildByTag:kTagInfoLayer];
		[infoLabel setString: [NSString stringWithFormat:@"%u nodes", quantityOfNodes] ];

		lastRenderedCount = quantityOfNodes;
	}
}

-(void) updateQuantityOfNodes
{
	// override me
}

@end

#pragma mark -
#pragma mark IterateSpriteSheet

@implementation IterateSpriteSheet

- (id)initWithQuantityOfNodes:(unsigned int)nodes
{
	batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet1.png"];

	if( ( self=[super initWithQuantityOfNodes:nodes]) ) {

		[self addChild:batchNode];
		[self scheduleUpdate];
	}

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) updateQuantityOfNodes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	// increase nodes
	if( currentQuantityOfNodes < quantityOfNodes ) {
		for(int i=0;i < (quantityOfNodes-currentQuantityOfNodes);i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0, 0, 32, 32)];
			[batchNode addChild:sprite];
			[sprite setPosition:ccp( CCRANDOM_0_1()*s.width, CCRANDOM_0_1()*s.height)];
		}
	}


	// decrease nodes
	else if ( currentQuantityOfNodes > quantityOfNodes ) {
		for(int i=0;i < (currentQuantityOfNodes-quantityOfNodes);i++) {
			int index = currentQuantityOfNodes-i-1;
			[batchNode removeChildAtIndex:index cleanup:YES];
		}

	}

	currentQuantityOfNodes = quantityOfNodes;
}

-(NSString*) title
{
	return @"none";
}
-(NSString*) profilerName
{
	return @"none";
}
@end

@implementation IterateSpriteSheetFastEnum

-(void) update:(ccTime)dt
{
	CC_PROFILER_START_INSTANCE(self, [self profilerName] );


	// iterate using fast enumeration protocol
	for( CCSprite* sprite in [batchNode children] )
	{
		[sprite setVisible:NO];
	}

	CC_PROFILER_STOP_INSTANCE(self, [self profilerName] );
}

-(NSString*) title
{
	return @"A - Iterate SpriteSheet";
}
-(NSString*) subtitle
{
	return @"Iterate children using Fast Enum API. See console";
}
-(NSString*) profilerName
{
	return @"iter fast enum";
}

@end

@implementation IterateSpriteSheetCArray

-(void) update:(ccTime)dt
{
	ccArray *array = batchNode.children->data;

	CC_PROFILER_START( [self profilerName] );

	// iterate using fast enumeration protocol
	for( int i=0; i < array->num; i++)
	{
		CCSprite *sprite = array->arr[i];
		[sprite setVisible:NO];
	}

	CC_PROFILER_STOP( [self profilerName] );
}

-(NSString*) title
{
	return @"B - Iterate SpriteSheet";
}
-(NSString*) subtitle
{
	return @"Iterate children using C Array API. See console";
}

-(NSString*) profilerName
{
	return @"iter c-array";
}

@end

#pragma mark -
#pragma mark AddRemoveSpriteSheet

@implementation AddRemoveSpriteSheet

- (id)initWithQuantityOfNodes:(unsigned int)nodes
{
	batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet1.png"];

	if( ( self=[super initWithQuantityOfNodes:nodes]) ) {

		[self addChild:batchNode];
		[self scheduleUpdate];
	}

	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) updateQuantityOfNodes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	// increase nodes
	if( currentQuantityOfNodes < quantityOfNodes ) {
		for(int i=0;i < (quantityOfNodes-currentQuantityOfNodes);i++) {
			CCSprite *sprite = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0, 0, 32, 32)];
			[batchNode addChild:sprite];
			[sprite setPosition:ccp( CCRANDOM_0_1()*s.width, CCRANDOM_0_1()*s.height)];
			[sprite setVisible:NO];
		}
	}


	// decrease nodes
	else if ( currentQuantityOfNodes > quantityOfNodes ) {
		for(int i=0;i < (currentQuantityOfNodes-quantityOfNodes);i++) {
			int index = currentQuantityOfNodes-i-1;
			[batchNode removeChildAtIndex:index cleanup:YES];
		}

	}

	currentQuantityOfNodes = quantityOfNodes;
}

-(NSString*) title
{
	return @"none";
}
-(NSString*) profilerName
{
	return @"none";
}
@end

@implementation AddSpriteSheet

-(void) update:(ccTime)dt
{
	// reset seed
	srandom(0);

	// 15 percent
	int totalToAdd = currentQuantityOfNodes * 0.15f;

	if( totalToAdd > 0 ) {

		CCSprite *sprites[ totalToAdd ];
		int		zs[ totalToAdd];

		// Don't include the sprite creation time and random as part of the profiling
		for(int i=0;i<totalToAdd;i++) {
			sprites[i] = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,32,32)];
			zs[i] = CCRANDOM_MINUS1_1() * 50;
		}

		// add them with random Z (very important!)
		CC_PROFILER_START( [self profilerName] );

		for( int i=0; i < totalToAdd;i++ )
		{
			[batchNode addChild:sprites[i] z:zs[i] tag:kTagBase+i];
		}

		[batchNode sortAllChildren];
		CC_PROFILER_STOP( [self profilerName] );

		// remove them
		for( int i=0;i <  totalToAdd;i++)
		{
			[batchNode removeChildByTag:kTagBase+i cleanup:YES];
		}
	}
}

-(NSString*) title
{
	return @"C - Add to spritesheet";
}
-(NSString*) subtitle
{
	return @"Adds %10 of total sprites with random z. See console";
}
-(NSString*) profilerName
{
	return @"add sprites";
}
@end

@implementation RemoveSpriteSheet
-(void) update:(ccTime)dt
{
	srandom(0);

	// 15 percent
	int totalToAdd = currentQuantityOfNodes * 0.15f;

	if( totalToAdd > 0 ) {

		CCSprite *sprites[ totalToAdd ];

		// Don't include the sprite creation time as part of the profiling
		for(int i=0;i<totalToAdd;i++) {
			sprites[i] = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,32,32)];
		}

		// add them with random Z (very important!)
		for( int i=0; i < totalToAdd;i++ )
		{
			[batchNode addChild:sprites[i] z:CCRANDOM_MINUS1_1() * 50 tag:kTagBase+i];
		}

		// remove them
		CC_PROFILER_START( [self profilerName] );

		for( int i=0;i <  totalToAdd;i++)
		{
			[batchNode removeChildByTag:kTagBase+i cleanup:YES];
		}
		CC_PROFILER_STOP( [self profilerName] );
	}
}

-(NSString*) title
{
	return @"D - Del from spritesheet";
}
-(NSString*) subtitle
{
	return @"Remove %10 of total sprites placed randomly. See console";
}
-(NSString*) profilerName
{
	return @"remove sprites";
}
@end

@implementation ReorderSpriteSheet
-(void) update:(ccTime)dt
{
	srandom(0);

	// 15 percent
	int totalToAdd = currentQuantityOfNodes * 0.15f;

	if( totalToAdd > 0 ) {

		CCSprite *sprites[ totalToAdd ];

		// Don't include the sprite creation time as part of the profiling
		for(int i=0;i<totalToAdd;i++) {
			sprites[i] = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,32,32)];
		}

		// add them with random Z (very important!)
		for( int i=0; i < totalToAdd;i++ )
		{
			[batchNode addChild:sprites[i] z:CCRANDOM_MINUS1_1() * 50 tag:kTagBase+i];
		}

		[batchNode sortAllChildren];

		// reorder them
		CC_PROFILER_START( [self profilerName] );
		for( int i=0;i <  totalToAdd;i++)
		{
			[batchNode reorderChild:[[batchNode children] objectAtIndex:i] z:CCRANDOM_MINUS1_1() * 50];
		}

		[batchNode sortAllChildren];
		CC_PROFILER_STOP( [self profilerName] );

		// remove them
		for( int i=0;i <  totalToAdd;i++)
		{
			[batchNode removeChildByTag:kTagBase+i cleanup:YES];
		}
	}
}

-(NSString*) title
{
	return @"E - Reorder from spritesheet";
}
-(NSString*) subtitle
{
	return @"Reorder %10 of total sprites placed randomly. See console";
}
-(NSString*) profilerName
{
	return @"reorder sprites";
}
@end

@implementation ReorderSpriteSheetInOrder
-(void) update:(ccTime)dt
{
	srandom(0);

	// 15 percent
	int totalToAdd = currentQuantityOfNodes * 0.15f;

	if( totalToAdd > 0 ) {

		CCSprite *sprites[ totalToAdd ];

		// Don't include the sprite creation time as part of the profiling
		for(int i=0;i<totalToAdd;i++) {
			sprites[i] = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,32,32)];
		}


		for( int i=0; i < totalToAdd;i++ )
		{
			[batchNode addChild:sprites[i] z:i tag:kTagBase+i];
		}

		[batchNode sortAllChildren];

		// reorder them
		CC_PROFILER_START([self profilerName]);
		for( int i=0;i <  totalToAdd;i++)
		{
			CCSprite* temp =[[batchNode children] objectAtIndex:i];
			[batchNode reorderChild:temp z:i+1];
		}
		[batchNode sortAllChildren];
		CC_PROFILER_STOP([self profilerName]);
		// remove them
		for( int i=0;i <  totalToAdd;i++)
		{
			[batchNode removeChildByTag:kTagBase+i cleanup:YES];
		}
	}
}

-(NSString*) title
{
	return @"F - Reorder from spritesheet";
}
-(NSString*) subtitle
{
	return @"Reorder %10 of total sprites placed in order. See console";
}
-(NSString*) profilerName
{
	return @"reorder sprites in order";
}
@end

@implementation ReorderSpriteSheetInReverseOrder
-(void) update:(ccTime)dt
{
	srandom(0);

	// 15 percent
	int totalToAdd = currentQuantityOfNodes * 0.15f;

	if( totalToAdd > 0 ) {

		CCSprite *sprites[ totalToAdd ];

		// Don't include the sprite creation time as part of the profiling
		for(int i=0;i<totalToAdd;i++) {
			sprites[i] = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,32,32)];
		}



		for( int i=0; i < totalToAdd;i++ )
		{
			[batchNode addChild:sprites[i] z:i tag:kTagBase+i];
		}
		[batchNode sortAllChildren];


		// reorder them, worst case scenario
		CC_PROFILER_START([self profilerName]);
		for( int i=0;i <  totalToAdd;i++)
		{
			CCSprite* temp =[[batchNode children] objectAtIndex:i];
			[batchNode reorderChild:temp z:totalToAdd-i];
		}
		[batchNode sortAllChildren];
		CC_PROFILER_STOP([self profilerName]);

		// remove them
		for( int i=0;i <  totalToAdd;i++)
		{
			[batchNode removeChildByTag:kTagBase+i cleanup:YES];
		}
	}
}

-(NSString*) title
{
	return @"G - Reorder from spritesheet";
}
-(NSString*) subtitle
{
	return @"Reorder %10 of total sprites placed in reverse order. See console";
}
-(NSString*) profilerName
{
	return @"reorder sprites in reverse order";
}
@end

@implementation AddSpriteSheetInOrder
-(void) update:(ccTime)dt
{
	srandom(0);

	// 15 percent
	int totalToAdd = currentQuantityOfNodes * 0.15f;

	if( totalToAdd > 0 ) {

		CCSprite *sprites[ totalToAdd ];

		// Don't include the sprite creation time as part of the profiling
		for(int i=0;i<totalToAdd;i++) {
			sprites[i] = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,32,32)];
		}

		//best case scenario
		CC_PROFILER_START([self profilerName]);
		for( int i=0; i < totalToAdd;i++ )
		{
			[batchNode addChild:sprites[i] z:i tag:kTagBase+i];
		}
		[batchNode sortAllChildren];
		CC_PROFILER_STOP([self profilerName]);

		// remove them
		for( int i=0;i <  totalToAdd;i++)
		{
			[batchNode removeChildByTag:kTagBase+i cleanup:YES];
		}
	}
}

-(NSString*) title
{
	return @"H - Add to spritesheet";
}
-(NSString*) subtitle
{
	return @"Add %10 of total sprites placed in order. See console";
}
-(NSString*) profilerName
{
	return @"add sprites in order";
}
@end

@implementation AddSpriteSheetInReverseOrder
-(void) update:(ccTime)dt
{
	srandom(0);

	// 15 percent
	int totalToAdd = currentQuantityOfNodes * 0.15f;

	if( totalToAdd > 0 ) {

		CCSprite *sprites[ totalToAdd ];

		// Don't include the sprite creation time as part of the profiling
		for(int i=0;i<totalToAdd;i++) {
			sprites[i] = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,32,32)];
		}


		//worst case scenario
		CC_PROFILER_START([self profilerName]);
		for( int i=0; i < totalToAdd;i++ )
		{
			[batchNode addChild:sprites[i] z:totalToAdd-i tag:kTagBase+i];
		}
		[batchNode sortAllChildren];
		CC_PROFILER_STOP([self profilerName]);

		// remove them
		for( int i=0;i <  totalToAdd;i++)
		{
			[batchNode removeChildByTag:kTagBase+i cleanup:YES];
		}
	}
}

-(NSString*) title
{
	return @"I - Add to spritesheet";
}
-(NSString*) subtitle
{
	return @"Add %10 of total sprites placed in reverse order. See console";
}
-(NSString*) profilerName
{
	return @"add sprites in reverse order";
}
@end
