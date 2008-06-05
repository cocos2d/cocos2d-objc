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

@property (readwrite,retain) CocosNode *target;

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

+(id) actionWithDuration: (double) d;
-(id) initWithDuration: (double) d;
-(void) step;
-(void) start;
-(BOOL) isDone;
-(double) getDeltaTime;
- (IntervalAction*) reverse;
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
+(id) actions: (IntervalAction*) action1, ...;
+(id) actionOne: (IntervalAction*) one two:(IntervalAction*) two;
-(id) initOne: (IntervalAction*) one two:(IntervalAction*) two;
@end

//
// RotateTo
//
@interface RotateTo : IntervalAction
{
	float angle;
	float startAngle;
}
+(id) actionWithDuration: (double) t angle:(float) a;
-(id) initWithDuration: (double) t angle:(float) a;
@end

//
// RotateBy
//
@interface RotateBy : IntervalAction
{
	float angle;
	float startAngle;
}
+(id) actionWithDuration: (double) t angle:(float) a;
-(id) initWithDuration: (double) t angle:(float) a;
@end

//
// MoveTo
//
@interface MoveTo : IntervalAction
{
	CGPoint endPosition;
	CGPoint startPosition;
	CGPoint delta;
}
+(id) actionWithDuration: (double) t position: (CGPoint) pos;
-(id) initWithDuration: (double) t position: (CGPoint) pos;
@end

//
// MoveBy
//
@interface MoveBy : MoveTo
{
}
+(id) actionWithDuration: (double) t delta: (CGPoint) delta;
-(id) initWithDuration: (double) t delta: (CGPoint) delta;
@end

//
// ScaleTo
//
@interface ScaleTo : IntervalAction
{
	float scale;
	float startScale;
	float endScale;
	float delta;
}

+(id) actionWithDuration: (double) t scale:(float) s;
-(id) initWithDuration: (double) t scale:(float) s;
@end

//
// ScaleBy
//
@interface ScaleBy : ScaleTo
{
}
@end

//
// Accelerate
//
@interface Accelerate: IntervalAction
{
	IntervalAction *other;
	float rate;
}
+(id) actionWithAction: (IntervalAction*) action rate: (float) rate;
-(id) initWithAction: (IntervalAction*) action rate: (float) rate;
@end

//
// Delay
//
@interface DelayTime : IntervalAction
{
}
@end
