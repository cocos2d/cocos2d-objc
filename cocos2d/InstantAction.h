//
// cocos2d for iphone
// InstantAction
//


#import <UIKit/UIKit.h>

#import "Action.h"

/** Instant actions are immediate actions. They don't have a duration like
 the Interval Actions.
*/ 
@interface InstantAction : Action <NSCopying>
{
	double duration;
}
@property (readonly,assign) double duration;

-(void) step;
-(BOOL) isDone;
@end

/** Show the node
 */
 @interface Show : InstantAction
{
}
@end

/** Hide the node
 */
@interface Hide : InstantAction
{
}
@end

/** Toggles the visibility of a node
 */
@interface ToggleVisibility : InstantAction
{
}
@end

/** Places the node in a certain position
 */
@interface Place : InstantAction <NSCopying>
{
	CGPoint position;
}
//! creates a Place action with a position
+(id) actionWithPosition: (CGPoint) pos;
//! Initializes a Place action with a position
-(id) initWithPosition: (CGPoint) pos;
@end

/** Calls a 'callback'
 */
@interface CallFunc : InstantAction <NSCopying>
{
	NSInvocation *invocation;
}
//! creates the action with the callback
+(id) actionWithTarget: (id) receiver selector:(SEL) callback;
//! initializes the action with the callback
-(id) initWithTarget: (id) receiver selector:(SEL) callback;
@end

