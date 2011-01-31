#import "cocos2d.h"

@class CCMenu;

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

@interface Layer1 : CCLayer
{
	CCMenuItem	*disabledItem;
}

-(void) menuCallback:(id) sender;
-(void) menuCallback2:(id) sender;
-(void) onQuit:(id) sender;
@end

@interface Layer2 : CCLayer
{
	CGPoint	centeredMenu;
	BOOL alignedH;
}
-(void) menuCallbackBack: (id) sender;
-(void) menuCallbackOpacity: (id) sender;
-(void) menuCallbackAlign: (id) sender;
@end

@interface Layer3 : CCLayer
{
	CCMenuItem	*disabledItem;
}
-(void) menuCallback: (id) sender;
-(void) menuCallback2: (id) sender;
@end

@interface Layer4 : CCLayer
{
}
-(void) menuCallback: (id) sender;
-(void) backCallback: (id) sender;
@end
