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
#import "CCLabelBMFont.h"
#import "ccMacros.h"
#import "CCScene.h"
#import "CCSpriteFrameCache.h"
#import "CCTexture.h"
#import "CCLabelBMFont.h"
#import "ccFPSImages.h"
#import "CCConfiguration.h"
#import "CCTransition.h"
#import "CCRenderer_Private.h"
#import "CCRenderDispatch_Private.h"

// support imports
#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"

#import "Support/CGPointExtension.h"
#import "Support/CCProfiling.h"
#import "Support/CCFileUtils.h"

#if __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#define CC_DIRECTOR_DEFAULT CCDirectorDisplayLink
#elif __CC_PLATFORM_MAC
#import "Platforms/Mac/CCDirectorMac.h"
#define CC_DIRECTOR_DEFAULT CCDirectorDisplayLink
#elif __CC_PLATFORM_ANDROID
#import "Platforms/Android/CCDirectorAndroid.h"
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

@implementation CCDirector {
	CCFrameBufferObject *_framebuffer;
}

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
@synthesize actionManagerFixed = _actionManagerFixed;

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
		_actionManagerFixed = [[CCFixedActionManager alloc] init];
		
		[_scheduler scheduleTarget:_actionManager];
		[_scheduler scheduleTarget:_actionManagerFixed];

		[_scheduler setPaused:NO target:_actionManager];
		[_scheduler setPaused:NO target:_actionManagerFixed];
		
		
		// touch manager
		_responderManager = [ CCResponderManager responderManager ];
		
		_winSizeInPixels = _winSizeInPoints = CGSizeZero;
		
		__ccContentScaleFactor = 1;
		self.UIScaleFactor = 1;
		
		_rendererPool = [NSMutableArray array];
		_globalShaderUniforms = [NSMutableDictionary dictionary];
		
		// Force the graphics API to be selected if it hasn't already done so.
		// Startup code is annoyingly different for iOS/Mac/Android.
		[[CCConfiguration sharedConfiguration] graphicsAPI];
		_framebuffer = [[CCFrameBufferObjectClass alloc] init];
	}

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Size: %0.f x %0.f, view = %@>", [self class], self, _winSizeInPoints.width, _winSizeInPoints.height, self.view];
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);


	_sharedDirector = nil;

}

- (void) drawScene
{	
    /* calculate "global" dt */
	[self calculateDeltaTime];

	/* tick before glClear: issue #533 */
	if( ! _isPaused ) [_scheduler update: _dt];

	/* to avoid flickr, nextScene MUST be here: after tick and before draw.
	 XXX: Which bug is this one. It seems that it can't be reproduced with v0.9 */
	if( _nextScene ) [self setNextScene];
	
	CC_VIEW<CCDirectorView> *ccview = self.view;
	[ccview beginFrame];
	
	if(CCRenderDispatchBeginFrame()){
		GLKMatrix4 projection = self.projectionMatrix;
		
		// Synchronize the framebuffer with the view.
		[_framebuffer syncWithView:self.view];
		
		CCRenderer *renderer = [self rendererFromPool];
		[renderer prepareWithProjection:&projection framebuffer:_framebuffer];
		[CCRenderer bindRenderer:renderer];
		
		[renderer enqueueClear:(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) color:_runningScene.colorRGBA.glkVector4 depth:1.0f stencil:0 globalSortOrder:NSIntegerMin];
		
		// Render
		[_runningScene visit:renderer parentTransform:&projection];
		[_notificationNode visit:renderer parentTransform:&projection];
		if( _displayStats ) [self showStats];
		
		[CCRenderer bindRenderer:nil];
		
		CCRenderDispatchCommitFrame(renderer.threadsafe, ^{
			[ccview addFrameCompletionHandler:^{
				// Return the renderer to the pool when the frame completes.
				[self poolRenderer:renderer];
			}];
			
			[renderer flush];
			[ccview presentFrame];
		});
		
		_totalFrames++;
		
		if( _displayStats ) [self calculateMPF];
	}
}

-(CCRenderer *)rendererFromPool
{
	@synchronized(_rendererPool){
		if(_rendererPool.count > 0){
			CCRenderer *renderer = _rendererPool.lastObject;
			[_rendererPool removeLastObject];
			
			return renderer;
		}
	}
	
	// Allocate and return a new renderer.
	return [[CCRenderer alloc] init];
}

-(void)poolRenderer:(CCRenderer *)renderer
{
	@synchronized(_rendererPool){
		[_rendererPool addObject:renderer];
	}
}

-(void)addFrameCompletionHandler:(dispatch_block_t)handler
{
	[self.view addFrameCompletionHandler:handler];
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

#if DEBUG
	// If we are debugging our code, prevent big delta time
	if( _dt > 0.2f )
		_dt = 1/60.0f;
#endif

	_lastUpdate = now;
}

#pragma mark Director - Memory Helper

-(void) purgeCachedData
{
    if([_delegate respondsToSelector:@selector(purgeCachedData)])
    {
        [_delegate purgeCachedData];
    }
    
	[CCRenderState flushCache];
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

#pragma mark Director Integration with a UIKit view

-(void) setView:(CC_VIEW<CCDirectorView> *)view
{
#if __CC_PLATFORM_IOS
		[super setView:view];
#else 
		_view = view;
#endif

		// set size
		CGSize size = CCNSSizeToCGSize(self.view.bounds.size);
#if __CC_PLATFORM_IOS
		CGFloat scale = self.view.layer.contentsScale ?: 1.0;
#elif __CC_PLATFORM_ANDROID
        CGFloat scale = _view.contentScaleFactor;
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
			[self setProjection: _projection];
		}

		// Dump info once OpenGL was initilized
		[[CCConfiguration sharedConfiguration] dumpInfo];
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

-(CGFloat)flipY
{
	return -1.0;
}

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	GLKMatrix4 transform = self.projectionMatrix;
	GLKMatrix4 invTransform = GLKMatrix4Invert(transform, NULL);
	
	// Calculate z=0 using -> transform*[0, 0, 0, 1]/w
	float zClip = transform.m[14]/transform.m[15];
	
	CGSize glSize = self.view.bounds.size;
	GLKVector3 clipCoord = GLKVector3Make(2.0*uiPoint.x/glSize.width - 1.0, 2.0*uiPoint.y/glSize.height - 1.0, zClip);
	
	clipCoord.y *= self.flipY;
	
	GLKVector3 glCoord = GLKMatrix4MultiplyAndProjectVector3(invTransform, clipCoord);
	return ccp(glCoord.x, glCoord.y);
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	GLKMatrix4 transform = self.projectionMatrix;
		
	GLKVector3 clipCoord = GLKMatrix4MultiplyAndProjectVector3(transform, GLKVector3Make(glPoint.x, glPoint.y, 0.0));
	
	CGSize glSize = self.view.bounds.size;
	return ccp(glSize.width*(clipCoord.v[0]*0.5 + 0.5), glSize.height*(self.flipY*clipCoord.v[1]*0.5 + 0.5));
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
	GLKMatrix4 projection = self.projectionMatrix;
	
	// TODO It's _possible_ that a user will use a non-axis aligned projection. Weird, but possible.
	GLKMatrix4 projectionInv = GLKMatrix4Invert(projection, NULL);
	
	// Calculate z=0 using -> transform*[0, 0, 0, 1]/w
	float zClip = projection.m[14]/projection.m[15];
	
	// Bottom left and top right coords of viewport in clip coords.
	GLKVector3 clipBL = GLKVector3Make(-1.0, -1.0, zClip);
	GLKVector3 clipTR = GLKVector3Make( 1.0,  1.0, zClip);
	
	// Bottom left and top right coords in GL coords.
	GLKVector3 glBL = GLKMatrix4MultiplyAndProjectVector3(projectionInv, clipBL);
	GLKVector3 glTR = GLKMatrix4MultiplyAndProjectVector3(projectionInv, clipTR);
	
	return CGRectMake(glBL.x, glBL.y, glTR.x - glBL.x, glTR.y - glBL.y);
}

-(CGSize)designSize
{
	// Return the viewSize unless designSize has been set.
	return (CGSizeEqualToSize(_designSize, CGSizeZero) ? self.viewSize : _designSize);
}

-(void) reshapeProjection:(CGSize)newViewSize
{
	_winSizeInPixels = newViewSize;
	_winSizeInPoints = CGSizeMake( _winSizeInPixels.width / __ccContentScaleFactor, _winSizeInPixels.height / __ccContentScaleFactor );
	
	[self setProjection:_projection];
	
	[_runningScene viewDidResizeTo: _winSizeInPoints];
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
    [transition startTransition:scene];
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
        [transition startTransition:incomingScene];
    }
}

-(void) popToRootScene
{
	[self popToSceneStackLevel:1];
}

-(void) popToRootSceneWithTransition:(CCTransition *)transition {
	[self popToRootScene];
	_sendCleanupToScene = YES;
    [transition startTransition:_nextScene];
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
    [transition startTransition:scene];
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
    if([_delegate respondsToSelector:@selector(end)])
    {
        [_delegate end];
    }
    
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
	[[CCFileUtils sharedFileUtils] purgeCachedEntries];

	// OpenGL view

	// Since the director doesn't attach the openglview to the window
	// it shouldn't remove it from the window too.
//	[openGLView_ removeFromSuperview];
	
	CC_CHECK_GL_ERROR_DEBUG();
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

    if([_delegate respondsToSelector:@selector(pause)])
    {
        [_delegate pause];
    }
    
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
    
    if([_delegate respondsToSelector:@selector(resume)])
    {
        [_delegate resume];
    }
    
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
    if([_delegate respondsToSelector:@selector(startAnimation)])
    {
        [_delegate startAnimation];
    }
    
	_nextDeltaTimeZero = YES;
}

- (void)stopAnimation
{
	CCLOG(@"cocos2d: Director#stopAnimation. Override me");
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	//CCLOG(@"cocos2d: Director#setAnimationInterval. Override me");
}

- (CCTime)fixedUpdateInterval
{
	return self.scheduler.fixedUpdateInterval;
}

-(void)setFixedUpdateInterval:(CCTime)fixedUpdateInterval
{
	self.scheduler.fixedUpdateInterval = fixedUpdateInterval;
}

@end


@interface CCFPSLabel : CCNode<CCTextureProtocol>
@property(nonatomic, strong) NSString *string;
@end

static const int CCFPSLabelChars = 12;
static const float CCFPSLabelItemWidth = 12;
static const float CCFPSLabelItemHeight = 32;

@implementation CCFPSLabel {
	CCSpriteVertexes _charVertexes[CCFPSLabelChars];
}

-(instancetype)initWithString:(NSString *)string texture:(CCTexture *)texture
{
	if((self = [super init])){
		_string = string;
		
		self.texture = texture;
		self.shader = [CCShader positionTextureColorShader];
		
		float w = CCFPSLabelItemWidth;
		float h = CCFPSLabelItemHeight;
		
		float tx = CCFPSLabelItemWidth/texture.contentSize.width;
		float ty = CCFPSLabelItemHeight/texture.contentSize.height;
		
		for(int i=0; i<CCFPSLabelChars; i++){
			float tx0 = i*tx;
			float tx1 = (i + 1)*tx;
			_charVertexes[i].bl = (CCVertex){GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f), GLKVector2Make(tx0, 0.0f), GLKVector2Make(0.0f, 0.0f), GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)};
			_charVertexes[i].br = (CCVertex){GLKVector4Make(   w, 0.0f, 0.0f, 1.0f), GLKVector2Make(tx1, 0.0f), GLKVector2Make(0.0f, 0.0f), GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)};
			_charVertexes[i].tr = (CCVertex){GLKVector4Make(   w,    h, 0.0f, 1.0f), GLKVector2Make(tx1,   ty), GLKVector2Make(0.0f, 0.0f), GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)};
			_charVertexes[i].tl = (CCVertex){GLKVector4Make(0.0f,    h, 0.0f, 1.0f), GLKVector2Make(tx0,   ty), GLKVector2Make(0.0f, 0.0f), GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f)};
		}
	}
	
	return self;
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	for(int i=0; i<_string.length; i++){
		int c = [_string characterAtIndex:i];
		
		// Skip spaces.
		if(c == ' ') continue;
		
		// Index relative to '.'.
		c = MAX(0, MIN(CCFPSLabelChars - 1, c - '.'));
		GLKMatrix4 t = GLKMatrix4Multiply(*transform, GLKMatrix4MakeTranslation(i*CCFPSLabelItemWidth, 0.0f, 0.0f));
		
		CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:self.renderState globalSortOrder:NSIntegerMax];
		CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(_charVertexes[c].bl, &t));
		CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(_charVertexes[c].br, &t));
		CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(_charVertexes[c].tr, &t));
		CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(_charVertexes[c].tl, &t));
		CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
		CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
	}
}

@end


@implementation CCDirector(Stats)

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
			
			// Subtract one for the stat label's own batch. This caused a lot of confusion on the forums...
			NSString *draws = [[NSString alloc] initWithFormat:@"%4lu", (unsigned long)__ccNumberOfDraws - 1];
			[_drawsLabel setString:draws];
		}
		
		// TODO should pass as a parameter instead? Requires changing method signatures...
		CCRenderer *renderer = [CCRenderer currentRenderer];
		[_drawsLabel visit:renderer parentTransform:&_projectionMatrix];
		[_FPSLabel visit:renderer parentTransform:&_projectionMatrix];
		[_SPFLabel visit:renderer parentTransform:&_projectionMatrix];
	}
	
	__ccNumberOfDraws = 0;
}

-(void) calculateMPF
{
	struct timeval now;
	gettimeofday( &now, NULL);

	_secondsPerFrame = (now.tv_sec - _lastUpdate.tv_sec) + (now.tv_usec - _lastUpdate.tv_usec) / 1000000.0f;
}

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

	_FPSLabel = [[CCFPSLabel alloc]  initWithString:@"00.0" texture:texture];
	_SPFLabel = [[CCFPSLabel alloc]  initWithString:@"0.000" texture:texture];
	_drawsLabel = [[CCFPSLabel alloc]  initWithString:@"000" texture:texture];

	[CCTexture setDefaultAlphaPixelFormat:currentFormat];
	
	CGPoint offset = [self convertToGL:ccp(0, (self.flipY == 1.0) ? 0 : self.view.bounds.size.height)];
	CGPoint pos = ccpAdd(CC_DIRECTOR_STATS_POSITION, offset);
	[_drawsLabel setPosition: ccpAdd( ccp(0,34), pos ) ];
	[_SPFLabel setPosition: ccpAdd( ccp(0,17), pos ) ];
	[_FPSLabel setPosition: pos ];
}

@end
