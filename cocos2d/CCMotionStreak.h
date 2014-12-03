/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 ForzeField Studios S.L. http://forzefield.com
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
#import "CCTexture.h"
#import "ccTypes.h"
#import "CCNode.h"

/**
 CCMotionStreak creates a motion trail special effect. The trail fades out after a short period of time.
 
 ### Notes
 - Segments controls how smooth the shape of the trail appears.
 - Fast mode enables faster point addition and the cost of lower point precision.
 */
@interface CCMotionStreak : CCNode <CCTextureProtocol, CCShaderProtocol, CCBlendProtocol>

/// -----------------------------------------------------------------------
/// @name Creating a Motion Streak
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a motion streak object from the specified fade time, segments, stroke, color and texture file path values.
 *
 *  @param fade   Fade time.
 *  @param minSeg Minimum segments.
 *  @param stroke Stroke width.
 *  @param color  Color.
 *  @param path   Texture file path.
 *
 *  @return The CCMotionStreak object.
 *  @see CCColor
 */
+(id)streakWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color textureFilename:(NSString*)path;

/**
 *  Creates and returns a motion streak object from the specified fade time, segments, stroke, color and texture values.
 *
 *  @param fade    Fade time.
 *  @param minSeg  Minimum segments.
 *  @param stroke  Stroke width.
 *  @param color   Color.
 *  @param texture Texture.
 *
 *  @return The CCMotionStreak object.
 *  @see CCColor
 *  @see CCTexture
 */
+(id)streakWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color texture:(CCTexture*)texture;

/**
 *  Initializes and returns a motion streak object from the specified fade time, segments, stroke, color and texture file path values.
 *
 *  @param fade   Fade time.
 *  @param minSeg Minimum segments.
 *  @param stroke Stroke width.
 *  @param color  Color.
 *  @param path   Texture file path.
 *
 *  @return An initialized CCMotionStreak object.
 *  @see CCColor
 */
-(id)initWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color textureFilename:(NSString*)path;

/**
 *  Initializes and returns a motion streak object from the specified fade time, segments, stroke, color and texture values.
 *
 *  @param fade    Fade time.
 *  @param minSeg  Minimum segments.
 *  @param stroke  Stroke width.
 *  @param color   Color.
 *  @param texture Texture.
 *
 *  @return An initialized CCMotionStreak object.
 *  @see CCColor
 *  @see CCTexture
 */
-(id)initWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color texture:(CCTexture*)texture;

/// -----------------------------------------------------------------------
/// @name Resetting the Motion Streak
/// -----------------------------------------------------------------------

/** Remove all living segments. */
-(void)reset;

/// -----------------------------------------------------------------------
/// @name Accessing Motion Streak Attributes
/// -----------------------------------------------------------------------

/** Toggles "faster but less precise" mode. */
@property (nonatomic, readwrite, assign, getter = isFastMode) BOOL fastMode;

@end
