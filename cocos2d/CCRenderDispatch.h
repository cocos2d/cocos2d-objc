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

#import <dispatch/dispatch.h>
#import "ccMacros.h"

/*
	A multi-threaded rendering for iOS based on a serial dispatch queue.
	
	Multi-threading is disabled by default and must be explicitly enabled by setting CC_DIRECTOR_IOS_THREADED_RENDERING.
	This is required for backwards compatibility as it requires all GL code to be run on the queue.
	If you aren't using custom GL code, enabling multi-threading should "just work". If your game is GPU bound (drawing too many pixels or
	too many complicated shaders) then multi-threaded rendering will not help your performance. If you game is CPU bound (too much physics,
	AI, too many draw calls, etc) then multi-threaded rendering can help your performance.
	
	
	Supporting Multi-threading in Custom GL Code:
	
	First of all, if you are writing custom drawing methods that use [CCRenderer enqueueTriangles:] instead of custom GL code,
	then you don't need to do anything else. These APIs were created with multi-threading in mind from the start.
	
	Adding support for the multi-threaded renderer is fairly straightforward. All GL functions must be called on the GL queue either by
	equeueing them to a CCRenderer or wrapping them in a CCRenderDispatch() block. Since custom GL rendering already needs to be queued to
	the renderer, generally all you need to do is wrap any GL code in your init or dealloc methods with CCRenderDispatch(). If you want
	to write custom rendering code that is compatible with both multi-threading and Cocos2D 3.1 check for the CC_RENDER_DISPATCH_ENABLED token.
	
	
	Notes:
	* A CCRenderer will not be executed asychronously unless all blocks queued to it are marked as threadsafe.
	* CCClippingNode and rendering to CCRenderTexture do not yet work with multithreading and will force a fallback to synchronous rendering.
*/

/// Preprocessor token that can be used to detect if the GL queue is enabled.
#define CC_RENDER_DISPATCH_ENABLED (__CC_PLATFORM_IOS && CC_DIRECTOR_IOS_THREADED_RENDERING)

/// Enqueue a block to be executed on the render queue.
/// If 'threadsafe' is NO then the block will be executed synchronously.
/// If threaded rendering is not enabled then the block will be invoked immediately on the calling thread.
void CCRenderDispatch(BOOL threadsafe, dispatch_block_t block);
