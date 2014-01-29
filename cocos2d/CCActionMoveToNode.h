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
#import "CCActionInterval.h"

typedef CGPoint(^PositionUpdateBlock)(void);
typedef void(^ActionCompletedBlock)(void);

// -----------------------------------------------------------------
/** @name CCActionMoveToNode */

/**
 *  Moves a CCNode object to a moving target. The moving target can either be a CCNode or a moving position can be provided 
 *  by a block. The action can either end, once the target position is reached, or it can be continued infinitely, resulting 
 *  in the target of this action following the provided node or position infinitely.
 *
 *  Example for following a node:
 *  
 *  @code
 *  CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:200.f targetNode:myHero];
 *  @endcode
 *
 *  Example for providing a position using a block:
 *
 *  @code
 *  CCActionMoveToMovingTarget *moveTo = [CCActionMoveToMovingTarget actionWithSpeed:200.f positionUpdateBlock:^CGPoint{
 *     return [self calculateSomePosition];
 *  }];
 *  @endcode
 */
@interface CCActionMoveToNode : CCAction <NSCopying>

/**
 *  If you assign a block to this property, it will be called once the action is completed.
 *  In case you run this action as 'infinite follow', the actionCompletedBlock will be called the first time the target position
 *  is reached.
 *
 *  Example:
 *  @code
 *  [moveTo setActionCompletedBlock: ^(void) {
 *     CCLOG(@"Done!");
 *  }];
 *  @endcode
 */
@property (readwrite,nonatomic,copy) ActionCompletedBlock actionCompletedBlock;

/**
 *  Creates the action.
 *
 *  @param speed the speed of the movement in points per second within the parent's coordinate system
 *  @param targetNode the node which shall be followed
 *
 *  @return New MoveToMovingTarget action
 */
+(id) actionWithSpeed:(CGFloat)speed targetNode:(CCNode *)targetNode;

/**
 *  Creates the action.
 *
 *  @param speed the speed of the movement in points per second within the parent's coordinate system
 *  @param targetNode the node which shall be followed
 *  @param infinite Defines wether a node should follow the target infinitely; or stop once the target position is reached
 *
 *  @return New MoveToMovingTarget action
 */
+(id) actionWithSpeed:(CGFloat)speed targetNode:(CCNode *)targetNode followInfinite:(BOOL)infinite;

/**
 *  Creates the action.
 *
 *  @param speed the speed of the movement in points per second within the parent's coordinate system
 *  @param positionUpdateBlock a block that returns the target point for this action
 *
 *  @return New MoveToMovingTarget action
 */
+(id) actionWithSpeed:(CGFloat)speed positionUpdateBlock:(PositionUpdateBlock)block;

/**
 *  Creates the action.
 *
 *  @param speed the speed of the movement in points per second within the parent's coordinate system
 *  @param positionUpdateBlock a block that returns the target point for this action
 *  @param infinite Defines wether a node should follow the target infinitely; or stop once the target position is reached
 *
 *  @return New MoveToMovingTarget action
 */
+(id) actionWithSpeed:(CGFloat)speed positionUpdateBlock:(PositionUpdateBlock)block followInfinite:(BOOL)infinite;

/**
 *  Initializes the action.
 *
 *  @param speed the speed of the movement in points per second within the parent's coordinate system
 *  @param targetNode the node which shall be followed
 *
 *  @return New MoveToMovingTarget action
 */
-(id) initWithSpeed:(CGFloat)speed targetNode:(CCNode *)targetNode;

/**
 *  Initializes the action.
 *
 *  @param speed the speed of the movement in points per second within the parent's coordinate system
 *  @param targetNode the node which shall be followed
 *  @param infinite Defines wether a node should follow the target infinitely; or stop once the target position is reached
 *
 *  @return New MoveToMovingTarget action
 */
-(id) initWithSpeed:(CGFloat)speed targetNode:(CCNode *)targetNode followInfinite:(BOOL)infinite;

/**
 *  Initializes the action.
 *
 *  @param speed the speed of the movement in points per second within the parent's coordinate system
 *  @param positionUpdateBlock a block that returns the target point for this action
 *
 *  @return New MoveToMovingTarget action
 */
-(id) initWithSpeed:(CGFloat)speed positionUpdateBlock:(PositionUpdateBlock) block;

/**
 *  Initializes the action.
 *
 *  @param speed the speed of the movement in points per second within the parent's coordinate system
 *  @param positionUpdateBlock a block that returns the target point for this action
 *  @param infinite Defines wether a node should follow the target infinitely; or stop once the target position is reached
 *
 *  @return New MoveToMovingTarget action
 */
-(id) initWithSpeed:(CGFloat)speed positionUpdateBlock:(PositionUpdateBlock) block followInfinite:(BOOL)infinite;

@end
