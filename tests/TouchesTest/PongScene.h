/* TouchesTest (c) Valentin Milea 2009
 */
#import "cocos2d.h"

@interface PongScene : Scene {
@private
}
@end

@class Ball;

@interface PongLayer: Layer {
@private
	Ball *ball;
	NSArray *paddles;
	CGPoint ballStartingVelocity;
}
@end
