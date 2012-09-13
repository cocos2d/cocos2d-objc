/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 ForzeField Studios S.L. http://forzefield.com
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
#import "CCTexture2D.h"
#import "ccTypes.h"
#import "CCNode.h"

/** MotionStreak.
 Creates a trailing path.
 */
@interface CCMotionStreak : CCNode <CCTextureProtocol, CCRGBAProtocol>
{
    CCTexture2D *texture_;
    CGPoint positionR_;
    ccColor3B color_;
    ccBlendFunc blendFunc_;
    float stroke_;
    float fadeDelta_;
    float minSeg_;

    NSUInteger maxPoints_;
    NSUInteger nuPoints_;
	NSUInteger previousNuPoints_;

    /** Pointers */
    CGPoint *pointVertexes_;
    float *pointState_;

    // Opengl
    ccVertex2F *vertices_;
    unsigned char *colorPointer_;
    ccTex2F *texCoords_;

    BOOL	fastMode_;
	
	BOOL	startingPositionInitialized_;
}
/** blending function */
@property (nonatomic, readwrite, assign) ccBlendFunc blendFunc;

/** When fast mode is enabled, new points are added faster but with lower precision */
@property (nonatomic, readwrite, assign, getter = isFastMode) BOOL fastMode;

/** texture used for the motion streak */
@property (nonatomic, retain) CCTexture2D *texture;

/** creates and initializes a motion streak with fade in seconds, minimum segments, stroke's width, color, texture filename */
+ (id) streakWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(ccColor3B)color textureFilename:(NSString*)path;
/** creates and initializes a motion streak with fade in seconds, minimum segments, stroke's width, color, texture */
+ (id) streakWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(ccColor3B)color texture:(CCTexture2D*)texture;

/** initializes a motion streak with fade in seconds, minimum segments, stroke's width, color and texture filename */
- (id) initWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(ccColor3B)color textureFilename:(NSString*)path;
/** initializes a motion streak with fade in seconds, minimum segments, stroke's width, color and texture  */
- (id) initWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(ccColor3B)color texture:(CCTexture2D*)texture;

/** color used for the tint */
- (void) tintWithColor:(ccColor3B)colors;

/** Remove all living segments of the ribbon */
- (void) reset;

@end
