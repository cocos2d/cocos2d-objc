#import <UIKit/UIKit.h>
#import "Layer.h"

@class Label;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
-(void) handleTap;
@end


@interface MainLayer : Layer
{
	Label *hello;
}
@end
