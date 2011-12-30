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

#import "../ccConfig.h"
#import "../ccMacros.h"

#import "CCProfiling.h"

#pragma mark - Profiling Categories

/* set to NO the categories that you don't want to profile */
BOOL kCCProfilerCategorySprite = NO;
BOOL kCCProfilerCategoryBatchSprite = NO;
BOOL kCCProfilerCategoryParticles = NO;


@interface CCProfilingTimer()
- (id)initWithName:(NSString*)timerName;
@end


#pragma mark - CCProfiler

@implementation CCProfiler

static CCProfiler* g_sharedProfiler;

+ (CCProfiler*)sharedProfiler
{
	if (!g_sharedProfiler)
		g_sharedProfiler = [[CCProfiler alloc] init];

	return g_sharedProfiler;
}

- (CCProfilingTimer*) createAndAddTimerWithName:(NSString*)timerName
{
	CCProfilingTimer* t = [[CCProfilingTimer alloc] initWithName:timerName];
	[activeTimers setObject:t forKey:timerName];
	[t release];
	return t;
}

- (void)releaseTimer:(NSString*)timerName
{
	[activeTimers removeObjectForKey:timerName];
}

- (void) releaseAllTimers
{
	[activeTimers removeAllObjects];
}

- (id)init
{
	if ((self = [super init])) {
		activeTimers = [[NSMutableDictionary alloc] initWithCapacity:10];
	}

	return self;
}

- (void)dealloc
{
	[activeTimers release];
	[super dealloc];
}

- (void)displayTimers
{
	NSArray *values = [activeTimers allValues];
	for (CCProfilingTimer *timer in values) {
		printf("%s\n", [[timer description] cStringUsingEncoding:[NSString defaultCStringEncoding]]);
	}
}

@end

#pragma mark - CCProfilingTimer


@implementation CCProfilingTimer

- (id)initWithName:(NSString*)timerName
{
	if ((self = [super init])) {
		name = [timerName copy];
		numberOfCalls = 0;
		averageTime = 0;
		totalTime = 0;
		minTime = 10000;
		maxTime = 0;
		gettimeofday(&startTime, NULL);
	}

	return self;
}

- (void)dealloc
{
	CCLOGINFO(@"deallocing %@", self);
	[name release];
	[super dealloc];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@ ::\tavg: %fms,\tmin: %fms,\tmax: %fms,\ttotal: %.2fs,\tnr calls: %d", name, averageTime, minTime, maxTime, totalTime / 1000.0, numberOfCalls];
}

-(void) reset
{
	numberOfCalls = 0;
	averageTime = 0;
	totalTime = 0;
	minTime = 10000;
	maxTime = 0;
	gettimeofday(&startTime, NULL);
}

@end


void CCProfilingBeginTimingBlock(NSString *timerName)
{
	CCProfiler* p = [CCProfiler sharedProfiler];
	CCProfilingTimer *timer = [p->activeTimers objectForKey:timerName];
	if( ! timer )
		timer = [p createAndAddTimerWithName:timerName];

	gettimeofday(&timer->startTime, NULL);

	timer->numberOfCalls++;
}

void CCProfilingEndTimingBlock(NSString *timerName)
{
	CCProfiler* p = [CCProfiler sharedProfiler];
	CCProfilingTimer *timer = [p->activeTimers objectForKey:timerName];

	NSCAssert1(timer, @"CCProfilingTimer %@ not found", timerName);

	struct timeval currentTime;
	gettimeofday(&currentTime, NULL);
	timersub(&currentTime, &timer->startTime, &currentTime);
	double duration = currentTime.tv_sec * 1000.0 + currentTime.tv_usec / 1000.0;

	// milliseconds
	timer->averageTime = (timer->averageTime + duration) / 2.0f;
	timer->totalTime += duration;
	timer->maxTime = MAX( timer->maxTime, duration);
	timer->minTime = MIN( timer->minTime, duration);

}

void CCProfilingResetTimingBlock(NSString *timerName)
{
	CCProfiler* p = [CCProfiler sharedProfiler];
	CCProfilingTimer *timer = [p->activeTimers objectForKey:timerName];

	NSCAssert1(timer, @"CCProfilingTimer %@ not found", timerName);

	[timer reset];
}
