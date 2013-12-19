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

#import "CCPhysicsJoint.h"
#import "CCPhysics+ObjectiveChipmunk.h"


@interface CCNode(Private)
-(CGAffineTransform)nonRigidTransform;
@end


@interface CCPhysicsPivotJoint : CCPhysicsJoint
@end


@implementation CCPhysicsPivotJoint {
	ChipmunkPivotJoint *_constraint;
	CGPoint _anchor;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchor:(CGPoint)anchor
{
	if((self = [super init])){
		_constraint = [ChipmunkPivotJoint pivotJointWithBodyA:bodyA.body bodyB:bodyB.body pivot:anchor];
		_constraint.userData = self;
		
		_anchor = anchor;
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	CCPhysicsBody *bodyA = self.bodyA;
	CGPoint anchor = cpTransformPoint(bodyA.node.nonRigidTransform, _anchor);
	
	_constraint.anchorA = anchor;
	_constraint.anchorB = [_constraint.bodyB worldToLocal:[_constraint.bodyA localToWorld:anchor]];
}

@end


@interface CCPhysicsPinJoint : CCPhysicsJoint
@end


@implementation CCPhysicsPinJoint {
	ChipmunkPinJoint *_constraint;
	CGPoint _anchorA, _anchorB;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
{
	if((self = [super init])){
		_constraint = [ChipmunkPinJoint pinJointWithBodyA:bodyA.body bodyB:bodyB.body anchorA:anchorA anchorB:anchorB];
		_constraint.userData = self;
		
		_anchorA = anchorA;
		_anchorB = anchorB;
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	CCPhysicsBody *bodyA = self.bodyA, *bodyB = self.bodyB;
	cpVect anchorA = _constraint.anchorA = cpTransformPoint(bodyA.node.nonRigidTransform, _anchorA);
	cpVect anchorB = _constraint.anchorB = cpTransformPoint(bodyB.node.nonRigidTransform, _anchorB);
	
	_constraint.dist = cpvdist([bodyA.body localToWorld:anchorA], [bodyB.body localToWorld:anchorB]);
}

@end


@interface CCPhysicsSlideJoint : CCPhysicsJoint
@end


@implementation CCPhysicsSlideJoint {
	ChipmunkSlideJoint *_constraint;
	CGPoint _anchorA, _anchorB;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB minDistance:(CGFloat)min maxDistance:(CGFloat)max;
{
	if((self = [super init])){
		_constraint = [ChipmunkSlideJoint slideJointWithBodyA:bodyA.body bodyB:bodyB.body anchorA:anchorA anchorB:anchorB min:min max:max];
		_constraint.userData = self;
		
		_anchorA = anchorA;
		_anchorB = anchorB;
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	CCPhysicsBody *bodyA = self.bodyA, *bodyB = self.bodyB;
	_constraint.anchorA = cpTransformPoint(bodyA.node.nonRigidTransform, _anchorA);
	_constraint.anchorB = cpTransformPoint(bodyB.node.nonRigidTransform, _anchorB);
}

@end


@interface CCPhysicsSpringJoint : CCPhysicsJoint
@end


@implementation CCPhysicsSpringJoint {
	ChipmunkDampedSpring *_constraint;
	CGPoint _anchorA, _anchorB;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB restLength:(CGFloat)restLength stiffness:(CGFloat)stiffness damping:(CGFloat)damping

{
	if((self = [super init])){
		_constraint = [ChipmunkDampedSpring dampedSpringWithBodyA:bodyA.body bodyB:bodyB.body anchorA:anchorA anchorB:anchorB restLength:restLength stiffness:stiffness damping:damping];
		_constraint.userData = self;
		
		_anchorA = anchorA;
		_anchorB = anchorB;
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	CCPhysicsBody *bodyA = self.bodyA, *bodyB = self.bodyB;
	_constraint.anchorA = cpTransformPoint(bodyA.node.nonRigidTransform, _anchorA);
	_constraint.anchorB = cpTransformPoint(bodyB.node.nonRigidTransform, _anchorB);
}

@end


@implementation CCPhysicsJoint

-(id)init
{
	if((self = [super init])){
		_valid = YES;
	}
	
	return self;
}

-(void)addToPhysicsNode:(CCPhysicsNode *)physicsNode
{
	NSAssert(self.bodyA.physicsNode == self.bodyB.physicsNode, @"Bodies connected by a joint must be added to the same CCPhysicsNode.");
	
	[self willAddToPhysicsNode:physicsNode];
	[physicsNode.space smartAdd:self];
}

+(CCPhysicsJoint *)connectedPivotJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA
{
	CCPhysicsJoint *joint = [[CCPhysicsPivotJoint alloc] initWithBodyA:bodyA bodyB:bodyB anchor:anchorA];
	[bodyA addJoint:joint];
	[bodyB addJoint:joint];
	
	[joint addToPhysicsNode:bodyA.physicsNode];
	
	return joint;
}

+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
	anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
{
	CCPhysicsJoint *joint = [[CCPhysicsPinJoint alloc] initWithBodyA:bodyA bodyB:bodyB anchorA:anchorA anchorB:anchorB];
	[bodyA addJoint:joint];
	[bodyB addJoint:joint];
	
	[joint addToPhysicsNode:bodyA.physicsNode];
	
	return joint;
}

+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
	anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
	minDistance:(CGFloat)min maxDistance:(CGFloat)max
{
	CCPhysicsJoint *joint = [[CCPhysicsSlideJoint alloc] initWithBodyA:bodyA bodyB:bodyB anchorA:anchorA anchorB:anchorB minDistance:min maxDistance:max];
	[bodyA addJoint:joint];
	[bodyB addJoint:joint];
	
	[joint addToPhysicsNode:bodyA.physicsNode];
	
	return joint;
}

+(CCPhysicsJoint *)connectedSpringJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
	anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
	restLength:(CGFloat)restLength stiffness:(CGFloat)stiffness damping:(CGFloat)damping
{
	CCPhysicsSpringJoint *joint = [[CCPhysicsSpringJoint alloc] initWithBodyA:bodyA bodyB:bodyB anchorA:anchorA anchorB:anchorB restLength:restLength stiffness:stiffness damping:damping];
	[bodyA addJoint:joint];
	[bodyB addJoint:joint];
	
	[joint addToPhysicsNode:bodyA.physicsNode];
	
	return joint;
}

-(CCPhysicsBody *)bodyA {return self.constraint.bodyA.userData;}
//-(void)setBodyA:(CCPhysicsBody *)bodyA {NYI();}

-(CCPhysicsBody *)bodyB {return self.constraint.bodyB.userData;}
//-(void)setBodyB:(CCPhysicsBody *)bodyB {NYI();}

-(CGFloat)maxForce {return self.constraint.maxForce;}
-(void)setMaxForce:(CGFloat)maxForce
{
	NSAssert(maxForce > 0.0, @"Max force must be greater than 0.");
	self.constraint.maxForce = maxForce;
}

-(CGFloat)impulse {return self.constraint.impulse;}

-(void)invalidate {
	_valid = NO;
	
	[self tryRemoveFromPhysicsNode:self.bodyA.physicsNode];
	[self.bodyA removeJoint:self];
	[self.bodyB removeJoint:self];
}

static void
BreakConstraint(cpConstraint *constraint, cpSpace *space)
{
	CCPhysicsJoint *joint = [[ChipmunkConstraint constraintFromCPConstraint:constraint] userData];
	
	// Divide by the timestep to convent the impulse to a force.
	if(cpConstraintGetImpulse(constraint)/cpSpaceGetCurrentTimeStep(space) > joint.breakingForce){
		[joint invalidate];
	}
}

-(void)setBreakingForce:(CGFloat)breakingForce
{
	NSAssert(breakingForce > 0.0, @"Breaking force must be greater than 0.");
	_breakingForce = breakingForce;
	cpConstraintSetPostSolveFunc(self.constraint.constraint, breakingForce < INFINITY ? BreakConstraint : NULL);
}

@end


@implementation CCPhysicsJoint(ObjectiveChipmunk)

-(id<NSFastEnumeration>)chipmunkObjects {return [NSArray arrayWithObject:self.constraint];}

-(ChipmunkConstraint *)constraint
{
	@throw [NSException exceptionWithName:@"AbstractInvocation" reason:@"This method is abstract." userInfo:nil];
}

-(BOOL)isRunning
{
	return (self.bodyA.isRunning && self.bodyB.isRunning);
}

-(void)tryAddToPhysicsNode:(CCPhysicsNode *)physicsNode
{
	if(self.isRunning && self.constraint.space == nil) [self addToPhysicsNode:physicsNode];
}

-(void)tryRemoveFromPhysicsNode:(CCPhysicsNode *)physicsNode
{
	if(self.constraint.space) [physicsNode.space smartRemove:self];
}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	@throw [NSException exceptionWithName:@"AbstractInvocation" reason:@"This method is abstract." userInfo:nil];
}

@end
