/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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

#import "ccConfig.h"
#import "CCSpriteBatchNode.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCSpriteFrameCache.h"
#import "CCAnimation.h"
#import "CCAnimationCache.h"
#import "CCTextureCache.h"
#import "CCDrawingPrimitives.h"
#import "CCShaderCache.h"
#import "ccGLStateCache.h"
#import "CCGLProgram.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "Support/TransformUtils.h"
#import "Support/CCProfiling.h"
#import "Support/OpenGL_Internal.h"

// external
#import "kazmath/GL/matrix.h"

#pragma mark -
#pragma mark CCSprite

#if CC_SPRITEBATCHNODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL(__ARGS__) (ceil(__ARGS__))
#endif


@interface CCSprite ()
-(void) setTextureCoords:(CGRect)rect;
-(void) updateBlendFunc;
-(void) setReorderChildDirtyRecursively;
@end

@implementation CCSprite

@synthesize dirty = _dirty;
@synthesize quad = _quad;
@synthesize atlasIndex = _atlasIndex;
@synthesize textureRect = _rect;
@synthesize textureRectRotated = _rectRotated;
@synthesize blendFunc = _blendFunc;
@synthesize textureAtlas = _textureAtlas;
@synthesize offsetPosition = _offsetPosition;


+(id)spriteWithTexture:(CCTexture2D*)texture
{
	return [[[self alloc] initWithTexture:texture] autorelease];
}

+(id)spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	return [[[self alloc] initWithTexture:texture rect:rect] autorelease];
}

+(id)spriteWithFile:(NSString*)filename
{
	return [[[self alloc] initWithFile:filename] autorelease];
}

+(id)spriteWithFile:(NSString*)filename rect:(CGRect)rect
{
	return [[[self alloc] initWithFile:filename rect:rect] autorelease];
}

+(id)spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
	return [[[self alloc] initWithSpriteFrame:spriteFrame] autorelease];
}

+(id)spriteWithSpriteFrameName:(NSString*)spriteFrameName
{
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];

	NSAssert1(frame!=nil, @"Invalid spriteFrameName: %@", spriteFrameName);
	return [self spriteWithSpriteFrame:frame];
}

+(id)spriteWithCGImage:(CGImageRef)image key:(NSString*)key
{
	return [[[self alloc] initWithCGImage:image key:key] autorelease];
}

-(id) init
{
	return [self initWithTexture:nil rect:CGRectZero];
}

// designated initializer
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	if( (self = [super init]) )
	{
		// shader program
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];

		_dirty = _recursiveDirty = NO;

		_opacityModifyRGB = YES;

		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;

		_flipY = _flipX = NO;

		// default transform anchor: center
		_anchorPoint =  ccp(0.5f, 0.5f);

		// zwoptex default values
		_offsetPosition = CGPointZero;

		_hasChildren = NO;
		_batchNode = nil;

		// clean the Quad
		bzero(&_quad, sizeof(_quad));

		// Atlas: Color
		ccColor4B tmpColor = {255,255,255,255};
		_quad.bl.colors = tmpColor;
		_quad.br.colors = tmpColor;
		_quad.tl.colors = tmpColor;
		_quad.tr.colors = tmpColor;

		[self setTexture:texture];
		[self setTextureRect:rect rotated:rotated untrimmedSize:rect.size];


		// by default use "Self Render".
		// if the sprite is added to a batchnode, then it will automatically switch to "batchnode Render"
		[self setBatchNode:nil];

	}
	return self;
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	return [self initWithTexture:texture rect:rect rotated:NO];
}

-(id) initWithTexture:(CCTexture2D*)texture
{
	NSAssert(texture!=nil, @"Invalid texture for sprite");

	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	return [self initWithTexture:texture rect:rect];
}

-(id) initWithFile:(NSString*)filename
{
	NSAssert(filename != nil, @"Invalid filename for sprite");

	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
	if( texture ) {
		CGRect rect = CGRectZero;
		rect.size = texture.contentSize;
		return [self initWithTexture:texture rect:rect];
	}

	[self release];
	return nil;
}

-(id) initWithFile:(NSString*)filename rect:(CGRect)rect
{
	NSAssert(filename!=nil, @"Invalid filename for sprite");

	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
	if( texture )
		return [self initWithTexture:texture rect:rect];

	[self release];
	return nil;
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
	NSAssert(spriteFrame!=nil, @"Invalid spriteFrame for sprite");

	id ret = [self initWithTexture:spriteFrame.texture rect:spriteFrame.rect];
	[self setDisplayFrame:spriteFrame];
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
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addCGImage:image forKey:key];

	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;

	return [self initWithTexture:texture rect:rect];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Rect = (%.2f,%.2f,%.2f,%.2f) | tag = %ld | atlasIndex = %ld>", [self class], self,
			_rect.origin.x, _rect.origin.y, _rect.size.width, _rect.size.height,
			(long)_tag,
			(unsigned long)_atlasIndex
	];
}

- (void) dealloc
{
	[_texture release];
	[super dealloc];
}

-(CCSpriteBatchNode*) batchNode
{
	return _batchNode;
}

-(void) setBatchNode:(CCSpriteBatchNode *)batchNode
{
	_batchNode = batchNode; // weak reference

	// self render
	if( ! batchNode ) {
		_atlasIndex = CCSpriteIndexNotInitialized;
		_textureAtlas = nil;
		_dirty = _recursiveDirty = NO;

		float x1 = _offsetPosition.x;
		float y1 = _offsetPosition.y;
		float x2 = x1 + _rect.size.width;
		float y2 = y1 + _rect.size.height;
		_quad.bl.vertices = (ccVertex3F) { x1, y1, 0 };
		_quad.br.vertices = (ccVertex3F) { x2, y1, 0 };
		_quad.tl.vertices = (ccVertex3F) { x1, y2, 0 };
		_quad.tr.vertices = (ccVertex3F) { x2, y2, 0 };

	} else {

		// using batch
		_transformToBatch = CGAffineTransformIdentity;
		_textureAtlas = [batchNode textureAtlas]; // weak ref
	}
}

-(void) setTextureRect:(CGRect)rect
{
	[self setTextureRect:rect rotated:NO untrimmedSize:rect.size];
}

-(void) setTextureRect:(CGRect)rect rotated:(BOOL)rotated untrimmedSize:(CGSize)untrimmedSize
{
	_rectRotated = rotated;

	[self setContentSize:untrimmedSize];
	[self setVertexRect:rect];
	[self setTextureCoords:rect];

	CGPoint relativeOffset = _unflippedOffsetPositionFromCenter;

	// issue #732
	if( _flipX )
		relativeOffset.x = -relativeOffset.x;
	if( _flipY )
		relativeOffset.y = -relativeOffset.y;


	_offsetPosition.x = relativeOffset.x + (_contentSize.width - _rect.size.width) / 2;
	_offsetPosition.y = relativeOffset.y + (_contentSize.height - _rect.size.height) / 2;


	// rendering using batch node
	if( _batchNode ) {
		// update _dirty, don't update _recursiveDirty
		_dirty = YES;
	}

	// self rendering
	else
	{
		// Atlas: Vertex
		float x1 = _offsetPosition.x;
		float y1 = _offsetPosition.y;
		float x2 = x1 + _rect.size.width;
		float y2 = y1 + _rect.size.height;

		// Don't update Z.
		_quad.bl.vertices = (ccVertex3F) { x1, y1, 0 };
		_quad.br.vertices = (ccVertex3F) { x2, y1, 0 };
		_quad.tl.vertices = (ccVertex3F) { x1, y2, 0 };
		_quad.tr.vertices = (ccVertex3F) { x2, y2, 0 };
	}
}

// override this method to generate "double scale" sprites
-(void) setVertexRect:(CGRect)rect
{
	_rect = rect;
}

-(void) setTextureCoords:(CGRect)rect
{
	rect = CC_RECT_POINTS_TO_PIXELS(rect);

	CCTexture2D *tex	= (_batchNode) ? [_textureAtlas texture] : _texture;
	if(!tex)
		return;

	float atlasWidth = (float)tex.pixelsWide;
	float atlasHeight = (float)tex.pixelsHigh;

	float left, right ,top , bottom;

	if(_rectRotated)
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

		_quad.bl.texCoords.u = left;
		_quad.bl.texCoords.v = top;
		_quad.br.texCoords.u = left;
		_quad.br.texCoords.v = bottom;
		_quad.tl.texCoords.u = right;
		_quad.tl.texCoords.v = top;
		_quad.tr.texCoords.u = right;
		_quad.tr.texCoords.v = bottom;
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

		_quad.bl.texCoords.u = left;
		_quad.bl.texCoords.v = bottom;
		_quad.br.texCoords.u = right;
		_quad.br.texCoords.v = bottom;
		_quad.tl.texCoords.u = left;
		_quad.tl.texCoords.v = top;
		_quad.tr.texCoords.u = right;
		_quad.tr.texCoords.v = top;
	}
}

-(void)updateTransform
{
	NSAssert( _batchNode, @"updateTransform is only valid when CCSprite is being rendered using an CCSpriteBatchNode");

	// recaculate matrix only if it is dirty
	if( self.dirty ) {

		// If it is not visible, or one of its ancestors is not visible, then do nothing:
		if( !_visible || ( _parent && _parent != _batchNode && ((CCSprite*)_parent)->_shouldBeHidden) ) {
			_quad.br.vertices = _quad.tl.vertices = _quad.tr.vertices = _quad.bl.vertices = (ccVertex3F){0,0,0};
			_shouldBeHidden = YES;
		}

		else {

			_shouldBeHidden = NO;

			if( ! _parent || _parent == _batchNode )
				_transformToBatch = [self nodeToParentTransform];

			else {
				NSAssert( [_parent isKindOfClass:[CCSprite class]], @"Logic error in CCSprite. Parent must be a CCSprite");

				_transformToBatch = CGAffineTransformConcat( [self nodeToParentTransform] , ((CCSprite*)_parent)->_transformToBatch );
			}

			//
			// calculate the Quad based on the Affine Matrix
			//

			CGSize size = _rect.size;

			float x1 = _offsetPosition.x;
			float y1 = _offsetPosition.y;

			float x2 = x1 + size.width;
			float y2 = y1 + size.height;
			float x = _transformToBatch.tx;
			float y = _transformToBatch.ty;

			float cr = _transformToBatch.a;
			float sr = _transformToBatch.b;
			float cr2 = _transformToBatch.d;
			float sr2 = -_transformToBatch.c;
			float ax = x1 * cr - y1 * sr2 + x;
			float ay = x1 * sr + y1 * cr2 + y;

			float bx = x2 * cr - y1 * sr2 + x;
			float by = x2 * sr + y1 * cr2 + y;

			float cx = x2 * cr - y2 * sr2 + x;
			float cy = x2 * sr + y2 * cr2 + y;

			float dx = x1 * cr - y2 * sr2 + x;
			float dy = x1 * sr + y2 * cr2 + y;

			_quad.bl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(ax), RENDER_IN_SUBPIXEL(ay), _vertexZ };
			_quad.br.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(bx), RENDER_IN_SUBPIXEL(by), _vertexZ };
			_quad.tl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(dx), RENDER_IN_SUBPIXEL(dy), _vertexZ };
			_quad.tr.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(cx), RENDER_IN_SUBPIXEL(cy), _vertexZ };
		}

		[_textureAtlas updateQuad:&_quad atIndex:_atlasIndex];
		_dirty = _recursiveDirty = NO;
	}

	// recursively iterate over children
	if( _hasChildren )
		[_children makeObjectsPerformSelector:@selector(updateTransform)];

#if CC_SPRITE_DEBUG_DRAW
	// draw bounding box
	CGPoint vertices[4] = {
		ccp( _quad.bl.vertices.x, _quad.bl.vertices.y ),
		ccp( _quad.br.vertices.x, _quad.br.vertices.y ),
		ccp( _quad.tr.vertices.x, _quad.tr.vertices.y ),
		ccp( _quad.tl.vertices.x, _quad.tl.vertices.y ),
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW

}

#pragma mark CCSprite - draw

-(void) draw
{
	CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");

	NSAssert(!_batchNode, @"If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called");

	CC_NODE_DRAW_SETUP();

	ccGLBlendFunc( _blendFunc.src, _blendFunc.dst );

	ccGLBindTexture2D( [_texture name] );

	//
	// Attributes
	//

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );

#define kQuadSize sizeof(_quad.bl)
	long offset = (long)&_quad;

	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));

	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));

	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));


	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	CHECK_GL_ERROR_DEBUG();


#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGPoint vertices[4]={
		ccp(_quad.tl.vertices.x,_quad.tl.vertices.y),
		ccp(_quad.bl.vertices.x,_quad.bl.vertices.y),
		ccp(_quad.br.vertices.x,_quad.br.vertices.y),
		ccp(_quad.tr.vertices.x,_quad.tr.vertices.y),
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] = {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW

	CC_INCREMENT_GL_DRAWS(1);

	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
}

#pragma mark CCSprite - CCNode overrides

-(void) addChild:(CCSprite*)child z:(NSInteger)z tag:(NSInteger) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");

	if( _batchNode ) {
		NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSprite only supports CCSprites as children when using CCSpriteBatchNode");
		NSAssert( child.texture.name == _textureAtlas.texture.name, @"CCSprite is not using the same texture id");

		//put it in descendants array of batch node
		[_batchNode appendChild:child];

		if (!_isReorderChildDirty)
			[self setReorderChildDirtyRecursively];
	}

	//CCNode already sets _isReorderChildDirty so this needs to be after batchNode check
	[super addChild:child z:z tag:aTag];

	_hasChildren = YES;
}

-(void) reorderChild:(CCSprite*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	NSAssert( [_children containsObject:child], @"Child doesn't belong to Sprite" );

	if( z == child.zOrder )
		return;

	if( _batchNode && ! _isReorderChildDirty)
	{
		[self setReorderChildDirtyRecursively];
		[_batchNode reorderBatch:YES];
	}

	[super reorderChild:child z:z];
}

-(void)removeChild: (CCSprite *)sprite cleanup:(BOOL)doCleanup
{
	if( _batchNode )
		[_batchNode removeSpriteFromAtlas:sprite];

	[super removeChild:sprite cleanup:doCleanup];

	_hasChildren = ( [_children count] > 0 );
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	if( _batchNode ) {
		CCSprite *child;
		CCARRAY_FOREACH(_children, child)
			[_batchNode removeSpriteFromAtlas:child];
	}

	[super removeAllChildrenWithCleanup:doCleanup];

	_hasChildren = NO;
}

- (void) sortAllChildren
{
	if (_isReorderChildDirty)
	{
		NSInteger i,j,length = _children->data->num;
		CCNode** x = _children->data->arr;
		CCNode *tempItem;

		// insertion sort
		for(i=1; i<length; i++)
		{
			tempItem = x[i];
			j = i-1;

			//continue moving element downwards while zOrder is smaller or when zOrder is the same but orderOfArrival is smaller
			while(j>=0 && ( tempItem.zOrder < x[j].zOrder || ( tempItem.zOrder == x[j].zOrder && tempItem.orderOfArrival < x[j].orderOfArrival ) ) )
			{
				x[j+1] = x[j];
				j = j-1;
			}
			x[j+1] = tempItem;
		}

		if ( _batchNode)
			[_children makeObjectsPerformSelector:@selector(sortAllChildren)];

		_isReorderChildDirty=NO;
	}
}

//
// CCNode property overloads
// used only when parent is CCSpriteBatchNode
//
#pragma mark CCSprite - property overloads

-(void) setReorderChildDirtyRecursively
{
	//only set parents flag the first time

	if ( ! _isReorderChildDirty )
	{
		_isReorderChildDirty = YES;
		CCNode* node = (CCNode*) _parent;
		while (node && node != _batchNode)
		{
			[(CCSprite*)node setReorderChildDirtyRecursively];
			node=node.parent;
		}
	}
}

-(void) setDirtyRecursively:(BOOL)b
{
	_dirty = _recursiveDirty = b;
	// recursively set dirty
	if( _hasChildren ) {
		CCSprite *child;
		CCARRAY_FOREACH(_children, child)
			[child setDirtyRecursively:YES];
	}
}

// XXX HACK: optimization
#define SET_DIRTY_RECURSIVELY() {									\
					if( _batchNode && ! _recursiveDirty ) {	\
						_dirty = _recursiveDirty = YES;				\
						if( _hasChildren)							\
							[self setDirtyRecursively:YES];			\
						}											\
					}

-(void)setPosition:(CGPoint)pos
{
	[super setPosition:pos];
	SET_DIRTY_RECURSIVELY();
}

-(void)setRotation:(float)rot
{
	[super setRotation:rot];
	SET_DIRTY_RECURSIVELY();
}

-(void)setRotationX:(float)rot
{
	[super setRotationX:rot];
	SET_DIRTY_RECURSIVELY();
}

-(void)setRotationY:(float)rot
{
	[super setRotationY:rot];
	SET_DIRTY_RECURSIVELY();
}

-(void)setSkewX:(float)sx
{
	[super setSkewX:sx];
	SET_DIRTY_RECURSIVELY();
}

-(void)setSkewY:(float)sy
{
	[super setSkewY:sy];
	SET_DIRTY_RECURSIVELY();
}

-(void)setScaleX:(float) sx
{
	[super setScaleX:sx];
	SET_DIRTY_RECURSIVELY();
}

-(void)setScaleY:(float) sy
{
	[super setScaleY:sy];
	SET_DIRTY_RECURSIVELY();
}

-(void)setScale:(float) s
{
	[super setScale:s];
	SET_DIRTY_RECURSIVELY();
}

-(void) setVertexZ:(float)z
{
	[super setVertexZ:z];
	SET_DIRTY_RECURSIVELY();
}

-(void)setAnchorPoint:(CGPoint)anchor
{
	[super setAnchorPoint:anchor];
	SET_DIRTY_RECURSIVELY();
}

-(void) setIgnoreAnchorPointForPosition:(BOOL)value
{
	NSAssert( ! _batchNode, @"ignoreAnchorPointForPosition is invalid in CCSprite");
	[super setIgnoreAnchorPointForPosition:value];
}

-(void)setVisible:(BOOL)v
{
	[super setVisible:v];
	SET_DIRTY_RECURSIVELY();
}

-(void)setFlipX:(BOOL)b
{
	if( _flipX != b ) {
		_flipX = b;
		[self setTextureRect:_rect rotated:_rectRotated untrimmedSize:_contentSize];
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
		[self setTextureRect:_rect rotated:_rectRotated untrimmedSize:_contentSize];
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
	ccColor4B color4 = {_displayedColor.r, _displayedColor.g, _displayedColor.b, _displayedOpacity};

	
	// special opacity for premultiplied textures
	if ( _opacityModifyRGB ) {
		color4.r *= _displayedOpacity/255.0f;
		color4.g *= _displayedOpacity/255.0f;
		color4.b *= _displayedOpacity/255.0f;
    }

	_quad.bl.colors = color4;
	_quad.br.colors = color4;
	_quad.tl.colors = color4;
	_quad.tr.colors = color4;

	// renders using batch node
	if( _batchNode ) {
		if( _atlasIndex != CCSpriteIndexNotInitialized)
			[_textureAtlas updateQuad:&_quad atIndex:_atlasIndex];
		else
			// no need to set it recursively
			// update _dirty, don't update _recursiveDirty
			_dirty = YES;
	}
	// self render
	// do nothing
}

-(void) setColor:(ccColor3B)color3
{
    [super setColor:color3];
	[self updateColor];
}

-(void)updateDisplayedColor:(ccColor3B)parentColor
{
    [super updateDisplayedColor:parentColor];
    [self updateColor];
}

-(void) setOpacity:(GLubyte)opacity
{
    [super setOpacity:opacity];
	[self updateColor];
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	if( _opacityModifyRGB != modify )
		[self updateColor];
}

-(BOOL) doesOpacityModifyRGB
{
	return _opacityModifyRGB;
}

-(void)updateDisplayedOpacity:(GLubyte)parentOpacity
{
    [super updateDisplayedOpacity:parentOpacity];
    [self updateColor];
}


//
// Frames
//
#pragma mark CCSprite - Frames

-(void) setDisplayFrame:(CCSpriteFrame*)frame
{
	_unflippedOffsetPositionFromCenter = frame.offset;

	CCTexture2D *newTexture = [frame texture];
	// update texture before updating texture rect
	if ( newTexture.name != _texture.name )
		[self setTexture: newTexture];

	// update rect
	_rectRotated = frame.rotated;

	[self setTextureRect:frame.rect rotated:_rectRotated untrimmedSize:frame.originalSize];
}

-(void) setDisplayFrameWithAnimationName: (NSString*) animationName index:(int) frameIndex
{
	NSAssert( animationName, @"CCSprite#setDisplayFrameWithAnimationName. animationName must not be nil");

	CCAnimation *a = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];

	NSAssert( a, @"CCSprite#setDisplayFrameWithAnimationName: Frame not found");

	CCAnimationFrame *frame = [[a frames] objectAtIndex:frameIndex];

	NSAssert( frame, @"CCSprite#setDisplayFrame. Invalid frame");

	[self setDisplayFrame:frame.spriteFrame];
}


-(BOOL) isFrameDisplayed:(CCSpriteFrame*)frame
{
	CGRect r = [frame rect];
	return ( CGRectEqualToRect(r, _rect) &&
			frame.texture.name == self.texture.name &&
			CGPointEqualToPoint( frame.offset, _unflippedOffsetPositionFromCenter ) );
}

-(CCSpriteFrame*) displayFrame
{
	return [CCSpriteFrame frameWithTexture:_texture
							  rectInPixels:CC_RECT_POINTS_TO_PIXELS(_rect)
								   rotated:_rectRotated
									offset:CC_POINT_POINTS_TO_PIXELS(_unflippedOffsetPositionFromCenter)
							  originalSize:CC_SIZE_POINTS_TO_PIXELS(_contentSize)];
}

#pragma mark CCSprite - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	NSAssert( ! _batchNode, @"CCSprite: updateBlendFunc doesn't work when the sprite is rendered using a CCSpriteBatchNode");

	// it is possible to have an untextured sprite
	if( !_texture || ! [_texture hasPremultipliedAlpha] ) {
		_blendFunc.src = GL_SRC_ALPHA;
		_blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
		[self setOpacityModifyRGB:NO];
	} else {
		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;
		[self setOpacityModifyRGB:YES];
	}
}

-(void) setTexture:(CCTexture2D*)texture
{
	// If batchnode, then texture id should be the same
	NSAssert( !_batchNode || texture.name == _batchNode.texture.name , @"CCSprite: Batched sprites should use the same texture as the batchnode");	

	// accept texture==nil as argument
	NSAssert( !texture || [texture isKindOfClass:[CCTexture2D class]], @"setTexture expects a CCTexture2D. Invalid argument");

	if( ! _batchNode && _texture != texture ) {
		[_texture release];
		_texture = [texture retain];

		[self updateBlendFunc];
	}
}

-(CCTexture2D*) texture
{
	return _texture;
}

@end
