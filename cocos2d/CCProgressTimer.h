/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2010 Lam Pham
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <Foundation/Foundation.h>
#import "CCSprite.h"

/** Types of progress
 @since v0.99.1
 */
typedef enum {
	/// Radial Counter-Clockwise 
	kCCProgressTimerTypeRadialCCW,
	/// Radial ClockWise
	kCCProgressTimerTypeRadialCW,
	/// Horizontal Left-Right
	kCCProgressTimerTypeHorizontalBarLR,
	/// Horizontal Right-Left
	kCCProgressTimerTypeHorizontalBarRL,
	/// Vertical Bottom-top
	kCCProgressTimerTypeVerticalBarBT,
	/// Vertical Top-Bottom
	kCCProgressTimerTypeVerticalBarTB,
} CCProgressTimerType;

/**
 CCProgresstimer is a subclass of CCNode.
 It renders the inner sprite according to the percentage.
 The progress can be Radial, Horizontal or vertical.
 @since v0.99.1
 */
@interface CCProgressTimer : CCNode {
	CCProgressTimerType	type_;
	float				percentage_;
	CCSprite			*sprite_;
	
	int					vertexDataCount_;
	ccV2F_C4F_T2F		*vertexData_;
}

/**	Change the percentage to change progress. */
@property CCProgressTimerType type;

/** Percentages are from 0 to 100 */
@property float percentage;


/** The image to show the progress percentage */
@property (retain) CCSprite *sprite;


/** Creates a progress timer with an image filename as the shape the timer goes through */
+ (id) progressWithFile:(NSString*) filename;
/** Initializes  a progress timer with an image filename as the shape the timer goes through */
- (id) initWithFile:(NSString*) filename;

/** Creates a progress timer with the texture as the shape the timer goes through */
+ (id) progressWithTexture:(CCTexture2D*) texture;
/** Creates a progress timer with the texture as the shape the timer goes through */
- (id) initWithTexture:(CCTexture2D*) texture;

@end
