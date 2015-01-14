/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2015 Cocos2D Authors
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

#import "CCScheduler.h"

@class CCScheduler;

/**
 Private CCScheduler methods. Generally only useful within cocos2d. Instead, interface with the scheduler by scheduling things on CCNodes.
 
 @since v4.0
 */
@interface CCScheduler()

/**
Update the scheduler by stepping forward in time. You should NEVER call this method, unless you know what you are doing.

@param dt time delta- step forward by this many sections
*/
-(void) update:(CCTime)dt;

-(CCTimer *) scheduleBlock:(CCTimerBlock)block forTarget:(NSObject<CCSchedulerTarget> *)target withDelay:(CCTime)delay;

-(void) scheduleTarget:(NSObject<CCSchedulerTarget> *)target;

/**
 Unschedules all selectors and blocks for a given target.
 This also includes the "update" selector.
 */
-(void) unscheduleTarget:(NSObject<CCSchedulerTarget> *)target;

// This is used only for testing at the moment.
-(BOOL) isTargetScheduled:(NSObject<CCSchedulerTarget> *)target;

-(void) setPaused:(BOOL)paused target:(NSObject<CCSchedulerTarget> *)target;

-(BOOL) isTargetPaused:(NSObject<CCSchedulerTarget> *)target;

-(NSArray *) timersForTarget:(NSObject<CCSchedulerTarget> *)target;

@end

