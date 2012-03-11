//
// cocos2d dispatcher performance test - by 'cocos'
// Based on the Children Node Performance Test by 'araker'

#import "cocos2d.h"

#if ! CC_ENABLE_PROFILERS
#error CC_ENABLE_PROFILERS must be enabled. Edit ccConfig.h
#endif

#import "PerformanceDispatcher.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////

#define  COMPILE_FOR_NEW_API                    1	// USE 0 TO COMPILE WITH 4 OLD FILES FOR OLD API
													// To compare SPEED of NEW AND OLD API 
													// keep 0 and swap old files for new ones!
													// files to be swaped: CCTouchDispatcher.m/.h
													//					   CCTouchHandler.m/.h
													
													// USE 1 TO COMPILE WITH 4 NEW FILES FOR NEW API 

///////////////////////////////////////////////////////////////////////////////////////////////////////

enum {
	kTagInfoLayer = 1,
	kTagMainLayer = 2,
	kTagLabelAtlas = 3,
	
	kTagBase = 20000,
	kTagMenu = 10000,
};

static int sceneIdx=-1;


static NSString *transitions[] = {
		// ONLY OLD API used:
		@"AddingDelegatesTypical",	
		@"AddingDelegates",						// 1 Adding standard/targeted delegates to the touch dispatcher
		@"RemovingDelegates",					// 2 .Removing delegates from the touch dispatcher 
		@"AddRandomPriorityDelegates",		    // 3.
		@"RemoveDelegatesWithRandomPriority",	// 4
		@"ReorderDelegates",					// 5 - slow one by one via standard sort alg
		// NEW and OLD API
#if  COMPILE_FOR_NEW_API 	
		@"FastAdd",								// 1.a 
		@"FastRemoval",							// 2.a
		@"FastCompoundRemoval",					// 2.b
		@"ReorderingOneByOneQSORT",				// 5a slow old api with new sorting algorithm 
		@"ReorderingOneByOneMERGESORT",			// 5b slow old api with new sorting algorithm 
		@"UltraFastReordering",					// 5c new api with new sorting algorithm 
		@"Various"								// 6	

#endif	
};

Class nextAction(void)
{	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction(void)
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction(void)
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark SGSprite

@implementation SGSprite

-(id) init
{
	if((self=[super init])){		
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

// standard
// optional
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
}
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
}
// targeted
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
	return NO;
}
//optional
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{}
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{}
@end

/////

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
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:30];
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
		CCMenuItemFont *decrease = [CCMenuItemFont itemFromString: @" - " target:self selector:@selector(onDecrease:)];
		[decrease.label setColor:ccc3(0,200,20)];
		CCMenuItemFont *increase = [CCMenuItemFont itemFromString: @" + " target:self selector:@selector(onIncrease:)];
		[increase.label setColor:ccc3(0,200,20)];
		
		CCMenu *menu = [CCMenu menuWithItems: decrease, increase, nil];
		[menu alignItemsHorizontally];
		menu.position = ccp(s.width/2, s.height/2+15);
		[self addChild:menu z:1	tag:kTagMenu];
		
		CCLabelTTF *infoLabel = [CCLabelTTF labelWithString:@"0 handlers" fontName:@"Marker Felt" fontSize:30];
		[infoLabel setColor:ccc3(0,200,20)];
		infoLabel.position = ccp(s.width/2, s.height/2-15);
		[self addChild:infoLabel z:1 tag:kTagInfoLayer];
		
		
		// Next Prev Test
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
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
		[infoLabel setString: [NSString stringWithFormat:@"%u handlers", quantityOfNodes] ];
		
		lastRenderedCount = quantityOfNodes;
	}
}

-(void) updateQuantityOfNodes
{
	// override me
}

@end

////

#pragma mark -
#pragma mark IterateSpriteSheet

@implementation IterateSpriteSheet



- (void) testCallback:(id)sender
{
	
   // OLD FILES HAVE PROBLEM - this callback will crash	

	SGSprite *sprite = [SGSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0, 0, 32, 32)];		
	
	CCLOG(@"testing callback - start");
	
// Add delegate 
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-10];	
	
// Change priority	
	[[CCTouchDispatcher sharedDispatcher] setPriority:10 forDelegate:sprite];	
	
// Remove delegate
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];	
	
// Add delegate 
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-20];	
		
// Remove delegate 
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];		
	
// Remove delegate 	// legal should be considered NOP
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];		
	
// Add delegate 
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-30];		
	
// Change priority of the delegate 
	[[CCTouchDispatcher sharedDispatcher] setPriority:20 forDelegate:sprite];	
	[[CCTouchDispatcher sharedDispatcher] setPriority:30 forDelegate:sprite];
		
// remove it 	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];
// nothing added as a result.	
	
#if  COMPILE_FOR_NEW_API 		
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)]){	
		//	print all sprite delagates - all should be marked for removed
		CCLOG(@" Callback Log: all added sprites should be marked for removal");
		[[CCTouchDispatcher sharedDispatcher] setField:kCCDebug newValue:1 delegate:sprite type:kCCStandard];	
	}
#endif	
	
	CCLOG(@"testing callback - end");	
}

- (id)initWithQuantityOfNodes:(unsigned int)nodes
{
	batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet1.png" capacity:200];

	if( ( self=[super initWithQuantityOfNodes:nodes]) ) {
	
		_profilingTimer = [[CCProfiler timerWithName:[self profilerName] andInstance:self] retain];

		[self addChild:batchNode];
		
		//--- Button to test callback processing -----
		CGSize s = [[CCDirector sharedDirector] winSize];
		[CCMenuItemFont setFontSize:25];

		CCMenuItemFont *testCallbackProcessing = [CCMenuItemFont itemFromString:@"CallBack - It should not crash" target:self selector:@selector(testCallback:)];
        		
		[testCallbackProcessing.label setColor:ccc3(200,0,20)];
		
		CCMenu *menu = [CCMenu menuWithItems:testCallbackProcessing,nil];
		menu.position = ccp(s.width/2, s.height/2-70);
		[self addChild:menu];
		//---------------------------------------------
		
		
		[self scheduleUpdate];								
		
	}
	
	return self;
}

- (void) dealloc
{
	[CCProfiler releaseTimer:_profilingTimer];
	[super dealloc];
}

-(void) updateQuantityOfNodes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	// increase nodes
	if( currentQuantityOfNodes < quantityOfNodes ) {
		for(int i=0;i < (quantityOfNodes-currentQuantityOfNodes);i++) {
			SGSprite *sprite = [SGSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0, 0, 32, 32)];
			[batchNode addChild:sprite];
			[sprite setVisible:NO];
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


//// 0

@implementation AddingDelegatesTypical

-(void) update:(ccTime)dt
{	
	ccArray *array = batchNode.children->data;
	int count = array->num;
		
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING ADDING DELEGATES
	for( int i=0; i < count; i++)
	{
		// THE TYPICAL CASE - SAME PRIORITY FOR ALL DELEGATES
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:array->arr[i] priority:0];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:array->arr[i] priority:0 swallowsTouches:YES];
	}
	CCProfilingEndTimingBlock(_profilingTimer); //----
	
	// remove them 
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];		
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];
	}
}

-(NSString*) title
{
	return @"0 - Adding delegates Typical";
}
-(NSString*) subtitle
{
	return @"Adding standard/targeted delegates. Typical case. See console";
}
-(NSString*) profilerName
{
	return @"0-Adding delegates-typical ";
}

@end


//// 1

@implementation AddingDelegates

-(void) update:(ccTime)dt
{	
	ccArray *array = batchNode.children->data;

	int count = array->num;
	
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING ADDING DELEGATES
	for( int i=0; i < count; i++)
	{
		// THE WORST CASE FOR CCARRAY (insering at the front of the ccarray)
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:array->arr[i]priority:count-i];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:array->arr[i] priority:count-i swallowsTouches:YES];
	}
	CCProfilingEndTimingBlock(_profilingTimer); //----
	
	// remove them 
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];		
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];
	}
}

-(NSString*) title
{
	return @"1 - Adding delegates";
}
-(NSString*) subtitle
{
	return @"Adding standard/targeted delegates. Bad case for CCArray. See console";
}
-(NSString*) profilerName
{
	return @"1-Adding delegates";
}

@end

//// 2

@implementation  RemovingDelegates

-(void) update:(ccTime)dt
{
	ccArray *array = batchNode.children->data;

	int count = array->num;
	
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:count-i];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:sprite priority:count-i swallowsTouches:NO];
	}
	
	// remove them - profiling removal of delegates
	CCProfilingBeginTimingBlock(_profilingTimer); //---- PROFILING REMOVING DELEGATES
	for( int i=0; i < array->num; i++)
	{
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:array->arr[i]]; // type:kCCStandard
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:array->arr[i]]; // type:kCCTargeted
	}
	CCProfilingEndTimingBlock(_profilingTimer); //----
}

-(NSString*) title
{
	return @"2 - Removing delegates";
}
-(NSString*) subtitle
{
	return @"Removing delegates: 'removeDelegate:node' See console";
}

-(NSString*) profilerName
{
	return @"2-Removing delegates";
}

@end


///

#pragma mark -
#pragma mark AddRemoveSpriteSheet

@implementation AddRemoveSpriteSheet

- (id)initWithQuantityOfNodes:(unsigned int)nodes
{
	batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet1.png" capacity:200];
	
	if( ( self=[super initWithQuantityOfNodes:nodes]) ) {
		
		_profilingTimer = [[CCProfiler timerWithName:[self profilerName] andInstance:self] retain];
		
		[self addChild:batchNode];		
		[self scheduleUpdate];
	}
	
	return self;
}

- (void) dealloc
{
	[CCProfiler releaseTimer:_profilingTimer];
	[super dealloc];
}

-(void) updateQuantityOfNodes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	// increase nodes
	if( currentQuantityOfNodes < quantityOfNodes ) {
		for(int i=0;i < (quantityOfNodes-currentQuantityOfNodes);i++) {
			SGSprite *sprite = [SGSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0, 0, 32, 32)];
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

//// 3

@implementation AddRandomPriorityDelegates

-(void) update:(ccTime)dt
{
	// reset seed
	srandom(0);
	
	ccArray *array = batchNode.children->data;
	
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING ADDING DELEGATES
	for( int i=0; i < array->num; i++)
	{
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:array->arr[i] priority:/*array->num-i+*/ CCRANDOM_MINUS1_1() * 50];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:array->arr[i] priority:/*array->num-i+*/ CCRANDOM_MINUS1_1() * 50 swallowsTouches:YES];							
	}
	CCProfilingEndTimingBlock(_profilingTimer); //----
	
	// remove them 
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];
	}
}

-(NSString*) title
{
	return @"3. Add with RANDOM priority";
}
-(NSString*) subtitle
{
	return @"Adds sprites with random priority. See console";
}
-(NSString*) profilerName
{
	return @"3- Add delegates with RANDOM priority";
}
@end


//// 4
@implementation RemoveDelegatesWithRandomPriority
-(void) update:(ccTime)dt
{
	// reset seed
	srandom(0);
		
	ccArray *array = batchNode.children->data;
		
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50 ];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50  swallowsTouches:YES];
	}
	
	// remove them 
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING ADDING DELEGATES	
	for( int i=0; i < array->num; i++)
	{
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:array->arr[i]];
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:array->arr[i]];		
	}	
	CCProfilingEndTimingBlock(_profilingTimer); //----			
}

-(NSString*) title
{
	return @"4 - Delete (random priority)";
}
-(NSString*) subtitle
{
	return @"Remove sprites added with random priority. See console";
}
-(NSString*) profilerName
{
	return @"4 - Delete delegates with RANDOM priority";
}
@end



//// 5
@implementation ReorderDelegates
-(void) update:(ccTime)dt
{
	// reset seed
	srandom(0);
	
	ccArray *array = batchNode.children->data;
	
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		[sprite setVisible:NO];
		
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50 ];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50 swallowsTouches:YES];
	}
	
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING REORDERING DELEGATES		
	for( int i=0;i < array->num;i++)
	{		
		[[CCTouchDispatcher sharedDispatcher] setPriority:array->num-i+CCRANDOM_MINUS1_1() * 200 forDelegate:array->arr[i]];						
	}
	CCProfilingEndTimingBlock(_profilingTimer);	//--------------------------------------
	
	// remove them 
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];	
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite];		
	}	
}

-(NSString*) title
{
	return @"5 - Reorder priorities ";
}
-(NSString*) subtitle
{
	return @"Reorder %100 of delegates via default algorithm. See console";
}
-(NSString*) profilerName
{
	return @"5 - Reorder delegates NSMutableASort/InsertSort";
}
@end


#if  COMPILE_FOR_NEW_API 	
 
//// 1 a)
@implementation FastAdd
-(void) update:(ccTime)dt
{	
   if ( ![[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
	return;

	// reset seed
	srandom(0);
		
	ccArray *array = batchNode.children->data;
	
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING ADDING DELEGATES -  FAST ADD 
	for( int i=0; i < array->num; i++)
	{
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:array->arr[i] priority:array->num-i + CCRANDOM_MINUS1_1() * 50 tag:i disable:NO doNotSort:YES];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:array->arr[i] priority:array->num-i + CCRANDOM_MINUS1_1() * 50 swallowsTouches:NO tag:i disable:NO doNotSort:YES];						
	}
	// sorting is done here:
	[[CCTouchDispatcher sharedDispatcher] sortDelegates:kCCTargeted];
	[[CCTouchDispatcher sharedDispatcher] sortDelegates:kCCStandard];
	CCProfilingEndTimingBlock(_profilingTimer); //------------
	
	// remove them (fast removal)
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite delay:YES type:kCCStandard];
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite delay:YES type:kCCTargeted];							
	}		
	[[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCTargeted];
	[[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCStandard];
}

-(NSString*) title
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return @"1a - Fast Add of delegates";
	else
		return @"1a - Fast Add - new API required";	
}
-(NSString*) subtitle
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
	return @"1a Fast Add of delegates. Add first sort later. See console";
		else
	return @"1a - new API required for this test";
}
-(NSString*) profilerName
{
	return @"1 a - FAST ADD";
}
@end

//// 2 a
@implementation FastRemoval
-(void) update:(ccTime)dt
{
   if ( ![[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return;
	
	// reset seed
	srandom(0);
	
	ccArray *array = batchNode.children->data;

	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		[sprite setVisible:NO];
		
		// the worst case:		
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50 tag:kTagBase+i disable:NO doNotSort:YES];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50 swallowsTouches:NO tag:kTagBase+i disable:NO doNotSort:YES];						
	}
	
	[[CCTouchDispatcher sharedDispatcher]  sortDelegates:kCCTargeted];
	[[CCTouchDispatcher sharedDispatcher]  sortDelegates:kCCStandard];	
	
	// remove them 	
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING FAST REMOVAL 	

	[[CCTouchDispatcher sharedDispatcher] removeDelegatesWithField:kCCTag arg1:kTagBase arg2:CC_UNUSED_ARGUMENT operator:kCCGE delay:NO type:kCCStandard];
	[[CCTouchDispatcher sharedDispatcher] removeDelegatesWithField:kCCTag arg1:kTagBase arg2:CC_UNUSED_ARGUMENT operator:kCCGE delay:NO type:kCCTargeted];
	
	CCProfilingEndTimingBlock(_profilingTimer); //----	
}

-(NSString*) title
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return @"2a - Fast Removal";
	else	
		return @"2a-Fast Removal:new API required!";
}
	
-(NSString*) subtitle
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return @"Fast Removal. See console";
   else
		return @"FAST REMOVAL - new API required for this test";	
}
-(NSString*) profilerName
{
	return @"2a FAST REMOVAL";
}
@end

//// 2b
@implementation FastCompoundRemoval
-(void) update:(ccTime)dt
{
   if ( ![[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return;
		
	// reset seed
	srandom(0);
	
	ccArray *array = batchNode.children->data;
	
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		[sprite setVisible:NO];
		
		// the worst case:		
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50 tag:kTagBase+i disable:NO doNotSort:YES];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50 swallowsTouches:NO tag:kTagBase+i disable:NO doNotSort:YES];						
	}
	
	[[CCTouchDispatcher sharedDispatcher]  sortDelegates:kCCTargeted];
	[[CCTouchDispatcher sharedDispatcher]  sortDelegates:kCCStandard];	
	
	// remove them 	
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING COMPOUND FAST REMOVAL - removal delayed	
	// 
	[[CCTouchDispatcher sharedDispatcher] setDelegatesField:kCCRemoveToDo newValue:YES ifField:kCCTag arg1:kTagBase+52 arg2:CC_UNUSED_ARGUMENT operator:kCCEQ type:kCCStandard];	
	[[CCTouchDispatcher sharedDispatcher] setDelegatesField:kCCRemoveToDo newValue:YES ifField:kCCTag arg1:kTagBase arg2:kTagBase+52 operator:kCCGEAndLT type:kCCStandard];
	[[CCTouchDispatcher sharedDispatcher] setDelegatesField:kCCRemoveToDo newValue:YES ifField:kCCTag arg1:kTagBase+52 arg2:CC_UNUSED_ARGUMENT operator:kCCGT type:kCCStandard];
	
	
	[[CCTouchDispatcher sharedDispatcher] setDelegatesField:kCCRemoveToDo newValue:YES ifField:kCCTag arg1:kTagBase+51 arg2:CC_UNUSED_ARGUMENT operator:kCCEQ type:kCCTargeted];
	[[CCTouchDispatcher sharedDispatcher] setDelegatesField:kCCRemoveToDo newValue:YES ifField:kCCTag arg1:kTagBase    arg2:kTagBase+51 operator:kCCGEAndLT type:kCCTargeted];	
	[[CCTouchDispatcher sharedDispatcher] setDelegatesField:kCCRemoveToDo newValue:YES ifField:kCCTag arg1:kTagBase+51 arg2:CC_UNUSED_ARGUMENT operator:kCCGT type:kCCTargeted];		
	
	[[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCStandard];
	[[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCTargeted];	
	
	CCProfilingEndTimingBlock(_profilingTimer); //----	
}

-(NSString*) title
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return @"2b Fast Compound removal";
	else
		return @"2b-Fast Compound:new API required!";	
}
-(NSString*) subtitle
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return @"Fast Compound removal - removal in one pass. See console";
	else
		return @"2b-Fast Compound:new API required!";	
}
-(NSString*) profilerName
{
	return @"2b Fast Compound removal";
}
@end


//// 5 a
@implementation ReorderingOneByOneQSORT
-(void) update:(ccTime)dt
{
   if ( ![[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return;
		
	// reset seed
	srandom(0);
	
	ccArray *array = batchNode.children->data;
	
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50 ];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50   swallowsTouches:YES];
	}
		
	[[CCTouchDispatcher sharedDispatcher] setSortingAlgorithm:kCCAlgQSort];
	
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING REORDERING QSORT DELEGATES		
	for( int i=0;i < array->num;i++)
	{		
		[[CCTouchDispatcher sharedDispatcher] setPriority:array->num-i+CCRANDOM_MINUS1_1() * 200 forDelegate:array->arr[i]];						
	}
	CCProfilingEndTimingBlock(_profilingTimer);	
	
	// remove them
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite delay:YES type:kCCStandard];
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite delay:YES type:kCCTargeted];							
		
	}	
	
	[[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCTargeted];
	[[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCStandard];
}

-(NSString*) title
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
	return @"5a Changing priority - QSort";
		else
	return @"5a-QSort:new API required!";	
}
-(NSString*) subtitle
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return @"Slow Sort one by one. See console";
	else
		return @"5a-QSort:new API required!";	
}
-(NSString*) profilerName
{
	return @"5a QSort";
}
@end

//// 5 b
@implementation ReorderingOneByOneMERGESORT
-(void) update:(ccTime)dt
{
   if ( ![[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return;
	
	// reset seed
	srandom(0);
	
	ccArray *array = batchNode.children->data;
	
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		[sprite setVisible:NO];
		
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50 ];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 50   swallowsTouches:YES];
	}
	
	[[CCTouchDispatcher sharedDispatcher] setSortingAlgorithm:kCCAlgMergeLSort];
	
	CCProfilingBeginTimingBlock(_profilingTimer); //----  PROFILING REORDERING by LMERGESORT		
	for( int i=0;i < array->num;i++)
	{				
		[[CCTouchDispatcher sharedDispatcher] setPriority:array->num-i+CCRANDOM_MINUS1_1() * 200 forDelegate:array->arr[i]];						
	}
	CCProfilingEndTimingBlock(_profilingTimer);	//--------------------------------------------
		
	// remove them
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite delay:YES type:kCCStandard];
		else
			[[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite delay:YES type:kCCTargeted];							
	}	
	
	[[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCTargeted];
	[[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCStandard];
}

-(NSString*) title
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
	return @"5b Changing priority - LMerge";
		else
	return @"5b-LMerge:new API required!";
}
-(NSString*) subtitle
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return @"Slow Sort one by one. See console";
	else
		return @"5b-LMerge:new API required!";
}
-(NSString*) profilerName
{
	return @"5b MSort";
}
@end



//// 5 c
@implementation UltraFastReordering
-(void) update:(ccTime)dt
{
   if ( ![[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return;
	
	// reset seed
	srandom(0);
	
	ccArray *array = batchNode.children->data;
	
	for( int i=0; i < array->num; i++)
	{
		SGSprite *sprite = array->arr[i];
		// the worst case:		
		if (i%2)
			[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 200 tag:kTagBase+i disable:NO doNotSort:YES];
		else
			[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:sprite priority:array->num-i + CCRANDOM_MINUS1_1() * 200 swallowsTouches:NO tag:kTagBase+i disable:NO doNotSort:YES];										
	}
	[[CCTouchDispatcher sharedDispatcher] setSortingAlgorithm:kCCAlgInsertionSort];
	[[CCTouchDispatcher sharedDispatcher]  sortDelegates:kCCTargeted];
	[[CCTouchDispatcher sharedDispatcher]  sortDelegates:kCCStandard];	
		
	
	CCProfilingBeginTimingBlock(_profilingTimer); //----  ULTRA FAST REORDERING	- change priority first, sort later	
	for( int i=0;i < array->num;i++) // via priorityToDd
	{				
		if (i%2)	
			[[CCTouchDispatcher sharedDispatcher] setField:kCCPriorityToDo newValue:array->num-i+CCRANDOM_MINUS1_1() * 200 delegate:array->arr[i] type:kCCStandard];	
		else
			[[CCTouchDispatcher sharedDispatcher] setField:kCCPriorityToDo newValue:array->num-i+CCRANDOM_MINUS1_1() * 200 delegate:array->arr[i] type:kCCTargeted];	
	}
	// actual sorting: 
	[[CCTouchDispatcher sharedDispatcher]  sortDelegates:kCCTargeted];
	[[CCTouchDispatcher sharedDispatcher]  sortDelegates:kCCStandard];	
	CCProfilingEndTimingBlock(_profilingTimer);	//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		
	// remove them via fast removal
	[[CCTouchDispatcher sharedDispatcher] removeDelegatesWithField:kCCTag arg1:kTagBase arg2:CC_UNUSED_ARGUMENT operator:kCCGE delay:NO type:kCCStandard];
	[[CCTouchDispatcher sharedDispatcher] removeDelegatesWithField:kCCTag arg1:kTagBase arg2:CC_UNUSED_ARGUMENT operator:kCCGE delay:NO type:kCCTargeted];
}

-(NSString*) title
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
	return @"5c UltraFast(delayed)Reordering!";
		else
	return @"5c-InsertionSort:new API required!";	
}
-(NSString*) subtitle
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
	return @"UltraFastReordering - InsertionSort: See console";
		else
	return @"5c-InsertionSort:new API required!";
}
-(NSString*) profilerName
{
	return @"5c UltraFast(delayed)Reordering";
}
@end


#pragma mark -
#pragma mark BasicSpriteSheet

@implementation BasicSpriteSheet

-(void) updateQuantityOfNodes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	// increase nodes
	if( currentQuantityOfNodes < quantityOfNodes ) {
		for(int i=0;i < (quantityOfNodes-currentQuantityOfNodes);i++) {
			SGSprite *sprite = [SGSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0, 0, 32, 32)];
			[batchNode addChild:sprite z:i tag:i]; // to trace it
								
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
	[self scheduleOnce:@selector(update:) delay:1.0f]; 
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




@implementation Various

int myComparatorArg(const void * first, const void * second)
{
	// arrange according to tags.
	// if tags are equal take under consideration the priority 	
    
    id fId = ((id *) first)[0];  
    id sId = ((id *) second)[0]; 	
	
	CCTouchHandler *f = (CCTouchHandler*) fId;
	CCTouchHandler *s = (CCTouchHandler*) sId;
	
	// sprite tag
	//int fT = [f.delegate tag];   // delegate has to descend from CCNode
	//int sT = [s.delegate tag];  
    
	// delegate tag
	int fT = f.tag;
	int sT = s.tag;  
    
	int fP = f.priority;
	int sP = s.priority;	
	
	
	if (fT == sT) { 		
        if (fP == sP) {
            return NSOrderedSame;
        }
        else{
            if (fP < sP)   //  if fT == sT  than  p1 < p2 < p3  order:  p1,p2,p3 
                return NSOrderedAscending;
            else 
                return NSOrderedDescending;											
        }				
	}
    
	if (fT < sT)   // if t1 < t2 < t3   order:  t1,t2,t3 
		return NSOrderedAscending;
	else 
		return NSOrderedDescending;
}

//example of custom sort function, only useful when both delegates have the same parent
static NSComparisonResult zOrderComparator(const void * first, const void * second)
{	
    id fId = ((id *) first)[0];  
    id sId = ((id *) second)[0]; 	
	
	CCTouchHandler *f = (CCTouchHandler*) fId;
	CCTouchHandler *s = (CCTouchHandler*) sId;
    
	int fP = [f.delegate zOrder];   // delegate has to descend from CCNode
	int sP = [s.delegate zOrder];  
	
	if (fP == sP) return NSOrderedSame;
	
	if ([[CCTouchDispatcher sharedDispatcher] reversePriority]){
		if (fP < sP)   // if z1 < z2 < z3   order:  z1,z2,z3 
			return NSOrderedAscending;
		else
			return NSOrderedDescending;
	}
	else{ // default
		if (fP > sP)   // if z1 > z2 > z3   order:  z1,z2,z3 
			return NSOrderedAscending;
		else
			return NSOrderedDescending;
	}
}

//run this test in debug mode, else no logs will appear
-(void) variousTests
{
   if ( ![[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return;
		
    BOOL nl = ![[CCTouchDispatcher sharedDispatcher] locked];	

	
	if (nl){ 
	
		CCLOG(@"----------------------------------");
		CCLOG(@" 6 Various...	START			  ");
		CCLOG(@"----------------------------------");
			
	}
	else {
		CCLOG(@"----------------------------------");
		CCLOG(@" 6 Various...	START (CALLBACK)  ");
		CCLOG(@"----------------------------------");								
	}

	
	if (currentQuantityOfNodes == 0){
		
		CCLOG(@" 6 Various... no sprites ");
		return;		
	}

	// reset seed
	srandom(0);
	
	ccArray *array = batchNode.children->data;
    
    NSAssert(array->num >=15, @"too few elements in array, enlarge kNodesIncrease to 15 or more");
	SGSprite *sprite;
	int result;
	
	
	CCLOG(@"--------------------------------------");	
	CCLOG(@" 6 Various...	ADDING DELEGATES standard way");
	CCLOG(@"--------------------------------------");
		
    sprite = array->arr[0]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-5  tag: 0  disable:NO  doNotSort:NO];		
	sprite = array->arr[1];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 1  tag: 1  disable:YES doNotSort:NO];			
    sprite = array->arr[2]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 0  disable:NO  doNotSort:NO];					
    sprite = array->arr[3];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:NO];		
    sprite = array->arr[4];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-1  tag: 1  disable:NO  doNotSort:NO];			
	sprite = array->arr[5];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag:-3  disable:YES doNotSort:NO];		
	sprite = array->arr[6];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 5  tag: 0  disable:YES doNotSort:NO];		
	sprite = array->arr[7];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag: 5  disable:YES doNotSort:NO];	
	sprite = array->arr[8];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 1  tag: 1  disable:YES doNotSort:NO];		
	sprite = array->arr[9]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag: 8  disable:YES doNotSort:NO];		
	sprite = array->arr[10];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:NO];
	sprite = array->arr[11];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 0  disable:YES doNotSort:NO];
	sprite = array->arr[12];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 2  tag: 1  disable:YES doNotSort:NO];	
	sprite = array->arr[13];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 2  tag: 0  disable:YES doNotSort:NO];	
	sprite = array->arr[14];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:NO];	
	
	if(nl)
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];
	
	result = [[CCTouchDispatcher sharedDispatcher] removeAllDelegates:kCCStandard];	
	CCLOG(@" 6 Various... removeAllDelegates:kCCStandard]; number of removals = %d, expected 15",result);
	
	
	
	CCLOG(@"--------------------------------------");	
	CCLOG(@" 6 Various...	ADDING DELEGATES in reverse order");
	CCLOG(@"--------------------------------------");	
	
	[[CCTouchDispatcher sharedDispatcher] setReversePriority:YES];	 // reverse sorting	
	
    sprite = array->arr[0]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-5  tag: 0  disable:NO  doNotSort:NO];		
	sprite = array->arr[1];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 1  tag: 1  disable:YES doNotSort:NO];			
    sprite = array->arr[2]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 0  disable:NO  doNotSort:NO];					
    sprite = array->arr[3];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:NO];		
    sprite = array->arr[4];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-1  tag: 1  disable:NO  doNotSort:NO];			
	sprite = array->arr[5];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag:-3  disable:YES doNotSort:NO];		
	sprite = array->arr[6];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 5  tag: 0  disable:YES doNotSort:NO];		
	sprite = array->arr[7];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag: 5  disable:YES doNotSort:NO];	
	sprite = array->arr[8];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 1  tag: 1  disable:YES doNotSort:NO];		
	sprite = array->arr[9]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag: 8  disable:YES doNotSort:NO];		
	sprite = array->arr[10];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:NO];
	sprite = array->arr[11];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 0  disable:YES doNotSort:NO];
	sprite = array->arr[12];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 2  tag: 1  disable:YES doNotSort:NO];	
	sprite = array->arr[13];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 2  tag: 0  disable:YES doNotSort:NO];	
	sprite = array->arr[14];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:NO];	
	
	if(nl)	
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];
	
	result = [[CCTouchDispatcher sharedDispatcher] removeAllDelegates:kCCStandard];	
	CCLOG(@" 6 Various... removeAllDelegates:kCCStandard]; number of removals = %d, expected 15",result);	
	
	
	CCLOG(@"--------------------------------------");	
	CCLOG(@" 6 Various...	ADDING DELEGATES custom order ");
	CCLOG(@"--------------------------------------");	
	
	[[CCTouchDispatcher sharedDispatcher] setUsersComparator:myComparatorArg];	// change sorting comparator
	

	sprite = array->arr[11];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 0  disable:YES doNotSort:NO];
	sprite = array->arr[12];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 2  tag: 1  disable:YES doNotSort:NO];	
	sprite = array->arr[13];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 2  tag: 0  disable:YES doNotSort:NO];	
	sprite = array->arr[14];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:NO];	
    sprite = array->arr[1]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-5  tag: 0  disable:NO  doNotSort:NO];		
	sprite = array->arr[0];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 1  tag: 1  disable:YES doNotSort:NO];			
    sprite = array->arr[3]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 0  disable:NO  doNotSort:NO];					
    sprite = array->arr[2];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:NO];		
    sprite = array->arr[5];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-1  tag: 1  disable:NO  doNotSort:NO];			
	sprite = array->arr[4];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag:-3  disable:YES doNotSort:NO];		
	sprite = array->arr[7];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 5  tag: 0  disable:YES doNotSort:NO];		
	sprite = array->arr[6];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag: 5  disable:YES doNotSort:NO];	
	sprite = array->arr[8];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 1  tag: 1  disable:YES doNotSort:NO];		
	sprite = array->arr[9]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag: 8  disable:YES doNotSort:NO];		
	sprite = array->arr[10];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:NO];
	
	if(nl)	
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];
	
	result = [[CCTouchDispatcher sharedDispatcher] removeAllDelegates:kCCStandard];	
	CCLOG(@" 6 Various... removeAllDelegates:kCCStandard]; number of removals = %d, expected 15",result);		
				
	
	CCLOG(@"--------------------------------------");	
	CCLOG(@" 6 Various...	ADDING DELEGATES in the order of being added");
	CCLOG(@"--------------------------------------");				
	
			
    sprite = array->arr[0]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-5  tag: 0  disable:NO  doNotSort:YES];		
	sprite = array->arr[1];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 1  tag: 1  disable:YES doNotSort:YES];			
    sprite = array->arr[2]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 0  disable:NO  doNotSort:YES];					
    sprite = array->arr[3];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:YES];		
    sprite = array->arr[4];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-1  tag: 1  disable:NO  doNotSort:YES];			
	sprite = array->arr[5];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag:-3  disable:YES doNotSort:YES];		
	sprite = array->arr[6];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 5  tag: 0  disable:YES doNotSort:YES];		
	sprite = array->arr[7];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag: 5  disable:YES doNotSort:YES];	
	sprite = array->arr[8];	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 1  tag: 1  disable:YES doNotSort:YES];		
	sprite = array->arr[9]; [[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority:-3  tag: 8  disable:YES doNotSort:YES];		
	sprite = array->arr[10];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:YES];
	sprite = array->arr[11];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 0  disable:YES doNotSort:YES];
	sprite = array->arr[12];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 2  tag: 1  disable:YES doNotSort:YES];	
	sprite = array->arr[13];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 2  tag: 0  disable:YES doNotSort:YES];	
	sprite = array->arr[14];[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:sprite priority: 0  tag: 1  disable:YES doNotSort:YES];
		
	if(nl){		
		CCLOG(@" 6 Various... before sort:");
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];
	}		

	//--------------------------------------------
	//		SORTING
	//--------------------------------------------
	
	
	CCLOG(@"----------------------------------");	
	CCLOG(@" 6 Various...	SORTING");
	CCLOG(@"----------------------------------");	
	
	[[CCTouchDispatcher sharedDispatcher] setReversePriority:NO];		// default	
		[[CCTouchDispatcher sharedDispatcher] setUsersComparator:NULL];	// default
	if(nl)	
		CCLOG(@" 6 Various... after standard CCAlgInsertionSort sort:");
	[[CCTouchDispatcher sharedDispatcher] sortDelegates:kCCStandard];
	if(nl)		
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];

	if(nl)	
		CCLOG(@" 6 Various... after custom sort tag && priority:");
	[[CCTouchDispatcher sharedDispatcher] setUsersComparator:myComparatorArg];	// change sorting comparator
	[[CCTouchDispatcher sharedDispatcher] sortDelegates:kCCStandard];
	if(nl)		
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];

	if(nl)	
		CCLOG(@" 6 Various... after no custom, reverse priority with kCCAlgQSort");
	[[CCTouchDispatcher sharedDispatcher] setReversePriority:YES];	 // reverse sorting
	[[CCTouchDispatcher sharedDispatcher] setUsersComparator:NULL]; // change sorting comparator
	[[CCTouchDispatcher sharedDispatcher] setSortingAlgorithm:kCCAlgQSort];	
	[[CCTouchDispatcher sharedDispatcher] sortDelegates:kCCStandard];
	if(nl)		
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];	
	
	if(nl)		
		CCLOG(@" 6 Various... sort with kCCAlgMergeLSort zOrderComparator Notice: zOrder(==spriteTag) ");	
	[[CCTouchDispatcher sharedDispatcher] setReversePriority:NO];	 // reverse sorting	
	[[CCTouchDispatcher sharedDispatcher] setUsersComparator: zOrderComparator]; // change sorting comparator
	[[CCTouchDispatcher sharedDispatcher] setSortingAlgorithm:kCCAlgMergeLSort];	
	[[CCTouchDispatcher sharedDispatcher] sortDelegates:kCCStandard];
    
	if(nl)		
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];	
	
	
	//---------------------------------
	// counting delegates
	//---------------------------------
	
	/* return number of delegates of the given type
	 User's callback safe: delegates in the process of being removed are not counted. 
	 @since v1.1.0
	 */		

	
	CCLOG(@"----------------------------------");	
	CCLOG(@" 6 Various... COUNTING DELEGATES");
	CCLOG(@"----------------------------------");
	
	result = [[CCTouchDispatcher sharedDispatcher] countDelegatesUsage:kCCStandard];
	CCLOG(@" 6 Various... countDelegatesUsage %d should be 15 ",result);
	
	/* checks if the touch delegate is already added to the dispatcher's list of the given type 
	 It may be important since any attempt to add two identical delegates triggers the 'NSAssert'. 
	 User's callback safe: 
	 It returns 0 if delegate does not exist or is marked for removal or >0 if delegate is added. 
	 If delegate is marked for removal adding the same delegate is safe.  
	 @since v1.1.0
	 */
	result = [[CCTouchDispatcher sharedDispatcher]  countDelegateUsage:sprite type:kCCStandard];
	CCLOG(@" 6 Various... countDelegateUsage %d should be 1 ",result);
	
	/* returns number of delegates with the specified tag
	 User's callback safe: delegates in the process of being removed are not counted. 
	 */
	result = [[CCTouchDispatcher sharedDispatcher]  countTagUsage:1 type:kCCStandard];
	CCLOG(@" 6 Various... countTagUsage %d should be 7 ",result);
	
	/* returns number of delegates with the specified priority
	 User's callback safe: delegates in the process of being removed are not counted. 
	 @since v1.1.0
	 */
	result = [[CCTouchDispatcher sharedDispatcher]  countPriorityUsage:-3 type:kCCStandard];
	CCLOG(@" 6 Various... countPriorityUsage %d should be 3 ",result);
	
	/* returns number of delegates with the specified disable value ((Use: YES or NO)
	 User's callback safe: delegates in the process of being removed are not counted. 
	 @since v1.1.0
	 */
	result = [[CCTouchDispatcher sharedDispatcher]  countDisableUsage:NO type:kCCStandard];
		CCLOG(@" 6 Various... countDisableUsage %d should be 3 ",result);
	
	/* returns number of delegates with the specified value for given field 
	 User's callback safe: delegates in the process of being removed are not counted. 
	 Notice: It is generic functions covering all sugar 'countThisFieldUsage()' functions
	 @since v1.1.0
	 */
	result = [[CCTouchDispatcher sharedDispatcher]  countFieldUsage:kCCDisable fieldValue:YES type:kCCStandard];
	CCLOG(@" 6 Various... countFieldUsage:kCCDisable %d should be 12 ",result);
	

	CCLOG(@"---------------------------------------------");
	CCLOG(@" 6 Various... RETRIEVE FIELD OF THE DELEGATE ");
	CCLOG(@"---------------------------------------------");	
	
	//----------------------------------
	// retrieval of the field value
	// ---------------------------------
	/* returns priority of the delegate or NSNotFound when delegate does not exist 
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher]  retrievePriorityField:sprite type:kCCStandard];
	CCLOG(@" 6 Various... retrievePriorityField %d - should be 0 ",result);

	/* returns tag of the delegate or NSNotFound when delegate does not exist 
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] retrieveTagField:sprite type:kCCStandard];
	CCLOG(@" 6 Various... retrieveTagField %d - should be 1 ",result);

	/* returns value of the disable field or NSNotFound when delegate does not exist 
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] retrieveDisableField:sprite type:kCCStandard];
	CCLOG(@" 6 Various... retrieveDisableField %d - should be 1 ",result);

	/* returns value of the field or NSNotFound when delegate does not exist 
	Notice: It is generic functions covering all sugar 'retrieve*Field(.)' functions
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] retrieveField:kCCRemove delegate:sprite type:kCCStandard];
	CCLOG(@" 6 Various... retrieveField:kCCRemove %d - should be 0 ",result);	
	
	//--------------------------------
	// disabling of the delegate/s
	//--------------------------------
	
	CCLOG(@"-----------------------------------------");
	CCLOG(@" 6 Various... DISABLING OF THE DELEGATE/S");
	CCLOG(@"-----------------------------------------");	
	

	/* disables/enables already added touch delegate 
	@since v1.1.0
	*/			
	result = [[CCTouchDispatcher sharedDispatcher] disableDelegate:sprite disable:NO type:kCCStandard];
	CCLOG(@" 6 Various... Nr of obj affected by disableDelegate:sprite disable:NO type:kCCStandard]; disable=%d,  should be 0;  result = %d",
	[[CCTouchDispatcher sharedDispatcher] retrieveDisableField:sprite type:kCCStandard], result );	

	/*  disables/enables all delegates of the given type 
	returns number of disabled delegates
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] disableAllDelegates:NO type:kCCStandard];
	CCLOG(@" 6 Various... Nr of obj affected by disableAllDelegates:NO type:kCCStandard]; = %d,  should be 15 (60 in callback)", result);	
	
	/* disables/enables already added touch delegates of the given type
	with specified tag. (That allows fast selective disabling without removing and adding to the list)
	returns number of disabled delegates
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] disableDelegatesWithTag:1 disable:YES type:kCCStandard];
	CCLOG(@" 6 Various... Nr of obj affected by disableDelegatesWithTag:1 disable:YES type:kCCStandard]; = %d,   should be 7 (28 in callback)", result);
	
	/* disables/enables already added targeted touch delegates of the given type
	with specified priority (including marked for removal).
	returns number of disabled delegates 
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] disableDelegatesWithPriority:-3 disable:YES type:kCCStandard];
	CCLOG(@" 6 Various... Nr of obj affected by disableDelegatesWithPriority:-3 disable:YES type:kCCStandard]; = %d,   should be 3 (12 in callback)", result);

	/* inside the event loop delegates marked for removal still receive touches (default)
	'disableRemovedDelegates' disables/enables delegates marked for removal inside the event loop.
	Use it inside the touch callback function if you do not want removed delegates to be active
	during event loop.
	returns number of disabled delegates (including marked for removal)
	@since v1.1.0
	*/ 
	
	result = [[CCTouchDispatcher sharedDispatcher] disableRemovedDelegates:YES type:kCCStandard];
	CCLOG(@" 6 Various... Nr of obj affected by disableRemovedDelegates:YES type:kCCStandard]; = %d,   should be 0 (45 in callback)", result);

	/* generic function to disable/enable delagates when a specific field contains certain value.  
	The content of the field is evaluated against ar1 and arg2 using (ccOperators)op.
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] disableDelegatesWithField:kCCTag arg1:1 arg2:CC_UNUSED_ARGUMENT operator:kCCEQ disable:YES type:kCCStandard];
	CCLOG(@" 6 Various... Nr of obj affected by disableDelegatesWithField:kCCTag arg1:1 arg2:CC_UNUSED_ARGUMENT operator:kCCEQ disable:YES type:kCCStandard]; = %d, should be 7 (28 in callback)", result);

	
	//-------------------------------------------------------------------------
	// setting value of the specific field to a new value for the given delegate
	//-------------------------------------------------------------------------
	
	CCLOG(@"-----------------------------------------");
	CCLOG(@" 6 Various... SETTING FIELDS TO NEW VALUES");
	CCLOG(@"-----------------------------------------");		
	
	

	CCLOG(@" 6 Various... debug log for the specific sprite before changing its fields:\n");
	result = [[CCTouchDispatcher sharedDispatcher] setField:kCCDebug newValue:1 delegate:sprite type:kCCStandard];
	
	/* Changes the priority of the previously added delegate.
	It will force new sort only if new value is different from the old one.
	returns the number of affected delegates. Removed delegates are not considered.
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] setPriority:-77 delegate:sprite delay:NO type:kCCStandard];
	CCLOG(@" 6 Various... seting tag field to -77, result=%d", result);
	/* set a new tag for delegate
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] setTag:66 delegate:sprite type:kCCStandard];
	CCLOG(@" 6 Various... seting pri field to 66, result=%d", result);
	/* setDisable == disableDelegate  - disable/enable delegate
	@since v1.1.0
	*/
	result = [[CCTouchDispatcher sharedDispatcher] setDisable:NO delegate:sprite type:kCCStandard];
	CCLOG(@" 6 Various... seting disable field to NO, result=%d", result);		

	/* generic power function: sets value of the specific field to a new value.
	Return number of affected delegates. It returns 0 if delegate is not found. Less than 0 for an error.  
	@since v1.1.0
	*/
	
	result = [[CCTouchDispatcher sharedDispatcher] setField:kCCRemoveToDo newValue:1 delegate:sprite type:kCCStandard];
	CCLOG(@" 6 Various... marking sprite for removal, result=%d", result);	
	
	/* debug */
	CCLOG(@" 6 Various... debug log after changes:\n");	
	result = [[CCTouchDispatcher sharedDispatcher] setField:kCCDebug newValue:1 delegate:sprite type:kCCStandard];

	result = [[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCStandard];					
	CCLOG(@" 6 Various... removing marked for removal delegates, number of removals = %d",result);	
	
	/* Removes the delegate of the given type, releasing the delegate 
	 @since v1.1.0
	 */	
	result = [[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCStandard];					
	CCLOG(@" 6 Various... repeating removing marked for removal delegates, number of removals = %d",result);	
		
	result = [[CCTouchDispatcher sharedDispatcher] removeDelegate:sprite delay:NO type:kCCStandard];
	CCLOG(@" 6 Various... removing same delegate removeDelegate:sprite type:kCCStandard]; number of removals = %d",result);			
	/* setRemove == removeDelegate - remove delegate 
	 @since v1.1.0
	 */
	result = [[CCTouchDispatcher sharedDispatcher] setRemove:sprite delay:NO type:kCCStandard];	
	CCLOG(@" 6 Various... removing same delegate setRemove:sprite type:kCCStandard]; number of removals = %d",result);	
		
	result = [[CCTouchDispatcher sharedDispatcher] retrieveField:kCCRemove delegate:sprite type:kCCStandard];
	CCLOG(@" 6 Various... retrieveField:kCCRemove=%d, should be NSNotFound=NSIntegerMax e.g:(2147483647)",result);		
	
	
	//------------------------------------------------------------------------------------------------
	// setting new value for a delegates specific field conditional on the value of other(same) field
	//------------------------------------------------------------------------------------------------
	/** sets new priority for all delegates with the given tag
	 @since v1.1.0
	 */
		
	
	if(nl)	{
		CCLOG(@" 6 Various... Printing log before: setting delegates with tag==0 to have priority= -33");
		CCLOG(@" 6 Various...                 setting all delegates with priority==-33 to have tag= 22");
		CCLOG(@" 6 Various...                 setting all delegates with priority==-33 to be disabled!");			  
			  
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];	
	}	
			  
	result = [[CCTouchDispatcher sharedDispatcher] setPriorityForTag:0 newPriority:-33 delay:NO type:kCCStandard];
			  
	/** sets new tag for all delegates with the given priority 
	 @since v1.1.0
	 */
	result = [[CCTouchDispatcher sharedDispatcher] setTagForPriority:-33 newTag:22 type:kCCStandard];
			  
				  			
	/** 'Only For Eagles' - generic power function - allows changes for delegates with the specific field value
	 The content of the field is evaluated against arg1 and arg2 using (ccOperators)op.
	 It returns number of affected delegates.
	 @since v1.1.0
	 */
	result = [[CCTouchDispatcher sharedDispatcher] setDelegatesField:kCCDisable newValue:0
		ifField:kCCPriority arg1:-33 arg2:CC_UNUSED_ARGUMENT operator:kCCEQ type:kCCStandard];	

	if(nl)	{
		CCLOG(@" 6 Various... results: NOTICE: since the current algorithm sorts according to z value order was not changed!");	
		[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];		
	}

	//---------------------------------
	// removal of the delegate/s
	//---------------------------------	
	
	
	CCLOG(@"----------------------------------");
	CCLOG(@" 6 Various... REMOVING DELEGATE/S");
	CCLOG(@"----------------------------------");		
		
	
	// Note: removal cannot be undone. If you need already removed delegate than add it again.
		
	/* removes all delegates of the given type with specified tag 
	 returns number of delegates removed 
	 @since v1.1.0
	 */ 
	result = [[CCTouchDispatcher sharedDispatcher] removeDelegatesWithTag:22 delay:NO type:kCCStandard];			
	CCLOG(@" 6 Various... removeDelegatesWithTag:22 type:kCCStandard]; number of removals = %d,  expected 5",result);			
	
	
	/* removes all delegates of the given type with specified priority
	 returns number of delegates removed
	 @since v1.1.0
	 */ 
	result = [[CCTouchDispatcher sharedDispatcher] removeDelegatesWithPriority:-3 delay:NO type:kCCStandard];	
	CCLOG(@" 6 Various... removeDelegatesWithPriority:-3 type:kCCStandard]; number of removals = %d,  expected 3",result);	
	
	
	/* power function: covers all 'removeDelegates*' functions. Removes delegates of the given type 
	 for which a given field contains desired value.
	 The value of the field is evaluated against arg1 and arg2 using (ccOperators)op.
	 @since v1.1.0
	 */
	result = [[CCTouchDispatcher sharedDispatcher] removeDelegatesWithField:kCCPriority arg1:1 arg2:CC_UNUSED_ARGUMENT operator:kCCEQ delay:NO type:kCCStandard];			

		CCLOG(@" 6 Various... removeDelegatesWithField:kCCPriority arg1:1 arg2:CC_UNUSED_ARGUMENT operator:kCCEQ type:kCCStandard]; number of removals = %d,  expected 2",result);
	
	
	/* removes all delegates of the given type marked for removal by the following functions used with kCCRemoveToDo field:
	 setField:kCCRemoveToDo ... or/and setDelegatesField:kCCRemoveToDo ...
	 Used that way they mark delegates to be removed at the later time. 
	 At latest delegates will be removed at the end of the callback event processing loop. 
	 returns number of delegates removed.
	 if function is called in the touch callback it returns -1. Delegates will be removed at the end of callback anyway.
	 @since v1.1.0
	 */ 
	result = [[CCTouchDispatcher sharedDispatcher] removeToDoDelegates:kCCStandard];
	CCLOG(@" 6 Various... removeToDoDelegates:kCCStandard]; number of removals = %d, expected 0 (-1 in callback)",result);	
	
			
	/* removes all delegates of the given type 
		returns number of delegates removed
		@since v1.1.0
	*/ 
		
	// END cleanup:	
	result = [[CCTouchDispatcher sharedDispatcher] removeAllDelegates:kCCStandard];	
	CCLOG(@" 6 Various... removeAllDelegates:kCCStandard]; number of removals = %d, expected 4",result);	
	
	// FINAL LOG
	CCLOG(@" 6 Various...  STANDARD HANDLERS container outside callback should be empty but it should have 60 handlers in the callback!");	
	[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:NO type:kCCStandard];		

	CCLOG(@" 6 Various...  STANDARD HANDLERS container at the end of event loop should be empty!");	
	[[CCTouchDispatcher sharedDispatcher] printDebugLog:1 afterEvents:YES type:kCCStandard];		
	
	
	if (nl){ 			
		CCLOG(@"----------------------------------");
		CCLOG(@" 6 Various...	END			  ");
		CCLOG(@"----------------------------------");
		CCLOG(@"\n\r");		
		
	}
	else {
		CCLOG(@"----------------------------------");
		CCLOG(@" 6 Various...	END (CALLBACK)  ");
		CCLOG(@"----------------------------------");	
		CCLOG(@"\n\r");		
	}			
}

-(void) update:(ccTime)dt
{
  [self variousTests];
}


- (void) testCallback:(id)sender
{	
	[self variousTests];	
}

- (id)initWithQuantityOfNodes:(unsigned int)nodes
{
	batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet1.png" capacity:200];
	
	if( ( self=[super initWithQuantityOfNodes:nodes]) ) {
		
		//_profilingTimer = [[CCProfiler timerWithName:[self profilerName] andInstance:self] retain];
		
		[self addChild:batchNode];		
		//[self scheduleUpdate];
		//[self schedule: @selector(update:) interval:5.0f];
		
		
		CCNode *menu1 = [self getChildByTag:kTagMenu];
		if (menu1)		
			[self removeChild:menu1 cleanup:YES];		
		CCNode *infoLabel = [self getChildByTag:kTagInfoLayer];
		if (infoLabel)
			[self removeChild:infoLabel cleanup:YES];			
		
		//--- Button to test callback processing -----
		CGSize s = [[CCDirector sharedDirector] winSize];
		[CCMenuItemFont setFontSize:25];
		
		CCMenuItemFont *testCallbackProcessing = [CCMenuItemFont itemFromString:@"CallBack - It should not crash:See Console!" target:self selector:@selector(testCallback:)];
		
		[testCallbackProcessing.label setColor:ccc3(200,0,20)];
		
		CCMenu *menu = [CCMenu menuWithItems:testCallbackProcessing,nil];
		menu.position = ccp(s.width/2, s.height/2);
		[self addChild:menu];
		//---------------------------------------------	
		
		[self scheduleOnce:@selector(update:) delay:1.0f]; 
	}
	
	return self;
}

- (void) dealloc
{
	[CCProfiler releaseTimer:_profilingTimer];
	[super dealloc];
}


-(NSString*) title
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
	return @"6 Various";
		else
	return @"6 new API required!";	
}
-(NSString*) subtitle
{
   if ( [[CCTouchDispatcher sharedDispatcher] respondsToSelector:@selector(locked)])
		return @"Various Tests. See console";
	else
		return @"6 Various Tests - new API required!";		
}
-(NSString*) profilerName
{
	return @"6 Various Tests";
}
@end


#endif

