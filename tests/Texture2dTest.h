#import "cocos2d.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

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

@interface TexturePVRRGBA4444GZ : TextureDemo
{}
@end

@interface TexturePVRRGBA4444CCZ : TextureDemo
{}
@end

@interface TexturePVRRGBA5551 : TextureDemo
{}
@end

@interface TexturePVRRGB565 : TextureDemo
{}
@end

@interface TexturePVRRGB888 : TextureDemo
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

@interface TexturePVR2BPPv3 : TextureDemo
{}
@end

@interface TexturePVRII2BPPv3 : TextureDemo
{}
@end

@interface TexturePVR4BPPv3 : TextureDemo
{}
@end

@interface TexturePVRII4BPPv3 : TextureDemo
{}
@end

@interface TexturePVRRGBA8888v3 : TextureDemo
{}
@end

@interface TexturePVRBGRA8888v3 : TextureDemo
{}
@end

@interface TexturePVRRGBA4444v3 : TextureDemo
{}
@end

@interface TexturePVRRGBA5551v3 : TextureDemo
{}
@end

@interface TexturePVRRGB565v3 : TextureDemo
{}
@end

@interface TexturePVRRGB888v3 : TextureDemo
{}
@end

@interface TexturePVRA8v3 : TextureDemo
{}
@end

@interface TexturePVRI8v3 : TextureDemo
{}
@end

@interface TexturePVRAI88v3 : TextureDemo
{}
@end

@interface TexturePVRBadEncoding : TextureDemo
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

@interface TexturePVRNPOT4444 : TextureDemo
{}
@end

@interface TexturePVRNPOT8888 : TextureDemo
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

@interface TextureAsyncBlock : TextureDemo
{
	int imageOffset;
}
@end

@interface TextureAsyncBlock2 : TextureDemo
{
	CCSprite* sprite1_;
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

@interface TextureDrawAtPoint : TextureDemo
{
	CCTexture2D *tex1_, *tex2_;
}
@end

@interface TextureDrawInRect : TextureDemo
{
	CCTexture2D *tex1_, *tex2_;
}
@end

@interface TextureMemoryAlloc : TextureDemo
{
	CCSprite *background_;
}
@end

@interface TexturePVRv3Premult : TextureDemo
{}
@end
