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
#import "CCNode_Private.h"


@interface CCNode(Private)
-(CGAffineTransform)nonRigidTransform;
@end

//Function Prototype
static inline void
CCPhysicsBodyUpdatePosition(cpBody *body, cpFloat dt);

#define FOREACH_SHAPE(__body__, __shapeVar__) for(CCPhysicsShape *__shapeVar__ = __body__->_shapeList; __shapeVar__; __shapeVar__ = __shapeVar__.next)


@implementation CCPhysicsBody
{
	ChipmunkBody *_body;
	CCPhysicsShape *_shapeList;
	
	NSMutableArray *_joints;
	
	NSMutableArray *_chipmunkObjects;
	
	BOOL _affectedByGravity;
	BOOL _allowsRotation;
    
	BOOL _trackingPerformed;
    BOOL _isKinematicTransformDirty;
    
    CGAffineTransform _lastTransform;
    
    CGPoint           _relativePosition;
    float             _relativeRotation;
}


//MARK: Constructors:

-(id)initWithShapeList:(CCPhysicsShape *)shapeList
{
	if((self = [super init])){
		_body = [ChipmunkBody bodyWithMass:0.0 andMoment:0.0];
		_body.userData = self;
		cpBodySetPositionUpdateFunc(_body.body,CCPhysicsBodyUpdatePosition);
		
		_affectedByGravity = YES;
		_allowsRotation = YES;
        _isKinematicTransformDirty = YES;
		
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

+(CCPhysicsBody *)bodyWithPolylineFromRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
	CGPoint points[] = {
		{CGRectGetMinX(rect), CGRectGetMinY(rect)},
		{CGRectGetMaxX(rect), CGRectGetMinY(rect)},
		{CGRectGetMaxX(rect), CGRectGetMaxY(rect)},
		{CGRectGetMinX(rect), CGRectGetMaxY(rect)},
	};
	
	return [self bodyWithPolylineFromPoints:points count:4 cornerRadius:cornerRadius looped:YES];
}

+(CCPhysicsBody *)bodyWithPolylineFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius looped:(bool)looped;
{
	NSAssert(looped || count >= 2, @"Non-looped polyline bodies must have at least two points.");
	NSAssert(!looped || count >= 3, @"Looped polyline bodies must have at least three points.");
	
	CCPhysicsShape *shapes = nil;
	
	NSUInteger limit = (looped ? count : count - 1);
	for(int i=0; i<limit; i++){
		CCPhysicsShape *shape = [CCPhysicsShape pillShapeFrom:points[i] to:points[(i + 1)%count] cornerRadius:cornerRadius];
		// TODO Broken. Values may be wrong after applying a transform in onEnter.
		//cpSegmentShapeSetNeighbors(shape.shape.shape, points[(i - 1 + count)%count], points[(i + 2)%count]);
		
		shape.next = shapes;
		shapes = shape;
	}
	
	CCPhysicsBody *body = [[self alloc] initWithShapeList:shapes];
	body.type = CCPhysicsBodyTypeStatic;
	
	return body;
}

+(CCPhysicsBody *)bodyWithShapes:(NSArray *)shapes
{
	CCPhysicsShape *shapeList = nil;
	for(NSUInteger i=0, count=shapes.count; i<count; i++){
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

-(CGFloat)density
{
	return self.mass/self.area;
}

-(void)setDensity:(CGFloat)density
{
    FOREACH_SHAPE(self, shape) shape.density = density;
}

-(CGFloat)area
{
	CGFloat sum = 0.0;
	FOREACH_SHAPE(self, shape) sum += shape.area;
	
	return sum;
}

-(CGFloat)friction {return _shapeList.friction;}
-(void)setFriction:(CGFloat)friction {FOREACH_SHAPE(self, shape) shape.friction = friction;}

-(CGFloat)elasticity {return _shapeList.elasticity;}
-(void)setElasticity:(CGFloat)elasticity {FOREACH_SHAPE(self, shape) shape.elasticity = elasticity;}

-(CGPoint)surfaceVelocity {return _shapeList.surfaceVelocity;}
-(void)setSurfaceVelocity:(CGPoint)surfaceVelocity {FOREACH_SHAPE(self, shape) shape.surfaceVelocity = surfaceVelocity;}


//MARK: Simulation Properties:

-(CCPhysicsNode *)physicsNode {return _body.space.userData;}
-(BOOL)isRunning {return self.physicsNode != nil;}

static void
NotAffectedByGravity
(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt)
{
	cpBodyUpdateVelocity(body, cpvzero, damping, dt);
}

-(BOOL)affectedByGravity
{
	if(self.type == CCPhysicsBodyTypeDynamic){
		return _affectedByGravity;
	} else {
		// Static and kinematic bodies are never affected by gravity.
		return NO;
	}
}

-(void)setAffectedByGravity:(BOOL)affectedByGravity
{
	NSAssert(self.type == CCPhysicsBodyTypeDynamic, @"Only dynamic bodies can be affected by gravity.");
	
	cpBodyVelocityFunc func = (affectedByGravity ? cpBodyUpdateVelocity : NotAffectedByGravity);
	cpBodySetVelocityUpdateFunc(self.body.body, func);
	
	_affectedByGravity = affectedByGravity;
}

-(BOOL)allowsRotation {
	if(self.type == CCPhysicsBodyTypeDynamic){
		return _allowsRotation;
	} else {
		// The allowsRotation property is only applicable to dynamic bodies.
		return NO;
	}
}

-(void)setAllowsRotation:(BOOL)allowsRotation
{
	NSAssert(self.type == CCPhysicsBodyTypeDynamic, @"CCPhysicsBody.allowsRotation only applies to dynamic bodies.");
	
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

static CCPhysicsBodyType ToCocosBodyType[] = {CCPhysicsBodyTypeDynamic, CCPhysicsBodyTypeKinematic, CCPhysicsBodyTypeStatic};
static cpBodyType ToChipmunkBodyType[] = {CP_BODY_TYPE_DYNAMIC, CP_BODY_TYPE_KINEMATIC, CP_BODY_TYPE_STATIC};

-(CCPhysicsBodyType)type {return ToCocosBodyType[_body.type];}
-(void)setType:(CCPhysicsBodyType)type
{
	ChipmunkSpace *space = self.physicsNode.space;
	if(space && cpSpaceIsLocked(space.space)){
		// Chipmunk body type cannot be changed from within a callback, need to make this safe.
		[space addPostStepBlock:^{_body.type = ToChipmunkBodyType[type];} key:self];
	} else {
		_body.type = ToChipmunkBodyType[type];
	}
}

static inline void
CCPhysicsBodyUpdatePosition(cpBody *body, cpFloat dt)
{
	// Skip kinematic bodies.
	if(cpBodyGetType(body) == CP_BODY_TYPE_KINEMATIC) return;
	
	cpBodyUpdatePosition(body, dt);
}

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
}

//MARK: Velocity

-(CGPoint)velocity {return CPV_TO_CCP(_body.velocity);}
-(void)setVelocity:(CGPoint)velocity {_body.velocity = CCP_TO_CPV(velocity);}

-(CGFloat)angularVelocity {return _body.angularVelocity;}
-(void)setAngularVelocity:(CGFloat)angularVelocity
{
#if DEBUG
	if(!self.allowsRotation) CCLOG(@"Did you intend to set the angular velocity on a physicsBody where allowsRotation is NO?");
#endif
	
	_body.angularVelocity = angularVelocity;
}

//MARK: Forces, Torques and Impulses:

-(CGPoint)force {return CPV_TO_CCP(_body.force);}
-(void)setForce:(CGPoint)force {_body.force = CCP_TO_CPV(force);}

-(CGFloat)torque {return _body.torque;}
-(void)setTorque:(CGFloat)torque {_body.torque = torque;}

-(void)applyTorque:(CGFloat)torque {_body.torque += torque;}
-(void)applyAngularImpulse:(CGFloat)impulse {_body.angularVelocity += impulse/_body.moment;}

-(void)applyForce:(CGPoint)force {_body.force = cpvadd(_body.force, CCP_TO_CPV(force));}
-(void)applyImpulse:(CGPoint)impulse {_body.velocity = cpvadd(_body.velocity, cpvmult(CCP_TO_CPV(impulse), 1.0f/_body.mass));}

-(void)applyForce:(CGPoint)force atLocalPoint:(CGPoint)point
{
	[_body applyForce:CCP_TO_CPV(force) atLocalPoint:CCP_TO_CPV(point)];
}

-(void)applyImpulse:(CGPoint)impulse atLocalPoint:(CGPoint)point
{
	[_body applyImpulse:CCP_TO_CPV(impulse) atLocalPoint:CCP_TO_CPV(point)];
}

-(void)applyForce:(CGPoint)force atWorldPoint:(CGPoint)point {[_body applyForce:CCP_TO_CPV(force) atWorldPoint:CCP_TO_CPV(point)];}
-(void)applyImpulse:(CGPoint)impulse atWorldPoint:(CGPoint)point {[_body applyImpulse:CCP_TO_CPV(impulse) atWorldPoint:CCP_TO_CPV(point)];}

//MARK: Misc.

-(NSArray *)joints
{
	return (_joints ?: [NSArray array]);
}

-(BOOL)sleeping {return _body.isSleeping;}

@end


@implementation CCPhysicsBody(ObjectiveChipmunk)


-(void)setNode:(CCNode *)node {_node = node;}

-(CGPoint)absolutePosition {return CPV_TO_CCP(_body.position);}
-(void)setAbsolutePosition:(CGPoint)absolutePosition
{
	_body.position = CCP_TO_CPV(absolutePosition);
	
	if(_body.type == CP_BODY_TYPE_STATIC){
		// Need to force Chipmunk to update the spatial indexes for a static body.
		[_body.space reindexShapesForBody:_body];
	}
}

-(CGFloat)absoluteRadians {return _body.angle;}
-(void)setAbsoluteRadians:(CGFloat)absoluteRadians {
	_body.angle = absoluteRadians;
	
	if(_body.type == CP_BODY_TYPE_STATIC){
		// Need to force Chipmunk to update the spatial indexes for a static body.
		[_body.space reindexShapesForBody:_body];
	}
}


-(CGFloat)relativeRotation {return _relativeRotation;}
-(void)setRelativeRotation:(CGFloat)relativeRotation
{
    _relativeRotation = relativeRotation;
}

-(CGPoint)relativePosition {return _relativePosition;}
-(void)setRelativePosition:(CGPoint)relativePosition
{
    _relativePosition = relativePosition;
}


-(CGAffineTransform)absoluteTransform {
	return CPTRANSFORM_TO_CGAFFINETRANSFORM(_body.transform);
}


-(BOOL)isKinematicTransformDirty
{
    return _isKinematicTransformDirty;
}



-(void)updateKinetics:(CCTime)deltaTime
{

    if(!_isKinematicTransformDirty)
    {
        self.type = CCPhysicsBodyTypeStatic;
        self.velocity = CGPointZero;
    }
    else
    {
        _isKinematicTransformDirty = NO;
        
        /////// Update absolute position
        
		CGAffineTransform phyicsTransform = NodeToPhysicsTransform(self.node.parent);
		
		CGPoint anchorPointInPointsScaled = ccpCompMult(self.node.anchorPointInPoints,
												   ccp(self.node.scaleX, self.node.scaleY));
		
        CGPoint rotPos = ccpRotateByAngle(anchorPointInPointsScaled, CGPointZero, -CC_DEGREES_TO_RADIANS(self.relativeRotation));
		CGPoint newPos2 = ccpSub(self.relativePosition , rotPos );
		CGPoint newPos3 = cpTransformPoint(phyicsTransform, newPos2);

		self.absolutePosition = newPos3;
        /////// Update absolute angle

		CGFloat parentRotation = NodeToPhysicsRotation(self.node.parent);
		CGFloat newRotation = -CC_DEGREES_TO_RADIANS(self.relativeRotation - parentRotation);
		self.absoluteRadians = newRotation;


        ////////////        ////////////        ////////////        ////////////        ////////////
        /// update velocity and angular velocity.
        
        CGPoint lastPos = cpTransformPoint(_lastTransform, cpvzero);
        CGPoint velocity = ccpMult(ccpSub(self.absolutePosition, lastPos), 1.0/deltaTime);
		
        // Change in transform since last frame.
        cpTransform deltaTransform = cpTransformMult(cpTransformInverse(_lastTransform), self.absoluteTransform);

        // Change in rotation since the last frame.
        cpFloat deltaRadians = cpfatan2(deltaTransform.b, deltaTransform.a);
        cpFloat angularVelocity = deltaRadians/deltaTime;
        
        
		_body.angularVelocity = angularVelocity;
        self.velocity = velocity;
       
        _lastTransform = self.absoluteTransform;
       
    }
    
}

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
    _lastTransform = NodeToPhysicsTransform(self.node);
	FOREACH_SHAPE(self, shape) [shape willAddToPhysicsNode:physics nonRigidTransform:transform];

    if(self.type == CCPhysicsBodyTypeStatic)
		[self trackParentTransformations:physics];
}

-(void)didAddToPhysicsNode:(CCPhysicsNode *)physics
{
	if(!self.allowsRotation) _body.moment = INFINITY;
}

-(void)didRemoveFromPhysicsNode:(CCPhysicsNode *)physics
{
	FOREACH_SHAPE(self, shape) [shape didRemoveFromPhysicsNode:physics];

	if(_trackingPerformed)
		[self removeParentTransformTracking:physics];
}


#pragma - Tracking movement

//The following are properties which we track on the parent nodes in order to update the child nodes.
NSString *  kDependantProperties[2] = { @"position", @"rotation"};

#ifdef DEBUG
//The following are properties which cannot be animated. Changing their values after onEnter in unhandled.
NSString *  kRestrictedProperties[3] = { @"scale", @"scaleX", @"scaleY"};
#endif

-(void)trackParentTransformations:(CCPhysicsNode *)physics
{
	_trackingPerformed = YES;
    CCNode * node = self.node;
    
    while (node && node != physics)
    {
        for (int i = 0; i < sizeof(kDependantProperties)/sizeof(kDependantProperties[0]); i++)
        {
            [node addObserver:self forKeyPath:kDependantProperties[i] options:NSKeyValueObservingOptionNew context:nil];
        }
        
#ifdef DEBUG
        for (int i = 0; i < sizeof(kRestrictedProperties)/sizeof(kRestrictedProperties[0]); i++)
        {
            [node addObserver:self forKeyPath:kRestrictedProperties[i] options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        }
#endif
        node = node.parent;
    }
}

-(void)removeParentTransformTracking:(CCPhysicsNode *)physics
{
    CCNode * node = self.node;

    
    while (node && node != physics)
    {
        for (int i = 0; i < sizeof(kDependantProperties)/sizeof(kDependantProperties[0]); i++)
        {
            [node removeObserver:self forKeyPath:kDependantProperties[i]];
        }
#ifdef DEBUG
        for (int i = 0; i < sizeof(kRestrictedProperties)/sizeof(kRestrictedProperties[0]); i++)
        {
            [node removeObserver:self forKeyPath:kRestrictedProperties[i]];
        }
#endif
        
        node = node.parent;
    }
	
	_trackingPerformed = NO;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
#ifdef DEBUG
    for (int i = 0; i < sizeof(kRestrictedProperties)/sizeof(kRestrictedProperties[0]); i++)
    {
        if([kRestrictedProperties[i] isEqualToString:keyPath])
        {
            if([change[NSKeyValueChangeNewKey] isEqualToValue:change[NSKeyValueChangeOldKey]])
            {
                continue;
            }

            //There are several properties on a physics body that cannot be changed after on enter (eg scale). Scaleing the parent of a physics body will fail as well, at least until the CCPhysicsNode parent.
            NSAssert(![kRestrictedProperties[i] isEqualToString:keyPath], @"Property '%@' cannot be changed on a physics body or one of its parents after onEnter.",keyPath);

        }
    }
#endif
    
    _isKinematicTransformDirty = YES;
    
    if(self.type == CCPhysicsBodyTypeDynamic || self.type == CCPhysicsBodyTypeKinematic)
        return;
    
    [self setType:CCPhysicsBodyTypeKinematic];
    
    _isKinematicTransformDirty = YES;
    [self.physicsNode.kineticNodes addObject:self.node];
}

@end
