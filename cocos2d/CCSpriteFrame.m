/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
#import "ccMacros.h"

@implementation CCSpriteFrame
@synthesize offsetInPixels = _offsetInPixels, offset = _offset;
@synthesize originalSize = _originalSize, originalSizeInPixels = _originalSizeInPixels;
@synthesize textureFilename = _textureFilename;
@synthesize rotated = _rotated;

+(id) frameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	return [[[self alloc] initWithTexture:texture rect:rect] autorelease];
}

+(id) frameWithTextureFilename:(NSString*)filename rect:(CGRect)rect
{
	return [[[self alloc] initWithTextureFilename:filename rect:rect] autorelease];
}

+(id) frameWithTexture:(CCTexture2D*)texture rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	return [[[self alloc] initWithTexture:texture rectInPixels:rect rotated:rotated offset:offset originalSize:originalSize] autorelease];
}

+(id) frameWithTextureFilename:(NSString*)filename rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	return [[[self alloc] initWithTextureFilename:filename rectInPixels:rect rotated:rotated offset:offset originalSize:originalSize] autorelease];
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	CGRect rectInPixels = CC_RECT_POINTS_TO_PIXELS( rect );
	return [self initWithTexture:texture rectInPixels:rectInPixels rotated:NO offset:CGPointZero originalSize:rectInPixels.size];
}

-(id) initWithTextureFilename:(NSString*)filename rect:(CGRect)rect
{
	CGRect rectInPixels = CC_RECT_POINTS_TO_PIXELS( rect );
	return [self initWithTextureFilename:filename rectInPixels:rectInPixels rotated:NO offset:CGPointZero originalSize:rectInPixels.size];
}

-(id) initWithTexture:(CCTexture2D*)texture rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	if( (self=[super init]) )
    {
		self.texture = texture;
		_rectInPixels = rect;
		_rect = CC_RECT_PIXELS_TO_POINTS( rect );
		_offsetInPixels = offset;
        _offset = CC_POINT_PIXELS_TO_POINTS( _offsetInPixels );
		_originalSizeInPixels = originalSize;
		_originalSize = CC_SIZE_PIXELS_TO_POINTS( _originalSizeInPixels );
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
		_rect = CC_RECT_PIXELS_TO_POINTS( rect );
		_offsetInPixels = offset;
        _offset = CC_POINT_PIXELS_TO_POINTS( _offsetInPixels );
		_originalSizeInPixels = originalSize;
		_originalSize = CC_SIZE_PIXELS_TO_POINTS( _originalSizeInPixels );
        _rotated = rotated;
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Texture=%@, Rect = (%.2f,%.2f,%.2f,%.2f)> rotated:%d offset=(%.2f,%.2f)", [self class], self,
			_textureFilename,
			_rect.origin.x,
			_rect.origin.y,
			_rect.size.width,
			_rect.size.height,
			_rotated,
            _offsetInPixels.x,
            _offsetInPixels.y
			];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);
	[_texture release];
	[_textureFilename release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithTextureFilename:_textureFilename rectInPixels:_rectInPixels rotated:_rotated offset:_offsetInPixels originalSize:_originalSizeInPixels];
	copy.texture = _texture;
	return copy;
}

-(CGRect) rect
{
	return _rect;
}

-(CGRect) rectInPixels
{
	return _rectInPixels;
}

-(void) setRect:(CGRect)rect
{
	_rect = rect;
	_rectInPixels = CC_RECT_POINTS_TO_PIXELS(_rect);
}

-(void) setRectInPixels:(CGRect)rectInPixels
{
	_rectInPixels = rectInPixels;
	_rect = CC_RECT_PIXELS_TO_POINTS( _rectInPixels );
}

-(void) setOffset:(CGPoint)offsets
{
    _offset = offsets;
    _offsetInPixels = CC_POINT_POINTS_TO_PIXELS( _offset );
}

-(void) setOffsetInPixels:(CGPoint)offsetInPixels
{
    _offsetInPixels = offsetInPixels;
    _offset = CC_POINT_PIXELS_TO_POINTS( _offsetInPixels );
}

-(void) setTexture:(CCTexture2D *)texture
{
	if( _texture != texture ) {
		[_texture release];
		_texture = [texture retain];
	}
}

-(CCTexture2D*) texture
{
	if( _texture )
		return _texture;

	if( _textureFilename )
		return [[CCTextureCache sharedTextureCache] addImage:_textureFilename];

	// no texture or texture filename
	return nil;
}
@end
