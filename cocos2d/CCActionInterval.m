/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2011 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
	return nil;
}

+(id) actionWithDuration: (CCTime) d
{
	return [[self alloc] initWithDuration:d ];
}

-(id) initWithDuration: (CCTime) d
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

-(void) step: (CCTime) dt
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
@implementation CCActionSequence
+(id) actions: (CCActionFiniteTime*) action1, ...
{
	va_list args;
	va_start(args, action1);

	id ret = [self actions:action1 vaList:args];

	va_end(args);

	return  ret;
}

+(id) actions: (CCActionFiniteTime*) action1 vaList:(va_list)args
{
	CCActionFiniteTime *now;
	CCActionFiniteTime *prev = action1;
	
	while( action1 ) {
		now = va_arg(args,CCActionFiniteTime*);
		if ( now )
			prev = [self actionOne: prev two: now];
		else
			break;
	}

	return prev;
}


+(id) actionWithArray: (NSArray*) actions
{
	CCActionFiniteTime *prev = [actions objectAtIndex:0];
	
	for (NSUInteger i = 1; i < [actions count]; i++)
		prev = [self actionOne:prev two:[actions objectAtIndex:i]];
	
	return prev;
}

+(id) actionOne: (CCActionFiniteTime*) one two: (CCActionFiniteTime*) two
{
	return [[self alloc] initOne:one two:two ];
}

-(id) initOne: (CCActionFiniteTime*) one two: (CCActionFiniteTime*) two
{
	NSAssert( one!=nil && two!=nil, @"Sequence: arguments must be non-nil");
	// NSAssert( one!=_actions[0] && one!=_actions[1], @"Sequence: re-init using the same parameters is not supported");
	// NSAssert( two!=_actions[1] && two!=_actions[0], @"Sequence: re-init using the same parameters is not supported");
	
	CCTime d = [one duration] + [two duration];
	
	if( (self=[super initWithDuration: d]) ) {
		
		// XXX: Supports re-init without leaking. Fails if one==_one || two==_two
		
		_actions[0] = one;
		_actions[1] = two;
	}
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initOne:[_actions[0] copy] two:[_actions[1] copy] ];
	return copy;
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

-(void) update: (CCTime) t
{

	int found = 0;
	CCTime new_t = 0.0f;
	
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
@implementation CCActionRepeat
@synthesize innerAction=_innerAction;

+(id) actionWithAction:(CCActionFiniteTime*)action times:(NSUInteger)times
{
	return [[self alloc] initWithAction:action times:times];
}

-(id) initWithAction:(CCActionFiniteTime*)action times:(NSUInteger)times
{
	CCTime d = [action duration] * times;

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
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[_innerAction copy] times:_times];
	return copy;
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
-(void) update:(CCTime) dt
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

@implementation CCActionSpawn
+(id) actions: (CCActionFiniteTime*) action1, ...
{
	va_list args;
	va_start(args, action1);

	id ret = [self actions:action1 vaList:args];

	va_end(args);
	return ret;
}

+(id) actions: (CCActionFiniteTime*) action1 vaList:(va_list)args
{
	CCActionFiniteTime *now;
	CCActionFiniteTime *prev = action1;
	
	while( action1 ) {
		now = va_arg(args,CCActionFiniteTime*);
		if ( now )
			prev = [self actionOne: prev two: now];
		else
			break;
	}

	return prev;
}


+(id) actionWithArray: (NSArray*) actions
{
	CCActionFiniteTime *prev = [actions objectAtIndex:0];

	for (NSUInteger i = 1; i < [actions count]; i++)
		prev = [self actionOne:prev two:[actions objectAtIndex:i]];

	return prev;
}

+(id) actionOne: (CCActionFiniteTime*) one two: (CCActionFiniteTime*) two
{
	return [[self alloc] initOne:one two:two ];
}

-(id) initOne: (CCActionFiniteTime*) one two: (CCActionFiniteTime*) two
{
	NSAssert( one!=nil && two!=nil, @"Spawn: arguments must be non-nil");
	NSAssert( one!=_one && one!=_two, @"Spawn: reinit using same parameters is not supported");
	NSAssert( two!=_two && two!=_one, @"Spawn: reinit using same parameters is not supported");

	CCTime d1 = [one duration];
	CCTime d2 = [two duration];

	if( (self=[super initWithDuration: MAX(d1,d2)] ) ) {

		// XXX: Supports re-init without leaking. Fails if one==_one || two==_two

		_one = one;
		_two = two;

		if( d1 > d2 )
			_two = [CCActionSequence actionOne:two two:[CCActionDelay actionWithDuration: (d1-d2)] ];
		else if( d1 < d2)
			_one = [CCActionSequence actionOne:one two: [CCActionDelay actionWithDuration: (d2-d1)] ];

	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initOne: [_one copy] two: [_two copy] ];
	return copy;
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

-(void) update: (CCTime) t
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

@implementation CCActionRotateTo
+(id) actionWithDuration: (CCTime) t angle:(float) a
{
	return [[self alloc] initWithDuration:t angle:a ];
}

-(id) initWithDuration: (CCTime) t angle:(float) a
{
	if( (self=[super initWithDuration: t]) )
		_dstAngleX = _dstAngleY = a;

	return self;
}

+(id) actionWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY
{
	return [[self alloc] initWithDuration:t angleX:aX angleY:aY ];
}

-(id) initWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY
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
	_startAngleX = [_target rotationalSkewX];
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
	_startAngleY = [_target rotationalSkewY];
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
-(void) update: (CCTime) t
{
    // added to support overriding setRotation only
    if ((_startAngleX == _startAngleY) && (_diffAngleX == _diffAngleY))
    {
        [_target setRotation:(_startAngleX + (_diffAngleX * t))];
    }
    else
    {
        [_target setRotationalSkewX: _startAngleX + _diffAngleX * t];
        [_target setRotationalSkewY: _startAngleY + _diffAngleY * t];
    }
}
@end


//
// RotateBy
//
#pragma mark - RotateBy

@implementation CCActionRotateBy
+(id) actionWithDuration: (CCTime) t angle:(float) a
{
	return [[self alloc] initWithDuration:t angle:a ];
}

-(id) initWithDuration: (CCTime) t angle:(float) a
{
	if( (self=[super initWithDuration: t]) )
		_angleX = _angleY = a;

	return self;
}

+(id) actionWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY
{
	return [[self alloc] initWithDuration:t angleX:aX angleY:aY ];
}

-(id) initWithDuration: (CCTime) t angleX:(float) aX angleY:(float) aY
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
	_startAngleX = [_target rotationalSkewX];
	_startAngleY = [_target rotationalSkewY];
}

-(void) update: (CCTime) t
{
	// XXX: shall I add % 360
    // added to support overriding setRotation only
    if ((_startAngleX == _startAngleY) && (_angleX == _angleY))
    {
        [_target setRotation:(_startAngleX + (_angleX * t))];
    }
    else
    {
        [_target setRotationalSkewX: (_startAngleX + _angleX * t )];
        [_target setRotationalSkewY: (_startAngleY + _angleY * t )];
    }
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

@implementation CCActionMoveBy
+(id) actionWithDuration: (CCTime) t position: (CGPoint) p
{
	return [[self alloc] initWithDuration:t position:p ];
}

-(id) initWithDuration: (CCTime) t position: (CGPoint) p
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

-(void) update: (CCTime) t
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

@implementation CCActionMoveTo
+(id) actionWithDuration: (CCTime) t position: (CGPoint) p
{
	return [[self alloc] initWithDuration:t position:p ];
}

-(id) initWithDuration: (CCTime) t position: (CGPoint) p
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

@implementation CCActionSkewTo
+(id) actionWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy
{
	return [[self alloc] initWithDuration: t skewX:sx skewY:sy];
}

-(id) initWithDuration:(CCTime)t skewX:(float)sx skewY:(float)sy
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

-(void) update: (CCTime) t
{
	[_target setSkewX: (_startSkewX + _deltaX * t ) ];
	[_target setSkewY: (_startSkewY + _deltaY * t ) ];
}

@end

//
// CCSkewBy
//
#pragma mark - CCSkewBy

@implementation CCActionSkewBy

-(id) initWithDuration:(CCTime)t skewX:(float)deltaSkewX skewY:(float)deltaSkewY
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

@implementation CCActionJumpBy
+(id) actionWithDuration: (CCTime) t position: (CGPoint) pos height: (CCTime) h jumps:(NSUInteger)j
{
	return [[self alloc] initWithDuration: t position: pos height: h jumps:j];
}

-(id) initWithDuration: (CCTime) t position: (CGPoint) pos height: (CCTime) h jumps:(NSUInteger)j
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

-(void) update: (CCTime) t
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

@implementation CCActionJumpTo
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
static inline CGFloat bezierat( float a, float b, float c, float d, CCTime t )
{
	return (powf(1-t,3) * a +
			3*t*(powf(1-t,2))*b +
			3*powf(t,2)*(1-t)*c +
			powf(t,3)*d );
}

//
// BezierBy
//
@implementation CCActionBezierBy
+(id) actionWithDuration: (CCTime) t bezier:(ccBezierConfig) c
{
	return [[self alloc] initWithDuration:t bezier:c ];
}

-(id) initWithDuration: (CCTime) t bezier:(ccBezierConfig) c
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

-(void) update: (CCTime) t
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

	CCActionBezierBy *action = [[self class] actionWithDuration:[self duration] bezier:r];
	return action;
}
@end

//
// BezierTo
//
#pragma mark - CCBezierTo
@implementation CCActionBezierTo
-(id) initWithDuration: (CCTime) t bezier:(ccBezierConfig) c
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
@implementation CCActionScaleTo
+(id) actionWithDuration: (CCTime) t scale:(float) s
{
	return [[self alloc] initWithDuration: t scale:s];
}

-(id) initWithDuration: (CCTime) t scale:(float) s
{
	if( (self=[super initWithDuration: t]) ) {
		_endScaleX = s;
		_endScaleY = s;
	}
	return self;
}

+(id) actionWithDuration: (CCTime) t scaleX:(float)sx scaleY:(float)sy
{
	return [[self alloc] initWithDuration: t scaleX:sx scaleY:sy];
}

-(id) initWithDuration: (CCTime) t scaleX:(float)sx scaleY:(float)sy
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

-(void) update: (CCTime) t
{
    // added to support overriding setScale only
    if ((_startScaleX == _startScaleY) && (_endScaleX == _endScaleY))
    {
        [_target setScale:(_startScaleX + (_deltaX * t))];
    }
    else
    {
        [_target setScaleX: (_startScaleX + _deltaX * t ) ];
        [_target setScaleY: (_startScaleY + _deltaY * t ) ];
    }
}
@end

//
// ScaleBy
//
#pragma mark - CCScaleBy
@implementation CCActionScaleBy
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
@implementation CCActionBlink
+(id) actionWithDuration: (CCTime) t blinks: (NSUInteger) b
{
	return [[ self alloc] initWithDuration: t blinks: b];
}

-(id) initWithDuration: (CCTime) t blinks: (NSUInteger) b
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

-(void) update: (CCTime) t
{
	if( ! [self isDone] ) {
		CCTime slice = 1.0f / _times;
		CCTime m = fmodf(t, slice);
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
@implementation CCActionFadeIn
-(void) update: (CCTime) t
{
	[(CCNode*) _target setOpacity: 1.0 *t];
}

-(CCActionInterval*) reverse
{
	return [CCActionFadeOut actionWithDuration:_duration];
}
@end

//
// FadeOut
//
#pragma mark - CCFadeOut
@implementation CCActionFadeOut
-(void) update: (CCTime) t
{
	[(CCNode*) _target setOpacity: 1.0 *(1-t)];
}

-(CCActionInterval*) reverse
{
	return [CCActionFadeIn actionWithDuration:_duration];
}
@end

//
// FadeTo
//
#pragma mark - CCFadeTo
@implementation CCActionFadeTo
+(id) actionWithDuration: (CCTime) t opacity: (CGFloat) o
{
	return [[ self alloc] initWithDuration: t opacity: o];
}

-(id) initWithDuration: (CCTime) t opacity: (CGFloat) o
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
	_fromOpacity = [(CCNode*)_target opacity];
}

-(void) update: (CCTime) t
{
	[(CCNode*)_target setOpacity:_fromOpacity + ( _toOpacity - _fromOpacity ) * t];
}
@end

//
// TintTo
//
#pragma mark - CCTintTo
@implementation CCActionTintTo
+(id) actionWithDuration:(CCTime)duration color:(CCColor*)color
{
	return [(CCActionTintTo*)[ self alloc] initWithDuration:duration color:color];
}

-(id) initWithDuration:(CCTime)t color:(CCColor*)color
{
	if( (self=[super initWithDuration:t] ) )
		_to = color;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [(CCActionTintTo*)[[self class] allocWithZone: zone] initWithDuration:[self duration] color:_to];
	return copy;
}

-(void) startWithTarget:(CCNode*)aTarget
{
	[super startWithTarget:aTarget];

	CCNode* tn = (CCNode*) _target;
	_from = [tn color];
}

-(void) update: (CCTime) t
{
	CCNode* tn = (CCNode*) _target;
    
	ccColor4F fc = _from.ccColor4f;
	ccColor4F tc = _to.ccColor4f;
    
	[tn setColor:[CCColor colorWithRed:fc.r + (tc.r - fc.r) * t green:fc.g + (tc.g - fc.g) * t blue:fc.b + (tc.b - fc.b) * t alpha:1]];
}
@end

//
// TintBy
//
#pragma mark - CCTintBy
@implementation CCActionTintBy
+(id) actionWithDuration:(CCTime)t red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b
{
	return [(CCActionTintBy*)[ self alloc] initWithDuration:t red:r green:g blue:b];
}

-(id) initWithDuration:(CCTime)t red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b
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
	return[(CCActionTintBy*)[[self class] allocWithZone: zone] initWithDuration: [self duration] red:_deltaR green:_deltaG blue:_deltaB];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];

	CCNode* tn = (CCNode*) _target;
	CCColor* color = [tn color];
    
	_fromR = color.red;
	_fromG = color.green;
	_fromB = color.blue;
}

-(void) update: (CCTime) t
{
	CCNode* tn = (CCNode*) _target;
	[tn setColor:[CCColor colorWithRed:_fromR + _deltaR * t green:_fromG + _deltaG * t blue:_fromB + _deltaB * t alpha:1]];
}

- (CCActionInterval*) reverse
{
	return [CCActionTintBy actionWithDuration:_duration red:-_deltaR green:-_deltaG blue:-_deltaB];
}
@end

//
// DelayTime
//
#pragma mark - CCDelayTime
@implementation CCActionDelay
-(void) update: (CCTime) t
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
@implementation CCActionReverse
+(id) actionWithAction: (CCActionFiniteTime*) action
{
	// casting to prevent warnings
	CCActionReverse *a = [self alloc];
	return [a initWithAction:action];
}

-(id) initWithAction: (CCActionFiniteTime*) action
{
	NSAssert(action != nil, @"CCReverseTime: action should not be nil");
	NSAssert(action != _other, @"CCReverseTime: re-init doesn't support using the same arguments");

	if( (self=[super initWithDuration: [action duration]]) ) {
		// Don't leak if action is reused
		_other = action;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithAction:[_other copy] ];
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

-(void) update:(CCTime)t
{
	[_other update:1-t];
}

-(CCActionInterval*) reverse
{
	return [_other copy];
}
@end

//
// Animate
//

#pragma mark - CCAnimate
@implementation CCActionAnimate

@synthesize animation = _animation;

+(id) actionWithAnimation: (CCAnimation*)anim
{
	return [[self alloc] initWithAnimation:anim];
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
	return [[[self class] allocWithZone: zone] initWithAnimation:[_animation copy] ];
}


-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	CCSprite *sprite = _target;


	if( _animation.restoreOriginalFrame )
		_origFrame = sprite.spriteFrame;
	
	_nextFrame = 0;
	_executedLoops = 0;
}

-(void) stop
{
	if( _animation.restoreOriginalFrame ) {
		CCSprite *sprite = _target;
        sprite.spriteFrame = _origFrame;
	}

	[super stop];
}

-(void) update: (CCTime) t
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
			[(CCSprite*)_target setSpriteFrame: frameToDisplay];
			
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
        [newArray addObject:[element copy]];

	CCAnimation *newAnim = [CCAnimation animationWithAnimationFrames:newArray delayPerUnit:_animation.delayPerUnit loops:_animation.loops];
	newAnim.restoreOriginalFrame = _animation.restoreOriginalFrame;
	return [[self class] actionWithAnimation:newAnim];
}
@end
