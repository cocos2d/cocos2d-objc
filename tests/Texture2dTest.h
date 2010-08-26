#import "cocos2d.h"

//CLASS INTERFACE
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

@interface TextureDemo : CCLayer
{}

-(NSString*) title;
-(NSString*) subtitle;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface TexturePNG : TextureDemo
{}
@end

@interface TextureJPEG : TextureDemo
{}
@end

@interface TextureBMP : TextureDemo
{}
@end

@interface TextureTIFF : TextureDemo
{}
@end

@interface TextureGIF : TextureDemo
{}
@end

@interface TextureMipMap : TextureDemo
{}
@end

@interface TexturePVR : TextureDemo
{}
@end

@interface TexturePVR2BPP : TextureDemo
{}
@end

@interface TexturePVR4BPP : TextureDemo
{}
@end

@interface TexturePVRRGBA8888 : TextureDemo
{}
@end

@interface TexturePVRBGRA8888 : TextureDemo
{}
@end

@interface TexturePVRRGBA4444 : TextureDemo
{}
@end

@interface TexturePVRRGBA5551 : TextureDemo
{}
@end

@interface TexturePVRRGB565 : TextureDemo
{}
@end

@interface TexturePVRA8 : TextureDemo
{}
@end

@interface TexturePVRI8 : TextureDemo
{}
@end

@interface TexturePVRAI88 : TextureDemo
{}
@end

@interface TexturePVRMipMap : TextureDemo
{}
@end

@interface TexturePVRMipMap2 : TextureDemo
{}
@end

@interface TexturePVRNonSquare : TextureDemo
{}
@end

@interface TexturePVRNPOT : TextureDemo
{}
@end

@interface TexturePVRRaw : TextureDemo
{}
@end

@interface TextureCGImage : TextureDemo
{}
@end

@interface TextureAlias : TextureDemo
{}
@end

@interface TexturePixelFormat : TextureDemo
{}
@end

@interface TextureBlend : TextureDemo
{}
@end

@interface TextureAsync : TextureDemo
{
	int imageOffset;
}
@end

@interface TextureLibPNG : TextureDemo
{}
-(void) transformSprite:(CCSprite*)sprite;
@end

@interface TextureLibPNGTest1 : TextureLibPNG
{}
@end

@interface TextureLibPNGTest2 : TextureLibPNG
{}
@end

@interface TextureLibPNGTest3 : TextureLibPNG
{}
@end

@interface TextureGlRepeat : TextureDemo
{}
@end

@interface TextureGlClamp : TextureDemo
{}
@end

@interface TextureSizeTest : TextureDemo
{}
@end

@interface TextureCache1 : TextureDemo
{}
@end


