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
 *
 */

#import <Foundation/Foundation.h>
#if __CC_PLATFORM_IOS
#import <CoreGraphics/CoreGraphics.h>
#endif

@class CCSpriteFrame;
@class CCTexture;
@class CCSpriteFrame;

/**
 CCAnimationFrame contains information for a single animation frame.
 
 A `CCAnimationFrameDisplayedNotification` notification will be broadcast when a frame is displayed that contains a non-nil dictionary.
 
 */
@interface CCAnimationFrame : NSObject <NSCopying> {
    
    // SpriteFrame object.
    CCSpriteFrame* _spriteFrame;
    
    // Display frame for x delay time units.
    float _delayUnits;
    
    // Custom dictionary.
    NSDictionary *_userInfo;
}


/// -----------------------------------------------------------------------
/// @name Creating a Animation Frame
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns an Animation Frame object using the specified frame name, delay units and user info values.
 *
 *  @param spriteFrame Sprite Frame.
 *  @param delayUnits  Delay time units.
 *  @param userInfo    Custom dictionary.
 *
 *  @return An initialized CCAnimationFrame Object.
 *  @see CCSpriteFrame
 */
-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame delayUnits:(float)delayUnits userInfo:(NSDictionary*)userInfo;


/// -----------------------------------------------------------------------
/// @name Animation Frame Properties
/// -----------------------------------------------------------------------

/** CCSpriteFrame to be used.
 @see CCSpriteFrame */
@property (nonatomic, readwrite, strong) CCSpriteFrame* spriteFrame;

/** Number of time units to display this frame. */
@property (nonatomic, readwrite) float delayUnits;

/** Dictionary with custom user data. */
@property (nonatomic, readwrite, strong) NSDictionary *userInfo;

@end


/** 
 A CCAnimation is used to perform animations on a CCSprite.
 
 The CCAnimation primarily contains a collection of CCAnimationFrame objects that contain information about
 individual animation frames.
 */
@interface CCAnimation : NSObject <NSCopying>
{
    // Array of CCSpriteFrame.
	NSMutableArray	*_frames;
    
    // Total delay units.
	float			_totalDelayUnits;
    
    // Delay in seconds of the per frame delay unit.
	float			_delayPerUnit;
    
    // True to restore original frame when animation complete.
	BOOL			_restoreOriginalFrame;
    
    // Number of times to loop animation.
	NSUInteger		_loops;
}

/// -----------------------------------------------------------------------
/// @name Creating an Animation
/// -----------------------------------------------------------------------

/**
 *  Creates and returns an animation object.
 *
 *  @return The CCAnimation Object.
 */
+(instancetype) animation;

/**
 *  Creates and returns an animation object using the specified CCSpriteFrame array value.
 *  Default per frame delay of 1 second.
 *
 *  @param arrayOfSpriteFrameNames CCSpriteFrame array.
 *
 *  @return The CCAnimation Object.
 */
+(instancetype) animationWithSpriteFrames:(NSArray*)arrayOfSpriteFrameNames;

/**
 *  Creates and returns an animation object using the specified CCSpriteFrame array and per frame dealy values.
 *
 *  @param arrayOfSpriteFrameNames CCSpriteFrame array.
 *  @param delay                   Per frame delay (in seconds).
 *
 *  @return The CCAnimation Object.
 */
+(instancetype) animationWithSpriteFrames:(NSArray*)arrayOfSpriteFrameNames delay:(float)delay;

/**
 *  Creates and returns an animation object using the specified CCSpriteFrame array, per frame delay and times to repeat animation values.
 *
 *  @param arrayOfAnimationFrames CCSpriteFrame array.
 *  @param delayPerUnit           Per frame delay (in seconds).
 *  @param loops                  Number of times to repeat animation.
 *
 *  @return The CCAnimation Object.
 */
+(instancetype) animationWithAnimationFrames:(NSArray*)arrayOfAnimationFrames delayPerUnit:(float)delayPerUnit loops:(NSUInteger)loops;

/**
 *  Initializes and returns an animation object.
 *
 *  @param arrayOfSpriteFrameNames CCSpriteFrame array.
 *
 *  @return An initialized CCAnimation Object.
 */
-(id) initWithSpriteFrames:(NSArray*)arrayOfSpriteFrameNames;

/**
 *  Initializes and returns an animation object using the specified CCSpriteFrame array and per frame dealy values.
 *
 *  @param arrayOfSpriteFrameNames CCSpriteFrame array.
 *  @param delay                   Per frame delay (in seconds).
 *
 *  @return An initialized CCAnimation Object.
 */
-(id) initWithSpriteFrames:(NSArray *)arrayOfSpriteFrameNames delay:(float)delay;

/**
 *  Initializes and returns an animation object using the specified CCSpriteFrame array, per frame delay and times to repeat animation values.
 *
 *  @param arrayOfAnimationFrames CCSpriteFrame array.
 *  @param delayPerUnit           Per frame delay (in seconds).
 *  @param loops                  Number of times to repeat animation.
 *
 *  @return An initialized CCAnimation Object.
 */
-(id) initWithAnimationFrames:(NSArray*)arrayOfAnimationFrames delayPerUnit:(float)delayPerUnit loops:(NSUInteger)loops;


/// -----------------------------------------------------------------------
/// @name Adding Sprite Frames
/// -----------------------------------------------------------------------

/**
 *  Add the specified sprite frame to the animation object.
 *
 *  @param frame CCSpriteFrame object.
 *  @see CCSpriteFrame
 */
-(void) addSpriteFrame:(CCSpriteFrame*)frame;

/**
 *  Creates and adds a CCSpriteFrame to the animation object from the specified image file.
 *
 *  @param filename Image file resource.
 */
-(void) addSpriteFrameWithFilename:(NSString*)filename;

/**
 *  Creates and adds a CCSpriteFrame to the animation object from the specified the texture and rectangle values.
 *
 *  @param texture Texture object.
 *  @param rect    Rectangle to use.
 *  @see CCTexture
 */
-(void) addSpriteFrameWithTexture:(CCTexture*)texture rect:(CGRect)rect;

/// -----------------------------------------------------------------------
/// @name Animation Timing
/// -----------------------------------------------------------------------

/** Total Delay units. */
@property (nonatomic, readonly) float totalDelayUnits;

/** Delay in seconds of the per frame delay unit. */
@property (nonatomic, readwrite) float delayPerUnit;

/** Duration in seconds of the whole animation. */
@property (nonatomic,readonly) float duration;

/** Number of times to loop animation. */
@property (nonatomic, readwrite) NSUInteger loops;

/// -----------------------------------------------------------------------
/// @name Animation Frames
/// -----------------------------------------------------------------------

/** Array of CCAnimationFrames. */
@property (nonatomic,readwrite,strong) NSMutableArray *frames;

/** True to restore original frame when animation complete. */
@property (nonatomic,readwrite) BOOL restoreOriginalFrame;

@end
