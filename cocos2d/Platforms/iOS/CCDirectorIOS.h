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


// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import "../../CCDirector.h"

/** @typedef ccDeviceOrientation
 Possible device orientations
 */
typedef enum {
	/// Device oriented vertically, home button on the bottom
	kCCDeviceOrientationPortrait = UIDeviceOrientationPortrait,	
	/// Device oriented vertically, home button on the top
    kCCDeviceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
	/// Device oriented horizontally, home button on the right
    kCCDeviceOrientationLandscapeLeft = UIDeviceOrientationLandscapeLeft,
	/// Device oriented horizontally, home button on the left
    kCCDeviceOrientationLandscapeRight = UIDeviceOrientationLandscapeRight,
	
	// Backward compatibility stuff
	CCDeviceOrientationPortrait = kCCDeviceOrientationPortrait,
	CCDeviceOrientationPortraitUpsideDown = kCCDeviceOrientationPortraitUpsideDown,
	CCDeviceOrientationLandscapeLeft = kCCDeviceOrientationLandscapeLeft,
	CCDeviceOrientationLandscapeRight = kCCDeviceOrientationLandscapeRight,
} ccDeviceOrientation;

/** @typedef tPixelFormat
 Possible Pixel Formats for the OpenGL View.
 
 @deprecated Will be removed in v1.0
 */
typedef enum {
	/** RGB565 pixel format. No alpha. 16-bit. (Default) */
	kCCPixelFormatRGB565,
	/** RGBA format. 32-bit. Needed for some 3D effects. It is not as fast as the RGB565 format. */
	kCCPixelFormatRGBA8888,
	/** default pixel format */
	kCCPixelFormatDefault = kCCPixelFormatRGB565,
	
	// backward compatibility stuff
	kPixelFormatRGB565 = kCCPixelFormatRGB565,
	kRGB565 = kCCPixelFormatRGB565,
	kPixelFormatRGBA8888 = kCCPixelFormatRGBA8888,
	kRGBA8 = kCCPixelFormatRGBA8888,
} tPixelFormat;

/** @typedef tDepthBufferFormat
 Possible DepthBuffer Formats for the OpenGLView.
 Use 16 or 24 bit depth buffers if you are going to use real 3D objects.
 
 @deprecated Will be removed in v1.0
 */
typedef enum {
	/// A Depth Buffer of 0 bits will be used (default)
	kCCDepthBufferNone,
	/// A depth buffer of 16 bits will be used
	kCCDepthBuffer16,
	/// A depth buffer of 24 bits will be used
	kCCDepthBuffer24,
	
	// backward compatibility stuff
	kDepthBuffer16 = kCCDepthBuffer16,
	kDepthBuffer24 = kCCDepthBuffer24,
} tDepthBufferFormat;

/** @typedef ccDirectorType
 Possible Director Types.
 @since v0.8.2
 */
typedef enum {
	/** Will use a Director that triggers the main loop from an NSTimer object
	 *
	 * Features and Limitations:
	 * - Integrates OK with UIKit objects
	 * - It the slowest director
	 * - The invertal update is customizable from 1 to 60
	 */
	kCCDirectorTypeNSTimer,
	
	/** will use a Director that triggers the main loop from a custom main loop.
	 *
	 * Features and Limitations:
	 * - Faster than NSTimer Director
	 * - It doesn't integrate well with UIKit objecgts
	 * - The interval update can't be customizable
	 */
	kCCDirectorTypeMainLoop,
	
	/** Will use a Director that triggers the main loop from a thread, but the main loop will be executed on the main thread.
	 *
	 * Features and Limitations:
	 * - Faster than NSTimer Director
	 * - It doesn't integrate well with UIKit objecgts
	 * - The interval update can't be customizable
	 */
	kCCDirectorTypeThreadMainLoop,
	
	/** Will use a Director that synchronizes timers with the refresh rate of the display.
	 *
	 * Features and Limitations:
	 * - Faster than NSTimer Director
	 * - Only available on 3.1+
	 * - Scheduled timers & drawing are synchronizes with the refresh rate of the display
	 * - Integrates OK with UIKit objects
	 * - The interval update can be 1/60, 1/30, 1/15
	 */	
	kCCDirectorTypeDisplayLink,
	
	/** Default director is the NSTimer directory */
	kCCDirectorTypeDefault = kCCDirectorTypeNSTimer,
	
	// backward compatibility stuff
	CCDirectorTypeNSTimer = kCCDirectorTypeNSTimer,
	CCDirectorTypeMainLoop = kCCDirectorTypeMainLoop,
	CCDirectorTypeThreadMainLoop = kCCDirectorTypeThreadMainLoop,
	CCDirectorTypeDisplayLink = kCCDirectorTypeDisplayLink,
	CCDirectorTypeDefault = kCCDirectorTypeDefault,
	
	
} ccDirectorType;

/** CCDirector extensions for iPhone
 */
@interface CCDirector (iOSExtension)

// rotates the screen if an orientation differnent than Portrait is used
-(void) applyOrientation;

/** Sets the device orientation.
 If the orientation is going to be controlled by an UIViewController, then the orientation should be Portrait
 */
-(void) setDeviceOrientation:(ccDeviceOrientation)orientation;

/** returns the device orientation */
-(ccDeviceOrientation) deviceOrientation;

/** The size in pixels of the surface. It could be different than the screen size.
 High-res devices might have a higher surface size than the screen size.
 In non High-res device the contentScale will be emulated.

 The recommend way to enable Retina Display is by using the "enableRetinaDisplay:(BOOL)enabled" method.

 @since v0.99.4
 */
-(void) setContentScaleFactor:(CGFloat)scaleFactor;

/** Will enable Retina Display on devices that supports it.
 It will enable Retina Display on iPhone4 and iPod Touch 4.
 It will return YES, if it could enabled it, otherwise it will return NO.
 
 This is the recommened way to enable Retina Display.
 @since v0.99.5
 */
-(BOOL) enableRetinaDisplay:(BOOL)yes;


/** returns the content scale factor */
-(CGFloat) contentScaleFactor;
@end

@interface CCDirector (iOSExtensionClassMethods)

/** There are 4 types of Director.
 - kCCDirectorTypeNSTimer (default)
 - kCCDirectorTypeMainLoop
 - kCCDirectorTypeThreadMainLoop
 - kCCDirectorTypeDisplayLink
 
 Each Director has it's own benefits, limitations.
 If you are using SDK 3.1 or newer it is recommed to use the DisplayLink director
 
 This method should be called before any other call to the director.
 
 It will return NO if the director type is kCCDirectorTypeDisplayLink and the running SDK is < 3.1. Otherwise it will return YES.
 
 @since v0.8.2
 */
+(BOOL) setDirectorType:(ccDirectorType) directorType;
@end

#pragma mark -
#pragma mark CCDirectorIOS

/** CCDirectorIOS: Base class of iOS directors
 @since v0.99.5
 */
@interface CCDirectorIOS : CCDirector
{
	/* orientation */
	ccDeviceOrientation	deviceOrientation_;
	
	/* contentScaleFactor could be simulated */
	BOOL	isContentScaleSupported_;
	
	tPixelFormat pixelFormat_;					// Deprecated. Will be removed in 1.0
	tDepthBufferFormat depthBufferFormat_;		// Deprecated. Will be removed in 1.0
}

// iPhone Specific

/** Pixel format used to create the context */
@property (nonatomic,readonly) tPixelFormat pixelFormat DEPRECATED_ATTRIBUTE;

/** Uses a new pixel format for the EAGLView.
 Call this class method before attaching it to a UIView
 Default pixel format: kRGB565. Supported pixel formats: kRGBA8 and kRGB565
 
 @deprecated Set the pixel format when creating the EAGLView. This method will be removed in v1.0
 */
-(void) setPixelFormat: (tPixelFormat)p DEPRECATED_ATTRIBUTE;

/** Change depth buffer format of the render buffer.
 Call this class method before attaching it to a UIWindow/UIView
 Default depth buffer: 0 (none).  Supported: kCCDepthBufferNone, kCCDepthBuffer16, and kCCDepthBuffer24
 
 @deprecated Set the depth buffer format when creating the EAGLView. This method will be removed in v1.0
 */
-(void) setDepthBufferFormat: (tDepthBufferFormat)db DEPRECATED_ATTRIBUTE;

// Integration with UIKit
/** detach the cocos2d view from the view/window */
-(BOOL)detach DEPRECATED_ATTRIBUTE;

/** attach in UIWindow using the full frame.
 It will create a EAGLView.
 
 @deprecated set setOpenGLView instead. Will be removed in v1.0
 */
-(BOOL)attachInWindow:(UIWindow *)window DEPRECATED_ATTRIBUTE;

/** attach in UIView using the full frame.
 It will create a EAGLView.
 
 @deprecated set setOpenGLView instead. Will be removed in v1.0
 */
-(BOOL)attachInView:(UIView *)view DEPRECATED_ATTRIBUTE;

/** attach in UIView using the given frame.
 It will create a EAGLView and use it.
 
 @deprecated set setOpenGLView instead. Will be removed in v1.0
 */
-(BOOL)attachInView:(UIView *)view withFrame:(CGRect)frame DEPRECATED_ATTRIBUTE;

@end

/** FastDirector is a Director that triggers the main loop as fast as possible.
 *
 * Features and Limitations:
 *  - Faster than "normal" director
 *  - Consumes more battery than the "normal" director
 *  - It has some issues while using UIKit objects
 */
@interface CCDirectorFast : CCDirectorIOS
{
	BOOL isRunning;
	
	NSAutoreleasePool	*autoreleasePool;
}
-(void) mainLoop;
@end

/** ThreadedFastDirector is a Director that triggers the main loop from a thread.
 *
 * Features and Limitations:
 *  - Faster than "normal" director
 *  - Consumes more battery than the "normal" director
 *  - It can be used with UIKit objects
 *
 * @since v0.8.2
 */
@interface CCDirectorFastThreaded : CCDirectorIOS
{
	BOOL isRunning;	
}
-(void) mainLoop;
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
@interface CCDirectorDisplayLink : CCDirectorIOS
{
	id displayLink;
}
-(void) mainLoop:(id)sender;
@end

/** TimerDirector is a Director that calls the main loop from an NSTimer object
 *
 * Features and Limitations:
 * - Integrates OK with UIKit objects
 * - It the slowest director
 * - The invertal update is customizable from 1 to 60
 *
 * It is the default Director.
 */
@interface CCDirectorTimer : CCDirectorIOS
{
	NSTimer *animationTimer;
}
-(void) mainLoop;
@end

// optimization. Should only be used to read it. Never to write it.
extern CGFloat	__ccContentScaleFactor;

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
