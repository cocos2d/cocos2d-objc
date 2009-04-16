//
// drawing primitives test
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//

// cocos import
#import "cocos2d.h"

// local import
#import "drawPrimitivesTest.h"

enum {
	kTagSprite1 = 1,
	kTagSprite2 = 2,
	kTagSprite3 = 3,
};


static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Test1",
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


@implementation TestDemo
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[Director sharedDirector] winSize];
	
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:-1];	
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) restartCallback: (id) sender
{
	BOOL landscape = [[Director sharedDirector] landscape];
	[[Director sharedDirector] setLandscape: !landscape];

	Scene *s = [Scene node];
	[s addChild: [restartAction() node]];	

	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	BOOL landscape = [[Director sharedDirector] landscape];
	[[Director sharedDirector] setLandscape: !landscape];

	Scene *s = [Scene node];
	[s addChild: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	BOOL landscape = [[Director sharedDirector] landscape];
	[[Director sharedDirector] setLandscape: !landscape];

	Scene *s = [Scene node];
	[s addChild: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
@end

@implementation Test1
//TIP:
// Every CocosNode has a "draw" method.
// In the "draw" method you put all the code that actually draws your node.
//
// As you can see the drawing primitives aren't CocosNode. They are just helper
// functions that let's you draw basic things like: points, line, polygons and circles.
//
// TIP:
// If you want to rotate a circle or any other "primtive", you can do it by rotating
// the node.
-(void) draw
{
	CGSize s = [[Director sharedDirector] winSize];
	
	
	// simple line
	glLineWidth(1);
	drawLine( ccp(0, 0), ccp(s.width, s.height) );
	
	// line: color, width, anti-aliased
	glLineWidth( 5.0f );
	glEnable(GL_LINE_SMOOTH);
	glColor4ub(255,0,0,255);
	drawLine( ccp(0, s.height), ccp(s.width, 0) );

	
	// big point in the center
	glPointSize(64);
	glColor4ub(0,0,255,128);
	drawPoint( ccp(s.width / 2, s.height / 2) );
	
	CGPoint points[] = { ccp(60,60), ccp(70,70), ccp(60,70), ccp(70,60) };
	glPointSize(4);
	glColor4ub(0,255,255,255);
	drawPoints( points, 4);
	
	// draw a green circle with 10 segments
	glEnable(GL_LINE_SMOOTH);
	glLineWidth(16);
	glColor4ub(0, 255, 0, 255);
	drawCircle( ccp(s.width/2,  s.height/2), 100, 0, 10, NO);

	// draw a green circle with 50 segments with line to center
	glEnable(GL_LINE_SMOOTH);
	glLineWidth(2);
	glColor4ub(0, 255, 255, 255);
	drawCircle( ccp(s.width/2, s.height/2), 50, CC_DEGREES_TO_RADIANS(90), 50, YES);	
	
	// open yellow poly
	glColor4ub(255, 255, 0, 255);
	glLineWidth(10);
	CGPoint vertices[] = { ccp(0,0), ccp(50,50), ccp(100,50), ccp(100,100), ccp(50,100) };
	drawPoly( vertices, 5, NO);
	
	// closed purble poly
	glColor4ub(255, 0, 255, 255);
	glLineWidth(2);
	CGPoint vertices2[] = { ccp(30,130), ccp(30,230), ccp(50,200) };
	drawPoly( vertices2, 3, YES);
	
	
	// restore original values
	glLineWidth(1);
	glDisable(GL_LINE_SMOOTH);
	glColor4ub(255,255,255,255);
	glPointSize(1);
}
-(NSString *) title
{
	return @"draw primitives";
}
@end

#pragma mark AppController

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	Scene *scene = [Scene node];
	[scene addChild: [nextAction() node]];
			 
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
	[window release];
	[super dealloc];
}
@end
