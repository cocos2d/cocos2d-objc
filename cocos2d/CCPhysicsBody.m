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

// Used to access cpBodyAccumulateMassFromShapes()
#define CP_ALLOW_PRIVATE_ACCESS 1

#import "CCPhysicsBody.h"
#import "CCPhysics+ObjectiveChipmunk.h"


// TODO temporary
static inline void NYI(){@throw @"Not Yet Implemented";}


#define FOREACH_SHAPE(__body__, __shapeVar__) for(CCPhysicsShape *__shapeVar__ = __body__->_shapeList; __shapeVar__; __shapeVar__ = __shapeVar__.next)


@implementation CCPhysicsBody
{
	ChipmunkBody *_body;
	CCPhysicsShape *_shapeList;
	
	NSMutableArray *_joints;
	
	NSMutableArray *_chipmunkObjects;
	
	BOOL _allowsRotation;
	BOOL _affectedByGravity;
}

//MARK: Constructors:

-(id)initWithShapeList:(CCPhysicsShape *)shapeList
{
	if((self = [super init])){
		_body = [ChipmunkBody bodyWithMass:0.0 andMoment:0.0];
		_body.userData = self;
		
		_allowsRotation = YES;
		_affectedByGravity = YES;
		
		_chipmunkObjects = [NSMutableArray arrayWithCapacity:2];
		[_chipmunkObjects addObject:_body];
		
		_shapeList = shapeList;
		FOREACH_SHAPE(self, shape){
			shape.body = self;
			[_chipmunkObjects addObject:shape.shape];
		}
	}
	
	return self;
}

+(CCPhysicsBody *)bodyWithCircleOfRadius:(CGFloat)radius andCenter:(CGPoint)center
{
	CCPhysicsShape *shape = [CCPhysicsShape circleShapeWithRadius:radius center:center];
	return [[self alloc] initWithShapeList:shape];
}

+(CCPhysicsBody *)bodyWithRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
	CCPhysicsShape *shape = [CCPhysicsShape rectShape:rect cornerRadius:cornerRadius];
	return [[self alloc] initWithShapeList:shape];
}

+(CCPhysicsBody *)bodyWithPillFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius
{
	CCPhysicsShape *shape = [CCPhysicsShape pillShapeFrom:from to:to cornerRadius:cornerRadius];
	return [[self alloc] initWithShapeList:shape];
}

+(CCPhysicsBody *)bodyWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius
{
	CCPhysicsShape *shape = [CCPhysicsShape polygonShapeWithPoints:points count:count cornerRadius:cornerRadius];
	return [[self alloc] initWithShapeList:shape];
}

+(CCPhysicsBody *)bodyWithPolylineFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius looped:(bool)looped;
{
	NSAssert(looped || count > 1, @"Non-looped polyline bodies must have at least two points.");
	NSAssert(!looped || count > 2, @"Looped polyline bodies must have at least three points.");
	
	CCPhysicsShape *shapes = nil;
	
	int limit = (looped ? count : count - 1);
	for(int i=0; i<limit; i++){
		CCPhysicsShape *shape = [CCPhysicsShape pillShapeFrom:points[i] to:points[(i + 1)%count] cornerRadius:cornerRadius];
		// TODO Broken. Values may be wrong after applying a transform in onEnter.
		//cpSegmentShapeSetNeighbors(shape.shape.shape, points[(i - 1 + count)%count], points[(i + 2)%count]);
		
		shape.next = shapes;
		shapes = shape;
	}
	
	return [[self alloc] initWithShapeList:shapes];
}

+(CCPhysicsBody *)bodyWithShapes:(NSArray *)shapes
{
	CCPhysicsShape *shapeList = nil;
	for(int i=0, count=shapes.count; i<count; i++){
		CCPhysicsShape *shape = shapes[i];
		shape.next = shapeList;
		shapeList = shape;
	}
	
	return [[self alloc] initWithShapeList:shapeList];
}

//MARK: Basic Properties:

-(CGFloat)mass
{
	CGFloat sum = 0.0;
	FOREACH_SHAPE(self, shape) sum += shape.mass;
	
	return sum;
}

-(void)setMass:(CGFloat)mass
{
	NSAssert(_shapeList.next == nil, @"Cannot set the mass of a multi-shape body directly. Set the individual shape masses instead.");
	_shapeList.mass = mass;
}

//-(CGFloat)density
//{
//	return self.mass/self.area;
//}
//
//-(void)setDensity:(CGFloat)density
//{
//	NSAssert(_shapeList.next == nil, @"Cannot set the density of a multi-shape body directly. Set the individual shape densities instead.");
//	_shapeList.density = density;
//}
//
//-(CGFloat)area
//{
//	CGFloat sum = 0.0;
//	FOREACH_SHAPE(self, shape) sum += shape.area;
//	
//	return sum;
//}

-(CGFloat)friction {return _shapeList.friction;}
-(void)setFriction:(CGFloat)friction {FOREACH_SHAPE(self, shape) shape.friction = friction;}

-(CGFloat)elasticity {return _shapeList.elasticity;}
-(void)setElasticity:(CGFloat)elasticity {FOREACH_SHAPE(self, shape) shape.elasticity = elasticity;}

-(CGPoint)surfaceVelocity {return _shapeList.surfaceVelocity;}
-(void)setSurfaceVelocity:(CGPoint)surfaceVelocity {FOREACH_SHAPE(self, shape) shape.surfaceVelocity = surfaceVelocity;}


//MARK: Simulation Properties:

-(CCPhysicsNode *)physicsNode {return _body.space.userData;}
-(BOOL)isRunning {return self.physicsNode != nil;}

//-(BOOL)affectedByGravity {NYI(); return YES;}
//-(void)setAffectedByGravity:(BOOL)affectedByGravity {NYI();}

-(BOOL)allowsRotation {return _allowsRotation;}
-(void)setAllowsRotation:(BOOL)allowsRotation
{
	if(self.isRunning){
		if(allowsRotation){
			cpBodyAccumulateMassFromShapes(_body.body);
		} else {
			_body.moment = INFINITY;
			_body.angularVelocity = 0.0;
		}
	}
	
	_allowsRotation = allowsRotation;
}

static ccPhysicsBodyType ToCocosBodyType[] = {CCPhysicsBodyTypeDynamic, CCPhysicsBodyTypeKinematic, CCPhysicsBodyTypeStatic};
static cpBodyType ToChipmunkBodyType[] = {CP_BODY_TYPE_DYNAMIC, CP_BODY_TYPE_KINEMATIC, CP_BODY_TYPE_STATIC};

-(ccPhysicsBodyType)type {return ToCocosBodyType[_body.type];}
-(void)setType:(ccPhysicsBodyType)type {_body.type = ToChipmunkBodyType[type];}

//MARK: Collision and Contact:

-(BOOL)sensor {return _shapeList.sensor;}
-(void)setSensor:(BOOL)sensor {FOREACH_SHAPE(self, shape) shape.sensor = sensor;}

-(id)collisionGroup {return _shapeList.collisionGroup;};
-(void)setCollisionGroup:(id)collisionGroup {FOREACH_SHAPE(self, shape) shape.collisionGroup = collisionGroup;}

-(NSString *)collisionType {return _shapeList.collisionType;}
-(void)setCollisionType:(NSString *)collisionType {FOREACH_SHAPE(self, shape) shape.collisionType = collisionType;}

-(NSArray *)collisionCategories {return _shapeList.collisionCategories;}
-(void)setCollisionCategories:(NSArray *)collisionCategories {FOREACH_SHAPE(self, shape) shape.collisionCategories = collisionCategories;}

-(NSArray *)collisionMask {return _shapeList.collisionMask;}
-(void)setCollisionMask:(NSArray *)collisionMask {FOREACH_SHAPE(self, shape) shape.collisionMask = collisionMask;}

-(void)eachCollisionPair:(void (^)(CCPhysicsCollisionPair *))block
{
	CCPhysicsCollisionPair *pair = [[CCPhysicsCollisionPair alloc] init];
	cpBodyEachArbiter_b(_body.body, ^(cpArbiter *arbiter){
		pair.arbiter = arbiter;
		block(pair);
	});
	
	pair.arbiter = NULL;
}

//MARK: Velocity

-(CGPoint)velocity {return _body.velocity;}
-(void)setVelocity:(CGPoint)velocity {_body.velocity = velocity;}

-(CGFloat)angularVelocity {return _body.angularVelocity;}
-(void)setAngularVelocity:(CGFloat)angularVelocity
{
#if DEBUG
	if(!self.allowsRotation) CCLOG(@"Did you intend to set the angular velocity on a physicsBody where allowsRotation is NO?");
#endif
	
	_body.angularVelocity = angularVelocity;
}

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
	return (_joints ?: [NSArray array]);
}

-(BOOL)sleeping {return _body.isSleeping;}

@end


@implementation CCPhysicsBody(ObjectiveChipmunk)

-(void)setNode:(CCNode *)node {_node = node;}

-(cpVect)absolutePosition {return _body.position;}
-(void)setAbsolutePosition:(cpVect)absolutePosition {_body.position = absolutePosition;}

-(cpFloat)absoluteRadians {return _body.angle;}
-(void)setAbsoluteRadians:(cpFloat)absoluteRadians {_body.angle = absoluteRadians;}

-(cpTransform)absoluteTransform {return _body.transform;}

-(ChipmunkBody *)body {return _body;}

-(NSArray *)chipmunkObjects {return _chipmunkObjects;}

-(void)addJoint:(CCPhysicsJoint *)joint
{
	if(_joints == nil) _joints = [NSMutableArray array];
	[_joints addObject:joint];
}

-(void)removeJoint:(CCPhysicsJoint *)joint
{
	[_joints removeObject:joint];
}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics nonRigidTransform:(cpTransform)transform
{
	FOREACH_SHAPE(self, shape) [shape willAddToPhysicsNode:physics nonRigidTransform:transform];
}

-(void)didAddToPhysicsNode:(CCPhysicsNode *)physics
{
	if(!self.allowsRotation) _body.moment = INFINITY;
}

-(void)didRemoveFromPhysicsNode:(CCPhysicsNode *)physics
{
	FOREACH_SHAPE(self, shape) [shape didRemoveFromPhysicsNode:physics];
}

@end
