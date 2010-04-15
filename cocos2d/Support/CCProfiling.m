//
//  Profiling.m
//  cocos2d-iphone
//
//  Created by Stuart Carnie on 1/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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
