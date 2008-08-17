#import <UIKit/UIKit.h>

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@interface AnchorDemo : Layer
{
	Sprite * grossini;
	Sprite *tamara;
}
-(void) centerSprites;
-(NSString*) title;
@end

@interface Anchor1 : AnchorDemo
{
}
@end

@interface Anchor2 : AnchorDemo
{
}
@end

@interface Anchor3 : AnchorDemo
{
}
@end