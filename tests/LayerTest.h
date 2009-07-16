#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface LayerTest: Layer
{
}
-(NSString*) title;
@end

@interface LayerTest1 : LayerTest
{
}
@end

@interface LayerTest2 : LayerTest
{
}
@end
