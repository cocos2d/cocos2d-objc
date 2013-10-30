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

#import "ccMacros.h"
#import "ccTypes.h"


@class CCTexture;
@class CCDirector;

#pragma mark - CCRGBAProtocol

/// CC RGBA protocol
@protocol CCRGBAProtocol <NSObject>
/** sets and returns the color (tint)
 @since v0.8
 */
@property (nonatomic) ccColor3B color;
/** returns the displayed color */
@property (nonatomic, readonly) ccColor3B displayedColor;
/** whether or not color should be propagated to its children */
@property (nonatomic, getter = isCascadeColorEnabled) BOOL cascadeColorEnabled;

/** recursive method that updates display color */
- (void)updateDisplayedColor:(ccColor3B)color;

/** sets and returns the opacity.
 @warning If the the texture has premultiplied alpha then, the R, G and B channels will be modified.
 Values goes from 0 to 255, where 255 means fully opaque.
 */
@property (nonatomic) GLubyte opacity;
/** returns the displayed opacity */
@property (nonatomic, readonly) GLubyte displayedOpacity;
/** whether or not opacity should be propagated to its children */
@property (nonatomic, getter = isCascadeOpacityEnabled) BOOL cascadeOpacityEnabled;

/** recursive method that updates the displayed opacity */
- (void)updateDisplayedOpacity:(GLubyte)opacity;

@optional
/** sets the premultipliedAlphaOpacity property.
 If set to NO then opacity will be applied as: glColor(R,G,B,opacity);
 If set to YES then opacity will be applied as: glColor(opacity, opacity, opacity, opacity );
 Textures with premultiplied alpha will have this property by default on YES. Otherwise the default value is NO
 @since v0.8
 */
-(void) setOpacityModifyRGB:(BOOL)boolean;
/** returns whether or not the opacity will be applied using glColor(R,G,B,opacity) or glColor(opacity, opacity, opacity, opacity);
 @since v0.8
 */
 -(BOOL) doesOpacityModifyRGB;
@end

#pragma mark - CCBlendProtocol
/**
 You can specify the blending function.
 @since v0.99.0
 */
@protocol CCBlendProtocol <NSObject>
/** set the source blending function for the texture */
-(void) setBlendFunc:(ccBlendFunc)blendFunc;
/** returns the blending function used for the texture */
-(ccBlendFunc) blendFunc;
@end


#pragma mark - CCTextureProtocol

/** CCNode objects that uses a Texture2D to render the images.
 The texture can have a blending function.
 If the texture has alpha premultiplied the default blending function is:
    src=GL_ONE dst= GL_ONE_MINUS_SRC_ALPHA
 else
	src=GL_SRC_ALPHA dst= GL_ONE_MINUS_SRC_ALPHA
 But you can change the blending function at any time.
 @since v0.8.0
 */
@protocol CCTextureProtocol <CCBlendProtocol>
/** returns the used texture */
-(CCTexture*) texture;
/** sets a new texture. it will be retained */
-(void) setTexture:(CCTexture*)texture;
@end

#pragma mark - CCLabelProtocol
/** Common interface for Labels */
@protocol CCLabelProtocol <NSObject>
/** sets a new label using an NSString.
 The string will be copied.
 */
-(void) setString:(NSString*)label;
/** returns the string that is rendered */
-(NSString*) string;
@optional
/** sets a new label using a CString.
 @since v0.99.0
 */
-(void) setCString:(char*)label;
@end


#pragma mark - CCDirectorDelegate
/** CCDirector delegate */
@protocol CCDirectorDelegate <NSObject>

@optional
/** Called by CCDirector when the projection is updated, and "custom" projection is used */
-(void) updateProjection;

#ifdef __CC_PLATFORM_IOS
/** Returns a Boolean value indicating whether the CCDirector supports the specified orientation. Default value is YES (supports all possible orientations) */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

// Commented. See issue #1453 for further info: http://code.google.com/p/cocos2d-iphone/issues/detail?id=1453
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

/** Called when projection is resized (due to layoutSubviews on the view). This is important to respond to in order to setup your scene with the proper dimensions (which only exist after the first call to layoutSubviews) so that you can set your scene as early as possible to avoid startup flicker
 */
-(void) directorDidReshapeProjection:(CCDirector*)director;

#endif // __CC_PLATFORM_IOS

@end


#pragma mark - CCAccelerometerDelegate

#ifdef __CC_PLATFORM_IOS
/** CCAccelerometerDelegate delegate */
@class UIAcceleration;
@class UIAccelerometer;
@protocol CCAccelerometerDelegate <NSObject>

@optional
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
@end
#endif // __CC_PLATFORM_IOS
