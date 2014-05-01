/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCBSequenceProperty.h"

@class CCBSequence;

#pragma mark Animation Manager Delegate

@protocol CCBAnimationManagerDelegate <NSObject>

- (void) completedAnimationSequenceNamed:(NSString*)name;

@end

#pragma mark Animation Manager

@interface CCBAnimationManager : NSObject <CCSchedulerTarget>
{
    NSMutableDictionary* _nodeSequences;
    NSMutableDictionary* _baseValues;
    
    NSInteger _animationManagerId;
    CCBSequence* _runningSequence;
    CCBSequence* _lastSequence;
    
    void (^block)(id sender);
    
    CCScheduler* _scheduler;
    NSMutableArray* _currentActions;
    
    BOOL _loop;
    
}

// Sequence Array
@property (nonatomic,readonly) NSMutableArray* sequences;

// Auto play sequence id.
@property (nonatomic,assign) int autoPlaySequenceId;

// Animation manager updates on a fixed timestep.
@property (nonatomic,assign) bool fixedTimestep;

// Base node.
@property (nonatomic,unsafe_unretained) CCNode* rootNode;

// (CCB) Optional owner
@property (nonatomic,unsafe_unretained) id owner;

// (CCB) Resolution and default container size.
@property (nonatomic,assign) CGSize rootContainerSize;

// Delegate.
@property (nonatomic,weak) NSObject<CCBAnimationManagerDelegate>* delegate;

// Currently running sequence name.
@property (unsafe_unretained, nonatomic,readonly) NSString* runningSequenceName;

// Last sequence name completed.
@property (nonatomic,readonly) NSString* lastCompletedSequenceName;

// Speed.
@property (nonatomic,assign) float playbackSpeed;

// Pause.
@property (nonatomic,assign) bool paused;

// (CCB) Node Management
- (CGSize) containerSize:(CCNode*)node;
- (void) addNode:(CCNode*)node andSequences:(NSDictionary*)seq;
- (void) moveAnimationsFromNode:(CCNode*)fromNode toNode:(CCNode*)toNode;

// Reset node state.
- (void) setBaseValue:(id)value forNode:(CCNode*)node propertyName:(NSString*)propName;

// Run an animation.
- (void) runAnimationsForSequenceNamed:(NSString*)name;
- (void) runAnimationsForSequenceNamed:(NSString*)name tweenDuration:(float)tweenDuration;
- (void) runAnimationsForSequenceId:(int)seqId tweenDuration:(float) tweenDuration;

// Animation call back.
-(void) setCompletedAnimationCallbackBlock:(void(^)(id sender))b;

#pragma mark Time Controls
- (void)timeSeekForSequenceNamed:(NSString*)name time:(float)time;
- (void)timeSeekForSequenceId:(int)seqId time:(float)time;

#pragma mark Simple Sequence Builder
- (void)addKeyFramesForSequenceNamed:(NSString*)name propertyType:(CCBSequencePropertyType)propertyType frameArray:(NSArray*)frameArray node:(CCNode *)node loop:(BOOL)loop;

@end
