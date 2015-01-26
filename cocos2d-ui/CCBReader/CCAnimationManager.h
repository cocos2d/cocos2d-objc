/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
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

/**
 The animation manager delegate receives callbacks when animation sequences finishes playing.
 Used by CCAnimationManager.
 */
@protocol CCBAnimationManagerDelegate <NSObject>

/**
 * Called when an animation sequence has finished playing.
 * @param name The name of the sequence that just finished playing.
 */
- (void) completedAnimationSequenceNamed:(NSString*)name;

@end

#pragma mark Animation Manager

/**
 The animation manager plays back animations, usually created by a tool such as SpriteBuilder.
 Any animation can have an arbitrary number of sequences (timelines) which each have keyframes for different properties.
 
 @note Animation names are case sensitive.
 */
@interface CCAnimationManager : NSObject <CCSchedulerTarget>
{
    NSMutableDictionary* _nodeSequences;
    NSMutableDictionary* _baseValues;
    
    NSInteger _animationManagerId;
    CCBSequence* _runningSequence;
    CCBSequence* _lastSequence;
    
    void (^block)(id sender);
    
    CCScheduler* _scheduler;
    NSMutableArray* _currentActions;
    
}

/** @name Altering Animation Playback */

/// If set to true the animation manager will run on a fixed time step. This is required to run animations synchronized with physics updates.
@property (nonatomic,assign) bool fixedTimestep;

/// Playback speed, default is 1 and corresponds to the normal playback speed. Use this property for fast forward or slow motion playback.
@property (nonatomic,assign) float playbackSpeed;

/// Set to true to pause the animation currently being run.
@property (nonatomic,assign) bool paused;


/** @name Playing Animations */

/// The name of the currently running sequence (timeline).
@property (unsafe_unretained, nonatomic,readonly) NSString* runningSequenceName;

/**
 * Plays an animation sequence (timeline) by its name.
 * @param name The name of the sequence to play.
 * @see runAnimationsForSequenceNamed:tweenDuration:
 * @see runningSequenceName
 */
- (void) runAnimationsForSequenceNamed:(NSString*)name;

/**
 * Plays an animation sequence (timeline) by its name, tweens smoothly to the new sequence.
 * @param name The name of the sequence to play.
 * @param tweenDuration Time to tween to the new sequence.
 * @see runAnimationsForSequenceNamed:
 * @see runningSequenceName
 */
- (void) runAnimationsForSequenceNamed:(NSString*)name tweenDuration:(float)tweenDuration;

#pragma mark Time Controls

//Renamed to jumpToSequenceNamed:time
//- (void)timeSeekForSequenceNamed:(NSString*)name time:(float)time __attribute__((deprecated));

/**
 * Jumps to a specific time in a specific sequence (timeline).
 * @param name The name of the sequence to jump to.
 * @param time The time in the sequence.
 */
- (void)jumpToSequenceNamed:(NSString*)name time:(float)time;


/** @name Animation Playback Ended */

/// The name of the last completed sequence (timeline).
@property (nonatomic,readonly) NSString* lastCompletedSequenceName;

/**
 * Sets a block to be called when an animation sequence has finished playing.
 * @param b The block to call.
 */
-(void) setCompletedAnimationCallbackBlock:(void(^)(id sender))b;

/// The animation manager delegate receives updates about the animation playback state.
/// @see CCBAnimationManagerDelegate
@property (nonatomic,weak) NSObject<CCBAnimationManagerDelegate>* delegate;

@end
