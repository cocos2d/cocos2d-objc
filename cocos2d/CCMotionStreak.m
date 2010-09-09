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
 *
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
		segThreshold_ = seg;
		width_ = width;
		lastLocation_ = CGPointZero;
		ribbon_ = [CCRibbon ribbonWithWidth:width_ image:path length:length color:color fade:fade];
		[self addChild:ribbon_];

		// update ribbon position
		[self scheduleUpdate];
	}
	return self;
}

-(void)update:(ccTime)delta
{
	CGPoint location = [self convertToWorldSpace:CGPointZero];
	[ribbon_ setPosition:ccp(-1*location.x, -1*location.y)];
	float len = sqrtf(powf(lastLocation_.x - location.x, 2) + powf(lastLocation_.y - location.y, 2));
	if (len > segThreshold_)
	{
		[ribbon_ addPointAt:location width:width_];
		lastLocation_ = location;
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
