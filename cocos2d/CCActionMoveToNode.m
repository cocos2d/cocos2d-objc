/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 MakeGamesWithUs Inc.
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
 *
 */

#import "CCActionMoveToNode.h"

@implementation CCActionMoveToNode {
    // speed of the movement in points/seconds
    CGFloat _speed;
    // variable to determine if this action is completed
    BOOL _done;
    /* stores if the ActionCompleted block has already been called for an infinite follow action.
     For infinite follow actions the block is only allowed to be called once */
    BOOL _actionCompletedOnce;
    // block that provides target position
    PositionUpdateBlock _positionUpdateBlock;
    // node that shall be followed
    CCNode *_targetNode;
    // defines wether a node should follow the target infinitely; or stop once the target position is reached
    BOOL _followInfinite;
}

- (void)dealloc {
    CCLOG(@"gone");
}

#pragma mark - Initializers

+ (id)actionWithSpeed:(CGFloat)speed positionUpdateBlock:(PositionUpdateBlock)block followInfinite:(BOOL)infinite
{
    return [[self alloc] initWithSpeed:speed positionUpdateBlock:block followInfinite:infinite];
}

+ (id)actionWithSpeed:(CGFloat)speed positionUpdateBlock:(PositionUpdateBlock)block
{
    return [[self alloc] initWithSpeed:speed positionUpdateBlock:block];
}

+ (id)actionWithSpeed:(CGFloat)speed targetNode:(CCNode *)targetNode followInfinite:(BOOL)infinite
{
    return [[self alloc] initWithSpeed:speed targetNode:targetNode followInfinite:infinite];
}

+ (id)actionWithSpeed:(CGFloat)speed targetNode:(CCNode *)targetNode
{
    return [[self alloc] initWithSpeed:speed targetNode:targetNode];
}

- (id)initWithSpeed:(CGFloat)speed positionUpdateBlock:(PositionUpdateBlock)block followInfinite:(BOOL)infinite {
    self = [super init];
    
    if (self) {
        _positionUpdateBlock = block;
        _speed = speed;
        _followInfinite = infinite;
    }
    
    return self;
}

- (id)initWithSpeed:(CGFloat)speed positionUpdateBlock:(PositionUpdateBlock)block
{
    return [self initWithSpeed:speed positionUpdateBlock:block followInfinite:NO];
}

- (id)initWithSpeed:(CGFloat)speed targetNode:(CCNode *)targetNode followInfinite:(BOOL)infinite {
    self = [super init];
    
    if (self) {
        _targetNode = targetNode;
        _speed = speed;
        _followInfinite = infinite;
    }
    
    return self;
}

- (id)initWithSpeed:(CGFloat)speed targetNode:(CCNode *)targetNode
{
    return [self initWithSpeed:speed targetNode:targetNode followInfinite:NO];
}

#pragma mark - NSCopying

-(id) copyWithZone: (NSZone*) zone
{
    CCAction *copy = nil;
    
    if (_targetNode) {
        copy = [[[self class] allocWithZone: zone] initWithSpeed:_speed targetNode:_targetNode];
    } else {
        copy = [[[self class] allocWithZone: zone] initWithSpeed:_speed positionUpdateBlock:_positionUpdateBlock];
    }
    
	return copy;
}

#pragma mark - CCAction override

- (void)step:(CCTime)dt
{
    CGPoint endPosition = CGPointZero;
    
    if (_positionUpdateBlock) {
        // if a block is provided, get target position by executing the block
        endPosition = _positionUpdateBlock();
    }  else if (_targetNode) {
        // if a node shall be followed, get the world position of that node
        CGPoint worldPos = [_targetNode.parent convertToWorldSpace:_targetNode.position];
        // and convert the position to the node space of the target of this action
        endPosition = [[(CCNode*)_target parent] convertToNodeSpace:worldPos];
    } 

    CCNode *actionTargetNode = (CCNode*)_target;

    // calculate distance between node and target position
    CGPoint positionDelta = ccpSub(endPosition, actionTargetNode.position);
    
    // normalize distance -> results in a movement vector
    CGPoint normalizedDiff = ccpNormalize(positionDelta);
    
    // multiply the movement vector with the speed
    CGPoint moveBy = ccpMult(normalizedDiff, (dt * _speed));
    
    // calculate the new position of this node
    CGPoint newPos =  ccpAdd(actionTargetNode.position, moveBy);
    
    // if moveBy > position delta, we would be shooting past the target, instead set position to target position
    CGFloat moveByLength = ccpLength(moveBy);
    CGFloat distanceTargetLength = ccpLength(positionDelta);
    
    if (moveByLength > distanceTargetLength) {
        // if this isn't an infinite action, it is completed, because we reached the target position
        if (!_followInfinite) {
            _done = YES;
            
            if (self.actionCompletedBlock) {
                self.actionCompletedBlock();
            }
        }
        // if this is an infinite action, only call the action completion block once
        else if (_followInfinite && !_actionCompletedOnce) {
            _actionCompletedOnce = YES;
            
            if (self.actionCompletedBlock) {
                self.actionCompletedBlock();
            }
        }
        
        newPos = endPosition;
    }
    
	[_target setPosition: newPos];
}

- (BOOL) isDone
{
	return _done;
}

@end
