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

#import "CCPhysicsBody.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#define DEFAULT_FRICTION 0.7
#define DEFAULT_ELASTICITY 0.2

// TODO temporary
static inline void NYI(){@throw @"Not Yet Implemented";}

@implementation CCPhysicsBody
{
	CCNode *_node;
	
	ChipmunkBody *_body;
	ChipmunkShape *_shape;
	
	NSArray *_chipmunkObjects;
	
	NSString *_collisionType;
	NSArray *_collisionCategories;
	NSArray *_collisionMask;
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
-(BOOL)isRunning {return self.physicsNode != nil;}

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
-(NSString *)collisionType {return _collisionType;}
-(void)setCollisionType:(NSString *)collisionType {_collisionType = [collisionType copy];}

-(NSArray *)collisionCategories {
	if(_collisionCategories){
		return _collisionCategories;
	} else {
		// This will still correctly return nil if not added to a physics node.
		return [self.physicsNode categoriesForBitmask:_shape.filter.categories];
	}
}
-(void)setCollisionCategories:(NSArray *)collisionCategories
{
	CCPhysicsNode *physics = self.physicsNode;
	if(physics){
		cpShapeFilter filter = _shape.filter;
		filter.categories = [physics bitmaskForCategories:collisionCategories];
		_shape.filter = filter;
	} else {
		_collisionCategories = collisionCategories;
	}
}

-(NSArray *)collisionMask
{
	if(_collisionMask){
		return _collisionMask;
	} else {
		// This will still correctly return nil if not added to a physics node.
		return [self.physicsNode categoriesForBitmask:_shape.filter.mask];
	}
}

-(void)setCollisionMask:(NSArray *)collisionMask
{
	CCPhysicsNode *physics = self.physicsNode;
	if(physics){
		cpShapeFilter filter = _shape.filter;
		filter.mask = [physics bitmaskForCategories:collisionMask];
		_shape.filter = filter;
	} else {
		_collisionMask = collisionMask;
	}
}

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

-(CCNode *)node {return _node;}
-(void)setNode:(CCNode *)node {_node = node;}

-(NSArray *)chipmunkObjects {return _chipmunkObjects;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	// Intern the collision type to ensure it's not a unique object reference.
	_collisionType = [physics internString:_collisionType];
	_shape.collisionType = _collisionType;
	
	// Set up the collision bitmasks.
	cpShapeFilter filter = _shape.filter;
	filter.categories = [physics bitmaskForCategories:_collisionCategories];
	filter.mask = [physics bitmaskForCategories:_collisionMask];
	_shape.filter = filter;
	
	// nil the array references to save on memory.
	// They will rarely be read back and we can easily reconstruct the array.
	_collisionCategories = nil;
	_collisionType = nil;
}

-(void)didRemoveFromPhysicsNode:(CCPhysicsNode *)physics
{
	cpShapeFilter filter = _shape.filter;
	
	// Read the collision categories back just in case they are read later.
	_collisionCategories = [physics categoriesForBitmask:filter.categories];
	_collisionMask = [physics categoriesForBitmask:filter.mask];
}

@end


