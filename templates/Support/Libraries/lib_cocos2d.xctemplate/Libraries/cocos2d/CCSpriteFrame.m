/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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


#import "CCTextureCache.h"
#import "CCSpriteFrame.h"
#import "CCTexture.h"
#import "ccMacros.h"
#import "CCSpriteFrameCache.h"

@implementation CCSpriteFrame
{
	__weak CCTexture *_lazyTexture;
}

@synthesize textureFilename = _textureFilename;
@synthesize rotated = _rotated;

@dynamic rect;

+(id) frameWithImageNamed:(NSString*)imageName
{
    CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
    if (!frame)
    {
        CCTexture* texture = [[CCTextureCache sharedTextureCache] addImage:imageName];
        frame = [texture createSpriteFrame];
    }
    
    return frame;
}

+(id) frameWithTexture:(CCTexture*)texture rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	return [[self alloc] initWithTexture:texture rectInPixels:rect rotated:rotated offset:offset originalSize:originalSize];
}

+(id) frameWithTextureFilename:(NSString*)filename rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	return [[self alloc] initWithTextureFilename:filename rectInPixels:rect rotated:rotated offset:offset originalSize:originalSize];
}


-(id) initWithTexture:(CCTexture*)texture rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	if( (self=[super init]) )
    {
		self.texture = texture;
		_rectInPixels = rect;
		_offsetInPixels = offset;
		_originalSizeInPixels = originalSize;
        _rotated = rotated;
	}
	return self;
}

-(id) initWithTextureFilename:(NSString *)filename rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	if( (self=[super init]) )
    {
		_texture = nil;
		_textureFilename = [filename copy];
		_rectInPixels = rect;
		_offsetInPixels = offset;
		_originalSizeInPixels = originalSize;
        _rotated = rotated;
	}
	return self;
}

- (NSString*) description
{
	CGRect rect = self.rect;
	return [NSString stringWithFormat:@"<%@ = %p | Texture=%@, Rect = (%.2f,%.2f,%.2f,%.2f)> rotated:%d offset=(%.2f,%.2f)", [self class], self,
			_textureFilename,
			rect.origin.x,
			rect.origin.y,
			rect.size.width,
			rect.size.height,
			_rotated,
            _offsetInPixels.x,
            _offsetInPixels.y
			];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);
}

-(id) copyWithZone: (NSZone*) zone
{
	CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithTextureFilename:_textureFilename rectInPixels:_rectInPixels rotated:_rotated offset:_offsetInPixels originalSize:_originalSizeInPixels];
	copy.texture = _texture;
	return copy;
}

-(CGRect) rect
{
	return CC_RECT_SCALE(_rectInPixels, 1.0/self.texture.contentScale);
}

-(CGPoint)offset
{
	return ccpMult(_offsetInPixels, 1.0/self.texture.contentScale);
}

-(CGSize)originalSize
{
	return CC_SIZE_SCALE(_originalSizeInPixels, 1.0/self.texture.contentScale);
}

-(void) setTexture:(CCTexture *)texture
{
	if( _texture != texture ) {
		_texture = texture;
	}
}

-(CCTexture *)lazyTexture
{
	CCTexture *texture = _lazyTexture;
	if(!texture && _textureFilename){
		_lazyTexture = texture = [[CCTextureCache sharedTextureCache] addImage:_textureFilename];
	}
	
	return texture;
}

-(CCTexture*) texture
{
	return (_texture ?: self.lazyTexture);
}
@end
