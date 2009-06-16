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


#import "IntervalAction.h"
#import "Sprite.h"
#import "CocosNode.h"
#import "Support/CGPointExtension.h"

//
// IntervalAction
//
#pragma mark -
#pragma mark IntervalAction
@implementation IntervalAction

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
	if( !(self=[super init]) )
		return nil;
	
	duration = d;
	elapsed = 0.0f;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] ];
	return copy;
}


- (BOOL) isDone
{
	return (elapsed >= duration);
}

-(void) step: (ccTime) dt
{
	elapsed += dt;
	[self update: MIN(1, elapsed/duration)];
}

-(void) start
{
	if( gettimeofday( &lastUpdate, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	
	elapsed = 0.0f;
}

- (IntervalAction*) reverse
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
@implementation Sequence
+(id) actionOne: (FiniteTimeAction*) one two: (FiniteTimeAction*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

+(id) actions: (FiniteTimeAction*) action1, ...
{
	va_list params;
	va_start(params,action1);
	
	FiniteTimeAction *now;
	FiniteTimeAction *prev = action1;
	
	while( action1 ) {
		now = va_arg(params,FiniteTimeAction*);
		if ( now )
			prev = [Sequence actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

-(id) initOne: (FiniteTimeAction*) one_ two: (FiniteTimeAction*) two_
{
	NSAssert( one_!=nil, @"Sequence: argument one must be non-nil");
	NSAssert( two_!=nil, @"Sequence: argument two must be non-nil");

	FiniteTimeAction *one = one_;
	FiniteTimeAction *two = two_;
		
	ccTime d = [one duration] + [two duration];
	[super initWithDuration: d];
	
	actions = [[NSArray arrayWithObjects: one, two, nil] retain];
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone:zone] initOne:[[[actions objectAtIndex:0] copy] autorelease] two:[[[actions objectAtIndex:1] copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[actions release];
	[super dealloc];
}

-(void) start
{
	[super start];
	for( Action * action in actions )
		action.target = target;
	
	split = [[actions objectAtIndex:0] duration] / duration;
	last = -1;
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
		[[actions objectAtIndex:0] start];
		[[actions objectAtIndex:0] update:1.0f];
		[[actions objectAtIndex:0] stop];
	}

	if (last != found ) {
		if( last != -1 ) {
			[[actions objectAtIndex: last] update: 1.0f];
			[[actions objectAtIndex: last] stop];
		}
		[[actions objectAtIndex: found] start];
	}
	[[actions objectAtIndex:found] update: new_t];
	last = found;
}

- (IntervalAction *) reverse
{
	return [Sequence actionOne: [[actions objectAtIndex:1] reverse] two: [[actions objectAtIndex:0] reverse ] ];
}
@end

//
// Repeat
//
#pragma mark -
#pragma mark Repeat
@implementation Repeat
+(id) actionWithAction: (FiniteTimeAction*) action times: (unsigned int) t
{
	return [[[self alloc] initWithAction: action times: t] autorelease];
}

-(id) initWithAction: (FiniteTimeAction*) action times: (unsigned int) t
{
	ccTime d = [action duration] * t;

	if( !(self=[super initWithDuration: d ]) )
		return nil;

	times = t;
	other = [action retain];

	total = 0;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone:zone] initWithAction:[[other copy] autorelease] times:times];
	return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) start
{
	total = 0;
	[super start];
	other.target = target;
	[other start];
}

//-(void) step:(ccTime) dt
//{
//	[other step: dt];
//	if( [other isDone] ) {
//		total++;
//		[other start];
//	}
//}

// issue #80. Instead of hooking step:, hook update: since it can be called by any 
// container action like Repeat, Sequence, AccelDeccel, etc..
-(void) update:(ccTime) dt
{
	ccTime t = dt * times;
	float r = fmodf(t, 1.0f);
	if( t > total+1 ) {
		[other update:1.0f];
		total++;
		[other stop];
		[other start];
		[other update:0.0f];
	} else {
		// fix last repeat position
		// else it could be 0.
		if( dt== 1.0f)
			r=1.0f;
		[other update: MIN(r,1)];
	}
}

-(BOOL) isDone
{
	return ( total == times );
}

- (IntervalAction *) reverse
{
	return [Repeat actionWithAction:[other reverse] times: times];
}
@end

//
// Spawn
//
#pragma mark -
#pragma mark Spawn

@implementation Spawn
+(id) actions: (FiniteTimeAction*) action1, ...
{
	va_list params;
	va_start(params,action1);
	
	FiniteTimeAction *now;
	FiniteTimeAction *prev = action1;
	
	while( action1 ) {
		now = va_arg(params,FiniteTimeAction*);
		if ( now )
			prev = [Spawn actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

+(id) actionOne: (FiniteTimeAction*) one two: (FiniteTimeAction*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

-(id) initOne: (FiniteTimeAction*) one_ two: (FiniteTimeAction*) two_
{
	NSAssert( one_!=nil, @"Spawn: argument one must be non-nil");
	NSAssert( two_!=nil, @"Spawn: argument two must be non-nil");

	ccTime d1 = [one_ duration];
	ccTime d2 = [two_ duration];	
	
	[super initWithDuration: fmaxf(d1,d2)];

	one = one_;
	two = two_;

	if( d1 > d2 )
		two = [Sequence actionOne: two_ two:[DelayTime actionWithDuration: (d1-d2)] ];
	else if( d1 < d2)
		one = [Sequence actionOne: one_ two: [DelayTime actionWithDuration: (d2-d1)] ];
	
	[one retain];
	[two retain];
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initOne: [[one copy] autorelease] two: [[two copy] autorelease] ];
	return copy;
}

-(void) dealloc
{
	[one release];
	[two release];
	[super dealloc];
}

-(void) start
{
	[super start];
	one.target = target;
	two.target = target;
	[one start];
	[two start];
}

-(void) update: (ccTime) t
{
	[one update:t];
	[two update:t];
}

- (IntervalAction *) reverse
{
	return [Spawn actionOne: [one reverse] two: [two reverse ] ];
}
@end

//
// RotateTo
//
#pragma mark -
#pragma mark RotateTo

@implementation RotateTo
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
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] angle: angle];
	return copy;
}

-(void) start
{
	[super start];
	startAngle = target.rotation;
	angle -= startAngle;
	if (angle > 180)
		angle = -360 + angle;
	if (angle < -180)
		angle = 360 + angle;
}
-(void) update: (ccTime) t
{
	target.rotation = startAngle + angle * t;
}
@end


//
// RotateBy
//
#pragma mark -
#pragma mark RotateBy

@implementation RotateBy
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
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] angle: angle];
	return copy;
}

-(void) start
{
	[super start];
	startAngle = [target rotation];
}

-(void) update: (ccTime) t
{	
	// XXX: shall I add % 360
	target.rotation = (startAngle + angle * t );
}

-(IntervalAction*) reverse
{
	return [RotateBy actionWithDuration: duration angle: -angle];
}

@end

//
// MoveTo
//
#pragma mark -
#pragma mark MoveTo

@implementation MoveTo
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
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: endPosition];
	return copy;
}

-(void) start
{
	[super start];
	startPosition = [target position];
	delta = ccpSub( endPosition, startPosition );
}

-(void) update: (ccTime) t
{	
	target.position = ccp( (startPosition.x + delta.x * t ), (startPosition.y + delta.y * t ) );
}
@end

//
// MoveBy
//
#pragma mark -
#pragma mark MoveBy

@implementation MoveBy
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
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: delta];
	return copy;
}

-(void) start
{
	CGPoint dTmp = delta;
	[super start];
	delta = dTmp;
}

-(IntervalAction*) reverse
{
	return [MoveBy actionWithDuration: duration position: ccp( -delta.x, -delta.y)];
}
@end

//
// JumpBy
//
#pragma mark -
#pragma mark JumpBy

@implementation JumpBy
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
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] position: delta height:height jumps:jumps];
	return copy;
}

-(void) start
{
	[super start];
	startPosition = target.position;
}

-(void) update: (ccTime) t
{
	ccTime y = height * fabsf( sinf(t * (CGFloat)M_PI * jumps ) );
	y += delta.y * t;
	ccTime x = delta.x * t;
	target.position = ccp( startPosition.x + x, startPosition.y + y );
}

-(IntervalAction*) reverse
{
	return [JumpBy actionWithDuration: duration position: ccp(-delta.x,-delta.y) height: height jumps:jumps];
}
@end

//
// JumpTo
//
#pragma mark -
#pragma mark JumpTo

@implementation JumpTo
-(void) start
{
	[super start];
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
@implementation BezierBy
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
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] bezier: config];
    return copy;
}

-(void) start
{
	[super start];
	startPosition = target.position;
}

-(void) update: (ccTime) t
{
	float xa = config.startPosition.x;
	float xb = config.controlPoint_1.x;
	float xc = config.controlPoint_2.x;
	float xd = config.endPosition.x;
	
	float ya = config.startPosition.y;
	float yb = config.controlPoint_1.y;
	float yc = config.controlPoint_2.y;
	float yd = config.endPosition.y;
	
	float x = bezierat(xa, xb, xc, xd, t);
	float y = bezierat(ya, yb, yc, yd, t);
	target.position = ccpAdd( startPosition, ccp(x,y));
}

- (IntervalAction*) reverse
{
	// XXX: reverse it's not working as expected
	ccBezierConfig r;
	r.startPosition = ccpNeg( config.startPosition);
	r.endPosition = ccpNeg(config.endPosition);
	r.controlPoint_1 = ccpNeg(config.controlPoint_1);
	r.controlPoint_2 = ccpNeg(config.controlPoint_2);
	
	BezierBy *action = [BezierBy actionWithDuration:[self duration] bezier:r];
	return action;
}
@end

//
// ScaleTo
//
#pragma mark -
#pragma mark ScaleTo
@implementation ScaleTo
+(id) actionWithDuration: (ccTime) t scale:(float) s
{
	return [[[self alloc] initWithDuration: t scale:s] autorelease];
}

-(id) initWithDuration: (ccTime) t scale:(float) s
{
	if( !(self=[super initWithDuration: t]) )
		return nil;
	
	endScaleX = s;
	endScaleY = s;
	return self;
}

+(id) actionWithDuration: (ccTime) t scaleX:(float)sx scaleY:(float)sy 
{
	return [[[self alloc] initWithDuration: t scaleX:sx scaleY:sy] autorelease];
}

-(id) initWithDuration: (ccTime) t scaleX:(float)sx scaleY:(float)sy
{
	if( !(self=[super initWithDuration: t]) )
		return nil;
	
	endScaleX = sx;
	endScaleY = sy;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] scaleX:endScaleX scaleY:endScaleY];
	return copy;
}

-(void) start
{
	[super start];
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
@implementation ScaleBy
-(void) start
{
	[super start];
	deltaX = startScaleX * endScaleX - startScaleX;
	deltaY = startScaleY * endScaleY - startScaleY;
}

-(IntervalAction*) reverse
{
	return [ScaleBy actionWithDuration: duration scaleX: 1/endScaleX scaleY:1/endScaleY];
}
@end

//
// Blink
//
#pragma mark -
#pragma mark Blink
@implementation Blink
+(id) actionWithDuration: (ccTime) t blinks: (unsigned int) b
{
	return [[[ self alloc] initWithDuration: t blinks: b] autorelease];
}

-(id) initWithDuration: (ccTime) t blinks: (unsigned int) b
{
	if( ! (self=[super initWithDuration: t] ) )
		return nil;
	times = b;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] blinks: times];
	return copy;
}

-(void) update: (ccTime) t
{
	ccTime slice = 1.0f / times;
	ccTime m = fmodf(t, slice);
	target.visible = (m > slice/2) ? YES : NO;
}

-(IntervalAction*) reverse
{
	// return 'self'
	return [Blink actionWithDuration: duration blinks: times];
}
@end

//
// FadeIn
//
#pragma mark -
#pragma mark FadeIn
@implementation FadeIn
-(void) update: (ccTime) t
{
	[(id<CocosNodeRGBA>) target setOpacity: 255 *t];
}
-(IntervalAction*) reverse
{
	return [FadeOut actionWithDuration: duration];
}
@end

//
// FadeOut
//
#pragma mark -
#pragma mark FadeOut
@implementation FadeOut
-(void) update: (ccTime) t
{
	[(id<CocosNodeRGBA>) target setOpacity: 255 *(1-t)];
}
-(IntervalAction*) reverse
{
	return [FadeIn actionWithDuration: duration];
}
@end

//
// FadeTo
//
#pragma mark -
#pragma mark FadeTo
@implementation FadeTo
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
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] opacity: toOpacity];
	return copy;
}

-(void) start
{
	[super start];
	fromOpacity = [(id<CocosNodeRGBA>)target opacity];
}

-(void) update: (ccTime) t
{
	[(id<CocosNodeRGBA>)target setOpacity: fromOpacity + ( toOpacity - fromOpacity ) * t];
}
@end

//
// TintTo
//
#pragma mark -
#pragma mark TintTo
@implementation TintTo
+(id) actionWithDuration:(ccTime)t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b
{
	return [[(TintTo*)[ self alloc] initWithDuration:t red:r green:g blue:b] autorelease];
}

-(id) initWithDuration: (ccTime) t red:(GLubyte)r green:(GLubyte)g blue:(GLubyte)b
{
	if( (self=[super initWithDuration: t] ) ) {
		toR = r;
		toG = g;
		toB = b;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [(TintTo*)[[self class] allocWithZone: zone] initWithDuration: [self duration] red:toR green:toG blue:toB];
	return copy;
}

-(void) start
{
	[super start];
	
	id<CocosNodeRGBA> tn = (id<CocosNodeRGBA>) target;
	
	fromR = [tn r];
	fromG = [tn g];
	fromB = [tn b];
}

-(void) update: (ccTime) t
{
	id<CocosNodeRGBA> tn = (id<CocosNodeRGBA>) target;
	[tn setRGB:fromR + (toR - fromR) * t :fromG + (toG - fromG) * t :fromB + (toB - fromB) * t];
}
@end

//
// TintBy
//
#pragma mark -
#pragma mark TintBy
@implementation TintBy
+(id) actionWithDuration:(ccTime)t red:(GLshort)r green:(GLshort)g blue:(GLshort)b
{
	return [[(TintBy*)[ self alloc] initWithDuration:t red:r green:g blue:b] autorelease];
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
	return[(TintBy*)[[self class] allocWithZone: zone] initWithDuration: [self duration] red:deltaR green:deltaG blue:deltaB];
}

-(void) start
{
	[super start];
	
	id<CocosNodeRGBA> tn = (id<CocosNodeRGBA>) target;
	fromR = [tn r];
	fromG = [tn g];
	fromB = [tn b];
}

-(void) update: (ccTime) t
{
	id<CocosNodeRGBA> tn = (id<CocosNodeRGBA>) target;
	[tn setRGB:fromR + deltaR * t :fromG + deltaG * t :fromB + deltaB * t];
}
- (IntervalAction*) reverse
{
	return [TintBy actionWithDuration:duration red:-deltaR green:-deltaG blue:-deltaB];
}
@end

//
// DelayTime
//
#pragma mark -
#pragma mark DelayTime
@implementation DelayTime
-(void) update: (ccTime) t
{
	return;
}

-(id)reverse
{
	return [DelayTime actionWithDuration:duration];
}
@end

//
// ReverseTime
//
#pragma mark -
#pragma mark ReverseTime
@implementation ReverseTime
+(id) actionWithAction: (FiniteTimeAction*) action
{
	// casting to prevent warnings
	ReverseTime *a = [super alloc];
	return [[a initWithAction:action] autorelease];
}

-(id) initWithAction: (FiniteTimeAction*) action
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

-(void) start
{
	[super start];
	other.target = target;
	[other start];
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

-(IntervalAction*) reverse
{
	return [[other copy] autorelease];
}
@end

//
// Animate
//
#pragma mark -
#pragma mark Animate
@implementation Animate

+(id) actionWithAnimation: (id<CocosAnimation>)anim
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:YES] autorelease];
}

+(id) actionWithAnimation: (id<CocosAnimation>)anim restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithAnimation:anim restoreOriginalFrame:b] autorelease];
}

-(id) initWithAnimation: (id<CocosAnimation>)anim
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");
	return [self initWithAnimation:anim restoreOriginalFrame:YES];
}

-(id) initWithAnimation: (id<CocosAnimation>)anim restoreOriginalFrame:(BOOL) b
{
	NSAssert( anim!=nil, @"Animate: argument Animation must be non-nil");

	if( (self=[super initWithDuration: [[anim frames] count] * [anim delay]]) ) {

		restoreOriginalFrame = b;
		animation = [anim retain];
		origFrame = nil;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithAnimation: animation];
}

-(void) dealloc
{
	[animation release];
	[origFrame release];
	[super dealloc];
}

-(void) start
{
	[super start];
	id<CocosNodeFrames> sprite = (id<CocosNodeFrames>) target;

	[origFrame release];

	origFrame = [[sprite displayFrame] retain];
}

-(void) stop
{
	if( restoreOriginalFrame ) {
		id<CocosNodeFrames> sprite = (id<CocosNodeFrames>) target;
		[sprite setDisplayFrame:origFrame];
	}
	
	[super stop];
}

-(void) update: (ccTime) t
{
	NSUInteger idx=0;
	
	ccTime slice = 1.0f / [[animation frames] count];
	
	if(t !=0 )
		idx = t/ slice;

	if( idx >= [[animation frames] count] ) {
		idx = [[animation frames] count] -1;
	}
	id<CocosNodeFrames> sprite = (id<CocosNodeFrames>) target;
	if (! [sprite isFrameDisplayed: [[animation frames] objectAtIndex: idx]] ) {
		[sprite setDisplayFrame: [[animation frames] objectAtIndex:idx]];
	}
}
@end
