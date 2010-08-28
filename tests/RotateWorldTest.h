#import "cocos2d.h"

@class CCLabel;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
    UIWindow *window;
}
@property (nonatomic, retain) UIWindow *window;
@end

@interface SpriteLayer: CCLayer
{
}
@end

@interface TextLayer: CCLayer
{
}
@end

@interface MainLayer : CCLayer
{
}
@end
