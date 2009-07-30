/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "AtlasSpriteManager.h"
#import "AtlasSprite.h"
#import "Support/CGPointExtension.h"

#pragma mark -
#pragma mark AltasSprite

#if 1
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL(__A__) ( (int)(__A__))
#endif

enum {
	kIndexNotInitialized = 0xffffffff,
};

@interface AtlasSprite (Private)
-(void)updateTextureCoords;
-(void) initAnimationDictionary;
@end

@implementation AtlasSprite

@synthesize dirty;
@synthesize quad = quad_;
@synthesize atlasIndex = atlasIndex_;
@synthesize textureRect = rect_;
@synthesize opacity=opacity_, color=color_;

+(id)spriteWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager
{
	return [[[self alloc] initWithRect:rect spriteManager:manager] autorelease];
}

-(id)initWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager
{
	if( (self = [super init])) {
		textureAtlas_ = [manager textureAtlas];	// weak reference. Don't release
		
		opacityModifyRGB_ = [[textureAtlas_ texture] hasPremultipliedAlpha];
		
		atlasIndex_ = kIndexNotInitialized;

		dirty = YES;
		
		flipY_ = flipX_ = NO;
		
		// default transform anchor: center
		anchorPoint_ = ccp(0.5f, 0.5f);

		// RGB and opacity
		opacity_ = 255;
		color_ = ccWHITE;
		ccColor4B tmpColor = {255,255,255,255};
		quad_.bl.colors = tmpColor;
		quad_.br.colors = tmpColor;
		quad_.tl.colors = tmpColor;
		quad_.tr.colors = tmpColor;
		
		animations = nil;		// lazy alloc
		
		[self setTextureRect:rect];
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
	[super dealloc];
}

-(void) initAnimationDictionary
{
	animations = [[NSMutableDictionary dictionaryWithCapacity:2] retain];
}

-(void)setTextureRect:(CGRect) rect
{
	rect_ = rect;

	[self updateTextureCoords];
	
	// Don't update Atlas if index == -1. issue #283
	if( atlasIndex_ == kIndexNotInitialized)
		dirty = YES;
	else
		[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];

	if( ! CGSizeEqualToSize(rect.size, contentSize_))  {
		[self setContentSize:rect.size];
		dirty = YES;
	}
}

-(void)updateTextureCoords
{
	float atlasWidth = textureAtlas_.texture.pixelsWide;
	float atlasHeight = textureAtlas_.texture.pixelsHigh;

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

//
// CocosNode property overloads
//
#pragma mark AltasSprite - property overloads
-(void)setPosition:(CGPoint)pos
{
	[super setPosition:pos];
	dirty = YES;
}

-(void)setRotation:(float)rot
{
	[super setRotation:rot];
	dirty = YES;
}

-(void)setScaleX:(float) sx
{
	[super setScaleX:sx];
	dirty = YES;
}

-(void)setScaleY:(float) sy
{
	[super setScaleY:sy];
	dirty = YES;
}

-(void)setScale:(float) s
{
	[super setScale:s];
	dirty = YES;
}

-(void) setVertexZ:(float)z
{
	[super setVertexZ:z];
	dirty = YES;
}

-(void)setAnchorPoint:(CGPoint)anchor
{
	[super setAnchorPoint:anchor];
	dirty = YES;
}

-(void)setRelativeTransformAnchor:(BOOL)relative
{
	CCLOG(@"relativeTransformAnchor is ignored in AtlasSprite");
}

-(void)setVisible:(BOOL)v
{
	[super setVisible:v];
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
// Composition overload
//
-(id) addChild:(CocosNode*)child z:(int)z tag:(int) aTag
{
	NSAssert(NO, @"AtlasSprite can't have children");
	return nil;
}

//
// RGBA protocol
//
#pragma mark AtlasSprite - RGBA protocol
-(void) updateColor
{
	if( atlasIndex_ != kIndexNotInitialized)
		[textureAtlas_ updateQuad:&quad_ atIndex:atlasIndex_];
	else
		dirty = YES;
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

-(void) setRGB: (GLubyte)r :(GLubyte)g :(GLubyte)b
{	
	[self setColor:ccc3(r,g,b)];
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
// CocosNodeFrames protocol
//
#pragma mark AtlasSprite - CocosNodeFrames protocol
-(void) setDisplayFrame:(id)newFrame
{
	AtlasSpriteFrame *frame = (AtlasSpriteFrame*)newFrame;
	CGRect rect = [frame rect];

	[self setTextureRect: rect];	
}

-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex
{
	if( ! animations )
		[self initAnimationDictionary];
	
	AtlasAnimation *a = [animations objectForKey: animationName];
	AtlasSpriteFrame *frame = [[a frames] objectAtIndex:frameIndex];
	
	NSAssert( frame, @"AtlasSprite#setDisplayFrame. Invalid frame");
	CGRect rect = [frame rect];

	[self setTextureRect: rect];
	
}

-(BOOL) isFrameDisplayed:(id)frame 
{
	AtlasSpriteFrame *spr = (AtlasSpriteFrame*)frame;
	CGRect r = [spr rect];
	return CGRectEqualToRect(r, rect_);
}

-(id) displayFrame
{
	return [AtlasSpriteFrame frameWithRect:rect_];
}
// XXX: duplicated code. Sprite.m and AtlasSprite.m share this same piece of code
-(void) addAnimation: (id<CocosAnimation>) anim
{
	// lazy alloc
	if( ! animations )
		[self initAnimationDictionary];
	
	[animations setObject:anim forKey:[anim name]];
}
// XXX: duplicated code. Sprite.m and AtlasSprite.m share this same piece of code
-(id<CocosAnimation>)animationByName: (NSString*) animationName
{
	NSAssert( animationName != nil, @"animationName parameter must be non nil");
    return [animations objectForKey:animationName];
}
@end


#pragma mark -
#pragma mark AltasAnimation

@implementation AtlasAnimation
@synthesize name, delay, frames;

+(id) animationWithName:(NSString*)aname delay:(float)d frames:rect1,...
{
	va_list args;
	va_start(args,rect1);
	
	id s = [[[self alloc] initWithName:aname delay:d firstFrame:rect1 vaList:args] autorelease];
	
	va_end(args);
	return s;
}

+(id) animationWithName:(NSString*)aname delay:(float)d
{
	return [[[self alloc] initWithName:aname delay:d] autorelease];
}

-(id) initWithName:(NSString*)t delay:(float)d
{
	return [self initWithName:t delay:d firstFrame:nil vaList:nil];
}

/* initializes an AtlasAnimation with an AtlasSpriteManager, a name, and the frames from AtlasSpriteFrames */
-(id) initWithName:(NSString*)t delay:(float)d firstFrame:(AtlasSpriteFrame*)frame vaList:(va_list)args
{
	if( (self=[super init]) ) {
	
		name = t;
		frames = [[NSMutableArray array] retain];
		delay = d;
		
		if( frame ) {
			[frames addObject:frame];
			
			AtlasSpriteFrame *frame2 = va_arg(args, AtlasSpriteFrame*);
			while(frame2) {
				[frames addObject:frame2];
				frame2 = va_arg(args, AtlasSpriteFrame*);
			}	
		}
	}
	return self;
}

-(void) dealloc
{
	CCLOG( @"deallocing %@",self);
	[frames release];
	[super dealloc];
}

-(void) addFrameWithRect:(CGRect)rect
{
	AtlasSpriteFrame *frame = [AtlasSpriteFrame frameWithRect:rect];
	[frames addObject:frame];
}
@end

#pragma mark -
#pragma mark AtlasSpriteFrame
@implementation AtlasSpriteFrame
@synthesize rect;

+(id) frameWithRect:(CGRect)frame
{
	return [[[self alloc] initWithRect:(CGRect)frame] autorelease];
}
-(id) initWithRect:(CGRect)frame
{
	if( ([super init]) ) {
		rect = frame;
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Rect = (%.2f,%.2f,%.2f,%.2f)>", [self class], self,
			rect.origin.x,
			rect.origin.y,
			rect.size.width,
			rect.size.height];
}

- (void) dealloc
{
	CCLOG( @"deallocing %@",self);
	[super dealloc];
}
@end

