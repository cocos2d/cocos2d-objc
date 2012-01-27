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
 *
 */

#import <Foundation/Foundation.h>
#ifdef __CC_PLATFORM_IOS
#import <CoreGraphics/CoreGraphics.h>
#endif // IPHONE

@class CCSpriteFrame;
@class CCTexture2D;
@class CCSpriteFrame;

/** CCAnimationFrame
 A frame of the animation. It contains information like:
	- sprite frame name
	- # of units of time
	- offset
 
 @since v2.0
 */
@interface CCAnimationFrame : NSObject <NSCopying>
{}
/** CCSpriteFrameName to be used */
@property (nonatomic, readwrite, retain) CCSpriteFrame* spriteFrame;

/** offset when rendering the frame */
@property (nonatomic, readwrite) CGPoint offset;

/**  how many units of time the frame takes */
@property (nonatomic, readwrite) float unitsOfTime;

/** initializes the animation frame with a spriteframe, a delay and an offset */
-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame unitsOfTime:(float)unitsOfTime offset:(CGPoint)offset;
@end

/** A CCAnimation object is used to perform animations on the CCSprite objects.

 The CCAnimation object contains CCAnimationFrame objects, and a possible delay between the frames.
 You can animate a CCAnimation object by using the CCAnimate action. Example:

  [sprite runAction:[CCAnimate actionWithAnimation:animation]];

 */
@interface CCAnimation : NSObject
{}

/** total units of time of the animation */
@property (nonatomic, readonly) float totalUnitsOfTime;
/** unit of time value */
@property (nonatomic, readwrite) float unitOfTimeValue;
/** duration in seconds of the animation. It is the result of totalUnitsOfTime * unitOfTimeValue */
@property (nonatomic,readonly) float duration;
/** average delay of each frame.
 @deprecated Use duration and / or totalUnitsOfTime instead.
 */
@property (nonatomic,readwrite,assign) float delay;
/** array of CCAnimationFrames */
@property (nonatomic,readwrite,retain) NSMutableArray *frames;
/** whether or not it shall restore the original frame when the animation finishes */
@property (nonatomic,readwrite) BOOL restoreOriginalFrame;

/** Creates an animation
 @since v0.99.5
 */
+(id) animation;

/** Creates an animation with frames.
 @since v0.99.5
 */
+(id) animationWithFrames:(NSArray*)frames;

/* Creates an animation with frames and a delay between frames.
 @since v0.99.5
 */
+(id) animationWithFrames:(NSArray*)arrayOfSpriteFrameNames delay:(float)delay;

/* Creates an animation with an array of CCAnimationFrame and whether or not to loop the animation
 @since v2.0
 */
+(id) animationWithFrames:(NSArray*)arrayOfAnimationFrames unitOfTimeValue:(float)unitOfTimeValue;


/** Initializes a CCAnimation with frames.
 @since v0.99.5
*/
-(id) initWithFrames:(NSArray*)arrayOfSpriteFrameNames;

/** Initializes a CCAnimation with frames and a delay between frames
 @since v0.99.5
 */
-(id) initWithFrames:(NSArray *)arrayOfSpriteFrameNames delay:(float)delay;

/* Initializes an animation with an array of CCAnimationFrame and whether or not to loop the animation
 @since v2.0
 */
-(id) initWithFrames:(NSArray*)arrayOfAnimationFrames unitOfTimeValue:(float)unitOfTimeValue;

/** Adds a frame to a CCAnimation. */
-(void) addFrame:(CCSpriteFrame*)frame;

/** Adds a frame with an image filename. Internally it will create a CCSpriteFrame and it will add it.
 Added to facilitate the migration from v0.8 to v0.9.
 */
-(void) addFrameWithFilename:(NSString*)filename;

/** Adds a frame with a texture and a rect. Internally it will create a CCSpriteFrame and it will add it.
 Added to facilitate the migration from v0.8 to v0.9.
 */
-(void) addFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;

@end
