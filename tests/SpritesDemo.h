#import <UIKit/UIKit.h>
#import "Layer.h"

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@interface SpriteDemo : Layer
{
	Sprite * grossini;
	Sprite *tamara;
}
-(void) centerSprites;
-(NSString*) title;
@end

@interface SpriteMove : SpriteDemo
{
}
@end

@interface SpriteRotate : SpriteDemo
{
}
@end

@interface SpriteScale : SpriteDemo
{
}
@end

@interface SpriteJump : SpriteDemo
{
}
@end

@interface SpriteBlink : SpriteDemo
{
}
@end

@interface SpriteSequence : SpriteDemo
{
}
@end

@interface SpriteSpawn : SpriteDemo
{
}
@end

@interface SpriteReverse : SpriteDemo
{
}
@end

@interface SpriteRepeat : SpriteDemo
{
}
@end

@interface SpriteDelayTime : SpriteDemo
{
}
@end

@interface SpriteReverseSequence : SpriteDemo
{
}
@end

@interface SpriteAccelerate : SpriteDemo
{
}
@end

@interface SpriteCallFunc : SpriteDemo
{
}
@end
