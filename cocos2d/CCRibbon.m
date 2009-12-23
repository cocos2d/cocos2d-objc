/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008, 2009 Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 *
 *
 * A ribbon is a dynamically generated list of polygons drawn as a single or series
 * of triangle strips. The primary use of Ribbon is as the drawing class of Motion Streak,
 * but it is quite useful on it's own. When manually drawing a ribbon, you can call addPointAt
 * and pass in the parameters for the next location in the ribbon. The system will automatically
 * generate new polygons, texture them accourding to your texture width, etc, etc.
 *
 * Ribbon data is stored in a RibbonSegment class. This class statically allocates enough verticies and
 * texture coordinates for 50 locations (100 verts or 48 triangles). The ribbon class will allocate
 * new segments when they are needed, and reuse old ones if available. The idea is to avoid constantly
 * allocating new memory and prefer a more static method. However, since there is no way to determine
 * the maximum size of some ribbons (motion streaks), a truely static allocation is not possible.
 *
 */


#import "CCRibbon.h"
#import "CCTextureCache.h"
#import "Support/CGPointExtension.h"
#import "ccMacros.h"

//
// Ribbon
//
@implementation CCRibbon
@synthesize blendFunc=blendFunc_;
@synthesize color=color_;
@synthesize textureLength = textureLength_;

+(id)ribbonWithWidth:(float)w image:(NSString*)path length:(float)l color:(ccColor4B)color fade:(float)fade
{
	self = [[[self alloc] initWithWidth:w image:path length:l color:color fade:fade] autorelease];
	return self;
}

-(id)initWithWidth:(float)w image:(NSString*)path length:(float)l color:(ccColor4B)color fade:(float)fade
{
	self = [super init];
	if (self)
	{
		
		mSegments = [[NSMutableArray alloc] init];
		dSegments = [[NSMutableArray alloc] init];

		/* 1 initial segment */
		CCRibbonSegment* seg = [[[CCRibbonSegment alloc] init] autorelease];
		[mSegments addObject:seg];
		
		textureLength_ = l;
		
		color_ = color;
		mFadeTime = fade;
		mLastLocation = CGPointZero;
		mLastWidth = w/2;
		mTexVPos = 0.0f;
		
		mCurTime = 0;
		mPastFirstPoint = NO;
		
		/* XXX:
		 Ribbon, by default uses this blend function, which might not be correct
		 if you are using premultiplied alpha images,
		 but 99% you might want to use this blending function regarding of the texture
		 */
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage:path];

		/* default texture parameter */
		ccTexParams params = { GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT };
		[texture_ setTexParameters:&params];
	}
	return self;
}

-(void)dealloc
{
	[mSegments release];
	[dSegments release];
	[texture_ release];
	[super dealloc];
}

// rotates a point around 0, 0
-(CGPoint)rotatePoint:(CGPoint)vec rotation:(float)a
{
	float xtemp = (vec.x * cosf(a)) - (vec.y * sinf(a));
	vec.y = (vec.x * sinf(a)) + (vec.y * cosf(a));
	vec.x = xtemp;
	return vec;
}

-(void)update:(ccTime)delta
{
	mCurTime+= delta;
	mDelta = delta;
}

-(float)sideOfLine:(CGPoint)p l1:(CGPoint)l1 l2:(CGPoint)l2
{
	CGPoint vp = ccpPerp(ccpSub(l1, l2));
	CGPoint vx = ccpSub(p, l1);
	return ccpDot(vx, vp);
}

// adds a new segment to the ribbon
-(void)addPointAt:(CGPoint)location width:(float)w
{
	w=w*0.5f;
	// if this is the first point added, cache it and return
	if (!mPastFirstPoint)
	{
		mLastWidth = w;
		mLastLocation = location;
		mPastFirstPoint = YES;
		return;
	}

	CGPoint sub = ccpSub(mLastLocation, location);
	float r = ccpToAngle(sub) + (float)M_PI_2;
	CGPoint p1 = ccpAdd([self rotatePoint:ccp(-w, 0) rotation:r], location);
	CGPoint p2 = ccpAdd([self rotatePoint:ccp(w, 0) rotation:r], location);
	float len = sqrtf(powf(mLastLocation.x - location.x, 2) + powf(mLastLocation.y - location.y, 2));
	float tend = mTexVPos + len/textureLength_;
	CCRibbonSegment* seg;
	// grab last segment
	seg = [mSegments objectAtIndex:[mSegments count]-1];
	// lets kill old segments
	for (CCRibbonSegment* seg2 in mSegments)
	{
		if (seg2 != seg && seg2->finished)
		{
			[dSegments addObject:seg2];
		}
	}
	[mSegments removeObjectsInArray:dSegments];
	// is the segment full?
	if (seg->end >= 50)
		[mSegments removeObjectsInArray:dSegments];
	// grab last segment and appent to it if it's not full
	seg = [mSegments objectAtIndex:[mSegments count]-1];
	// is the segment full?
	if (seg->end >= 50)
	{
		CCRibbonSegment* newSeg;
		// grab it from the cache if we can
		if ([dSegments count] > 0)
		{
			newSeg = [dSegments objectAtIndex:0];
			[dSegments removeObject:newSeg];
			[newSeg reset];
		}
		else
		{
			newSeg = [[[CCRibbonSegment alloc] init] autorelease];
		}
		
		newSeg->creationTime[0] = seg->creationTime[seg->end - 1];
		int v = (seg->end-1)*6;
		int c = (seg->end-1)*4;	
		newSeg->verts[0] = seg->verts[v];
		newSeg->verts[1] = seg->verts[v+1];
		newSeg->verts[2] = seg->verts[v+2];
		newSeg->verts[3] = seg->verts[v+3];
		newSeg->verts[4] = seg->verts[v+4];
		newSeg->verts[5] = seg->verts[v+5];
		
		newSeg->coords[0] = seg->coords[c];
		newSeg->coords[1] = seg->coords[c+1];
		newSeg->coords[2] = seg->coords[c+2];
		newSeg->coords[3] = seg->coords[c+3];	  
		newSeg->end++;
		seg = newSeg;
		[mSegments addObject:seg];
	}  
	if (seg->end == 0)
	{
		// first edge has to get rotation from the first real polygon
		CGPoint lp1 = ccpAdd([self rotatePoint:ccp(-mLastWidth, 0) rotation:r], mLastLocation);
		CGPoint lp2 = ccpAdd([self rotatePoint:ccp(+mLastWidth, 0) rotation:r], mLastLocation);
		seg->creationTime[0] = mCurTime - mDelta;
		seg->verts[0] = lp1.x;
		seg->verts[1] = lp1.y;
		seg->verts[2] = 0.0f;
		seg->verts[3] = lp2.x;
		seg->verts[4] = lp2.y;
		seg->verts[5] = 0.0f;
		seg->coords[0] = 0.0f;
		seg->coords[1] = mTexVPos;
		seg->coords[2] = 1.0f;
		seg->coords[3] = mTexVPos;
		seg->end++;
	}

	int v = seg->end*6;
	int c = seg->end*4;
	// add new vertex
	seg->creationTime[seg->end] = mCurTime;
	seg->verts[v] = p1.x;
	seg->verts[v+1] = p1.y;
	seg->verts[v+2] = 0.0f;
	seg->verts[v+3] = p2.x;
	seg->verts[v+4] = p2.y;
	seg->verts[v+5] = 0.0f;


	seg->coords[c] = 0.0f;
	seg->coords[c+1] = tend;
	seg->coords[c+2] = 1.0f;
	seg->coords[c+3] = tend;

	mTexVPos = tend;
	mLastLocation = location;
	mLastPoint1 = p1;
	mLastPoint2 = p2;
	mLastWidth = w;
	seg->end++;
}

-(void) draw
{
	if ([mSegments count] > 0)
	{
		glEnableClientState( GL_VERTEX_ARRAY);
		glEnableClientState( GL_TEXTURE_COORD_ARRAY );
		glEnable( GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, [texture_ name]);

		BOOL newBlend = NO;
		if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
			newBlend = YES;
			glBlendFunc( blendFunc_.src, blendFunc_.dst );
		}

		for (CCRibbonSegment* seg in mSegments)
			[seg draw:mCurTime fadeTime:mFadeTime color:color_];

		if( newBlend )
			glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	  
		glDisable( GL_TEXTURE_2D);
		glDisableClientState( GL_VERTEX_ARRAY );
		glDisableClientState( GL_TEXTURE_COORD_ARRAY );
		glDisableClientState( GL_COLOR_ARRAY );
	}
}

#pragma mark Ribbon - CocosNodeTexture protocol
-(void) setTexture:(CCTexture2D*) texture
{
	[texture_ release];
	texture_ = [texture retain];
	[self setContentSize: texture.contentSize];
	/* XXX Don't update blending function in Ribbons */
}

-(CCTexture2D*) texture
{
	return texture_;
}

@end


#pragma mark -
#pragma mark RibbonSegment

@implementation CCRibbonSegment

-(id)init
{
	self = [super init];
	if (self)
	{
		[self reset];
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | end = %i, begin = %i>", [self class], self, end, begin];
}

- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

-(void)reset
{
	end = 0;
	begin = 0;
	finished = NO;
}

-(void)draw:(float)curTime fadeTime:(float)fadeTime color:(ccColor4B)color
{
	GLubyte r = color.r;
	GLubyte g = color.g;
	GLubyte b = color.b;
	GLubyte a = color.a;

	if (begin < 50)
	{
		// the motion streak class will call update and cause time to change, thus, if mCurTime != 0
		// we have to generate alpha for the ribbon each frame.
		if (curTime == 0)
		{
			// no alpha over time, so just set the color
			glColor4ub(r,g,b,a);
		}
		else
		{
			// generate alpha/color for each point
			glEnableClientState(GL_COLOR_ARRAY);
			uint i = begin;
			for (; i < end; ++i)
			{
				int idx = i*8;
				colors[idx] = r;
				colors[idx+1] = g;
				colors[idx+2] = b;
				colors[idx+4] = r;
				colors[idx+5] = g;
				colors[idx+6] = b;
				float alive = ((curTime - creationTime[i]) / fadeTime);
				if (alive > 1)
				{
					begin++;
					colors[idx+3] = 0;
					colors[idx+7] = 0;
				}
				else
				{
					colors[idx+3] = (GLubyte)(255.f - (alive * 255.f));
					colors[idx+7] = colors[idx+3];
				}
			}
			glColorPointer(4, GL_UNSIGNED_BYTE, 0, &colors[begin*8]);
		}
		glVertexPointer(3, GL_FLOAT, 0, &verts[begin*6]);
		glTexCoordPointer(2, GL_FLOAT, 0, &coords[begin*4]);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, (end - begin) * 2);
	}
	else
		finished = YES;
}
@end

