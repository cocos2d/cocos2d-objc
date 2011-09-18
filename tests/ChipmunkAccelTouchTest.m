//
// Accelerometer + Chipmunk physics + multi touches example
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import "ChipmunkAccelTouchTest.h"

#import "RootViewController.h"

enum {
	kTagParentNode = 1,
};

// callback to remove Shapes from the Space
void removeShape( cpBody *body, cpShape *shape, void *data )
{
	cpShapeFree( shape );
}

#pragma mark - PhysicsSprite
@implementation PhysicsSprite

-(void) setPhysicsBody:(cpBody *)body
{
	body_ = body;
}

// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{	
	CGFloat x = body_->p.x;
	CGFloat y = body_->p.y;
	
	if ( !isRelativeAnchorPoint_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
		
	// Make matrix
	CGFloat c = body_->rot.x;
	CGFloat s = body_->rot.y;
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}
	
	// Translate, Rot, anchor Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );

	return transform_;
}

-(void) dealloc
{
	cpBodyEachShape(body_, removeShape, NULL);
	cpBodyFree( body_ );

	[super dealloc];
}

@end

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
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;

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
		spriteTexture_ = [parent texture];
#else
		// doesn't use batch node. Slower
		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"grossini_dance_atlas.png"];
		CCNode *parent = [CCNode node];		
#endif
		[self addChild:parent z:0 tag:kTagParentNode];
		
		[self addNewSpriteAtPosition:ccp(200,200)];

		[self scheduleUpdate];
	}

	return self;
}

-(void) initPhysics
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	// init chipmunk
	cpInitChipmunk();
	
	space_ = cpSpaceNew();
	
	space_->gravity = ccp(0, -100);
	
	//
	// rogue shapes
	// We have to free them manually
	//
	// bottom
	walls_[0] = cpSegmentShapeNew( space_->staticBody, ccp(0,0), ccp(s.width,0), 0.0f);

	// top
	walls_[1] = cpSegmentShapeNew( space_->staticBody, ccp(0,s.height), ccp(s.width,s.height), 0.0f);

	// left
	walls_[2] = cpSegmentShapeNew( space_->staticBody, ccp(0,0), ccp(0,s.height), 0.0f);

	// right
	walls_[3] = cpSegmentShapeNew( space_->staticBody, ccp(s.width,0), ccp(s.width,s.height), 0.0f);

	for( int i=0;i<4;i++) {
		walls_[i]->e = 1.0f;
		walls_[i]->u = 1.0f;
		cpSpaceAddStaticShape(space_, walls_[i] );
	}	
}

- (void)dealloc
{
	// manually Free rogue shapes
	for( int i=0;i<4;i++) {
		cpShapeFree( walls_[i] );
	}

	cpSpaceFree( space_ );

	[super dealloc];

}

-(void) onEnter
{
	[super onEnter];

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
}

-(void) update:(ccTime) delta
{
	// Should use a fixed size step based on the animation interval.
	int steps = 2;
	CGFloat dt = [[CCDirector sharedDirector] animationInterval]/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space_, dt);
	}
}

-(void) createResetButton
{
	CCMenuItemImage *reset = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" block:^(id sender) {
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
	
	PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(posx, posy, 85, 121)];
	[parent addChild: sprite];
	
	sprite.position = pos;
	
	int num = 4;
	CGPoint verts[] = {
		ccp(-24,-54),
		ccp(-24, 54),
		ccp( 24, 54),
		ccp( 24,-54),
	};
	
	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, CGPointZero));

	body->p = pos;
	cpSpaceAddBody(space_, body);
	
	cpShape* shape = cpPolyShapeNew(body, num, verts, CGPointZero);
	shape->e = 0.5f; shape->u = 0.5f;
	cpSpaceAddShape(space_, shape);
	
	[sprite setPhysicsBody:body];
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

	CGPoint v = ccp( accelX, accelY);

	space_->gravity = ccpMult(v, 200);
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Turn on multiple touches
	EAGLView *view = [director openGLView];
	[view setMultipleTouchEnabled:YES];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// Assume that PVR images have the alpha channel premultiplied
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	// add layer
	CCScene *scene = [CCScene node];
	[scene addChild: [MainLayer node] ];
	
	[director runWithScene:scene];
}

- (void) dealloc
{
	[window_ release];
	[viewController_ release];

	[super dealloc];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// sent to background
-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

// sent to foreground
-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
