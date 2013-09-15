/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Stuart Carnie
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


#import <Foundation/Foundation.h>
#import <sys/time.h>

@class CCProfilingTimer;

/** CCProfiler
 cocos2d builtin profiler.

 To use it, enable set the CC_ENABLE_PROFILERS=1 in the ccConfig.h file
 */
@interface CCProfiler : NSObject {
@public
	NSMutableDictionary* activeTimers;
}

/** shared instance */
+ (CCProfiler*)sharedProfiler;

/** Creates and adds a new timer */
- (CCProfilingTimer*) createAndAddTimerWithName:(NSString*)timerName;

/** releases a timer */
- (void)releaseTimer:(NSString*)timerName;

/** releases all timers */
- (void) releaseAllTimers;

/** display the timers */
- (void)displayTimers;

@end

/** CCProfilingTimer
Profiling timers used by CCProfiler
 */
@interface CCProfilingTimer : NSObject {

@public
	NSString		*name;
	struct timeval	startTime;
	double			averageTime;
	double			minTime;
	double			maxTime;
	double			totalTime;
	NSUInteger		numberOfCalls;
}

/** resets the timer properties */
-(void) reset;
@end

extern void CCProfilingBeginTimingBlock(NSString *timerName);
extern void CCProfilingEndTimingBlock(NSString *timerName);
extern void CCProfilingResetTimingBlock(NSString *timerName);

/*
 * cocos2d profiling categories
 * used to enable / disable profilers with granularity
 */

extern BOOL kCCProfilerCategorySprite;
extern BOOL kCCProfilerCategoryBatchSprite;
extern BOOL kCCProfilerCategoryParticles;
