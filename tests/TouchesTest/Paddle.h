/* TouchesTest (c) Valentin Milea 2009
 */
#import "cocos2d.h"

typedef enum tagPaddleState {
	kPaddleStateGrabbed,
	kPaddleStateUngrabbed
} PaddleState;

@interface Paddle : TextureNode <TargetedTouchDelegate> {
@private
	PaddleState state;
}

@property(nonatomic, readonly) CGRect rect;

+ (id)paddleWithTexture:(Texture2D *)texture;
- (id)initWithTexture:(Texture2D *)texture;
@end
