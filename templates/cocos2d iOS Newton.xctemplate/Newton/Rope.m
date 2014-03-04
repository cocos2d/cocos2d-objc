/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Lars Birkemose
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

#import "Rope.h"
#import "NewtonSphere.h"
#import "ObjectiveChipmunk.h"

// -----------------------------------------------------------------------
#pragma mark Rope
// -----------------------------------------------------------------------

@implementation Rope

// -----------------------------------------------------------------------
#pragma mark - Create and Destroy
// -----------------------------------------------------------------------

+ (instancetype)ropeWithSegments:(int)segments objectA:(CCNode *)objectA posA:(CGPoint)posA objectB:(CCNode *)objectB posB:(CGPoint)posB
{
    return([[Rope alloc] initWithSegments:segments objectA:objectA posA:posA objectB:objectB posB:posB]);
}

- (instancetype)initWithSegments:(int)segments objectA:(CCNode *)objectA posA:(CGPoint)posA objectB:(CCNode *)objectB posB:(CGPoint)posB
{
    // Apple recommend assigning self with supers return value, and handling self not created
    self = [super init];
    if (!self) return(nil);

    NSAssert(segments > 1, @"Rope must have at least two segments");

    // Create a rope with variable number of segments
    CGPoint directionVector = ccpNormalize(ccpSub(posB, posA));
    CGPoint currentPos = posA;
    float segmentLength = ccpDistance(posA, posB) / segments;
    CGPoint segmentVector = ccpMult(directionVector, segmentLength);
    
    NSAssert(segmentLength > 0, @"Segment length must be greater then zero");
    
    //
    CCNode* previousNode = objectA;
    if (!previousNode)
    {
        // if no start body exists, create a static body at the start position
        previousNode = [CCNode node];
        previousNode.position = posA;
        previousNode.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
        previousNode.physicsBody.type = CCPhysicsBodyTypeStatic;
        [self addChild:previousNode];
    }
    CGPoint jointAnchor = ccpSub(posA, previousNode.position);
    
    for (int segment = 0; segment < segments; segment ++)
    {
        // calculate position of current segment
        CGPoint segmentPos = ccpAdd(currentPos, ccpMult(segmentVector, 0.5));
        // create a rope segment sprite
        CCNode *baseSegment = [CCNode node];
        baseSegment.position = segmentPos;

        // add a sprite
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"rope.png"];
        sprite.color = CCNewtonRopeColor;
        [baseSegment addChild:sprite];
        
        // adjust the length of the sprite, to match the segment length
        sprite.scaleY = segmentLength / sprite.contentSize.height;

        // add the physics
        // the physics is a rounded pill shape, stretching half the segmentVetor in each direction
        baseSegment.physicsBody = [CCPhysicsBody bodyWithPillFrom:ccpMult(segmentVector, -0.5)
                                                               to:ccpMult(segmentVector, 0.5)
                                                     cornerRadius:sprite.contentSize.width * 0.5];
        
        baseSegment.physicsBody.mass = NewtonRopeNormalMass;
        
        // add collisions
        baseSegment.physicsBody.collisionCategories = @[NewtonSphereCollisionRope];
        baseSegment.physicsBody.collisionMask = @[];
        
        // add rope segments to same grounp, so that they dont collide with each other
        baseSegment.physicsBody.collisionGroup = self;
        
        // add the compound rope piece, to the entire rope
        [self addChild:baseSegment];
        
        // attach joint to previous body
        
        [CCPhysicsJoint connectedPivotJointWithBodyA:previousNode.physicsBody bodyB:baseSegment.physicsBody anchorA:jointAnchor];
        jointAnchor = ccpMult(segmentVector, 0.5);
        previousNode = baseSegment;
        
        // advance to next pos
        currentPos = ccpAdd(currentPos, segmentVector);
    
    }
    
    // attach last joint, to objectB
    if (!objectB)
    {
        // if no end body exists, create a static body at the end position
        objectB = [CCNode node];
        objectB.position = posB;
        objectB.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:CGPointZero];
        objectB.physicsBody.type = CCPhysicsBodyTypeStatic;
        [self addChild:objectB];
    }
    
    // attach the final joint
    [CCPhysicsJoint connectedPivotJointWithBodyA:previousNode.physicsBody
                                           bodyB:objectB.physicsBody
                                         anchorA:jointAnchor];
    


    // done
    return(self);
}

- (void)dealloc
{
    CCLOG(@"A rope was deallocated");
    // clean up code goes here, should there be any
    
}

// -----------------------------------------------------------------------

@end
