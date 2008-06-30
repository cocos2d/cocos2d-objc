#import <UIKit/UIKit.h>
#import "Layer.h"

@class Label;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@class EmitFireworks;
@interface TextLayer: Layer
{
	EmitFireworks *emitter;
}
@end
