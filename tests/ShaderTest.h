#import "cocos2d.h"

//CLASS INTERFACE
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import "BaseAppController.h"
@interface AppController : BaseAppController
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

@interface ShaderTest: CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;

@end

@interface ShaderMonjori : ShaderTest
{
}
@end

@interface ShaderMandelbrot : ShaderTest
{
}
@end

@interface ShaderJulia : ShaderTest
{
}
@end


@interface ShaderHeart : ShaderTest
{
}
@end

@interface ShaderFlower : ShaderTest
{
}
@end

@interface ShaderPlasma : ShaderTest
{
}
@end

@class SpriteBlur;
@interface ShaderBlur : ShaderTest
{
	SpriteBlur *blurSprite;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	UISlider	*sliderCtl_;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	NSSlider	*sliderCtl_;
	NSWindow	*overlayWindow;
#endif
}
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@property(nonatomic, retain) UISlider *sliderCtl;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@property(nonatomic, retain) NSSlider *sliderCtl;
#endif

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(UISlider*) createSliderCtl;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
-(NSSlider*) createSliderCtl;
#endif

@end
