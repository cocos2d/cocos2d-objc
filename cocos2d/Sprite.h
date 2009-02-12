/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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


#import <UIKit/UIKit.h>

#import "Support/Texture2D.h"

#import "TextureNode.h"

/** an Animation object used within Sprites to perform animations */
@interface Animation : NSObject
{
	NSString *name;
	float	delay;
	NSMutableArray *frames;
}

@property (readwrite,copy) NSString * name;
@property (readwrite,assign) float delay;
@property (readwrite,retain) NSMutableArray *frames;

/** initializes an Animation with name and delay */
-(id) initWithName: (NSString*) name delay:(float)delay;

/** creates an Animation with name, delay and frames from image files */
+(id) animationWithName: (NSString*) name delay:(float)delay images:image1,... NS_REQUIRES_NIL_TERMINATION;
/** initializes an Animation with name, delay and frames from image files */
-(id) initWithName: (NSString*) name delay:(float)delay firstImage:(NSString*)filename vaList:(va_list) args;
/** adds a frame to an Animation */
-(void) addFrame: (NSString*) filename;

/** creates an Animation with name, delay and frames from Texture2D objects */
+(id) animationWithName: (NSString*) name delay:(float)delay textures:tex1,... NS_REQUIRES_NIL_TERMINATION;
/** initializes an Animation with name, delay and frames from Texture2D objects */
-(id) initWithName: (NSString*) name delay:(float)delay firstTexture:(Texture2D*)tex vaList:(va_list) args;
/** adds a frame from a Texture2D object to an Animation */
-(void) addFrameWithTexture: (Texture2D*) tex;

@end


/** a 2D sprite */
@interface Sprite : TextureNode
{
	NSMutableDictionary *animations;	
}

/** creates an sprite with an image file */
+ (id) spriteWithFile:(NSString *)imageFile;
/** creates an sprite with a PVRTC image file
 * It can only load square images: width == height, and it must be a power of 2 (128,256,512...)
 * bpp can only be 2 or 4. 2 means more compression but lower quality.
 * hasAlpha: whether or not the image contains alpha channel
 * @deprecated This method will be removed in v0.8. Use spriteWithFile instead. It supports PVRTC (non Raw) format
 */
+ (id) spriteWithPVRTCFile: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w;
/** creates an sprite from a CGImageRef image */
+ (id) spriteWithCGImage:(CGImageRef)image;

/** initializes the sprite with an image file */
- (id) initWithFile:(NSString *) imageFile;
/** creates an sprite with a PVRTC image file
 * It can only load square images: width == height, and it must be a power of 2 (128,256,512...)
 * bpp can only be 2 or 4. 2 means more compression but lower quality.
 * hasAlpha: whether or not the image contains alpha channel
 * @deprecated This method will be removed in v0.8. Use initWithFile instead. It supports PVRTC (non Raw) format
 */
- (id) initWithPVRTCFile: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w;
/** creates an sprite from a CGImageRef image */
- (id) initWithCGImage:(CGImageRef)image;
/** creates an sprite with a Texture2D instance */
+(id) spriteWithTexture:(Texture2D*) tex;
/** initializes the sprite with a Texture2D instance */
-(id) initWithTexture:(Texture2D*) tex;


/** adds an Animation to the Sprite */
-(void) addAnimation: (Animation*) animation;
/** changes the display frame based on an animation and an index */
-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex;

@end
