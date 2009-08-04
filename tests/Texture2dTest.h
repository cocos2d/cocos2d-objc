#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
{
	UIWindow	*window;
}
@end

@interface TextureDemo : Layer
{}

-(NSString*) title;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end

@interface TextureLabel : TextureDemo
{}
@end

@interface TextureLabel2 : TextureDemo
{}
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

@interface TexturePVR : TextureDemo
{}
@end

@interface TexturePVRMipMap : TextureDemo
{}
@end

@interface TexturePVRRaw : TextureDemo
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
{
}
-(void) transformSprite:(Sprite*)sprite;
@end

@interface TextureLibPNGTest1 : TextureLibPNG
{
}
@end

@interface TextureLibPNGTest2 : TextureLibPNG
{
}
@end

@interface TextureLibPNGTest3 : TextureLibPNG
{
}
@end

@interface TextureGlRepeat : TextureDemo
{
}
@end

@interface TextureGlClamp : TextureDemo
{
}
@end


