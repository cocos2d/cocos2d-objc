/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008, 2009 Jason Booth
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
#import "CCNode.h"
#import "CCRibbon.h"

/**
 * CCMotionStreak manages a Ribbon based on it's motion in absolute space.
 * You construct it with a fadeTime, minimum segment size, texture path, texture
 * length and color. The fadeTime controls how long it takes each vertex in
 * the streak to fade out, the minimum segment size it how many pixels the
 * streak will move before adding a new ribbon segement, and the texture
 * length is the how many pixels the texture is stretched across. The texture
 * is vertically aligned along the streak segemnts. 
 *
 * Limitations:
 *   CCMotionStreak, by default, will use the GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA blending function.
 *   This blending function might not be the correct one for certain textures.
 *   But you can change it by using:
 *     [obj setBlendFunc: (ccBlendfunc) {new_src_blend_func, new_dst_blend_func}];
 *
 * @since v0.8.1
 */
@interface CCMotionStreak : CCNode <CCTextureProtocol>
{
	CCRibbon*	ribbon_;
	float		segThreshold_;
	float		width_;
	CGPoint	lastLocation_;
}

/** Ribbon used by MotionStreak (weak reference) */
@property (nonatomic,readonly) CCRibbon *ribbon;

/** creates the a MotionStreak. The image will be loaded using the TextureMgr. */
+(id)streakWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(ccColor4B)color;

/** initializes a MotionStreak. The file will be loaded using the TextureMgr. */
-(id)initWithFade:(float)fade minSeg:(float)seg image:(NSString*)path width:(float)width length:(float)length color:(ccColor4B)color;

/** polling function */
-(void)update:(ccTime)delta;

@end
