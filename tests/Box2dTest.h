//
// cocos2d
//

#import "cocos2d.h"
#import "Box2D.h"


//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface Box2DTestLayer : Layer {
	b2World* world;
	b2Body* body;	
}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end
