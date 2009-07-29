#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface TileDemo: Layer
{
    TextureAtlas *atlas;
}
-(NSString*) title;
@end

@interface TileMapTest : TileDemo
{
}
@end

@interface TileMapEditTest : TileDemo
{
}
@end


@interface TMXOrthoTest : TileDemo
{
}
@end

@interface TMXHexTest : TileDemo
{
}
@end

@interface TMXIsoTest : TileDemo
{
}
@end
