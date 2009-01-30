#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
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
	LabelAtlas *label;
	ccTime		time;
}
@end

@interface Atlas3 : AtlasDemo
{
}
@end
