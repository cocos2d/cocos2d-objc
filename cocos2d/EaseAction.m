/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * EaseAction by Jason Booth
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
// EaseExponentialIn
//
@implementation EaseExponentialIn
-(void) update: (ccTime) t
{
	[other update: (t==0) ? 0 : pow(2, 10 * (t/1 - 1)) - 1 * 0.001];
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
	[other update: (t==1) ? 1 : (-pow(2, -10 * t/1) + 1)];
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
  if (t==0) t = 0;
  if (t==1) t = 1;
  else if ((t/=0.5) < 1)
    t = 0.5 * pow(2, 10 * (t - 1));
  else
    t = 0.5 * (-pow(2, -10 * --t) + 2);
  [other update:t];
}
@end


//
// EaseCubicIn
//
@implementation EaseCubicIn
-(void) update: (ccTime) t
{
	[other update: t*t];
}
- (IntervalAction*) reverse
{
	return [EaseCubicOut actionWithAction: [other reverse]];
}
@end

//
// EaseCubicOut
//
@implementation EaseCubicOut
-(void) update: (ccTime) t
{
	[other update: -1 * t * (t-2)];
}
- (IntervalAction*) reverse
{
	return [EaseCubicIn actionWithAction: [other reverse]];
}

@end

//
// EaseCubicInOut
//
@implementation EaseCubicInOut
-(void) update: (ccTime) t
{
  if ((t/=0.5) < 1) [other update: 0.5*t*t];
  else [other update: -0.5 * ((--t)*(t-2) - 1)];
}
@end


//
// EaseQuadIn
//
@implementation EaseQuadIn
-(void) update: (ccTime) t
{
	[other update: t*t];
}
- (IntervalAction*) reverse
{
	return [EaseQuadOut actionWithAction: [other reverse]];
}
@end

//
// EaseQuadOut
//
@implementation EaseQuadOut
-(void) update: (ccTime) t
{
	[other update: -1*t*(t-2)];
}
- (IntervalAction*) reverse
{
	return [EaseQuadIn actionWithAction: [other reverse]];
}
@end

//
// EaseQuadInOut
//
@implementation EaseQuadInOut
-(void) update: (ccTime) t
{
  if ((t/=0.5) < 1) [other update:(0.5*t*t)];
  else [other update:-0.5*((--t)*(t-2)-1)];
}
@end

//
// EaseSineIn
//
@implementation EaseSineIn
-(void) update: (ccTime) t
{
  [other update:-1*cos(t * 1.57079633) +1];
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
  [other update:sin(t * 1.57079633)];
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
  [other update:-0.5*(cos(3.14159265*t) - 1)];
}
@end



