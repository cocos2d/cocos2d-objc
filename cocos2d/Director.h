//
// cocos2d
//

// cocoa related
#import <UIKit/UIKit.h>

// OpenGL related
#import "EAGLView.h"

// cocos2d related
#import "Scene.h"


//CLASS INTERFACE
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

- (void) runScene:(Scene*) scene;
- (void) pushScene:(Scene*) scene;
- (void) popScene;

- (void) drawScene;
- (void) startAnimation;
- (void) stopAnimation;

+ (Director *)sharedDirector;
@end
