//
//  Profiling.h
//  cocos2d-iphone
//
//  Created by Stuart Carnie on 1/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/time.h>

@class CCProfilingTimer;

@interface CCProfiler : NSObject {
	NSMutableArray* activeTimers;
}

+ (CCProfiler*)sharedProfiler;
+ (CCProfilingTimer*)timerWithName:(NSString*)timerName andInstance:(id)instance;
+ (void)releaseTimer:(CCProfilingTimer*)timer;
- (void)displayTimers;

@end


@interface CCProfilingTimer : NSObject {
	NSString* name;
	struct timeval startTime;
	double averageTime;
}

@end

extern void CCProfilingBeginTimingBlock(CCProfilingTimer* timer);
extern void CCProfilingEndTimingBlock(CCProfilingTimer* timer);
