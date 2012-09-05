#import "cocos2d.h"

#import "BaseAppController.h"
@interface AppController : BaseAppController
@end

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

#ifdef __CC_PLATFORM_IOS
	UISlider	*sliderCtl_;
#elif defined(__CC_PLATFORM_MAC)
	NSSlider	*sliderCtl_;
	NSWindow	*overlayWindow;
#endif
}
#ifdef __CC_PLATFORM_IOS
@property(nonatomic, retain) UISlider *sliderCtl;
#elif defined(__CC_PLATFORM_MAC)
@property(nonatomic, retain) NSSlider *sliderCtl;
#endif

#ifdef __CC_PLATFORM_IOS
-(UISlider*) createSliderCtl;
#elif defined(__CC_PLATFORM_MAC)
-(NSSlider*) createSliderCtl;
#endif

@end

@interface ShaderRetroEffect : ShaderTest
{
	CCLabelBMFont *label_;
	ccTime			accum_;
}
@end

@interface ShaderFail : ShaderTest
{
}
@end


