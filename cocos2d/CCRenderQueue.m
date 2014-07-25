/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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

#import "CCRenderQueue.h"


/// Maximum number of frames that can be queued at once.
#define CCRENDER_QUEUE_MAX_COUNT 3

/// EAGLContext created by the rendering queue
static EAGLContext *CCRENDER_QUEUE_CONTEXT = nil;
/// Dispatch queue that backs the queue.
static dispatch_queue_t CCRENDER_QUEUE = nil;
/// Semaphore to control the number of in-progress frames being rendered.
static dispatch_semaphore_t CCRENDER_QUEUE_SEMAPHORE = nil;


EAGLContext *CCRenderQueueSetup(void)
{
	static dispatch_once_t once = 0;
	dispatch_once(&once, ^{
		CCRENDER_QUEUE = dispatch_queue_create("CCRenderQueue", DISPATCH_QUEUE_SERIAL);
		CCRENDER_QUEUE_CONTEXT = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		CCRENDER_QUEUE_SEMAPHORE = dispatch_semaphore_create(CCRENDER_QUEUE_MAX_COUNT);
	});
	
	return CCRENDER_QUEUE_CONTEXT;
}

BOOL CCRenderQueueReady(void)
{
	return !dispatch_semaphore_wait(CCRENDER_QUEUE_SEMAPHORE, 0);
}

void CCRenderQueueAsync(BOOL frame, void (^block)())
{
	dispatch_async(CCRENDER_QUEUE, ^{
		[EAGLContext setCurrentContext:CCRENDER_QUEUE_CONTEXT];
		block();
		[EAGLContext setCurrentContext:nil];
		
		if(frame) dispatch_semaphore_signal(CCRENDER_QUEUE_SEMAPHORE);
	});
}

void CCRenderQueueSync(BOOL frame, void (^block)())
{
	dispatch_sync(CCRENDER_QUEUE, ^{
		[EAGLContext setCurrentContext:CCRENDER_QUEUE_CONTEXT];
		block();
		[EAGLContext setCurrentContext:nil];
		
		if(frame) dispatch_semaphore_signal(CCRENDER_QUEUE_SEMAPHORE);
	});
}
