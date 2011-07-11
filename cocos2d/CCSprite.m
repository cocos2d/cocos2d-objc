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

#import <Availability.h>

#import "ccConfig.h"
#import "CCSpriteBatchNode.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCSpriteFrameCache.h"
#import "CCAnimation.h"
#import "CCAnimationCache.h"
#import "CCTextureCache.h"
#import "Support/CGPointExtension.h"
#import "CCDrawingPrimitives.h"

#pragma mark -
#pragma mark CCSprite

#if CC_SPRITEBATCHNODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL(__A__) ( (int)(__A__))
#endif

// XXX: Optmization
struct transformValues_ {
	CGPoint pos;		// position x and y
	CGPoint	scale;		// scale x and y
	float	rotation;
	CGPoint skew;		// skew x and y
	CGPoint ap;			// anchor point in pixels
	BOOL	visible;
};

@interface CCSprite (Private)
-(void)updateTextureCoords:(CGRect)rect;
-(void)updateBlendFunc;
-(void) initAnimationDictionary;
-(void) getTransformValues:(struct transformValues_*)tv;	// optimization
@end

@implementation CCSprite

@synthesize dirty = dirty_;
@synthesize quad = quad_;
@synthesize atlasIndex = atlasIndex_;
@synthesize textureRect = rect_;
@synthesize textureRectRotated = rectRotated_;
@synthesize blendFunc = blendFunc_;
@synthesize usesBatchNode = usesBatchNode_;
@synthesize textureAtlas = textureAtlas_;
@synthesize batchNode = batchNode_;
@synthesize honorParentTransform = honorParentTransform_;
@synthesize offsetPositionInPixels = offsetPositionInPixels_;


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

+(id) spriteWithBatchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect
{
	return [[[self alloc] initWithBatchNode:batchNode rect:rect] autorelease];
}

-(id) init
{
	if( (self=[super init]) ) {
		dirty_ = recursiveDirty_ = NO;
		
		// by default use "Self Render".
		// if the sprite is added to a batchnode, then it will automatically switch to "batchnode Render"
		[self useSelfRender];
		
		opacityModifyRGB_			= YES;
		opacity_					= 255;
		color_ = colorUnmodified_	= ccWHITE;
		
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		
		// update texture (calls updateBlendFunc)
		[self setTexture:nil];
		
		// clean the Quad
		bzero(&quad_, sizeof(quad_));
		
		flipY_ = flipX_ = NO;
		
		// lazy alloc
		animations_ = nil;
		
		// default transform anchor: center
		anchorPoint_ =  ccp(0.5f, 0.5f);
		
		// zwoptex default values
		offsetPositionInPixels_ = CGPointZero;
		
		honorParentTransform_ = CC_HONOR_PARENT_TRANSFORM_ALL;
		hasChildren_ = NO;
		
		// Atlas: Color
		ccColor4B tmpColor = {255,255,255,255};
		quad_.bl.colors = tmpColor;
		quad_.br.colors = tmpColor;
		quad_.tl.colors = tmpColor;
		quad_.tr.colors = tmpColor;	
		
		// Atlas: Vertex
		
		// updated in "useSelfRender"
		
		// Atlas: TexCoords
		[self setTextureRectInPixels:CGRectZero rotated:NO untrimmedSize:CGSizeZero];
		
		// updateMethod selector
		updateMethod = (__typeof__(updateMethod))[self methodForSelector:@selector(updateTransform)];
	}
	
	return self;
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	NSAssert(texture!=nil, @"Invalid texture for sprite");
	// IMPORTANT: [self init] and not [super init];
	if( (self = [self init]) )
	{
		[self setTexture:texture];
		[self setTextureRect:rect];
	}
	return self;
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
	NSAssert(filename!=nil, @"Invalid filename for sprite");

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

// XXX: deprecated
- (id) initWithCGImage: (CGImageRef)image
{
	NSAssert(image!=nil, @"Invalid CGImageRef for sprite");

	// XXX: possible bug. See issue #349. New API should be added
	NSString *key = [NSString stringWithFormat:@"%08X",(unsigned long)image];
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addCGImage:image forKey:key];
	
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	
	return [self initWithTexture:texture rect:rect];
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

-(id) initWithBatchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect
{
	id ret = [self initWithTexture:batchNode.texture rect:rect];
	[self useBatchNode:batchNode];
	
	return ret;
}

-(id) initWithBatchNode:(CCSpriteBatchNode*)batchNode rectInPixels:(CGRect)rect
{
	id ret = [self initWithTexture:batchNode.texture];
	[self setTextureRectInPixels:rect rotated:NO untrimmedSize:rect.size];
	[self useBatchNode:batchNode];
	
	return ret;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Rect = (%.2f,%.2f,%.2f,%.2f) | tag = %i | atlasIndex = %i>", [self class], self,
			rect_.origin.x, rect_.origin.y, rect_.size.width, rect_.size.height,
			tag_,
			atlasIndex_
	];
}

- (void) dealloc
{
	[texture_ release];
	[animations_ release];
	[super dealloc];
}

-(void) useSelfRender
{
	atlasIndex_ = CCSpriteIndexNotInitialized;
	usesBatchNode_ = NO;
	textureAtlas_ = nil;
	batchNode_ = nil;
	dirty_ = recursiveDirty_ = NO;
	
	float x1 = 0 + offsetPositionInPixels_.x;
	float y1 = 0 + offsetPositionInPixels_.y;
	float x2 = x1 + rectInPixels_.size.width;
	float y2 = y1 + rectInPixels_.size.height;
	quad_.bl.vertices = (ccVertex3F) { x1, y1, 0 };
	quad_.br.vertices = (ccVertex3F) { x2, y1, 0 };
	quad_.tl.vertices = (ccVertex3F) { x1, y2, 0 };
	quad_.tr.vertices = (ccVertex3F) { x2, y2, 0 };		
}

-(void) useBatchNode:(CCSpriteBatchNode*)batchNode
{
	usesBatchNode_ = YES;
	textureAtlas_ = [batchNode textureAtlas]; // weak ref
	batchNode_ = batchNode; // weak ref
}

-(void) initAnimationDictionary
{
	animations_ = [[NSMutableDictionary alloc] initWithCapacity:2];
}

-(void)setTextureRect:(CGRect)rect
{
	CGRect rectInPixels = CC_RECT_POINTS_TO_PIXELS( rect );
	[self setTextureRectInPixels:rectInPixels rotated:NO untrimmedSize:rectInPixels.size];
}

-(void)setTextureRectInPixels:(CGRect)rect rotated:(BOOL)rotated untrimmedSize:(CGSize)untrimmedSize
{
	rectInPixels_ = rect;
	rect_ = CC_RECT_PIXELS_TO_POINTS( rect );
	rectRotated_ = rotated;

	[self setContentSizeInPixels:untrimmedSize];
	[self updateTextureCoords:rectInPixels_];

	CGPoint relativeOffsetInPixels = unflippedOffsetPositionFromCenter_;
	
	// issue #732
	if( flipX_ )
		relativeOffsetInPixels.x = -relativeOffsetInPixels.x;
	if( flipY_ )
		relativeOffsetInPixels.y = -relativeOffsetInPixels.y;
	
	offsetPositionInPixels_.x = relativeOffsetInPixels.x + (contentSizeInPixels_.width - rectInPixels_.size.width) / 2;
	offsetPositionInPixels_.y = relativeOffsetInPixels.y + (contentSizeInPixels_.height - rectInPixels_.size.height) / 2;
	
	
	// rendering using batch node
	if( usesBatchNode_ ) {
		// update dirty_, don't update recursiveDirty_
		dirty_ = YES;
	}

	// self rendering
	else
	{
		// Atlas: Vertex
		float x1 = 0 + offsetPositionInPixels_.x;
		float y1 = 0 + offsetPositionInPixels_.y;
		float x2 = x1 + rectInPixels_.size.width;
		float y2 = y1 + rectInPixels_.size.height;
		
		// Don't update Z.
		quad_.bl.vertices = (ccVertex3F) { x1, y1, 0 };
		quad_.br.vertices = (ccVertex3F) { x2, y1, 0 };
		quad_.tl.vertices = (ccVertex3F) { x1, y2, 0 };
		quad_.tr.vertices = (ccVertex3F) { x2, y2, 0 };	
	}			
}

-(void)updateTextureCoords:(CGRect)rect
{
	CCTexture2D *tex	= (usesBatchNode_)?[textureAtlas_ texture]:texture_;
	if(!tex)
		return;
	
	float atlasWidth = (float)tex.pixelsWide;
	float atlasHeight = (float)tex.pixelsHigh;
	
	float left,right,top,bottom;
	
	if(rectRotated_){
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		left	= (2*rect.origin.x+1)/(2*atlasWidth);
		right	= left+(rect.size.height*2-2)/(2*atlasWidth);
		top		= (2*rect.origin.y+1)/(2*atlasHeight);
		bottom	= top+(rect.size.width*2-2)/(2*atlasHeight);
#else
		left	= rect.origin.x/atlasWidth;
		right	= left+(rect.size.height/atlasWidth);
		top		= rect.origin.y/atlasHeight;
		bottom	= top+(rect.size.width/atlasHeight);
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		
		if( flipX_)
			CC_SWAP(top,bottom);
		if( flipY_)
			CC_SWAP(left,right);
		
		quad_.bl.texCoords.u = left;
		quad_.bl.texCoords.v = top;
		quad_.br.texCoords.u = left;
		quad_.br.texCoords.v = bottom;
		quad_.tl.texCoords.u = right;
		quad_.tl.texCoords.v = top;
		quad_.tr.texCoords.u = right;
		quad_.tr.texCoords.v = bottom;
	} else {
#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		left	= (2*rect.origin.x+1)/(2*atlasWidth);
		right	= left + (rect.size.width*2-2)/(2*atlasWidth);
		top		= (2*rect.origin.y+1)/(2*atlasHeight);
		bottom	= top + (rect.size.height*2-2)/(2*atlasHeight);
#else
		left	= rect.origin.x/atlasWidth;
		right	= left + rect.size.width/atlasWidth;
		top		= rect.origin.y/atlasHeight;
		bottom	= top + rect.size.height/atlasHeight;
#endif // ! CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
		
		if( flipX_)
			CC_SWAP(left,right);
		if( flipY_)
			CC_SWAP(top,bottom);
		
		quad_.bl.texCoords.u = left;
		quad_.bl.texCoords.v = bottom;
		quad_.br.texCoords.u = right;
		quad_.br.texCoords.v = bottom;
		quad_.tl.texCoords.u = left;
		quad_.tl.texCoords.v = top;
		quad_.tr.texCoords.u = right;
		quad_.tr.texCoords.v = top;
	}
}

-(void)updateTransform
{
	NSAssert( usesBatchNode_, @"updateTransform is only valid when CCSprite is being renderd using an CCSpriteBatchNode");

	// optimization. Quick return if not dirty
	if( ! dirty_ )
		return;
	
	CGAffineTransform matrix;
	
	// Optimization: if it is not visible, then do nothing
	if( ! visible_ ) {
		quad_.br.vertices = quad_.tl.vertices = quad_.tr.vertices = quad_.bl.vertices = (ccVertex3F){0,0,0};
		[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
		dirty_ = recursiveDirty_ = NO;
		return ;
	}
	

	// Optimization: If parent is batchnode, or parent is nil
	// build Affine transform manually
	if( ! parent_ || parent_ == batchNode_ ) {
		
		float radians = -CC_DEGREES_TO_RADIANS(rotation_);
		float c = cosf(radians);
		float s = sinf(radians);

		matrix = CGAffineTransformMake( c * scaleX_,  s * scaleX_,
									   -s * scaleY_, c * scaleY_,
									   positionInPixels_.x, positionInPixels_.y);
		if( skewX_ || skewY_ ) {
			CGAffineTransform skewMatrix = CGAffineTransformMake(1.0f, tanf(CC_DEGREES_TO_RADIANS(skewY_)),
																 tanf(CC_DEGREES_TO_RADIANS(skewX_)), 1.0f,
																 0.0f, 0.0f);
			matrix = CGAffineTransformConcat(skewMatrix, matrix);
		}
		matrix = CGAffineTransformTranslate(matrix, -anchorPointInPixels_.x, -anchorPointInPixels_.y);		

		
	}  else { 	// parent_ != batchNode_ 

		// else do affine transformation according to the HonorParentTransform

		matrix = CGAffineTransformIdentity;
		ccHonorParentTransform prevHonor = CC_HONOR_PARENT_TRANSFORM_ALL;
		
		for (CCNode *p = self ; p && p != batchNode_ ; p = p.parent) {
			
			// Might happen. Issue #1053
			NSAssert( [p isKindOfClass:[CCSprite class]], @"CCSprite should be a CCSprite subclass. Probably you initialized an sprite with a batchnode, but you didn't add it to the batch node." );

			struct transformValues_ tv;
			[(CCSprite*)p getTransformValues: &tv];
			
			// If any of the parents are not visible, then don't draw this node
			if( ! tv.visible ) {
				quad_.br.vertices = quad_.tl.vertices = quad_.tr.vertices = quad_.bl.vertices = (ccVertex3F){0,0,0};
				[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
				dirty_ = recursiveDirty_ = NO;
				return;
			}
			CGAffineTransform newMatrix = CGAffineTransformIdentity;
			
			// 2nd: Translate, Skew, Rotate, Scale
			if( prevHonor & CC_HONOR_PARENT_TRANSFORM_TRANSLATE )
				newMatrix = CGAffineTransformTranslate(newMatrix, tv.pos.x, tv.pos.y);
			if( prevHonor & CC_HONOR_PARENT_TRANSFORM_ROTATE )
				newMatrix = CGAffineTransformRotate(newMatrix, -CC_DEGREES_TO_RADIANS(tv.rotation));
			if ( prevHonor & CC_HONOR_PARENT_TRANSFORM_SKEW ) {
				CGAffineTransform skew = CGAffineTransformMake(1.0f, tanf(CC_DEGREES_TO_RADIANS(tv.skew.y)), tanf(CC_DEGREES_TO_RADIANS(tv.skew.x)), 1.0f, 0.0f, 0.0f);
				// apply the skew to the transform
				newMatrix = CGAffineTransformConcat(skew, newMatrix);
			}
			if( prevHonor & CC_HONOR_PARENT_TRANSFORM_SCALE ) {
				newMatrix = CGAffineTransformScale(newMatrix, tv.scale.x, tv.scale.y);
			}
			
			// 3rd: Translate anchor point
			newMatrix = CGAffineTransformTranslate(newMatrix, -tv.ap.x, -tv.ap.y);

			// 4th: Matrix multiplication
			matrix = CGAffineTransformConcat( matrix, newMatrix);
			
			prevHonor = [(CCSprite*)p honorParentTransform];
		}		
	}
	
	
	//
	// calculate the Quad based on the Affine Matrix
	//	

	CGSize size = rectInPixels_.size;

	float x1 = offsetPositionInPixels_.x;
	float y1 = offsetPositionInPixels_.y;
	
	float x2 = x1 + size.width;
	float y2 = y1 + size.height;
	float x = matrix.tx;
	float y = matrix.ty;
	
	float cr = matrix.a;
	float sr = matrix.b;
	float cr2 = matrix.d;
	float sr2 = -matrix.c;
	float ax = x1 * cr - y1 * sr2 + x;
	float ay = x1 * sr + y1 * cr2 + y;
	
	float bx = x2 * cr - y1 * sr2 + x;
	float by = x2 * sr + y1 * cr2 + y;
	
	float cx = x2 * cr - y2 * sr2 + x;
	float cy = x2 * sr + y2 * cr2 + y;
	
	float dx = x1 * cr - y2 * sr2 + x;
	float dy = x1 * sr + y2 * cr2 + y;
	
	quad_.bl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(ax), RENDER_IN_SUBPIXEL(ay), vertexZ_ };
	quad_.br.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(bx), RENDER_IN_SUBPIXEL(by), vertexZ_ };
	quad_.tl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(dx), RENDER_IN_SUBPIXEL(dy), vertexZ_ };
	quad_.tr.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(cx), RENDER_IN_SUBPIXEL(cy), vertexZ_ };
		
	[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
	dirty_ = recursiveDirty_ = NO;
}

// XXX: Optimization: instead of calling 5 times the parent sprite to obtain: position, scale.x, scale.y, anchorpoint and rotation,
// this fuction return the 5 values in 1 single call
-(void) getTransformValues:(struct transformValues_*) tv
{
	tv->pos			= positionInPixels_;
	tv->scale.x		= scaleX_;
	tv->scale.y		= scaleY_;
	tv->rotation	= rotation_;
	tv->skew.x		= skewX_;
	tv->skew.y		= skewY_;
	tv->ap			= anchorPointInPixels_;
	tv->visible		= visible_;
}

#pragma mark CCSprite - draw

-(void) draw
{
	[super draw];

	NSAssert(!usesBatchNode_, @"If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called");

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: -

	BOOL newBlend = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
	if( newBlend )
		glBlendFunc( blendFunc_.src, blendFunc_.dst );

#define kQuadSize sizeof(quad_.bl)
	glBindTexture(GL_TEXTURE_2D, [texture_ name]);
	
	long offset = (long)&quad_;
	
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexPointer(3, GL_FLOAT, kQuadSize, (void*) (offset + diff) );
	
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (void*)(offset + diff));
	
	// tex coords
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glTexCoordPointer(2, GL_FLOAT, kQuadSize, (void*)(offset + diff));
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGSize s = self.contentSize;
	CGPoint vertices[4] = {
		ccp(0,0), ccp(s.width,0),
		ccp(s.width,s.height), ccp(0,s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPositionInPixels;
	CGPoint vertices[4] = {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
	
}

#pragma mark CCSprite - CCNode overrides

-(void) addChild:(CCSprite*)child z:(NSInteger)z tag:(NSInteger) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	
	[super addChild:child z:z tag:aTag];
	
	if( usesBatchNode_ ) {
		NSAssert( [child isKindOfClass:[CCSprite class]], @"CCSprite only supports CCSprites as children when using CCSpriteBatchNode");
		NSAssert( child.texture.name == textureAtlas_.texture.name, @"CCSprite is not using the same texture id");
		
		NSUInteger index = [batchNode_ atlasIndexForChild:child atZ:z];
		[batchNode_ insertChild:child inAtlasAtIndex:index];
	}
	
	hasChildren_ = YES;
}

-(void) reorderChild:(CCSprite*)child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	NSAssert( [children_ containsObject:child], @"Child doesn't belong to Sprite" );

	if( z == child.zOrder )
		return;

	if( usesBatchNode_ ) {
		// XXX: Instead of removing/adding, it is more efficient to reorder manually
		[child retain];
		[self removeChild:child cleanup:NO];
		[self addChild:child z:z];
		[child release];
	}

	else
		[super reorderChild:child z:z];
}

-(void)removeChild: (CCSprite *)sprite cleanup:(BOOL)doCleanup
{
	if( usesBatchNode_ )
		[batchNode_ removeSpriteFromAtlas:sprite];

	[super removeChild:sprite cleanup:doCleanup];
	
	hasChildren_ = ( [children_ count] > 0 );
}

-(void)removeAllChildrenWithCleanup:(BOOL)doCleanup
{
	if( usesBatchNode_ ) {
		CCSprite *child;
		CCARRAY_FOREACH(children_, child)
			[batchNode_ removeSpriteFromAtlas:child];
	}
	
	[super removeAllChildrenWithCleanup:doCleanup];
	
	hasChildren_ = NO;
}

//
// CCNode property overloads
// used only when parent is CCSpriteBatchNode
//
#pragma mark CCSprite - property overloads


-(void) setDirtyRecursively:(BOOL)b
{
	dirty_ = recursiveDirty_ = b;
	// recursively set dirty
	if( hasChildren_ ) {
		CCSprite *child;
		CCARRAY_FOREACH(children_, child)
			[child setDirtyRecursively:YES];
	}
}

// XXX HACK: optimization
#define SET_DIRTY_RECURSIVELY() {									\
					if( usesBatchNode_ && ! recursiveDirty_ ) {	\
						dirty_ = recursiveDirty_ = YES;				\
						if( hasChildren_)							\
							[self setDirtyRecursively:YES];			\
						}											\
					}

-(void)setPosition:(CGPoint)pos
{
	[super setPosition:pos];
	SET_DIRTY_RECURSIVELY();
}

-(void)setPositionInPixels:(CGPoint)pos
{
	[super setPositionInPixels:pos];
	SET_DIRTY_RECURSIVELY();
}

-(void)setRotation:(float)rot
{
	[super setRotation:rot];
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

-(void)setIsRelativeAnchorPoint:(BOOL)relative
{
	NSAssert( ! usesBatchNode_, @"relativeTransformAnchor is invalid in CCSprite");
	[super setIsRelativeAnchorPoint:relative];
}

-(void)setVisible:(BOOL)v
{
	[super setVisible:v];
	SET_DIRTY_RECURSIVELY();
}

-(void)setFlipX:(BOOL)b
{
	if( flipX_ != b ) {
		flipX_ = b;
		[self setTextureRectInPixels:rectInPixels_ rotated:rectRotated_ untrimmedSize:contentSizeInPixels_];
	}
}
-(BOOL) flipX
{
	return flipX_;
}

-(void) setFlipY:(BOOL)b
{
	if( flipY_ != b ) {
		flipY_ = b;	
		[self setTextureRectInPixels:rectInPixels_ rotated:rectRotated_ untrimmedSize:contentSizeInPixels_];
	}	
}
-(BOOL) flipY
{
	return flipY_;
}

//
// RGBA protocol
//
#pragma mark CCSprite - RGBA protocol
-(void) updateColor
{
	ccColor4B color4 = {color_.r, color_.g, color_.b, opacity_ };
	
	quad_.bl.colors = color4;
	quad_.br.colors = color4;
	quad_.tl.colors = color4;
	quad_.tr.colors = color4;
	
	// renders using Sprite Manager
	if( usesBatchNode_ ) {
		if( atlasIndex_ != CCSpriteIndexNotInitialized)
			[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
		else
			// no need to set it recursively
			// update dirty_, don't update recursiveDirty_
			dirty_ = YES;
	}
	// self render
	// do nothing
}

-(GLubyte) opacity
{
	return opacity_;
}

-(void) setOpacity:(GLubyte) anOpacity
{
	opacity_			= anOpacity;

	// special opacity for premultiplied textures
	if( opacityModifyRGB_ )
		[self setColor: colorUnmodified_];
	
	[self updateColor];
}

- (ccColor3B) color
{
	if(opacityModifyRGB_)
		return colorUnmodified_;
	
	return color_;
}

-(void) setColor:(ccColor3B)color3
{
	color_ = colorUnmodified_ = color3;
	
	if( opacityModifyRGB_ ){
		color_.r = color3.r * opacity_/255;
		color_.g = color3.g * opacity_/255;
		color_.b = color3.b * opacity_/255;
	}
	
	[self updateColor];
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	ccColor3B oldColor	= self.color;
	opacityModifyRGB_	= modify;
	self.color			= oldColor;
}

-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

//
// Frames
//
#pragma mark CCSprite - Frames

-(void) setDisplayFrame:(CCSpriteFrame*)frame
{
	unflippedOffsetPositionFromCenter_ = frame.offsetInPixels;

	CCTexture2D *newTexture = [frame texture];
	// update texture before updating texture rect
	if ( newTexture.name != texture_.name )
		[self setTexture: newTexture];
	
	// update rect
	rectRotated_ = frame.rotated;
	[self setTextureRectInPixels:frame.rectInPixels rotated:frame.rotated untrimmedSize:frame.originalSizeInPixels];
}

// XXX deprecated
-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex
{
	if( ! animations_ )
		[self initAnimationDictionary];
	
	CCAnimation *a = [animations_ objectForKey: animationName];
	CCSpriteFrame *frame = [[a frames] objectAtIndex:frameIndex];
	
	NSAssert( frame, @"CCSprite#setDisplayFrame. Invalid frame");
	
	[self setDisplayFrame:frame];
}

-(void) setDisplayFrameWithAnimationName: (NSString*) animationName index:(int) frameIndex
{
	NSAssert( animationName, @"CCSprite#setDisplayFrameWithAnimationName. animationName must not be nil");
	
	CCAnimation *a = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
	
	NSAssert( a, @"CCSprite#setDisplayFrameWithAnimationName: Frame not found");
	
	CCSpriteFrame *frame = [[a frames] objectAtIndex:frameIndex];
	
	NSAssert( frame, @"CCSprite#setDisplayFrame. Invalid frame");
	
	[self setDisplayFrame:frame];
}


-(BOOL) isFrameDisplayed:(CCSpriteFrame*)frame 
{
	CGRect r = [frame rect];
	return ( CGRectEqualToRect(r, rect_) &&
			frame.texture.name == self.texture.name );
}

-(CCSpriteFrame*) displayedFrame
{	
	return [CCSpriteFrame frameWithTexture:texture_
							  rectInPixels:rectInPixels_
								   rotated:rectRotated_
									offset:unflippedOffsetPositionFromCenter_
							  originalSize:contentSizeInPixels_];
}

-(void) addAnimation: (CCAnimation*) anim
{
	// lazy alloc
	if( ! animations_ )
		[self initAnimationDictionary];
	
	[animations_ setObject:anim forKey:[anim name]];
}

-(CCAnimation*)animationByName: (NSString*) animationName
{
	NSAssert( animationName != nil, @"animationName parameter must be non nil");
    return [animations_ objectForKey:animationName];
}

#pragma mark CCSprite - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	NSAssert( ! usesBatchNode_, @"CCSprite: updateBlendFunc doesn't work when the sprite is rendered using a CCSpriteBatchNode");

	// it's possible to have an untextured sprite
	if( !texture_ || ! [texture_ hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
		[self setOpacityModifyRGB:NO];
	} else {
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		[self setOpacityModifyRGB:YES];
	}
}

-(void) setTexture:(CCTexture2D*)texture
{
	NSAssert( ! usesBatchNode_, @"CCSprite: setTexture doesn't work when the sprite is rendered using a CCSpriteBatchNode");
	
	// accept texture==nil as argument
	NSAssert( !texture || [texture isKindOfClass:[CCTexture2D class]], @"setTexture expects a CCTexture2D. Invalid argument");

	[texture_ release];
	texture_ = [texture retain];
	
	[self updateBlendFunc];
}

-(CCTexture2D*) texture
{
	return texture_;
}

@end
