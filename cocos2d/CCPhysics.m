/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Scott Lembcke
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCPhysics.h"
#import "CCDrawNode.h"

static void NYI(){@throw @"Not Yet Implemented";}

// Do not change this value unless you redefine the cpBitmask type to have more than 32 bits.
#define MAX_CATEGORIES 32

#define DEFAULT_FRICTION 0.7
#define DEFAULT_ELASTICITY 0.2

@interface CCPhysicsCollisionPair(Private)
@property(nonatomic, assign) cpArbiter *arbiter;
@end


@implementation CCPhysicsBody
{
	CCNode *_node;
	
	ChipmunkBody *_body;
	ChipmunkShape *_shape;
	
	NSArray *_chipmunkObjects;
}

//MARK: Constructors:

+(CCPhysicsBody *)bodyWithCircleOfRadius:(CGFloat)radius andCenter:(CGPoint)center
{
	// TODO temporary code.
	CCPhysicsBody *body = [[CCPhysicsBody alloc] init];
	body->_body = [ChipmunkBody bodyWithMass:0.0 andMoment:0.0];
	body->_body.userData = self;
	
	body->_shape = [ChipmunkCircleShape circleWithBody:body->_body radius:radius offset:center];
	body->_shape.mass = 1.0;
	body->_shape.friction = DEFAULT_FRICTION;
	body->_shape.elasticity = DEFAULT_ELASTICITY;
	body->_shape.userData = self;
	
	body->_chipmunkObjects = @[body->_body, body->_shape];
	
	return body;
}

+(CCPhysicsBody *)bodyWithRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
	// TODO temporary code.
	CCPhysicsBody *body = [[CCPhysicsBody alloc] init];
	body->_body = [ChipmunkBody bodyWithMass:0.0 andMoment:0.0];
	body->_body.userData = self;
	
	cpBB bb = {CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect)};
	body->_shape = [ChipmunkPolyShape boxWithBody:body->_body bb:bb radius:cornerRadius];
	body->_shape.mass = 1.0;
	body->_shape.friction = DEFAULT_FRICTION;
	body->_shape.elasticity = DEFAULT_ELASTICITY;
	body->_shape.userData = self;
	
	body->_chipmunkObjects = @[body->_body, body->_shape];
	
	return body;
}

+(CCPhysicsBody *)bodyWithPillFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius
{
	// TODO temporary code.
	CCPhysicsBody *body = [[CCPhysicsBody alloc] init];
	body->_body = [ChipmunkBody bodyWithMass:0.0 andMoment:0.0];
	body->_body.userData = self;
	
	body->_shape = [ChipmunkSegmentShape segmentWithBody:body->_body from:from to:to radius:cornerRadius];
	body->_shape.mass = 1.0;
	body->_shape.friction = DEFAULT_FRICTION;
	body->_shape.elasticity = DEFAULT_ELASTICITY;
	body->_shape.userData = self;
	
	body->_chipmunkObjects = @[body->_body, body->_shape];
	
	return body;
}

+(CCPhysicsBody *)bodyWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius
{
	// TODO temporary code.
	CCPhysicsBody *body = [[CCPhysicsBody alloc] init];
	body->_body = [ChipmunkBody bodyWithMass:0.0 andMoment:0.0];
	body->_body.userData = self;
	
	body->_shape = [ChipmunkPolyShape polyWithBody:body->_body count:count verts:points transform:cpTransformIdentity radius:cornerRadius];
	body->_shape.mass = 1.0;
	body->_shape.friction = DEFAULT_FRICTION;
	body->_shape.elasticity = DEFAULT_ELASTICITY;
	body->_shape.userData = self;
	
	body->_chipmunkObjects = @[body->_body, body->_shape];
	
	return body;
}

+(CCPhysicsBody *)bodyWithSegmentLoopFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius
{
	NYI(); return nil;
}

+(CCPhysicsBody *)bodyWithSegmentChainFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius
{
	NYI(); return nil;
}

//MARK: Basic Properties:

-(CGFloat)mass {return _shape.mass;}
-(void)setMass:(CGFloat)mass {_shape.mass = mass;}

-(CGFloat)density {return _shape.density;}
-(void)setDensity:(CGFloat)density {_shape.density = density;}

-(CGFloat)area {return _shape.area;}

-(CGFloat)friction {return _shape.friction;}
-(void)setFriction:(CGFloat)friction {_shape.friction = friction;}

-(CGFloat)elasticity {return _shape.elasticity;}
-(void)setElasticity:(CGFloat)elasticity {_shape.elasticity = elasticity;}

-(CGPoint)surfaceVelocity {return _shape.surfaceVelocity;}
-(void)setSurfaceVelocity:(CGPoint)surfaceVelocity {_shape.surfaceVelocity = surfaceVelocity;}


//MARK: Simulation Properties:

-(CCPhysicsNode *)physicsNode {return _body.space.userData;}

-(BOOL)affectedByGravity {NYI(); return YES;}
-(void)setAffectedByGravity:(BOOL)affectedByGravity {NYI();}

-(BOOL)allowsRotation {NYI(); return YES;}
-(void)setAllowsRotation:(BOOL)allowsRotation {NYI();}

static ccPhysicsBodyType ToCocosBodyType[] = {kCCPhysicsBodyTypeDynamic, kCCPhysicsBodyTypeKinematic, kCCPhysicsBodyTypeStatic};
static cpBodyType ToChipmunkBodyType[] = {CP_BODY_TYPE_DYNAMIC, CP_BODY_TYPE_KINEMATIC, CP_BODY_TYPE_STATIC};

-(ccPhysicsBodyType)type {return ToCocosBodyType[_body.type];}
-(void)setType:(ccPhysicsBodyType)type {_body.type = ToChipmunkBodyType[type];}

//MARK: Collision and Contact:

-(id)collisionGroup {return _shape.group;};
-(void)setCollisionGroup:(id)collisionGroup {_shape.group = collisionGroup;}

// TODO these need a reference to the space to intern the strings
// Needs to be deferred?
-(NSString *)collisionType {NYI(); return (NSString *)_shape.collisionType;}
-(void)setCollisionType:(NSString *)collisionType {NYI();}

-(NSArray *)collisionCategories {NYI(); return @[];}
-(void)setCollisionCategories:(NSArray *)collisionCategories {NYI();}

-(NSArray *)collisionMask {NYI(); return @[];}
-(void)setCollisionMask:(NSArray *)collisionMask {NYI();}

-(void)eachContactPair:(void (^)(CCPhysicsCollisionPair *))block
{
	// TODO Need to implement the CCPhysicsCollisionPair type first.
	NYI();
	cpBodyEachArbiter_b(_body.body, ^(cpArbiter *arbiter){});
}

//MARK: Velocity

-(CGPoint)velocity {return _body.velocity;}
-(void)setVelocity:(CGPoint)velocity {_body.velocity = velocity;}

-(CGFloat)angularVelocity {return _body.angularVelocity;}
-(void)setAngularVelocity:(CGFloat)angularVelocity {_body.angularVelocity = angularVelocity;}

//MARK: Forces, Torques and Impulses:

-(CGPoint)force {return _body.force;}
-(void)setForce:(CGPoint)force {_body.force = force;}

-(CGFloat)torque {return _body.torque;}
-(void)setTorque:(CGFloat)torque {_body.torque = torque;}

-(void)applyTorque:(CGFloat)torque {_body.torque += torque;}
-(void)applyAngularImpulse:(CGFloat)impulse {_body.angularVelocity += impulse/_body.moment;}

-(void)applyForce:(CGPoint)force {_body.force = cpvadd(_body.force, force);}
-(void)applyImpulse:(CGPoint)impulse {_body.velocity = cpvadd(_body.velocity, cpvmult(impulse, 1.0f/_body.moment));}

-(void)applyForce:(CGPoint)force atLocalPoint:(CGPoint)point
{
	cpVect f = cpTransformVect(_body.transform, force);
	[_body applyForce:f atLocalPoint:point];
}

-(void)applyImpulse:(CGPoint)impulse atLocalPoint:(CGPoint)point
{
	cpVect j = cpTransformVect(_body.transform, impulse);
	[_body applyImpulse:j atLocalPoint:point];
}

-(void)applyForce:(CGPoint)force atWorldPoint:(CGPoint)point {[_body applyForce:force atWorldPoint:point];}
-(void)applyImpulse:(CGPoint)impulse atWorldPoint:(CGPoint)point {[_body applyImpulse:impulse atWorldPoint:point];}

//MARK: Misc.

-(NSArray *)joints
{
	NYI();
	return @[];
}

-(BOOL)sleeping {return _body.isSleeping;}

@end


@implementation CCPhysicsBody(ObjectiveChipmunk)

-(cpVect)absolutePosition {return _body.position;}
-(void)setAbsolutePosition:(cpVect)absolutePosition {_body.position = absolutePosition;}

-(cpFloat)absoluteRadians {return _body.angle;}
-(void)setAbsoluteRadians:(cpFloat)absoluteRadians {_body.angle = absoluteRadians;}

-(cpTransform)absoluteTransform {return _body.transform;}

//-(cpVect)

-(CCNode *)node {return _node;}
-(void)setNode:(CCNode *)node {_node = node;}

-(NSArray *)chipmunkObjects {return _chipmunkObjects;}

@end


@interface CCPhysicsJoint(ObjectiveChipmunk)

@property(nonatomic, readonly) ChipmunkConstraint *constraint;

@end


@implementation CCPhysicsJoint

-(id)init
{
	@throw @"CCPhysicsJoint is an abstract class.";
}

-(CCPhysicsBody *)bodyA {return self.constraint.bodyA.userData;}
-(void)setBodyA:(CCPhysicsBody *)bodyA {NYI();}

-(CCPhysicsBody *)bodyB {return self.constraint.bodyB.userData;}
-(void)setBodyB:(CCPhysicsBody *)bodyB {NYI();}

-(CGFloat)maxForce {return self.constraint.maxForce;}
-(void)setMaxForce:(CGFloat)maxForce {self.constraint.maxForce = maxForce;}

-(CGFloat)maxBias {return self.constraint.maxBias;}
-(void)setMaxBias:(CGFloat)maxBias {self.constraint.maxBias = maxBias;}

-(CGFloat)impulse {return self.constraint.impulse;}

-(BOOL)enabled {NYI(); return NO;}
-(void)setEnabled:(BOOL)enabled {NYI();}

-(void)setBreakingForce:(CGFloat)breakingForce {NYI();}

@end


@implementation CCPhysicsCollisionPair {
	cpArbiter *_arbiter;
}

-(cpArbiter *)arbiter {return _arbiter;}
-(void)setArbiter:(cpArbiter *)arbiter {_arbiter = arbiter;}

// Check that the arbiter is set and return it.
-(cpArbiter *)arb
{
	NSAssert(_arbiter, @"Do not store references to CCPhysicsCollisionPair objects.");
	return _arbiter;
}

-(BOOL)ignore
{
	return cpArbiterIgnore(self.arb);
}

-(CGFloat)friction {return cpArbiterGetFriction(self.arb);}
-(void)setFriction:(CGFloat)friction {cpArbiterSetFriction(self.arb, friction);}

-(CGFloat)restitution {return cpArbiterGetRestitution(self.arb);}
-(void)setRestitution:(CGFloat)restitution {cpArbiterSetRestitution(self.arb, restitution);}

-(CGPoint)surfaceVelocity {return cpArbiterGetSurfaceVelocity(self.arb);}
-(void)setSurfaceVelocity:(CGPoint)surfaceVelocity {cpArbiterSetSurfaceVelocity(self.arb, surfaceVelocity);}

-(CGFloat)totalKineticEnergy {return cpArbiterTotalKE(self.arb);}
-(CGPoint)totalImpulse {return cpArbiterTotalImpulse(self.arb);}

-(id)userData {return cpArbiterGetUserData(self.arb);}
-(void)setUserData:(id)userData {cpArbiterSetUserData(self.arb, userData);}

@end


@implementation CCPhysicsNode {
	ChipmunkSpace *_space;
	
	NSMutableDictionary *_internedStrings;
	NSMutableArray *_categories;
	
	CCDrawNode *_debug;
}

// Used by CCNode.physicsNode
-(BOOL)isPhysicsNode {return YES;}

-(id)init
{
	if((self = [super init])){
		_space = [[ChipmunkSpace alloc] init];
		_space.gravity = cpvzero;
		_space.sleepTimeThreshold = 0.5f;
		_space.userData = self;
		
		_internedStrings = [NSMutableDictionary dictionary];
		_categories = [NSMutableArray array];
		
		_debug = [CCDrawNode node];
		[self addChild:_debug z:1000]; // TODO magic z-order
	}
	
	return self;
}

-(ChipmunkSpace *)space {return _space;}

-(CGPoint)gravity {return _space.gravity;}
-(void)setGravity:(CGPoint)gravity {_space.gravity = gravity;}

-(ccTime)sleepTimeThreshold {return _space.sleepTimeThreshold;}
-(void)setSleepTimeThreshold:(ccTime)sleepTimeThreshold {_space.sleepTimeThreshold = sleepTimeThreshold;}

-(void)setDelegate:(id<CCPhysicsCollisionPairDelegate>)delegate {NYI();}

//MARK: Queries:

-(CCPhysicsBody *)pointQueryAt:(CGPoint)point within:(CGFloat)radius block:(BOOL (^)(CCPhysicsBody *, CGPoint, CGFloat))block
{
	NYI();
	return nil;
}

-(CCPhysicsBody *)rayQueryFirstFrom:(CGPoint)start to:(CGPoint)end block:(BOOL (^)(CCPhysicsBody *, CGPoint, CGPoint, CGFloat))block
{
	NYI();
	return nil;
}

-(BOOL)rectQuery:(CGRect)rect block:(BOOL (^)(CCPhysicsBody *))block
{
	NYI();
	return NO;
}

//MARK: Interned Strings and Categories:

-(NSString *)internString:(NSString *)string
{
	NSString *interned = [_internedStrings objectForKey:string];
	if(interned == nil){
		interned = [string copy];
		[_internedStrings setObject:interned forKey:interned];
	}
	
	return interned;
}

-(NSUInteger)indexForCategory:(NSString *)category
{
	// Add the category if it doesn't exist yet.
	if(![_categories containsObject:category]){
		NSAssert(_categories.count <= MAX_CATEGORIES, @"A space can only track up to %d categories.", MAX_CATEGORIES);
		[_categories addObject:category];
	}
	
	return [_categories indexOfObject:category];
}

-(cpBitmask)bitmaskForCategories:(NSArray *)categories
{
	cpBitmask bitmask = 0;
	
	for(NSString *category in categories){
		bitmask |= (1 << [self indexForCategory:category]);
	}
	
	return bitmask;
}

//MARK: Lifecycle and Scheduling

-(void)onEnter
{
	[super onEnter];
	[self scheduleUpdate];
}

-(void)onExit
{
	[super onExit];
	[self unscheduleUpdate];
}

-(void)fixedUpdate:(ccTime)delta
{
	[_space step:1.0f/60.0f];
}

-(void)update:(ccTime)delta
{
	// TODO need a real fixed time step here.
	[self fixedUpdate:1.0/60.0];
}

//MARK: Debug Drawing:

static inline ccColor4F ToCCColor4f(cpSpaceDebugColor c){return (ccColor4F){c.r, c.g, c.b, c.a};}

static void
DrawCircle(cpVect p, cpFloat a, cpFloat r, cpSpaceDebugColor outline, cpSpaceDebugColor fill, CCDrawNode *draw)
{[draw drawDot:p radius:r color:ToCCColor4f(fill)];}

static void
DrawSegment(cpVect a, cpVect b, cpSpaceDebugColor color, CCDrawNode *draw)
{[draw drawSegmentFrom:a to:b radius:1.0 color:ToCCColor4f(color)];}

static void
DrawFatSegment(cpVect a, cpVect b, cpFloat r, cpSpaceDebugColor outline, cpSpaceDebugColor fill, CCDrawNode *draw)
{[draw drawSegmentFrom:a to:b radius:r color:ToCCColor4f(fill)];}

static void
DrawPolygon(int count, const cpVect *verts, cpFloat r, cpSpaceDebugColor outline, cpSpaceDebugColor fill, CCDrawNode *draw)
{[draw drawPolyWithVerts:verts count:count fillColor:ToCCColor4f(fill) borderWidth:1.0 borderColor:ToCCColor4f(outline)];}

static void
DrawDot(cpFloat size, cpVect pos, cpSpaceDebugColor color, CCDrawNode *draw)
{[draw drawDot:pos radius:size/2.0 color:ToCCColor4f(color)];}

static cpSpaceDebugColor
ColorForShape(cpShape *shape, CCDrawNode *draw)
{return (cpSpaceDebugColor){0.8, 0.0, 0.0, 0.75};}

-(void)draw
{
	cpSpaceDebugDrawOptions drawOptions = {
		(cpSpaceDebugDrawCircleImpl)DrawCircle,
		(cpSpaceDebugDrawSegmentImpl)DrawSegment,
		(cpSpaceDebugDrawFatSegmentImpl)DrawFatSegment,
		(cpSpaceDebugDrawPolygonImpl)DrawPolygon,
		(cpSpaceDebugDrawDotImpl)DrawDot,
		
		CP_SPACE_DEBUG_DRAW_SHAPES | CP_SPACE_DEBUG_DRAW_CONSTRAINTS | CP_SPACE_DEBUG_DRAW_COLLISION_POINTS,
		
		{1.0, 1.0, 1.0, 1.0},
		(cpSpaceDebugDrawColorForShapeImpl)ColorForShape,
		{0.0, 1.0, 0.0, 1.0},
		{1.0, 0.0, 0.0, 1.0},
		_debug,
	};
	
	[_debug clear];
	cpSpaceDebugDraw(_space.space, &drawOptions);
	
	cpSpaceEachBody_b(_space.space, ^(cpBody *body){
		if(cpBodyGetType(body) == CP_BODY_TYPE_DYNAMIC){
			[_debug drawDot:cpBodyGetPosition(body) radius:5.0 color:ccc4f(1, 0, 0, 1)];
			
			cpVect cog = cpBodyLocalToWorld(body, cpBodyGetCenterOfGravity(body));
			[_debug drawDot:cog radius:5.0 color:ccc4f(1, 1, 0, 1)];
//			CCLOG(@"%p cog: %@", body, NSStringFromCGPoint(cog));
		}
	});
}

@end
