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
#import "CCDirectorView.h"

/**
 Possible OpenGL projections used by CCDirector.
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

#if __CC_PLATFORM_IOS
#define CC_VIEWCONTROLLER UIViewController
#define CC_VIEW UIView

#elif __CC_PLATFORM_MAC
#define CC_VIEWCONTROLLER NSObject
#define CC_VIEW NSOpenGLView

#endif



/** The director creates and handles the main Window and the Cocos2D view. It also presents Scenes and initiates scene updates and drawing.
 
 CCDirector inherits from CC_VIEWCONTROLLER which is equivalent to UIViewController on iOS, and NSObject on OS X.

 Since the CCDirector is a singleton, the standard way to use its methods and properties is:
 
 - `[[CCDirector sharedDirector] methodName];`
 - `[CCDirector sharedDirector].aProperty;`

 The CCDirector is responsible for:
 
  - initializing the OpenGL ES / Metal context
  - setting the pixel format (default on is RGB565)
  - setting the buffer depth (default one is 0-bit)
  - setting the projection (default one is 3D)

 The CCDirector also sets the default OpenGL context:
 
  - `GL_TEXTURE_2D` is enabled
  - `GL_VERTEX_ARRAY` is enabled
  - `GL_COLOR_ARRAY` is enabled
  - `GL_TEXTURE_COORD_ARRAY` is enabled
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
	
	NSMutableArray *_rendererPool;
    
@protected
    GLKMatrix4 _projectionMatrix;
    __weak id<CCDirectorDelegate> _delegate;
    __weak NSThread *_runningThread;
}

// Undocumented members (considered private)
@property ( nonatomic, strong ) CCResponderManager* responderManager;
@property (nonatomic, readwrite, weak) id<CCDirectorDelegate> delegate;


/** @name Singleton Accessor */

/** @returns The shared director instance. */
+(CCDirector*)sharedDirector;

/** @name Accessing OpenGL Thread */

/** If you want to run any Cocos2D task, run it in this thread. Any task that modifies Cocos2D's OpenGL state must be
 executed on this thread due to OpenGL state changes only being allowed on the OpenGL thread.
 
 @returns The Cocos2D thread, typically this will be the main thread. */
@property (weak, readonly, nonatomic ) NSThread *runningThread;

#pragma mark Director - Stats

#pragma mark Director - View Size

/** @name View Scale */

/** Content scaling factor. Sets the ratio of points to pixels. Default value is initalized from the content scale of the GL view used by the director.
 @see UIScaleFactor
 @see [UIView contentScaleFactor](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/#//apple_ref/occ/instp/UIView/contentScaleFactor)
 */
@property(nonatomic, assign) CGFloat contentScaleFactor;

/** UI scaling factor, default value is 1. Positions and content sizes are scale by this factor if the position type is set to scale.
 @see contentScaleFactor
 */
@property (nonatomic,readwrite,assign) float UIScaleFactor;

/// User definable value that is used for default contentSizes of many node types (CCScene, CCNodeColor, etc).
/// Defaults to the view size.
@property(nonatomic, assign) CGSize designSize;


/** @name Working with View and Projection */

/// View used by the director for rendering. The CC_VIEW macro equals UIView on iOS, NSOpenGLView on OS X and CCGLView.
/// @see CCDirectorView
@property(nonatomic, strong) CC_VIEW<CCDirectorView> *view;
/** Sets an OpenGL projection
 @see CCDirectorProjection
 @see projectionMatrix */
@property (nonatomic, readwrite) CCDirectorProjection projection;
/// Projection matrix used for rendering.
/// @see projection
@property(nonatomic, readonly) GLKMatrix4 projectionMatrix;

/// Rect of the visible screen area in GL coordinates.
@property(nonatomic, readonly) CGRect viewportRect;

/* Sets the glViewport*/
-(void) setViewport;

/// The current global shader values values.
@property(nonatomic, readonly) NSMutableDictionary *globalShaderUniforms;
/** Whether or not to display statistics in the view's lower left corner. From top to bottom the numbers are:
 number of draw calls, time per frame (in seconds), framerate (average over most recent frames).
 @see totalFrames
 @see secondsPerFrame */
@property (nonatomic, readwrite, assign) BOOL displayStats;

/** @returns The size of the view in points.
 @see viewSizeInPixels */
- (CGSize) viewSize;

/** @returns The size of the view in pixels.
 On Mac winSize and winSizeInPixels return the same value.
 @see viewSize
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

/** @name Presenting Scenes */

/** The current running Scene. Director can only run one Scene at a time.
 @see presentScene: */
@property (nonatomic, readonly) CCScene* runningScene;

/**
 *  Presents a new scene.
 *
 *  If no scene is currently running, the scene will be started.
 *  
 *  If another scene is currently running, this scene will be stopped, and the new scene started.
 *
 *  @param scene Scene to start.
 *  @see presentScene:withTransition:
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
 *  @param transition Transition to use. Can be nil.
 *  @see presentScene:
 */
- (void)presentScene:(CCScene *)scene withTransition:(CCTransition *)transition;

// purposefully undocumented: is the same as calling presentScene:
- (void) runWithScene:(CCScene*) scene;

/**
 * Suspends the execution of the running scene, pushing it on the stack of suspended scenes.
 *
 * The new scene will be executed, the previous scene remains in memory.
 * Try to avoid big stacks of pushed scenes to reduce memory allocation.
 *
 *  @warning ONLY call it if there is already a running scene.
 *
 *  @param scene New scene to start.
 *  @see pushScene:withTransition:
 *  @see popScene
 *  @see popToRootScene
 */
- (void) pushScene:(CCScene*) scene;

/** Pops out a scene from the queue. This scene will replace the running one.
 * The running scene will be deleted. If there are no more scenes in the stack the execution is terminated.
 *
 *  @warning ONLY call it if there is a running scene.
 *
 *  @see pushScene:
 *  @see popSceneWithTransition:
 *  @see popToRootScene
 */
- (void) popScene;

/**Pops out all scenes from the queue until the root scene in the queue.
 *
 * This scene will replace the running one.
 * Internally it will call `popToSceneStackLevel:1`
 *  @see popScene
 *  @see pushScene:
 */
- (void) popToRootScene;

/**Pops out all scenes from the queue until the root scene in the queue, using a transition
 *
 * This scene will replace the running one. Internally it will call `popToRootScene`
 * @param transition The transition to play.
 *  @see popToRootScene
 */
-(void) popToRootSceneWithTransition:(CCTransition *)transition;

/* Pops out all scenes from the queue until it reaches `level`.
 If level is 0, it will end the director.
 If level is 1, it will pop all scenes until it reaches to root scene.
 If level is <= than the current stack level, it won't do anything.
 */
-(void) popToSceneStackLevel:(NSUInteger)level;

// purposefully undocumented: is the same as calling presentScene:
-(void) replaceScene: (CCScene*) scene;

// purposefully undocumented: is the same as calling presentScene:withTransition:
- (void)replaceScene:(CCScene *)scene withTransition:(CCTransition *)transition;

/**
 *  Pushes the running scene onto the scene stack, and presents the incoming scene, using a transition
 *
 *  @param scene      The scene to present
 *  @param transition The transition to use
 *  @see pushScene:
 */
- (void)pushScene:(CCScene *)scene withTransition:(CCTransition *)transition;

/**
 *  Replaces the running scene, with the last scene pushed to the stack, using a transition
 *
 *  @param transition The transition to use
 *	@see popScene
 */
- (void)popSceneWithTransition:(CCTransition *)transition;

- (void)startTransition:(CCTransition *)transition;

/* Draw the scene.
 This method is called every frame. Don't call it manually.
 */
-(void) drawScene;

/** @name Animating the Active Scene */

/** The animation interval is the time per frame. Typically specified as `1.0 / 60.0` where the latter number defines
 the framerate. The lowest value is 0.0166 (1/60).
 @see fixedUpdateInterval */
@property (nonatomic, readwrite, assign) CCTime animationInterval;
/** The fixed animation interval is used to run "fixed updates" at a fixed rate, independently of the framerate. Used primarly by the physics engine.
 @see animationInterval */
@property (nonatomic, readwrite, assign) CCTime fixedUpdateInterval;
/** whether or not the next delta time will be zero */
@property (nonatomic,readwrite,assign,getter=isNextDeltaTimeZero) BOOL nextDeltaTimeZero;
/** Whether or not the Director is paused.
 @see animating
 @see pause
 @see resume */
@property (nonatomic, readonly,getter=isPaused) BOOL paused;
/** Whether or not the Director is active (animating).
 @see paused
 @see startAnimation
 @see stopAnimation */
@property (nonatomic, readonly,getter=isAnimating) BOOL animating;
/** How many frames were called since the director started
 @see secondsPerFrame
 @see displayStats */
@property (nonatomic, readonly) NSUInteger totalFrames;
/** Time it took to render the most recent frames, in seconds per frame.
 @see totalFrames
 @see displayStats */
@property (nonatomic, readonly) CCTime secondsPerFrame;

/** Ends the execution, releases the running scene.
 It doesn't remove the view from the view hierarchy. You have to do it manually.
 */
-(void) end;

/** Pauses the running scene. All scheduled timers and actions will be paused.
 When paused, the director refreshes the screen at a very low framerate (4 fps) to conserve battery power.
 @see resume
 */
-(void) pause;

/** Resumes the paused scene and its scheduled timers and actions.
 The "delta time" will be set to 0 as if the game wasn't paused.
 @see pause
 @see nextDeltaTimeZero
 */
-(void) resume;

/** Stops the animation. All scheduled updates and actions are effectively paused. 

 When not animating, the director doesn't redraw the view at all. It is best to hide the view when not animating the director.
 If you need to keep showing the director's view use pause instead.
 
 @see startAnimation
 */
-(void) stopAnimation;

/** Begins drawing the screen. Scheduled timers and actions will run.
 
 @warning Don't call this function to start the main loop. To run the main loop call presentScene:
 @see stopAnimation */
-(void) startAnimation;

#pragma mark Director - Memory Helper

/** @name Purging Caches */

/** Removes all the cocos2d resources that have been previously loaded and automatically cached, textures for instance. */
-(void) purgeCachedData;

#pragma mark Internal stuff

/* Whether or not the replaced scene will receive the cleanup message.
 If the new scene is pushed, then the old scene won't receive the "cleanup" message.
 If the new scene replaces the old one, the it will receive the "cleanup" message.
 */
@property (nonatomic, readonly) BOOL sendCleanupToScene;

/* This object will be visited after the main scene is visited.
 This object MUST implement the "visit" selector.
 Useful to hook a notification object, like CCNotifications (http://github.com/manucorporat/CCNotifications)
 */
@property (nonatomic, readwrite, strong) id	notificationNode;

/* CCScheduler associated with this director
 */
@property (nonatomic,readwrite,strong) CCScheduler *scheduler;

/* CCActionManager associated with this director
 */
@property (nonatomic,readwrite,strong) CCActionManager *actionManager;

/* CCFixedActionManager associated with this director
 */
@property (nonatomic,readwrite,strong) CCActionManager *actionManagerFixed;

/// XXX: missing description
-(float) getZEye;

/// Get a renderer object to use for rendering.
/// This method is thread safe.
-(CCRenderer *)rendererFromPool;

/// Return a renderer to a pool after rendering.
/// This method is thread safe.
-(void)poolRenderer:(CCRenderer *)renderer;

/// Add a block to be called when the GPU finishes rendering a frame.
/// This is used to pool rendering resources (renderers, buffers, textures, etc) without stalling the GPU pipeline.
-(void)addFrameCompletionHandler:(dispatch_block_t)handler;

-(void) createStatsLabel;

@end

// optimization. Should only be used to read it. Never to write it.
extern NSUInteger __ccNumberOfDraws;

// optimization. Should only be used to read it. Never to write it.
extern CGFloat	__ccContentScaleFactor;
