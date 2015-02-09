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
 */


#import "CCDeprecated.h"

#import "ccUtils.h"
#import "CCImage.h"
#import "CCDeviceInfo.h"
#import "CCRenderDispatch.h"

#import "CCMetalSupport_Private.h"
#import "CCTexture_Private.h"
#import "CCNode_Private.h"
#import "CCScheduler_Private.h"


@implementation CCDirector(Deprecated)

+(CCDirector *)sharedDirector
{
    return [CCDirector currentDirector];
}

@end


@implementation CCColor(Deprecated)

+ (CCColor*) colorWithCcColor3b:(ccColor3B)c
{
    return [[CCColor alloc] initWithCcColor3b:c];
}

+ (CCColor*) colorWithCcColor4b:(ccColor4B)c
{
    return [[CCColor alloc] initWithCcColor4b:c];
}

+ (CCColor*) colorWithCcColor4f:(ccColor4F)c
{
    return [[CCColor alloc] initWithCcColor4f:c];
}

- (CCColor*) initWithCcColor3b: (ccColor3B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:1];
}

- (CCColor*) initWithCcColor4b: (ccColor4B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:c.a/255.0];
}

- (CCColor*) initWithCcColor4f: (ccColor4F) c
{
    return [self initWithRed:c.r green:c.g blue:c.b alpha:c.a];
}

- (ccColor3B) ccColor3b
{
    GLKVector4 vec4 = self.glkVector4;
    return (ccColor3B){(uint8_t)(vec4.r*255), (uint8_t)(vec4.g*255), (uint8_t)(vec4.b*255)};
}

- (ccColor4B) ccColor4b
{
    GLKVector4 vec4 = self.glkVector4;
    return (ccColor4B){(uint8_t)(vec4.r*255), (uint8_t)(vec4.g*255), (uint8_t)(vec4.b*255), (uint8_t)(vec4.a*255)};
}

- (ccColor4F) ccColor4f
{
    GLKVector4 vec4 = self.glkVector4;
    return ccc4f(vec4.r, vec4.g, vec4.b, vec4.a);
}

@end


@implementation CCNode(Deprecated)

static CGAffineTransform
CGAffineTransformFromGLKMatrix4(GLKMatrix4 m)
{
    return CGAffineTransformMake(m.m[0], m.m[1], m.m[4], m.m[5], m.m[12], m.m[13]);
}

- (CGAffineTransform)nodeToParentTransform;
{
    return CGAffineTransformFromGLKMatrix4(self.nodeToParentMatrix);
}

- (CGAffineTransform)parentToNodeTransform;
{
    return CGAffineTransformFromGLKMatrix4(self.parentToNodeMatrix);
}

- (CGAffineTransform)nodeToWorldTransform;
{
    return CGAffineTransformFromGLKMatrix4(self.nodeToWorldMatrix);
}

- (CGAffineTransform)worldToNodeTransform;
{
    return CGAffineTransformFromGLKMatrix4(self.worldToNodeMatrix);
}

-(BOOL)isRunningInActiveScene
{
    return self.active;
}

-(NSUInteger) numberOfRunningActions
{
    return self.actions.count;
}

-(void)stopActionByTag:(NSInteger)tag
{
	NSAssert(tag != kCCActionTagInvalid, @"Invalid tag");
	[self.scheduler removeActionByName:[NSString stringWithFormat:@"%d", tag] target:self];
}

-(CCAction *)getActionByTag:(NSInteger)tag
{
	NSAssert(tag != kCCActionTagInvalid, @"Invalid tag");
	return 	[self.scheduler getActionByName:[NSString stringWithFormat:@"%d", tag] target:self];
}

@end


@implementation CCTexture(Deprecated)

-(CCSpriteFrame *)createSpriteFrame {return self.spriteFrame;}
-(NSUInteger)pixelWidth {return self.sizeInPixels.width;}
-(NSUInteger)pixelHeight {return self.sizeInPixels.height;}
-(CGSize)contentSizeInPixels {return CC_SIZE_SCALE(self.contentSize, self.contentScale);}

- (id)initWithCGImage:(CGImageRef)cgImage contentScale:(CGFloat)contentScale;
{
    CCImage *image = [[CCImage alloc] initWithCGImage:cgImage contentScale:contentScale options:nil];
    return [self initWithImage:image options:nil];
}

-(BOOL)isAntialiased
{
    return _antialiased;
}

- (void) setAntialiased:(BOOL)antialiased
{
	if(_antialiased != antialiased){
		CCRenderDispatch(NO, ^{
#if __CC_METAL_SUPPORTED_AND_ENABLED
			if([CCDeviceInfo sharedDeviceInfo].graphicsAPI == CCGraphicsAPIMetal){
				CCMetalContext *context = [CCMetalContext currentContext];
				
				MTLSamplerDescriptor *samplerDesc = [MTLSamplerDescriptor new];
				samplerDesc.minFilter = samplerDesc.magFilter = (antialiased ? MTLSamplerMinMagFilterLinear : MTLSamplerMinMagFilterNearest);
				samplerDesc.mipFilter = (_hasMipmaps ? MTLSamplerMipFilterNearest : MTLSamplerMipFilterNotMipmapped);
				samplerDesc.sAddressMode = MTLSamplerAddressModeClampToEdge;
				samplerDesc.tAddressMode = MTLSamplerAddressModeClampToEdge;
				
				((CCTextureMetal *)self)->_metalSampler = [context.device newSamplerStateWithDescriptor:samplerDesc];
			} else
#endif
			{
				CCGL_DEBUG_PUSH_GROUP_MARKER("CCTexture: Set Alias Texture Parameters");
				
				glBindTexture(GL_TEXTURE_2D, [(CCTextureGL *)self name]);
				
				if(_hasMipmaps){
					glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, antialiased ? GL_NEAREST_MIPMAP_NEAREST : GL_NEAREST_MIPMAP_NEAREST);
				} else {
					glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, antialiased ? GL_LINEAR : GL_NEAREST);
				}
				glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, antialiased ? GL_LINEAR : GL_NEAREST);
				
				CCGL_DEBUG_POP_GROUP_MARKER();
				CC_CHECK_GL_ERROR_DEBUG();
			}
		});
		
		_antialiased = antialiased;
	}
}

-(BOOL)hasPremultipliedAlpha
{
    return _premultipliedAlpha;
}

@end
