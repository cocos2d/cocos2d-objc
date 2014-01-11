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
 CCMotionStreak creates a motion trail special effect.
 
 ### Notes
 - Segments controls how smooth the shape of the trail appears.
 - Fast mode enables faster point addition and the cost of lower point precision.
 */
@interface CCMotionStreak : CCNode <CCTextureProtocol> {
    
    // Texture.
    CCTexture *_texture;
    
    // Position.
    CGPoint _positionR;
    
    // Blend mode.
    ccBlendFunc _blendFunc;
    
    // Stroke width.
    float _stroke;
    
    // Fade time.
    float _fadeDelta;
    
    // Minimum segments.
    float _minSeg;
    
    // Point counters.
    NSUInteger _maxPoints;
    NSUInteger _nuPoints;
	NSUInteger _previousNuPoints;

    // Trail vertexes.
    CGPoint *_pointVertexes;
    
    // Trail vertex states.
    float *_pointState;

    // OpenGL.
    ccVertex2F *_vertices;
    unsigned char *_colorPointer;
    ccTex2F *_texCoords;

    // Toggle fast mode.
    BOOL	_fastMode;
	
    // Starting point.
	BOOL	_startingPositionInitialized;
}

/// -----------------------------------------------------------------------
/// @name Accessing Motion Streak Attributes
/// -----------------------------------------------------------------------

/** Blend method. */
@property (nonatomic, readwrite, assign) ccBlendFunc blendFunc;

/** Fast mode toggle. */
@property (nonatomic, readwrite, assign, getter = isFastMode) BOOL fastMode;

/** Trail texture. */
@property (nonatomic, strong) CCTexture *texture;


/// -----------------------------------------------------------------------
/// @name Creating a CCMotionStreak Object
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
 */
+(id)streakWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color texture:(CCTexture*)texture;


/// -----------------------------------------------------------------------
/// @name Initializing a CCMotionStreak Object
/// -----------------------------------------------------------------------

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
 */
-(id)initWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color texture:(CCTexture*)texture;

/** Remove all living segments. */
-(void)reset;

@end
