/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
 *
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

#import "ccTypes.h"

@class CCNode;

/**
 Delegate type used to set custom projections for CCScene and CCViewportNode.

 @since 4.0.0
 */
@protocol CCProjectionDelegate

/**
 Return the current projection matrix.

 @since 4.0.0
 */
@property(nonatomic, readonly) GLKMatrix4 projection;

@end


@interface CCAbstractProjection : NSObject

/**
 Initialize an abstract projection delegate with a target from which the content size is read.

 @since 4.0.0
 */
-(instancetype)initWithTarget:(CCNode *)target;

/**
 The z-value of the camera's near plane.

 @since 4.0.0
 */
@property (nonatomic, assign) float nearZ;

/**
 The z-value of the camera's far plane.

 @since 4.0.0
 */
@property (nonatomic, assign) float farZ;

@end


/**
 Creates a orthographic projection matrix from (0, 0) to the content size in points of its target.
 This is the default delegate type used by CCViewPortNodes and CCScenes.
 It sets up the projection so that the size of points are preserved.
 */
@interface CCOrthoProjection : CCAbstractProjection<CCProjectionDelegate>
@end

/**
 Creates an orthographic projection matrix that is centered on (0, 0) with a width and height that matches the content size in points of its target.
 This is useful for viewport nodes that you want to use like a camera that can be centered on an object.
 */
@interface CCCenteredOrthoProjection : CCAbstractProjection<CCProjectionDelegate>
@end


/**
 Creates an perspective projection centered on (0, 0, 0).
 This is useful for viewport nodes that you want to use like a camera that can be centered on an object.

 @since 4.0.0
 */
@interface CCCenteredPerspectiveProjection : CCAbstractProjection<CCProjectionDelegate>

/**
 The z-value of the eye point.

 @since 4.0.0
 */
@property (nonatomic, assign) float eyeZ;

@end
