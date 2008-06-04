//
//  Action.h
//  test-opengl2
//
//  Created by Ricardo Quesada on 30/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#include <sys/time.h>

@class CocosNode;

@interface Action : NSObject {
	CocosNode *target;	
}

@property (readwrite,assign) CocosNode *target;

-(void) start;
-(BOOL) isDone;
-(void) stop;
-(void) step;
-(void) update: (double) time;

@end

//
// InstantAction
//
@interface InstantAction : Action
{
}

-(void) step;
-(BOOL) isDone;
@end

//
// IntervalAction
//
@interface IntervalAction: Action
{
	struct timeval lastUpdate;
	double elapsed;
	double duration;	
}

@property (readwrite,assign) double duration;

-(id) initWithDuration: (double) d;
-(void) step;
-(void) start;
-(BOOL) isDone;
-(double) getDeltaTime;
@end

//
// Sequence
//
@interface Sequence : IntervalAction
{
	NSArray *actions;
	double split;
	int last;
}
-(id) initOne: (IntervalAction*) one two:(IntervalAction*) two;
@end

//
// RotateBy
//
@interface RotateBy : IntervalAction
{
	float angle;
	float start_angle;
}
-(id) initWithDuration: (double) t angle:(float) a;
@end

//
// MoveBy
//
@interface MoveBy : IntervalAction
{
	CGPoint delta;
	CGPoint startPos;
}
-(id) initWithDuration: (double) t delta: (CGPoint) delta;
@end

//
// ScaleBy
//
@interface ScaleBy : IntervalAction
{
	float scale;
	float start_scale;
}
-(id) initWithDuration: (double) t scale:(float) s;
@end