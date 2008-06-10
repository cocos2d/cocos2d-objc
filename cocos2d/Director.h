//
// cocos2d
//

// cocoa related
#import <UIKit/UIKit.h>

// OpenGL related
#import "EAGLView.h"

// cocos2d related
#import "Scene.h"


/**Class that creates and handle the main Window and manages how
and when to execute the Scenes
*/
@interface Director : NSObject
{
	UIWindow*				window;
	EAGLView*				GLView;
	CGRect					winSize;

	NSTimer *animationTimer;
	NSTimeInterval animationInterval;

	/* landscape mode ? */
	BOOL landscape;
	
	/* running scene */
	Scene *runningScene;

	// scenes
	NSMutableArray *scenes;
}

@property (readwrite, assign) NSTimeInterval animationInterval;
@property (readwrite,assign) UIWindow* window;

- (CGRect) winSize;
- (BOOL) landscape;
- (void) setLandscape: (BOOL) on;

- (void) setAlphaBlending: (BOOL) on;
- (void) setDepthTest: (BOOL) on;
- (void) setTexture2D: (BOOL) on;
- (void) setDefaultProjection;

/**Runs a scene, entering in the Director's main loop.
 */
- (void) runScene:(Scene*) scene;

/**Suspends the execution of the running scene, pushing it on the stack of suspended scenes.
 The new scene will be executed.
 */
- (void) pushScene:(Scene*) scene;

/**Pops out a scene from the queue.
 This scene will replace the running one.
 The running scene will be deleted. If there are no more scenes in the stack the execution is terminated.
 */
- (void) popScene;

/** Replaces the running scene with a new one. The running scene is terminated.
 */
-(void) replaceScene: (Scene*) scene;

- (void) drawScene;
- (void) startAnimation;
- (void) stopAnimation;

+ (Director *)sharedDirector;
@end
