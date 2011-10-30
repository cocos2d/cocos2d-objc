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
