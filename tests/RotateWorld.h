#import <UIKit/UIKit.h>
#import "Layer.h"

@class Label;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
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
	Label *hello;
}
@end
