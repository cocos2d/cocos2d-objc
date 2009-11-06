/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008, 2009 by Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
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
	float mSegThreshold;
	float mWidth;
	CGPoint mLastLocation;
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
