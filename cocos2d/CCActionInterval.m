/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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



#import "CCActionInterval.h"
#import "CCActionInstant.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCAnimation.h"
#import "CCNode.h"
#import "Support/CGPointExtension.h"

//
// IntervalAction
//
#pragma mark -
#pragma mark IntervalAction
@implementation CCActionInterval

@synthesize elapsed = elapsed_;

-(id) init
{
	NSAssert(NO, @"IntervalActionInit: Init not supported. Use InitWithDuration");
	[self release];
	return nil;
}

+(id) actionWithDuration: (ccTime) d
{
	return [[[self alloc] initWithDuration:d ] autorelease];
}

-(id) initWithDuration: (ccTime) d
{
	if( (self=[super init]) ) {
		duration_ = d;

		// prevent division by 0
		// This comparison could be in step:, but it might decrease the performance
		// by 3% in heavy based action games.
		if( duration_ == 0 )
			duration_ = FLT_EPSILON;
		elapsed_ = 0;
		firstTick_ = YES;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] ];
	return copy;
}

- (BOOL) isDone
{
	return (elapsed_ >= duration_);
}

-(void) step: (ccTime) dt
{
	if( firstTick_ ) {
		firstTick_ = NO;
		elapsed_ = 0;
	} else
		elapsed_ += dt;

	[self update: MIN(1, elapsed_/MAX(duration_,FLT_EPSILON))];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	elapsed_ = 0.0f;
	firstTick_ = YES;
}

- (CCActionInterval*) reverse
{
	NSAssert(NO, @"CCIntervalAction: reverse not implemented.");
	return nil;
}
@end

//
// Sequence
//
#pragma mark -
#pragma mark Sequence
@implementation CCSequence
+(id) actions: (CCFiniteTimeAction*) action1, ...
{
	va_list params;
	va_start(params,action1);

	CCFiniteTimeAction *now;
	CCFiniteTimeAction *prev = action1;

	while( action1 ) {
		now = va_arg(params,CCFiniteTimeAction*);
		if ( now )
			prev = [self actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

+(id) actionsWithArray: (NSArray*) actions
{
	CCFiniteTimeAction *prev = [actions objectAtIndex:0];

	for (NSUInteger i = 1; i < [actions count]; i++)
		prev = [self actionOne:prev two:[actions objectAtIndex:i]];

	return prev;
}

+(id) actionOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{
	return [[[self alloc] initOne:one two:two ] autorelease];
}

-(id) initOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{
	NSAssert( one!=nil && two!=nil, @"Sequence: arguments must be non-nil");
	NSAssert( one!=actions_[0] && one!=actions_[1], @"Sequence: re-init using the same parameters is not supported");
	NSAssert( two!=actions_[1] && two!=actions_[0], @"Sequence: re-init using the same parameters is not supported");

	ccTime d = [one duration] + [two duration];

	if( (self=[super initWithDuration: d]) ) {

		// XXX: Supports re-init without leaking. Fails if one==one_ || two==two_
		[actions_[0] release];
		[actions_[1] release];

		actions_[0] = [one retain];
		actions_[1] = [two retain];
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initOne:[[actions_[0] copy] autorelease] two:[[actions_[1] copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[actions_[0] release];
	[actions_[1] release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	split_ = [actions_[0] duration] / MAX(duration_, FLT_EPSILON);
	last_ = -1;
}

-(void) stop
{
	[actions_[0] stop];
	[actions_[1] stop];
	[super stop];
}

-(void) update: (ccTime) t
{
	int found = 0;
	ccTime new_t = 0.0f;

	if( t >= split_ ) {
		found = 1;
		if ( split_ == 1 )
			new_t = 1;
		else
			new_t = (t-split_) / (1 - split_ );
	} else {
		found = 0;
		if( split_ != 0 )
			new_t = t / split_;
		else
			new_t = 1;
	}

	if (last_ == -1 && found==1)	{
		[actions_[0] startWithTarget:target_];
		[actions_[0] update:1.0f];
		[actions_[0] stop];
	}

	if (last_ != found ) {
		if( last_ != -1 ) {
			[actions_[last_] update: 1.0f];
			[actions_[last_] stop];
		}
		[actions_[found] startWithTarget:target_];
	}
	[actions_[found] update: new_t];
	last_ = found;
}

- (CCActionInterval *) reverse
{
	return [[self class] actionOne: [actions_[1] reverse] two: [actions_[0] reverse ] ];
}
@end

//
// Repeat
//
#pragma mark -
#pragma mark CCRepeat
@implementation CCRepeat
@synthesize innerAction=innerAction_;

+(id) actionWithAction:(CCFiniteTimeAction*)action times:(NSUInteger)times
{
	return [[[self alloc] initWithAction:action times:times] autorelease];
}

-(id) initWithAction:(CCFiniteTimeAction*)action times:(NSUInteger)times
{
	ccTime d = [action duration] * times;

	if( (self=[super initWithDuration: d ]) ) {
		times_ = times;
		self.innerAction = action;
		isActionInstant_ = ([action isKindOfClass:[CCActionInstant class]]) ? YES : NO;

		//a instant action needs to be executed one time less in the update method since it uses startWithTarget to execute the action
		if (isActionInstant_) times_ -=1;
		total_ = 0;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[[innerAction_ copy] autorelease] times:times_];
	return copy;
}

-(void) dealloc
{
	[innerAction_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	total_ = 0;
	nextDt_ = [innerAction_ duration]/duration_;
	[super startWithTarget:aTarget];
	[innerAction_ startWithTarget:aTarget];
}

-(void) stop
{
    [innerAction_ stop];
	[super stop];
}


// issue #80. Instead of hooking step:, hook update: since it can be called by any
// container action like Repeat, Sequence, AccelDeccel, etc..
-(void) update:(ccTime) dt
{
	if (dt >= nextDt_)
	{
		while (dt > nextDt_ && total_ < times_)
		{

			[innerAction_ update:1.0f];
			total_++;

			[innerAction_ stop];
			[innerAction_ startWithTarget:target_];
			nextDt_ += [innerAction_ duration]/duration_;
		}

		//fix for issue #1288, incorrect end value of repeat
		if(dt == 1.0 && total_ < times_)
        {
            total_++;
        }

		//don't set a instantaction back or update it, it has no use because it has no duration
		if (!isActionInstant_)
		{
			if (total_ == times_)
			{
				[innerAction_ update:1];
				[innerAction_ stop];
			}//issue #390 prevent jerk, use right update
			else
			{
				[innerAction_ update:dt - (nextDt_ - innerAction_.duration/duration_)];
			}
		}
	}
	else
	{
		[innerAction_ update:fmodf(dt * times_,1.0f)];
	}
}

-(BOOL) isDone
{
	return ( total_ == times_ );
}

- (CCActionInterval *) reverse
{
	return [[self class] actionWithAction:[innerAction_ reverse] times:times_];
}
@end

//
// Spawn
//
#pragma mark -
#pragma mark Spawn

@implementation CCSpawn
+(id) actions: (CCFiniteTimeAction*) action1, ...
{
	va_list params;
	va_start(params,action1);

	CCFiniteTimeAction *now;
	CCFiniteTimeAction *prev = action1;

	while( action1 ) {
		now = va_arg(params,CCFiniteTimeAction*);
		if ( now )
			prev = [self actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

+(id) actionsWithArray: (NSArray*) actions
{
	CCFiniteTimeAction *prev = [actions objectAtIndex:0];

	for (NSUInteger i = 1; i < [actions count]; i++)
		prev = [self actionOne:prev two:[actions objectAtIndex:i]];

	return prev;
}

+(id) actionOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{
	return [[[self alloc] initOne:one two:two ] autorelease];
}

-(id) initOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{
	NSAssert( one!=nil && two!=nil, @"Spawn: arguments must be non-nil");
	NSAssert( one!=one_ && one!=two_, @"Spawn: reinit using same parameters is not supported");
	NSAssert( two!=two_ && two!=one_, @"Spawn: reinit using same parameters is not supported");

	ccTime d1 = [one duration];
	ccTime d2 = [two duration];

	if( (self=[super initWithDuration: MAX(d1,d2)] ) ) {

		// XXX: Supports re-init without leaking. Fails if one==one_ || two==two_
		[one_ release];
		[two_ release];

		one_ = one;
		two_ = two;

		if( d1 > d2 )
			two_ = [CCSequence actionOne:two two:[CCDelayTime actionWithDuration: (d1-d2)] ];
		else if( d1 < d2)
			one_ = [CCSequence actionOne:one two: [CCDelayTime actionWithDuration: (d2-d1)] ];

		[one_ retain];
		[two_ retain];
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initOne: [[one_ copy] autorelease] two: [[two_ copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[one_ release];
	[two_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[one_ startWithTarget:target_];
	[two_ startWithTarget:target_];
}

-(void) stop
{
	[one_ stop];
	[two_ stop];
	[super stop];
}

-(void) update: (ccTime) t
{
	[one_ update:t];
	[two_ update:t];
}

- (CCActionInterval *) reverse
{
	return [[self class] actionOne: [one_ reverse] two: [two_ reverse ] ];
}
@end

//
// RotateTo
//
#pragma mark -
#pragma mark RotateTo

@implementation CCRotateTo
+(id) actionWithDuration: (ccTime) t angle:(float) a
{
	return [[[self alloc] initWithDuration:t angle:a ] autorelease];
}

-(id) initWithDuration: (ccTime) t angle:(float) a
{
	if( (self=[super initWithDuration: t]) )
		dstAngle_ = a;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] angle:dstAngle_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];

	startAngle_ = [target_ rotation];
	if (startAngle_ > 0)
		startAngle_ = fmodf(startAngle_, 360.0f);
	else
		startAngle_ = fmodf(startAngle_, -360.0f);

	diffAngle_ =dstAngle_ - startAngle_;
	if (diffAngle_ > 180)
		diffAngle_ -= 360;
	if (diffAngle_ < -180)
		diffAngle_ += 360;
}
-(void) update: (ccTime) t
{
	[target_ setRotation: startAngle_ + diffAngle_ * t];
}
@end


//
// RotateBy
//
#pragma mark -
#pragma mark RotateBy

@implementation CCRotateBy
+(id) actionWithDuration: (ccTime) t angle:(float) a
{
	return [[[self alloc] initWithDuration:t angle:a ] autorelease];
}

-(id) initWithDuration: (ccTime) t angle:(float) a
{
	if( (self=[super initWithDuration: t]) )
		angle_ = a;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] angle: angle_];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	startAngle_ = [target_ rotation];
}

-(void) update: (ccTime) t
{
	// XXX: shall I add % 360
	[target_ setRotation: (startAngle_ +angle_ * t )];
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ angle:-angle_];
}

@end

//
// MoveTo
//
#pragma mark -
#pragma mark MoveTo

@implementation CCMoveTo
+(id) actionWithDuration: (ccTime) t position: (CGPoint) p
{
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p
{
	if( (self=[super initWithDuration: t]) )
		endPosition_ = p;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: endPosition_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startPosition_ = [(CCNode*)target_ position];
	delta_ = ccpSub( endPosition_, startPosition_ );
}

-(void) update: (ccTime) t
{
	[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), (startPosition_.y + delta_.y * t ) )];
}
@end

//
// MoveBy
//
#pragma mark -
#pragma mark MoveBy

@implementation CCMoveBy
+(id) actionWithDuration: (ccTime) t position: (CGPoint) p
{
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p
{
	if( (self=[super initWithDuration: t]) )
		delta_ = p;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: delta_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	CGPoint dTmp = delta_;
	[super startWithTarget:aTarget];
	delta_ = dTmp;
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ position:ccp( -delta_.x, -delta_.y)];
}
@end


//
// SkewTo
//
#pragma mark -
#pragma mark SkewTo

@implementation CCSkewTo
+(id) actionWithDuration:(ccTime)t skewX:(float)sx skewY:(float)sy
{
	return [[[self alloc] initWithDuration: t skewX:sx skewY:sy] autorelease];
}

-(id) initWithDuration:(ccTime)t skewX:(float)sx skewY:(float)sy
{
	if( (self=[super initWithDuration:t]) ) {
		endSkewX_ = sx;
		endSkewY_ = sy;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] skewX:endSkewX_ skewY:endSkewY_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];

	startSkewX_ = [target_ skewX];

	if (startSkewX_ > 0)
		startSkewX_ = fmodf(startSkewX_, 180.0f);
	else
		startSkewX_ = fmodf(startSkewX_, -180.0f);

	deltaX_ = endSkewX_ - startSkewX_;

	if ( deltaX_ > 180 ) {
		deltaX_ -= 360;
	}
	if ( deltaX_ < -180 ) {
		deltaX_ += 360;
	}

	startSkewY_ = [target_ skewY];

	if (startSkewY_ > 0)
		startSkewY_ = fmodf(startSkewY_, 360.0f);
	else
		startSkewY_ = fmodf(startSkewY_, -360.0f);

	deltaY_ = endSkewY_ - startSkewY_;

	if ( deltaY_ > 180 ) {
		deltaY_ -= 360;
	}
	if ( deltaY_ < -180 ) {
		deltaY_ += 360;
	}
}

-(void) update: (ccTime) t
{
	[target_ setSkewX: (startSkewX_ + deltaX_ * t ) ];
	[target_ setSkewY: (startSkewY_ + deltaY_ * t ) ];
}

@end

//
// CCSkewBy
//
@implementation CCSkewBy

-(id) initWithDuration:(ccTime)t skewX:(float)deltaSkewX skewY:(float)deltaSkewY
{
	if( (self=[super initWithDuration:t skewX:deltaSkewX skewY:deltaSkewY]) ) {
		skewX_ = deltaSkewX;
		skewY_ = deltaSkewY;
	}
	return self;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	deltaX_ = skewX_;
	deltaY_ = skewY_;
	endSkewX_ = startSkewX_ + deltaX_;
	endSkewY_ = startSkewY_ + deltaY_;
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ skewX:-skewX_ skewY:-skewY_];
}
@end


//
// JumpBy
//
#pragma mark -
#pragma mark JumpBy

@implementation CCJumpBy
+(id) actionWithDuration: (ccTime) t position: (CGPoint) pos height: (ccTime) h jumps:(NSUInteger)j
{
	return [[[self alloc] initWithDuration: t position: pos height: h jumps:j] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) pos height: (ccTime) h jumps:(NSUInteger)j
{
	if( (self=[super initWithDuration:t]) ) {
		delta_ = pos;
		height_ = h;
		jumps_ = j;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] position:delta_ height:height_ jumps:jumps_];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	startPosition_ = [(CCNode*)target_ position];
}

-(void) update: (ccTime) t
{
	// Sin jump. Less realistic
//	ccTime y = height * fabsf( sinf(t * (CGFloat)M_PI * jumps ) );
//	y += delta.y * t;
//	ccTime x = delta.x * t;
//	[target setPosition: ccp( startPosition.x + x, startPosition.y + y )];

	// parabolic jump (since v0.8.2)
	ccTime frac = fmodf( t * jumps_, 1.0f );
	ccTime y = height_ * 4 * frac * (1 - frac);
	y += delta_.y * t;
	ccTime x = delta_.x * t;
	[target_ setPosition: ccp( startPosition_.x + x, startPosition_.y + y )];

}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ position: ccp(-delta_.x,-delta_.y) height:height_ jumps:jumps_];
}
@end

//
// JumpTo
//
#pragma mark -
#pragma mark JumpTo

@implementation CCJumpTo
-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	delta_ = ccp( delta_.x - startPosition_.x, delta_.y - startPosition_.y );
}
@end


#pragma mark -
#pragma mark BezierBy

// Bezier cubic formula:
//	((1 - t) + t)3 = 1
// Expands to…
//   (1 - t)3 + 3t(1-t)2 + 3t2(1 - t) + t3 = 1
static inline float bezierat( float a, float b, float c, float d, ccTime t )
{
	return (powf(1-t,3) * a +
			3*t*(powf(1-t,2))*b +
			3*powf(t,2)*(1-t)*c +
			powf(t,3)*d );
}

//
// BezierBy
//
@implementation CCBezierBy
+(id) actionWithDuration: (ccTime) t bezier:(ccBezierConfig) c
{
	return [[[self alloc] initWithDuration:t bezier:c ] autorelease];
}

-(id) initWithDuration: (ccTime) t bezier:(ccBezierConfig) c
{
	if( (self=[super initWithDuration: t]) ) {
		config_ = c;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] bezier:config_];
    return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	startPosition_ = [(CCNode*)target_ position];
}

-(void) update: (ccTime) t
{
	float xa = 0;
	float xb = config_.controlPoint_1.x;
	float xc = config_.controlPoint_2.x;
	float xd = config_.endPosition.x;

	float ya = 0;
	float yb = config_.controlPoint_1.y;
	float yc = config_.controlPoint_2.y;
	float yd = config_.endPosition.y;

	float x = bezierat(xa, xb, xc, xd, t);
	float y = bezierat(ya, yb, yc, yd, t);
	[target_ setPosition:  ccpAdd( startPosition_, ccp(x,y))];
}

- (CCActionInterval*) reverse
{
	ccBezierConfig r;

	r.endPosition	 = ccpNeg(config_.endPosition);
	r.controlPoint_1 = ccpAdd(config_.controlPoint_2, ccpNeg(config_.endPosition));
	r.controlPoint_2 = ccpAdd(config_.controlPoint_1, ccpNeg(config_.endPosition));

	CCBezierBy *action = [[self class] actionWithDuration:[self duration] bezier:r];
	return action;
}
@end

//
// BezierTo
//
#pragma mark -
#pragma mark BezierTo
@implementation CCBezierTo
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	config_.controlPoint_1 = ccpSub(config_.controlPoint_1, startPosition_);
	config_.controlPoint_2 = ccpSub(config_.controlPoint_2, startPosition_);
	config_.endPosition = ccpSub(config_.endPosition, startPosition_);
}
@end


//
// ScaleTo
//
#pragma mark -
#pragma mark ScaleTo
@implementation CCScaleTo
+(id) actionWithDuration: (ccTime) t scale:(float) s
{
	return [[[self alloc] initWithDuration: t scale:s] autorelease];
}

-(id) initWithDuration: (ccTime) t scale:(float) s
{
	if( (self=[super initWithDuration: t]) ) {
		endScaleX_ = s;
		endScaleY_ = s;
	}
	return self;
}

+(id) actionWithDuration: (ccTime) t scaleX:(float)sx scaleY:(float)sy
{
	return [[[self alloc] initWithDuration: t scaleX:sx scaleY:sy] autorelease];
}

-(id) initWithDuration: (ccTime) t scaleX:(float)sx scaleY:(float)sy
{
	if( (self=[super initWithDuration: t]) ) {
		endScaleX_ = sx;
		endScaleY_ = sy;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] scaleX:endScaleX_ scaleY:endScaleY_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startScaleX_ = [target_ scaleX];
	startScaleY_ = [target_ scaleY];
	deltaX_ = endScaleX_ - startScaleX_;
	deltaY_ = endScaleY_ - startScaleY_;
}

-(void) update: (ccTime) t
{
	[target_ setScaleX: (startScaleX_ + deltaX_ * t ) ];
	[target_ setScaleY: (startScaleY_ + deltaY_ * t ) ];
}
@end

//
// ScaleBy
//
#pragma mark -
#pragma mark ScaleBy
@implementation CCScaleBy
-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	deltaX_ = startScaleX_ * endScaleX_ - startScaleX_;
	deltaY_ = startScaleY_ * endScaleY_ - startScaleY_;
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:duration_ scaleX:1/endScaleX_ scaleY:1/endScaleY_];
}
@end

//
// Blink
//
#pragma mark -
#pragma mark Blink
@implementation CCBlink
+(id) actionWithDuration: (ccTime) t blinks: (NSUInteger) b
{
	return [[[ self alloc] initWithDuration: t blinks: b] autorelease];
}

-(id) initWithDuration: (ccTime) t blinks: (NSUInteger) b
{
	if( (self=[super initWithDuration: t] ) )
		times_ = b;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] blinks: times_];
	return copy;
}

-(void) update: (ccTime) t
{
	if( ! [self isDone] ) {
		ccTime slice = 1.0f / times_;
		ccTime m = fmodf(t, slice);
		[target_ setVisible: (m > slice/2) ? YES : NO];
	}
}

-(CCActionInterval*) reverse
{
	// return 'self'
	return [[self class] actionWithDuration:duration_ blinks: times_];
}
@end

//
// FadeIn
//
#pragma mark -
#pragma mark FadeIn
@implementation CCFadeIn
- (id) initWithDuration:(ccTime)d
{
	return [super initWithDuration:d opacity:255];
}

+ (id) actionWithDuration:(ccTime)d
{
	return [super actionWithDuration:d opacity:255];
}

-(CCActionInterval*) reverse
{
	return [CCFadeOut actionWithDuration:duration_];
}
@end

//
// FadeOut
//
#pragma mark -
#pragma mark FadeOut
@implementation CCFadeOut
- (id) initWithDuration:(ccTime)d
{
	return [super initWithDuration:d opacity:0];
}

+ (id) actionWithDuration:(ccTime)d
{
	return [super actionWithDuration:d opacity:0];
}

-(CCActionInterval*) reverse
{
	return [CCFadeIn actionWithDuration:duration_];
}
@end

//
// FadeTo
//
#pragma mark -
#pragma mark FadeTo
@implementation CCFadeTo
+(id) actionWithDuration: (ccTime) t opacity: (GLubyte) o
{
	return [[[ self alloc] initWithDuration: t opacity: o] autorelease];
}

-(id) initWithDuration: (ccTime) t opacity: (GLubyte) o
{
	if( (self=[super initWithDuration: t] ) )
		toOpacity_ = o;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] opacity:toOpacity_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	fromOpacity_ = [(id<CCRGBAProtocol>)target_ opacity];
}

-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>)target_ setOpacity:fromOpacity_ + ( toOpacity_ - fromOpacity_ ) * t];
}
@end

//
// TintTo
//
#pragma mark -
#pragma mark TintTo
@implementation CCTintTo
+(id) actionWithDuration:(ccTime)t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b
{
	return [[(CCTintTo*)[ self alloc] initWithDuration:t red:r green:g blue:b] autorelease];
}

-(id) initWithDuration: (ccTime) t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b
{
	if( (self=[super initWithDuration:t] ) )
		to_ = ccc3(r,g,b);

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [(CCTintTo*)[[self class] allocWithZone: zone] initWithDuration:[self duration] red:to_.r green:to_.g blue:to_.b];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	from_ = [tn color];
}

-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	[tn setColor:ccc3(from_.r + (to_.r - from_.r) * t, from_.g + (to_.g - from_.g) * t, from_.b + (to_.b - from_.b) * t)];
}
@end

//
// TintBy
//
#pragma mark -
#pragma mark TintBy
@implementation CCTintBy
+(id) actionWithDuration:(ccTime)t red:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	return [[(CCTintBy*)[ self alloc] initWithDuration:t red:r green:g blue:b] autorelease];
}

-(id) initWithDuration:(ccTime)t red:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	if( (self=[super initWithDuration: t] ) ) {
		deltaR_ = r;
		deltaG_ = g;
		deltaB_ = b;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return[(CCTintBy*)[[self class] allocWithZone: zone] initWithDuration: [self duration] red:deltaR_ green:deltaG_ blue:deltaB_];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	ccColor3B color = [tn color];
	fromR_ = color.r;
	fromG_ = color.g;
	fromB_ = color.b;
}

-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target_;
	[tn setColor:ccc3( fromR_ + deltaR_ * t, fromG_ + deltaG_ * t, fromB_ + deltaB_ * t)];
}

- (CCActionInterval*) reverse
{
	return [CCTintBy actionWithDuration:duration_ red:-deltaR_ green:-deltaG_ blue:-deltaB_];
}
@end

//
// DelayTime
//
#pragma mark -
#pragma mark DelayTime
@implementation CCDelayTime
-(void) update: (ccTime) t
{
	return;
}

-(id)reverse
{
	return [[self class] actionWithDuration:duration_];
}
@end

//
// ReverseTime
//
#pragma mark -
#pragma mark ReverseTime
@implementation CCReverseTime
+(id) actionWithAction: (CCFiniteTimeAction*) action
{
	// casting to prevent warnings
	CCReverseTime *a = [super alloc];
	return [[a initWithAction:action] autorelease];
}

-(id) initWithAction: (CCFiniteTimeAction*) action
{
	NSAssert(action != nil, @"CCReverseTime: action should not be nil");
	NSAssert(action != other_, @"CCReverseTime: re-init doesn't support using the same arguments");

	if( (self=[super initWithDuration: [action duration]]) ) {
		// Don't leak if action is reused
		[other_ release];
		other_ = [action retain];
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithAction:[[other_ copy] autorelease] ];
}

-(void) dealloc
{
	[other_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[other_ startWithTarget:target_];
}

-(void) stop
{
	[other_ stop];
	[super stop];
}

-(void) update:(ccTime)t
{
	[other_ update:1-t];
}

-(CCActionInterval*) reverse
{
	return [[other_ copy] autorelease];
}
@end

//
// Animate
//

#pragma mark - CCAnimate
@implementation CCAnimate

@synthesize animation = animation_;
@synthesize nextFrame = nextFrame_;

+(id) actionWithAnimation: (CCAnimation*)anim
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:anim.restoreOriginalFrame] autorelease];
}

+(id) actionWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)restore
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:restore] autorelease];
}

+(id) actionWithDuration:(ccTime)duration animation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)restore
{
	return [[[self alloc] initWithDuration:duration animation:anim restoreOriginalFrame:restore] autorelease];
}

-(id) initWithAnimation: (CCAnimation*)anim
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	return [self initWithAnimation:anim restoreOriginalFrame:anim.restoreOriginalFrame];
}

-(id) initWithAnimation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");

	return [self initWithDuration:anim.duration animation:anim restoreOriginalFrame:restoreOriginalFrame];
}

// delegate initializer
-(id) initWithDuration:(ccTime)duration animation: (CCAnimation*)anim restoreOriginalFrame:(BOOL)restoreOriginalFrame
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");

	if( (self=[super initWithDuration:duration] ) ) {

		nextFrame_ = 0;
		restoreOriginalFrame_ = restoreOriginalFrame;
		self.animation = anim;
		origFrame_ = nil;

		splitTimes_ = [[NSMutableArray alloc] initWithCapacity:anim.frames.count];

		float accumUnitsOfTime = 0;
		float newUnitOfTimeValue = duration / anim.totalDelayUnits;

		for( CCAnimationFrame *frame in anim.frames ) {

			NSNumber *value = [NSNumber numberWithFloat: (accumUnitsOfTime * newUnitOfTimeValue) / duration];
			accumUnitsOfTime += frame.delayUnits;

			[splitTimes_ addObject:value];
		}
	}
	return self;
}


-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:duration_ animation:animation_ restoreOriginalFrame:restoreOriginalFrame_];
}

-(void) dealloc
{
	[splitTimes_ release];
	[animation_ release];
	[origFrame_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	CCSprite *sprite = target_;

	[origFrame_ release];

	if( restoreOriginalFrame_ )
		origFrame_ = [[sprite displayedFrame] retain];

	nextFrame_ = 0;
}

-(void) stop
{
	if( restoreOriginalFrame_ ) {
		CCSprite *sprite = target_;
		[sprite setDisplayFrame:origFrame_];
	}

	[super stop];
}

-(void) update: (ccTime) t
{
	NSArray *frames = [animation_ frames];
	NSUInteger numberOfFrames = [frames count];
	CCSpriteFrame *frameToDisplay = nil;

	for( NSUInteger i=nextFrame_; i < numberOfFrames; i++ ) {
		NSNumber *splitTime = [splitTimes_ objectAtIndex:i];

		if( [splitTime floatValue] <= t ) {
			CCAnimationFrame *frame = [frames objectAtIndex:i];
			frameToDisplay = [frame spriteFrame];
			[(CCSprite*)target_ setDisplayFrame: frameToDisplay];

			NSDictionary *dict = [frame userInfo];
			if( dict )
				[[NSNotificationCenter defaultCenter] postNotificationName:CCAnimationFrameDisplayedNotification object:target_ userInfo:dict];

			nextFrame_ = i+1;

        }//could be more than one frame per tick, due to low frame rate or frame delta < 1/FPS
        else break;
	}
}

- (CCActionInterval *) reverse
{
	NSArray *oldArray = [animation_ frames];
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[oldArray count]];
    NSEnumerator *enumerator = [oldArray reverseObjectEnumerator];
    for (id element in enumerator)
        [newArray addObject:[[element copy] autorelease]];

	CCAnimation *newAnim = [CCAnimation animationWithFrames:newArray delayPerUnit:animation_.delayPerUnit];
	return [[self class] actionWithDuration:duration_ animation:newAnim restoreOriginalFrame:restoreOriginalFrame_];
}

@end

@implementation CCTargetedAction

@synthesize forcedTarget = forcedTarget_;

+ (id) actionWithTarget:(id) target action:(CCFiniteTimeAction*) action
{
	return [[ (CCTargetedAction*)[self alloc] initWithTarget:target action:action] autorelease];
}

- (id) initWithTarget:(id) targetIn action:(CCFiniteTimeAction*) actionIn
{
	if((self = [super initWithDuration:actionIn.duration]))
	{
		forcedTarget_ = [targetIn retain];
		action_ = [actionIn retain];
	}
	return self;
}

- (void) dealloc
{
	[forcedTarget_ release];
	[action_ release];
	[super dealloc];
}

- (void) startWithTarget:(id)aTarget
{
	[super startWithTarget:forcedTarget_];
	[action_ startWithTarget:forcedTarget_];
}

- (void) stop
{
	[action_ stop];
}

- (void) update:(ccTime) time
{
	[action_ update:time];
}

@end