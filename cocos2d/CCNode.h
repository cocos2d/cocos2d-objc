/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

#import <Availability.h>

#import "Platforms/CCGL.h"
#import "CCAction.h"
#import "ccTypes.h"
#import "CCTexture2D.h"
#import "CCProtocols.h"
#import "ccConfig.h"
#import "Support/CCArray.h"

enum {
	kCCNodeTagInvalid = -1,
};

@class CCCamera;
@class CCGridBase;

/** CCNode is the main element. Anything thats gets drawn or contains things that get drawn is a CCNode.
 The most popular CCNodes are: CCScene, CCLayer, CCSprite, CCMenu.
 
 The main features of a CCNode are:
 - They can contain other CCNode nodes (addChild, getChildByTag, removeChild, etc)
 - They can schedule periodic callback (schedule, unschedule, etc)
 - They can execute actions (runAction, stopAction, etc)
 
 Some CCNode nodes provide extra functionality for them or their children.
 
 Subclassing a CCNode usually means (one/all) of:
 - overriding init to initialize resources and schedule callbacks
 - create callbacks to handle the advancement of time
 - overriding draw to render the node
 
 Features of CCNode:
 - position
 - scale (x, y)
 - rotation (in degrees, clockwise)
 - CCCamera (an interface to gluLookAt )
 - CCGridBase (to do mesh transformations)
 - anchor point
 - size
 - visible
 - z-order
 - openGL z position
 
 Default values:
  - rotation: 0
  - position: (x=0,y=0)
  - scale: (x=1,y=1)
  - contentSize: (x=0,y=0)
  - anchorPoint: (x=0,y=0)
 
 Limitations:
 - A CCNode is a "void" object. It doesn't have a texture
 
 Order in transformations with grid disabled
 -# The node will be translated (position)
 -# The node will be rotated (rotation)
 -# The node will be scaled (scale)
 -# The node will be moved according to the camera values (camera)
 
 Order in transformations with grid enabled
 -# The node will be translated (position)
 -# The node will be rotated (rotation)
 -# The node will be scaled (scale)
 -# The grid will capture the screen
 -# The node will be moved according to the camera values (camera)
 -# The grid will render the captured screen
 
 Camera:
 - Each node has a camera. By default it points to the center of the CCNode.
 */ 
@interface CCNode : NSObject
{	
	// rotation angle
	float rotation_;	
	
	// scaling factors
	float scaleX_, scaleY_;
	
	// position of the node
	CGPoint position_;
	CGPoint	positionInPixels_;
	
	// skew angles
	float skewX_, skewY_;

	// is visible
	BOOL visible_;
	
	// anchor point in pixels
	CGPoint anchorPointInPixels_;	
	// anchor point normalized
	CGPoint anchorPoint_;	
	// If YES the transformtions will be relative to (-transform.x, -transform.y).
	// Sprites, Labels and any other "small" object uses it.
	// Scenes, Layers and other "whole screen" object don't use it.
	BOOL isRelativeAnchorPoint_;
	
	// untransformed size of the node
	CGSize	contentSize_;
	CGSize	contentSizeInPixels_;
	
	// transform
	CGAffineTransform transform_, inverse_;
#if	CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	GLfloat	transformGL_[16];
#endif

	// openGL real Z vertex
	float vertexZ_;
	
	// a Camera
	CCCamera *camera_;
	
	// a Grid
	CCGridBase *grid_;
	
	// z-order value
	NSInteger zOrder_;
	
	// array of children
	CCArray *children_;
	
	// weakref to parent
	CCNode *parent_;
	
	// a tag. any number you want to assign to the node
	NSInteger tag_;
    
	// user data field
	void *userData_;

	// Is running
	BOOL isRunning_;
	
	//used to preserve sequence while sorting children with the same zOrder
	int mutatedIndex_;

	// To reduce memory, place BOOLs that are not properties here:
	BOOL isTransformDirty_:1;
	BOOL isInverseDirty_:1;
	BOOL isReorderChildDirty_:1;
#if	CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	BOOL isTransformGLDirty_:1;
#endif
}

/** The z order of the node relative to it's "brothers": children of the same parent */
@property(nonatomic,readonly) NSInteger zOrder;
/** The real openGL Z vertex.
 Differences between openGL Z vertex and cocos2d Z order:
   - OpenGL Z modifies the Z vertex, and not the Z order in the relation between parent-children
   - OpenGL Z might require to set 2D projection
   - cocos2d Z order works OK if all the nodes uses the same openGL Z vertex. eg: vertexZ = 0
 @warning: Use it at your own risk since it might break the cocos2d parent-children z order
 @since v0.8
 */
@property (nonatomic,readwrite) float vertexZ;

/** The X skew angle of the node in degrees.
 This angle describes the shear distortion in the X direction.
 Thus, it is the angle between the Y axis and the left edge of the shape
 The default skewX angle is 0. Positive values distort the node in a CW direction.
 */
@property(nonatomic,readwrite,assign) float skewX;

/** The Y skew angle of the node in degrees.
 This angle describes the shear distortion in the Y direction.
 Thus, it is the angle between the X axis and the bottom edge of the shape
 The default skewY angle is 0. Positive values distort the node in a CCW direction.
 */
@property(nonatomic,readwrite,assign) float skewY;
/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node CW. */
@property(nonatomic,readwrite,assign) float rotation;
/** The scale factor of the node. 1.0 is the default scale factor. It modifies the X and Y scale at the same time. */
@property(nonatomic,readwrite,assign) float scale;
/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the X scale factor. */
@property(nonatomic,readwrite,assign) float scaleX;
/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the Y scale factor. */
@property(nonatomic,readwrite,assign) float scaleY;
/** Position (x,y) of the node in points. (0,0) is the left-bottom corner. */
@property(nonatomic,readwrite,assign) CGPoint position;
/** Position (x,y) of the node in points. (0,0) is the left-bottom corner. */
@property(nonatomic,readwrite,assign) CGPoint positionInPixels;
/** A CCCamera object that lets you move the node using a gluLookAt
*/
@property(nonatomic,readonly) CCCamera* camera;
/** Array of children */
@property(nonatomic,readonly) CCArray *children;
/** A CCGrid object that is used when applying effects */
@property(nonatomic,readwrite,retain) CCGridBase* grid;
/** Whether of not the node is visible. Default is YES */
@property(nonatomic,readwrite,assign) BOOL visible;
/** anchorPoint is the point around which all transformations and positioning manipulations take place.
 It's like a pin in the node where it is "attached" to its parent.
 The anchorPoint is normalized, like a percentage. (0,0) means the bottom-left corner and (1,1) means the top-right corner.
 But you can use values higher than (1,1) and lower than (0,0) too.
 The default anchorPoint is (0,0). It starts in the bottom-left corner. CCSprite and other subclasses have a different default anchorPoint.
 @since v0.8
 */
@property(nonatomic,readwrite) CGPoint anchorPoint;
/** The anchorPoint in absolute pixels.
 Since v0.8 you can only read it. If you wish to modify it, use anchorPoint instead
 */
@property(nonatomic,readonly) CGPoint anchorPointInPixels;

/** The untransformed size of the node in Points
 The contentSize remains the same no matter the node is scaled or rotated.
 All nodes has a size. Layer and Scene has the same size of the screen.
 @since v0.8
 */
@property (nonatomic,readwrite) CGSize contentSize;

/** The untransformed size of the node in Pixels
 The contentSize remains the same no matter the node is scaled or rotated.
 All nodes has a size. Layer and Scene has the same size of the screen.
 @since v0.8
 */
@property (nonatomic,readwrite) CGSize contentSizeInPixels;

/** whether or not the node is running */
@property(nonatomic,readonly) BOOL isRunning;
/** A weak reference to the parent */
@property(nonatomic,readwrite,assign) CCNode* parent;
/** If YES the transformtions will be relative to it's anchor point.
 * Sprites, Labels and any other sizeble object use it have it enabled by default.
 * Scenes, Layers and other "whole screen" object don't use it, have it disabled by default.
 */
@property(nonatomic,readwrite,assign) BOOL isRelativeAnchorPoint;
/** A tag used to identify the node easily */
@property(nonatomic,readwrite,assign) NSInteger tag;
/** A custom user data pointer */
@property(nonatomic,readwrite,assign) void *userData;

/** used internally for zOrder sorting, don't change this manually */
@property(nonatomic,readwrite) int mutatedIndex;

// initializators
/** allocates and initializes a node.
 The node will be created as "autorelease".
 */
+(id) node;
/** initializes the node */
-(id) init;


// scene managment

/** callback that is called every time the CCNode enters the 'stage'.
 If the CCNode enters the 'stage' with a transition, this callback is called when the transition starts.
 During onEnter you can't a "sister/brother" node.
 */
-(void) onEnter;
/** callback that is called when the CCNode enters in the 'stage'.
 If the CCNode enters the 'stage' with a transition, this callback is called when the transition finishes.
 @since v0.8
 */
-(void) onEnterTransitionDidFinish;
/** callback that is called every time the CCNode leaves the 'stage'.
 If the CCNode leaves the 'stage' with a transition, this callback is called when the transition finishes.
 During onExit you can't access a sibling node.
 */
-(void) onExit;


// composition: ADD

/** Adds a child to the container with z-order as 0.
 If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
 @since v0.7.1
 */
-(void) addChild: (CCNode*)node;

/** Adds a child to the container with a z-order.
 If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
 @since v0.7.1
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z;

/** Adds a child to the container with z order and tag.
 If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
 @since v0.7.1
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z tag:(NSInteger)tag;

// composition: REMOVE

/** Remove itself from its parent node. If cleanup is YES, then also remove all actions and callbacks.
 If the node orphan, then nothing happens.
 @since v0.99.3
 */
-(void) removeFromParentAndCleanup:(BOOL)cleanup;

/** Removes a child from the container. It will also cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
-(void) removeChild: (CCNode*)node cleanup:(BOOL)cleanup;

/** Removes a child from the container by tag value. It will also cleanup all running actions depending on the cleanup parameter
 @since v0.7.1
 */
-(void) removeChildByTag:(NSInteger) tag cleanup:(BOOL)cleanup;

/** Removes all children from the container and do a cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
-(void) removeAllChildrenWithCleanup:(BOOL)cleanup;

// composition: GET
/** Gets a child from the container given its tag
 @return returns a CCNode object
 @since v0.7.1
 */
-(CCNode*) getChildByTag:(NSInteger) tag;

/** Reorders a child according to a new z value.
 * The child MUST be already added.
 */
-(void) reorderChild:(CCNode*)child z:(NSInteger)zOrder;

/** performance improvement, Sort the children array once before drawing, instead of every time when a child is added or reordered
 don't call this manually unless a child added needs to be removed in the same frame */
- (void) sortAllChildren;

/** Stops all running actions and schedulers
 @since v0.8
 */
-(void) cleanup;

// draw

/** Override this method to draw your own node.
 The following GL states will be enabled by default:
	- glEnableClientState(GL_VERTEX_ARRAY);
	- glEnableClientState(GL_COLOR_ARRAY);
	- glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	- glEnable(GL_TEXTURE_2D);
 
   AND YOU SHOULD NOT DISABLE THEM AFTER DRAWING YOUR NODE
 
 But if you enable any other GL state, you should disable it after drawing your node.
 */
-(void) draw;
/** recursive method that visit its children and draw them */
-(void) visit;

// transformations

/** performs OpenGL view-matrix transformation based on position, scale, rotation and other attributes. */
-(void) transform;

/** performs OpenGL view-matrix transformation of it's ancestors.
 Generally the ancestors are already transformed, but in certain cases (eg: attaching a FBO)
 it's necessary to transform the ancestors again.
 @since v0.7.2
 */
-(void) transformAncestors;

/** returns a "local" axis aligned bounding box of the node in points.
 The returned box is relative only to its parent.
 The returned box is in Points.
 
 @since v0.8.2
 */
- (CGRect) boundingBox;

/** returns a "local" axis aligned bounding box of the node in pixels.
 The returned box is relative only to its parent.
 The returned box is in Points.
 
 @since v0.99.5
 */
- (CGRect) boundingBoxInPixels;


// actions

/** Executes an action, and returns the action that is executed.
 The node becomes the action's target.
 @warning Starting from v0.8 actions don't retain their target anymore.
 @since v0.7.1
 @return An Action pointer
 */
-(CCAction*) runAction: (CCAction*) action;
/** Removes all actions from the running action list */
-(void) stopAllActions;
/** Removes an action from the running action list */
-(void) stopAction: (CCAction*) action;
/** Removes an action from the running action list given its tag
 @since v0.7.1
*/
-(void) stopActionByTag:(NSInteger) tag;
/** Gets an action from the running action list given its tag
 @since v0.7.1
 @return the Action the with the given tag
 */
-(CCAction*) getActionByTag:(NSInteger) tag;
/** Returns the numbers of actions that are running plus the ones that are schedule to run (actions in actionsToAdd and actions arrays). 
 * Composable actions are counted as 1 action. Example:
 *    If you are running 1 Sequence of 7 actions, it will return 1.
 *    If you are running 7 Sequences of 2 actions, it will return 7.
 */
-(NSUInteger) numberOfRunningActions;

// timers

/** check whether a selector is scheduled. */
//-(BOOL) isScheduled: (SEL) selector;

/** schedules the "update" method. It will use the order number 0. This method will be called every frame.
 Scheduled methods with a lower order value will be called before the ones that have a higher order value.
 Only one "udpate" method could be scheduled per node.
 
 @since v0.99.3
 */
-(void) scheduleUpdate;

/** schedules the "update" selector with a custom priority. This selector will be called every frame.
 Scheduled selectors with a lower priority will be called before the ones that have a higher value.
 Only one "udpate" selector could be scheduled per node (You can't have 2 'update' selectors).

 @since v0.99.3
 */
-(void) scheduleUpdateWithPriority:(NSInteger)priority;

/* unschedules the "update" method.
 
 @since v0.99.3
 */
-(void) unscheduleUpdate;


/** schedules a selector.
 The scheduled selector will be ticked every frame
 */
-(void) schedule: (SEL) s;
/** schedules a custom selector with an interval time in seconds.
 If time is 0 it will be ticked every frame.
 If time is 0, it is recommended to use 'scheduleUpdate' instead.
 
 If the selector is already scheduled, then the interval parameter will be updated without scheduling it again.
 */
-(void) schedule: (SEL) s interval:(ccTime)seconds;
/** unschedules a custom selector.*/
-(void) unschedule: (SEL) s;

/** unschedule all scheduled selectors: custom selectors, and the 'update' selector.
 Actions are not affected by this method.
@since v0.99.3
 */
-(void) unscheduleAllSelectors;

/** resumes all scheduled selectors and actions.
 Called internally by onEnter
 */
-(void) resumeSchedulerAndActions;
/** pauses all scheduled selectors and actions.
 Called internally by onExit
 */
-(void) pauseSchedulerAndActions;


// transformation methods

/** Returns the matrix that transform the node's (local) space coordinates into the parent's space coordinates.
 The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)nodeToParentTransform;
/** Returns the matrix that transform parent's space coordinates to the node's (local) space coordinates.
 The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)parentToNodeTransform;
/** Retrusn the world affine transform matrix. The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)nodeToWorldTransform;
/** Returns the inverse world affine transform matrix. The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)worldToNodeTransform;
/** Converts a Point to node (local) space coordinates. The result is in Points.
 @since v0.7.1
 */
- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint;
/** Converts a Point to world space coordinates. The result is in Points.
 @since v0.7.1
 */
- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint;
/** Converts a Point to node (local) space coordinates. The result is in Points.
 treating the returned/received node point as anchor relative.
 @since v0.7.1
 */
- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint;
/** Converts a local Point to world space coordinates.The result is in Points.
 treating the returned/received node point as anchor relative.
 @since v0.7.1
 */
- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
/** Converts a UITouch to node (local) space coordinates. The result is in Points.
 @since v0.7.1
 */
- (CGPoint)convertTouchToNodeSpace:(UITouch *)touch;
/** Converts a UITouch to node (local) space coordinates. The result is in Points.
 This method is AR (Anchor Relative)..
 @since v0.7.1
 */
- (CGPoint)convertTouchToNodeSpaceAR:(UITouch *)touch;
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
@end
