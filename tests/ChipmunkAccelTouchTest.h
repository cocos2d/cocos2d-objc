//
// cocos2d
//

#import "cocos2d.h"
#import "chipmunk.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface Layer1 : CCLayer
{
	cpSpace *space;
}
-(void) addNewSpriteX:(float)x y:(float)y;
@end
	
