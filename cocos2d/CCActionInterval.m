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
#pragma mark - CCIntervalAction
@implementation CCActionInterval

@synthesize elapsed = _elapsed;

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
		_duration = d;

		// prevent division by 0
		// This comparison could be in step:, but it might decrease the performance
		// by 3% in heavy based action games.
		if( _duration == 0 )
			_duration = FLT_EPSILON;
		_elapsed = 0;
		_firstTick = YES;
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
	return (_elapsed >= _duration);
}

-(void) step: (ccTime) dt
{
	if( _firstTick ) {
		_firstTick = NO;
		_elapsed = 0;
	} else
		_elapsed += dt;


	[self update: MAX(0,					// needed for rewind. elapsed could be negative
					  MIN(1, _elapsed/
						  MAX(_duration,FLT_EPSILON)	// division by 0
						  )
					  )
	 ];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	_elapsed = 0.0f;
	_firstTick = YES;
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
#pragma mark - CCSequence
@implementation CCSequence
+(id) actions: (CCFiniteTimeAction*) action1, ...
{
	va_list args;
	va_start(args, action1);

	id ret = [self actions:action1 vaList:args];

	va_end(args);

	return  ret;
}

+(id) actions: (CCFiniteTimeAction*) action1 vaList:(va_list)args
{
	CCFiniteTimeAction *now;
	CCFiniteTimeAction *prev = action1;
	
	while( action1 ) {
		now = va_arg(args,CCFiniteTimeAction*);
		if ( now )
			prev = [self actionOne: prev two: now];
		else
			break;
	}

	return prev;
}


+(id) actionWithArray: (NSArray*) actions
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
	NSAssert( one!=_actions[0] && one!=_actions[1], @"Sequence: re-init using the same parameters is not supported");
	NSAssert( two!=_actions[1] && two!=_actions[0], @"Sequence: re-init using the same parameters is not supported");
	
	ccTime d = [one duration] + [two duration];
	
	if( (self=[super initWithDuration: d]) ) {
		
		// XXX: Supports re-init without leaking. Fails if one==_one || two==_two
		[_actions[0] release];
		[_actions[1] release];
		
		_actions[0] = [one retain];
		_actions[1] = [two retain];
	}
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initOne:[[_actions[0] copy] autorelease] two:[[_actions[1] copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[_actions[0] release];
	[_actions[1] release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	_split = [_actions[0] duration] / MAX(_duration, FLT_EPSILON);
	_last = -1;
}

-(void) stop
{
	// Issue #1305
	if( _last != - 1)
		[_actions[_last] stop];

	[super stop];
}

-(void) update: (ccTime) t
{

	int found = 0;
	ccTime new_t = 0.0f;
	
	if( t < _split ) {
		// action[0]
		found = 0;
		if( _split != 0 )
			new_t = t / _split;
		else
			new_t = 1;

	} else {
		// action[1]
		found = 1;
		if ( _split == 1 )
			new_t = 1;
		else
			new_t = (t-_split) / (1 - _split );
	}
	
	if ( found==1 ) {
		
		if( _last == -1 ) {
			// action[0] was skipped, execute it.
			[_actions[0] startWithTarget:_target];
			[_actions[0] update:1.0f];
			[_actions[0] stop];
		}
		else if( _last == 0 )
		{
			// switching to action 1. stop action 0.
			[_actions[0] update: 1.0f];
			[_actions[0] stop];
		}
	}
	else if(found==0 && _last==1 )
	{
		// Reverse mode ?
		// XXX: Bug. this case doesn't contemplate when _last==-1, found=0 and in "reverse mode"
		// since it will require a hack to know if an action is on reverse mode or not.
		// "step" should be overriden, and the "reverseMode" value propagated to inner Sequences.
		[_actions[1] update:0];
		[_actions[1] stop];
	}
	
	// Last action found and it is done.
	if( found == _last && [_actions[found] isDone] ) {
		return;
	}

	// New action. Start it.
	if( found != _last )
		[_actions[found] startWithTarget:_target];
	
	[_actions[found] update: new_t];
	_last = found;
}

- (CCActionInterval *) reverse
{
	return [[self class] actionOne: [_actions[1] reverse] two: [_actions[0] reverse ] ];
}
@end

//
// Repeat
//
#pragma mark - CCRepeat
@implementation CCRepeat
@synthesize innerAction=_innerAction;

+(id) actionWithAction:(CCFiniteTimeAction*)action times:(NSUInteger)times
{
	return [[[self alloc] initWithAction:action times:times] autorelease];
}

-(id) initWithAction:(CCFiniteTimeAction*)action times:(NSUInteger)times
{
	ccTime d = [action duration] * times;

	if( (self=[super initWithDuration: d ]) ) {
		_times = times;
		self.innerAction = action;
		_isActionInstant = ([action isKindOfClass:[CCActionInstant class]]) ? YES : NO;

		//a instant action needs to be executed one time less in the update method since it uses startWithTarget to execute the action
		if (_isActionInstant) _times -=1;
		_total = 0;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[[_innerAction copy] autorelease] times:_times];
	return copy;
}

-(void) dealloc
{
	[_innerAction release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	_total = 0;
	_nextDt = [_innerAction duration]/_duration;
	[super startWithTarget:aTarget];
	[_innerAction startWithTarget:aTarget];
}

-(void) stop
{
    [_innerAction stop];
	[super stop];
}


// issue #80. Instead of hooking step:, hook update: since it can be called by any
// container action like CCRepeat, CCSequence, CCEase, etc..
-(void) update:(ccTime) dt
{
	if (dt >= _nextDt)
	{
		while (dt > _nextDt && _total < _times)
		{

			[_innerAction update:1.0f];
			_total++;

			[_innerAction stop];
			[_innerAction startWithTarget:_target];
			_nextDt += [_innerAction duration]/_duration;
		}
		
		// fix for issue #1288, incorrect end value of repeat
		if(dt >= 1.0f && _total < _times) 
		{
			_total++;
		}
		
		// don't set a instantaction back or update it, it has no use because it has no duration
		if (!_isActionInstant)
		{
			if (_total == _times)
			{
				[_innerAction update:1];
				[_innerAction stop];
			}
			else
			{
				// issue #390 prevent jerk, use right update
				[_innerAction update:dt - (_nextDt - _innerAction.duration/_duration)];
			}
		}
	}
	else
	{
		[_innerAction update:fmodf(dt * _times,1.0f)];
	}
}

-(BOOL) isDone
{
	return ( _total == _times );
}

- (CCActionInterval *) reverse
{
	return [[self class] actionWithAction:[_innerAction reverse] times:_times];
}
@end

//
// Spawn
//
#pragma mark - CCSpawn

@implementation CCSpawn
+(id) actions: (CCFiniteTimeAction*) action1, ...
{
	va_list args;
	va_start(args, action1);

	id ret = [self actions:action1 vaList:args];

	va_end(args);
	return ret;
}

+(id) actions: (CCFiniteTimeAction*) action1 vaList:(va_list)args
{
	CCFiniteTimeAction *now;
	CCFiniteTimeAction *prev = action1;
	
	while( action1 ) {
		now = va_arg(args,CCFiniteTimeAction*);
		if ( now )
			prev = [self actionOne: prev two: now];
		else
			break;
	}

	return prev;
}


+(id) actionWithArray: (NSArray*) actions
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
	NSAssert( one!=_one && one!=_two, @"Spawn: reinit using same parameters is not supported");
	NSAssert( two!=_two && two!=_one, @"Spawn: reinit using same parameters is not supported");

	ccTime d1 = [one duration];
	ccTime d2 = [two duration];

	if( (self=[super initWithDuration: MAX(d1,d2)] ) ) {

		// XXX: Supports re-init without leaking. Fails if one==_one || two==_two
		[_one release];
		[_two release];

		_one = one;
		_two = two;

		if( d1 > d2 )
			_two = [CCSequence actionOne:two two:[CCDelayTime actionWithDuration: (d1-d2)] ];
		else if( d1 < d2)
			_one = [CCSequence actionOne:one two: [CCDelayTime actionWithDuration: (d2-d1)] ];

		[_one retain];
		[_two retain];
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initOne: [[_one copy] autorelease] two: [[_two copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[_one release];
	[_two release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_one startWithTarget:_target];
	[_two startWithTarget:_target];
}

-(void) stop
{
	[_one stop];
	[_two stop];
	[super stop];
}

-(void) update: (ccTime) t
{
	[_one update:t];
	[_two update:t];
}

- (CCActionInterval *) reverse
{
	return [[self class] actionOne: [_one reverse] two: [_two reverse ] ];
}
@end

//
// RotateTo
//
#pragma mark - CCRotateTo

@implementation CCRotateTo
+(id) actionWithDuration: (ccTime) t angle:(float) a
{
	return [[[self alloc] initWithDuration:t angle:a ] autorelease];
}

-(id) initWithDuration: (ccTime) t angle:(float) a
{
	if( (self=[super initWithDuration: t]) )
		_dstAngleX = _dstAngleY = a;

	return self;
}

+(id) actionWithDuration: (ccTime) t angleX:(float) aX angleY:(float) aY
{
	return [[[self alloc] initWithDuration:t angleX:aX angleY:aY ] autorelease];
}

-(id) initWithDuration: (ccTime) t angleX:(float) aX angleY:(float) aY
{
	if( (self=[super initWithDuration: t]) ){
		_dstAngleX = aX;
    _dstAngleY = aY;
  }
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] angleX:_dstAngleX angleY:_dstAngleY];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];

  //Calculate X
	_startAngleX = [_target rotationX];
	if (_startAngleX > 0)
		_startAngleX = fmodf(_startAngleX, 360.0f);
	else
		_startAngleX = fmodf(_startAngleX, -360.0f);

	_diffAngleX = _dstAngleX - _startAngleX;
	if (_diffAngleX > 180)
		_diffAngleX -= 360;
	if (_diffAngleX < -180)
		_diffAngleX += 360;
  
	
  //Calculate Y: It's duplicated from calculating X since the rotation wrap should be the same
	_startAngleY = [_target rotationY];
	if (_startAngleY > 0)
		_startAngleY = fmodf(_startAngleY, 360.0f);
	else
		_startAngleY = fmodf(_startAngleY, -360.0f);
  
	_diffAngleY = _dstAngleY - _startAngleY;
	if (_diffAngleY > 180)
		_diffAngleY -= 360;
	if (_diffAngleY < -180)
		_diffAngleY += 360;
}
-(void) update: (ccTime) t
{
	[_target setRotationX: _startAngleX + _diffAngleX * t];
	[_target setRotationY: _startAngleY + _diffAngleY * t];
}
@end


//
// RotateBy
//
#pragma mark - RotateBy

@implementation CCRotateBy
+(id) actionWithDuration: (ccTime) t angle:(float) a
{
	return [[[self alloc] initWithDuration:t angle:a ] autorelease];
}

-(id) initWithDuration: (ccTime) t angle:(float) a
{
	if( (self=[super initWithDuration: t]) )
		_angleX = _angleY = a;

	return self;
}

+(id) actionWithDuration: (ccTime) t angleX:(float) aX angleY:(float) aY
{
	return [[[self alloc] initWithDuration:t angleX:aX angleY:aY ] autorelease];
}

-(id) initWithDuration: (ccTime) t angleX:(float) aX angleY:(float) aY
{
	if( (self=[super initWithDuration: t]) ){
		_angleX = aX;
    _angleY = aY;
  }
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] angleX: _angleX angleY:_angleY];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	_startAngleX = [_target rotationX];
	_startAngleY = [_target rotationY];
}

-(void) update: (ccTime) t
{
	// XXX: shall I add % 360
	[_target setRotationX: (_startAngleX + _angleX * t )];
	[_target setRotationY: (_startAngleY + _angleY * t )];
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:_duration angleX:-_angleX angleY:-_angleY];
}

@end

//
// MoveBy
//
#pragma mark - MoveBy

@implementation CCMoveBy
+(id) actionWithDuration: (ccTime) t position: (CGPoint) p
{
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) p
{
	if( (self=[super initWithDuration: t]) )
		_positionDelta = p;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:[self duration] position:_positionDelta];
}

-(void) startWithTarget:(CCNode *)target
{
	[super startWithTarget:target];
	_previousPos = _startPos = [target position];
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:_duration position:ccp( -_positionDelta.x, -_positionDelta.y)];
}

-(void) update: (ccTime) t
{

	CCNode *node = (CCNode*)_target;

#if CC_ENABLE_STACKABLE_ACTIONS
	CGPoint currentPos = [node position];
	CGPoint diff = ccpSub(currentPos, _previousPos);
	_startPos = ccpAdd( _startPos, diff);
	CGPoint newPos =  ccpAdd( _startPos, ccpMult(_positionDelta, t) );
	[_target setPosition: newPos];
	_previousPos = newPos;
#else
	[node setPosition: ccpAdd( _startPos, ccpMult(_positionDelta, t))];
#endif // CC_ENABLE_STACKABLE_ACTIONS
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
	if( (self=[super initWithDuration: t]) ) {
		_endPosition = p;
    }

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: _endPosition];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	_positionDelta = ccpSub( _endPosition, [(CCNode*)_target position] );
}

@end

//
// SkewTo
//
#pragma mark - CCSkewTo

@implementation CCSkewTo
+(id) actionWithDuration:(ccTime)t skewX:(float)sx skewY:(float)sy
{
	return [[[self alloc] initWithDuration: t skewX:sx skewY:sy] autorelease];
}

-(id) initWithDuration:(ccTime)t skewX:(float)sx skewY:(float)sy
{
	if( (self=[super initWithDuration:t]) ) {
		_endSkewX = sx;
		_endSkewY = sy;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] skewX:_endSkewX skewY:_endSkewY];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];

	_startSkewX = [_target skewX];

	if (_startSkewX > 0)
		_startSkewX = fmodf(_startSkewX, 180.0f);
	else
		_startSkewX = fmodf(_startSkewX, -180.0f);

	_deltaX = _endSkewX - _startSkewX;

	if ( _deltaX > 180 ) {
		_deltaX -= 360;
	}
	if ( _deltaX < -180 ) {
		_deltaX += 360;
	}

	_startSkewY = [_target skewY];

	if (_startSkewY > 0)
		_startSkewY = fmodf(_startSkewY, 360.0f);
	else
		_startSkewY = fmodf(_startSkewY, -360.0f);

	_deltaY = _endSkewY - _startSkewY;

	if ( _deltaY > 180 ) {
		_deltaY -= 360;
	}
	if ( _deltaY < -180 ) {
		_deltaY += 360;
	}
}

-(void) update: (ccTime) t
{
	[_target setSkewX: (_startSkewX + _deltaX * t ) ];
	[_target setSkewY: (_startSkewY + _deltaY * t ) ];
}

@end

//
// CCSkewBy
//
#pragma mark - CCSkewBy

@implementation CCSkewBy

-(id) initWithDuration:(ccTime)t skewX:(float)deltaSkewX skewY:(float)deltaSkewY
{
	if( (self=[super initWithDuration:t skewX:deltaSkewX skewY:deltaSkewY]) ) {
		_skewX = deltaSkewX;
		_skewY = deltaSkewY;
	}
	return self;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	_deltaX = _skewX;
	_deltaY = _skewY;
	_endSkewX = _startSkewX + _deltaX;
	_endSkewY = _startSkewY + _deltaY;
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:_duration skewX:-_skewX skewY:-_skewY];
}
@end


//
// JumpBy
//
#pragma mark - CCJumpBy

@implementation CCJumpBy
+(id) actionWithDuration: (ccTime) t position: (CGPoint) pos height: (ccTime) h jumps:(NSUInteger)j
{
	return [[[self alloc] initWithDuration: t position: pos height: h jumps:j] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) pos height: (ccTime) h jumps:(NSUInteger)j
{
	if( (self=[super initWithDuration:t]) ) {
		_delta = pos;
		_height = h;
		_jumps = j;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] position:_delta height:_height jumps:_jumps];
	return copy;
}

-(void) startWithTarget:(id)target
{
	[super startWithTarget:target];
	_previousPos = _startPosition = [(CCNode*)_target position];
}

-(void) update: (ccTime) t
{
	// Sin jump. Less realistic
//	ccTime y = _height * fabsf( sinf(t * (CGFloat)M_PI * _jumps ) );
//	y += _delta.y * dt;
	
//	// parabolic jump (since v0.8.2)
	CGFloat frac = fmodf( t * _jumps, 1.0f );
	CGFloat y = _height * 4 * frac * (1 - frac);
	y += _delta.y * t;

	CGFloat x = _delta.x * t;
	
	CCNode *node = (CCNode*)_target;

#if CC_ENABLE_STACKABLE_ACTIONS
	CGPoint currentPos = [node position];
	
	CGPoint diff = ccpSub( currentPos, _previousPos );
	_startPosition = ccpAdd( diff, _startPosition);
	
	CGPoint newPos = ccpAdd( _startPosition, ccp(x,y));
	[node setPosition:newPos];
	
	_previousPos = newPos;
#else
	[node setPosition: ccpAdd( _startPosition, ccp(x,y))];
#endif // !CC_ENABLE_STACKABLE_ACTIONS
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:_duration position: ccp(-_delta.x,-_delta.y) height:_height jumps:_jumps];
}
@end

//
// JumpTo
//
#pragma mark - CCJumpTo

@implementation CCJumpTo
-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	_delta = ccp( _delta.x - _startPosition.x, _delta.y - _startPosition.y );
}
@end


#pragma mark - CCBezierBy

// Bezier cubic formula:
//	((1 - t) + t)3 = 1
// Expands to…
//   (1 - t)3 + 3t(1-t)2 + 3t2(1 - t) + t3 = 1
static inline CGFloat bezierat( float a, float b, float c, float d, ccTime t )
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
		_config = c;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:[self duration] bezier:_config];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	_previousPosition = _startPosition = [(CCNode*)_target position];
}

-(void) update: (ccTime) t
{
	CGFloat xa = 0;
	CGFloat xb = _config.controlPoint_1.x;
	CGFloat xc = _config.controlPoint_2.x;
	CGFloat xd = _config.endPosition.x;

	CGFloat ya = 0;
	CGFloat yb = _config.controlPoint_1.y;
	CGFloat yc = _config.controlPoint_2.y;
	CGFloat yd = _config.endPosition.y;

	CGFloat x = bezierat(xa, xb, xc, xd, t);
	CGFloat y = bezierat(ya, yb, yc, yd, t);
	
	CCNode *node = (CCNode*)_target;

#if CC_ENABLE_STACKABLE_ACTIONS
	CGPoint currentPos = [node position];
	CGPoint diff = ccpSub(currentPos, _previousPosition);
	_startPosition = ccpAdd( _startPosition, diff);

	CGPoint newPos = ccpAdd( _startPosition, ccp(x,y));
	[node setPosition: newPos];
	
	_previousPosition = newPos;
#else
	[node setPosition: ccpAdd( _startPosition, ccp(x,y))];
#endif // !CC_ENABLE_STACKABLE_ACTIONS
}

- (CCActionInterval*) reverse
{
	ccBezierConfig r;

	r.endPosition	 = ccpNeg(_config.endPosition);
	r.controlPoint_1 = ccpAdd(_config.controlPoint_2, ccpNeg(_config.endPosition));
	r.controlPoint_2 = ccpAdd(_config.controlPoint_1, ccpNeg(_config.endPosition));

	CCBezierBy *action = [[self class] actionWithDuration:[self duration] bezier:r];
	return action;
}
@end

//
// BezierTo
//
#pragma mark - CCBezierTo
@implementation CCBezierTo
-(id) initWithDuration: (ccTime) t bezier:(ccBezierConfig) c
{
	if( (self=[super initWithDuration: t]) ) {
		_toConfig = c;
	}
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	_config.controlPoint_1 = ccpSub(_toConfig.controlPoint_1, _startPosition);
	_config.controlPoint_2 = ccpSub(_toConfig.controlPoint_2, _startPosition);
	_config.endPosition = ccpSub(_toConfig.endPosition, _startPosition);
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:[self duration] bezier:_toConfig];
}

@end


//
// ScaleTo
//
#pragma mark - CCScaleTo
@implementation CCScaleTo
+(id) actionWithDuration: (ccTime) t scale:(float) s
{
	return [[[self alloc] initWithDuration: t scale:s] autorelease];
}

-(id) initWithDuration: (ccTime) t scale:(float) s
{
	if( (self=[super initWithDuration: t]) ) {
		_endScaleX = s;
		_endScaleY = s;
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
		_endScaleX = sx;
		_endScaleY = sy;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] scaleX:_endScaleX scaleY:_endScaleY];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	_startScaleX = [_target scaleX];
	_startScaleY = [_target scaleY];
	_deltaX = _endScaleX - _startScaleX;
	_deltaY = _endScaleY - _startScaleY;
}

-(void) update: (ccTime) t
{
	[_target setScaleX: (_startScaleX + _deltaX * t ) ];
	[_target setScaleY: (_startScaleY + _deltaY * t ) ];
}
@end

//
// ScaleBy
//
#pragma mark - CCScaleBy
@implementation CCScaleBy
-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	_deltaX = _startScaleX * _endScaleX - _startScaleX;
	_deltaY = _startScaleY * _endScaleY - _startScaleY;
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:_duration scaleX:1/_endScaleX scaleY:1/_endScaleY];
}
@end

//
// Blink
//
#pragma mark - CCBlink
@implementation CCBlink
+(id) actionWithDuration: (ccTime) t blinks: (NSUInteger) b
{
	return [[[ self alloc] initWithDuration: t blinks: b] autorelease];
}

-(id) initWithDuration: (ccTime) t blinks: (NSUInteger) b
{
	if( (self=[super initWithDuration: t] ) )
		_times = b;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] blinks: _times];
	return copy;
}

-(void) startWithTarget:(id)target
{
	[super startWithTarget:target];
	_originalState = [target visible];
}

-(void) update: (ccTime) t
{
	if( ! [self isDone] ) {
		ccTime slice = 1.0f / _times;
		ccTime m = fmodf(t, slice);
		[_target setVisible: (m > slice/2) ? YES : NO];
	}
}

-(void) stop
{
	[_target setVisible:_originalState];
	[super stop];
}

-(CCActionInterval*) reverse
{
	// return 'self'
	return [[self class] actionWithDuration:_duration blinks: _times];
}
@end

//
// FadeIn
//
#pragma mark - CCFadeIn
@implementation CCFadeIn
-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>) _target setOpacity: 255 *t];
}

-(CCActionInterval*) reverse
{
	return [CCFadeOut actionWithDuration:_duration];
}
@end

//
// FadeOut
//
#pragma mark - CCFadeOut
@implementation CCFadeOut
-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>) _target setOpacity: 255 *(1-t)];
}

-(CCActionInterval*) reverse
{
	return [CCFadeIn actionWithDuration:_duration];
}
@end

//
// FadeTo
//
#pragma mark - CCFadeTo
@implementation CCFadeTo
+(id) actionWithDuration: (ccTime) t opacity: (GLubyte) o
{
	return [[[ self alloc] initWithDuration: t opacity: o] autorelease];
}

-(id) initWithDuration: (ccTime) t opacity: (GLubyte) o
{
	if( (self=[super initWithDuration: t] ) )
		_toOpacity = o;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] opacity:_toOpacity];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	_fromOpacity = [(id<CCRGBAProtocol>)_target opacity];
}

-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>)_target setOpacity:_fromOpacity + ( _toOpacity - _fromOpacity ) * t];
}
@end

//
// TintTo
//
#pragma mark - CCTintTo
@implementation CCTintTo
+(id) actionWithDuration:(ccTime)t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b
{
	return [[(CCTintTo*)[ self alloc] initWithDuration:t red:r green:g blue:b] autorelease];
}

-(id) initWithDuration: (ccTime) t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b
{
	if( (self=[super initWithDuration:t] ) )
		_to = ccc3(r,g,b);

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [(CCTintTo*)[[self class] allocWithZone: zone] initWithDuration:[self duration] red:_to.r green:_to.g blue:_to.b];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) _target;
	_from = [tn color];
}

-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) _target;
	[tn setColor:ccc3(_from.r + (_to.r - _from.r) * t, _from.g + (_to.g - _from.g) * t, _from.b + (_to.b - _from.b) * t)];
}
@end

//
// TintBy
//
#pragma mark - CCTintBy
@implementation CCTintBy
+(id) actionWithDuration:(ccTime)t red:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	return [[(CCTintBy*)[ self alloc] initWithDuration:t red:r green:g blue:b] autorelease];
}

-(id) initWithDuration:(ccTime)t red:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	if( (self=[super initWithDuration: t] ) ) {
		_deltaR = r;
		_deltaG = g;
		_deltaB = b;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return[(CCTintBy*)[[self class] allocWithZone: zone] initWithDuration: [self duration] red:_deltaR green:_deltaG blue:_deltaB];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) _target;
	ccColor3B color = [tn color];
	_fromR = color.r;
	_fromG = color.g;
	_fromB = color.b;
}

-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) _target;
	[tn setColor:ccc3( _fromR + _deltaR * t, _fromG + _deltaG * t, _fromB + _deltaB * t)];
}

- (CCActionInterval*) reverse
{
	return [CCTintBy actionWithDuration:_duration red:-_deltaR green:-_deltaG blue:-_deltaB];
}
@end

//
// DelayTime
//
#pragma mark - CCDelayTime
@implementation CCDelayTime
-(void) update: (ccTime) t
{
	return;
}

-(id)reverse
{
	return [[self class] actionWithDuration:_duration];
}
@end

//
// ReverseTime
//
#pragma mark - CCReverseTime
@implementation CCReverseTime
+(id) actionWithAction: (CCFiniteTimeAction*) action
{
	// casting to prevent warnings
	CCReverseTime *a = [self alloc];
	return [[a initWithAction:action] autorelease];
}

-(id) initWithAction: (CCFiniteTimeAction*) action
{
	NSAssert(action != nil, @"CCReverseTime: action should not be nil");
	NSAssert(action != _other, @"CCReverseTime: re-init doesn't support using the same arguments");

	if( (self=[super initWithDuration: [action duration]]) ) {
		// Don't leak if action is reused
		[_other release];
		_other = [action retain];
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithAction:[[_other copy] autorelease] ];
}

-(void) dealloc
{
	[_other release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_other startWithTarget:_target];
}

-(void) stop
{
	[_other stop];
	[super stop];
}

-(void) update:(ccTime)t
{
	[_other update:1-t];
}

-(CCActionInterval*) reverse
{
	return [[_other copy] autorelease];
}
@end

//
// Animate
//

#pragma mark - CCAnimate
@implementation CCAnimate

@synthesize animation = _animation;

+(id) actionWithAnimation: (CCAnimation*)anim
{
	return [[[self alloc] initWithAnimation:anim] autorelease];
}

// delegate initializer
-(id) initWithAnimation:(CCAnimation*)anim
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	
	float singleDuration = anim.duration;

	if( (self=[super initWithDuration:singleDuration * anim.loops] ) ) {

		_nextFrame = 0;
		self.animation = anim;
		_origFrame = nil;
		_executedLoops = 0;
		
		_splitTimes = [[NSMutableArray alloc] initWithCapacity:anim.frames.count];
		
		float accumUnitsOfTime = 0;
		float newUnitOfTimeValue = singleDuration / anim.totalDelayUnits;
		
		for( CCAnimationFrame *frame in anim.frames ) {

			NSNumber *value = [NSNumber numberWithFloat: (accumUnitsOfTime * newUnitOfTimeValue) / singleDuration];
			accumUnitsOfTime += frame.delayUnits;

			[_splitTimes addObject:value];
		}		
	}
	return self;
}


-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithAnimation:[[_animation copy]autorelease] ];
}

-(void) dealloc
{
	[_splitTimes release];
	[_animation release];
	[_origFrame release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	CCSprite *sprite = _target;

	[_origFrame release];

	if( _animation.restoreOriginalFrame )
		_origFrame = [[sprite displayFrame] retain];
	
	_nextFrame = 0;
	_executedLoops = 0;
}

-(void) stop
{
	if( _animation.restoreOriginalFrame ) {
		CCSprite *sprite = _target;
		[sprite setDisplayFrame:_origFrame];
	}

	[super stop];
}

-(void) update: (ccTime) t
{
	
	// if t==1, ignore. Animation should finish with t==1
	if( t < 1.0f ) {
		t *= _animation.loops;
		
		// new loop?  If so, reset frame counter
		NSUInteger loopNumber = (NSUInteger)t;
		if( loopNumber > _executedLoops ) {
			_nextFrame = 0;
			_executedLoops++;
		}
		
		// new t for animations
		t = fmodf(t, 1.0f);
	}
	
	NSArray *frames = [_animation frames];
	NSUInteger numberOfFrames = [frames count];
	CCSpriteFrame *frameToDisplay = nil;

	for( NSUInteger i=_nextFrame; i < numberOfFrames; i++ ) {
		NSNumber *splitTime = [_splitTimes objectAtIndex:i];

		if( [splitTime floatValue] <= t ) {
			CCAnimationFrame *frame = [frames objectAtIndex:i];
			frameToDisplay = [frame spriteFrame];
			[(CCSprite*)_target setDisplayFrame: frameToDisplay];
			
			NSDictionary *dict = [frame userInfo];
			if( dict )
				[[NSNotificationCenter defaultCenter] postNotificationName:CCAnimationFrameDisplayedNotification object:_target userInfo:dict];

			_nextFrame = i+1;
		}
		// Issue 1438. Could be more than one frame per tick, due to low frame rate or frame delta < 1/FPS
		else
			break;
	}
}

- (CCActionInterval *) reverse
{
	NSArray *oldArray = [_animation frames];
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[oldArray count]];
    NSEnumerator *enumerator = [oldArray reverseObjectEnumerator];
    for (id element in enumerator)
        [newArray addObject:[[element copy] autorelease]];

	CCAnimation *newAnim = [CCAnimation animationWithAnimationFrames:newArray delayPerUnit:_animation.delayPerUnit loops:_animation.loops];
	newAnim.restoreOriginalFrame = _animation.restoreOriginalFrame;
	return [[self class] actionWithAnimation:newAnim];
}
@end


#pragma mark - CCTargetedAction

@implementation CCTargetedAction

@synthesize forcedTarget = _forcedTarget;

+ (id) actionWithTarget:(id) target action:(CCFiniteTimeAction*) action
{
	return [[ (CCTargetedAction*)[self alloc] initWithTarget:target action:action] autorelease];
}

- (id) initWithTarget:(id) targetIn action:(CCFiniteTimeAction*) actionIn
{
	if((self = [super initWithDuration:actionIn.duration]))
	{
		_forcedTarget = [targetIn retain];
		_action = [actionIn retain];
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [ (CCTargetedAction*) [[self class] allocWithZone: zone] initWithTarget:_forcedTarget action:[[_action copy] autorelease]];
	return copy;
}

- (void) dealloc
{
	[_forcedTarget release];
	[_action release];
	[super dealloc];
}

//- (void) updateDuration:(id)aTarget
//{
//	[action updateDuration:forcedTarget];
//	_duration = action.duration;
//}

- (void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_action startWithTarget:_forcedTarget];
}

- (void) stop
{
	[_action stop];
}

- (void) update:(ccTime) time
{
	[_action update:time];
}

@end
