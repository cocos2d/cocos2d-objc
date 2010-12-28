#import "cocos2d.h"

@class CCSprite;

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

@interface ActionDemo : CCLayer
{
	CCSprite * grossini;
	CCSprite *tamara;
	CCSprite *kathia;
}
-(void) centerSprites:(unsigned int)numberOfSprites;
-(NSString*) title;
-(NSString*) subtitle;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end


@interface ActionManual : ActionDemo
{}
@end

@interface ActionMove : ActionDemo
{}
@end

@interface ActionRotate : ActionDemo
{}
@end

@interface ActionScale : ActionDemo
{}
@end

@interface ActionSkew : ActionDemo
{}
@end

@interface ActionSkewRotateScale : ActionDemo
{}
@end

@interface ActionJump : ActionDemo
{}
@end

@interface ActionBlink : ActionDemo
{}
@end

@interface ActionAnimate : ActionDemo
{}
@end

@interface ActionSequence : ActionDemo
{}
@end

@interface ActionSequence2 : ActionDemo
{}
@end

@interface ActionSpawn : ActionDemo
{}
@end

@interface ActionReverse : ActionDemo
{}
@end

@interface ActionRepeat : ActionDemo
{}
@end

@interface ActionDelayTime : ActionDemo
{}
@end

@interface ActionReverseSequence : ActionDemo
{}
@end

@interface ActionReverseSequence2 : ActionDemo
{}
@end

@interface ActionCallFunc : ActionDemo
{}
@end

@interface ActionCallFuncND : ActionDemo
{}
@end

@interface ActionCallBlock : ActionDemo
{}
@end


@interface ActionFade : ActionDemo
{}
@end

@interface ActionTint : ActionDemo
{}
@end

@interface ActionOrbit : ActionDemo
{}
@end

@interface ActionBezier : ActionDemo
{}
@end

@interface ActionRepeatForever : ActionDemo
{}
@end

@interface ActionRotateToRepeat : ActionDemo
{}
@end

@interface ActionRotateJerk : ActionDemo
{}
@end
@interface ActionFollow : ActionDemo
{}
@end

@interface ActionProperty : ActionDemo
{}
@end


