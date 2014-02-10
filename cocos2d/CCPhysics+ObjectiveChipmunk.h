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
#import "CCPhysicsShape.h"
#import "CCPhysicsNode.h"
#import "CCPhysicsJoint.h"
#import "ObjectiveChipmunk/ObjectiveChipmunk.h"

// In the future, this header will be useful for writing your own Objective-Chipmunk
// code to interact with CCPhysics. For now, it's not very well documented on how to do it.
// Do ask questions on the Cocos2D forums if you are interested in learning how.
//
// Things to consider:
//  Projectile bodies?
//  Interpolation?
//  Post-step callbacks?
//  What to do about CCActions?
//  Check argument types for delegate callbacks?
//  Angular velocity in degrees?
//  Warnings for CCPhysicsCollisionPair methods in the wrong event cycle?
//  Should CCPhysicsCollisionPair.userData retain?


#if CP_USE_CGTYPES

#define CCP_TO_CPV(p) (p)
#define CPV_TO_CCP(p) (p)

#define CPTRANSFORM_TO_CGAFFINETRANSFORM(t) (t)
#define CGAFFINETRANSFORM_TO_CPTRANSFORM(t) (t)

#else

// If Chipmunk is not configured to use CG types then they will need to be converted.
static inline cpVect CCP_TO_CPV(CGPoint p){return cpv(p.x, p.y);}
static inline CGPoint CPV_TO_CCP(cpVect p){return CGPointMake(p.x, p.y);}

static inline CGAffineTransform CPTRANSFORM_TO_CGAFFINETRANSFORM(cpTransform t){return CGAffineTransformMake(t.a, t.b, t.c, t.d, t.tx, t.ty);}
static inline cpTransform CGAFFINETRANSFORM_TO_CPTRANSFORM(CGAffineTransform t){return cpTransformNew(t.a, t.b, t.c, t.d, t.tx, t.ty);}

#endif

@interface CCPhysicsBody (ObjectiveChipmunk)<ChipmunkObject>

/** The CCNode this physics body is attached to. */
@property(nonatomic, weak) CCNode *node;

/** The CCPhysicsNode this body is added to. */
@property(nonatomic, readonly) CCPhysicsNode *physicsNode;

/** Returns YES if the body is currently added to a physicsNode. */
@property(nonatomic, readonly) BOOL isRunning;

/** The position of the body relative to the space. */
@property(nonatomic, assign) CGPoint absolutePosition;

/** The rotation of the body relative to the space. */
@property(nonatomic, assign) CGFloat absoluteRadians;

/** The transform of the body relative to the space. */
@property(nonatomic, readonly) CGAffineTransform absoluteTransform;

/** Chipmunk Body. */
@property(nonatomic, readonly) ChipmunkBody *body;

/** Implements the ChipmunkObject protocol. */
@property(nonatomic, readonly) NSArray *chipmunkObjects;

/**
 *  Add joint to body.
 *
 *  @param joint Physics joint to use.
 */
-(void)addJoint:(CCPhysicsJoint *)joint;

/**
 *  Remove joint from body.
 *
 *  @param joint Physics joint to remove.
 */
-(void)removeJoint:(CCPhysicsJoint *)joint;

/**
 *  Used for deferring collision type setup until there is access to the physics node.
 *
 *  @param physics Physics node.
 *  @param transform Transform to use.
 */
-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics nonRigidTransform:(cpTransform)transform;

/**
 *  Used for deferring collision type setup until there is access to the physics node.
 *
 *  @param physics Physics node.
 */
-(void)didAddToPhysicsNode:(CCPhysicsNode *)physics;

/**
 *  Used for deferring collision type setup until there is access to the physics node.
 *
 *  @param physics Physics node.
 */
-(void)didRemoveFromPhysicsNode:(CCPhysicsNode *)physics;

@end


@interface CCPhysicsShape(ObjectiveChipmunk)

/** Access to the underlying Objective-Chipmunk shape object. */
@property(nonatomic, readonly) ChipmunkShape *shape;

/** Next shape in the linked list. */
@property(nonatomic, strong) CCPhysicsShape *next;

/** Body this shape is attached to. */
@property(nonatomic, weak) CCPhysicsBody *body;

/**
 *  Used for deferring collision type setup until there is access to the physics node.
 *
 *  @param physics Physics node.
 *  @param transform Transform to use.
 */
-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics nonRigidTransform:(cpTransform)transform;

/**
 *  Used for deferring collision type setup until there is access to the physics node.
 *
 *  @param physics Physics node.
 */
-(void)didRemoveFromPhysicsNode:(CCPhysicsNode *)physics;

@end


@interface CCPhysicsJoint(ObjectiveChipmunk)<ChipmunkObject>

/** Access to the underlying Objective-Chipmunk object. */
@property(nonatomic, readonly) ChipmunkConstraint *constraint;

/** Returns YES if the body is currently added to a physicsNode. */
@property(nonatomic, readonly) BOOL isRunning;

/**
 *  Add the join to the physics node, but only if both connected bodies are running.
 *
 *  @param physicsNode Physics node.
 */
-(void)tryAddToPhysicsNode:(CCPhysicsNode *)physicsNode;

/**
 *  Remove the joint from the physics node, but only if the joint is added.
 *
 *  @param physicsNode Physics node.
 */
-(void)tryRemoveFromPhysicsNode:(CCPhysicsNode *)physicsNode;

/**
 *  Used for deferring collision type setup until there is access to the physics node.
 *
 *  @param physics Physics node.
 */
-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics;

@end


@interface CCPhysicsCollisionPair(ObjectiveChipmunk)

/// Access to the underlying Objective-Chipmunk object.
@property(nonatomic, assign) cpArbiter *arbiter;

@end


@interface CCPhysicsNode(ObjectiveChipmunk)

/** Access to the underlying Objective-Chipmunk object. */
@property(nonatomic, readonly) ChipmunkSpace *space;

/**
 *  Intern and copy a string to ensure it can be checked by reference
 *  Used for collision type identifiers by CCPhysics.
 *  Nil and @"default" both return the value nil.
 *
 *  @param string Intern string.
 *
 *  @return String.
 */
-(NSString *)internString:(NSString *)string;

/**
 *  Retain and track a category identifier and return its index.
 *  Up to 32 categories can be tracked for a space.
 *
 *  @param category String category.
 *
 *  @return Category index.
 */
-(NSUInteger)indexForCategory:(NSString *)category;

/**
 *  Convert an array of NSStrings for collision category identifiers into a category bitmask.
 *  The categories are retained and assigned indexes.
 *  Up to 32 categories can be tracked for a space.
 *
 *  @param categories Array of categories.
 *
 *  @return Bitmask.
 */
-(cpBitmask)bitmaskForCategories:(NSArray *)categories;

/**
 *  Convert a cpBitmask value to an array of collision category strings.
 *  Ignores any bits that don't have a collision category assigned in the physics node.
 *
 *  @param categories Category bitmask.
 *
 *  @return Array of collision categories.
 */
-(NSArray *)categoriesForBitmask:(cpBitmask)categories;

@end
