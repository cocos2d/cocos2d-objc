//
// cocos2d
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "BaseAppController.h"

//CLASS INTERFACE
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
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

@interface MainLayer : CCLayer {
	
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
}
@end

@interface PhysicsSprite : CCSprite
{
	b2Body *body_;	// strong ref
}

-(void) setPhysicsBody:(b2Body*)body;

@end