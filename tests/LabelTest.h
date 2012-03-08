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


@interface Atlas3BM : AtlasDemo
{
	ccTime		time;
}
@end

@interface Atlas3BN : AtlasDemo
{
	ccTime		time;
}
@end

@interface Atlas4BM : AtlasDemo
{
	ccTime		time;
}
@end

@interface Atlas4BN : AtlasDemo
{
	ccTime		time;
}
@end

@interface Atlas5BM : AtlasDemo
{}
@end

@interface Atlas5BN : AtlasDemo
{}
@end

@interface Atlas6BM : AtlasDemo
{}
@end

@interface Atlas6BN : AtlasDemo
{}
@end

@interface AtlasBitmapColorBM : AtlasDemo
{}
@end

@interface AtlasBitmapColorBN : AtlasDemo
{}
@end

@interface AtlasFastBitmapBM : AtlasDemo
{}
@end

@interface AtlasFastBitmapBN : AtlasDemo
{}
@end

@interface BitmapFontMultiLineBM : AtlasDemo
{}
@end

@interface BitmapFontMultiLineBN : AtlasDemo
{}
@end

@interface LabelsEmptyBM : AtlasDemo
{
	BOOL setEmpty;
}
@end

@interface LabelsEmptyBN : AtlasDemo
{
	BOOL setEmpty;
}
@end

@interface LabelBMFontHD : AtlasDemo
{
}
@end

@interface LabelBNFontHD : AtlasDemo
{
}
@end

@interface LabelAtlasHD : AtlasDemo
{
}
@end

@interface LabelGlyphDesignerBM : AtlasDemo
{
}
@end

@interface LabelGlyphDesignerBN : AtlasDemo
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

@interface LabelTTFLineBreak : AtlasDemo
{
}
@end

