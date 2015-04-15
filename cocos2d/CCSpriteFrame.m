/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
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


#import "ccTypes.h"
#import "ccUtils.h"

#import "CCSpriteFrame.h"

#import "CCTextureCache.h"
#import "CCSpriteFrameCache_Private.h"
#import "CCTexture_Private.h"

@implementation CCSpriteFrame {
	BOOL _rotated;
	CCTexture *_texture;
	NSString *_textureFilename;
	CCProxy __weak *_proxy;
	__weak CCTexture *_lazyTexture;
}

+(instancetype) frameWithImageNamed:(NSString*)imageName
{
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName];
}

-(instancetype)initWithTexture:(CCTexture*)texture rect:(CGRect)rect rotated:(BOOL)rotated trimOffset:(CGPoint)trimOffset untrimmedSize:(CGSize)untrimmedSize;
{
	if( (self=[super init]) )
    {
		self.texture = texture;
		_rect = rect;
		_trimOffset = trimOffset;
		_untrimmedSize = untrimmedSize;
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
            _trimOffset.x,
            _trimOffset.y
			];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);
}

-(id) copyWithZone: (NSZone*) zone
{
	CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithTexture:_texture rect:_rect rotated:_rotated trimOffset:_trimOffset untrimmedSize:_untrimmedSize];
    copy->_textureFilename = _textureFilename;
    
	return copy;
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

// This is a private setter used by the cache.
-(void)setTextureFilename:(NSString *)textureFilename
{
    _textureFilename = [textureFilename copy];
    
    // Make sure any previously loaded texture is cleared.
    _texture = nil;
    _lazyTexture = nil;
}

- (BOOL)hasProxy
{
	@synchronized(self){
		// NSLog(@"hasProxy: %p", self);
		return(_proxy != nil);
	}
}

- (CCProxy *)proxy
{
	@synchronized(self){
		__strong CCProxy *proxy = _proxy;

		if (_proxy == nil){
			proxy = [[CCProxy alloc] initWithTarget:self];
			_proxy = proxy;
		}

		return(proxy);
	}
}

+(void)purgeCache
{
    // TODO not thread safe.
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
}

@end
