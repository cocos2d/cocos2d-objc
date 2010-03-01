#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface AtlasDemo: CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface Atlas1 : AtlasDemo
{
	CCTextureAtlas *textureAtlas;
}
@end

@interface LabelAtlasTest : AtlasDemo
{
	ccTime		time;
}
@end

@interface LabelAtlasColorTest : AtlasDemo
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

@interface Atlas5 : AtlasDemo
{}
@end

@interface Atlas6 : AtlasDemo
{}
@end

@interface AtlasBitmapColor : AtlasDemo
{}
@end


@interface AtlasFastBitmap : AtlasDemo
{}
@end

