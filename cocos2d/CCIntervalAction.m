/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CCIntervalAction.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCNode.h"
#import "Support/CGPointExtension.h"

//
// IntervalAction
//
#pragma mark -
#pragma mark IntervalAction
@implementation CCIntervalAction

@synthesize elapsed;

-(id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"IntervalActionInit"
								reason:@"Init not supported. Use InitWithDuration"
								userInfo:nil];
	@throw myException;
	
}

+(id) actionWithDuration: (ccTime) d
{
	return [[[self alloc] initWithDuration:d ] autorelease];
}

-(id) initWithDuration: (ccTime) d
{
	if( (self=[super init]) ) {
		duration = d;
		
		// prevent division by 0
		// This comparison could be in step:, but it might decrease the performance
		// by 3% in heavy based action games.
		if( duration == 0 )
			duration = FLT_EPSILON;
		elapsed = 0;
		firstTick = YES;
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
	return (elapsed >= duration);
}

-(void) step: (ccTime) dt
{
	if( firstTick ) {
		firstTick = NO;
		elapsed = 0;
	} else
		elapsed += dt;

	[self update: MIN(1, elapsed/duration)];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	elapsed = 0.0f;
	firstTick = YES;
}

- (CCIntervalAction*) reverse
{
	NSException* myException = [NSException
								exceptionWithName:@"ReverseActionNotImplemented"
								reason:@"Reverse Action not implemented"
								userInfo:nil];
	@throw myException;	
}
@end

//
// Sequence
//
#pragma mark -
#pragma mark Sequence
@implementation CCSequence
+(id) actionOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

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

-(id) initOne: (CCFiniteTimeAction*) one_ two: (CCFiniteTimeAction*) two_
{
	NSAssert( one_!=nil, @"Sequence: argument one must be non-nil");
	NSAssert( two_!=nil, @"Sequence: argument two must be non-nil");

	CCFiniteTimeAction *one = one_;
	CCFiniteTimeAction *two = two_;
		
	ccTime d = [one duration] + [two duration];
	[super initWithDuration: d];
	
	actions = [[NSArray arrayWithObjects: one, two, nil] retain];
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initOne:[[[actions objectAtIndex:0] copy] autorelease] two:[[[actions objectAtIndex:1] copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[actions release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];	
	split = [[actions objectAtIndex:0] duration] / duration;
	last = -1;
}

-(void) stop
{
	for( CCAction *action in actions )
		[action stop];
	[super stop];
}

-(void) update: (ccTime) t
{
	int found = 0;
	ccTime new_t = 0.0f;
	
	if( t >= split ) {
		found = 1;
		if ( split == 1 )
			new_t = 1;
		else
			new_t = (t-split) / (1 - split );
	} else {
		found = 0;
		if( split != 0 )
			new_t = t / split;
		else
			new_t = 1;
	}
	
	if (last == -1 && found==1)	{
		[(CCAction *) [actions objectAtIndex:0] startWithTarget:target];
		[(CCAction *) [actions objectAtIndex:0] update:1.0f];
		[(CCAction *) [actions objectAtIndex:0] stop];
	}

	if (last != found ) {
		if( last != -1 ) {
			[(CCAction *) [actions objectAtIndex: last] update: 1.0f];
			[(CCAction *) [actions objectAtIndex: last] stop];
		}
		[(CCAction *) [actions objectAtIndex: found] startWithTarget:target];
	}
	[(CCAction *) [actions objectAtIndex:found] update: new_t];
	last = found;
}

- (CCIntervalAction *) reverse
{
	return [[self class] actionOne: [[actions objectAtIndex:1] reverse] two: [[actions objectAtIndex:0] reverse ] ];
}
@end

//
// Repeat
//
#pragma mark -
#pragma mark Repeat
@implementation CCRepeat
+(id) actionWithAction: (CCFiniteTimeAction*) action times: (unsigned int) t
{
	return [[[self alloc] initWithAction: action times: t] autorelease];
}

-(id) initWithAction: (CCFiniteTimeAction*) action times: (unsigned int) t
{
	ccTime d = [action duration] * t;

	if( (self=[super initWithDuration: d ]) ) {
		times = t;
		other = [action retain];

		total = 0;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[[other copy] autorelease] times:times];
	return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	total = 0;
	[super startWithTarget:aTarget];
	[other startWithTarget:aTarget];
}

-(void) stop {
    
    [other stop];
	[super stop];
}


// issue #80. Instead of hooking step:, hook update: since it can be called by any 
// container action like Repeat, Sequence, AccelDeccel, etc..
-(void) update:(ccTime) dt
{
	ccTime t = dt * times;
	if( t > total+1 ) {
		[other update:1.0f];
		total++;
		[other stop];
		[other startWithTarget:target];
		
		// repeat is over ?
		if( total== times )
			// so, set it in the original position
			[other update:0];
		else
			// no ? start next repeat with the right update
			// to prevent jerk (issue #390)
			[other update: t-(total+1)];

	} else {
		
		float r = fmodf(t, 1.0f);
		
		// fix last repeat position
		// else it could be 0.
		if( dt== 1.0f) {
			r=1.0f;
			total++; // this is the added line
		}
		[other update: MIN(r,1)];
	}
}

-(BOOL) isDone
{
	return ( total == times );
}

- (CCIntervalAction *) reverse
{
	return [[self class] actionWithAction:[other reverse] times: times];
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

+(id) actionOne: (CCFiniteTimeAction*) one two: (CCFiniteTimeAction*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

-(id) initOne: (CCFiniteTimeAction*) one_ two: (CCFiniteTimeAction*) two_
{
	NSAssert( one_!=nil, @"Spawn: argument one must be non-nil");
	NSAssert( two_!=nil, @"Spawn: argument two must be non-nil");

	ccTime d1 = [one_ duration];
	ccTime d2 = [two_ duration];	
	
	[super initWithDuration: fmaxf(d1,d2)];

	one = one_;
	two = two_;

	if( d1 > d2 )
		two = [CCSequence actionOne: two_ two:[CCDelayTime actionWithDuration: (d1-d2)] ];
	else if( d1 < d2)
		one = [CCSequence actionOne: one_ two: [CCDelayTime actionWithDuration: (d2-d1)] ];
	
	[one retain];
	[two retain];
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initOne: [[one copy] autorelease] two: [[two copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[one release];
	[two release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[one startWithTarget:target];
	[two startWithTarget:target];
}

-(void) stop
{
	[one stop];
	[two stop];
	[super stop];
}

-(void) update: (ccTime) t
{
	[one update:t];
	[two update:t];
}

- (CCIntervalAction *) reverse
{
	return [[self class] actionOne: [one reverse] two: [two reverse ] ];
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
	if( (self=[super initWithDuration: t]) ) {	
		dstAngle = a;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] angle: dstAngle];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	
	startAngle = [target rotation];
	if (startAngle > 0)
		startAngle = fmodf(startAngle, 360.0f);
	else
		startAngle = fmodf(startAngle, -360.0f);
	
	diffAngle = dstAngle - startAngle;
	if (diffAngle > 180)
		diffAngle -= 360;
	if (diffAngle < -180)
		diffAngle += 360;
}
-(void) update: (ccTime) t
{
	[target setRotation: startAngle + diffAngle * t];
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
	if( !(self=[super initWithDuration: t]) )
		return nil;

	angle = a;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] angle: angle];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	startAngle = [target rotation];
}

-(void) update: (ccTime) t
{	
	// XXX: shall I add % 360
	[target setRotation: (startAngle + angle * t )];
}

-(CCIntervalAction*) reverse
{
	return [[self class] actionWithDuration: duration angle: -angle];
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
	if( !(self=[super initWithDuration: t]) )
		return nil;
	
	endPosition = p;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: endPosition];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startPosition = [(CCNode*)target position];
	delta = ccpSub( endPosition, startPosition );
}

-(void) update: (ccTime) t
{	
	[target setPosition: ccp( (startPosition.x + delta.x * t ), (startPosition.y + delta.y * t ) )];
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
	if( !(self=[super initWithDuration: t]) )
		return nil;

	delta = p;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: delta];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	CGPoint dTmp = delta;
	[super startWithTarget:aTarget];
	delta = dTmp;
}

-(CCIntervalAction*) reverse
{
	return [[self class] actionWithDuration: duration position: ccp( -delta.x, -delta.y)];
}
@end

//
// JumpBy
//
#pragma mark -
#pragma mark JumpBy

@implementation CCJumpBy
+(id) actionWithDuration: (ccTime) t position: (CGPoint) pos height: (ccTime) h jumps:(int)j
{
	return [[[self alloc] initWithDuration: t position: pos height: h jumps:j] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (CGPoint) pos height: (ccTime) h jumps:(int)j
{
	if( !(self=[super initWithDuration:t]) )
		return nil;

	delta = pos;
	height = h;
	jumps = j;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: delta height:height jumps:jumps];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	startPosition = [(CCNode*)target position];
}

-(void) update: (ccTime) t
{
	// Sin jump. Less realistic
//	ccTime y = height * fabsf( sinf(t * (CGFloat)M_PI * jumps ) );
//	y += delta.y * t;
//	ccTime x = delta.x * t;
//	[target setPosition: ccp( startPosition.x + x, startPosition.y + y )];	
	
	// parabolic jump (since v0.8.2)
	ccTime frac = fmodf( t * jumps, 1.0f );
	ccTime y = height * 4 * frac * (1 - frac);
	y += delta.y * t;
	ccTime x = delta.x * t;
	[target setPosition: ccp( startPosition.x + x, startPosition.y + y )];
	
}

-(CCIntervalAction*) reverse
{
	return [[self class] actionWithDuration: duration position: ccp(-delta.x,-delta.y) height: height jumps:jumps];
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
	delta = ccp( delta.x - startPosition.x, delta.y - startPosition.y );
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
		config = c;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] bezier: config];
    return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	startPosition = [(CCNode*)target position];
}

-(void) update: (ccTime) t
{
	float xa = 0;
	float xb = config.controlPoint_1.x;
	float xc = config.controlPoint_2.x;
	float xd = config.endPosition.x;
	
	float ya = 0;
	float yb = config.controlPoint_1.y;
	float yc = config.controlPoint_2.y;
	float yd = config.endPosition.y;
	
	float x = bezierat(xa, xb, xc, xd, t);
	float y = bezierat(ya, yb, yc, yd, t);
	[target setPosition:  ccpAdd( startPosition, ccp(x,y))];
}

- (CCIntervalAction*) reverse
{
	ccBezierConfig r;

	r.endPosition	 = ccpNeg(config.endPosition);
	r.controlPoint_1 = ccpAdd(config.controlPoint_2, ccpNeg(config.endPosition));
	r.controlPoint_2 = ccpAdd(config.controlPoint_1, ccpNeg(config.endPosition));
	
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
	config.controlPoint_1 = ccpSub(config.controlPoint_1, startPosition);
	config.controlPoint_2 = ccpSub(config.controlPoint_2, startPosition);
	config.endPosition = ccpSub(config.endPosition, startPosition);
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
		endScaleX = s;
		endScaleY = s;
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
		endScaleX = sx;
		endScaleY = sy;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] scaleX:endScaleX scaleY:endScaleY];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	startScaleX = [target scaleX];
	startScaleY = [target scaleY];
	deltaX = endScaleX - startScaleX;
	deltaY = endScaleY - startScaleY;
}

-(void) update: (ccTime) t
{
	[target setScaleX: (startScaleX + deltaX * t ) ];
	[target setScaleY: (startScaleY + deltaY * t ) ];
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
	deltaX = startScaleX * endScaleX - startScaleX;
	deltaY = startScaleY * endScaleY - startScaleY;
}

-(CCIntervalAction*) reverse
{
	return [[self class] actionWithDuration: duration scaleX: 1/endScaleX scaleY:1/endScaleY];
}
@end

//
// Blink
//
#pragma mark -
#pragma mark Blink
@implementation CCBlink
+(id) actionWithDuration: (ccTime) t blinks: (unsigned int) b
{
	return [[[ self alloc] initWithDuration: t blinks: b] autorelease];
}

-(id) initWithDuration: (ccTime) t blinks: (unsigned int) b
{
	if( (self=[super initWithDuration: t] ) ) {
		times = b;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] blinks: times];
	return copy;
}

-(void) update: (ccTime) t
{
	ccTime slice = 1.0f / times;
	ccTime m = fmodf(t, slice);
	[target setVisible: (m > slice/2) ? YES : NO];
}

-(CCIntervalAction*) reverse
{
	// return 'self'
	return [[self class] actionWithDuration: duration blinks: times];
}
@end

//
// FadeIn
//
#pragma mark -
#pragma mark FadeIn
@implementation CCFadeIn
-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>) target setOpacity: 255 *t];
}
-(CCIntervalAction*) reverse
{
	return [CCFadeOut actionWithDuration: duration];
}
@end

//
// FadeOut
//
#pragma mark -
#pragma mark FadeOut
@implementation CCFadeOut
-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>) target setOpacity: 255 *(1-t)];
}
-(CCIntervalAction*) reverse
{
	return [CCFadeIn actionWithDuration: duration];
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
		toOpacity = o;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] opacity: toOpacity];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
	fromOpacity = [(id<CCRGBAProtocol>)target opacity];
}

-(void) update: (ccTime) t
{
	[(id<CCRGBAProtocol>)target setOpacity: fromOpacity + ( toOpacity - fromOpacity ) * t];
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
	if( (self=[super initWithDuration: t] ) ) {
		to = ccc3(r,g,b);
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [(CCTintTo*)[[self class] allocWithZone: zone] initWithDuration: [self duration] red:to.r green:to.g blue:to.b];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target;
	from = [tn color];
}

-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target;
	[tn setColor:ccc3(from.r + (to.r - from.r) * t, from.g + (to.g - from.g) * t, from.b + (to.b - from.b) * t)];
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
		deltaR = r;
		deltaG = g;
		deltaB = b;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return[(CCTintBy*)[[self class] allocWithZone: zone] initWithDuration: [self duration] red:deltaR green:deltaG blue:deltaB];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target;
	ccColor3B color = [tn color];
	fromR = color.r;
	fromG = color.g;
	fromB = color.b;
}

-(void) update: (ccTime) t
{
	id<CCRGBAProtocol> tn = (id<CCRGBAProtocol>) target;
	[tn setColor:ccc3( fromR + deltaR * t, fromG + deltaG * t, fromB + deltaB * t)];
}
- (CCIntervalAction*) reverse
{
	return [CCTintBy actionWithDuration:duration red:-deltaR green:-deltaG blue:-deltaB];
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
	return [[self class] actionWithDuration:duration];
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
	if( !(self=[super initWithDuration: [action duration]]) )
		return nil;
	
	other = [action retain];
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithAction:[[other copy] autorelease] ];
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[other startWithTarget:target];
}

-(void) stop
{
	[other stop];
	[super stop];
}

-(void) update:(ccTime)t
{
	[other update:1-t];
}

-(CCIntervalAction*) reverse
{
	return [[other copy] autorelease];
}
@end

//
// Animate
//

#pragma mark -
#pragma mark Animate
@implementation CCAnimate

@synthesize animation = animation_;

+(id) actionWithAnimation: (id<CCAnimationProtocol>)anim
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:YES] autorelease];
}

+(id) actionWithAnimation: (id<CCAnimationProtocol>)anim restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:b] autorelease];
}

+(id) actionWithDuration:(ccTime)duration animation: (id<CCAnimationProtocol>)anim restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithDuration:duration animation:anim restoreOriginalFrame:b] autorelease];
}

-(id) initWithAnimation: (id<CCAnimationProtocol>)anim
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	return [self initWithAnimation:anim restoreOriginalFrame:YES];
}

-(id) initWithAnimation: (id<CCAnimationProtocol>)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");

	if( (self=[super initWithDuration: [[anim frames] count] * [anim delay]]) ) {

		restoreOriginalFrame = b;
		self.animation = anim;
		origFrame = nil;
	}
	return self;
}

-(id) initWithDuration:(ccTime)aDuration animation: (id<CCAnimationProtocol>)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	
	if( (self=[super initWithDuration:aDuration] ) ) {
		
		restoreOriginalFrame = b;
		self.animation = anim;
		origFrame = nil;
	}
	return self;
}


-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:duration animation:animation_ restoreOriginalFrame:restoreOriginalFrame];
}

-(void) dealloc
{
	[animation_ release];
	[origFrame release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	id<CCFrameProtocol> sprite = (id<CCFrameProtocol>) target;

	[origFrame release];

	if( restoreOriginalFrame )
		origFrame = [[sprite displayedFrame] retain];
}

-(void) stop
{
	if( restoreOriginalFrame ) {
		id<CCFrameProtocol> sprite = (id<CCFrameProtocol>) target;
		[sprite setDisplayFrame:origFrame];
	}
	
	[super stop];
}

-(void) update: (ccTime) t
{
	NSUInteger idx=0;
	
	NSArray *frames = [animation_ frames];
	NSUInteger numberOfFrames = [frames count];
	ccTime slice = 1.0f / numberOfFrames;
	
	if(t !=0 )
		idx = t/ slice;

	if( idx >= numberOfFrames ) {
		idx = numberOfFrames -1;
	}
	id<CCFrameProtocol> sprite = (id<CCFrameProtocol>) target;
	if (! [sprite isFrameDisplayed: [frames objectAtIndex: idx]] ) {
		[sprite setDisplayFrame: [frames objectAtIndex:idx]];
	}
}

- (CCIntervalAction *) reverse
{
	NSArray *oldArray = [animation_ frames];
	NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[oldArray count]];
    NSEnumerator *enumerator = [oldArray reverseObjectEnumerator];
    for (id element in enumerator) {
        [newArray addObject:[[element copy] autorelease]];
    }
	
	CCAnimation *newAnim = [CCAnimation animationWithName:animation_.name delay:animation_.delay frames:newArray];
	return [[self class] actionWithDuration:duration animation:newAnim restoreOriginalFrame:restoreOriginalFrame];
}

@end
