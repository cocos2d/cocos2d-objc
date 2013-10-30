//
// Click and Move demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

#import "cocos2d.h"
#import "BaseAppController.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface MainLayer : CCLayer<CCPhysicsCollisionDelegate>
@end

@implementation MainLayer

// This method is called anytime the ball collides with something.
// The argument names in collision delegate methods correspond to the collisionType strings set on the CCPhysicsBody objects.
-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball wildcard:(CCNode *)other
{
	// Ball collisions should always be perfectly bouncy and frictionless.
	pair.friction = 0.0;
	pair.restitution = 1.0;
	
	return YES;
}

// This is called when the ball collides with a block.
-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball block:(CCNode *)block
{
	[block removeFromParent];
	
	return YES;
}

//-(void)setup_
//{
//	
//	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
////	physicsNode.gravity = ccp(0.0, -100.0);
//	physicsNode.collisionDelegate = self;
//	physicsNode.debugDraw = YES;
//	[self addChild:physicsNode];
//	
//	// Add the ball
//	{
//		CCSprite *sprite = [CCSprite spriteWithFile: @"r1.png"];
//		sprite.position = ccp(240, 50);
//		
//		CGSize size = sprite.contentSize;
//		CGFloat radius = (size.width + size.height)/4.0;
//		sprite.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:radius andCenter:sprite.anchorPointInPoints];
//		sprite.physicsBody.collisionType = @"ball";
//		sprite.physicsBody.velocity = ccpMult(ccp(CCRANDOM_MINUS1_1(), CCRANDOM_MINUS1_1()), 600.0);
//		
//		[physicsNode addChild:sprite];
//	}
//	
//	// Add some blocks.
//	for(int j=0; j<3; j++){
//		for(int i=0; i<8; i++){
//			CCSprite *sprite = [CCSprite spriteWithFile: @"blocks.png"];
//			
//			CGSize size = sprite.contentSize;
//			sprite.position = ccp(size.width*(i + 0.5), 320 - size.height*(j + 0.5));
//			sprite.scaleX = 0.5 + 0.5*CCRANDOM_0_1();
//			sprite.scaleY = 0.5 + 0.5*CCRANDOM_0_1();
//			sprite.rotation = 30*CCRANDOM_MINUS1_1();
//			
//			CGRect rect = CGRectMake(0, 0, size.width, size.height);
//			sprite.physicsBody = [CCPhysicsBody bodyWithRect:rect cornerRadius:0.0];
//			sprite.physicsBody.type = CCPhysicsBodyTypeStatic;
//			sprite.physicsBody.collisionType = @"block";
//			
//			[physicsNode addChild:sprite];
//		}
//	}
//	
//	CGPoint points[] = {
//		CGPointMake(  0,   0),
//		CGPointMake(480,   0),
//		CGPointMake(480, 320),
//		CGPointMake(  0, 320),
//	};
//	
//	CCNode *edges = [CCNode node];
//	edges.physicsBody = [CCPhysicsBody bodyWithPolylineFromPoints:points count:4 cornerRadius:0.0 looped:true];
//	edges.physicsBody.type = CCPhysicsBodyTypeStatic;
//	[physicsNode addChild:edges];
//}

-(void)setup
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	physicsNode.gravity = ccp(0.0, -100.0);
	physicsNode.collisionDelegate = self;
	physicsNode.debugDraw = YES;
	[self addChild:physicsNode];
	
	CCSprite *sprite1, *sprite2;
	
	{
		CCSprite *sprite = [CCSprite spriteWithFile: @"blocks.png"];
		sprite.position = ccp(280, 140);
		
		CGSize size = sprite.contentSize;
		sprite.physicsBody = [CCPhysicsBody bodyWithRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:0];
		
		[physicsNode addChild:sprite];
		sprite1 = sprite;
	}
	
	{
		CCSprite *sprite = [CCSprite spriteWithFile: @"blocks.png"];
		sprite.position = ccp(200, 200);
		sprite.rotation = 30;
		sprite.scaleX = 1.5;
		sprite.scaleY = 2.0;
		
		CGSize size = sprite.contentSize;
		sprite.physicsBody = [CCPhysicsBody bodyWithRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:0];
		sprite.physicsBody.type = CCPhysicsBodyTypeStatic;
		
		[physicsNode addChild:sprite];
		sprite2 = sprite;
	}
	
//	[CCPhysicsJoint connectedPivotJointWithBodyA:sprite1.physicsBody bodyB:sprite2.physicsBody anchor:CGPointMake(0, 0)];
	CCPhysicsJoint *joint = [CCPhysicsJoint connectedPivotJointWithBodyA:sprite2.physicsBody bodyB:sprite1.physicsBody anchor:CGPointMake(sprite1.contentSize.width, sprite1.contentSize.height)];
	
	[self scheduleBlock:^(CCTimer *timer){
		[sprite1 removeFromParent];
	} delay:3.0];
	
	[self scheduleBlock:^(CCTimer *timer){
		[physicsNode addChild:sprite1];
	} delay:5.0];
	
	[self scheduleBlock:^(CCTimer *timer){
		[joint invalidate];
	} delay:7.0];
}

-(id)init
{
	if((self = [super init])){
		[self setup];
	}
	
	return self;
}

//-(void)onEnter
//{
//	[super onEnter];
//	
//	[self setup];
//}

@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];

	// Turn on display FPS
	[director_ setDisplayStats:YES];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Set multiple touches on
	[[director_ view] setMultipleTouchEnabled:YES];

	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

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

@end
