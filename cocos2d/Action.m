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

@end

//
// Sequence
//
@implementation Sequence

-(id) initOne: (IntervalAction*) one two: (IntervalAction*) two
{
	double d = [one duration] + [two duration];
	[super initWithDuration: d];
	
	actions = [[NSArray arrayWithObjects: one, two, nil] retain];
	
	return self;
}

-(void) start
{
	[super start];
	for( Action * action in actions )
		[action setTarget: target];
	
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
@end


//
// RotateBy
//
@implementation RotateBy
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
	start_angle = [target rotation];
}

-(void) update: (double) t
{	
	// XXX: shall I add % 360
	[target setRotation: (start_angle + angle * t ) ];
}
@end

//
// MoveBy
//
@implementation MoveBy
-(id) initWithDuration: (double) t delta: (CGPoint) p
{
	if( ![super initWithDuration: t] )
		return nil;

	delta = p;
	return self;
}

-(void) start
{
	[super start];
	startPos = [target position];
}

-(void) update: (double) t
{	
	[target setPosition: CGPointMake( (startPos.x + delta.x * t ), (startPos.y + delta.y * t )) ];
}
@end

//
// ScaleBy
//
@implementation ScaleBy
-(id) initWithDuration: (double) t scale:(float) s
{
	if( ![super initWithDuration: t] )
		return nil;

	scale = s;
	return self;
}

-(void) start
{
	[super start];
	start_scale = [target scale];
}

-(void) update: (double) t
{	
	[target setScale: (start_scale + scale * t ) ];	
}
@end


