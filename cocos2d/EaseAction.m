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
 */

#import "EaseAction.h"

//
// EaseAction
//
@implementation EaseAction

+(id) actionWithAction: (IntervalAction*) action
{
	return [[[self alloc] initWithAction: action] autorelease ];
}

-(id) initWithAction: (IntervalAction*) action
{
	NSAssert( action!=nil, @"Ease: arguments must be non-nil");
  
	if( !(self=[super initWithDuration: action.duration]) )
		return nil;
	
	other = [action retain];
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone:zone] initWithAction:[[other copy] autorelease]];
	return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) start
{
	[super start];
	other.target = target;
	[other start];
}

-(void) update: (ccTime) t
{
	[other update: t];
}

-(IntervalAction*) reverse
{
	return [[self class] actionWithAction: [other reverse]];
}
@end


//
// EaseRateAction
//
@implementation EaseRateAction
@synthesize rate;
+(id) actionWithAction: (IntervalAction*) action rate:(float)aRate
{
	return [[[self alloc] initWithAction: action rate:aRate] autorelease ];
}

-(id) initWithAction: (IntervalAction*) action rate:(float)aRate
{
	if( (self=[super initWithAction:action ]) ) {
		self.rate = aRate;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone:zone] initWithAction:[[other copy] autorelease] rate:rate];
	return copy;
}

-(void) dealloc
{
	[super dealloc];
}

-(IntervalAction*) reverse
{
	return [[self class] actionWithAction: [other reverse] rate:1/rate];
}
@end

//
// EeseIn
//
@implementation EaseIn
-(void) update: (ccTime) t
{
	[other update: powf(t,rate)];
}
@end

//
// EaseOut
//
@implementation EaseOut
-(void) update: (ccTime) t
{
	[other update: powf(t,1/rate)];
}
@end

//
// EaseInOut
//
@implementation EaseInOut
-(void) update: (ccTime) t
{	
	int sign =1;
	int r = (int) rate;
	if (r % 2 == 0)
		sign = -1;

	if ((t*=2) < 1) 
		[other update: 0.5f * powf (t, rate)];
	else
		[other update: sign*0.5f * (powf (t-2, rate) + sign*2)];	
}

// InOut and OutIn are symmetrical
-(IntervalAction*) reverse
{
	return [[self class] actionWithAction: [other reverse] rate:rate];
}

@end

//
// EaseExponentialIn
//
@implementation EaseExponentialIn
-(void) update: (ccTime) t
{
	[other update: (t==0) ? 0 : powf(2, 10 * (t/1 - 1)) - 1 * 0.001f];
}
- (IntervalAction*) reverse
{
	return [EaseExponentialOut actionWithAction: [other reverse]];
}
@end

//
// EaseExponentialOut
//
@implementation EaseExponentialOut
-(void) update: (ccTime) t
{
	[other update: (t==1) ? 1 : (-powf(2, -10 * t/1) + 1)];
}
- (IntervalAction*) reverse
{
	return [EaseExponentialIn actionWithAction: [other reverse]];
}
@end

//
// EaseExponentialInOut
//
@implementation EaseExponentialInOut
-(void) update: (ccTime) t
{
	if ((t/=0.5f) < 1)
		t = 0.5f * powf(2, 10 * (t - 1));
	else
		t = 0.5f * (-powf(2, -10 * --t) + 2);
	[other update:t];
}
@end

//
// EaseSineIn
//
@implementation EaseSineIn
-(void) update: (ccTime) t
{
	[other update:-1*cosf(t * (float)M_PI_2) +1];
}
- (IntervalAction*) reverse
{
	return [EaseSineOut actionWithAction: [other reverse]];
}
@end

//
// EaseSineOut
//
@implementation EaseSineOut
-(void) update: (ccTime) t
{
	[other update:sinf(t * (float)M_PI_2)];
}
- (IntervalAction*) reverse
{
	return [EaseSineIn actionWithAction: [other reverse]];
}
@end

//
// EaseSineInOut
//
@implementation EaseSineInOut
-(void) update: (ccTime) t
{
	[other update:-0.5f*(cosf( (float)M_PI*t) - 1)];
}
@end



