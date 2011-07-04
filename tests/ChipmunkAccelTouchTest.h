//
// cocos2d
//

#import "cocos2d.h"
#import "chipmunk.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow	*window_;
	UIViewController *viewController_;
}
@end

@interface Layer1 : CCLayer
{
	cpSpace *space;
}
-(void) addNewSpriteX:(float)x y:(float)y;
@end
	
