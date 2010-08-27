#import "cocos2d.h"

//CLASS INTERFACE
#if __IPHONE_OS_VERSION_MIN_REQUIRED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end

#elif __MAC_OS_X_VERSION_MIN_REQUIRED
@interface cocos2dmacAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	MacGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet MacGLView	*glView;

@end
#endif // Mac

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

@interface BitmapFontMultiLine : AtlasDemo
{}
@end

@interface LabelsEmpty : AtlasDemo
{
	BOOL setEmpty;
}
@end

