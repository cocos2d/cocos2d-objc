/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import "ccConfig.h"
#import "ccTypes.h"
#import "ccMacros.h"

#import "CCProtocols.h"
#import "Platforms/CCGL.h"
#import "CCResponderManager.h"
#import "CCRenderer.h"

/**
 Possible OpenGL projections used by director
 */
typedef NS_ENUM(NSUInteger, CCDirectorProjection) {
	/// sets a 2D projection (orthogonal projection).
	CCDirectorProjection2D,

	/// sets a 3D projection with a fovy=60, znear=0.5f and zfar=1500.
	CCDirectorProjection3D,

	/// it calls "updateProjection" on the projection delegate.
	CCDirectorProjectionCustom,

	/// Detault projection is 3D projection
	CCDirectorProjectionDefault = CCDirectorProjection2D,

};


@class CCFPSLabel;
@class CCScene;
@class CCScheduler;
@class CCActionManager;
@class CCTransition;

#ifdef __CC_PLATFORM_IOS
#define CC_VIEWCONTROLLER UIViewController
#elif defined(__CC_PLATFORM_MAC)
#define CC_VIEWCONTROLLER NSObject
#endif

/**Class that creates and handle the main Window and manages how
and when to execute the Scenes.

 The CCDirector is also responsible for:
  - initializing the OpenGL ES context
  - setting the OpenGL pixel format (default on is RGB565)
  - setting the OpenGL buffer depth (default one is 0-bit)
  - setting the projection (default one is 3D)

 Since the CCDirector is a singleton, the standard way to use it is by calling:
  - [[CCDirector sharedDirector] methodName];

 The CCDirector also sets the default OpenGL context:
  - GL_TEXTURE_2D is enabled
  - GL_VERTEX_ARRAY is enabled
  - GL_COLOR_ARRAY is enabled
  - GL_TEXTURE_COORD_ARRAY is enabled
*/
@interface CCDirector : CC_VIEWCONTROLLER
{
	// internal timer
	NSTimeInterval _animationInterval;
	NSTimeInterval _oldAnimationInterval;

	/* stats */
	BOOL	_displayStats;

	NSUInteger _frames;
	NSUInteger _totalFrames;
	CCTime _secondsPerFrame;

	CCTime		_accumDt;
	CCTime		_frameRate;
	CCFPSLabel *_FPSLabel;
	CCFPSLabel *_SPFLabel;
	CCFPSLabel *_drawsLabel;

	/* is the running scene paused */
	BOOL _isPaused;
    
    /* Is the director running */
    BOOL _animating;

	/* The running scene */
	CCScene *_runningScene;

	/* This object will be visited after the scene. Useful to hook a notification node */
	id _notificationNode;

	/* will be the next 'runningScene' in the next frame
	 nextScene is a weak reference. */
	CCScene *_nextScene;

	/* If YES, then "old" scene will receive the cleanup message */
	BOOL	_sendCleanupToScene;

	/* scheduled scenes */
	NSMutableArray *_scenesStack;

	/* last time the main loop was updated */
	struct timeval _lastUpdate;
	/* delta time since last tick to main loop */
	CCTime _dt;
	/* whether or not the next delta time will be zero */
	BOOL _nextDeltaTimeZero;

	/* projection used */
	CCDirectorProjection _projection;

	/* window size in points */
	CGSize	_winSizeInPoints;

	/* window size in pixels */
	CGSize	_winSizeInPixels;

	/* scheduler associated with this director */
	CCScheduler *_scheduler;

	/* action manager associated with this director */
	CCActionManager *_actionManager;

    /* fixed timestep action manager associated with this director */
    CCActionManager *_actionManagerFixed;
	
	/*  OpenGLView. On iOS it is a copy of self.view */
	CCGLView		*__view;
	
	CCRenderer *_renderer;
}

/** returns the cocos2d thread.
 If you want to run any cocos2d task, run it in this thread.
 Typically this is the main thread.
 */
@property (weak, readonly, nonatomic ) NSThread *runningThread;
/** The current running Scene. Director can only run one Scene at the time */
@property (nonatomic, readonly) CCScene* runningScene;
/** The FPS value */
@property (nonatomic, readwrite, assign) CCTime animationInterval;
@property (nonatomic, readwrite, assign) CCTime fixedUpdateInterval;
/** Whether or not to display director statistics */
@property (nonatomic, readwrite, assign) BOOL displayStats;
/** whether or not the next delta time will be zero */
@property (nonatomic,readwrite,assign,getter=isNextDeltaTimeZero) BOOL nextDeltaTimeZero;
/** Whether or not the Director is paused */
@property (nonatomic, readonly,getter=isPaused) BOOL paused;
/** Whether or not the Director is active (animating) */
@property (nonatomic, readonly,getter=isAnimating) BOOL animating;
/** Sets an OpenGL projection */
@property (nonatomic, readwrite) CCDirectorProjection projection;
/** How many frames were called since the director started */
@property (nonatomic, readonly) NSUInteger totalFrames;
/** seconds per frame */
@property (nonatomic, readonly) CCTime secondsPerFrame;

/** Sets the touch manager
 */
@property ( nonatomic, strong ) CCResponderManager* responderManager;

/** CCDirector delegate. It shall implement the CCDirectorDelegate protocol
 */
@property (nonatomic, readwrite, weak) id<CCDirectorDelegate> delegate;

/** Content scaling factor. Sets the ratio of Cocos2D "points" to pixels. Default value is initalized from the content scale of the GL view used by the director.
 */
@property(nonatomic, assign) CGFloat contentScaleFactor;

/** UI scaling factor, default value is 1. Positions and content sizes are scale by this factor if the position type is set to scale.
 */
@property (nonatomic,readwrite,assign) float UIScaleFactor;

/// User definable value that is used for default contentSizes of many node types (CCScene, CCNodeColor, etc).
/// Defaults to the view size.
@property(nonatomic, assign) CGSize designSize;

/// Projection matrix used for rendering.
@property(nonatomic, readonly) GLKMatrix4 projectionMatrix;

/// The current global shader values values.
@property(nonatomic, readonly) NSMutableDictionary *globalShaderUniforms;

/** returns a shared instance of the director */
+(CCDirector*)sharedDirector;


#pragma mark Director - Stats

#pragma mark Director - View Size
/** returns the size of the OpenGL view in points */
- (CGSize) viewSize;

/** returns the size of the OpenGL view in pixels.
 On Mac winSize and winSizeInPixels return the same value.
 */
- (CGSize) viewSizeInPixels;

/**
 *  Changes the projection size.
 *
 *  @param newViewSize New projection size.
 */
-(void) reshapeProjection:(CGSize)newViewSize;

/**
 *  Converts a UIKit coordinate to an OpenGL coordinate.
 *
 *  Useful to convert (multi) touch coordinates to the current layout (portrait or landscape).
 *
 *  @param p Point to convert.
 *
 *  @return Converted point.
 */
-(CGPoint) convertToGL: (CGPoint) p;

/**
 *  Converts an OpenGL coordinate to a UIKit coordinate.
 *
 *  Useful to convert node points to window points for calls such as glScissor.
 *
 *  @param p Point to convert.
 *
 *  @return Converted point.
 */
-(CGPoint) convertToUI:(CGPoint)p;

#pragma mark Director - Scene Management

/**
 *  Presents a new scene.
 *
 *  If no scene is currently running, the scene will be started.
 *  
 *  If another scene is currently running, this scene will be stopped, and the new scene started.
 *
 *  @param scene Scene to start.
 */
- (void)presentScene:(CCScene *)scene;

/**
 *  Presents a new scene, with a transition.
 *
 *  If no scene is currently running, the new scene will be started without a transition.
 *
 *  If another scene is currently running, this scene will be stopped, and the new scene started, according to the provided transition.
 *
 *  @param scene Scene to start.
 *  @param transition Transition to use.
 */
- (void)presentScene:(CCScene *)scene withTransition:(CCTransition *)transition;

/**
 *  Enters the Director's main loop with the given Scene.
 *
 *  Call it to run only your FIRST scene.
 *  Don't call it if there is already a running scene.
 *
 *  It will call pushScene: and then it will call startAnimation
 *
 *  @param scene Scene to run.
 */
- (void) runWithScene:(CCScene*) scene;

/**
 * Suspends the execution of the running scene, pushing it on the stack of suspended scenes.
 *
 * The new scene will be executed.
 * Try to avoid big stacks of pushed scenes to reduce memory allocation.
 *
 * ONLY call it if there is a running scene.
 *
 *  @param scene New scene to start.
 */
- (void) pushScene:(CCScene*) scene;

/** Pops out a scene from the queue.
 * This scene will replace the running one.
 * The running scene will be deleted. If there are no more scenes in the stack the execution is terminated.
 * ONLY call it if there is a running scene.
 */
- (void) popScene;

/**Pops out all scenes from the queue until the root scene in the queue.
 *
 * This scene will replace the running one.
 * Internally it will call `popToSceneStackLevel:1`
 */
- (void) popToRootScene;

/**Pops out all scenes from the queue until the root scene in the queue, using a transition
 *
 * This scene will replace the running one.
 * Internally it will call `popToRootScene`
 */
-(void) popToRootSceneWithTransition:(CCTransition *)transition;

/** Replaces the running scene with a new one. The running scene is terminated.
 *
 * ONLY call it if there is a running scene.
 *
 *  @param scene New scene to start.
 */
-(void) replaceScene: (CCScene*) scene;

/**
 *  Presents a new scene by either starting first scene, or replacing the running
 *  Performs a transition between the outgoing and the incoming scene
 *
 *  @param scene      The incoming scene
 *  @param transition The transition to perform
 */
- (void)replaceScene:(CCScene *)scene withTransition:(CCTransition *)transition;

/**
 *  Pushes the running scene onto the scene stack, and presents the incoming scene, using a transition
 *
 *  @param scene      The scene to present
 *  @param transition The transition to use
 */
- (void)pushScene:(CCScene *)scene withTransition:(CCTransition *)transition;

/**
 *  Replaces the running scene, with the last scene pushed to the stack, using a transition
 *
 *  @param transition The transition to use
 */
- (void)popSceneWithTransition:(CCTransition *)transition;

/** Ends the execution, releases the running scene.
 It doesn't remove the OpenGL view from its parent. You have to do it manually.
 */
-(void) end;

/** Pauses the running scene.
 The running scene will be _drawed_ but all scheduled timers will be paused
 While paused, the draw rate will be 4 FPS to reduce CPU consumption
 */
-(void) pause;

/** Resumes the paused scene
 The scheduled timers will be activated again.
 The "delta time" will be 0 (as if the game wasn't paused)
 */
-(void) resume;

/** Stops the animation. Nothing will be drawn. The main loop won't be triggered anymore.
 If you want to pause your animation call [pause] instead.
 */
-(void) stopAnimation;

/** The main loop is triggered again.
 Call this function only if [stopAnimation] was called earlier
 @warning Don't call this function to start the main loop. To run the main loop call runWithScene
 */
-(void) startAnimation;


#if defined(__CC_PLATFORM_MAC)
// XXX: Hack. Should be placed on CCDirectorMac.h. Refactoring needed
// sets the openGL view
-(void) setView:(CCGLView*)view;

/** returns the OpenGL view */
-(CCGLView*) view;
#endif

#pragma mark Director - Memory Helper

/** Removes all the cocos2d data that was cached automatically.
 It will purge the CCTextureCache, CCLabelBMFont cache.
 IMPORTANT: The CCSpriteFrameCache won't be purged. If you want to purge it, you have to purge it manually.
 */
-(void) purgeCachedData;

@end

// optimization. Should only be used to read it. Never to write it.
extern CGFloat	__ccContentScaleFactor;
