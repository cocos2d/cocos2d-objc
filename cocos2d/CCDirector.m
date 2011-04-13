/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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
#import <Availability.h>

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

// support imports
#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"

#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "Platforms/iOS/CCDirectorIOS.h"
#define CC_DIRECTOR_DEFAULT CCDirectorTimer
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import "Platforms/Mac/CCDirectorMac.h"
#define CC_DIRECTOR_DEFAULT CCDirectorDisplayLink
#endif

#import "Support/CCProfiling.h"

#define kDefaultFPS		60.0	// 60 frames per second

extern NSString * cocos2dVersion(void);


@interface CCDirector (Private)
-(void) setNextScene;
// shows the FPS in the screen
-(void) showFPS;
// calculates delta time since last time it was called
-(void) calculateDeltaTime;
@end

@implementation CCDirector

@synthesize animationInterval = animationInterval_;
@synthesize runningScene = runningScene_;
@synthesize displayFPS = displayFPS_;
@synthesize nextDeltaTimeZero = nextDeltaTimeZero_;
@synthesize isPaused = isPaused_;
@synthesize sendCleanupToScene = sendCleanupToScene_;
@synthesize runningThread = runningThread_;
@synthesize notificationNode = notificationNode_;
@synthesize projectionDelegate = projectionDelegate_;
//
// singleton stuff
//
static CCDirector *_sharedDirector = nil;

+ (CCDirector *)sharedDirector
{
	if (!_sharedDirector) {

		//
		// Default Director is TimerDirector
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
	CCLOG(@"cocos2d: %@", cocos2dVersion() );

	if( (self=[super init]) ) {

		CCLOG(@"cocos2d: Using Director Type:%@", [self class]);
		
		// scenes
		runningScene_ = nil;
		nextScene_ = nil;
		
		notificationNode_ = nil;
		
		oldAnimationInterval_ = animationInterval_ = 1.0 / kDefaultFPS;
		scenesStack_ = [[NSMutableArray alloc] initWithCapacity:10];
		
		// Set default projection (3D)
		projection_ = kCCDirectorProjectionDefault;

		// projection delegate if "Custom" projection is used
		projectionDelegate_ = nil;

		// FPS
		displayFPS_ = NO;
		frames_ = 0;
		
		// paused ?
		isPaused_ = NO;
		
		// running thread
		runningThread_ = nil;
		
		winSizeInPixels_ = winSizeInPoints_ = CGSizeZero;
	}

	return self;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

#if CC_DIRECTOR_FAST_FPS
	[FPSLabel_ release];
#endif
	[runningScene_ release];
	[notificationNode_ release];
	[scenesStack_ release];
	
	[projectionDelegate_ release];
	
	_sharedDirector = nil;
	
	[super dealloc];
}

-(void) setGLDefaultValues
{
	// This method SHOULD be called only after openGLView_ was initialized
	NSAssert( openGLView_, @"openGLView_ must be initialized");

	[self setAlphaBlending: YES];
	[self setDepthTest: YES];
	[self setProjection: projection_];
	
	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
#if CC_DIRECTOR_FAST_FPS
    if (!FPSLabel_) {
		CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
		FPSLabel_ = [[CCLabelAtlas labelWithString:@"00.0" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'] retain];
		[CCTexture2D setDefaultAlphaPixelFormat:currentFormat];		
	}
#endif	// CC_DIRECTOR_FAST_FPS
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
		dt = 0;
		return;
	}
	
	// new delta time
	if( nextDeltaTimeZero_ ) {
		dt = 0;
		nextDeltaTimeZero_ = NO;
	} else {
		dt = (now.tv_sec - lastUpdate_.tv_sec) + (now.tv_usec - lastUpdate_.tv_usec) / 1000000.0f;
		dt = MAX(0,dt);
	}

#ifdef DEBUG
	// If we are debugging our code, prevent big delta time
	if( dt > 0.2f )
		dt = 1/60.0f;
#endif
	
	lastUpdate_ = now;	
}

#pragma mark Director - Memory Helper

-(void) purgeCachedData
{
	[CCLabelBMFont purgeCachedData];	
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];	
}

#pragma mark Director - Scene OpenGL Helper

-(ccDirectorProjection) projection
{
	return projection_;
}

-(float) getZEye
{
	return ( winSizeInPixels_.height / 1.1566f );
}

-(void) setProjection:(ccDirectorProjection)projection
{
	CCLOG(@"cocos2d: override me");
}

- (void) setAlphaBlending: (BOOL) on
{
	if (on) {
		glEnable(GL_BLEND);
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
		
	} else
		glDisable(GL_BLEND);
}

- (void) setDepthTest: (BOOL) on
{
	if (on) {
		ccglClearDepth(1.0f);
		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
//		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	} else
		glDisable( GL_DEPTH_TEST );
}

#pragma mark Director Integration with a UIKit view

-(CC_GLVIEW*) openGLView
{
	return openGLView_;
}

-(void) setOpenGLView:(CC_GLVIEW *)view
{
	NSAssert( view, @"OpenGLView must be non-nil");

	if( view != openGLView_ ) {
		[openGLView_ release];
		openGLView_ = [view retain];
		
		// set size
		winSizeInPixels_ = winSizeInPoints_ = CCNSSizeToCGSize( [view bounds].size );

		[self setGLDefaultValues];
	}
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
	return winSizeInPoints_;
}

-(CGSize)winSizeInPixels
{
	return winSizeInPixels_;
}

-(CGSize)displaySizeInPixels
{
	return winSizeInPixels_;
}

-(void) reshapeProjection:(CGSize)newWindowSize
{
	winSizeInPixels_ = winSizeInPoints_ = newWindowSize;
	[self setProjection:projection_];
}

#pragma mark Director Scene Management

- (void)runWithScene:(CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	NSAssert( runningScene_ == nil, @"You can't run an scene if another Scene is running. Use replaceScene or pushScene instead");
	
	[self pushScene:scene];
	[self startAnimation];	
}

-(void) replaceScene: (CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	NSUInteger index = [scenesStack_ count];
	
	sendCleanupToScene_ = YES;
	[scenesStack_ replaceObjectAtIndex:index-1 withObject:scene];
	nextScene_ = scene;	// nextScene_ is a weak ref
}

- (void) pushScene: (CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	sendCleanupToScene_ = NO;

	[scenesStack_ addObject: scene];
	nextScene_ = scene;	// nextScene_ is a weak ref
}

-(void) popScene
{	
	NSAssert( runningScene_ != nil, @"A running Scene is needed");

	[scenesStack_ removeLastObject];
	NSUInteger c = [scenesStack_ count];
	
	if( c == 0 )
		[self end];
	else {
		sendCleanupToScene_ = YES;
		nextScene_ = [scenesStack_ objectAtIndex:c-1];
	}
}

-(void) end
{
	[runningScene_ onExit];
	[runningScene_ cleanup];
	[runningScene_ release];

	runningScene_ = nil;
	nextScene_ = nil;
	
	// remove all objects, but don't release it.
	// runWithScene might be executed after 'end'.
	[scenesStack_ removeAllObjects];
	
	[self stopAnimation];
	
#if CC_DIRECTOR_FAST_FPS
	[FPSLabel_ release];
	FPSLabel_ = nil;
#endif	

	[projectionDelegate_ release];
	projectionDelegate_ = nil;
	
	// Purge bitmap cache
	[CCLabelBMFont purgeCachedData];

	// Purge all managers
	[CCAnimationCache purgeSharedAnimationCache];
	[CCSpriteFrameCache purgeSharedSpriteFrameCache];
	[CCScheduler purgeSharedScheduler];
	[CCActionManager purgeSharedManager];
	[CCTextureCache purgeSharedTextureCache];
	
	
	// OpenGL view
	
	// Since the director doesn't attach the openglview to the window
	// it shouldn't remove it from the window too.
//	[openGLView_ removeFromSuperview];

	[openGLView_ release];
	openGLView_ = nil;	
}

-(void) setNextScene
{
	Class transClass = [CCTransitionScene class];
	BOOL runningIsTransition = [runningScene_ isKindOfClass:transClass];
	BOOL newIsTransition = [nextScene_ isKindOfClass:transClass];

	// If it is not a transition, call onExit/cleanup
	if( ! newIsTransition ) {
		[runningScene_ onExit];

		// issue #709. the root node (scene) should receive the cleanup message too
		// otherwise it might be leaked.
		if( sendCleanupToScene_)
			[runningScene_ cleanup];
	}

	[runningScene_ release];
	
	runningScene_ = [nextScene_ retain];
	nextScene_ = nil;

	if( ! runningIsTransition ) {
		[runningScene_ onEnter];
		[runningScene_ onEnterTransitionDidFinish];
	}
}

-(void) pause
{
	if( isPaused_ )
		return;

	oldAnimationInterval_ = animationInterval_;
	
	// when paused, don't consume CPU
	[self setAnimationInterval:1/4.0];
	isPaused_ = YES;
}

-(void) resume
{
	if( ! isPaused_ )
		return;
	
	[self setAnimationInterval: oldAnimationInterval_];

	if( gettimeofday( &lastUpdate_, NULL) != 0 ) {
		CCLOG(@"cocos2d: Director: Error in gettimeofday");
	}
	
	isPaused_ = NO;
	dt = 0;
}

- (void)startAnimation
{
	CCLOG(@"cocos2d: Director#startAnimation. Override me");
}

- (void)stopAnimation
{
	CCLOG(@"cocos2d: Director#stopAnimation. Override me");
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	CCLOG(@"cocos2d: Director#setAnimationInterval. Override me");
}

#if CC_DIRECTOR_FAST_FPS

// display the FPS using a LabelAtlas
// updates the FPS every frame
-(void) showFPS
{
	frames_++;
	accumDt_ += dt;
	
	if ( accumDt_ > CC_DIRECTOR_FPS_INTERVAL)  {
		frameRate_ = frames_/accumDt_;
		frames_ = 0;
		accumDt_ = 0;

//		sprintf(format,"%.1f",frameRate);
//		[FPSLabel setCString:format];

		NSString *str = [[NSString alloc] initWithFormat:@"%.1f", frameRate_];
		[FPSLabel_ setString:str];
		[str release];
	}

	[FPSLabel_ draw];
}
#else
// display the FPS using a manually generated Texture (very slow)
// updates the FPS 3 times per second aprox.
-(void) showFPS
{
	frames_++;
	accumDt_ += dt;
	
	if ( accumDt_ > CC_DIRECTOR_FPS_INTERVAL)  {
		frameRate_ = frames_/accumDt_;
		frames_ = 0;
		accumDt_ = 0;
	}
	
	NSString *str = [NSString stringWithFormat:@"%.2f",frameRate_];
	CCTexture2D *texture = [[CCTexture2D alloc] initWithString:str dimensions:CGSizeMake(100,30) alignment:CCTextAlignmentLeft fontName:@"Arial" fontSize:24];

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: GL_COLOR_ARRAY
	glDisableClientState(GL_COLOR_ARRAY);
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glColor4ub(224,224,244,200);
	[texture drawAtPoint: ccp(5,2)];
	[texture release];
	
	glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	// restore default GL state
	glEnableClientState(GL_COLOR_ARRAY);
}
#endif

- (void) showProfilers {
#if CC_ENABLE_PROFILERS
	accumDtForProfiler_ += dt;
	if (accumDtForProfiler_ > 1.0f) {
		accumDtForProfiler_ = 0;
		[[CCProfiler sharedProfiler] displayTimers];
	}
#endif // CC_ENABLE_PROFILERS
}

@end

