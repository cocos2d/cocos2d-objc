//
// cocos2d
//

#import <UIKit/UIKit.h>
#import "Box2D.h"

#import "Layer.h"

@class Menu;

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@interface Layer1 : Layer
{
	b2World* world;
}
-(void) step;
@end
