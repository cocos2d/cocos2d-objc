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

@interface ActionDemoInsideLayer : CCLayer {

    CCSprite *grossini;
	CCSprite *tamara;
	CCSprite *kathia;
}

-(void) centerSprites:(unsigned int)numberOfSprites;

@end

@interface ActionDemo : CCLayer
{
	
}
+ (id) nodeWithInsideLayer: (CCLayer *) insideLayer;
- (id) initWithInsideLayer: (CCLayer *) insideLayer;


-(NSString*) title;
-(NSString*) subtitle;

-(void) backCallback:(id) sender;
-(void) nextCallback:(id) sender;
-(void) restartCallback:(id) sender;
@end


@interface ActionManual : ActionDemoInsideLayer
{}
@end

@interface ActionMove : ActionDemoInsideLayer
{}
@end

@interface ActionRotate : ActionDemoInsideLayer
{}
@end

@interface ActionScale : ActionDemoInsideLayer
{}
@end

@interface ActionSkew : ActionDemoInsideLayer
{}
@end

@interface ActionSkewRotateScale : ActionDemoInsideLayer
{}
@end

@interface ActionJump : ActionDemoInsideLayer
{}
@end

@interface ActionBlink : ActionDemoInsideLayer
{}
@end

@interface ActionAnimate : ActionDemoInsideLayer
{}
@end

@interface ActionSequence : ActionDemoInsideLayer
{}
@end

@interface ActionSequence2 : ActionDemoInsideLayer
{}
@end

@interface ActionSpawn : ActionDemoInsideLayer
{}
@end

@interface ActionReverse : ActionDemoInsideLayer
{}
@end

@interface ActionRepeat : ActionDemoInsideLayer
{}
@end

@interface ActionDelayTime : ActionDemoInsideLayer
{}
@end

@interface ActionReverseSequence : ActionDemoInsideLayer
{}
@end

@interface ActionReverseSequence2 : ActionDemoInsideLayer
{}
@end

@interface ActionCallFunc : ActionDemoInsideLayer
{}
@end

@interface ActionCallFuncND : ActionDemoInsideLayer
{}
@end

@interface ActionCallBlock : ActionDemoInsideLayer
{}
@end

@interface ActionFade : ActionDemoInsideLayer
{}
@end

@interface ActionTint : ActionDemoInsideLayer
{}
@end

@interface ActionOrbit : ActionDemoInsideLayer
{}
@end

@interface ActionBezier : ActionDemoInsideLayer
{}
@end

@interface ActionRepeatForever : ActionDemoInsideLayer
{}
@end

@interface ActionRotateToRepeat : ActionDemoInsideLayer
{}
@end

@interface ActionRotateJerkSpeed : ActionDemoInsideLayer
{}
@end

@interface ActionFollow : ActionDemoInsideLayer
{}
@end

@interface ActionProperty : ActionDemoInsideLayer
{}
@end

@interface ActionProgress : ActionDemoInsideLayer
{}
@end


