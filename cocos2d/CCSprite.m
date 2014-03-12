/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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

#import "ccConfig.h"
#import "CCSpriteBatchNode.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCSpriteFrameCache.h"
#import "CCAnimation.h"
#import "CCAnimationCache.h"
#import "CCTextureCache.h"
#import "CCShader.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "Support/CCProfiling.h"
#import "Support/OpenGL_Internal.h"
#import "CCNode_Private.h"
#import "CCRenderer_private.h"
#import "CCSprite_Private.h"
#import "CCTexture_Private.h"

#pragma mark -
#pragma mark CCSprite

//#if CC_SPRITEBATCHNODE_RENDER_SUBPIXEL
//#define RENDER_IN_SUBPIXEL
//#else
//#define RENDER_IN_SUBPIXEL(__ARGS__) (ceil(__ARGS__))
//#endif


@implementation CCSprite {
	// Offset Position, used by sprite sheet editors.
	CGPoint _unflippedOffsetPositionFromCenter;

	// Vertex coords, texture coords and color info.
	CCVertex _verts[4];
	
	BOOL _opacityModifyRGB;
	BOOL _flipX, _flipY;
}

+(id)spriteWithImageNamed:(NSString*)imageName
{
    return [[self alloc] initWithImageNamed:imageName];
}

+(id)spriteWithTexture:(CCTexture*)texture
{
	return [[self alloc] initWithTexture:texture];
}

+(id)spriteWithTexture:(CCTexture*)texture rect:(CGRect)rect
{
	return [[self alloc] initWithTexture:texture rect:rect];
}

+(id)spriteWithFile:(NSString*)filename
{
	return [[self alloc] initWithFile:filename];
}

+(id)spriteWithFile:(NSString*)filename rect:(CGRect)rect
{
	return [[self alloc] initWithFile:filename rect:rect];
}

+(id)spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
	return [[self alloc] initWithSpriteFrame:spriteFrame];
}

+(id)spriteWithSpriteFrameName:(NSString*)spriteFrameName
{
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];

	NSAssert1(frame!=nil, @"Invalid spriteFrameName: %@", spriteFrameName);
	return [self spriteWithSpriteFrame:frame];
}

+(id)spriteWithCGImage:(CGImageRef)image key:(NSString*)key
{
	return [[self alloc] initWithCGImage:image key:key];
}

+(id) emptySprite
{
    return [[self alloc] init];
}

-(id) init
{
	return [self initWithTexture:nil rect:CGRectZero];
}

// designated initializer
-(id) initWithTexture:(CCTexture*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	if( (self = [super init]) )
	{
		// shader program
		self.shader = [CCShader positionTextureColorShader];
		
		self.blendMode = [CCBlendMode premultipliedAlphaMode];
		_opacityModifyRGB = YES;
		
		_flipY = _flipX = NO;

		// default transform anchor: center
		_anchorPoint =  ccp(0.5f, 0.5f);

		// zwoptex default values
		_offsetPosition = CGPointZero;
		
		#warning Seems like this isn't needed?
		GLKVector4 tmpColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
		_verts[0].color = tmpColor;
		_verts[1].color = tmpColor;
		_verts[2].color = tmpColor;
		_verts[3].color = tmpColor;
		
		[self setTexture:texture];
		[self setTextureRect:rect rotated:rotated untrimmedSize:rect.size];
	}
	return self;
}

- (id) initWithImageNamed:(NSString*)imageName
{
    return [self initWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:imageName]];
}

-(id) initWithTexture:(CCTexture*)texture rect:(CGRect)rect
{
	return [self initWithTexture:texture rect:rect rotated:NO];
}

-(id) initWithTexture:(CCTexture*)texture
{
	NSAssert(texture!=nil, @"Invalid texture for sprite");

	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	return [self initWithTexture:texture rect:rect];
}

-(id) initWithFile:(NSString*)filename
{
	NSAssert(filename != nil, @"Invalid filename for sprite");

	CCTexture *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
	if( texture ) {
		CGRect rect = CGRectZero;
		rect.size = texture.contentSize;
		return [self initWithTexture:texture rect:rect];
	}

	return nil;
}

-(id) initWithFile:(NSString*)filename rect:(CGRect)rect
{
	NSAssert(filename!=nil, @"Invalid filename for sprite");

	CCTexture *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
	if( texture )
		return [self initWithTexture:texture rect:rect];

	return nil;
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
	NSAssert(spriteFrame!=nil, @"Invalid spriteFrame for sprite");

	id ret = [self initWithTexture:spriteFrame.texture rect:spriteFrame.rect];
    self.spriteFrame = spriteFrame;
	return ret;
}

-(id)initWithSpriteFrameName:(NSString*)spriteFrameName
{
	NSAssert(spriteFrameName!=nil, @"Invalid spriteFrameName for sprite");

	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
	return [self initWithSpriteFrame:frame];
}

- (id) initWithCGImage:(CGImageRef)image key:(NSString*)key
{
	NSAssert(image!=nil, @"Invalid CGImageRef for sprite");

	// XXX: possible bug. See issue #349. New API should be added
	CCTexture *texture = [[CCTextureCache sharedTextureCache] addCGImage:image forKey:key];

	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;

	return [self initWithTexture:texture rect:rect];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Rect = (%.2f,%.2f,%.2f,%.2f) | tag = %@ >",
		[self class], self, _textureRect.origin.x, _textureRect.origin.y, _textureRect.size.width, _textureRect.size.height, _name
	];
}

-(void) setTextureRect:(CGRect)rect
{
	[self setTextureRect:rect rotated:NO untrimmedSize:rect.size];
}

-(void) setTextureRect:(CGRect)rect rotated:(BOOL)rotated untrimmedSize:(CGSize)untrimmedSize
{
	_textureRectRotated = rotated;

    self.contentSizeType = CCSizeTypePoints;
	[self setContentSize:untrimmedSize];
	_textureRect = rect;
	[self setTextureCoords:rect];

	CGPoint relativeOffset = _unflippedOffsetPositionFromCenter;

	// issue #732
	if( _flipX )
		relativeOffset.x = -relativeOffset.x;
	if( _flipY )
		relativeOffset.y = -relativeOffset.y;


	_offsetPosition.x = relativeOffset.x + (_contentSize.width - _textureRect.size.width) / 2;
	_offsetPosition.y = relativeOffset.y + (_contentSize.height - _textureRect.size.height) / 2;


	// Atlas: Vertex
	float x1 = _offsetPosition.x;
	float y1 = _offsetPosition.y;
	float x2 = x1 + _textureRect.size.width;
	float y2 = y1 + _textureRect.size.height;

	// Don't update Z.
	_verts[0].position = GLKVector4Make(x1, y1, 0.0f, 1.0f);
	_verts[1].position = GLKVector4Make(x2, y1, 0.0f, 1.0f);
	_verts[2].position = GLKVector4Make(x2, y2, 0.0f, 1.0f);
	_verts[3].position = GLKVector4Make(x1, y2, 0.0f, 1.0f);
}

-(void) setTextureCoords:(CGRect)rect
{
	if(!self.texture) return;
	
	CGFloat scale = self.texture.contentScale;
	rect = CC_RECT_SCALE(rect, scale);
	
	float atlasWidth = (float)self.texture.pixelWidth;
	float atlasHeight = (float)self.texture.pixelHeight;

	float left, right, top, bottom;
	
	#warning TODO Seems like this could be significantly simplified.
	if(_textureRectRotated)
    {
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		left	= (2*rect.origin.x+1)/(2*atlasWidth);
		right	= left+(rect.size.height*2-2)/(2*atlasWidth);
		top		= (2*rect.origin.y+1)/(2*atlasHeight);
		bottom	= top+(rect.size.width*2-2)/(2*atlasHeight);
#else
		left	= rect.origin.x/atlasWidth;
		right	= (rect.origin.x+rect.size.height) / atlasWidth;
		top		= rect.origin.y/atlasHeight;
		bottom	= (rect.origin.y+rect.size.width) / atlasHeight;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL

		if( _flipX)
			CC_SWAP(top,bottom);
		if( _flipY)
			CC_SWAP(left,right);
		
		_verts[0].texCoord1 = GLKVector2Make( left,    top);
		_verts[1].texCoord1 = GLKVector2Make( left, bottom);
		_verts[2].texCoord1 = GLKVector2Make(right, bottom);
		_verts[3].texCoord1 = GLKVector2Make(right,    top);
	} else {
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		left	= (2*rect.origin.x+1)/(2*atlasWidth);
		right	= left + (rect.size.width*2-2)/(2*atlasWidth);
		top		= (2*rect.origin.y+1)/(2*atlasHeight);
		bottom	= top + (rect.size.height*2-2)/(2*atlasHeight);
#else
		left	= rect.origin.x/atlasWidth;
		right	= (rect.origin.x + rect.size.width) / atlasWidth;
		top		= rect.origin.y/atlasHeight;
		bottom	= (rect.origin.y + rect.size.height) / atlasHeight;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL

		if( _flipX)
			CC_SWAP(left,right);
		if( _flipY)
			CC_SWAP(top,bottom);

		_verts[0].texCoord1 = GLKVector2Make( left, bottom);
		_verts[1].texCoord1 = GLKVector2Make(right, bottom);
		_verts[2].texCoord1 = GLKVector2Make(right,    top);
		_verts[3].texCoord1 = GLKVector2Make( left,    top);
	}
}

-(CCVertex *)verts
{
	return _verts;
}

#pragma mark CCSprite - draw

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;
{
	if(!CCCheckVisbility(transform, _contentSize)) return;
	
	CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:self.renderState];
	CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(_verts[0], transform));
	CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(_verts[1], transform));
	CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(_verts[2], transform));
	CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(_verts[3], transform));
	
	CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
	CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
	
#if CC_SPRITE_DEBUG_DRAW
	const GLKVector2 zero = {{0, 0}};
	const GLKVector4 red = {{1, 0, 0, 1}};
	
	CCRenderBuffer debug = [renderer enqueueLines:4 andVertexes:4 withState:[CCRenderState debugColor]];
	CCRenderBufferSetVertex(debug, 0, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts[0].position), zero, zero, red});
	CCRenderBufferSetVertex(debug, 1, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts[1].position), zero, zero, red});
	CCRenderBufferSetVertex(debug, 2, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts[2].position), zero, zero, red});
	CCRenderBufferSetVertex(debug, 3, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts[3].position), zero, zero, red});
	
	CCRenderBufferSetLine(debug, 0, 0, 1);
	CCRenderBufferSetLine(debug, 1, 1, 2);
	CCRenderBufferSetLine(debug, 2, 2, 3);
	CCRenderBufferSetLine(debug, 3, 3, 0);
#endif
}

#pragma mark CCSprite - CCNode overrides

//
// CCNode property overloads
// used only when parent is CCSpriteBatchNode
//
#pragma mark CCSprite - property overloads

-(void)setFlipX:(BOOL)b
{
	if( _flipX != b ) {
		_flipX = b;
		[self setTextureRect:_textureRect rotated:_textureRectRotated untrimmedSize:_contentSize];
	}
}
-(BOOL) flipX
{
	return _flipX;
}

-(void) setFlipY:(BOOL)b
{
	if( _flipY != b ) {
		_flipY = b;
		[self setTextureRect:_textureRect rotated:_textureRectRotated untrimmedSize:_contentSize];
	}
}
-(BOOL) flipY
{
	return _flipY;
}

//
// RGBA protocol
//
#pragma mark CCSprite - RGBA protocol
-(void) updateColor
{
	GLKVector4 color4 = GLKVector4Make(_displayColor.r, _displayColor.g, _displayColor.b, _displayColor.a);
	
	// special opacity for premultiplied textures
	if ( _opacityModifyRGB ) {
		color4.r *= _displayColor.a;
		color4.g *= _displayColor.a;
		color4.b *= _displayColor.a;
	}
	
	_verts[0].color = color4;
	_verts[1].color = color4;
	_verts[2].color = color4;
	_verts[3].color = color4;
}

-(void) setColor:(CCColor*)color
{
	[super setColor:color];
	[self updateColor];
}

- (void) setColorRGBA:(CCColor*)color
{
	[super setColorRGBA:color];
	[self updateColor];
}

-(void)updateDisplayedColor:(ccColor4F) parentColor
{
	[super updateDisplayedColor:parentColor];
	[self updateColor];
}

-(void) setOpacity:(CGFloat)opacity
{
	[super setOpacity:opacity];
	[self updateColor];
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	if( _opacityModifyRGB != modify ) {
		_opacityModifyRGB = modify;
		[self updateColor];
	}
}

-(BOOL) doesOpacityModifyRGB
{
	return _opacityModifyRGB;
}

-(void)updateDisplayedOpacity:(CGFloat)parentOpacity
{
    [super updateDisplayedOpacity:parentOpacity];
    [self updateColor];
}


//
// Frames
//
#pragma mark CCSprite - Frames

-(void) setSpriteFrame:(CCSpriteFrame*)frame
{
	_unflippedOffsetPositionFromCenter = frame.offset;

	CCTexture *newTexture = [frame texture];
	// update texture before updating texture rect
	if(newTexture != self.texture){
		[self setTexture: newTexture];
	}

	// update rect
	_textureRectRotated = frame.rotated;

	[self setTextureRect:frame.rect rotated:_textureRectRotated untrimmedSize:frame.originalSize];
    
    _spriteFrame = frame;
}

//-(void) setSpriteFrameWithAnimationName: (NSString*) animationName index:(int) frameIndex
//{
//	NSAssert( animationName, @"CCSprite#setSpriteFrameWithAnimationName. animationName must not be nil");
//	
//	CCAnimation *a = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
//	NSAssert( a, @"CCSprite#setSpriteFrameWithAnimationName: Frame not found");
//	
//	CCAnimationFrame *frame = [[a frames] objectAtIndex:frameIndex];
//	NSAssert( frame, @"CCSprite#setSpriteFrame. Invalid frame");
//	
//	self.spriteFrame = frame.spriteFrame;
//}

#pragma mark CCSprite - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	// it is possible to have an untextured sprite
	if(!self.texture || ![self.texture hasPremultipliedAlpha]){
		self.blendMode = [CCBlendMode alphaMode];
		[self setOpacityModifyRGB:NO];
	} else {
		self.blendMode = [CCBlendMode premultipliedAlphaMode];
		[self setOpacityModifyRGB:YES];
	}
}

-(void) setTexture:(CCTexture*)texture
{
	super.texture = texture;
	[self updateBlendFunc];
}

@end
