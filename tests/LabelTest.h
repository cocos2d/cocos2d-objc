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
+(id) nodeWithInsideLayer: (CCLayer *) insideLayer;
-(id) initWithInsideLayer: (CCLayer *) insideLayer;
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface Atlas1 : CCLayer
{
	CCTextureAtlas *textureAtlas;
}
@end

@interface LabelAtlasTest : CCLayer
{
	ccTime		time;
}
@end

@interface LabelAtlasColorTest : CCLayer
{
	ccTime		time;
}
@end


@interface Atlas3 : CCLayer
{
	ccTime		time;
}
@end

@interface Atlas4 : CCLayer
{
	ccTime		time;
}
@end

@interface Atlas5 : CCLayer
{}
@end

@interface Atlas6 : CCLayer
{}
@end

@interface AtlasBitmapColor : CCLayer
{}
@end


@interface AtlasFastBitmap : CCLayer
{}
@end

@interface BitmapFontMultiLine : CCLayer
{}
@end

@interface LabelsEmpty : CCLayer
{
	BOOL setEmpty;
}
@end

@interface LabelBMFontHD : CCLayer
{
}
@end

@interface LabelAtlasHD : CCLayer
{
}
@end

@interface LabelGlyphDesigner : CCLayer
{
}
@end

@interface LabelTTFTest : CCLayer
{
}
@end

@interface LabelTTFMultiline : CCLayer
{
}
@end

@interface LabelTTFLineBreak : CCLayer
{
}
@end

