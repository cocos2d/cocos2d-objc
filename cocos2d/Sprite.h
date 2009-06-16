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


#import <UIKit/UIKit.h>

#import "Support/Texture2D.h"

#import "TextureNode.h"

#pragma mark Sprite

@class Animation;
/** Sprite is a subclass of TextureNode that implements the CocosNodeFrames protocol.
 *
 * Sprite supports ALL CocosNode transformations, but in contrast to AtlasSprite it is much slower.
 * ONLY use Sprite if you can't achieve the same with effect with AtlasSprite, otherwise the use of
 * AtlasSprite is recommended.
 *
 * All features from TextureNode are valid, plus the following new features:
 *  - it supports animations (frames)
 *
 * Limitations of Sprite:
 *  - It doesn't perform as well as AtlasSprite
 */
@interface Sprite : TextureNode <CocosNodeFrames>
{
	NSMutableDictionary *animations;	
}

/** creates an sprite with an image file */
+ (id) spriteWithFile:(NSString *)imageFile;
/** creates an sprite from a CGImageRef image */
+ (id) spriteWithCGImage:(CGImageRef)image;

/** initializes the sprite with an image file */
- (id) initWithFile:(NSString *) imageFile;
/** creates an sprite from a CGImageRef image */
- (id) initWithCGImage:(CGImageRef)image;
/** creates an sprite with a Texture2D instance */
+(id) spriteWithTexture:(Texture2D*) tex;
/** initializes the sprite with a Texture2D instance */
-(id) initWithTexture:(Texture2D*) tex;
@end

#pragma mark Animation

/** an Animation object used within Sprites to perform animations */
@interface Animation : NSObject <CocosAnimation>
{
	NSString *name;
	float	delay;
	NSMutableArray *frames;
}

@property (readwrite,copy) NSString * name;

// CocosAnimation
@property (readwrite,assign) float delay;
@property (readwrite,retain) NSMutableArray *frames;

/** creates an Animation with name, delay and frames from image files */
+(id) animationWithName: (NSString*) name delay:(float)delay;

/** creates an Animation with name, delay and frames from image files */
+(id) animationWithName: (NSString*) name delay:(float)delay images:image1,... NS_REQUIRES_NIL_TERMINATION;

/** creates an Animation with name, delay and frames from Texture2D objects */
+(id) animationWithName: (NSString*) name delay:(float)delay textures:tex1,... NS_REQUIRES_NIL_TERMINATION;

/** initializes an Animation with name, delay and frames from Texture2D objects */
-(id) initWithName: (NSString*) name delay:(float)delay firstTexture:(Texture2D*)tex vaList:(va_list) args;



/** initializes an Animation with name and delay
 */
-(id) initWithName: (NSString*) name delay:(float)delay;

/** initializes an Animation with name, delay and frames from image files
 */
-(id) initWithName: (NSString*) name delay:(float)delay firstImage:(NSString*)filename vaList:(va_list) args;

/** adds a frame to an Animation */
-(void) addFrameWithFilename: (NSString*) filename;

/** adds a frame from a Texture2D object to an Animation */
-(void) addFrameWithTexture: (Texture2D*) tex;
@end
