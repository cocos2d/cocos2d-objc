/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
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

#import "CCNode.h"

@protocol CCProjectionDelegate;

@class CCLightCollection;
@class CCDirector;

/** CCScene is a subclass of CCNode. The scene represents the root node of the node hierarchy.

 A scene is created using the default node initializer:
 
    id scene = [CCScene node];
 
 @note In previous versions of Cocos2D, CCLayer was used to group nodes in a CCScene. In v3 but also in v2 before that,
 you can simply use a CCNode to group other nodes.
 */
@interface CCScene : CCNode

/** @name Accessing Lights */
/** 
 A collection of lights in the scene.
 @see CCLightCollection
 @since v3.4 and later
 */
@property (nonatomic, readonly, strong) CCLightCollection *lights;

/**
 The scene's scheduler is responsible of triggering the scheduled callbacks. See CCScheduler for more details.
 
 @since v4.0 and later
 */
@property (nonatomic, readonly, strong) CCScheduler *scheduler;

/**
 Delegate that calculates the projection matrix for this scene.
 The default value is an CCProjectionOrthographic delegate that goes from (0, 0) to the screen's size in points.

 @since 4.0.0
 */
@property (nonatomic, strong) id<CCProjectionDelegate> projectionDelegate;

/**
 Projection matrix for this scene. This value is overridden if the projectionDelegate is set.
 Defaults to the identity matrix.

 @since 4.0.0
 */
@property (nonatomic, assign) GLKMatrix4 projection;

/// -----------------------------------------------------------------------
/// @name Creating a Scene
/// -----------------------------------------------------------------------

/* Initialize the node. */
-(id)init;

@end
