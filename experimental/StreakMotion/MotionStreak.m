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
 *********************************************************
 *
 * Motion Streak manages a Ribbon based on it's motion in absolute space.
 * You construct it with a fadeTime, minimum segment size, texture path, texture
 * length and color. The fadeTime controls how long it takes each vertex in
 * the streak to fade out, the minimum segment size it how many pixels the
 * streak will move before adding a new ribbon segement, and the texture
 * length is the how many pixels the texture is stretched across. The texture
 * is vertically aligned along the streak segemnts. 
 */

#import "MotionStreak.h"
#import "cocos2d.h"

@implementation MotionStreak

+(id)streakWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(uint)color
{
  self = [[[MotionStreak alloc] initWithFade:(float)fade minSeg:seg image:path width:width length:length color:color] autorelease];
  return self;
}

-(id)initWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(uint)color
{
  self = [super init];
  if (self)
  {
    mFadeTime = fade;
    mSegThreshold = seg;
    mPath = path;
    mWidth = width;
    mTextureLength = length;
    mLastLocation = CGPointZero;
    mColor = color;
    mRibbon = [Ribbon ribbonWithWidth: mWidth image:mPath length:mTextureLength color:color fade:fade];
    [self addChild:mRibbon];
    
    // manually add timer to scheduler
    Timer *timer = [Timer timerWithTarget:self selector:@selector(update:) interval:0];
    [[Scheduler sharedScheduler] scheduleTimer:timer];
  }
  return self;
}

-(void)update:(ccTime)delta
{
	CGPoint location = [self convertToWorldSpace:CGPointZero];
  [mRibbon setPosition:ccp(-1*location.x, -1*location.y)];
  float len = sqrtf(powf(mLastLocation.x - location.x, 2) + powf(mLastLocation.y - location.y, 2));
  if (len > mSegThreshold)
  {
    [mRibbon addPointAt:location width:mWidth];
    mLastLocation = location;
  }
  [mRibbon update:delta];
}


-(void)dealloc
{
  [super dealloc];
}

@end
