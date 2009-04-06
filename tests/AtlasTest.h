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
	LabelAtlas *label;
	ccTime		time;
}
@end

@interface Atlas3 : AtlasDemo
{}
@end

@interface Atlas4 : AtlasDemo
{}
@end

@interface Atlas5 : AtlasDemo
{}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end

@interface Atlas6 : AtlasDemo
{}
@end

@interface Atlas7 : AtlasDemo
{}
@end

@interface Atlas8 : AtlasDemo
{
	int dir;
}
@end

@interface Atlas9 : AtlasDemo
{}
@end
