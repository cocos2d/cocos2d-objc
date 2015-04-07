/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
 *
 * Copyright (c) 2010 Ricardo Quesada
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

// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import "ccMacros.h"
#if __CC_PLATFORM_MAC

#import "CCDirectorMac.h"
#import "CCDirector_Private.h"

#import "CCRenderDispatch.h"
#import "ccFPSImages.h"


@implementation CCDirectorMac {
	CVDisplayLinkRef _displayLink;
    dispatch_semaphore_t _semaphore;
    
    // Should only be accessed from the displaylink thread.
    NSUInteger _frameCount;
}

-(instancetype)initWithView:(CCViewMacGL<CCView> *)view
{
    if((self = [super initWithView:view])){
        _semaphore = dispatch_semaphore_create(1);
    }
    
    return self;
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CCDirectorMac *director = (__bridge CCDirectorMac *)displayLinkContext;
    NSUInteger skip = MAX(1, director.frameSkipInterval);
    if(director->_frameCount++ % skip != 0) return kCVReturnSuccess;
    
    dispatch_semaphore_t semaphore = director->_semaphore;
    
    if(!dispatch_semaphore_wait(semaphore, 0)){
        dispatch_async(dispatch_get_main_queue(), ^{
            [director mainLoopBody];
            dispatch_semaphore_signal(semaphore);
        });
    }
    
    return kCVReturnSuccess;
}

- (void) startRunLoop
{
	[super startRunLoop];
    if(_animating) return;
    
    _lastUpdate = CACurrentMediaTime();

	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);

	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(_displayLink, &MyDisplayLinkCallback, (__bridge void *)(self));

	// Set the display link for the current renderer
	CCViewMacGL *openGLview = (CCViewMacGL *) self.view;
	CGLContextObj cglContext = [[openGLview openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[openGLview pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);

	// Activate the display link
	CVDisplayLinkStart(_displayLink);
    
    _animating = YES;
}

- (void) stopRunLoop
{
    if(!_animating) return;

	CCLOG(@"cocos2d: stopAnimation");

	if(_displayLink){
		CVDisplayLinkStop(_displayLink);
		CVDisplayLinkRelease(_displayLink);
		_displayLink = NULL;
	}
    
    _animating = NO;
}

-(void) dealloc
{
	if(_displayLink){
		CVDisplayLinkStop(_displayLink);
		CVDisplayLinkRelease(_displayLink);
	}
}

-(CGPoint)convertEventToGL:(NSEvent *)event
{
	NSPoint point = [[self view] convertPoint:[event locationInWindow] fromView:nil];
	return  [self convertToGL:NSPointToCGPoint(point)];
}

-(CGFloat)flipY
{
	return 1.0;
}

#pragma mark helper

-(void)getFPSImageData:(unsigned char**)datapointer length:(NSUInteger*)len contentScale:(CGFloat *)scale
{
    *datapointer = cc_fps_images_hd_png;
    *len = cc_fps_images_hd_len();
    *scale = 2;
}

@end
#endif
