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


// TODO temporary
static inline void NYI(){@throw @"Not Yet Implemented";}


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

// Removed since the transform cannot be calculated until after the node enters an active scene.
//-(cpTransform)shapeTransform
//{
//	// TODO Might be better to use the physics relative transform.
//	// That's not available until the scene is set up though... hrm.
//	CCNode *node = self.node;
//	if(node){
//		return [node nonRigidTransform];
//	} else {
//		return CGAffineTransformIdentity;
//	}
//}
//
//static cpFloat
//Determinant(cpTransform t)
//{
//	return (t.a*t.d - t.c*t.b);
//}

-(CGFloat)mass {return self.shape.mass;}
-(void)setMass:(CGFloat)mass {self.shape.mass = mass;}

// See [CCPhysicsShape shapeTransform] for why this is removed.
//-(CGFloat)density {return self.shape.density/Determinant(self.shapeTransform);}
//-(void)setDensity:(CGFloat)density {self.shape.density = density*Determinant(self.shapeTransform);}
//
//-(CGFloat)area {return self.shape.area*Determinant(self.shapeTransform);}

-(CGFloat)friction {return self.shape.friction;}
-(void)setFriction:(CGFloat)friction {self.shape.friction = friction;}

-(CGFloat)elasticity {return self.shape.elasticity;}
-(void)setElasticity:(CGFloat)elasticity {self.shape.elasticity = elasticity;}

-(CGPoint)surfaceVelocity {return self.shape.surfaceVelocity;}
-(void)setSurfaceVelocity:(CGPoint)surfaceVelocity {self.shape.surfaceVelocity = surfaceVelocity;}


//MARK: Simulation Properties:

-(CCPhysicsNode *)physicsNode {return self.shape.space.userData;}
//-(BOOL)isRunning {return self.physicsNode != nil;}

//MARK: Collision and Contact:

-(BOOL)sensor {return self.shape.sensor;}
-(void)setSensor:(BOOL)sensor {self.shape.sensor = sensor;}

-(id)collisionGroup {return self.shape.group;};
-(void)setCollisionGroup:(id)collisionGroup {self.shape.group = collisionGroup;}

// TODO these need a reference to the space to intern the strings
// Needs to be deferred?
-(NSString *)collisionType {return _collisionType;}
-(void)setCollisionType:(NSString *)collisionType {_collisionType = [collisionType copy];}

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
	_collisionType = nil;
	
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


static CGFloat
RadiusForTransform(CGAffineTransform t)
{
	// Return the magnitude of the longest basis vector.
	return cpfsqrt(MAX(t.a*t.a + t.b*t.b, t.c*t.c + t.d*t.d));
}


@implementation CCPhysicsCircleShape {
	ChipmunkCircleShape *_shape;
	CGFloat _radius;
	CGPoint _center;
}

-(id)initWithRadius:(CGFloat)radius center:(CGPoint)center
{
	if((self = [super init])){
		_shape = [ChipmunkCircleShape circleWithBody:nil radius:radius offset:center];
		_radius = radius;
		_center = center;
		
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
	CGFloat _radius;
	CGPoint _from, _to;
}

-(id)initFrom:(CGPoint)from to:(CGPoint)to cornerRadius:(CGFloat)cornerRadius
{
	if((self = [super init])){
		_shape = [ChipmunkSegmentShape segmentWithBody:nil from:from to:to radius:cornerRadius];
		_radius = cornerRadius;
		_from = from; _to = to;
		
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
	CGFloat _radius;
	CGPoint *_points;
	NSUInteger _count;
}

-(id)initWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius
{
	if((self = [super init])){
		_shape = [ChipmunkPolyShape polyWithBody:nil count:count verts:points transform:cpTransformIdentity radius:cornerRadius];
		_radius = cornerRadius;
		_points = calloc(count, sizeof(CGPoint));
		memcpy(_points, points, count*sizeof(CGPoint));
		_count = count;
		
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
	cpVect points[] = {
		cpv(bb.r, bb.b),
		cpv(bb.r, bb.t),
		cpv(bb.l, bb.t),
		cpv(bb.l, bb.b),
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
	cpPolyShapeSetVerts(shape, _count, _points, transform);
}

@end
