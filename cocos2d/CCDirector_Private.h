/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
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
 */

#import "CCDirector.h"
#import "CCTransition.h"

@interface CCDirector () {
	@protected
	GLKMatrix4 _projectionMatrix;
	__weak id<CCDirectorDelegate> _delegate;
	__weak NSThread *_runningThread;
}

/* Whether or not the replaced scene will receive the cleanup message.
 If the new scene is pushed, then the old scene won't receive the "cleanup" message.
 If the new scene replaces the old one, the it will receive the "cleanup" message.
 */
@property (nonatomic, readonly) BOOL sendCleanupToScene;

/* This object will be visited after the main scene is visited.
 This object MUST implement the "visit" selector.
 Useful to hook a notification object, like CCNotifications (http://github.com/manucorporat/CCNotifications)
 */
@property (nonatomic, readwrite, strong) id	notificationNode;

/* CCScheduler associated with this director
 */
@property (nonatomic,readwrite,strong) CCScheduler *scheduler;

/* CCActionManager associated with this director
 */
@property (nonatomic,readwrite,strong) CCActionManager *actionManager;

/* CCFixedActionManager associated with this director
 */
@property (nonatomic,readwrite,strong) CCActionManager *actionManagerFixed;


/// Rect of the visible screen area in GL coordinates.
@property(nonatomic, readonly) CGRect viewportRect;

/* Sets the glViewport*/
-(void) setViewport;

/// XXX: missing description
-(float) getZEye;

/* Pops out all scenes from the queue until it reaches `level`.
 If level is 0, it will end the director.
 If level is 1, it will pop all scenes until it reaches to root scene.
 If level is <= than the current stack level, it won't do anything.
 */
-(void) popToSceneStackLevel:(NSUInteger)level;

/* Draw the scene.
 This method is called every frame. Don't call it manually.
 */
-(void) drawScene;

- (void)startTransition:(CCTransition *)transition;

/// Get a renderer object to use for rendering.
/// This method is thread safe.
-(CCRenderer *)rendererFromPool;

/// Return a renderer to a pool after rendering.
/// This method is thread safe.
-(void)poolRenderer:(CCRenderer *)renderer;

/// Add a block to be called when the GPU finishes rendering a frame.
/// This is used to pool rendering resources (renderers, buffers, textures, etc) without stalling the GPU pipeline.
-(void)addFrameCompletionHandler:(dispatch_block_t)handler;

@end


@interface CCDirector(Stats)

-(void) createStatsLabel;

@end

@interface CCTransition (Private)

- (void)startTransition:(CCScene *)scene;

@end

// optimization. Should only be used to read it. Never to write it.
extern NSUInteger __ccNumberOfDraws;
