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
	id emitter1;
	id emitter2;
	id emitter3;
}
@end
