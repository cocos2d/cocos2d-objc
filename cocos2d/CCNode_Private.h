//
//  CCNode_Private.h
//  cocos2d-ios
//
//  Created by Viktor on 10/28/13.
//
//

#import "CCNode.h"

@interface CCNode ()

/* The real openGL Z vertex.
 Differences between openGL Z vertex and cocos2d Z order:
 - OpenGL Z modifies the Z vertex, and not the Z order in the relation between parent-children
 - OpenGL Z might require to set 2D projection
 - cocos2d Z order works OK if all the nodes uses the same openGL Z vertex. eg: vertexZ = 0
 @warning: Use it at your own risk since it might break the cocos2d parent-children z order
 @since v0.8
 */
@property (nonatomic,readwrite) float vertexZ;

@property (nonatomic,readonly) BOOL isPhysicsNode;

/* Shader Program
 @since v2.0
 */
@property(nonatomic,readwrite,strong) CCGLProgram *shaderProgram;

/* used internally for zOrder sorting, don't change this manually */
@property(nonatomic,readwrite) NSUInteger orderOfArrival;

/* GL server side state
 @since v2.0
 */
@property (nonatomic, readwrite) ccGLServerState glServerState;

/* CCActionManager used by all the actions.
 IMPORTANT: If you set a new CCActionManager, then previously created actions are going to be removed.
 @since v2.0
 */
@property (nonatomic, readwrite, strong) CCActionManager *actionManager;

/* CCScheduler used to schedule all "updates" and timers.
 IMPORTANT: If you set a new CCScheduler, then previously created timers/update are going to be removed.
 @since v2.0
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
 @since v0.8
 */
-(void) cleanup;

/* performs OpenGL view-matrix transformation of its ancestors.
 Generally the ancestors are already transformed, but in certain cases (eg: attaching a FBO) it is necessary to transform the ancestors again.
 @since v0.7.2
 */
-(void) transformAncestors;

@end
