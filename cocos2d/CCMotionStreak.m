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

#import "CCMotionStreak.h"
#import "Support/CGPointExtension.h"

@implementation CCMotionStreak

@synthesize ribbon=ribbon_;

+(id)streakWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(ccColor4B)color
{
	return [[[self alloc] initWithFade:(float)fade minSeg:seg image:path width:width length:length color:color] autorelease];
}

-(id)initWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(ccColor4B)color
{
	if( (self=[super init])) {
		mSegThreshold = seg;
		mWidth = width;
		mLastLocation = CGPointZero;
		ribbon_ = [CCRibbon ribbonWithWidth: mWidth image:path length:length color:color fade:fade];
		[self addChild:ribbon_];

		// update ribbon position
		[self schedule:@selector(update:) interval:0];
	}
	return self;
}

-(void)update:(ccTime)delta
{
	CGPoint location = [self convertToWorldSpace:CGPointZero];
	[ribbon_ setPosition:ccp(-1*location.x, -1*location.y)];
	float len = sqrtf(powf(mLastLocation.x - location.x, 2) + powf(mLastLocation.y - location.y, 2));
	if (len > mSegThreshold)
	{
		[ribbon_ addPointAt:location width:mWidth];
		mLastLocation = location;
	}
	[ribbon_ update:delta];
}


-(void)dealloc
{
	[super dealloc];
}

#pragma mark MotionStreak - CocosNodeTexture protocol

-(void) setTexture:(CCTexture2D*) texture
{
	[ribbon_ setTexture: texture];
}

-(CCTexture2D*) texture
{
	return [ribbon_ texture];
}

-(ccBlendFunc) blendFunc
{
	return [ribbon_ blendFunc];
}

-(void) setBlendFunc:(ccBlendFunc)blendFunc
{
	[ribbon_ setBlendFunc:blendFunc];
}

@end
