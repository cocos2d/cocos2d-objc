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

#import "CCNode.h"

@interface CCNode ()

/* The real openGL Z vertex.
 Differences between openGL Z vertex and cocos2d Z order:
 - OpenGL Z modifies the Z vertex, and not the Z order in the relation between parent-children
 - OpenGL Z might require to set 2D projection
 - cocos2d Z order works OK if all the nodes uses the same openGL Z vertex. eg: vertexZ = 0
 @warning: Use it at your own risk since it might break the cocos2d parent-children z order
 */
@property (nonatomic,readwrite) float vertexZ;

@property (nonatomic,readonly) BOOL isPhysicsNode;

/* Shader Program
 */
@property(nonatomic,readwrite,strong) CCGLProgram *shaderProgram;

/* used internally for zOrder sorting, don't change this manually */
@property(nonatomic,readwrite) NSUInteger orderOfArrival;

/* GL server side state
 */
@property (nonatomic, readwrite) ccGLServerState glServerState;

/* CCActionManager used by all the actions.
 IMPORTANT: If you set a new CCActionManager, then previously created actions are going to be removed.
 */
@property (nonatomic, readwrite, strong) CCActionManager *actionManager;

/* CCScheduler used to schedule all "updates" and timers.
 IMPORTANT: If you set a new CCScheduler, then previously created timers/update are going to be removed.
 */
@property (nonatomic, readwrite, strong) CCScheduler *scheduler;

/* Compares two nodes in respect to zOrder and orderOfArrival (used for sorting sprites in display list) */
- (NSComparisonResult) compareZOrderToNode:(CCNode*)node;

/* Reorders a child according to a new z value.
 * The child MUST be already added.
 */
-(void) reorderChild:(CCNode*)child z:(NSInteger)zOrder;

/* performance improvement, Sort the children array once before drawing, instead of every time when a child is added or reordered
 don't call this manually unless a child added needs to be removed in the same frame */
- (void) sortAllChildren;

/* Event that is called when the running node is no longer running (eg: its CCScene is being removed from the "stage" ).
 On cleanup you should break any possible circular references.
 CCNode's cleanup removes any possible scheduled timer and/or any possible action.
 If you override cleanup, you shall call [super cleanup]
 */
-(void) cleanup;

/* performs OpenGL view-matrix transformation of its ancestors.
 Generally the ancestors are already transformed, but in certain cases (eg: attaching a FBO) it is necessary to transform the ancestors again.
 */
-(void) transformAncestors;

/* final method called to actually remove a child node from the children.
 *  @param node    The child node to remove
 *  @param cleanup Stops all scheduled events and actions
 */
-(void) detachChild:(CCNode *)child cleanup:(BOOL)doCleanup;

@end
