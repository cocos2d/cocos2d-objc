/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
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


// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import "../../ccMacros.h"
#ifdef __CC_PLATFORM_MAC

#import <QuartzCore/CVDisplayLink.h>
#import "../../CCDirector.h"

@class CCEventDispatcher;

enum  {
	/// If the window is resized, it won't be autoscaled
	kCCDirectorResize_NoScale,
	/// If the window is resized, it will be autoscaled (default behavior)
	kCCDirectorResize_AutoScale,
};

@interface CCDirector (MacExtension)
/** sets the CCEventDispatcher (Mac only) */
@property (nonatomic, readwrite, retain) CCEventDispatcher* eventDispatcher;

/** converts an NSEvent to GL coordinates (Mac only) */
-(CGPoint) convertEventToGL:(NSEvent*)event;
@end

/** Base class of Mac directors
 @since v0.99.5
 */
@interface CCDirectorMac : CCDirector
{
	BOOL			_isFullScreen;
	int				_resizeMode;
	CGPoint			_winOffset;
    CGSize			_originalWinSize;

	NSWindow		*_fullScreenWindow;

	// Event Dispatcher
	CCEventDispatcher	*_eventDispatcher;

	// cache
	NSWindow		*_windowGLView;
    NSView          *_superViewGLView;
    NSRect          _originalWinRect; // Original size and position
}

// whether or not the view is in fullscreen mode
@property (nonatomic, readonly) BOOL isFullScreen;

// resize mode: with or without scaling
@property (nonatomic, readwrite) int resizeMode;

@property (nonatomic, readwrite) CGSize originalWinSize;

/** Sets the view in fullscreen or window mode */
- (void) setFullScreen:(BOOL)fullscreen;

/** Converts window size coordinates to logical coordinates.
 Useful only if resizeMode is kCCDirectorResize_Scale.
 If resizeMode is kCCDirectorResize_NoScale, then no conversion will be done.
*/
- (CGPoint) convertToLogicalCoordinates:(CGPoint)coordinates;
@end


/** DisplayLinkDirector is a Director that synchronizes timers with the refresh rate of the display.
 *
 * Features and Limitations:
 * - Only available on 3.1+
 * - Scheduled timers & drawing are synchronizes with the refresh rate of the display
 * - Only supports animation intervals of 1/60 1/30 & 1/15
 *
 * It is the recommended Director if the SDK is 3.1 or newer
 *
 * @since v0.8.2
 */
@interface CCDirectorDisplayLink : CCDirectorMac
{
	CVDisplayLinkRef displayLink;
}
@end

#endif // __CC_PLATFORM_MAC

