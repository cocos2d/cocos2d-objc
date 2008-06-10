//
// cocos2d for iphone
// IntervalAction
//

#import <UIKit/UIKit.h>
#import "Action.h"

#include <sys/time.h>

//
// IntervalAction
//
@interface IntervalAction: Action <NSCopying>
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
@interface Sequence : IntervalAction <NSCopying>
{
	NSArray *actions;
	double split;
	int last;
}
+(id) actions: (IntervalAction*) action1, ... NS_REQUIRES_NIL_TERMINATION;
+(id) actionOne: (IntervalAction*) one two:(IntervalAction*) two;
-(id) initOne: (IntervalAction*) one two:(IntervalAction*) two;
@end

//
// Repeat
//
@interface Repeat : IntervalAction <NSCopying>
{
	unsigned int times;
	unsigned int total;
	IntervalAction *other;
}
+(id) actionWithAction: (IntervalAction*) action times: (unsigned int) t;
-(id) initWithAction: (IntervalAction*) action times: (unsigned int) t;
@end

//
// Spawn
//
@interface Spawn : IntervalAction <NSCopying>
{
	IntervalAction *one;
	IntervalAction *two;
}
+(id) actions: (IntervalAction*) action1, ... NS_REQUIRES_NIL_TERMINATION;
+(id) actionOne: (IntervalAction*) one two:(IntervalAction*) two;
-(id) initOne: (IntervalAction*) one two:(IntervalAction*) two;
@end

//
// RotateTo
//
@interface RotateTo : IntervalAction <NSCopying>
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
@interface RotateBy : IntervalAction <NSCopying>
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
@interface MoveTo : IntervalAction <NSCopying>
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
@interface MoveBy : MoveTo <NSCopying>
{
}
+(id) actionWithDuration: (double) t delta: (CGPoint) delta;
-(id) initWithDuration: (double) t delta: (CGPoint) delta;
@end

//
// JumpBy
//
@interface JumpBy : IntervalAction <NSCopying>
{
	CGPoint startPosition;
	CGPoint delta;
	double height;
	int jumps;
}
+(id) actionWithDuration: (double) t position: (CGPoint) pos height: (double) h jumps:(int)j;
-(id) initWithDuration: (double) t position: (CGPoint) pos height: (double) h jumps:(int)j;
@end

//
// JumpTo
//
@interface JumpTo : JumpBy <NSCopying>
{
}
+(id) actionWithDuration: (double) t delta: (CGPoint) delta;
-(id) initWithDuration: (double) t delta: (CGPoint) delta;
@end


//
// ScaleTo
//
@interface ScaleTo : IntervalAction <NSCopying>
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
@interface ScaleBy : ScaleTo <NSCopying>
{
}
@end

//
// Blink
//
@interface Blink : IntervalAction <NSCopying>
{
	int times;
}
+(id) actionWithDuration: (double) t blinks: (int) blinks;
-(id) initWithDuration: (double) t blinks: (int) blinks;
@end

//
// Accelerate
//
@interface Accelerate: IntervalAction <NSCopying>
{
	IntervalAction *other;
	float rate;
}
+(id) actionWithAction: (IntervalAction*) action rate: (float) rate;
-(id) initWithAction: (IntervalAction*) action rate: (float) rate;
@end

//
// AccelDeccel
//
@interface AccelDeccel: IntervalAction <NSCopying>
{
	IntervalAction *other;
}
+(id) actionWithAction: (IntervalAction*) action;
-(id) initWithAction: (IntervalAction*) action;
@end

//
// Speed
//
@interface Speed : IntervalAction <NSCopying>
{
	double speed;
	IntervalAction * other;
}
+(id) actionWithAction: (IntervalAction*) action speed:(double)s;
-(id) initWithAction: (IntervalAction*) action speed:(double)s;
@end

//
// Delay
//
@interface DelayTime : IntervalAction <NSCopying>
{
}
@end
