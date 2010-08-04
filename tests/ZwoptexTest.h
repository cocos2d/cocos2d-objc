#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface ZwoptexTest: CCLayer
{
    CCTextureAtlas	*atlas;
}
-(NSString*) title;
-(NSString*) subtitle;
@end


@interface ZwoptexGenericTest : ZwoptexTest
{
	CCSprite *sprite1, *sprite2;
	int counter;
}
@end
