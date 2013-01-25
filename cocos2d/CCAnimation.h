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
	- # of delay units.
	- offset
 
 @since v2.0
 */
@interface CCAnimationFrame : NSObject <NSCopying>
{
    CCSpriteFrame* _spriteFrame;
    float _delayUnits;
    NSDictionary *_userInfo;
}
/** CCSpriteFrameName to be used */
@property (nonatomic, readwrite, retain) CCSpriteFrame* spriteFrame;

/**  how many units of time the frame takes */
@property (nonatomic, readwrite) float delayUnits;

/**  A CCAnimationFrameDisplayedNotification notification will be broadcasted when the frame is displayed with this dictionary as UserInfo. If UserInfo is nil, then no notification will be broadcasted. */
@property (nonatomic, readwrite, retain) NSDictionary *userInfo;

/** initializes the animation frame with a spriteframe, number of delay units and a notification user info */
-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame delayUnits:(float)delayUnits userInfo:(NSDictionary*)userInfo;
@end

/** A CCAnimation object is used to perform animations on the CCSprite objects.

 The CCAnimation object contains CCAnimationFrame objects, and a possible delay between the frames.
 You can animate a CCAnimation object by using the CCAnimate action. Example:

  [sprite runAction:[CCAnimate actionWithAnimation:animation]];

 */
@interface CCAnimation : NSObject <NSCopying>
{
	NSMutableArray	*_frames;
	float			_totalDelayUnits;
	float			_delayPerUnit;
	BOOL			_restoreOriginalFrame;
	NSUInteger		_loops;
}

/** total Delay units of the CCAnimation. */
@property (nonatomic, readonly) float totalDelayUnits;
/** Delay in seconds of the "delay unit" */
@property (nonatomic, readwrite) float delayPerUnit;
/** duration in seconds of the whole animation. It is the result of totalDelayUnits * delayPerUnit */
@property (nonatomic,readonly) float duration;
/** array of CCAnimationFrames */
@property (nonatomic,readwrite,retain) NSMutableArray *frames;
/** whether or not it shall restore the original frame when the animation finishes */
@property (nonatomic,readwrite) BOOL restoreOriginalFrame;
/** how many times the animation is going to loop. 0 means animation is not animated. 1, animation is executed one time, ... */
@property (nonatomic, readwrite) NSUInteger loops;

/** Creates an animation
 @since v0.99.5
 */
+(id) animation;

/** Creates an animation with an array of CCSpriteFrame.
 The frames will be created with one "delay unit".
 @since v0.99.5
 */
+(id) animationWithSpriteFrames:(NSArray*)arrayOfSpriteFrameNames;

/* Creates an animation with an array of CCSpriteFrame and a delay between frames in seconds.
 The frames will be added with one "delay unit".
 @since v0.99.5
 */
+(id) animationWithSpriteFrames:(NSArray*)arrayOfSpriteFrameNames delay:(float)delay;

/* Creates an animation with an array of CCAnimationFrame, the delay per units in seconds and and how many times it should be executed.
 @since v2.0
 */
+(id) animationWithAnimationFrames:(NSArray*)arrayOfAnimationFrames delayPerUnit:(float)delayPerUnit loops:(NSUInteger)loops;


/** Initializes a CCAnimation with an array of CCSpriteFrame.
 The frames will be added with one "delay unit".
 @since v0.99.5
*/
-(id) initWithSpriteFrames:(NSArray*)arrayOfSpriteFrameNames;

/** Initializes a CCAnimation with an array of CCSpriteFrames and a delay between frames in seconds.
 The frames will be added with one "delay unit".
 @since v0.99.5
 */
-(id) initWithSpriteFrames:(NSArray *)arrayOfSpriteFrameNames delay:(float)delay;

/* Initializes an animation with an array of CCAnimationFrame and the delay per units in seconds.
 @since v2.0
 */
-(id) initWithAnimationFrames:(NSArray*)arrayOfAnimationFrames delayPerUnit:(float)delayPerUnit loops:(NSUInteger)loops;

/** Adds a CCSpriteFrame to a CCAnimation.
 The frame will be added with one "delay unit".
*/
-(void) addSpriteFrame:(CCSpriteFrame*)frame;

/** Adds a frame with an image filename. Internally it will create a CCSpriteFrame and it will add it.
 The frame will be added with one "delay unit".
 Added to facilitate the migration from v0.8 to v0.9.
 */
-(void) addSpriteFrameWithFilename:(NSString*)filename;

/** Adds a frame with a texture and a rect. Internally it will create a CCSpriteFrame and it will add it.
 The frame will be added with one "delay unit".
 Added to facilitate the migration from v0.8 to v0.9.
 */
-(void) addSpriteFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;

@end
