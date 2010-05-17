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

#import "ccConfig.h"

#if CC_ENABLE_PROFILERS

#import "CCProfiling.h"

@interface CCProfilingTimer()
- (id)initWithName:(NSString*)timerName andInstance:(id)instance;
@end

@implementation CCProfiler

static CCProfiler* g_sharedProfiler;

+ (CCProfiler*)sharedProfiler {
	if (!g_sharedProfiler)
		g_sharedProfiler = [[CCProfiler alloc] init];
	
	return g_sharedProfiler;
}

+ (CCProfilingTimer*)timerWithName:(NSString*)timerName andInstance:(id)instance {
	CCProfiler* p = [CCProfiler sharedProfiler];
	CCProfilingTimer* t = [[CCProfilingTimer alloc] initWithName:timerName andInstance:instance];
	[p->activeTimers addObject:t];
	[t release];
	return t;
}

+ (void)releaseTimer:(CCProfilingTimer*)timer {
	CCProfiler* p = [CCProfiler sharedProfiler];
	[p->activeTimers removeObject:timer];
}

- (id)init {
	if (!(self = [super init])) return nil;
	
	activeTimers = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc {
	[activeTimers release];
	[super dealloc];
}

- (void)displayTimers {	
	for (id timer in activeTimers) {
		printf("%s\n", [[timer description] cStringUsingEncoding:[NSString defaultCStringEncoding]]);
	}
}

@end

@implementation CCProfilingTimer

- (id)initWithName:(NSString*)timerName andInstance:(id)instance {
	if (!(self = [super init])) return nil;
	
	name = [[NSString stringWithFormat:@"%@ (0x%.8x)", timerName, instance] retain];
	
	return self;
}

- (void)dealloc {
	[name release];
	[super dealloc];
}

- (NSString*)description {
	return [NSString stringWithFormat:@"%@ : avg time, %fms", name, averageTime];
}

void CCProfilingBeginTimingBlock(CCProfilingTimer* timer) {
	gettimeofday(&timer->startTime, NULL);
}

typedef unsigned int uint32;
void CCProfilingEndTimingBlock(CCProfilingTimer* timer) {
	struct timeval currentTime;
	gettimeofday(&currentTime, NULL);
	timersub(&currentTime, &timer->startTime, &currentTime);
	double duration = currentTime.tv_sec * 1000.0 + currentTime.tv_usec / 1000.0;
	
	// return in milliseconds
	timer->averageTime = (timer->averageTime + duration) / 2.0f;
}

@end

#endif
