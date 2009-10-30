//
// cocos2d
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"


//CLASS INTERFACE
@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface Box2DTestLayer : CCLayer {
	b2World* world;
	GLESDebugDraw *m_debugDraw;
}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end
