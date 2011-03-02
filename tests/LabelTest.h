#import "cocos2d.h"

//CLASS INTERFACE
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@interface cocos2dmacAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	MacGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet MacGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

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

@interface LabelBMFontHD : AtlasDemo
{
}
@end

@interface LabelAtlasHD : AtlasDemo
{
}
@end

@interface LabelGlyphDesigner : AtlasDemo
{
}
@end

@interface LabelTTFTest : AtlasDemo
{
}
@end

@interface LabelTTFMultiline : AtlasDemo
{
}
@end

