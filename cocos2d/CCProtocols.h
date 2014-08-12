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

#import "ccMacros.h"
#import "ccTypes.h"
#import "CCColor.h"


@class CCTexture;
@class CCDirector;
@class CCBlendMode;
@class CCShader;
@class CCRenderState;
@class CCEffect;

#pragma mark - CCShaderProtocol

/// Properties for controlling the shader of a CCNode when it renders.
/// These properties are already implemented by CCNode, but not normally exposed.
@protocol CCShaderProtocol <NSObject>

@optional

/// The shader this node will be drawn using.
@property(nonatomic, strong) CCShader *shader;
/// The dictionary of shader uniform values that will be passed to the shader.
@property(nonatomic, readonly) NSMutableDictionary *shaderUniforms;

/// The rendering state this node will use when rendering.
@property(nonatomic, readonly, strong) CCRenderState *renderState;

@end

#pragma mark - CCEffectProtocol

@protocol CCEffectProtocol <NSObject>

/** Effect which will be applied to this sprite, NOTE: effect will overwrite any custom CCShader settings. */
@property (nonatomic, strong) CCEffect* effect;

@end

#pragma mark - CCBlendProtocol
/**
 You can specify the blending function.
 */
@protocol CCBlendProtocol <NSObject>

@optional

/// The blending mode that will be used to render this node.
@property(nonatomic, readwrite, strong) CCBlendMode *blendMode;

/// The rendering state this node will use when rendering.
@property(nonatomic, readonly, strong) CCRenderState *renderState;

/** set the source blending function for the texture */
-(void) setBlendFunc:(ccBlendFunc)blendFunc __attribute__((deprecated));
/** returns the blending function used for the texture */
-(ccBlendFunc) blendFunc __attribute__((deprecated));

@end


#pragma mark - CCTextureProtocol

/** CCNode objects that uses a Texture2D to render the images.
 The texture can have a blending function.
 If the texture has alpha premultiplied the default blending function is:
    src=GL_ONE dst= GL_ONE_MINUS_SRC_ALPHA
 else
	src=GL_SRC_ALPHA dst= GL_ONE_MINUS_SRC_ALPHA
 But you can change the blending function at any time.
 */
@protocol CCTextureProtocol <CCBlendProtocol>

@optional

/// The main texture that will be passed to this node's shader.
@property(nonatomic, strong) CCTexture *texture;

/// The rendering state this node will use when rendering.
@property(nonatomic, readonly, strong) CCRenderState *renderState;

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
 */
-(void) setCString:(char*)label;
@end


#pragma mark - CCDirectorDelegate
/** CCDirector delegate */
@protocol CCDirectorDelegate <NSObject>

@optional
/** Called by CCDirector when the projection is updated, and "custom" projection is used */
-(GLKMatrix4) updateProjection;

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
