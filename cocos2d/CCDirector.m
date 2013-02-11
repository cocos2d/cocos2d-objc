/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
#import "CCTransition.h"
#import "CCScene.h"
#import "CCSpriteFrameCache.h"
#import "CCTexture2D.h"
#import "CCLabelBMFont.h"
#import "CCLayer.h"
#import "ccGLStateCache.h"
#import "CCShaderCache.h"
#import "ccFPSImages.h"
#import "CCDrawingPrimitives.h"
#import "CCConfiguration.h"

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


#pragma mark -
#pragma mark Director - global variables (optimization)

// XXX it shoul be a Director ivar. Move it there once support for multiple directors is added
NSUInteger	__ccNumberOfDraws = 0;

#define kDefaultFPS		60.0	// 60 frames per second

extern NSString * cocos2dVersion(void);

@interface CCDirector (Private)
-(void) setNextScene;
// shows the statistics
-(void) showStats;
// calculates delta time since last time it was called
-(void) calculateDeltaTime;
// calculates the milliseconds per frame from the start of the frame
-(void) calculateMPF;
// returns the FPS image data pointer and len
-(void)getFPSImageData:(unsigned char**)datapointer length:(NSUInteger*)len;
@end

@implementation CCDirector

@synthesize animationInterval = _animationInterval;
@synthesize runningScene = _runningScene;
@synthesize displayStats = _displayStats;
@synthesize nextDeltaTimeZero = _nextDeltaTimeZero;
@synthesize paused = _isPaused;
@synthesize isAnimating = _isAnimating;
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
		_projection = kCCDirectorProjectionDefault;

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
		[_scheduler scheduleUpdateForTarget:_actionManager priority:kCCPrioritySystem paused:NO];

		_winSizeInPixels = _winSizeInPoints = CGSizeZero;
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

	[_FPSLabel release];
	[_SPFLabel release];
	[_drawsLabel release];
	[_runningScene release];
	[_notificationNode release];
	[_scenesStack release];
	[_scheduler release];
	[_actionManager release];

	_sharedDirector = nil;

	[super dealloc];
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

-(ccDirectorProjection) projection
{
	return _projection;
}

-(float) getZEye
{
	return ( _winSizeInPixels.height / 1.1566f / CC_CONTENT_SCALE_FACTOR() );
}

-(void) setViewport
{
	CCLOG(@"cocos2d: override me");
}

-(void) setProjection:(ccDirectorProjection)projection
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
		[__view release];
		__view = [view retain];

		// set size
		_winSizeInPixels = _winSizeInPoints = CCNSSizeToCGSize( [__view bounds].size );

		[self createStatsLabel];
		
		// it could be nil
		if( view )
			[self setGLDefaultValues];

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

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	CCLOG(@"CCDirector#convertToGL: OVERRIDE ME.");
	return CGPointZero;
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	CCLOG(@"CCDirector#convertToUI: OVERRIDE ME.");
	return CGPointZero;
}

-(CGSize)winSize
{
	return _winSizeInPoints;
}

-(CGSize)winSizeInPixels
{
	return _winSizeInPixels;
}

-(void) reshapeProjection:(CGSize)newWindowSize
{
	_winSizeInPixels = _winSizeInPoints = newWindowSize;
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

-(void) replaceScene: (CCScene*) scene
{
	NSAssert( _runningScene, @"Use runWithScene: instead to start the director");
	NSAssert( scene != nil, @"Argument must be non-nil");

	NSUInteger index = [_scenesStack count];

	_sendCleanupToScene = YES;
	[_scenesStack replaceObjectAtIndex:index-1 withObject:scene];
	_nextScene = scene;	// _nextScene is a weak ref
}

- (void) pushScene: (CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	_sendCleanupToScene = NO;

	[_scenesStack addObject: scene];
	_nextScene = scene;	// _nextScene is a weak ref
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

-(void) popToRootScene
{
	NSAssert(_runningScene != nil, @"A running Scene is needed");
	NSUInteger c = [_scenesStack count];
	
	if (c == 1) {
		[_scenesStack removeLastObject];
		[self end];
	} else {
		while (c > 1) {
			CCScene *current = [_scenesStack lastObject];
			if( [current isRunning] ){
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
}

-(void) end
{
	[_runningScene onExitTransitionDidStart];
	[_runningScene onExit];
	[_runningScene cleanup];
	[_runningScene release];

	_runningScene = nil;
	_nextScene = nil;

	// remove all objects, but don't release it.
	// runWithScene might be executed after 'end'.
	[_scenesStack removeAllObjects];

	[self stopAnimation];

	[_FPSLabel release];
	[_SPFLabel release];
	[_drawsLabel release];
	_FPSLabel = nil, _SPFLabel=nil, _drawsLabel=nil;

	_delegate = nil;

	[self setView:nil];
	
	// Purge bitmap cache
	[CCLabelBMFont purgeCachedData];

	// Purge all managers / caches
	ccDrawFree();
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
	Class transClass = [CCTransitionScene class];
	BOOL runningIsTransition = [_runningScene isKindOfClass:transClass];
	BOOL newIsTransition = [_nextScene isKindOfClass:transClass];

	// If it is not a transition, call onExit/cleanup
	if( ! newIsTransition ) {
		[_runningScene onExitTransitionDidStart];
		[_runningScene onExit];

		// issue #709. the root node (scene) should receive the cleanup message too
		// otherwise it might be leaked.
		if( _sendCleanupToScene)
			[_runningScene cleanup];
	}

	[_runningScene release];

	_runningScene = [_nextScene retain];
	_nextScene = nil;

	if( ! runningIsTransition ) {
		[_runningScene onEnter];
		[_runningScene onEnterTransitionDidFinish];
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
			[spfstr release];

			_frameRate = _frames/_accumDt;
			_frames = 0;
			_accumDt = 0;

//			sprintf(format,"%.1f",frameRate);
//			[FPSLabel setCString:format];

			NSString *fpsstr = [[NSString alloc] initWithFormat:@"%.1f", _frameRate];
			[_FPSLabel setString:fpsstr];
			[fpsstr release];
			
			NSString *draws = [[NSString alloc] initWithFormat:@"%4lu", (unsigned long)__ccNumberOfDraws];
			[_drawsLabel setString:draws];
			[draws release];
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

-(void)getFPSImageData:(unsigned char**)datapointer length:(NSUInteger*)len
{
	*datapointer = cc_fps_images_png;
	*len = cc_fps_images_len();
}

-(void) createStatsLabel
{
	CCTexture2D *texture;
	CCTextureCache *textureCache = [CCTextureCache sharedTextureCache];
	
	if( _FPSLabel && _SPFLabel ) {

		[_FPSLabel release];
		[_SPFLabel release];
		[_drawsLabel release];
		[textureCache removeTextureForKey:@"cc_fps_images"];
		_FPSLabel = nil;
		_SPFLabel = nil;
		_drawsLabel = nil;
		
		[[CCFileUtils sharedFileUtils] purgeCachedEntries];
	}

	CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];

	unsigned char *data;
	NSUInteger data_len;
	[self getFPSImageData:&data length:&data_len];
	
	NSData *nsdata = [NSData dataWithBytes:data length:data_len];
	CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData( (CFDataRef) nsdata);
	CGImageRef imageRef = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
	texture = [textureCache addCGImage:imageRef forKey:@"cc_fps_images"];
	CGDataProviderRelease(imgDataProvider);
	CGImageRelease(imageRef);

	_FPSLabel = [[CCLabelAtlas alloc]  initWithString:@"00.0" texture:texture itemWidth:12 itemHeight:32 startCharMap:'.'];
	_SPFLabel = [[CCLabelAtlas alloc]  initWithString:@"0.000" texture:texture itemWidth:12 itemHeight:32 startCharMap:'.'];
	_drawsLabel = [[CCLabelAtlas alloc]  initWithString:@"000" texture:texture itemWidth:12 itemHeight:32 startCharMap:'.'];

	[CCTexture2D setDefaultAlphaPixelFormat:currentFormat];

	[_drawsLabel setPosition: ccpAdd( ccp(0,34), CC_DIRECTOR_STATS_POSITION ) ];
	[_SPFLabel setPosition: ccpAdd( ccp(0,17), CC_DIRECTOR_STATS_POSITION ) ];
	[_FPSLabel setPosition: CC_DIRECTOR_STATS_POSITION ];
}

@end

