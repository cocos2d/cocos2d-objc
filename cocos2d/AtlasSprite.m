/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

#pragma mark -
#pragma mark AltasSprite

@interface AtlasSprite (Private)
-(void)updateTextureCoords;
-(void)updatePosition;
@end

@implementation AtlasSprite

@synthesize dirty;
@synthesize atlasIndex = mAtlasIndex;
@synthesize textureRect = mRect;

+(id)spriteWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager
{
	return [[[self alloc] initWithRect:rect spriteManager:manager] autorelease];
}

-(id)initWithRect:(CGRect)rect spriteManager:(AtlasSpriteManager*)manager
{
	if( (self = [super init])) {
		mAtlas = [manager atlas];	// weak reference. Don't release
		spriteManager = manager;	// weak reference. Dont' release
		
		dirty = YES;

		[self setTextureRect:rect];
	}

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Rect = (%i,%i,%i,%i) | Tag = %i>", [self class], self, (int) mRect.origin.x, (int) mRect.origin.y, (int) mRect.size.width, (int) mRect.size.height, tag];
}

- (void) dealloc
{
	[super dealloc];
}

-(void)setTextureRect:(CGRect) rect
{
	mRect = rect;
	transformAnchor = cpv( mRect.size.width / 2, mRect.size.height /2 );

	[self updateTextureCoords];
	[self updateAtlas];
}

-(void)updateTextureCoords
{
	float atlasWidth = mAtlas.texture.pixelsWide;
	float atlasHeight = mAtlas.texture.pixelsHigh;

	float left = mRect.origin.x / atlasWidth;
	float right = (mRect.origin.x + mRect.size.width) / atlasWidth;
	float top = mRect.origin.y / atlasHeight;
	float bottom = (mRect.origin.y + mRect.size.height) / atlasHeight;

	ccQuad2 newCoords = {
		left, bottom,
		right, bottom,
		left, top,
		right, top,
	};

	mTexCoords = newCoords;
}

-(void)updatePosition
{
	// algorithm from pyglet ( http://www.pyglet.org ) 

	// if not visible
	// then everything is 0
	if( ! visible ) {		
		ccQuad3 newVertices = {
			0,0,0,
			0,0,0,
			0,0,0,
			0,0,0,			
		};
		
		mVertices = newVertices;
	}
	
	// rotation ? -> update: rotation, scale, position
	else if( rotation ) {
		float x1 = -transformAnchor.x * scaleX;
		float y1 = -transformAnchor.y * scaleY;

		float x2 = x1 + mRect.size.width * scaleX;
		float y2 = y1 + mRect.size.height * scaleY;
		float x = position.x;
		float y = position.y;
//		if (relativeTransformAnchor) {
//			x -= transformAnchor.x;
//			y -= transformAnchor.y;
//		}
		
		float r = (float)-CC_DEGREES_TO_RADIANS(rotation);
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

		ccQuad3 newVertices = 
					{ax, ay, 0,
					bx, by, 0,
					dx, dy, 0,
					cx, cy, 0};
		mVertices = newVertices;		
	}
	
	// scale ? -> update: scale, position
	else if(scaleX != 1 || scaleY != 1)
	{
		float x = position.x;
		float y = position.y;
//		if (relativeTransformAnchor) {
//			x -= transformAnchor.x;
//			y -= transformAnchor.y;
//		}
		
		float x1 = (x- transformAnchor.x * scaleX);
		float y1 = (y- transformAnchor.y * scaleY);
		float x2 = (x1 + mRect.size.width * scaleX);
		float y2 = (y1 + mRect.size.height * scaleY);
		ccQuad3 newVertices = {
			x1,y1,0,
			x2,y1,0,
			x1,y2,0,
			x2,y2,0,
		};

		mVertices = newVertices;	
	}
	
	// update position
	else {
		float x = position.x;
		float y = position.y;
//		if (relativeTransformAnchor) {
//			x -= transformAnchor.x;
//			y -= transformAnchor.y;
//		}
		
		float x1 = (x-transformAnchor.x);
		float y1 = (y-transformAnchor.y);
		float x2 = (x1 + mRect.size.width);
		float y2 = (y1 + mRect.size.height);
		ccQuad3 newVertices = {
			x1,y1,0,
			x2,y1,0,
			x1,y2,0,
			x2,y2,0,
		};
		
		mVertices = newVertices;
	}

	[mAtlas updateQuadWithTexture:&mTexCoords vertexQuad:&mVertices atIndex:mAtlasIndex];
	dirty = NO;
	return;
}

-(void)updateAtlas
{
	[mAtlas updateQuadWithTexture:&mTexCoords vertexQuad:&mVertices atIndex:mAtlasIndex];
}

//
// CocosNode property overloads
//
#pragma mark AltasSprite - property overloads
-(void)setPosition:(cpVect)pos
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

-(void)setTransformAnchor:(cpVect)anchor
{
	[super setTransformAnchor:anchor];
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

//
// CocosNodeSize protocol
//
-(CGSize)contentSize
{
	return mRect.size;
}

//
// CocosNodeFrames protocol
//
-(void) setDisplayFrame:(id)newFrame
{
	AtlasSpriteFrame *frame = (AtlasSpriteFrame*)newFrame;
	[self setTextureRect: [frame rect]];
}

-(BOOL) isFrameDisplayed:(id)frame 
{
	AtlasSpriteFrame *spr = (AtlasSpriteFrame*)frame;
	CGRect r = [spr rect];
	return CGRectEqualToRect(r, mRect);
}

-(id) displayFrame
{
	return [AtlasSpriteFrame frameWithRect:mRect];
}
@end


#pragma mark -
#pragma mark AltasAnimation

@implementation AtlasAnimation
@synthesize tag, delay, frames;

+(id) animationWithTag:(int)aTag delay:(float)d frames:rect1,...
{
	va_list args;
	va_start(args,rect1);
	
	id s = [[[self alloc] initWithTag:aTag delay:d firstFrame:rect1 vaList:args] autorelease];
	
	va_end(args);
	return s;
}

+(id) animationWithTag:(int)aTag delay:(float)d
{
	return [[[self alloc] initWithTag:aTag delay:d] autorelease];
}

-(id) initWithTag:(int)t delay:(float)d
{
	return [self initWithTag:t delay:d firstFrame:nil vaList:nil];
}

/** initializes an AtlasAnimation with an AtlasSpriteManager, a tag, and the frames from AtlasSpriteFrames */
-(id) initWithTag:(int)t delay:(float)d firstFrame:(AtlasSpriteFrame*)frame vaList:(va_list)args
{
	if( (self=[super init]) ) {
	
		tag = t;
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

