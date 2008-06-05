//
//  Action.m
//  test-opengl2
//
//  Created by Ricardo Quesada on 30/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//


#import "Action.h"
#import "CocosNode.h"


//
// Action Base Class
//
@implementation Action

@synthesize target;

-(id) init
{
	if( ![super init] )
		return nil;
	
	target = nil;
	return self;
}

-(void) dealloc
{
	NSLog(@"deallocing %@", self);
	if( target )
		[target release];
	[super dealloc];
}

-(void) start
{
	// override me
}

-(void) stop
{
	// override me
}

-(BOOL) isDone
{
	return YES;
}

-(void) step
{
	NSLog(@"[Action step]. override me");
}

-(void) update: (double) time
{
	NSLog(@"[Action update]. override me");
}

@end


//
// InstantAction
//
@implementation InstantAction
- (BOOL) isDone
{
	return YES;
}
-(void) step
{
	[self update: 1];
}
@end


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

+(id) actionWithDuration: (double) d
{
	return [[[self alloc] initWithDuration:d ] autorelease];
}

-(id) initWithDuration: (double) d
{
	if( ![super init] )
		return nil;
	
	duration = d;
	elapsed = 0.0;
	return self;
}

- (BOOL) isDone
{
	return (elapsed >= duration);
}

-(void) step
{
	elapsed += [self getDeltaTime];
	[self update: MIN(1, elapsed/duration)];
}

- (double) getDeltaTime
{
	struct timeval now;
	double delta;	
	
	if( gettimeofday( &now, NULL) != 0 ) {
		NSException* myException = [NSException
									exceptionWithName:@"GetTimeOfDay"
									reason:@"GetTimeOfDay abnormal error"
									userInfo:nil];
		@throw myException;
	}
	
	delta = (lastUpdate.tv_sec - now.tv_sec) + (lastUpdate.tv_usec - now.tv_usec) / 1000000.0;
	
	memcpy( &lastUpdate, &now, sizeof(lastUpdate) );
	return -delta;
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
	
	elapsed = 0.0;
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

-(id) initOne: (IntervalAction*) one two: (IntervalAction*) two
{
	double d = [one duration] + [two duration];
	[super initWithDuration: d];
	
	actions = [[NSArray arrayWithObjects: one, two, nil] retain];
	
	return self;
}

-(void) dealloc
{
//	NSLog( @"deallocing %@", self);
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

-(void) update: (double) t
{
	int found = 0;
	double new_t = 0.0;
	
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
		[[actions objectAtIndex:0] update:1];
		[[actions objectAtIndex:0] stop];
	}

	if (last != found ) {
		if( last != -1 ) {
			[[actions objectAtIndex: last] update: 1];
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
// RotateTo
//
@implementation RotateTo
+(id) actionWithDuration: (double) t angle:(float) a
{	
	return [[[self alloc] initWithDuration:t angle:a ] autorelease];
}

-(id) initWithDuration: (double) t angle:(float) a
{
	if( ! [super initWithDuration: t] )
		return nil;
	[super initWithDuration: t];
	
	angle = a;
	return self;
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
-(void) update: (double) t
{
	target.rotation = startAngle + angle * t;
}
@end


//
// RotateBy
//
@implementation RotateBy
+(id) actionWithDuration: (double) t angle:(float) a
{	
	return [[[self alloc] initWithDuration:t angle:a ] autorelease];
}

-(id) initWithDuration: (double) t angle:(float) a
{
	if( ! [super initWithDuration: t] )
		return nil;
	[super initWithDuration: t];

	angle = a;
	return self;
}

-(void) start
{
	[super start];
	startAngle = [target rotation];
}

-(void) update: (double) t
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
+(id) actionWithDuration: (double) t position: (CGPoint) p
{	
	return [[[self alloc] initWithDuration:t position:p ] autorelease];
}

-(id) initWithDuration: (double) t position: (CGPoint) p
{
	if( ![super initWithDuration: t] )
		return nil;
	
	endPosition = p;
	return self;
}

-(void) start
{
	[super start];
	startPosition = [target position];
	delta.x = endPosition.x - startPosition.x;
	delta.y = endPosition.y - startPosition.y;	
}

-(void) update: (double) t
{	
	[target setPosition: CGPointMake( (startPosition.x + delta.x * t ), (startPosition.y + delta.y * t )) ];
}
@end

//
// MoveBy
//
@implementation MoveBy
+(id) actionWithDuration: (double) t delta: (CGPoint) p
{	
	return [[[self alloc] initWithDuration:t delta:p ] autorelease];
}

-(id) initWithDuration: (double) t delta: (CGPoint) p
{
	if( ![super initWithDuration: t] )
		return nil;

	delta = p;
	return self;
}

-(void) start
{
	CGPoint dTmp = delta;
	[super start];
	delta = dTmp;
}

-(IntervalAction*) reverse
{
	return [MoveBy actionWithDuration: duration delta: CGPointMake( -delta.x, -delta.y)];
}
@end

//
// ScaleTo
//
@implementation ScaleTo
+(id) actionWithDuration: (double) t scale:(float) s
{
	return [[[self alloc] initWithDuration: t scale:s] autorelease];
}

-(id) initWithDuration: (double) t scale:(float) s
{
	if( ![super initWithDuration: t] )
		return nil;
	
	endScale = s;
	return self;
}

-(void) start
{
	[super start];
	startScale = [target scale];
	delta = endScale - startScale;
}

-(void) update: (double) t
{	
	[target setScale: (startScale + delta * t ) ];	
}
@end

//
// ScaleBy
//
@implementation ScaleBy
-(void) start
{
	[super start];
	delta = startScale * endScale - startScale;
}

-(IntervalAction*) reverse
{
	return [ScaleBy actionWithDuration: duration scale: 1/endScale];
}
@end

//
// Accelerate
//
@implementation Accelerate
+ (id) actionWithAction: (IntervalAction*) action rate: (float) r
{
	return [[[self alloc] initWithAction:action rate:r ] autorelease];
}

- (id) initWithAction: (IntervalAction*) action rate: (float) r
{	
	if( ! [super initWithDuration: [action duration]] )
		return nil;
	
	other = [action retain];
	rate = r;
	return self;
}

- (void) dealloc
{
//	NSLog( @"deallocing %@", self);
	[other release];
	[super dealloc];
}

- (void) start
{
	[super start];
	other.target = target;
	[other start];
}

- (void) update: (double) t
{
	[other update: pow(t,rate) ];
}

- (IntervalAction*) reverse
{
	return [Accelerate actionWithAction: [other reverse] rate: 1/rate];
}
@end

//
// Delay
//
@implementation DelayTime
-(void) update: (double) t
{
	return;
}
@end


