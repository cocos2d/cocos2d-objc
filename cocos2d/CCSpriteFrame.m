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
@synthesize offsetInPixels = offsetInPixels_, offset = offset_;
@synthesize originalSize = originalSize_, originalSizeInPixels = originalSizeInPixels_;
@synthesize textureFilename = textureFilename_;
@synthesize rotated = rotated_;

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
		rectInPixels_ = rect;
		rect_ = CC_RECT_PIXELS_TO_POINTS( rect );
		offsetInPixels_ = offset;
        offset_ = CC_POINT_PIXELS_TO_POINTS( offsetInPixels_ );
		originalSizeInPixels_ = originalSize;
		originalSize_ = CC_SIZE_PIXELS_TO_POINTS( originalSizeInPixels_ );
        rotated_ = rotated;
	}
	return self;
}

-(id) initWithTextureFilename:(NSString *)filename rectInPixels:(CGRect)rect rotated:(BOOL)rotated offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	if( (self=[super init]) )
    {
		texture_ = nil;
		textureFilename_ = [filename copy];
		rectInPixels_ = rect;
		rect_ = CC_RECT_PIXELS_TO_POINTS( rect );
		offsetInPixels_ = offset;
        offset_ = CC_POINT_PIXELS_TO_POINTS( offsetInPixels_ );
		originalSizeInPixels_ = originalSize;
		originalSize_ = CC_SIZE_PIXELS_TO_POINTS( originalSizeInPixels_ );
        rotated_ = rotated;
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Texture=%@, Rect = (%.2f,%.2f,%.2f,%.2f)> rotated:%d offset=(%.2f,%.2f)", [self class], self,
			textureFilename_,
			rect_.origin.x,
			rect_.origin.y,
			rect_.size.width,
			rect_.size.height,
			rotated_,
            offsetInPixels_.x,
            offsetInPixels_.y
			];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);
	[texture_ release];
	[textureFilename_ release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithTextureFilename:textureFilename_ rectInPixels:rectInPixels_ rotated:rotated_ offset:offsetInPixels_ originalSize:originalSizeInPixels_];
	copy.texture = texture_;
	return copy;
}

-(CGRect) rect
{
	return rect_;
}

-(CGRect) rectInPixels
{
	return rectInPixels_;
}

-(void) setRect:(CGRect)rect
{
	rect_ = rect;
	rectInPixels_ = CC_RECT_POINTS_TO_PIXELS( rect_ );
}

-(void) setRectInPixels:(CGRect)rectInPixels
{
	rectInPixels_ = rectInPixels;
	rect_ = CC_RECT_PIXELS_TO_POINTS( rectInPixels_ );
}

-(void) setOffset:(CGPoint)offsets
{
    offset_ = offsets;
    offsetInPixels_ = CC_POINT_POINTS_TO_PIXELS( offset_ );
}

-(void) setOffsetInPixels:(CGPoint)offsetInPixels
{
    offsetInPixels_ = offsetInPixels;
    offset_ = CC_POINT_PIXELS_TO_POINTS( offsetInPixels_ );
}

-(void) setTexture:(CCTexture2D *)texture
{
	if( texture_ != texture ) {
		[texture_ release];
		texture_ = [texture retain];
	}
}

-(CCTexture2D*) texture
{
	if( texture_ )
		return texture_;

	if( textureFilename_ )
		return [[CCTextureCache sharedTextureCache] addImage:textureFilename_];

	// no texture or texture filename
	return nil;
}
@end
