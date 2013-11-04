/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Lars Birkemose
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
#import "cocos2d.h"
#import "CCScene.h"

// -----------------------------------------------------------------

typedef NS_ENUM(NSInteger, CCTransitionDirection)
{
    CCTransitionDirectionUp,
    CCTransitionDirectionDown,
    CCTransitionDirectionRight,
    CCTransitionDirectionLeft,
    CCTransitionDirectionInvalid = -1,
};

// -----------------------------------------------------------------

@interface CCTransition : CCScene

// -----------------------------------------------------------------

/**
 *  Will downscale incoming and outgoing scene
 *  Can be used as an effect, or to decrease render time on complex scenes
 *  Default 1.0
 */
@property (nonatomic, assign) float outgoingDownScale;
@property (nonatomic, assign) float incomingDownScale;

/**
 *  Transition will be performed in retina resolution
 *  Will force outgoingDownScale and incomingDownScale to 1.0 on non retina devices, and 2.0 on retina devices if not set
 *  Default YES
 */
@property (nonatomic, getter = isRetinaTransition) BOOL retinaTransition;

/**
 *  Pixel format used for transition
 *  Default kCCTexture2DPixelFormat_RGB565
 */
@property (nonatomic, assign) CCTexturePixelFormat transitionPixelFormat;

/**
 *  Defines whether incoming and outgoing scene will be animated during transition
 *  Default NO
 */
@property (nonatomic, getter = isOutgoingSceneAnimated) BOOL outgoingSceneAnimated;
@property (nonatomic, getter = isIncomingSceneAnimated) BOOL incomingSceneAnimated;

/**
 *  The actual transition runtime in seconds
 */
@property (nonatomic, readonly) NSTimeInterval runTime;

/**
 *  Normalized transition progress
 */
@property (nonatomic, readonly) float progress;

// -----------------------------------------------------------------

/**
 *  Creates a cross fade transition
 *
 *  @param duration The duration of the transition in seconds
 *  @return A CCTransition
 */
+ (CCTransition *)transitionCrossFadeWithDuration:(NSTimeInterval)duration;

+ (CCTransition *)transitionFadeWithColor:(ccColor3B)color duration:(NSTimeInterval)duration;

+ (CCTransition *)transitionFadeWithDuration:(NSTimeInterval)duration;

+ (CCTransition *)transitionMoveInWithDirection:(CCTransitionDirection)direction duration:(NSTimeInterval)duration;

+ (CCTransition *)transitionPushWithDirection:(CCTransitionDirection)direction duration:(NSTimeInterval)duration;

+ (CCTransition *)transitionRevealWithDirection:(CCTransitionDirection)direction duration:(NSTimeInterval)duration;

// -----------------------------------------------------------------

@end
