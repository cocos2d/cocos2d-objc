//
//  Director.h
//  cocos2d
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
@interface Director : EAGLView
{
	UIWindow*	window;
	CGRect		winSize;

	NSTimer *animationTimer;
	NSTimeInterval animationInterval;

	BOOL landscape;
	
	/** running scene */
	Scene *runningScene;
	
	/* will be the next 'runningScene' in the next frame */
	Scene *nextScene;
	
	/* event handler */
	id	eventHandler;

	/** scheduled scenes */
	NSMutableArray *scenes;
}

@property (readonly, assign) Scene* runningScene;
@property (readwrite, assign) NSTimeInterval animationInterval;
@property (readwrite,assign) UIWindow* window;
@property (readwrite, assign) id eventHandler;

-(void) setNextScene;

/** returns the size of the screen 480x320 or 320x480 depeding if landscape mode is activated or not */
- (CGRect) winSize;
/** returns 320x480, always */
-(CGRect) displaySize;

/** returns whether or not the screen is in landscape mode */
- (BOOL) landscape;
/** sets lanscape mode */
- (void) setLandscape: (BOOL) on;

/** enables/disables OpenGL alpha blending */
- (void) setAlphaBlending: (BOOL) on;
/** enables/disables OpenGL depth test */
- (void) setDepthTest: (BOOL) on;
/** enables/disables OpenGL texture 2D */
- (void) setTexture2D: (BOOL) on;
/** sets Cocos OpenGL default projection */
- (void) setDefaultProjection;
/** sets a 2D projection */
-(void) set2Dprojection;
/** sets a 3D projection */
-(void) set3Dprojection;
/** rotates the screen if Landscape mode is activated */
-(void) applyLandscape;

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

/** Ends the execution */
-(void) end;

- (void) drawScene;
- (void) startAnimation;
- (void) stopAnimation;

/** converts a UIKit coordinate to an OpenGL coordinate
 Useful to convert (multi) touchs coordinates to the current layout (portrait or landscape)
 */
-(CGPoint) convertCoordinate: (CGPoint) p;

/** returns a shared instance of the director */
+ (Director *)sharedDirector;
@end
