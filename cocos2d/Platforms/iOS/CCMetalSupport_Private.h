/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013-2014 Cocos2D Authors
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

#import "ccMacros.h"
#if __CC_METAL_SUPPORTED_AND_ENABLED

#import <Metal/Metal.h>

#import "CCRenderer_Private.h"

// This is effectively hardcoded to 10 by Apple's docs and there is no API to query capabilities...
// Seems like an oversight, but whatever.
#define CCMTL_MAX_TEXTURES 10

// Maximum uniform bytes that can be passed to a shader.
// This space is preallocated by all render states.
#define CCMTL_MAX_UNIFORM_BYTES 32*4*4


#if DEBUG

#define CCMTL_DEBUG_INSERT_EVENT_MARKER(__encoder__, __message__) 
#define CCMTL_DEBUG_PUSH_GROUP_MARKER(__encoder__, __message__) [__encoder__ pushDebugGroup:__message__]
#define CCMTL_DEBUG_POP_GROUP_MARKER(__encoder__) [__encoder__ popDebugGroup]

#else

#define CCMTL_DEBUG_INSERT_EVENT_MARKER(__encoder__, __message__) 
#define CCMTL_DEBUG_PUSH_GROUP_MARKER(__encoder__, __message__)
#define CCMTL_DEBUG_POP_GROUP_MARKER(__encoder__)

#endif


@interface CCMetalContext : NSObject {
	@public
	id<MTLRenderCommandEncoder> _currentRenderCommandEncoder;
}

@property(nonatomic, readonly) id<MTLDevice> device;
@property(nonatomic, readonly) id<MTLLibrary> library;

@property(nonatomic, readonly) id<MTLCommandQueue> commandQueue;
@property(nonatomic, readonly) id<MTLCommandBuffer> currentCommandBuffer;

@property(nonatomic, strong) id<MTLTexture> destinationTexture;
@property(nonatomic, readonly) id<MTLRenderCommandEncoder> currentRenderCommandEncoder;

+(instancetype)currentContext;
+(void)setCurrentContext:(CCMetalContext *)context;

-(void)prepareCommandBuffer;
-(void)commitCurrentCommandBuffer;

@end


@interface CCGraphicsBufferMetal : CCGraphicsBuffer {
	@public
	id<MTLBuffer> _buffer;
}

@end


@interface CCRenderCommandDrawMetal : CCRenderCommandDraw
@end


#endif
