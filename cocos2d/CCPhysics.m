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

static void NYI(){@throw @"Not Yet Implemented";}

// Do not change this value unless you redefine the cpBitmask type to have more than 32 bits.
#define MAX_CATEGORIES 32

@interface CCPhysicsCollisionPair(Private)
@property(nonatomic, assign) cpArbiter *arbiter;
@end

@interface CCPhysicsBody(Private)
@property(nonatomic, strong) CCNode *node;
@end


@implementation CCPhysicsBody
{
	ChipmunkBody *_body;
	ChipmunkShape *_shape;
}

//MARK: Constructors:

-(id)init
{
	if((self = [super init])){
		NYI();
	}
	
	return self;
}

+(CCPhysicsBody *)bodyWithCircleOfRadius:(CGFloat)radius andCenter:(CGFloat)center
{
	NYI(); return nil;
}

+(CCPhysicsBody *)bodyWithRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
	NYI(); return nil;
}

+(CCPhysicsBody *)bodyWithPillWithStart:(CGPoint)start end:(CGPoint)end cornerRadius:(CGFloat)cornerRadius
{
	NYI(); return nil;
}

+(CCPhysicsBody *)bodyWithPolygonFromPoints:(CGPoint *)points count:(NSUInteger)count cornerRadius:(CGFloat)cornerRadius
{
	NYI(); return nil;
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

-(BOOL)affectedByGravity {NYI(); return YES;}
-(void)setAffectedByGravity:(BOOL)affectedByGravity {NYI();}

-(BOOL)allowsRotation {NYI(); return YES;}
-(void)setAllowsRotation:(BOOL)allowsRotation {NYI();}

-(BOOL)dynamic {NYI(); return YES;}
-(void)setDynamic:(BOOL)dynamic {NYI();}

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
-(CGFloat)angularVelocity {return _body.angularVelocity;}

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


@interface CCPhysicsJoint(Private)
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


@implementation CCPhysicsSpace {
	ChipmunkSpace *_space;
	
	NSMutableDictionary *_internedStrings;
	NSMutableArray *_categories;
}

-(id)initWithScene:(CCScene *)scene
{
	if((self = [super init])){
		_space = [[ChipmunkSpace alloc] init];
		_space.gravity = cpvzero;
		
		_scene = scene;
		
		_internedStrings = [NSMutableDictionary dictionary];
		_categories = [NSMutableArray array];
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

@end
