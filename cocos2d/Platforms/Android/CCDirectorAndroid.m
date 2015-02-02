//
//  CCDirectorAndroid.m
//  cocos2d-ios
//
//  Created by Oleg Osin on 5/22/14.
//
//

#import "CCDirectorAndroid.h"

#if __CC_PLATFORM_ANDROID

#import "CCDirector_Private.h"

#import "../../CCScheduler.h"
#import "../../CCTextureCache.h"
#import "../../ccMacros.h"
#import "../../CCScene.h"
#import "../../CCShader.h"
#import "../../ccFPSImages.h"
#import "../../CCDeviceInfo.h"
#import "CCRenderer_Private.h"
#import "CCTouch.h"

#import "ccUtils.h"
#import "CCActivity.h"



#pragma mark -
#pragma mark Director

@interface CCDirector ()
-(void) setNextScene;
-(void) showStats;
-(void) calculateDeltaTime;
-(void) calculateMPF;
@end



#pragma mark -
#pragma mark CCDirectorAndroid

@implementation CCDirectorAndroid

-(void) setViewport
{
	CGSize size = _winSizeInPixels;
	glViewport(0, 0, size.width, size.height );
}

-(void) setProjection:(CCDirectorProjection)projection
{
	CGSize sizePoint = _winSizeInPoints;
        
	switch (projection) {
		case CCDirectorProjection2D:
			_projectionMatrix = GLKMatrix4MakeOrtho(0, sizePoint.width, 0, sizePoint.height, -1024, 1024 );
			break;
            
		case CCDirectorProjection3D: {
			float zeye = sizePoint.height*sqrtf(3.0f)/2.0f;
			_projectionMatrix = GLKMatrix4Multiply(
                                                   GLKMatrix4MakePerspective(CC_DEGREES_TO_RADIANS(60), (float)sizePoint.width/sizePoint.height, 0.1f, zeye*2),
                                                   GLKMatrix4MakeTranslation(-sizePoint.width/2.0, -sizePoint.height/2, -zeye)
                                                   );
            break;
        }
            
        case CCDirectorProjectionCustom:
			if( [_delegate respondsToSelector:@selector(updateProjection)] )
				_projectionMatrix = [_delegate updateProjection];
			break;
            
		default:
			CCLOG(@"cocos2d: Director: unrecognized projection");
			break;
	}
    
	_projection = projection;
}


// override default logic
- (void)antiFlickrDrawCall
{
//    NSThread *thread = [self runningThread];
//    [self performSelector:@selector(mainLoopBody) onThread:thread withObject:nil waitUntilDone:YES];
}

-(void)end
{
	[super end];
}

-(void) setView:(CCGLView *)view
{
		[super setView:view];
		if( view ) {
			// set size
			CGFloat scale = view.contentScaleFactor;
			CGSize size = view.bounds.size;
			_winSizeInPixels = CGSizeMake(size.width * scale, size.height * scale);
		}
}

- (void)runBlock:(dispatch_block_t)block
{
    [[CCActivity currentActivity] runOnGameThread:block];
}

// Unlike iOS, GL isn't initialized on Android before the config is read
// Here we can perform the necessary configuration functions that operate on a GL context
- (void) onGLInitialization
{
    [self setViewport];
    [self createStatsLabel];

	[[CCDeviceInfo sharedDeviceInfo] dumpInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GL_INITIALIZED" object:nil];
}
@end


#pragma mark -
#pragma mark DirectorDisplayLink

@implementation CCDirectorDisplayLink

-(void) mainLoop:(id)sender
{
    EGLContext *ctx = [[CCActivity currentActivity] pushApplicationContext];
    
	[self mainLoopBody];
    
    [[CCActivity currentActivity] popApplicationContext:ctx];
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	_animationInterval = interval;
	if(_displayLink)
    {
		[self stopRunLoop];
		[self startRunLoop];
	}
}

- (void) startRunLoop
{
	[super startRunLoop];
    
    if(_animating)
        return;
    
	gettimeofday( &_lastUpdate, NULL);
    
	// approximate frame rate
	// assumes device refreshes at 60 fps
    
	CCLOG(@"cocos2d: animation started with frame interval: %d", (int)floorf(_animationInterval * 60.0));
    
    _displayLink = [NSTimer scheduledTimerWithTimeInterval:_animationInterval
                                             target:self
                                           selector:@selector(mainLoop:)
                                           userInfo:nil repeats:YES];
    
    _animating = YES;
}

- (void) stopRunLoop
{
    if(!_animating)
        return;
    
    if([_delegate respondsToSelector:@selector(stopRunLoop)])
    {
        [_delegate stopRunLoop];
    }
    
	CCLOG(@"cocos2d: animation stopped");
        
	[_displayLink invalidate];
	_displayLink = nil;
    _animating = NO;
}

// Overriden in order to use a more stable delta time
-(void) calculateDeltaTime
{
    static unsigned long long last = 0;
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    unsigned long long now = t.tv_sec * 1e9 + t.tv_nsec;
    if (now != last)
    {
        if (last != 0)
        {
            _dt = (now - last) / (double)NSEC_PER_SEC;
        }
        last = now;
    }
}


#pragma mark Director Thread

//
// Director has its own thread
//
-(void) threadMainLoop
{
	@autoreleasepool {
        [[NSRunLoop currentRunLoop] addTimer:_displayLink forMode:NSRunLoopCommonModes];
        
		// start the run loop
		[[NSRunLoop currentRunLoop] run];
	}
}

@end

#endif //__CC_PLATFORM_ANDROID

