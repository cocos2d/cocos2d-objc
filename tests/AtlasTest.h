#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface AtlasDemo: Layer
{
    TextureAtlas *atlas;
}
-(NSString*) title;
@end

@interface Atlas1 : AtlasDemo
{
	TextureAtlas *textureAtlas;
}
@end

@interface Atlas2 : AtlasDemo
{
	ccTime		time;
}
@end

@interface Atlas3 : AtlasDemo
{
	ccTime		time;
}
@end

@interface Atlas4 : AtlasDemo
{
	ccTime		time;
}
@end

@interface AtlasFastBitmap : AtlasDemo
{}
@end

