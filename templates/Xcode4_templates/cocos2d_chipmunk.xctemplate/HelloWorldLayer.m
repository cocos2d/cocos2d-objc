//
//  HelloWorldLayer.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//
//
//  HelloWorldLayer.m
//  rc0chipmunk
//
//  Created by the FABRIK on 9/27/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "AppDelegate.h"

// Import the interfaces
#import "HelloWorldLayer.h"

enum {
	kTagParentNode = 1,
};

//set to 0 to test self rendered physicsSprites
#define useBatchNode 1

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer ()
-(void) addNewSpriteAtPosition:(CGPoint)pos;
-(void) createMenu;
-(void) initPhysics;
@end


@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
#elif defined(__MAC_OS_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
        
		CGSize s = [[CCDirector sharedDirector] winSize];
        
		// title
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Multi touch the screen" fontName:@"Marker Felt" fontSize:36];
		label.position = ccp( s.width / 2, s.height - 30);
		[self addChild:label z:-1];
        
		// reset button
		[self createMenu];
        
        
		// init physics
		[self initPhysics];

		// doesn't use batch node. Slower
		_spriteTexture = [[CCTextureCache sharedTextureCache] addImage:@"grossini_dance_atlas.png"];
#if useBatchNode
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithTexture:_spriteTexture];
#else
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
    
	_space = cpSpaceNew();
    
	cpSpaceSetGravity( _space, cpv(0, -100) );
    
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
		cpShapeSetElasticity( _walls[i], 1.0f );
		cpShapeSetFriction( _walls[i], 1.0f );
		cpSpaceAddStaticShape(_space, _walls[i] );
	}
    
	_debugLayer = [CCPhysicsDebugNode debugNodeForCPSpace:_space];
	_debugLayer.visible = NO;
	[self addChild:_debugLayer z:100];
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

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
    
	// Reset Button
    
    CCMenuItemLabel *reset = [CCMenuItemFont itemFromString:@"reset" target:self selector:@selector(reset)];

    CCMenuItemLabel *debug = [CCMenuItemFont itemFromString:@"debug" target:self selector:@selector(debug)];

	CCMenu *menu = [CCMenu menuWithItems: debug, reset, nil];
    
	[menu alignItemsVertically];
    
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
    
    
	[self addChild: menu z:-1];
}

- (void) reset
{
    [[CCDirector sharedDirector] replaceScene: [HelloWorldLayer scene]]; 
}

- (void) debug
{
    [_debugLayer setVisible: !_debugLayer.visible];
}
-(void) addNewSpriteAtPosition:(CGPoint)pos
{
	// physics body
	int num = 4;
	cpVect verts[] = {
		cpv(-24,-54),
		cpv(-24, 54),
		cpv( 24, 54),
		cpv( 24,-54),
	};
    
	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, CGPointZero));
	cpBodySetPos( body, pos );
	cpSpaceAddBody(_space, body);
    
	cpShape* shape = cpPolyShapeNew(body, num, verts, CGPointZero);
	cpShapeSetElasticity( shape, 0.5f );
	cpShapeSetFriction( shape, 0.5f );
	cpSpaceAddShape(_space, shape);
    
	// sprite
	CCNode *parent = [self getChildByTag:kTagParentNode];
	int posx = CCRANDOM_0_1() * 200.0f;
	int posy = CCRANDOM_0_1() * 200.0f;
	posx = (posx % 4) * 85;
	posy = (posy % 3) * 121;
    
#if useBatchNode 
    CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithBatchNode:(CCSpriteBatchNode*)parent rect:CGRectMake(posx, posy, 85, 121)];
#else
	CCPhysicsSprite *sprite = [CCPhysicsSprite spriteWithTexture:_spriteTexture rect:CGRectMake(posx, posy, 85, 121)];
#endif
	[parent addChild: sprite];
	[sprite setBody:body];
	[sprite setPosition: pos];
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
	if( [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight )
		v = cpv( -accelY, accelX);
	else
		v = cpv( accelY, -accelX);
    
	cpSpaceSetGravity( _space, cpvmult(v, 200) );
}

@end