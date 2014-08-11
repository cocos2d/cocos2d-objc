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

#import "CCMetalSupport_Private.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED

#import <Metal/Metal.h>


@implementation CCGraphicsBufferMetal {
	id<MTLBuffer> _buffer;
}

-(instancetype)initWithCapacity:(NSUInteger)capacity elementSize:(size_t)elementSize type:(CCGraphicsBufferType)type;
{
	if((self = [super init])){
		#warning TODO
		id<MTLDevice> device = nil;
		
		// Use write combining? Buffers are already write only for the GL renderer.
		_buffer = [device newBufferWithLength:capacity*elementSize options:MTLResourceOptionCPUCacheModeDefault];
		
		_ptr = _buffer.contents;
	}
	
	return self;
}

-(void)destroy {}

-(void)resize:(size_t)newCapacity;
{
	#warning TODO
}

-(void)prepare;
{
	_count = 0;
}

-(void)commit; {}

@end

#else

// Temporary
#warning Metal disabled

#endif
