#import <UIKit/UIKit.h>
#import "Cocos2d.h"

@class Sprite;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface RenderTextureTest : Layer
{
  RenderTexture* target;
	Sprite* brush;
}


@end


