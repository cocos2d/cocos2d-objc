/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "ccTypes.h"
#import "Support/CCTexture2D.h"

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
 @warning If the the texture has premultiplied alpha then 
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
/** set the color of the node
 * example:  [node setRGB: 255:128:24];  or  [node setRGB:0xff:0x88:0x22];
 @since v0.7.1
 @deprecated Will be removed in v0.9. Use setColor instead.
 */
-(void) setRGB: (GLubyte)r :(GLubyte)g :(GLubyte)b __attribute__((deprecated));
/** The red component of the node's color
 @deprecated Will be removed in v0.9. Use color instead
 */
-(GLubyte) r __attribute__((deprecated));
/** The green component of the node's color.
 @deprecated Will be removed in v0.9. Use color instead
 */
-(GLubyte) g __attribute__((deprecated));
/** The blue component of the node's color.
 @deprecated Will be removed in v0.9. Use color instead
 */
-(GLubyte) b __attribute__((deprecated));
@end


/** CCNode objects that uses a Texture2D to render the images.
 The texture can have a blending function.
 If the texture has alpha premultiplied the default blending function is:
    src=GL_ONE dst= GL_ONE_MINUS_SRC_ALPHA
 else
	src=GL_SRC_ALPHA dst= GL_ONE_MINUS_SRC_ALPHA
 But you can change the blending funtion at any time.
 @since v0.8
 */
@protocol CCTextureProtocol <NSObject>
/** returns the used texture */
-(CCTexture2D*) texture;
/** sets a new texture. it will be retained */
-(void) setTexture:(CCTexture2D*)texture;
/** set the source blending function for the texture */
-(void) setBlendFunc:(ccBlendFunc)blendFunc;
/** returns the blending function used for the texture */
-(ccBlendFunc) blendFunc;
@end

/** Common interface for Labels */
@protocol CCLabelProtocol <NSObject>
/** sets a new label using an NSString */
-(void) setString:(NSString*)label;
@end



/// Objects that supports the Animation protocol
/// @since v0.7.1
@protocol CCAnimationProtocol <NSObject>
/** reaonly array with the frames */
-(NSArray*) frames;
/** delay of the animations */
-(float) delay;
/** name of the animation */
-(NSString*) name;
@end

/// Nodes supports frames protocol
/// @since v0.7.1
@protocol CCFrameProtocol <NSObject>
/** sets a new display frame to the node */
-(void) setDisplayFrame:(id)newFrame;
/** changes the display frame based on an animation and an index */
-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex;
/** returns the current displayed frame */
-(BOOL) isFrameDisplayed:(id)frame;
/** returns the current displayed frame */
-(id) displayFrame;
/** returns an Animation given it's name */
-(id<CCAnimationProtocol>)animationByName: (NSString*) animationName;
/** adds an Animation to the Sprite */
-(void) addAnimation: (id<CCAnimationProtocol>) animation;
@end

