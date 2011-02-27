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

@interface ShaderTest: CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;

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

@interface ShaderBlur : ShaderTest
{
}
@end
