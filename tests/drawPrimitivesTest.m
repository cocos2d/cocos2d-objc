//
// drawing primitives test
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "drawPrimitivesTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
			@"Test1",
};

Class nextAction(void);
Class backAction(void);
Class restartAction(void);

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

#pragma mark -
#pragma mark Base Class

@implementation TestDemo
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

 		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];

		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
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
#pragma mark Drawing Primitives Test 1

@implementation Test1
//
// TIP:
// Every CCNode has a "draw" method.
// In the "draw" method you put all the code that actually draws your node.
// And Test1 is a subclass of TestDemo, which is a subclass of Layer, which is a subclass of CCNode.
//
// As you can see the drawing primitives aren't CCNode objects. They are just helper
// functions that let's you draw basic things like: points, line, polygons and circles.
//
//
// TIP:
// Don't draw your stuff outide the "draw" method. Otherwise it wont get transformed.
//
//
// TIP:
// If you want to rotate/translate/scale a circle or any other "primtive", you can do it by rotating
// the node. eg:
//    self.rotation = 90;
//
-(void) draw
{
	CGSize s = [[CCDirector sharedDirector] winSize];

	CHECK_GL_ERROR_DEBUG();

	// draw a simple line
	// The default state is:
	// Line Width: 1
	// color: 255,255,255,255 (white, non-transparent)
	// Anti-Aliased
//	glEnable(GL_LINE_SMOOTH);
	ccDrawLine( ccp(0, 0), ccp(s.width, s.height) );

	CHECK_GL_ERROR_DEBUG();

	// line: color, width, aliased
	// glLineWidth > 1 and GL_LINE_SMOOTH are not compatible
	// GL_SMOOTH_LINE_WIDTH_RANGE = (1,1) on iPhone
//	glDisable(GL_LINE_SMOOTH);
	glLineWidth( 5.0f );
	ccDrawColor4B(255,0,0,255);
	ccDrawLine( ccp(0, s.height), ccp(s.width, 0) );

	CHECK_GL_ERROR_DEBUG();

	// TIP:
	// If you are going to use always the same color or width, you don't
	// need to call it before every draw
	//
	// Remember: OpenGL is a state-machine.

	// draw big point in the center
	ccPointSize(64);
	ccDrawColor4B(0,0,255,128);
	ccDrawPoint( ccp(s.width / 2, s.height / 2) );

	CHECK_GL_ERROR_DEBUG();

	// draw 4 small points
	CGPoint points[] = { ccp(60,60), ccp(70,70), ccp(60,70), ccp(70,60) };
	ccPointSize(4);
	ccDrawColor4B(0,255,255,255);
	ccDrawPoints( points, 4);

	CHECK_GL_ERROR_DEBUG();

	// draw a green circle with 10 segments
	glLineWidth(16);
	ccDrawColor4B(0, 255, 0, 255);
	ccDrawCircle( ccp(s.width/2,  s.height/2), 100, 0, 10, NO);

	CHECK_GL_ERROR_DEBUG();

	// draw a green circle with 50 segments with line to center
	glLineWidth(2);
	ccDrawColor4B(0, 255, 255, 255);
	ccDrawCircle( ccp(s.width/2, s.height/2), 50, CC_DEGREES_TO_RADIANS(90), 50, YES);

	CHECK_GL_ERROR_DEBUG();

	// open yellow poly
	ccDrawColor4B(255, 255, 0, 255);
	glLineWidth(10);
	CGPoint vertices[] = { ccp(0,0), ccp(50,50), ccp(100,50), ccp(100,100), ccp(50,100) };
	ccDrawPoly( vertices, 5, NO);

	CHECK_GL_ERROR_DEBUG();
	
	// filled poly
	glLineWidth(1);
	CGPoint filledVertices[] = { ccp(0,120), ccp(50,120), ccp(50,170), ccp(25,200), ccp(0,170) };
	ccDrawSolidPoly(filledVertices, 5, ccc4f(0.5f, 0.5f, 1, 1 ) );


	// closed purble poly
	ccDrawColor4B(255, 0, 255, 255);
	glLineWidth(2);
	CGPoint vertices2[] = { ccp(30,130), ccp(30,230), ccp(50,200) };
	ccDrawPoly( vertices2, 3, YES);

	CHECK_GL_ERROR_DEBUG();

	// draw quad bezier path
	ccDrawQuadBezier(ccp(0,s.height), ccp(s.width/2,s.height/2), ccp(s.width,s.height), 50);

	CHECK_GL_ERROR_DEBUG();

	// draw cubic bezier path
	ccDrawCubicBezier(ccp(s.width/2, s.height/2), ccp(s.width/2+30,s.height/2+50), ccp(s.width/2+60,s.height/2-50),ccp(s.width, s.height/2),100);

	CHECK_GL_ERROR_DEBUG();

    //draw a solid polygon
	CGPoint vertices3[] = {ccp(60,160), ccp(70,190), ccp(100,190), ccp(90,160)};
    ccDrawSolidPoly( vertices3, 4, ccc4f(1,1,0,1) );
        
	// restore original values
	glLineWidth(1);
	ccDrawColor4B(255,255,255,255);
	ccPointSize(1);

	CHECK_GL_ERROR_DEBUG();
}
-(NSString *) title
{
	return @"draw primitives";
}
@end

// CLASS IMPLEMENTATIONS

#ifdef __CC_PLATFORM_IOS

#pragma mark AppController - iOS

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

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
	[scene addChild: [nextAction() node]];

	[director_ pushScene: scene];

	return YES;
}
@end

#elif defined(__CC_PLATFORM_MAC)

#pragma mark AppController - Mac

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];


	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];

	[director_ runWithScene:scene];
}
@end
#endif

