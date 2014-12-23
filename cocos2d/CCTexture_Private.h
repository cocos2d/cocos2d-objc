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

#import "CCTexture.h"

#if __CC_METAL_SUPPORTED_AND_ENABLED
#import <Metal/Metal.h>
#endif


// -------------------------------------------------------------

// Proxy object returned in place of a CCTexture or CCSpriteFrame by the texture cache.
// Weakly retained by the original object, so it can be know if the object is referenced when a memory warning arrives.
// This is used as a temporary fix for the texture cache until asset loading can be refactored better.
@interface CCProxy : NSObject

- (id)initWithTarget:(id)target;

@end

// -------------------------------------------------------------

@interface CCTexture ()

// Fill in any missing fields of an options dictionary.
+(NSDictionary *)normalizeOptions:(NSDictionary *)options;

/* texture name */
@property(nonatomic,readonly) GLuint name;

// TODO This should really be split into a separate subclass somehow.
#if __CC_METAL_SUPPORTED_AND_ENABLED
@property(nonatomic,readonly) id<MTLTexture> metalTexture;
@property(nonatomic,readonly) id<MTLSamplerState> metalSampler;
#endif



@property(nonatomic,readwrite) BOOL premultipliedAlpha;

// Check if the texture's weakly retained proxy still exists.
@property(atomic, readonly) BOOL hasProxy;

// Retrieve the proxy for this texture.
@property(atomic, readonly, weak) CCProxy *proxy;

// Create the native texture object.
-(void)setupTexture:(CCTextureType)type sizeInPixels:(CGSize)sizeInPixels options:(NSDictionary *)options;

@end
