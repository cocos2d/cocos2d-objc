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

@class CCAnimationManager;

CGPoint NodeToPhysicsScale(CCNode * node);
float NodeToPhysicsRotation(CCNode *node);
GLKMatrix4 NodeToPhysicsTransform(CCNode *node);
GLKMatrix4 RigidBodyToParentTransform(CCNode *node, CCPhysicsBody *body);
CGPoint GetPositionFromBody(CCNode *node, CCPhysicsBody *body);
CGPoint TransformPointAsVector(CGPoint p, GLKMatrix4 t);
GLKMatrix4 GLKMatrix4MakeRigid(CGPoint translate, CGFloat radians);

// TODO Doesn't really belong here, but the header includes are such a sphagetti mess it's hard to find anywhere else.
/// Transform and project a CGPoint by a 4x4 matrix. Throw away the resulting z value.
static inline CGPoint
CGPointApplyGLKMatrix4(CGPoint p, GLKMatrix4 m){
	GLKVector3 v = GLKMatrix4MultiplyAndProjectVector3(m, GLKVector3Make(p.x, p.y, 0.0));
	return CGPointMake(v.x, v.y);
}

@interface CCNode()

/* The real openGL Z vertex.
 Differences between openGL Z vertex and cocos2d Z order:
 - OpenGL Z modifies the Z vertex, and not the Z order in the relation between parent-children
 - OpenGL Z might require to set 2D projection
 - cocos2d Z order works OK if all the nodes uses the same openGL Z vertex. eg: vertexZ = 0
 @warning: Use it at your own risk since it might break the cocos2d parent-children z order
 */
@property (nonatomic,readwrite) float vertexZ;

/* Reads and writes the animation manager for this node.*/
@property (nonatomic, readwrite) CCAnimationManager * animationManager;

-(CCScheduler *)scheduler;

/* performance improvement, Sort the children array once before drawing, instead of every time when a child is added or reordered
 don't call this manually unless a child added needs to be removed in the same frame */
- (void) sortAllChildren;

/* Event that is called when the running node is no longer running (eg: its CCScene is being removed from the "stage" ).
 On cleanup you should break any possible circular references.
 CCNode's cleanup removes any possible scheduled timer and/or any possible action.
 If you override cleanup, you shall call [super cleanup]
 */
-(void) cleanup;

/* final method called to actually remove a child node from the children.
 *  @param node    The child node to remove
 *  @param cleanup Stops all scheduled events and actions
 */
-(void) detachChild:(CCNode *)child cleanup:(BOOL)doCleanup;

- (void) contentSizeChanged;


/**
 In certain special situations, you may wish to designate a node's parent without adding that node to the list
 of children. In particular this can be useful when a node references another node in an atypical non-child
 way, such as how the the CCClipNode tracks the stencil. The stencil is kept outside of the normal heirarchy,
 but still needs a parent to function in a scene.
 
 @since v4.0
 */
-(void)setRawParent:(CCNode *)parent;

/**
 You probably want "active" instead, but this tells you if the node is in the active scene wihtout regards
 to its pause state.
 @since v4.0
 */
-(BOOL) isInActiveScene;

@end
