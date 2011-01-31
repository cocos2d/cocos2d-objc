#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface LayerTest: CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface LayerTest1 : LayerTest
{
}
@end

@interface LayerTest2 : LayerTest
{
}
@end

@interface LayerTestBlend : LayerTest
{
}
@end

@interface LayerGradient : LayerTest
{
}
@end
