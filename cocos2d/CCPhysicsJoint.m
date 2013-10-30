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

// TODO temporary
static inline void NYI(){@throw @"Not Yet Implemented";}


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
		_anchor = anchor;
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	CCPhysicsBody *bodyA = self.bodyA;
	CGPoint anchor = cpTransformPoint(bodyA.node.nonRigidTransform, _anchor);
	
	_constraint.anchr1 = anchor;
	_constraint.anchr2 = [_constraint.bodyB worldToLocal:[_constraint.bodyA localToWorld:anchor]];
}

@end


@implementation CCPhysicsJoint

-(id)init
{
	if((self = [super init])){
		
	}
	
	return self;
}

-(void)addToPhysicsNode:(CCPhysicsNode *)physicsNode
{
	NSAssert(self.bodyA.physicsNode == self.bodyB.physicsNode, @"Bodies connected by a joint must be added to the same CCPhysicsNode.");
	
	[self willAddToPhysicsNode:physicsNode];
	[physicsNode.space smartAdd:self];
}

+(CCPhysicsJoint *)connectedPivotJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchor:(CGPoint)anchor
{
	CCPhysicsJoint *joint = [[CCPhysicsPivotJoint alloc] initWithBodyA:bodyA bodyB:bodyB anchor:anchor];
	[bodyA addJoint:joint];
	[bodyB addJoint:joint];
	
	[joint addToPhysicsNode:bodyA.physicsNode];
	
	return joint;
}

-(CCPhysicsBody *)bodyA {return self.constraint.bodyA.userData;}
-(void)setBodyA:(CCPhysicsBody *)bodyA {NYI();}

-(CCPhysicsBody *)bodyB {return self.constraint.bodyB.userData;}
-(void)setBodyB:(CCPhysicsBody *)bodyB {NYI();}

-(CGFloat)maxForce {return self.constraint.maxForce;}
-(void)setMaxForce:(CGFloat)maxForce {self.constraint.maxForce = maxForce;}

-(CGFloat)impulse {return self.constraint.impulse;}

-(void)invalidate {
	[self tryRemoveFromPhysicsNode:self.bodyA.physicsNode];
	[self.bodyA removeJoint:self];
	[self.bodyB removeJoint:self];
}

-(void)setBreakingForce:(CGFloat)breakingForce {NYI();}

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
