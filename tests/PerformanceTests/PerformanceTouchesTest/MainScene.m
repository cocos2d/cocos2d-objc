//
// cocos2d performance touches test
//

#import "MainScene.h"

enum {
	kTagInfoLayer = 1,
	kTagMainLayer = 2,
	kTagParticleSystem = 3,
	kTagLabelAtlas = 4,
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


#pragma mark MainScene

@implementation MainScene
-(id) init
{
	if( (self=[super init]) ) {


		CGSize s = [[CCDirector sharedDirector] winSize];

		CCLabelTTF *title = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: title z:1];
		[title setPosition: ccp(s.width/2, s.height-50)];

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];

		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];

		[self schedule:@selector(update:)];

		label = [CCLabelBMFont labelWithString:@"00.0" fntFile:@"arial16.fnt"];
		label.position = ccp(s.width/2, s.height/2);
		[self addChild:label];

		elapsedTime = 0;
		numberOfTouchesB = numberOfTouchesM = numberOfTouchesE = numberOfTouchesC = 0;
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) update:(ccTime)dt
{
	elapsedTime += dt;

	if ( elapsedTime > 1.0f)  {
		float frameRateB = numberOfTouchesB / elapsedTime;
		float frameRateM = numberOfTouchesM / elapsedTime;
		float frameRateE = numberOfTouchesE / elapsedTime;
		float frameRateC = numberOfTouchesC / elapsedTime;
		elapsedTime = 0;
		numberOfTouchesB = numberOfTouchesM = numberOfTouchesE = numberOfTouchesC = 0;

		NSString *str = [[NSString alloc] initWithFormat:@"%.1f %.1f %.1f %.1f", frameRateB, frameRateM, frameRateE, frameRateC];
		[label setString:str];
		[str release];
	}
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

#pragma mark -
#pragma mark Example PerformanceTest1

@implementation PerformanceTest1

-(id) init
{
	if( (self=[super init] )) {

		self.isTouchEnabled = YES;

	}

	return self;
}

-(NSString *) title
{
	return @"Targeted touches";
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void) dealloc
{
	[super dealloc];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	numberOfTouchesB++;
	return YES;
}
-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
	numberOfTouchesM++;
}
-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	numberOfTouchesE++;
}
-(void) ccTouchCancelled:(UITouch*)touch withEvent:(UIEvent*)event
{
	numberOfTouchesC++;
}

@end

#pragma mark -
#pragma mark Example PerformanceTest2

@implementation PerformanceTest2

-(id) init
{
	if( (self=[super init] )) {

		self.isTouchEnabled = YES;

	}

	return self;
}

-(NSString *) title
{
	return @"Standard touches";
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:0];
}

-(void) dealloc
{
	[super dealloc];
}

-(void) ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	numberOfTouchesB += [touches count];
}
-(void) ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	numberOfTouchesM += [touches count];
}
-(void) ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	numberOfTouchesE += [touches count];
}
-(void) ccTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
	numberOfTouchesC += [touches count];
}
@end

