#import "cocos2d.h"

@class Label;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
    UIWindow *window;
}
@property (nonatomic, retain) UIWindow *window;
@end

@interface SpriteLayer: Layer
{
}
@end

@interface TextLayer: Layer
{
}
@end

@interface MainLayer : Layer
{
}
@end
