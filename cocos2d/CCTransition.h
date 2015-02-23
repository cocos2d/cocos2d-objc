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
#import "cocos2d.h"
#import "CCScene.h"

/**
 *  Defines the direction that a directional transition will move. Used by CCTransition.
 *
 *  If the direction is upwards, an exiting scene will ex. slide out the top, and an entering scene will slide in the bottom.
 */
typedef NS_ENUM(NSInteger, CCTransitionDirection)
{
    /** Transition moves upwards. */
    CCTransitionDirectionUp,
    
    /** Transition moves downwards. */
    CCTransitionDirectionDown,
    
    /** Transition moves rightwards. */
    CCTransitionDirectionRight,
    
    /** Transition moves leftwards. */
    CCTransitionDirectionLeft,
    
    /** An invalid transition direction. */
    CCTransitionDirectionInvalid = -1,
};

/**
 A transition animates the presentation of a new scene while moving the current scene out of view.
 A transition is optionally played when calling one of the presentScene:withTransition: methods of CCDirector.

 @note Since both scenes remain in memory and are being rendered, a transition may raise performance issues or
 memory warnings. If two complex scenes can not be reliably transitioned from/to it is best to not use transitions
 or to introduce an in-between scene that is presented only for a short period of time (ie a loading scene or merely
 a "fade to black" scene).
 */
@interface CCTransition : CCScene


/// -----------------------------------------------------------------------
/// @name Creating a Fade Scene Transition
/// -----------------------------------------------------------------------

/**
 *  Creates a cross fade transition directly from outgoing to incoming scene.
 *
 *  @param duration The duration of the transition in seconds.
 *
 *  @return The CCTransition Object.
 */
+ (CCTransition *)transitionCrossFadeWithDuration:(NSTimeInterval)duration;

/**
 *  Creates a fade transition from outgoing to incoming scene, through color.
 *
 *  @param color    The color to fade through
 *  @param duration The duration of the transition in seconds.
 *
 *  @return The CCTransition Object.
 *  @see CCColor
 */
+ (CCTransition *)transitionFadeWithColor:(CCColor*)color duration:(NSTimeInterval)duration;

/**
 *  Creates a fade transition from outgoing to incoming scene, through black.
 *
 *  @param duration The duration of the transition in seconds.
 *
 *  @return The CCTransition Object.
 */
+ (CCTransition *)transitionFadeWithDuration:(NSTimeInterval)duration;

/// -----------------------------------------------------------------------
/// @name Creating a Directional Scene Transition
/// -----------------------------------------------------------------------

/**
 *  Creates a transition where the incoming scene is moved in over the outgoing scene.
 *
 *  @param direction Direction to move the incoming scene.
 *  @param duration  The duration of the transition in seconds.
 *
 *  @return The CCTransition Object.
 *  @see CCTransitionDirection
 */
+ (CCTransition *)transitionMoveInWithDirection:(CCTransitionDirection)direction duration:(NSTimeInterval)duration;

/**
 *  Creates a transition where the incoming scene pushed the outgoing scene out.
 *
 *  @param direction Direction to move incoming and outgoing scenes.
 *  @param duration  The duration of the transition in seconds.
 *
 *  @return The CCTransition Object.
 *  @see CCTransitionDirection
 */
+ (CCTransition *)transitionPushWithDirection:(CCTransitionDirection)direction duration:(NSTimeInterval)duration;

/**
 *  Creates a transition where the incoming scene is revealed by sliding the outgoing scene out.
 *
 *  @param direction Direction to slide outcoing scene.
 *  @param duration  The duration of the transition in seconds.
 *
 *  @return The CCTransition Object.
 *  @see CCTransitionDirection
 */
+ (CCTransition *)transitionRevealWithDirection:(CCTransitionDirection)direction duration:(NSTimeInterval)duration;

/// -----------------------------------------------------------------------
/// @name Transition Performance Settings
/// -----------------------------------------------------------------------

/**
 *  Will downscale outgoing scene.
 *  Can be used as an effect, or to decrease render time on complex scenes.
 *  Default 1.0.
 */
@property (nonatomic, assign) float outgoingDownScale;

/**
 *  Will downscale incoming scene.
 *  Can be used as an effect, or to decrease render time on complex scenes.
 *  Default 1.0.
 */
@property (nonatomic, assign) float incomingDownScale;

/**
 *  Transition will be performed in retina resolution.
 *  Will force outgoingDownScale and incomingDownScale to 1.0 on non retina devices, and 2.0 on retina devices if not set.
 *  Default YES.
 */
@property (nonatomic, getter = isRetinaTransition) BOOL retinaTransition;

/**
 Pixel format used for transition.
 Default `CCTexturePixelFormat_RGBA8888`.
 @see CCTexturePixelFormat
 */
@property (nonatomic, assign) CCTexturePixelFormat transitionPixelFormat;

/**
 *  Depth/stencil format used for transition.
 *  Default `GL_DEPTH24_STENCIL8_OES`.
 */
@property (nonatomic, assign) GLuint transitionDepthStencilFormat;

/// -----------------------------------------------------------------------
/// @name Controlling Scene Animation during Transition
/// -----------------------------------------------------------------------

/**
 *  Defines whether outgoing scene will be animated during transition.
 *  Default NO.
 */
@property (nonatomic, getter = isOutgoingSceneAnimated) BOOL outgoingSceneAnimated;

/**
 *  Defines whether incoming scene will be animated during transition.
 *  Default NO.
 */
@property (nonatomic, getter = isIncomingSceneAnimated) BOOL incomingSceneAnimated;

/// -----------------------------------------------------------------------
/// @name For use with Custom Transitions
/// -----------------------------------------------------------------------

/**
 *  CCRenderTexture, holding the incoming scene as a texture
 *  Only valid after StartTransition has been called.
 */
@property (nonatomic, readonly) CCRenderTexture *incomingTexture;

/**
 *  CCRenderTexture, holding the outgoing scene as a texture
 *  Only valid after StartTransition has been called.
 */
@property (nonatomic, readonly) CCRenderTexture *outgoingTexture;

/// -----------------------------------------------------------------------
/// @name Transition Running Time and Progress
/// -----------------------------------------------------------------------

/** The actual transition runtime in seconds. */
@property (nonatomic, readonly) NSTimeInterval runTime;

/** Normalized (percentage) transition progress in the range 0.0 to 1.0. */
@property (nonatomic, readonly) float progress;


@end
