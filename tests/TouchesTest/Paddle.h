/* TouchesTest (c) Valentin Milea 2009
 */
#import "cocos2d.h"

typedef enum tagPaddleState {
	kPaddleStateGrabbed,
	kPaddleStateUngrabbed
} PaddleState;

@interface Paddle : CCTextureNode <CCTargetedTouchDelegate> {
@private
	PaddleState state;
}

@property(nonatomic, readonly) CGRect rect;

+ (id)paddleWithTexture:(CCTexture2D *)texture;
- (id)initWithTexture:(CCTexture2D *)texture;
@end
