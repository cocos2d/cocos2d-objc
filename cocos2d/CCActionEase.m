/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2009 Jason Booth
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
 */


/*
 * Elastic, Back and Bounce actions based on code from:
 * http://github.com/NikhilK/silverlightfx/
 *
 * by http://github.com/NikhilK
 */

#import "CCActionEase.h"

#ifndef M_PI_X_2
#define M_PI_X_2 (float)M_PI * 2.0f
#endif

#pragma mark EaseAction

//
// EaseAction
//
@implementation CCActionEase

+(id) actionWithAction: (CCActionInterval*) action
{
	return [[[self alloc] initWithAction: action] autorelease ];
}

-(id) initWithAction: (CCActionInterval*) action
{
	NSAssert( action!=nil, @"Ease: arguments must be non-nil");

	if( (self=[super initWithDuration: action.duration]) )
		other = [action retain];

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[[other copy] autorelease]];
	return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[other startWithTarget:target_];
}

-(void) stop
{
	[other stop];
	[super stop];
}

-(void) update: (ccTime) t
{
	[other update: t];
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithAction: [other reverse]];
}
@end


#pragma mark -
#pragma mark EaseRate

//
// EaseRateAction
//
@implementation CCEaseRateAction
@synthesize rate;
+(id) actionWithAction: (CCActionInterval*) action rate:(float)aRate
{
	return [[[self alloc] initWithAction: action rate:aRate] autorelease ];
}

-(id) initWithAction: (CCActionInterval*) action rate:(float)aRate
{
	if( (self=[super initWithAction:action ]) )
		self.rate = aRate;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[[other copy] autorelease] rate:rate];
	return copy;
}

-(void) dealloc
{
	[super dealloc];
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithAction: [other reverse] rate:1/rate];
}
@end

//
// EeseIn
//
@implementation CCEaseIn
-(void) update: (ccTime) t
{
	[other update: powf(t,rate)];
}
@end

//
// EaseOut
//
@implementation CCEaseOut
-(void) update: (ccTime) t
{
	[other update: powf(t,1/rate)];
}
@end

//
// EaseInOut
//
@implementation CCEaseInOut
-(void) update: (ccTime) t
{
	int sign =1;
	int r = (int) rate;
	if (r % 2 == 0)
		sign = -1;
	t *= 2;
	if (t < 1)
		[other update: 0.5f * powf (t, rate)];
	else
		[other update: sign*0.5f * (powf (t-2, rate) + sign*2)];
}

// InOut and OutIn are symmetrical
-(CCActionInterval*) reverse
{
	return [[self class] actionWithAction: [other reverse] rate:rate];
}

@end

#pragma mark -
#pragma mark EaseExponential

//
// EaseExponentialIn
//
@implementation CCEaseExponentialIn
-(void) update: (ccTime) t
{
	[other update: (t==0) ? 0 : powf(2, 10 * (t/1 - 1)) - 1 * 0.001f];
}

- (CCActionInterval*) reverse
{
	return [CCEaseExponentialOut actionWithAction: [other reverse]];
}
@end

//
// EaseExponentialOut
//
@implementation CCEaseExponentialOut
-(void) update: (ccTime) t
{
	[other update: (t==1) ? 1 : (-powf(2, -10 * t/1) + 1)];
}

- (CCActionInterval*) reverse
{
	return [CCEaseExponentialIn actionWithAction: [other reverse]];
}
@end

//
// EaseExponentialInOut
//
@implementation CCEaseExponentialInOut
-(void) update: (ccTime) t
{
	t /= 0.5f;
	if (t < 1)
		t = 0.5f * powf(2, 10 * (t - 1));
	else
		t = 0.5f * (-powf(2, -10 * (t -1) ) + 2);

	[other update:t];
}
@end


#pragma mark -
#pragma mark EaseSin actions

//
// EaseSineIn
//
@implementation CCEaseSineIn
-(void) update: (ccTime) t
{
	[other update:-1*cosf(t * (float)M_PI_2) +1];
}

- (CCActionInterval*) reverse
{
	return [CCEaseSineOut actionWithAction: [other reverse]];
}
@end

//
// EaseSineOut
//
@implementation CCEaseSineOut
-(void) update: (ccTime) t
{
	[other update:sinf(t * (float)M_PI_2)];
}

- (CCActionInterval*) reverse
{
	return [CCEaseSineIn actionWithAction: [other reverse]];
}
@end

//
// EaseSineInOut
//
@implementation CCEaseSineInOut
-(void) update: (ccTime) t
{
	[other update:-0.5f*(cosf( (float)M_PI*t) - 1)];
}
@end

#pragma mark -
#pragma mark EaseElastic actions

//
// EaseElastic
//
@implementation CCEaseElastic

@synthesize period = period_;

+(id) actionWithAction: (CCActionInterval*) action
{
	return [[[self alloc] initWithAction:action period:0.3f] autorelease];
}

+(id) actionWithAction: (CCActionInterval*) action period:(float)period
{
	return [[[self alloc] initWithAction:action period:period] autorelease];
}

-(id) initWithAction: (CCActionInterval*) action
{
	return [self initWithAction:action period:0.3f];
}

-(id) initWithAction: (CCActionInterval*) action period:(float)period
{
	if( (self=[super initWithAction:action]) )
		period_ = period;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[[other copy] autorelease] period:period_];
	return copy;
}

-(CCActionInterval*) reverse
{
	NSAssert(NO,@"Override me");
	return nil;
}

@end

//
// EaseElasticIn
//

@implementation CCEaseElasticIn
-(void) update: (ccTime) t
{
	ccTime newT = 0;
	if (t == 0 || t == 1)
		newT = t;

	else {
		float s = period_ / 4;
		t = t - 1;
		newT = -powf(2, 10 * t) * sinf( (t-s) *M_PI_X_2 / period_);
	}
	[other update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCEaseElasticOut actionWithAction: [other reverse] period:period_];
}

@end

//
// EaseElasticOut
//
@implementation CCEaseElasticOut

-(void) update: (ccTime) t
{
	ccTime newT = 0;
	if (t == 0 || t == 1) {
		newT = t;

	} else {
		float s = period_ / 4;
		newT = powf(2, -10 * t) * sinf( (t-s) *M_PI_X_2 / period_) + 1;
	}
	[other update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCEaseElasticIn actionWithAction: [other reverse] period:period_];
}

@end

//
// EaseElasticInOut
//
@implementation CCEaseElasticInOut
-(void) update: (ccTime) t
{
	ccTime newT = 0;

	if( t == 0 || t == 1 )
		newT = t;
	else {
		t = t * 2;
		if(! period_ )
			period_ = 0.3f * 1.5f;
		ccTime s = period_ / 4;

		t = t -1;
		if( t < 0 )
			newT = -0.5f * powf(2, 10 * t) * sinf((t - s) * M_PI_X_2 / period_);
		else
			newT = powf(2, -10 * t) * sinf((t - s) * M_PI_X_2 / period_) * 0.5f + 1;
	}
	[other update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCEaseElasticInOut actionWithAction: [other reverse] period:period_];
}

@end

#pragma mark -
#pragma mark EaseBounce actions

//
// EaseBounce
//
@implementation CCEaseBounce
-(ccTime) bounceTime:(ccTime) t
{
	if (t < 1 / 2.75) {
		return 7.5625f * t * t;
	}
	else if (t < 2 / 2.75) {
		t -= 1.5f / 2.75f;
		return 7.5625f * t * t + 0.75f;
	}
	else if (t < 2.5 / 2.75) {
		t -= 2.25f / 2.75f;
		return 7.5625f * t * t + 0.9375f;
	}

	t -= 2.625f / 2.75f;
	return 7.5625f * t * t + 0.984375f;
}
@end

//
// EaseBounceIn
//

@implementation CCEaseBounceIn

-(void) update: (ccTime) t
{
	ccTime newT = 1 - [self bounceTime:1-t];
	[other update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCEaseBounceOut actionWithAction: [other reverse]];
}

@end

@implementation CCEaseBounceOut

-(void) update: (ccTime) t
{
	ccTime newT = [self bounceTime:t];
	[other update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCEaseBounceIn actionWithAction: [other reverse]];
}

@end

@implementation CCEaseBounceInOut

-(void) update: (ccTime) t
{
	ccTime newT = 0;
	if (t < 0.5) {
		t = t * 2;
		newT = (1 - [self bounceTime:1-t] ) * 0.5f;
	} else
		newT = [self bounceTime:t * 2 - 1] * 0.5f + 0.5f;

	[other update:newT];
}
@end

#pragma mark -
#pragma mark Ease Back actions

//
// EaseBackIn
//
@implementation CCEaseBackIn

-(void) update: (ccTime) t
{
	ccTime overshoot = 1.70158f;
	[other update: t * t * ((overshoot + 1) * t - overshoot)];
}

- (CCActionInterval*) reverse
{
	return [CCEaseBackOut actionWithAction: [other reverse]];
}
@end

//
// EaseBackOut
//
@implementation CCEaseBackOut
-(void) update: (ccTime) t
{
	ccTime overshoot = 1.70158f;

	t = t - 1;
	[other update: t * t * ((overshoot + 1) * t + overshoot) + 1];
}

- (CCActionInterval*) reverse
{
	return [CCEaseBackIn actionWithAction: [other reverse]];
}
@end

//
// EaseBackInOut
//
@implementation CCEaseBackInOut

-(void) update: (ccTime) t
{
	ccTime overshoot = 1.70158f * 1.525f;

	t = t * 2;
	if (t < 1)
		[other update: (t * t * ((overshoot + 1) * t - overshoot)) / 2];
	else {
		t = t - 2;
		[other update: (t * t * ((overshoot + 1) * t + overshoot)) / 2 + 1];
	}
}
@end
