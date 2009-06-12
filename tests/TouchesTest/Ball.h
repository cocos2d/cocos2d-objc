/* TouchesTest (c) Valentin Milea 2009
 */
#import "cocos2d.h"

@class Paddle;

@interface Ball : TextureNode {
@private
	CGPoint velocity;
}

@property(nonatomic) CGPoint velocity;
@property(nonatomic, readonly) float radius;

+ (id)ballWithTexture:(Texture2D *)texture;
- (id)initWithTexture:(Texture2D *)texture;

- (void)move:(ccTime)delta;
- (void)collideWithPaddle:(Paddle *)paddle;
@end
