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


/* Idea of decoupling Window from Director taken from OC3D project: http://code.google.com/p/oc3d/
 */

#import <unistd.h>

// cocos2d imports
#import "CCDirector.h"
#import "CCScheduler.h"
#import "CCActionManager.h"
#import "CCTextureCache.h"
#import "CCAnimationCache.h"
#import "CCLabelAtlas.h"
#import "ccMacros.h"
#import "CCScene.h"
#import "CCSpriteFrameCache.h"
#import "CCTexture.h"
#import "CCLabelBMFont.h"
#import "ccGLStateCache.h"
#import "CCShaderCache.h"
#import "ccFPSImages.h"
#import "CCConfiguration.h"
#import "CCTransition.h"

// support imports
#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"

#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"
#import "Support/CCProfiling.h"
#import "Support/CCFileUtils.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#define CC_DIRECTOR_DEFAULT CCDirectorDisplayLink
#elif defined(__CC_PLATFORM_MAC)
#import "Platforms/Mac/CCDirectorMac.h"
#define CC_DIRECTOR_DEFAULT CCDirectorDisplayLink
#endif

#import "CCDirector_Private.h"
#import "CCNode_Private.h"

#pragma mark -
#pragma mark Director - global variables (optimization)

CGFloat	__ccContentScaleFactor = 1;

// XXX it shoul be a Director ivar. Move it there once support for multiple directors is added
NSUInteger	__ccNumberOfDraws = 0;

#define kDefaultFPS		60.0	// 60 frames per second

extern NSString * cocos2dVersion(void);

@interface CCScheduler (Private)
@property(nonatomic, assign) CCTime fixedUpdateInterval;
@end

@interface CCDirector (Private)
-(void) setNextScene;
// shows the statistics
-(void) showStats;
// calculates delta time since last time it was called
-(void) calculateDeltaTime;
// calculates the milliseconds per frame from the start of the frame
-(void) calculateMPF;
@end

@implementation CCDirector

@synthesize animationInterval = _animationInterval;
@synthesize runningScene = _runningScene;
@synthesize displayStats = _displayStats;
@synthesize nextDeltaTimeZero = _nextDeltaTimeZero;
@synthesize paused = _isPaused;
@synthesize animating = _animating;
@synthesize sendCleanupToScene = _sendCleanupToScene;
@synthesize runningThread = _runningThread;
@synthesize notificationNode = _notificationNode;
@synthesize delegate = _delegate;
@synthesize totalFrames = _totalFrames;
@synthesize secondsPerFrame = _secondsPerFrame;
@synthesize scheduler = _scheduler;
@synthesize actionManager = _actionManager;

//
// singleton stuff
//
static CCDirector *_sharedDirector = nil;

+ (CCDirector *)sharedDirector
{
	if (!_sharedDirector) {

		//
		// Default Director is DisplayLink
		//
		if( [ [CCDirector class] isEqual:[self class]] )
			_sharedDirector = [[CC_DIRECTOR_DEFAULT alloc] init];
		else
			_sharedDirector = [[self alloc] init];
	}

	return _sharedDirector;
}

+(id)alloc
{
	NSAssert(_sharedDirector == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

// Force creation of a new singleton, useful to prevent state leaking during tests.
+ (void) resetSingleton
{
	_sharedDirector = nil;
}

- (id) init
{
	if( (self=[super init] ) ) {

		// scenes
		_runningScene = nil;
		_nextScene = nil;

		_notificationNode = nil;

		_oldAnimationInterval = _animationInterval = 1.0 / kDefaultFPS;
		_scenesStack = [[NSMutableArray alloc] initWithCapacity:10];

		// Set default projection (3D)
		_projection = CCDirectorProjectionDefault;

		// projection delegate if "Custom" projection is used
		_delegate = nil;

		// FPS
		_displayStats = NO;
		_totalFrames = _frames = 0;

		// paused ?
		_isPaused = NO;

		// running thread
		_runningThread = nil;

		// scheduler
		_scheduler = [[CCScheduler alloc] init];

		// action manager
		_actionManager = [[CCActionManager alloc] init];
		[_scheduler scheduleTarget:_actionManager];
		[_scheduler setPaused:NO target:_actionManager];
        
        // touch manager
        _responderManager = [ CCResponderManager responderManager ];

		_winSizeInPixels = _winSizeInPoints = CGSizeZero;
		
		__ccContentScaleFactor = 1;
		self.UIScaleFactor = 1;
	}

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Size: %0.f x %0.f, view = %@>", [self class], self, _winSizeInPoints.width, _winSizeInPoints.height, __view];
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);


	_sharedDirector = nil;

}

-(void) setGLDefaultValues
{
	// This method SHOULD be called only after __view was initialized
	NSAssert( __view, @"__view must be initialized");

	[self setAlphaBlending: YES];
	[self setDepthTest: __view.depthFormat];
	[self setProjection: _projection];

	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

//
// Draw the Scene
//
- (void) drawScene
{
	// Override me
}

-(void) calculateDeltaTime
{
	struct timeval now;

	if( gettimeofday( &now, NULL) != 0 ) {
		CCLOG(@"cocos2d: error in gettimeofday");
		_dt = 0;
		return;
	}

	// new delta time
	if( _nextDeltaTimeZero ) {
		_dt = 0;
		_nextDeltaTimeZero = NO;
	} else {
		_dt = (now.tv_sec - _lastUpdate.tv_sec) + (now.tv_usec - _lastUpdate.tv_usec) / 1000000.0f;
		_dt = MAX(0,_dt);
	}

#ifdef DEBUG
	// If we are debugging our code, prevent big delta time
	if( _dt > 0.2f )
		_dt = 1/60.0f;
#endif

	_lastUpdate = now;
}

#pragma mark Director - Memory Helper

-(void) purgeCachedData
{
	[CCLabelBMFont purgeCachedData];
	if ([_sharedDirector view])
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[[CCFileUtils sharedFileUtils] purgeCachedEntries];
}

#pragma mark Director - Scene OpenGL Helper

-(CCDirectorProjection) projection
{
	return _projection;
}

-(float) getZEye
{
	return ( _winSizeInPixels.height / 1.1566f / __ccContentScaleFactor );
}

-(void) setViewport
{
	CCLOG(@"cocos2d: override me");
}

-(void) setProjection:(CCDirectorProjection)projection
{
	CCLOG(@"cocos2d: override me");
}

- (void) setAlphaBlending: (BOOL) on
{
	if (on) {
		ccGLBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);

	} else
		ccGLBlendFunc(GL_ONE, GL_ZERO);

	CHECK_GL_ERROR_DEBUG();
}

- (void) setDepthTest: (BOOL) on
{
	if (on) {
		glClearDepth(1.0f);

		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
//		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	} else
		glDisable( GL_DEPTH_TEST );

	CHECK_GL_ERROR_DEBUG();
}

#pragma mark Director Integration with a UIKit view

-(void) setView:(CCGLView*)view
{
//	NSAssert( view, @"OpenGLView must be non-nil");

	if( view != __view ) {
	
#ifdef __CC_PLATFORM_IOS
		[super setView:view];
#endif
		__view = view;

		// set size
		CGSize size = CCNSSizeToCGSize(__view.bounds.size);
#ifdef __CC_PLATFORM_IOS
		CGFloat scale = __view.layer.contentsScale ?: 1.0;
#else
		//self.view.wantsBestResolutionOpenGLSurface = YES;
		CGFloat scale = self.view.window.backingScaleFactor;
#endif
		
		_winSizeInPixels = CGSizeMake(size.width*scale, size.height*scale);
		_winSizeInPoints = size;
		__ccContentScaleFactor = scale;

		// it could be nil
		if( view ) {
			[self createStatsLabel];
			[self setGLDefaultValues];
		}

		// Dump info once OpenGL was initilized
		[[CCConfiguration sharedConfiguration] dumpInfo];

		CHECK_GL_ERROR_DEBUG();
	}
}

-(CCGLView*) view
{
	return  __view;
}


#pragma mark Director Scene Landscape

-(CGFloat) contentScaleFactor
{
	return __ccContentScaleFactor;
}

-(void) setContentScaleFactor:(CGFloat)scaleFactor
{
	NSAssert(scaleFactor > 0.0, @"scaleFactor must be positive.");
	
	if( scaleFactor != __ccContentScaleFactor ) {
		__ccContentScaleFactor = scaleFactor;
		_winSizeInPoints = CGSizeMake( _winSizeInPixels.width / scaleFactor, _winSizeInPixels.height / scaleFactor );

		// update projection
		[self setProjection:_projection];
		
		[[CCFileUtils sharedFileUtils] buildSearchResolutionsOrder];
		[self createStatsLabel];
	}
}

static void
GLToClipTransform(kmMat4 *transformOut)
{
	kmMat4 projection;
	kmGLGetMatrix(KM_GL_PROJECTION, &projection);
	
	kmMat4 modelview;
	kmGLGetMatrix(KM_GL_MODELVIEW, &modelview);
	
	kmMat4Multiply(transformOut, &projection, &modelview);
}

-(CGFloat)flipY
{
	return -1.0;
}

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	kmMat4 transform;
	GLToClipTransform(&transform);
	
	kmMat4 transformInv;
	kmMat4Inverse(&transformInv, &transform);
	
	// Calculate z=0 using -> transform*[0, 0, 0, 1]/w
	kmScalar zClip = transform.mat[14]/transform.mat[15];
	
	CGSize glSize = __view.bounds.size;
	kmVec3 clipCoord = {2.0*uiPoint.x/glSize.width - 1.0, 2.0*uiPoint.y/glSize.height - 1.0, zClip};
	clipCoord.y *= self.flipY;
	
	kmVec3 glCoord;
	kmVec3TransformCoord(&glCoord, &clipCoord, &transformInv);
	
//	NSLog(@"uiPoint: %@, glPoint: %@", NSStringFromCGPoint(uiPoint), NSStringFromCGPoint(ccp(glCoord.x, glCoord.y)));
	return ccp(glCoord.x, glCoord.y);
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	kmMat4 transform;
	GLToClipTransform(&transform);
		
	kmVec3 clipCoord;
	// Need to calculate the zero depth from the transform.
	kmVec3 glCoord = {glPoint.x, glPoint.y, 0.0};
	kmVec3TransformCoord(&clipCoord, &glCoord, &transform);
	
	CGSize glSize = __view.bounds.size;
	return ccp(glSize.width*(clipCoord.x*0.5 + 0.5), glSize.height*(self.flipY*clipCoord.y*0.5 + 0.5));
}

-(CGSize)viewSize
{
	return _winSizeInPoints;
}

-(CGSize)viewSizeInPixels
{
	return _winSizeInPixels;
}

-(CGRect)viewportRect
{
	// TODO It's _possible_ that a user will use a non-axis aligned projection. Weird, but possible.
	kmMat4 transform;
	GLToClipTransform(&transform);
		
	kmMat4 transformInv;
	kmMat4Inverse(&transformInv, &transform);
	
	// Calculate z=0 using -> transform*[0, 0, 0, 1]/w
	kmScalar zClip = transform.mat[14]/transform.mat[15];
	
	// Bottom left and top right coordinates of viewport in clip coords.
	kmVec3 clipBL = {-1.0, -1.0, zClip};
	kmVec3 clipTR = { 1.0,  1.0, zClip};
	
	kmVec3 glBL, glTR;
	kmVec3TransformCoord(&glBL, &clipBL, &transformInv);
	kmVec3TransformCoord(&glTR, &clipTR, &transformInv);
	
	return CGRectMake(glBL.x, glBL.y, glTR.x - glBL.x, glTR.y - glBL.y);
}

-(CGSize)designSize
{
	// Return the viewSize unless designSize has been set.
	return (CGSizeEqualToSize(_designSize, CGSizeZero) ? self.viewSize : _designSize);
}

-(void) reshapeProjection:(CGSize)newWindowSize
{
	_winSizeInPixels = newWindowSize;
	_winSizeInPoints = CGSizeMake( _winSizeInPixels.width / __ccContentScaleFactor, _winSizeInPixels.height / __ccContentScaleFactor );
	
	[self setProjection:_projection];
}

#pragma mark Director Scene Management

- (void)runWithScene:(CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	NSAssert(_runningScene == nil, @"This command can only be used to start the CCDirector. There is already a scene present.");

	[self pushScene:scene];
	[self startAnimation];
}

- (void)presentScene:(CCScene *)scene
{
    if (_runningScene)
        [self replaceScene:scene];
    else
        [self runWithScene:scene];
}

- (void)presentScene:(CCScene *)scene withTransition:(CCTransition *)transition
{
    if (_runningScene)
        [self replaceScene:scene withTransition:transition];
    else
        [self runWithScene:scene];
}

- (void) pushScene: (CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	_sendCleanupToScene = NO;

	[_scenesStack addObject: scene];
	_nextScene = scene;	// _nextScene is a weak ref
}

- (void)pushScene:(CCScene *)scene withTransition:(CCTransition *)transition
{
	NSAssert(scene, @"Scene must be non-nil");
    
    [_scenesStack addObject:scene];
    _sendCleanupToScene = NO;
    [transition performSelector:@selector(startTransition:) withObject:scene];
}

-(void) popScene
{
	NSAssert( _runningScene != nil, @"A running Scene is needed");

	[_scenesStack removeLastObject];
	NSUInteger c = [_scenesStack count];

	if( c == 0 )
		[self end];
	else {
		_sendCleanupToScene = YES;
		_nextScene = [_scenesStack objectAtIndex:c-1];
	}
}

- (void)popSceneWithTransition:(CCTransition *)transition
{
	NSAssert( _runningScene != nil, @"A running Scene is needed");
    
    if (_scenesStack.count < 2)
    {
        [self end];
    }
    else
    {
        [_scenesStack removeLastObject];
        CCScene * incomingScene = [_scenesStack lastObject];
        _sendCleanupToScene = YES;
        [transition performSelector:@selector(startTransition:) withObject:incomingScene];
    }
}

-(void) popToRootScene
{
	[self popToSceneStackLevel:1];
}

-(void) popToSceneStackLevel:(NSUInteger)level
{
	NSAssert(_runningScene != nil, @"A running Scene is needed");
	NSUInteger c = [_scenesStack count];

	// level 0? -> end
	if( level == 0) {
		[self end];
		return;
	}

	// current level or lower -> nothing
	if( level >= c)
		return;

	// pop stack until reaching desired level
	while (c > level) {
		CCScene *current = [_scenesStack lastObject];
		if( current.runningInActiveScene ){
			[current onExitTransitionDidStart];
			[current onExit];
		}
		[current cleanup];

		[_scenesStack removeLastObject];
		c--;
	}
	_nextScene = [_scenesStack lastObject];
	_sendCleanupToScene = NO;
}

// -----------------------------------------------------------------

- (void)replaceScene:(CCScene *)scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

    if (_runningScene)
    {
        _sendCleanupToScene = YES;
        [_scenesStack removeLastObject];
        [_scenesStack addObject:scene];
        _nextScene = scene;	// _nextScene is a weak ref
    }
    else
    {
        [self pushScene:scene];
        [self startAnimation];
    }
}

- (void)replaceScene:(CCScene *)scene withTransition:(CCTransition *)transition
{
    // the transition gets to become the running scene
    _sendCleanupToScene = YES;
    [transition performSelector:@selector(startTransition:) withObject:scene];
}

// -----------------------------------------------------------------

- (void)startTransition:(CCTransition *)transition
{
	NSAssert(transition, @"Argument must be non-nil");
    NSAssert(_runningScene, @"There must be a running scene");
    
    [_scenesStack removeLastObject];
    [_scenesStack addObject:transition];
    _nextScene = transition;
}

// -----------------------------------------------------------------

-(void) end
{
	[_runningScene onExitTransitionDidStart];
	[_runningScene onExit];
	[_runningScene cleanup];

	_runningScene = nil;
	_nextScene = nil;

	// remove all objects, but don't release it.
	// runWithScene might be executed after 'end'.
	[_scenesStack removeAllObjects];

	[self stopAnimation];

	_FPSLabel = nil, _SPFLabel=nil, _drawsLabel=nil;

	_delegate = nil;

	[self setView:nil];
	
	// Purge bitmap cache
	[CCLabelBMFont purgeCachedData];

	// Purge all managers / caches
	[CCAnimationCache purgeSharedAnimationCache];
	[CCSpriteFrameCache purgeSharedSpriteFrameCache];
	[CCTextureCache purgeSharedTextureCache];
	[CCShaderCache purgeSharedShaderCache];
	[[CCFileUtils sharedFileUtils] purgeCachedEntries];

	// OpenGL view

	// Since the director doesn't attach the openglview to the window
	// it shouldn't remove it from the window too.
//	[openGLView_ removeFromSuperview];


	// Invalidate GL state cache
	ccGLInvalidateStateCache();

	CHECK_GL_ERROR();
}

-(void) setNextScene
{
    // If next scene is a transition, the transition has just started
    // Make transition the running scene.
    // Outgoing scene will continue to run
    // Incoming scene was started by transition
    if ([_nextScene isKindOfClass:[CCTransition class]])
    {
        _runningScene = nil;
        _runningScene = _nextScene;
        _nextScene = nil;
        [_runningScene onEnter];
        return;
    }
    
    // If running scene is a transition class, the transition has ended
    // Make new scene, the running scene
    // Clean up transition
    // Outgoing scene was stopped by transition
    if ([_runningScene isKindOfClass:[CCTransition class]])
    {
        [_runningScene onExit];
        [_runningScene cleanup];
        _runningScene = nil;
        _runningScene = _nextScene;
        _nextScene = nil;
        return;
    }

    
	// if next scene is not a transition, force exit calls
	if (![_nextScene isKindOfClass:[CCTransition class]])
    {
		[_runningScene onExitTransitionDidStart];
		[_runningScene onExit];

		// issue #709. the root node (scene) should receive the cleanup message too
		// otherwise it might be leaked.
		if (_sendCleanupToScene) [_runningScene cleanup];
	}

	_runningScene = _nextScene;
	_nextScene = nil;

    // if running scene is not a transition, force enter calls
	if (![_runningScene isKindOfClass:[CCTransition class]])
    {
		[_runningScene onEnter];
		[_runningScene onEnterTransitionDidFinish];
        [_runningScene setPaused:NO];
	}
}

-(void) pause
{
	if( _isPaused )
		return;

	_oldAnimationInterval = _animationInterval;

	// when paused, don't consume CPU
	[self setAnimationInterval:1/4.0];
	
	[self willChangeValueForKey:@"isPaused"];
	_isPaused = YES;
	[self didChangeValueForKey:@"isPaused"];
}

-(void) resume
{
	if( ! _isPaused )
		return;

	[self setAnimationInterval: _oldAnimationInterval];

	if( gettimeofday( &_lastUpdate, NULL) != 0 ) {
		CCLOG(@"cocos2d: Director: Error in gettimeofday");
	}

	[self willChangeValueForKey:@"isPaused"];
	_isPaused = NO;
	[self didChangeValueForKey:@"isPaused"];

	_dt = 0;
}

- (void)startAnimation
{
	_nextDeltaTimeZero = YES;
}

- (void)stopAnimation
{
	CCLOG(@"cocos2d: Director#stopAnimation. Override me");
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	CCLOG(@"cocos2d: Director#setAnimationInterval. Override me");
}

- (CCTime)fixedUpdateInterval
{
	return self.scheduler.fixedUpdateInterval;
}

-(void)setFixedUpdateInterval:(CCTime)fixedUpdateInterval
{
	self.scheduler.fixedUpdateInterval = fixedUpdateInterval;
}


// display statistics
-(void) showStats
{
	_frames++;
	_accumDt += _dt;

	if( _displayStats ) {
		// Ms per Frame

		if( _accumDt > CC_DIRECTOR_STATS_INTERVAL)
		{
			NSString *spfstr = [[NSString alloc] initWithFormat:@"%.3f", _secondsPerFrame];
			[_SPFLabel setString:spfstr];

			_frameRate = _frames/_accumDt;
			_frames = 0;
			_accumDt = 0;

//			sprintf(format,"%.1f",frameRate);
//			[FPSLabel setCString:format];

			NSString *fpsstr = [[NSString alloc] initWithFormat:@"%.1f", _frameRate];
			[_FPSLabel setString:fpsstr];
			
			NSString *draws = [[NSString alloc] initWithFormat:@"%4lu", (unsigned long)__ccNumberOfDraws];
			[_drawsLabel setString:draws];
		}

		[_drawsLabel visit];
		[_FPSLabel visit];
		[_SPFLabel visit];
	}
	
	__ccNumberOfDraws = 0;
}

-(void) calculateMPF
{
	struct timeval now;
	gettimeofday( &now, NULL);

	_secondsPerFrame = (now.tv_sec - _lastUpdate.tv_sec) + (now.tv_usec - _lastUpdate.tv_usec) / 1000000.0f;
}

#pragma mark Director - Helper

-(void)getFPSImageData:(unsigned char**)datapointer length:(NSUInteger*)len contentScale:(CGFloat *)scale
{
	*datapointer = cc_fps_images_png;
	*len = cc_fps_images_len();
	*scale = 1.0;
}

-(void) createStatsLabel
{
	if( _FPSLabel && _SPFLabel ) {
		_FPSLabel = nil;
		_SPFLabel = nil;
		_drawsLabel = nil;
		
		[[CCFileUtils sharedFileUtils] purgeCachedEntries];
	}

	CCTexturePixelFormat currentFormat = [CCTexture defaultAlphaPixelFormat];
	[CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA4444];

	unsigned char *data;
	NSUInteger data_len;
	CGFloat contentScale = 0;
	[self getFPSImageData:&data length:&data_len contentScale:&contentScale];
	
	NSData *nsdata = [NSData dataWithBytes:data length:data_len];
	CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData( (__bridge CFDataRef) nsdata);
	CGImageRef imageRef = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
	CCTexture *texture = [[CCTexture alloc] initWithCGImage:imageRef contentScale:contentScale];
	CGDataProviderRelease(imgDataProvider);
	CGImageRelease(imageRef);

	_FPSLabel = [[CCLabelAtlas alloc]  initWithString:@"00.0" texture:texture itemWidth:12 itemHeight:32 startCharMap:'.'];
	_SPFLabel = [[CCLabelAtlas alloc]  initWithString:@"0.000" texture:texture itemWidth:12 itemHeight:32 startCharMap:'.'];
	_drawsLabel = [[CCLabelAtlas alloc]  initWithString:@"000" texture:texture itemWidth:12 itemHeight:32 startCharMap:'.'];

	[CCTexture setDefaultAlphaPixelFormat:currentFormat];
	
	CGPoint offset = [self convertToGL:ccp(0, (self.flipY == 1.0) ? 0 : __view.bounds.size.height)];
	CGPoint pos = ccpAdd(CC_DIRECTOR_STATS_POSITION, offset);
	[_drawsLabel setPosition: ccpAdd( ccp(0,34), pos ) ];
	[_SPFLabel setPosition: ccpAdd( ccp(0,17), pos ) ];
	[_FPSLabel setPosition: pos ];
}

@end

