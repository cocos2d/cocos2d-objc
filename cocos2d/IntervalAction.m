/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
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

//
// IntervalAction
//
@implementation IntervalAction

@synthesize duration;

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
@implementation Sequence
+(id) actionOne: (IntervalAction*) one two: (IntervalAction*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

+(id) actions: (IntervalAction*) action1, ...
{
	va_list params;
	va_start(params,action1);
	
	IntervalAction *now;
	IntervalAction *prev = action1;
	
	while( action1 ) {
		now = va_arg(params,IntervalAction*);
		if ( now )
			prev = [Sequence actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

-(id) initOne: (IntervalAction*) one_ two: (IntervalAction*) two_
{
	NSAssert( one_!=nil, @"Sequence: argument one must be non-nil");
	NSAssert( two_!=nil, @"Sequence: argument two must be non-nil");

	IntervalAction *one = one_;
	IntervalAction *two = two_;
		
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
@implementation Repeat
+(id) actionWithAction: (IntervalAction*) action times: (unsigned int) t
{
	return [[[self alloc] initWithAction: action times: t] autorelease];
}

-(id) initWithAction: (IntervalAction*) action times: (unsigned int) t
{
	int d = [action duration] * t;

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
@implementation Spawn
+(id) actions: (IntervalAction*) action1, ...
{
	va_list params;
	va_start(params,action1);
	
	IntervalAction *now;
	IntervalAction *prev = action1;
	
	while( action1 ) {
		now = va_arg(params,IntervalAction*);
		if ( now )
			prev = [Spawn actionOne: prev two: now];
		else
			break;
	}
	va_end(params);
	return prev;
}

+(id) actionOne: (IntervalAction*) one two: (IntervalAction*) two
{	
	return [[[self alloc] initOne:one two:two ] autorelease];
}

-(id) initOne: (IntervalAction*) one_ two: (IntervalAction*) two_
{
	NSAssert( one_!=nil, @"Spawn: argument one must be non-nil");
	NSAssert( two_!=nil, @"Spawn: argument two must be non-nil");

	ccTime d1 = [one_ duration];
	ccTime d2 = [two_ duration];	
	
	[super initWithDuration: fmaxf(d1,d2)];

	one = one_;
	two = two_;

	if( d1 > d2 )
		two = [Sequence actions: two_, [DelayTime actionWithDuration: (d1-d2)], nil];
	else if( d1 < d2)
		one = [Sequence actions: one_, [DelayTime actionWithDuration: (d2-d1)], nil];
	
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
	[target do: one];
	[target do: two];
}

-(BOOL) isDone
{
	return [one isDone] && [two isDone];	
}
-(void) update: (ccTime) t
{
	// ignore. not needed
}

- (IntervalAction *) reverse
{
	return [Spawn actionOne: [one reverse] two: [two reverse ] ];
}
@end

//
// RotateTo
//
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
@implementation MoveTo
+(id) actionWithDuration: (ccTime) t position: (cpVect) p
{	
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (cpVect) p
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
	delta = cpvsub( endPosition, startPosition );
}

-(void) update: (ccTime) t
{	
	target.position = cpv( (startPosition.x + delta.x * t ), (startPosition.y + delta.y * t ) );
}
@end

//
// MoveBy
//
@implementation MoveBy
+(id) actionWithDuration: (ccTime) t position: (cpVect) p
{	
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (cpVect) p
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
	cpVect dTmp = delta;
	[super start];
	delta = dTmp;
}

-(IntervalAction*) reverse
{
	return [MoveBy actionWithDuration: duration position: cpv( -delta.x, -delta.y)];
}
@end

//
// JumpBy
//
@implementation JumpBy
+(id) actionWithDuration: (ccTime) t position: (cpVect) pos height: (ccTime) h jumps:(int)j
{
	return [[[self alloc] initWithDuration: t position: pos height: h jumps:j] autorelease];
}

-(id) initWithDuration: (ccTime) t position: (cpVect) pos height: (ccTime) h jumps:(int)j
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
	ccTime y = height * fabsf( sinf(t * (cpFloat)M_PI * jumps ) );
	y += delta.y * t;
	ccTime x = delta.x * t;
	target.position = cpv( startPosition.x + x, startPosition.y + y );
}

-(IntervalAction*) reverse
{
	return [JumpBy actionWithDuration: duration position: cpv(-delta.x,-delta.y) height: height jumps:jumps];
}
@end

//
// JumpTo
//
@implementation JumpTo
-(void) start
{
	[super start];
	delta = cpv( delta.x - startPosition.x, delta.y - startPosition.y );
}
@end

//
// ScaleTo
//
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
	Action *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] scaleX: endScaleX scaleY:endScaleY];
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
@implementation Blink
+(id) actionWithDuration: (ccTime) t blinks: (int) b
{
	return [[[ self alloc] initWithDuration: t blinks: b] autorelease];
}

-(id) initWithDuration: (ccTime) t blinks: (int) b
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
@implementation FadeIn
-(void) update: (ccTime) t
{
	[(id<CocosNodeOpacity>) target setOpacity: 255 *t];
}
-(IntervalAction*) reverse
{
	return [FadeOut actionWithDuration: duration];
}
@end

//
// FadeOut
//
@implementation FadeOut
-(void) update: (ccTime) t
{
	[(id<CocosNodeOpacity>) target setOpacity: 255 *(1-t)];
}
-(IntervalAction*) reverse
{
	return [FadeIn actionWithDuration: duration];
}
@end

//
// FadeTo
//
@implementation FadeTo
+(id) actionWithDuration: (ccTime) t opacity: (GLubyte) o
{
	return [[[ self alloc] initWithDuration: t opacity: o] autorelease];
}

-(id) initWithDuration: (ccTime) t opacity: (GLubyte) o
{
	if( ! (self=[super initWithDuration: t] ) )
		return nil;
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
	fromOpacity = [(id<CocosNodeOpacity>)target opacity];
}

-(void) update: (ccTime) t
{
	[(id<CocosNodeOpacity>)target setOpacity: fromOpacity + ( toOpacity - fromOpacity ) * t];
}
@end

//
// Accelerate
//
@implementation Accelerate
@synthesize rate;
+ (id) actionWithAction: (IntervalAction*) action rate: (float) r
{
	return [[[self alloc] initWithAction:action rate:r ] autorelease];
}

- (id) initWithAction: (IntervalAction*) action rate: (float) r
{	
	NSAssert( action!=nil, @"Accelerate: argument action must be non-nil");

	if( ! (self=[super initWithDuration: [action duration]]) )
		return nil;

	other = [action retain];
	
	rate = r;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithAction: [[other copy] autorelease] rate: rate];
	return copy;
}

- (void) dealloc
{
	[other release];
	[super dealloc];
}

- (void) start
{
	[super start];
	other.target = target;
	[other start];
}

- (void) update: (ccTime) t
{
	[other update: powf(t,rate) ];
}

- (IntervalAction*) reverse
{
	return [Accelerate actionWithAction: [other reverse] rate: 1/rate];
}
@end

//
// AccelDeccel
//
@implementation AccelDeccel
+(id) actionWithAction: (IntervalAction*) action
{
	return [[[self alloc] initWithAction: action ] autorelease ];
}

-(id) initWithAction: (IntervalAction*) action
{
	NSAssert( action!=nil, @"AccelDeccel: argument action must be non-nil");

	if( !(self=[super initWithDuration: action.duration ]) )
		return nil;

	other = [action retain];
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithAction: [[other copy] autorelease] ];
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
	ccTime ft = (t-0.5f) * 12;
	ccTime nt = 1.0f/( 1.0f + expf(-ft) );
	[other update: nt];	
}

-(IntervalAction*) reverse
{
	return [AccelDeccel actionWithAction: [other reverse]];
}
@end

//
// Speed
//
@implementation Speed
@synthesize speed;
+(id) actionWithAction: (IntervalAction*) action speed:(ccTime) s
{
	return [[[self alloc] initWithAction: action speed:s] autorelease ];
}

-(id) initWithAction: (IntervalAction*) action speed:(ccTime) s
{
	NSAssert( action!=nil, @"Speed: argument action must be non-nil");

	if( !(self=[super initWithDuration: action.duration / s ]) )
		return nil;
	
	other = [action retain];
	
	speed = s;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone:zone] initWithAction:[[other copy] autorelease] speed:speed];
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
	return [Speed actionWithAction: [other reverse] speed:speed];
}
@end


//
// DelayTime
//
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

@implementation ReverseTime
+(id) actionWithAction: (IntervalAction*) action
{
	return [[[super alloc] initWithAction:action] autorelease];
}

-(id) initWithAction: (IntervalAction*) action
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
@implementation Animate

+(id) actionWithAnimation: (Animation*) a
{
	return [[[self alloc] initWithAnimation: a restoreOriginalFrame:YES] autorelease];
}

+(id) actionWithAnimation: (Animation*) a restoreOriginalFrame:(BOOL)b
{
	return [[[self alloc] initWithAnimation: a restoreOriginalFrame:b] autorelease];
}

-(id) initWithAnimation: (Animation*) a
{
	NSAssert( a!=nil, @"Animate: argument Animation must be non-nil");
	return [self initWithAnimation:a restoreOriginalFrame:YES];
}

-(id) initWithAnimation: (Animation*) a restoreOriginalFrame:(BOOL) b
{
	NSAssert( a!=nil, @"Animate: argument Animation must be non-nil");

	if( !(self=[super initWithDuration: [[a frames] count] * [a delay]]) )
		return nil;

	restoreOriginalFrame = b;
	animation = [a retain];
	origFrame = nil;
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
	Sprite *s = (Sprite*) target;

	[[s texture] retain];
	[origFrame release];
	origFrame = [s texture];
}

-(void) stop
{
	
	if( restoreOriginalFrame ) {
		Sprite *s = (Sprite*) target;

		// XXX TODO should I retain ?
		// XXX NO, I should not retain it
		// TextureNode.texture shall be (retain) property
		[origFrame retain];
		[[s texture] release];
		[s setTexture: origFrame];
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
	Sprite *s = (Sprite*) target;
	if ( s.texture != [[animation frames] objectAtIndex: idx] ) {
		// XXX TODO should I retain ?
		// XXX NO, I should not retain it
		// TextureNode.texture shall be (retain) property
		id obj = [[animation frames] objectAtIndex:idx];
		[obj retain];
		[[s texture] release];
		[s setTexture: obj];
	}
}
@end

