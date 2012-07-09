//
// Accelerometer + Chipmunk physics + multi touches example
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import "ChipmunkAccelTouchTest.h"

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

	if ( ignoreAnchorPointForPosition_ ) {
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

#ifdef __CC_PLATFORM_IOS
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
#elif defined(__CC_PLATFORM_MAC)
		self.isMouseEnabled = YES;
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

	space_ = cpSpaceNew();
	cpSpaceSetGravity(space_, cpv(0, -100) );

	//
	// rogue shapes
	// We have to free them manually
	//
	// bottom
	walls_[0] = cpSegmentShapeNew( space_->staticBody, cpv(0,0), cpv(s.width,0), 0.0f);

	// top
	walls_[1] = cpSegmentShapeNew( space_->staticBody, cpv(0,s.height), cpv(s.width,s.height), 0.0f);

	// left
	walls_[2] = cpSegmentShapeNew( space_->staticBody, cpv(0,0), cpv(0,s.height), 0.0f);

	// right
	walls_[3] = cpSegmentShapeNew( space_->staticBody, cpv(s.width,0), cpv(s.width,s.height), 0.0f);

	for( int i=0;i<4;i++) {
		cpShapeSetElasticity(walls_[i], 1.0f );
		cpShapeSetFriction(walls_[i], 1.0f );
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

	PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(posx, posy, 85, 121)];
	[parent addChild: sprite];

	sprite.position = pos;

	int num = 4;
	cpVect verts[] = {
		cpv(-24,-54),
		cpv(-24, 54),
		cpv( 24, 54),
		cpv( 24,-54),
	};

	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpvzero));
	cpBodySetPos( body, cpv(pos.x, pos.y) );
	cpSpaceAddBody(space_, body);

	cpShape* shape = cpPolyShapeNew(body, num, verts, cpvzero);
	cpShapeSetElasticity( shape, 0.5f );
	cpShapeSetFriction(shape, 0.5f );
	cpSpaceAddShape(space_, shape);

	[sprite setPhysicsBody:body];
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
	
	cpSpaceSetGravity( space_, cpvmult(v, 200) );
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

	// add layer
	CCScene *scene = [CCScene node];
	[scene addChild: [MainLayer node] ];

	[director_ pushScene:scene];

	return YES;
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
