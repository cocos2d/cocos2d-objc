#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface ExtensionTest : CCLayer
{
    CCTextureAtlas	*atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
-(void) restartCallback: (id) sender;
-(void) nextCallback: (id) sender;
-(void) backCallback: (id) sender;
@end


@interface Test1 : ExtensionTest
{
	CCSprite *sprite1, *sprite2;
	int counter;
}
@end
