/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "ccConfig.h"
#import "CCSpriteSheet.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCTextureCache.h"
#import "Support/CGPointExtension.h"
#import "CCDrawingPrimitives.h"

#pragma mark -
#pragma mark CCSprite

#if CC_ATLAS_SPRITE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL(__A__) ( (int)(__A__))
#endif


@interface CCSprite (Private)
-(void)updateTextureCoords;
-(void)updateBlendFunc;
-(void) initAnimationDictionary;
@end

@implementation CCSprite

@synthesize dirty;
@synthesize quad = quad_;
@synthesize atlasIndex = atlasIndex_;
@synthesize textureRect = rect_;
@synthesize opacity=opacity_, color=color_;
@synthesize blendFunc = blendFunc_;
@synthesize parentIsSpriteSheet = parentIsSpriteSheet_;
@synthesize textureAtlas = textureAtlas_;


+(id)spriteWithTexture:(CCTexture2D*)texture
{
	return [[[self alloc] initWithTexture:texture] autorelease];
}

+(id)spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	return [[[self alloc] initWithTexture:texture rect:rect] autorelease];
}

+(id)spriteWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset
{
	return [[[self alloc] initWithTexture:texture rect:rect offset:offset] autorelease];
}

+(id)spriteWithFile:(NSString*)filename
{
	return [[[self alloc] initWithFile:filename] autorelease];
}

+(id)spriteWithFile:(NSString*)filename rect:(CGRect)rect
{
	return [[[self alloc] initWithFile:filename rect:rect] autorelease];
}

+(id)spriteWithFile:(NSString*)filename rect:(CGRect)rect offset:(CGPoint)offset
{
	return [[[self alloc] initWithFile:filename rect:rect offset:offset] autorelease];
}

+(id)spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
	return [[[self alloc] initWithSpriteFrame:spriteFrame] autorelease];
}

+(id)spriteWithCGImage:(CGImageRef)image
{
	return [[[self alloc] initWithCGImage:image] autorelease];
}

-(id) initWithTexture:(CCTexture2D*)texture
{
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	return [self initWithTexture:texture rect:rect offset:CGPointZero];
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	return [self initWithTexture:texture rect:rect offset:CGPointZero];
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset
{
	if( (self = [super init]) )
	{
		
		// by default sprites are self-rendered
		parentIsSpriteSheet_ = NO;

		// Stuff in case the Sprite is self-rendered
		selfRenderTextureAtlas_ = [[CCTextureAtlas textureAtlasWithTexture:texture capacity:1] retain];
		
		// Stuff in case the Sprite is rendered using an Sprite Manager
		textureAtlas_ = nil;
		atlasIndex_ = CCSpriteIndexNotInitialized;
		dirty = YES;
		
		// update texture
		[self setTexture:texture];
				
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		[self updateBlendFunc];
		
		// clean the Quad
		bzero(&quad_, sizeof(quad_));
		
		flipY_ = flipX_ = NO;

		// lazy alloc
		animations = nil;

		// default transform anchor: center
		anchorPoint_ = ccp( (-offset.x / rect.size.width) + 0.5f,
						   (-offset.y / rect.size.height) + 0.5f );

//		anchorPoint_ = ccp(0.5f, 0.5f);
		
		// Atlas: Color
		opacity_ = 255;
		color_ = ccWHITE;
		ccColor4B tmpColor = {255,255,255,255};
		quad_.bl.colors = tmpColor;
		quad_.br.colors = tmpColor;
		quad_.tl.colors = tmpColor;
		quad_.tr.colors = tmpColor;	
		
		// Atlas: Vertex
		float x1 = 0;
		float y1 = 0;
		float x2 = x1 + rect.size.width;
		float y2 = y1 + rect.size.height;		
		quad_.bl.vertices = (ccVertex3F) { x1, y1, 0 };
		quad_.br.vertices = (ccVertex3F) { x2, y1, 0 };
		quad_.tl.vertices = (ccVertex3F) { x1, y2, 0 };
		quad_.tr.vertices = (ccVertex3F) { x2, y2, 0 };		
		
		// Atlas: TexCoords
		[self setTextureRect:rect];		
	}
	return self;
}

-(id) initWithFile:(NSString*)filename
{
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	return [self initWithTexture:texture rect:rect offset:CGPointZero];
}

-(id) initWithFile:(NSString*)filename rect:(CGRect)rect
{
	return [self initWithFile:filename rect:rect offset:CGPointZero];
}

-(id) initWithFile:(NSString*)filename rect:(CGRect)rect offset:(CGPoint)offset
{
	if( (self = [super init]) ) {
		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
		
		[self initWithTexture:texture rect:rect offset:offset];
	}
	return self;
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
	return [self initWithTexture:spriteFrame.texture rect:spriteFrame.rect offset:spriteFrame.offset];
}

- (id) initWithCGImage: (CGImageRef)image
{
	if( (self = [super init]) ) {
		// XXX: possible bug. See issue #349. New API should be added
		NSString *key = [NSString stringWithFormat:@"%08X",(unsigned long)image];
		CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addCGImage:image forKey:key];
		
		CGSize size = texture.contentSize;
		CGRect rect = CGRectMake(0, 0, size.width, size.height );
		
		[self initWithTexture:texture rect:rect];
		 
	}
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Rect = (%.2f,%.2f,%.2f,%.2f) | tag = %i>", [self class], self, rect_.origin.x, rect_.origin.y, rect_.size.width, rect_.size.height, tag];
}

- (void) dealloc
{
	[animations release];
	[selfRenderTextureAtlas_ release];
	[super dealloc];
}

-(void) initAnimationDictionary
{
	animations = [[NSMutableDictionary dictionaryWithCapacity:2] retain];
}

-(void)setTextureRect:(CGRect) rect
{
	BOOL updateVertex = NO;

	if( (rect.size.width != rect_.size.width) || (rect.size.height != rect_.size.height) )
		updateVertex = YES;
		
	rect_ = rect;

	[self updateTextureCoords];
	
	// rendering using SpriteSheet
	if( parentIsSpriteSheet_ ) {
		// Don't update Atlas if index == CCSpriteIndexNotInitialized. issue #283
		if( atlasIndex_ == CCSpriteIndexNotInitialized)
			dirty = YES;
		else
			[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];

		if( ! CGSizeEqualToSize(rect.size, contentSize_))  {
			[self setContentSize:rect.size];
			dirty = YES;
		}
	}
	// self rendering
	else
	{
		if( updateVertex ) {
			// Atlas: Vertex
			float x1 = 0;
			float y1 = 0;
			float x2 = x1 + rect.size.width;
			float y2 = y1 + rect.size.height;		
			quad_.bl.vertices = (ccVertex3F) { x1, y1, 0 };
			quad_.br.vertices = (ccVertex3F) { x2, y1, 0 };
			quad_.tl.vertices = (ccVertex3F) { x1, y2, 0 };
			quad_.tr.vertices = (ccVertex3F) { x2, y2, 0 };			
		}
		
		[selfRenderTextureAtlas_ updateQuad:&quad_ atIndex:0];
		if( ! CGSizeEqualToSize(rect.size, contentSize_))  {
			[self setContentSize:rect.size];
		}		
	}
}

-(void)updateTextureCoords
{
	
	float atlasWidth = texture_.pixelsWide;
	float atlasHeight = texture_.pixelsHigh;

	float left = rect_.origin.x / atlasWidth;
	float right = (rect_.origin.x + rect_.size.width) / atlasWidth;
	float top = rect_.origin.y / atlasHeight;
	float bottom = (rect_.origin.y + rect_.size.height) / atlasHeight;

	
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

-(void)updatePosition
{
	NSAssert( parentIsSpriteSheet_, @"updatePosition is only valid when CCSprite is using a CCSpriteSheet as parent");

	// algorithm from pyglet ( http://www.pyglet.org ) 

	// if not visible
	// then everything is 0
	if( ! visible ) {		
		quad_.br.vertices = quad_.tl.vertices = quad_.tr.vertices = quad_.bl.vertices = (ccVertex3F){0,0,0};

	}
	
	// rotation ? -> update: rotation, scale, position
	else if( rotation_ ) {
		float x1 = -transformAnchor_.x * scaleX_;
		float y1 = -transformAnchor_.y * scaleY_;

		float x2 = x1 + rect_.size.width * scaleX_;
		float y2 = y1 + rect_.size.height * scaleY_;
		float x = position_.x;
		float y = position_.y;
		
		float r = -CC_DEGREES_TO_RADIANS(rotation_);
		float cr = cosf(r);
		float sr = sinf(r);
		float ax = x1 * cr - y1 * sr + x;
		float ay = x1 * sr + y1 * cr + y;
		float bx = x2 * cr - y1 * sr + x;
		float by = x2 * sr + y1 * cr + y;
		float cx = x2 * cr - y2 * sr + x;
		float cy = x2 * sr + y2 * cr + y;
		float dx = x1 * cr - y2 * sr + x;
		float dy = x1 * sr + y2 * cr + y;
		quad_.bl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(ax), RENDER_IN_SUBPIXEL(ay), vertexZ_ };
		quad_.br.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(bx), RENDER_IN_SUBPIXEL(by), vertexZ_ };
		quad_.tl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(dx), RENDER_IN_SUBPIXEL(dy), vertexZ_ };
		quad_.tr.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(cx), RENDER_IN_SUBPIXEL(cy), vertexZ_ };
		
	}
	
	// scale ? -> update: scale, position
	else if(scaleX_ != 1 || scaleY_ != 1)
	{
		float x = position_.x;
		float y = position_.y;
		
		float x1 = (x- transformAnchor_.x * scaleX_);
		float y1 = (y- transformAnchor_.y * scaleY_);
		float x2 = (x1 + rect_.size.width * scaleX_);
		float y2 = (y1 + rect_.size.height * scaleY_);

		quad_.bl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(x1), RENDER_IN_SUBPIXEL(y1), vertexZ_ };
		quad_.br.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(x2), RENDER_IN_SUBPIXEL(y1), vertexZ_ };
		quad_.tl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(x1), RENDER_IN_SUBPIXEL(y2), vertexZ_ };
		quad_.tr.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(x2), RENDER_IN_SUBPIXEL(y2), vertexZ_ };
		
	}
	
	// update position
	else {
		float x = position_.x;
		float y = position_.y;
		
		float x1 = (x-transformAnchor_.x);
		float y1 = (y-transformAnchor_.y);
		float x2 = (x1 + rect_.size.width);
		float y2 = (y1 + rect_.size.height);

		quad_.bl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(x1), RENDER_IN_SUBPIXEL(y1), vertexZ_ };
		quad_.br.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(x2), RENDER_IN_SUBPIXEL(y1), vertexZ_ };
		quad_.tl.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(x1), RENDER_IN_SUBPIXEL(y2), vertexZ_ };
		quad_.tr.vertices = (ccVertex3F) { RENDER_IN_SUBPIXEL(x2), RENDER_IN_SUBPIXEL(y2), vertexZ_ };
		
	}
	
	[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
	dirty = NO;
	return;
}

-(void)insertInAtlasAtIndex:(NSUInteger)index
{
	atlasIndex_ = index;
	[textureAtlas_ insertQuad:&quad_ atIndex:atlasIndex_];
}


#pragma mark CCSprite - draw

-(void) draw
{	
	NSAssert(!parentIsSpriteSheet_, @"CCSprite can't be dirty when it's parent is not an CCSpriteSheet");

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	BOOL newBlend = NO;
	if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
		newBlend = YES;
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	}
	
	[selfRenderTextureAtlas_ drawNumberOfQuads:1];

	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);	
}

//
// CCNode property overloads
// used only when parent is CCSpriteSheet
//
#pragma mark CCSprite - property overloads
-(void)setPosition:(CGPoint)pos
{
	[super setPosition:pos];
	if( parentIsSpriteSheet_ )
		dirty = YES;
}

-(void)setRotation:(float)rot
{
	[super setRotation:rot];
	if( parentIsSpriteSheet_ )
		dirty = YES;
}

-(void)setScaleX:(float) sx
{
	[super setScaleX:sx];
	if( parentIsSpriteSheet_ )
		dirty = YES;
}

-(void)setScaleY:(float) sy
{
	[super setScaleY:sy];
	if( parentIsSpriteSheet_ )
		dirty = YES;
}

-(void)setScale:(float) s
{
	[super setScale:s];
	if( parentIsSpriteSheet_ )
		dirty = YES;
}

-(void) setVertexZ:(float)z
{
	[super setVertexZ:z];
	if( parentIsSpriteSheet_ )
		dirty = YES;
}

-(void)setAnchorPoint:(CGPoint)anchor
{
	[super setAnchorPoint:anchor];
	if( parentIsSpriteSheet_ )
		dirty = YES;
}

-(void)setRelativeAnchorPoint:(BOOL)relative
{
	NSAssert( ! parentIsSpriteSheet_, @"relativeTransformAnchor is invalid in CCSprite");
	[super setRelativeAnchorPoint:relative];
}

-(void)setVisible:(BOOL)v
{
	[super setVisible:v];
	if( parentIsSpriteSheet_ )
		dirty = YES;
}

-(void)setFlipX:(BOOL)b
{
	if( flipX_ != b ) {
		flipX_ = b;
		[self setTextureRect:rect_];
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
		[self setTextureRect:rect_];
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
	// renders using Sprite Manager
	if( parentIsSpriteSheet_ ) {
		if( atlasIndex_ != CCSpriteIndexNotInitialized)
			[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
		else
			dirty = YES;
	}
	// self render
	else
	{
		[selfRenderTextureAtlas_ updateQuad:&quad_ atIndex:0];
	}
}

-(void) setOpacity:(GLubyte) anOpacity
{
	opacity_ = anOpacity;
	
	// special opacity for premultiplied textures
	if( opacityModifyRGB_ )
		color_.r = color_.g = color_.b = opacity_;

	ccColor4B color4 = {color_.r, color_.g, color_.b, opacity_ };

	quad_.bl.colors = color4;
	quad_.br.colors = color4;
	quad_.tl.colors = color4;
	quad_.tr.colors = color4;

	[self updateColor];
}

-(void) setColor:(ccColor3B)color3
{
	color_ = color3;
	
	ccColor4B color4 = {color_.r, color_.g, color_.b, opacity_ };
	quad_.bl.colors = color4;
	quad_.br.colors = color4;
	quad_.tl.colors = color4;
	quad_.tr.colors = color4;
	
	[self updateColor];
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_ = modify;
}

-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

//
// CCFrameProtocol protocol
//
#pragma mark CCSprite - CCFrameProtocol protocol
-(void) setDisplayFrame:(id)newFrame
{
	CCSpriteFrame *frame = (CCSpriteFrame*)newFrame;

	// update anchor point
	anchorPoint_ = ccp( (- frame.offset.x / frame.rect.size.width) + 0.5f,
					   ( - frame.offset.y / frame.rect.size.height) + 0.5f );
	
	// update rect
	CGRect rect = [frame rect];
	[self setTextureRect: rect];	

	// update texture
	if ( frame.texture.name != self.texture.name )
		[self setTexture: frame.texture];
}

-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex
{
	if( ! animations )
		[self initAnimationDictionary];
	
	CCAnimation *a = [animations objectForKey: animationName];
	CCSpriteFrame *frame = [[a frames] objectAtIndex:frameIndex];
	
	NSAssert( frame, @"CCSprite#setDisplayFrame. Invalid frame");
	
	[self setDisplayFrame:frame];
}

-(BOOL) isFrameDisplayed:(id)frame 
{
	CCSpriteFrame *spr = (CCSpriteFrame*)frame;
	CGRect r = [spr rect];
	return ( CGRectEqualToRect(r, rect_) &&
			spr.texture.name == self.texture.name);
}

-(id) displayFrame
{
	return [CCSpriteFrame frameWithTexture:self.texture rect:rect_ offset:CGPointZero];
}

-(void) addAnimation: (id<CCAnimationProtocol>) anim
{
	// lazy alloc
	if( ! animations )
		[self initAnimationDictionary];
	
	[animations setObject:anim forKey:[anim name]];
}

-(id<CCAnimationProtocol>)animationByName: (NSString*) animationName
{
	NSAssert( animationName != nil, @"animationName parameter must be non nil");
    return [animations objectForKey:animationName];
}

#pragma mark CCSprite - CocosNodeTexture protocol

-(void) updateBlendFunc
{
	NSAssert( ! parentIsSpriteSheet_, @"CCSprite: updateBlendFunc doesn't work when the sprite is rendered using a CCSprite manager");

	if( ! [texture_ hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	}
	
	opacityModifyRGB_ = [texture_ hasPremultipliedAlpha];
}

-(void) setTexture:(CCTexture2D*)texture
{
	NSAssert( ! parentIsSpriteSheet_, @"CCSprite: updateBlendFunc doesn't work when the sprite is rendered using a CCSprite manager");

	selfRenderTextureAtlas_.texture = texture;
	[self updateBlendFunc];
	
	texture_ = texture;
}

-(CCTexture2D*) texture
{
	return texture_;
}

@end
