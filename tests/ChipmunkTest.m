//
// Accelerometer + Chipmunk physics + multi touches example
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import "ChipmunkTest.h"

enum {
	kTagParentNode = 1,
};

enum {
	Z_PHYSICS_DEBUG = 100,
};

// callback to remove Shapes from the Space
void removeShape( cpBody *body, cpShape *shape, void *data )
{
	cpShapeFree( shape );
}

#pragma mark - MainLayer

@interface MainLayer ()
-(void) addNewSpriteAtPosition:(CGPoint)pos;
-(void) createResetButton;
-(void) initPhysics;
@end


@implementation MainLayer

-(id) init
{
	if( (self=[super init])) {

		// enable events

#ifdef __CC_PLATFORM_IOS
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.mouseEnabled = YES;
#endif

		CGSize s = [[CCDirector sharedDirector] winSize];

		// title
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Multi touch the screen" fontName:@"Marker Felt" fontSize:36];
		label.position = ccp( s.width / 2, s.height - 30);
		[self addChild:label z:-1];

		// reset button
		[self createResetButton];

		// init physics
		[self initPhysics];

#if 1
		// Use batch node. Faster
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"grossini_dance_atlas.png" capacity:100];
		_spriteTexture = [parent texture];
#else
		// doesn't use batch node. Slower
		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"grossini_dance_atlas.png"];
		CCNode *parent = [CCNode node];
#endif
		[self addChild:parent z:0 tag:kTagParentNode];

		[self addNewSpriteAtPosition:ccp(200,200)];

		
		// menu for debug layer
		[CCMenuItemFont setFontSize:18];
		CCMenuItemFont *item = [CCMenuItemFont itemWithString:@"Toggle debug" block:^(id sender) {
			[_debugLayer setVisible: ! _debugLayer.visible];
		}];
		CCMenu *menu = [CCMenu menuWithItems:item, nil];
		[self addChild:menu];
		[menu setPosition:ccp(s.width-100, s.height-60)];
		
		[self scheduleUpdate];
	}

	return self;
}

-(void) initPhysics
{
	CGSize s = [[CCDirector sharedDirector] winSize];

	// init chipmunk
	_space = cpSpaceNew();
	cpSpaceSetGravity(_space, cpv(0, -100) );

	//
	// rogue shapes
	// We have to free them manually
	//
	// bottom
	_walls[0] = cpSegmentShapeNew( _space->staticBody, cpv(0,0), cpv(s.width,0), 0.0f);

	// top
	_walls[1] = cpSegmentShapeNew( _space->staticBody, cpv(0,s.height), cpv(s.width,s.height), 0.0f);

	// left
	_walls[2] = cpSegmentShapeNew( _space->staticBody, cpv(0,0), cpv(0,s.height), 0.0f);

	// right
	_walls[3] = cpSegmentShapeNew( _space->staticBody, cpv(s.width,0), cpv(s.width,s.height), 0.0f);

	for( int i=0;i<4;i++) {
		cpShapeSetElasticity(_walls[i], 1.0f );
		cpShapeSetFriction(_walls[i], 1.0f );
		cpSpaceAddStaticShape(_space, _walls[i] );
	}
	
	// Physics debug layer
	_debugLayer = [CCPhysicsDebugNode debugNodeForCPSpace:_space];
	[self addChild:_debugLayer z:Z_PHYSICS_DEBUG];
}

- (void)dealloc
{
	// manually Free rogue shapes
	for( int i=0;i<4;i++) {
		cpShapeFree( _walls[i] );
	}

	cpSpaceFree( _space );

	[super dealloc];

}

-(void) update:(ccTime) delta
{
	// Should use a fixed size step based on the animation interval.
	int steps = 2;
	CGFloat dt = [[CCDirector sharedDirector] animationInterval]/(CGFloat)steps;

	for(int i=0; i<steps; i++){
		cpSpaceStep(_space, dt);
	}
}

-(void) createResetButton
{
	CCMenuItemImage *reset = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" block:^(id sender) {
		CCScene *s = [CCScene node];
		id child = [[[MainLayer class] alloc] init];
		[s addChild:child];
		[child release];
		[[CCDirector sharedDirector] replaceScene: s];
	}];

	CCMenu *menu = [CCMenu menuWithItems:reset, nil];

	CGSize s = [[CCDirector sharedDirector] winSize];

	menu.position = ccp(s.width/2, 30);
	[self addChild: menu z:-1];
}

-(void) addNewSpriteAtPosition:(CGPoint)pos
{
	int posx, posy;

	CCNode *parent = [self getChildByTag:kTagParentNode];

	posx = CCRANDOM_0_1() * 200.0f;
	posy = CCRANDOM_0_1() * 200.0f;

	posx = (posx % 4) * 85;
	posy = (posy % 3) * 121;

	int num = 4;
	cpVect verts[] = {
		cpv(-24,-54),
		cpv(-24, 54),
		cpv( 24, 54),
		cpv( 24,-54),
	};

	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpvzero));
	cpBodySetPos( body, cpv(pos.x, pos.y) );
	cpSpaceAddBody(_space, body);

	cpShape* shape = cpPolyShapeNew(body, num, verts, cpvzero);
	cpShapeSetElasticity( shape, 0.5f );
	cpShapeSetFriction(shape, 0.5f );
	cpSpaceAddShape(_space, shape);

	CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithTexture:_spriteTexture rect:CGRectMake(posx, posy, 85, 121)];
	[parent addChild: sprite];

	[sprite setCPBody: body];
	[sprite setPosition: pos];
}

#pragma mark iOS Events
#ifdef	__CC_PLATFORM_IOS

-(void) onEnter
{
	[super onEnter];

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];

		location = [[CCDirector sharedDirector] convertToGL: location];

		[self addNewSpriteAtPosition: location];
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	cpVect v;
	if( [[CCDirector sharedDirector] interfaceOrientation] == UIInterfaceOrientationLandscapeRight )
		v = cpv( -accelY, accelX);
	else
		v = cpv( accelY, -accelX);
	
	cpSpaceSetGravity( _space, cpvmult(v, 200) );
}

#elif defined(__CC_PLATFORM_MAC)

#pragma mark Mac Events

-(BOOL) ccMouseUp:(NSEvent *)event
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	[self addNewSpriteAtPosition: location];

	return YES;
}


#endif

@end

#ifdef __CC_PLATFORM_IOS

#pragma mark - AppController - iOS

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Turn on multiple touches
	[director_.view setMultipleTouchEnabled:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// Assume that PVR images have the alpha channel premultiplied
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

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
		[scene addChild: [MainLayer node] ];
		[director runWithScene: scene];
	}
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

#elif defined(__CC_PLATFORM_MAC)

#pragma mark - AppController - Mac

@implementation AppController


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[super applicationDidFinishLaunching:aNotification];

	// add layer
	CCScene *scene = [CCScene node];
	[scene addChild: [MainLayer node] ];

	[director_ runWithScene:scene];
}
@end
#endif
