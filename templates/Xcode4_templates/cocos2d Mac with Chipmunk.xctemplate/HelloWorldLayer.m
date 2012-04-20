//
//  HelloWorldLayer.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

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

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer ()
-(void) addNewSpriteAtPosition:(CGPoint)pos;
-(void) createResetButton;
-(void) initPhysics;
@end


@implementation HelloWorldLayer

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		// title
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Click on the screen" fontName:@"Marker Felt" fontSize:36];
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
	
	space_->gravity = cpv(0, -100);
	
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
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		CCScene *s = [CCScene node];
		id child = [HelloWorldLayer node];
		[s addChild:child];
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
	
	body->p = cpv(pos.x, pos.y);
	cpSpaceAddBody(space_, body);
	
	cpShape* shape = cpPolyShapeNew(body, num, verts, cpvzero);
	shape->e = 0.5f; shape->u = 0.5f;
	cpSpaceAddShape(space_, shape);
	
	[sprite setPhysicsBody:body];
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

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

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

-(BOOL) ccMouseDown:(NSEvent *)event
{
	CGPoint location = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
	[self addNewSpriteAtPosition:location];
	
	return YES;
}

#endif
@end
