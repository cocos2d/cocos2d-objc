/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008, 2009 by Jason Booth
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

#import <Foundation/Foundation.h>
#import "CocosNode.h"
#import "Ribbon.h"

/** Motion Streak - creates a ribbon based on velocity of motion with fading tail */
@interface MotionStreak : CocosNode 
{
  Ribbon* mRibbon;
  float mFadeTime;
  float mSegThreshold;
  uint mColor;
  NSString* mPath;
  float mWidth;
  float mTextureLength;
  CGPoint mLastLocation;
}

/** creates the streak */
+(id)streakWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(uint)color;

/** init the streak */
-(id)initWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(uint)color;

/** polling function */
-(void)update:(ccTime)delta;

@end
