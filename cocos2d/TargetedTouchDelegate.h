#import <UIKit/UIKit.h>

//
// TargetedTouchDelegate
//
@protocol TargetedTouchDelegate <NSObject>

/** Return YES to claim the touch.
 Updates of claimed touches (move/ended/cancelled) are sent only to the
 delegate(s) that claimed them when they began. In other words, updates
 will "target" their specific handler, without bothering the other handlers.
 */
- (BOOL)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
@optional
// touch updates:
- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;
@end
