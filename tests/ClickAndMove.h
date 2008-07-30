#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class Label;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end


@interface MainLayer : Layer
{
	Label *hello;
}
@end
