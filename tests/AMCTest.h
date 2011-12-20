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

@interface AMCDemo: CCLayer
{
    CCTextureAtlas	*atlas;
}

// Creates layer first time, that we will save/load after.
-(CCLayer *) insideLayer;

-(NSString*) title;
-(NSString*) subtitle;
@end


@interface SpriteAMC1 : AMCDemo
{}
-(CCSprite *) spriteWithCoords:(CGPoint)p;
@end




