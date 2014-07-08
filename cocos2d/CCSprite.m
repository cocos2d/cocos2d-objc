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
#import "CCNode_Private.h"
#import "CCRenderer_private.h"
#import "CCSprite_Private.h"
#import "CCTexture_Private.h"
#import "CCEffect.h"
#import "CCEffectRenderer.h"
#import "CCEffectStack.h"

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
	
	// Center of extents (half width/height) of the sprite for culling purposes.
	GLKVector2 _vertexCenter, _vertexExtents;

	// Vertex coords, texture coords and color info.
	CCSpriteVertexes _verts;
	
	BOOL _flipX, _flipY;
    
    CCEffect *_effect;
#if CC_ENABLE_EXPERIMENTAL_EFFECTS
    CCEffectRenderer *_effectRenderer;
#endif
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
	if((self = [super init])){
		self.blendMode = [CCBlendMode premultipliedAlphaMode];
		self.shader = [CCShader positionTextureColorShader];
		
		_flipY = _flipX = NO;

		// default transform anchor: center
		_anchorPoint =  ccp(0.5f, 0.5f);

		// zwoptex default values
		_offsetPosition = CGPointZero;
		
		[self updateColor];
		
		[self setTexture:texture];
		[self setTextureRect:rect rotated:rotated untrimmedSize:rect.size];
        
#if CC_ENABLE_EXPERIMENTAL_EFFECTS
        _effectRenderer = [[CCEffectRenderer alloc] init];
#endif
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
    
	CCSpriteTexCoordSet texCoords = [CCSprite textureCoordsForTexture:self.texture withRect:rect rotated:rotated xFlipped:_flipX yFlipped:_flipY];
    _verts.bl.texCoord1 = texCoords.bl;
    _verts.br.texCoord1 = texCoords.br;
    _verts.tr.texCoord1 = texCoords.tr;
    _verts.tl.texCoord1 = texCoords.tl;
    
    
	CGPoint relativeOffset = _unflippedOffsetPositionFromCenter;

	// issue #732
	if(_flipX) relativeOffset.x = -relativeOffset.x;
	if(_flipY) relativeOffset.y = -relativeOffset.y;

	_offsetPosition.x = relativeOffset.x + (_contentSize.width - _textureRect.size.width) / 2;
	_offsetPosition.y = relativeOffset.y + (_contentSize.height - _textureRect.size.height) / 2;

	// Atlas: Vertex
	float x1 = _offsetPosition.x;
	float y1 = _offsetPosition.y;
	float x2 = x1 + _textureRect.size.width;
	float y2 = y1 + _textureRect.size.height;
	
	_verts.bl.position = GLKVector4Make(x1, y1, 0.0f, 1.0f);
	_verts.br.position = GLKVector4Make(x2, y1, 0.0f, 1.0f);
	_verts.tr.position = GLKVector4Make(x2, y2, 0.0f, 1.0f);
	_verts.tl.position = GLKVector4Make(x1, y2, 0.0f, 1.0f);
	
	// Set the center/extents for culling purposes.
	_vertexCenter = GLKVector2Make((x1 + x2)*0.5f, (y1 + y2)*0.5f);
	_vertexExtents = GLKVector2Make((x2 - x1)*0.5f, (y2 - y1)*0.5f);
}

+ (CCSpriteTexCoordSet)textureCoordsForTexture:(CCTexture *)texture withRect:(CGRect)rect rotated:(BOOL)rotated xFlipped:(BOOL)flipX yFlipped:(BOOL)flipY
{
    CCSpriteTexCoordSet result;
	if(!texture) return result;
	
	CGFloat scale = texture.contentScale;
	rect = CC_RECT_SCALE(rect, scale);
	
	float atlasWidth = (float)texture.pixelWidth;
	float atlasHeight = (float)texture.pixelHeight;

	if(rotated){
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		float left   = (2.0f*rect.origin.x + 1.0f)/(2.0f*atlasWidth);
		float right  = left+(rect.size.height*2.0f - 2.0f)/(2.0f*atlasWidth);
		float top    = 1.0f - (2.0f*rect.origin.y + 1.0f)/(2.0f*atlasHeight);
		float bottom = 1.0f - top+(rect.size.width*2.0f - 2.0f)/(2.0f*atlasHeight);
#else
		float left   = rect.origin.x/atlasWidth;
		float right  = (rect.origin.x + rect.size.height)/atlasWidth;
		float top    = 1.0f - rect.origin.y/atlasHeight;
		float bottom = 1.0f - (rect.origin.y + rect.size.width)/atlasHeight;
#endif

		if(flipX) CC_SWAP(top,bottom);
		if(flipY) CC_SWAP(left,right);
		
		result.bl = GLKVector2Make( left,    top);
		result.br = GLKVector2Make( left, bottom);
		result.tr = GLKVector2Make(right, bottom);
		result.tl = GLKVector2Make(right,    top);
	} else {
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		float left   = (2.0f*rect.origin.x + 1.0f)/(2.0f*atlasWidth);
		float right  = left + (rect.size.width*2.0f - 2.0f)/(2.0f*atlasWidth);
		float top    = 1.0f - (2.0f*rect.origin.y + 1.0f)/(2.0f*atlasHeight);
		float bottom = 1.0f - top + (rect.size.height*2.0f - 2.0f)/(2.0f*atlasHeight);
#else
		float left   = rect.origin.x/atlasWidth;
		float right  = (rect.origin.x + rect.size.width)/atlasWidth;
		float top    = 1.0f - rect.origin.y/atlasHeight;
		float bottom = 1.0f - (rect.origin.y + rect.size.height)/atlasHeight;
#endif

		if(flipX) CC_SWAP(left,right);
		if(flipY) CC_SWAP(top,bottom);

		result.bl = GLKVector2Make( left, bottom);
		result.br = GLKVector2Make(right, bottom);
		result.tr = GLKVector2Make(right,    top);
		result.tl = GLKVector2Make( left,    top);
	}
    
    return result;
}

-(const CCSpriteVertexes *)vertexes
{
	return &_verts;
}

- (CGAffineTransform)nodeToTextureTransform
{
    CGFloat sx = (_verts.br.texCoord1.s - _verts.bl.texCoord1.s) / (_verts.br.position.x - _verts.bl.position.x);
    CGFloat sy = (_verts.tl.texCoord1.t - _verts.bl.texCoord1.t) / (_verts.tl.position.y - _verts.bl.position.y);
    CGFloat tx = (_verts.bl.texCoord1.s - _verts.bl.position.x * sx);
    CGFloat ty = (_verts.bl.texCoord1.t - _verts.bl.position.y * sy);
    
	return CGAffineTransformMake(sx, 0.0f, 0.0f, sy, tx, ty);
}

#pragma mark CCSprite - draw

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;
{
    if(!CCRenderCheckVisbility(transform, _vertexCenter, _vertexExtents)) return;
    
#if CC_ENABLE_EXPERIMENTAL_EFFECTS
    if (self.effect)
    {
        _effectRenderer.contentSize = self.texture.contentSize;
        if ([self.effect prepareForRendering] == CCEffectPrepareSuccess)
        {
            // Preparing an effect for rendering can modify its uniforms
            // dictionary which means we need to reinitialize our copy of the
            // uniforms.
            [self updateShaderUniformsFromEffect];
        }
        [_effectRenderer drawSprite:self withEffect:self.effect uniforms:_shaderUniforms renderer:renderer transform:transform];
    }
    else
#endif
    {
        [self enqueueTriangles:renderer transform:transform];
	}
    
#if CC_SPRITE_DEBUG_DRAW
	const GLKVector2 zero = {{0, 0}};
	const GLKVector4 white = {{1, 1, 1, 1}};
	
	CCRenderBuffer debug = [renderer enqueueLines:4 andVertexes:4 withState:[CCRenderState debugColor] globalSortOrder:0];
	CCRenderBufferSetVertex(debug, 0, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.bl.position), zero, zero, white});
	CCRenderBufferSetVertex(debug, 1, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.br.position), zero, zero, white});
	CCRenderBufferSetVertex(debug, 2, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.tr.position), zero, zero, white});
	CCRenderBufferSetVertex(debug, 3, (CCVertex){GLKMatrix4MultiplyVector4(*transform, _verts.tl.position), zero, zero, white});
	
	CCRenderBufferSetLine(debug, 0, 0, 1);
	CCRenderBufferSetLine(debug, 1, 1, 2);
	CCRenderBufferSetLine(debug, 2, 2, 3);
	CCRenderBufferSetLine(debug, 3, 3, 0);
#endif
}

-(void)enqueueTriangles:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:self.renderState globalSortOrder:0];
    CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(_verts.bl, transform));
    CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(_verts.br, transform));
    CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(_verts.tr, transform));
    CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(_verts.tl, transform));
    
    CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
    CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
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
	
	// Premultiply alpha.
	color4.r *= _displayColor.a;
	color4.g *= _displayColor.a;
	color4.b *= _displayColor.a;
	
	_verts.bl.color = color4;
	_verts.br.color = color4;
	_verts.tr.color = color4;
	_verts.tl.color = color4;
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

-(void)updateDisplayedOpacity:(CGFloat)parentOpacity
{
    [super updateDisplayedOpacity:parentOpacity];
    [self updateColor];
}

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
-(CCEffect *)effect
{
	return _effect;
}

-(void)setEffect:(CCEffect *)effect
{
    _effect = effect;
    if (effect)
    {
        [self updateShaderUniformsFromEffect];
    }
    else
    {
        _shaderUniforms = nil;
    }
}
#endif

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
	[self setTextureRect:frame.rect rotated:frame.rotated untrimmedSize:frame.originalSize];
    
    _spriteFrame = frame;
}

-(void) setNormalMapSpriteFrame:(CCSpriteFrame*)frame
{
    CCSpriteTexCoordSet texCoords = [CCSprite textureCoordsForTexture:frame.texture withRect:frame.rect rotated:frame.rotated xFlipped:_flipX yFlipped:_flipY];
    _verts.bl.texCoord2 = texCoords.bl;
    _verts.br.texCoord2 = texCoords.br;
    _verts.tr.texCoord2 = texCoords.tr;
    _verts.tl.texCoord2 = texCoords.tl;
    
    // Set the main texture in the uniforms dictionary (if the dictionary exists).
    self.shaderUniforms[CCShaderUniformNormalMapTexture] = (frame.texture ?: [CCTexture none]);
    _renderState = nil;
    
    _normalMapSpriteFrame = frame;
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

#pragma mark CCSprite - Effects

#if CC_ENABLE_EXPERIMENTAL_EFFECTS
- (void)updateShaderUniformsFromEffect
{
    // Initialize the shader uniforms dictionary with the sprite's main texture and
    // normal map if it has them.
    _shaderUniforms = [@{ CCShaderUniformMainTexture : (_texture ?: [CCTexture none]),
                          CCShaderUniformNormalMapTexture : (_normalMapSpriteFrame.texture ?: [CCTexture none]),
                          } mutableCopy];
    
    // And then copy the new effect's uniforms into the node's uniforms dictionary.
    [_shaderUniforms addEntriesFromDictionary:_effect.shaderUniforms];
}
#endif

@end
