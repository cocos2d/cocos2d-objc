//
// cocos2d
//

#import <UIKit/UIKit.h>

#import "Layer.h"
#import "chipmunk.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate>
{
}
@end

@interface Layer1 : Layer
{
	cpSpace *space;
}
-(void) step: (double) dt;
-(void) addNewSpriteX:(float)x y:(float)y;
@end
