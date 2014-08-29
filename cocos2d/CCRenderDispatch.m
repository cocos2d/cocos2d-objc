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

#import "CCRenderDispatch_Private.h"
#import "CCGL.h"

#if CC_RENDER_DISPATCH_ENABLED

/// Maximum number of frames that can be queued at once.
#define CC_RENDER_DISPATCH_MAX_FRAMES 3

/// Dispatch queue that backs the queue.
static dispatch_queue_t CC_RENDER_DISPATCH_QUEUE = nil;
/// Semaphore to control the number of in-progress frames being rendered.
static dispatch_semaphore_t CC_RENDER_DISPATCH_SEMAPHORE = nil;
/// EAGLContext used by the GL queue
static EAGLContext *CC_RENDER_DISPATCH_CONTEXT = nil;


EAGLContext *CCRenderDispatchSetupGL(EAGLRenderingAPI api, EAGLSharegroup *sharegroup)
{
	NSCAssert(CC_RENDER_DISPATCH_ENABLED, @"Threaded rendering is not enabled.");
	
	static dispatch_once_t once = 0;
	dispatch_once(&once, ^{
		CC_RENDER_DISPATCH_CONTEXT = [[EAGLContext alloc] initWithAPI:api sharegroup:sharegroup];
		
		CC_RENDER_DISPATCH_QUEUE = dispatch_queue_create("CCRenderQueue", DISPATCH_QUEUE_SERIAL);
		CC_RENDER_DISPATCH_SEMAPHORE = dispatch_semaphore_create(CC_RENDER_DISPATCH_MAX_FRAMES);
	});
	
	return CC_RENDER_DISPATCH_CONTEXT;
}

#endif


static void CCRenderDispatchExecute(BOOL threadsafe, BOOL frame, dispatch_block_t block)
{
#if CC_RENDER_DISPATCH_ENABLED
	(threadsafe ? dispatch_async : dispatch_sync)(CC_RENDER_DISPATCH_QUEUE, ^{
		[EAGLContext setCurrentContext:CC_RENDER_DISPATCH_CONTEXT];
		
		block();
		
		CC_CHECK_GL_ERROR_DEBUG();
		[EAGLContext setCurrentContext:nil];
		
		if(frame) dispatch_semaphore_signal(CC_RENDER_DISPATCH_SEMAPHORE);
	});
#else
	block();
#endif
}

BOOL CCRenderDispatchBeginFrame(void)
{
#if CC_RENDER_DISPATCH_ENABLED
	return !dispatch_semaphore_wait(CC_RENDER_DISPATCH_SEMAPHORE, 0);
#else
	return YES;
#endif
}

void CCRenderDispatchCommitFrame(BOOL threadsafe, dispatch_block_t block)
{
	CCRenderDispatchExecute(threadsafe, YES, block);
}

void CCRenderDispatch(BOOL threadsafe, dispatch_block_t block)
{
	CCRenderDispatchExecute(threadsafe, NO, block);
}
