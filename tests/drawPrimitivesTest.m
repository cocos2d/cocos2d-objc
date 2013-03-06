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
	@"TestDrawNode",
	@"TestDrawingPrimitives",
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

@implementation BaseLayer
-(id) init
{
	if( (self=[super init]) ) {

		CGSize s = [[CCDirector sharedDirector] winSize];

 		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF* l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:1];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}

		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];

		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];

		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
		item2.position = ccp( s.width/2, item2.contentSize.height/2);
		item3.position = ccp( s.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
		[self addChild: menu z:100];
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

-(NSString*) subtitle
{
	return nil;
}
@end

#pragma mark -
#pragma mark Drawing Primitives Test 1

@implementation TestDrawingPrimitives
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

	// draw a green Arc with 50 segments without line to center
	glLineWidth(2);
	ccDrawColor4B(0, 255, 255, 255);
	ccDrawArc( ccp(s.width-105, s.height/2-105), 100, CC_DEGREES_TO_RADIANS(90), CC_DEGREES_TO_RADIANS(90), 50, NO);
    
	CHECK_GL_ERROR_DEBUG();
    
	// draw a green solid Arc with 50 segments without line to center
	glLineWidth(2);
	ccDrawColor4B(0, 255, 255, 255);
	ccDrawSolidArc( ccp(s.width-105, s.height/2+105), 100, CC_DEGREES_TO_RADIANS(90), CC_DEGREES_TO_RADIANS(90), 50);
    
	CHECK_GL_ERROR_DEBUG();
    
	// draw a green solid circle with 50 segments with line to center
	glLineWidth(1);
	ccDrawColor4B(0, 255, 255, 255);
	ccDrawSolidCircle( ccp(105, s.height/2), 100, 50);
    
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

-(NSString*) subtitle
{
	return @"Drawing Primitives. Use CCDrawNode instead";
}

@end

@implementation TestDrawNode

-(id) init
{
	if( (self=[super init]) ) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];

		CCDrawNode *draw = [[CCDrawNode alloc] init];
		[self addChild:draw z:10];
		[draw release];

		// Draw 10 circles
		for( int i=0; i < 10; i++) {
			[draw drawDot:ccp(s.width/2, s.height/2) radius:10*(10-i) color:ccc4f(CCRANDOM_0_1(), CCRANDOM_0_1(), CCRANDOM_0_1(), 1)];
		}

		// Draw polygons
		CGPoint points[] = { {s.height/4,0}, {s.width,s.height/5}, {s.width/3*2,s.height} };
		[draw drawPolyWithVerts:points count:sizeof(points)/sizeof(points[0]) fillColor:ccc4f(1,0,0,0.5) borderWidth:4 borderColor:ccc4f(0,0,1,1)];
		
		// star poly (triggers buggs)
		{
			const float o=80;
			const float w=20;
			const float h=50;
			CGPoint star[] = {
				{o+w,o-h}, {o+w*2, o},						// lower spike
				{o + w*2 + h, o+w }, {o + w*2, o+w*2},		// right spike
//				{o +w, o+w*2+h}, {o,o+w*2},					// top spike
//				{o -h, o+w}, {o,o},							// left spike
			};

			[draw drawPolyWithVerts:star count:sizeof(star)/sizeof(star[0]) fillColor:ccc4f(1,0,0,0.5) borderWidth:1 borderColor:ccc4f(0,0,1,1)];
		}

		// star poly (doesn't trigger bug... order is important un tesselation is supported.
		{
			const float o=180;
			const float w=20;
			const float h=50;
			CGPoint star[] = {
				{o,o}, {o+w,o-h}, {o+w*2, o},				// lower spike
				{o + w*2 + h, o+w }, {o + w*2, o+w*2},		// right spike
				{o +w, o+w*2+h}, {o,o+w*2},					// top spike
				{o -h, o+w},								// left spike
			};
			
			[draw drawPolyWithVerts:star count:sizeof(star)/sizeof(star[0]) fillColor:ccc4f(1,0,0,0.5) borderWidth:1 borderColor:ccc4f(0,0,1,1)];
		}

		
		// Draw segment
		[draw drawSegmentFrom:ccp(20,s.height) to:ccp(20,s.height/2) radius:10 color:ccc4f(0, 1, 0, 1)];

		[draw drawSegmentFrom:ccp(10,s.height/2) to:ccp(s.width/2, s.height/2) radius:40 color:ccc4f(1, 0, 1, 0.5)];


		
	}
	
	return self;
}

-(NSString *) title
{
	return @"Test CCDrawNode";
}

-(NSString*) subtitle
{
	return @"Testing DrawNode - batched draws. Concave polygons are BROKEN";
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

	return YES;
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil){
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		CCScene *scene = [CCScene node];
		[scene addChild: [nextAction() node]];
		[director runWithScene: scene];
	}
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

