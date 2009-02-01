#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
	UIWindow	*window;
}
@end

@interface SpriteDemo : Layer
{
	Sprite * grossini;
	Sprite *tamara;
	Sprite *kathia;
}
-(void) positionForTwo;
-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end


@interface SpriteEaseExponential : SpriteDemo
{}
@end

@interface SpriteEaseExponentialInOut : SpriteDemo
{}
@end

@interface SpriteEaseCubic : SpriteDemo
{}
@end

@interface SpriteEaseCubicInOut : SpriteDemo
{}
@end

@interface SpriteEaseQuad : SpriteDemo
{}
@end

@interface SpriteEaseQuadInOut : SpriteDemo
{}
@end

@interface SpriteEaseSine : SpriteDemo
{}
@end

@interface SpriteEaseSineInOut : SpriteDemo
{}
@end