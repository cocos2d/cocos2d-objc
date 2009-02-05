/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * Ribbon Class by Jason Booth
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


#import "Ribbon.h"
#import "TextureMgr.h"
#import "OpenGL_Internal.h"


//
// Ribbon
//
@implementation Ribbon

+(id)ribbonWithWidth:(float)w image:(NSString*)path length:(float)l color:(uint)color fade:(float)fade
{
  self = [[[Ribbon alloc] initWithWidth:w image:path length:l color:color fade:fade] autorelease];
  return self;
}

-(id)initWithWidth:(float)w image:(NSString*)path length:(float)l color:(uint)color fade:(float)fade
{
  self = [super init];
  if (self)
  {
    mTextureLength = l;
    mTexture = [[[TextureMgr sharedTextureMgr] addImage:path] retain];
    mColor = color;
    mFadeTime = fade;
    mLastLocation = cpvzero;
    mLastWidth = w/2;
    mTexVPos = 0.0;
    mSegments = [[[NSMutableArray alloc] init] retain];
    dSegments = [[[NSMutableArray alloc] init] retain];
    RibbonSegment* seg = [[[RibbonSegment alloc] init] autorelease];
    [mSegments addObject:seg];
    mCurTime = 0;
    mPastFirstPoint = NO;
  }
  return self;
}

-(void)dealloc
{
  [mSegments release];
  [dSegments release];
  [mTexture release];
  [super dealloc];
}

// rotates a point around 0, 0
-(cpVect)rotatePoint:(cpVect)vec rotation:(float)a
{
  float xtemp = (vec.x * cos(a)) - (vec.y * sin(a));
  vec.y = (vec.x * sin(a)) + (vec.y * cos(a));
  vec.x = xtemp;
  return vec;
}

-(void)update:(ccTime)delta
{
  mCurTime+= delta;
  mDelta = delta;
}

-(float)sideOfLine:(cpVect)p l1:(cpVect)l1 l2:(cpVect)l2
{
  cpVect vp = cpvperp(cpvsub(l1, l2));
  cpVect vx = cpvsub(p, l1);
  return cpvdot(vx, vp);
}

// adds a new segment to the ribbon
-(void)addPointAt:(cpVect)location width:(float)w
{
  w=w*0.5;
  // if this is the first point added, cache it and return
  if (!mPastFirstPoint)
  {
    mLastWidth = w;
    mLastLocation = location;
    mPastFirstPoint = YES;
    return;
  }
  
  cpVect sub = cpvsub(mLastLocation, location);
  float r = cpvtoangle(sub) + 1.57079637;
  cpVect p1 = cpvadd([self rotatePoint:cpv(-w, 0) rotation:r], location);
  cpVect p2 = cpvadd([self rotatePoint:cpv(w, 0) rotation:r], location);
  float len = sqrt(pow(mLastLocation.x - location.x, 2) + pow(mLastLocation.y - location.y, 2));
  float tend = mTexVPos + len/mTextureLength;
  RibbonSegment* seg;
  // first lets kill old segments
  for (seg in mSegments)
  {
    if (seg->finished)
    {
      [dSegments addObject:seg];
    }
  }
  [mSegments removeObjectsInArray:dSegments];
  // grab last segment and appent to it if it's not full
  seg = [mSegments objectAtIndex:[mSegments count]-1];
  // is the segment full?
  if (seg->end >= 50)
  {
    // grab it from the cache if we can
    if ([dSegments count] > 0)
    {
      seg = [dSegments objectAtIndex:0];
      [dSegments removeObject:seg];
      [seg reset];
    }
    else
      seg = [[[RibbonSegment alloc] init] autorelease];
    [mSegments addObject:seg];
  }
  if (seg->end == 0)
  {
    // first edge has to get rotation from the first real polygon
    cpVect lp1 = cpvadd([self rotatePoint:cpv(-mLastWidth, 0) rotation:r], mLastLocation);
    cpVect lp2 = cpvadd([self rotatePoint:cpv(+mLastWidth, 0) rotation:r], mLastLocation);
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

-(void)draw
{
  if ([mSegments count] > 0)
  {
    glEnableClientState( GL_VERTEX_ARRAY);
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    glEnable( GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, [mTexture name]);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );

    GLubyte r = mColor >> 24 & 0xFF;
    GLubyte g = mColor >> 16 & 0xFF;
    GLubyte b = mColor >> 8 & 0xFF;
    GLubyte a = mColor & 0xFF;
    
    for (RibbonSegment* seg in mSegments)
    {
      [seg draw:mCurTime fadeTime:mFadeTime r:r g:g b:b a:a];
    }    
    glDisable( GL_TEXTURE_2D);
    glDisableClientState( GL_VERTEX_ARRAY );
    glDisableClientState( GL_TEXTURE_COORD_ARRAY );
    glDisableClientState( GL_COLOR_ARRAY );
  }
}

@end

@implementation RibbonSegment

-(id)init
{
  self = [super init];
  if (self)
  {
    [self reset];
  }
  return self;
}

-(void)reset
{
  end = 0;
  begin = 0;
  finished = NO;
}

-(void)draw:(float)curTime fadeTime:(float)fadeTime r:(GLubyte)r g:(GLubyte)g b:(GLubyte)b a:(GLubyte)a
{
  if (begin < 50)
  {
    // the motion streak class will call update and cause time to change, thus, if mCurTime != 0
    // we have to generate alpha for the ribbon each frame.
    if (curTime == 0)
    {
      // no alpha over time, so just set the color
      glColor4ub(r, g, b, a); 
    }
    else
    {
      // generate alpha/color for each point
      glEnableClientState(GL_COLOR_ARRAY);
      int i = begin;
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

