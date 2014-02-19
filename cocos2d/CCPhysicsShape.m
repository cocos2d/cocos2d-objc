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

#import "CCPhysicsShape.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#import "chipmunk/chipmunk_unsafe.h"


#define DEFAULT_FRICTION 0.7
#define DEFAULT_ELASTICITY 0.2


@interface CCNode()
-(CGAffineTransform)nonRigidTransform;
@end


@interface CCPhysicsCircleShape : CCPhysicsShape
-(id)initWithRadius:(CGFloat)radius center:(CGPoint)center;
@end


@interface CCPhysicsSegmentShape : CCPhysicsShape;
-(id)initFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius;
@end


@interface CCPhysicsPolyShape : CCPhysicsShape
-(id)initWithRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
-(id)initWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius;
@end


@implementation CCPhysicsShape {
	CCPhysicsShape *_next;
	
	NSString *_collisionType;
	NSArray *_collisionCategories;
	NSArray *_collisionMask;
}

+(CCPhysicsShape *)circleShapeWithRadius:(CGFloat)radius center:(CGPoint)center
{
	return [[CCPhysicsCircleShape alloc] initWithRadius:radius center:center];
}

+(CCPhysicsShape *)rectShape:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
	return [[CCPhysicsPolyShape alloc] initWithRect:rect cornerRadius:cornerRadius];
}

+(CCPhysicsShape *)pillShapeFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius
{
	return [[CCPhysicsSegmentShape alloc] initFrom:from to:to cornerRadius:cornerRadius];
}

+(CCPhysicsShape *)polygonShapeWithPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius
{
	return [[CCPhysicsPolyShape alloc] initWithPolygonFromPoints:points count:count cornerRadius:cornerRadius];
}

-(cpTransform)shapeTransform
{
	// TODO Might be better to use the physics relative transform.
	// That's not available until the scene is set up though... hrm.
	CCNode *node = self.node;
	if(node){
		return CGAFFINETRANSFORM_TO_CPTRANSFORM([node nonRigidTransform]);
	} else {
		return cpTransformIdentity;
	}
}

static cpFloat
Determinant(cpTransform t)
{
	return (t.a*t.d - t.c*t.b);
}

-(CGFloat)mass {return self.shape.mass;}
-(void)setMass:(CGFloat)mass {self.shape.mass = mass;}

-(CGFloat)density {return 1e3*self.shape.density/Determinant(self.shapeTransform);}
-(void)setDensity:(CGFloat)density {self.shape.density = 1e-3*density*Determinant(self.shapeTransform);}

-(CGFloat)area {return self.shape.area*Determinant(self.shapeTransform);}

-(CGFloat)friction {return self.shape.friction;}
-(void)setFriction:(CGFloat)friction {self.shape.friction = friction;}

-(CGFloat)elasticity {return self.shape.elasticity;}
-(void)setElasticity:(CGFloat)elasticity {self.shape.elasticity = elasticity;}

-(CGPoint)surfaceVelocity {return CPV_TO_CCP(self.shape.surfaceVelocity);}
-(void)setSurfaceVelocity:(CGPoint)surfaceVelocity {self.shape.surfaceVelocity = CCP_TO_CPV(surfaceVelocity);}


//MARK: Simulation Properties:

-(CCPhysicsNode *)physicsNode {return self.shape.space.userData;}
//-(BOOL)isRunning {return self.physicsNode != nil;}

//MARK: Collision and Contact:

-(BOOL)sensor {return self.shape.sensor;}
-(void)setSensor:(BOOL)sensor {self.shape.sensor = sensor;}

-(id)collisionGroup {return self.shape.filter.group;};
-(void)setCollisionGroup:(id)collisionGroup {
	cpShapeFilter filter = self.shape.filter;
	filter.group = collisionGroup;
	self.shape.filter = filter;
}

// TODO these need a reference to the space to intern the strings
-(NSString *)collisionType {return _collisionType;}
-(void)setCollisionType:(NSString *)collisionType
{
	CCPhysicsNode *physics = self.physicsNode;
	if(physics){
		_collisionType = [physics internString:collisionType];
		self.shape.collisionType = _collisionType;
	} else {
		_collisionType = [collisionType copy];
	}
}

-(NSArray *)collisionCategories {
	if(_collisionCategories){
		return _collisionCategories;
	} else {
		// This will still correctly return nil if not added to a physics node.
		return [self.physicsNode categoriesForBitmask:self.shape.filter.categories];
	}
}

-(void)setCollisionCategories:(NSArray *)collisionCategories
{
	CCPhysicsNode *physics = self.physicsNode;
	if(physics){
		cpShapeFilter filter = self.shape.filter;
		filter.categories = [physics bitmaskForCategories:collisionCategories];
		self.shape.filter = filter;
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
		return [self.physicsNode categoriesForBitmask:self.shape.filter.mask];
	}
}

-(void)setCollisionMask:(NSArray *)collisionMask
{
	CCPhysicsNode *physics = self.physicsNode;
	if(physics){
		cpShapeFilter filter = self.shape.filter;
		filter.mask = [physics bitmaskForCategories:collisionMask];
		self.shape.filter = filter;
	} else {
		_collisionMask = collisionMask;
	}
}

-(CCNode *)node {return self.body.node;}

@end


@implementation CCPhysicsShape(ObjectiveChipmunk)

-(void)rescaleShape:(cpTransform)transform {@throw [NSException exceptionWithName:@"AbstractInvocation" reason:@"This method is abstract." userInfo:nil];}
-(ChipmunkShape *)shape {@throw [NSException exceptionWithName:@"AbstractInvocation" reason:@"This method is abstract." userInfo:nil];}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics nonRigidTransform:(cpTransform)transform;
{
	// Intern the collision type to ensure it's not a unique object reference.
	_collisionType = [physics internString:_collisionType];
	self.shape.collisionType = _collisionType;
	
	// Set up the collision bitmasks.
	cpShapeFilter filter = self.shape.filter;
	filter.categories = [physics bitmaskForCategories:_collisionCategories];
	filter.mask = [physics bitmaskForCategories:_collisionMask];
	self.shape.filter = filter;
	
	// nil the array references to save on memory.
	// They will rarely be read back and we can easily reconstruct the array.
	_collisionCategories = nil;
	_collisionMask = nil;
	
	[self rescaleShape:transform];
}

-(void)didRemoveFromPhysicsNode:(CCPhysicsNode *)physics
{
	cpShapeFilter filter = self.shape.filter;
	
	// Read the collision categories back just in case they are read later.
	_collisionCategories = [physics categoriesForBitmask:filter.categories];
	_collisionMask = [physics categoriesForBitmask:filter.mask];
}

-(CCPhysicsShape *)next {return _next;}
-(void)setNext:(CCPhysicsShape *)next {_next = next;}

-(CCPhysicsBody *)body {return self.shape.body.userData;}
-(void)setBody:(CCPhysicsBody *)body {self.shape.body = body.body;}

@end


static cpFloat
RadiusForTransform(cpTransform t)
{
	// Return the magnitude of the longest basis vector.
	return cpfsqrt(MAX(t.a*t.a + t.b*t.b, t.c*t.c + t.d*t.d));
}


@implementation CCPhysicsCircleShape {
	ChipmunkCircleShape *_shape;
	cpFloat _radius;
	cpVect _center;
}

-(id)initWithRadius:(CGFloat)radius center:(CGPoint)center
{
	if((self = [super init])){
		_radius = radius;
		_center = CCP_TO_CPV(center);
		_shape = [ChipmunkCircleShape circleWithBody:nil radius:_radius offset:_center];
		
		_shape.mass = 1.0;
		_shape.friction = DEFAULT_FRICTION;
		_shape.elasticity = DEFAULT_ELASTICITY;
		_shape.userData = self;
	}
	
	return self;
}

-(ChipmunkShape *)shape {return _shape;}

-(void)rescaleShape:(cpTransform)transform
{
	cpShape *shape = self.shape.shape;
	cpCircleShapeSetRadius(shape, _radius*RadiusForTransform(transform));
	cpCircleShapeSetOffset(shape, cpTransformPoint(transform, _center));
}

@end


@implementation CCPhysicsSegmentShape {
	ChipmunkCircleShape *_shape;
	cpFloat _radius;
	cpVect _from, _to;
}

-(id)initFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius
{
	if((self = [super init])){
		_radius = cornerRadius;
		_from = CCP_TO_CPV(from); _to = CCP_TO_CPV(to);
		_shape = [ChipmunkSegmentShape segmentWithBody:nil from:_from to:_to radius:cornerRadius];
		
		_shape.mass = 1.0;
		_shape.friction = DEFAULT_FRICTION;
		_shape.elasticity = DEFAULT_ELASTICITY;
		_shape.userData = self;
	}
	
	return self;
}

-(ChipmunkShape *)shape {return _shape;}

-(void)rescaleShape:(cpTransform)transform
{
	cpShape *shape = self.shape.shape;
	cpSegmentShapeSetRadius(shape, _radius*RadiusForTransform(transform));
	cpSegmentShapeSetEndpoints(shape, cpTransformPoint(transform, _from), cpTransformPoint(transform, _to));
	// TODO need to update neighbors.
}

@end


@implementation CCPhysicsPolyShape {
	ChipmunkPolyShape *_shape;
	cpFloat _radius;
	cpVect *_points;
	NSUInteger _count;
}

-(id)initWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius
{
	if((self = [super init])){
		_radius = cornerRadius;
		_points = calloc(count, sizeof(cpVect));
		_count = count;
		
#if !CP_USE_CGTYPES
		for(NSUInteger i=0; i<count; i++){
			_points[i] = CCP_TO_CPV(points[i]);
		}
#else
		memcpy(_points, points, count*sizeof(CGPoint));
#endif
		
		_shape = [ChipmunkPolyShape polyWithBody:nil count:(int)_count verts:_points transform:cpTransformIdentity radius:_radius];
		
		_shape.mass = 1.0;
		_shape.friction = DEFAULT_FRICTION;
		_shape.elasticity = DEFAULT_ELASTICITY;
		_shape.userData = self;
	}
	
	return self;
}

-(id)initWithRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
	cpBB bb = {CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect)};
	CGPoint points[] = {
		ccp(bb.r, bb.b),
		ccp(bb.r, bb.t),
		ccp(bb.l, bb.t),
		ccp(bb.l, bb.b),
	};
	
	return [self initWithPolygonFromPoints:points count:4 cornerRadius:cornerRadius];
}

-(void)dealloc
{
	free(_points);
}

-(ChipmunkShape *)shape {return _shape;}

-(void)rescaleShape:(cpTransform)transform
{
	cpShape *shape = self.shape.shape;
	cpPolyShapeSetRadius(shape, _radius*RadiusForTransform(transform));
	cpPolyShapeSetVerts(shape, (int)_count, _points, transform);
}

@end
