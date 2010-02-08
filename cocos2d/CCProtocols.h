/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "ccTypes.h"
#import "CCTexture2D.h"

#pragma mark -
#pragma mark CCRGBAProtocol

/// CC RGBA protocol
@protocol CCRGBAProtocol <NSObject>
/** sets Color
 @since v0.8
 */
-(void) setColor:(ccColor3B)color;
/** returns the color
 @since v0.8
 */
-(ccColor3B) color;

/// returns the opacity
-(GLubyte) opacity;
/** sets the opacity.
 @warning If the the texture has premultiplied alpha then, the R, G and B channels will be modifed.
 */
-(void) setOpacity: (GLubyte) opacity;
@optional
/** sets the premultipliedAlphaOpacity property.
 If set to NO then opacity will be applied as: glColor(R,G,B,opacity);
 If set to YES then oapcity will be applied as: glColor(opacity, opacity, opacity, opacity );
 Textures with premultiplied alpha will have this property by default on YES. Otherwise the default value is NO
 @since v0.8
 */
-(void) setOpacityModifyRGB:(BOOL)boolean;
/** returns whether or not the opacity will be applied using glColor(R,G,B,opacity) or glColor(opacity, opacity, opacity, opacity);
 @since v0.8
 */
 -(BOOL) doesOpacityModifyRGB;
@end

#pragma mark -
#pragma mark CCBlendProtocol
/**
 You can specify the blending fuction.
 @since v0.99.0
 */
@protocol CCBlendProtocol <NSObject>
/** set the source blending function for the texture */
-(void) setBlendFunc:(ccBlendFunc)blendFunc;
/** returns the blending function used for the texture */
-(ccBlendFunc) blendFunc;
@end


#pragma mark -
#pragma mark CCTextureProtocol

/** CCNode objects that uses a Texture2D to render the images.
 The texture can have a blending function.
 If the texture has alpha premultiplied the default blending function is:
    src=GL_ONE dst= GL_ONE_MINUS_SRC_ALPHA
 else
	src=GL_SRC_ALPHA dst= GL_ONE_MINUS_SRC_ALPHA
 But you can change the blending funtion at any time.
 @since v0.8.0
 */
@protocol CCTextureProtocol <CCBlendProtocol>
/** returns the used texture */
-(CCTexture2D*) texture;
/** sets a new texture. it will be retained */
-(void) setTexture:(CCTexture2D*)texture;
@end

#pragma mark -
#pragma mark CCLabelProtocol
/** Common interface for Labels */
@protocol CCLabelProtocol <NSObject>
/** sets a new label using an NSString */
-(void) setString:(NSString*)label;

@optional
/** sets a new label using a CString.
 It is faster than setString since it doesn't require to alloc/retain/release an NString object.
 @since v0.99.0
 */
-(void) setCString:(char*)label;
@end

#pragma mark -
#pragma mark CCAnimationProtocol

/// Objects that supports the Animation protocol
/// @since v0.7.1
@protocol CCAnimationProtocol <NSObject>
/** readonly array with the frames. */
-(NSArray*) frames;
/** set a array of frames */
-(void) setFrames:(NSArray*)array;
/** delay of between frames in seconds. */
-(float) delay;
/** name of the animation. */
-(NSString*) name;
@end

#pragma mark -
#pragma mark CCFrameProtocol

/// Nodes supports frames protocol
/// @since v0.7.1
@class CCSpriteFrame;
@protocol CCFrameProtocol <NSObject>
/** sets a new display frame to the node. */
-(void) setDisplayFrame:(CCSpriteFrame*)newFrame;
/** changes the display frame based on an animation and an index. */
-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex;
/** returns the current displayed frame. */
-(BOOL) isFrameDisplayed:(CCSpriteFrame*)frame;
/** returns the current displayed frame. */
-(CCSpriteFrame*) displayedFrame;
/** returns an Animation given it's name. */
-(id<CCAnimationProtocol>)animationByName: (NSString*) animationName;
/** adds an Animation to the Sprite. */
-(void) addAnimation: (id<CCAnimationProtocol>) animation;
@end

