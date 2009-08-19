//
//  Box2DView.mm
//  Box2D OpenGL View
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//

//
// File heavily modified for cocos2d integration
// http://www.cocos2d-iphone.org
//

#import "Box2DView.h"

#define kAccelerometerFrequency 30
#define FRAMES_BETWEEN_PRESSES_FOR_DOUBLE_CLICK 10

Settings settings;

enum {
	kTagBox2DNode,
};

@implementation MenuLayer
+(id) menuWithEntryID:(int)entryId
{
	return [[[self alloc] initWithEntryID:entryId] autorelease];
}

- (id) initWithEntryID:(int)entryId
{
	if ((self = [super init])) {
		
		CGSize s = [[Director sharedDirector] winSize];
		
		entryID = entryId;
		
		self.isTouchEnabled = YES;
		
		Box2DView *view = [Box2DView viewWithEntryID:entryId];
		[self addChild:view z:0 tag:kTagBox2DNode];
		[view setScale:15];
		[view setAnchorPoint:ccp(0,0)];
		[view setPosition:ccp(s.width/2, s.height/3)];
		
		Label* label = [Label labelWithString:[view title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];		
		
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];		

	}
	return self;
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	id box = [MenuLayer menuWithEntryID:entryID];
	[s addChild:box];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	int next = entryID + 1;
	if( next >= g_totalEntries)
		next = 0;
	id box = [MenuLayer menuWithEntryID:next];
	[s addChild:box];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	int next = entryID - 1;
	if( next < 0 ) {
		next = g_totalEntries - 1;
	}
	
	id box = [MenuLayer menuWithEntryID:next];
	[s addChild:box];
	[[Director sharedDirector] replaceScene: s];
}

-(void) registerWithTouchDispatcher
{
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
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
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
	
	touchLocation = [[Director sharedDirector] convertCoordinate: touchLocation];
	prevLocation = [[Director sharedDirector] convertCoordinate: prevLocation];
	
	CGPoint diff = ccpSub(touchLocation,prevLocation);
	
	CocosNode *node = [self getChildByTag:kTagBox2DNode];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, diff)];
}
@end

#pragma mark -
#pragma mark Box2DView
@implementation Box2DView

+(id) viewWithEntryID:(int)entryId
{
	return [[[self alloc] initWithEntryID:entryId] autorelease];
}

- (id) initWithEntryID:(int)entryId
{    
    if ((self = [super init])) {
		
		self.isAccelerometerEnabled = YES;
		self.isTouchEnabled = YES;

		[self schedule:@selector(tick:)];

		entry = g_testEntries + entryId;
		test = entry->createFcn();
    }
		
    return self;
}

-(NSString*) title
{
	return [NSString stringWithCString:entry->name];
}

- (void)tick:(ccTime) dt
{
	test->Step(&settings);
}

-(void) draw
{
	[super draw];
	glEnableClientState(GL_VERTEX_ARRAY);
	test->m_world->DrawDebugData();
	glDisableClientState(GL_VERTEX_ARRAY);	
}

- (void)dealloc
{
	delete test;
    [super dealloc];
}

-(void) registerWithTouchDispatcher
{
	// higher priority than dragging
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-10 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[Director sharedDirector] convertCoordinate:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
//	NSLog(@"pos: %f,%f -> %f,%f", touchLocation.x, touchLocation.y, nodePosition.x, nodePosition.y);

	return test->MouseDown(b2Vec2(nodePosition.x,nodePosition.y));	
}

- (void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[Director sharedDirector] convertCoordinate:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
	
	test->MouseMove(b2Vec2(nodePosition.x,nodePosition.y));		
}

- (void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[Director sharedDirector] convertCoordinate:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
	
	test->MouseUp(b2Vec2(nodePosition.x,nodePosition.y));
}


- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	// Only run for valid values
	if (acceleration.y!=0 && acceleration.x!=0)
	{
		if (test) test->SetGravity(-acceleration.y,acceleration.x);
	}
}

@end
