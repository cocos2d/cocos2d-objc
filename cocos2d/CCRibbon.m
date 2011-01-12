/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008, 2009 Jason Booth
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
 */

/*
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
		
		segments_ = [[NSMutableArray alloc] init];
		deletedSegments_ = [[NSMutableArray alloc] init];

		/* 1 initial segment */
		CCRibbonSegment* seg = [[CCRibbonSegment alloc] init];
		[segments_ addObject:seg];
		[seg release];
		
		textureLength_ = l;
		
		color_ = color;
		fadeTime_ = fade;
		lastLocation_ = CGPointZero;
		lastWidth_ = w/2;
		texVPos_ = 0.0f;
		
		curTime_ = 0;
		pastFirstPoint_ = NO;
		
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
	[segments_ release];
	[deletedSegments_ release];
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
	curTime_+= delta;
	delta_ = delta;
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
	location.x *= CC_CONTENT_SCALE_FACTOR();
	location.y *= CC_CONTENT_SCALE_FACTOR();

	w = w*0.5f;
	// if this is the first point added, cache it and return
	if (!pastFirstPoint_)
	{
		lastWidth_ = w;
		lastLocation_ = location;
		pastFirstPoint_ = YES;
		return;
	}

	CGPoint sub = ccpSub(lastLocation_, location);
	float r = ccpToAngle(sub) + (float)M_PI_2;
	CGPoint p1 = ccpAdd([self rotatePoint:ccp(-w, 0) rotation:r], location);
	CGPoint p2 = ccpAdd([self rotatePoint:ccp(w, 0) rotation:r], location);
	float len = sqrtf(powf(lastLocation_.x - location.x, 2) + powf(lastLocation_.y - location.y, 2));
	float tend = texVPos_ + len/textureLength_;
	CCRibbonSegment* seg;
	// grab last segment
	seg = [segments_ lastObject];
	// lets kill old segments
	for (CCRibbonSegment* seg2 in segments_)
	{
		if (seg2 != seg && seg2->finished)
		{
			[deletedSegments_ addObject:seg2];
		}
	}
	[segments_ removeObjectsInArray:deletedSegments_];
	// is the segment full?
	if (seg->end >= 50)
		[segments_ removeObjectsInArray:deletedSegments_];
	// grab last segment and append to it if it's not full
	seg = [segments_ lastObject];
	// is the segment full?
	if (seg->end >= 50)
	{
		CCRibbonSegment* newSeg;
		// grab it from the cache if we can
		if ([deletedSegments_ count] > 0)
		{
			newSeg = [deletedSegments_ objectAtIndex:0];
			[newSeg retain];							// will be released later
			[deletedSegments_ removeObject:newSeg];
			[newSeg reset];
		}
		else
		{
			newSeg = [[CCRibbonSegment alloc] init]; // will be released later
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
		[segments_ addObject:seg];
		[newSeg release];	 // it was retained before
		
	}  
	if (seg->end == 0)
	{
		// first edge has to get rotation from the first real polygon
		CGPoint lp1 = ccpAdd([self rotatePoint:ccp(-lastWidth_, 0) rotation:r], lastLocation_);
		CGPoint lp2 = ccpAdd([self rotatePoint:ccp(+lastWidth_, 0) rotation:r], lastLocation_);
		seg->creationTime[0] = curTime_ - delta_;
		seg->verts[0] = lp1.x;
		seg->verts[1] = lp1.y;
		seg->verts[2] = 0.0f;
		seg->verts[3] = lp2.x;
		seg->verts[4] = lp2.y;
		seg->verts[5] = 0.0f;
		seg->coords[0] = 0.0f;
		seg->coords[1] = texVPos_;
		seg->coords[2] = 1.0f;
		seg->coords[3] = texVPos_;
		seg->end++;
	}

	int v = seg->end*6;
	int c = seg->end*4;
	// add new vertex
	seg->creationTime[seg->end] = curTime_;
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

	texVPos_ = tend;
	lastLocation_ = location;
	lastPoint1_ = p1;
	lastPoint2_ = p2;
	lastWidth_ = w;
	seg->end++;
}

-(void) draw
{
	if ([segments_ count] > 0)
	{
		// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
		// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
		// Unneeded states: GL_COLOR_ARRAY
		glDisableClientState(GL_COLOR_ARRAY);
		
		glBindTexture(GL_TEXTURE_2D, [texture_ name]);

		BOOL newBlend = blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST;
		if( newBlend )
			glBlendFunc( blendFunc_.src, blendFunc_.dst );

		for (CCRibbonSegment* seg in segments_)
			[seg draw:curTime_ fadeTime:fadeTime_ color:color_];

		if( newBlend )
			glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
		
		// restore default GL state
		glEnableClientState( GL_COLOR_ARRAY );
	}
}

#pragma mark Ribbon - CocosNodeTexture protocol
-(void) setTexture:(CCTexture2D*) texture
{
	[texture_ release];
	texture_ = [texture retain];
	[self setContentSizeInPixels: texture.contentSizeInPixels];
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
	CCLOGINFO(@"cocos2d: deallocing %@", self);
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
		// the motion streak class will call update and cause time to change, thus, if curTime_ != 0
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

