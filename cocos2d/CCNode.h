/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <OpenGLES/ES1/gl.h>

#import "CCAction.h"
#import "ccTypes.h"
#import "CCTexture2D.h"

enum {
	kCCNodeTagInvalid = -1,
};

@class CCCamera;
@class CCGridBase;

/** CCNode is the main element. Anything thats gets drawn or contains things that get drawn is a CCNode.
 The most popular CCNodes are: CCScene, CCLayer, CCSprite, CCMenu.
 
 The main features of a CCNode are:
 - They can contain other CCnode nodes (addChild, getChildByTag, removeChild, etc)
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
 - rotation (in degrees)
 - Camera ( using spherical coordinates )
 - GridBase (to do mesh transformations)
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
 */ 
@interface CCNode : NSObject {
	
	// rotation angle
	float rotation_;	
	
	// scaling factors
	float scaleX_, scaleY_;
	
	// position of the node
	CGPoint position_;
	
	// If YES the transformtions will be relative to (-transform.x, -transform.y).
	// Sprites, Labels and any other "small" object uses it.
	// Scenes, Layers and other "whole screen" object don't use it.
	BOOL relativeAnchorPoint_;
	
	// anchor point in pixels
	CGPoint anchorPointInPixels_;	
	// anchor point normalized
	CGPoint anchorPoint_;
	
	// untransformed size of the node
	CGSize	contentSize_;
	
	CGAffineTransform transform_, inverse_;
	BOOL isTransformDirty_, isInverseDirty_;
	
	// openGL real Z vertex
	float vertexZ_;
	
	// is visible
	BOOL visible;
	
	// a Camera
	CCCamera *camera;
	
	// a Grid
	CCGridBase *grid;
	
	// z-order value
	int zOrder;
	
	// array of children
	NSMutableArray *children;
	
	// is running
	BOOL isRunning;
	
	// weakref to parent
	CCNode *parent;
	
	// a tag. any number you want to assign to the node
	int tag;

	// scheduled selectors
	NSMutableDictionary *scheduledSelectors;
    
	// user data field
	void *userData;
}

/** The z order of the node relative to it's "brothers": children of the same parent */
@property(nonatomic,readonly) int zOrder;
/** The real openGL Z vertex.
 Differences between openGL Z vertex and cocos2d Z order:
   - OpenGL Z modifies the Z vertex, and not the Z order in the relation between parent-children
   - OpenGL Z might require to set 2D projection
   - cocos2d Z order works OK if all the nodes uses the same openGL Z vertex. eg: vertexZ = 0
 @warning: Use it at your own risk since it might break the cocos2d parent-children z order
 @since v0.8
 */
@property (nonatomic,readwrite) float vertexZ;
/** The rotation (angle) of the node in degrees. 0 is the default rotation angle */
@property(nonatomic,readwrite,assign) float rotation;
/** The scale factor of the node. 1.0 is the default scale factor. It modifies the X and Y scale at the same time */
@property(nonatomic,readwrite,assign) float scale;
/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the X scale factor. */
@property(nonatomic,readwrite,assign) float scaleX;
/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the Y scale factor. */
@property(nonatomic,readwrite,assign) float scaleY;
/** Position (x,y) of the node in OpenGL coordinates. (0,0) is the left-bottom corner */
@property(nonatomic,readwrite,assign) CGPoint position;
/** A Camera object that lets you move the node using camera coordinates.
 * If you use the Camera then position, scale & rotation won't be used */
@property(nonatomic,readonly) CCCamera* camera;
/** A Grid object that is used when applying Effects */
@property(nonatomic,readwrite,retain) CCGridBase* grid;
/** Whether of not the node is visible. Default is YES */
@property(nonatomic,readwrite,assign) BOOL visible;
/** anchorPoint is the point around which all transformations and positioning manipulations take place.
 It's like a pin in the node where it is "attached" to its parent.
 The anchorPoint is normalized, like a percentage. (0,0) means the bottom-left corner and (1,1) means the top-right corner.
 But you can use values higher than (1,1) and lower than (0,0) too.
 The default anchorPoint is (0.5,0.5), so it starts in the center of the node.
 @since v0.8
 */
@property(nonatomic,readwrite) CGPoint anchorPoint;
/** The anchorPoint in absolute pixels.
 Since v0.8 you can only read it. If you wish to modify it, use anchorPoint instead
 */
@property(nonatomic,readonly) CGPoint anchorPointInPixels;

/** The untransformed size of the node.
 The contentSize remains the same no matter the node is scaled or rotated.
 All nodes has a size. Layer and Scene has the same size of the screen.
 @since v0.8
 */
@property (nonatomic,readwrite) CGSize contentSize;
/** A weak reference to the parent */
@property(nonatomic,readwrite,assign) CCNode* parent;
/** If YES the transformtions will be relative to it's anchor point.
 * Sprites, Labels and any other sizeble object use it have it enabled by default.
 * Scenes, Layers and other "whole screen" object don't use it, have it disabled by default.
 */
@property(nonatomic,readwrite,assign) BOOL relativeAnchorPoint;
/** A tag used to identify the node easily */
@property(nonatomic,readwrite,assign) int tag;
/** A custom user data pointer */
@property(nonatomic,readwrite,assign) void *userData;

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
 During onExit you can't a "sister/brother" node.
 */
-(void) onExit;


// composition: ADD

/** Adds a child to the container with z-order as 0.
 It returns self, so you can chain several addChilds.
 @since v0.7.1
 */
-(id) addChild: (CCNode*)node;

/** Adds a child to the container with a z-order
 It returns self, so you can chain several addChilds.
 @since v0.7.1
 */
-(id) addChild: (CCNode*)node z:(int)z;

/** Adds a child to the container with z order and tag
 It returns self, so you can chain several addChilds.
 @since v0.7.1
 */
-(id) addChild: (CCNode*)node z:(int)z tag:(int)tag;

// composition: REMOVE

/** Removes a child from the container. It will also cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
-(void) removeChild: (CCNode*)node cleanup:(BOOL)cleanup;

/** Removes a child from the container by tag value. It will also cleanup all running actions depending on the cleanup parameter
 @since v0.7.1
 */
-(void) removeChildByTag:(int) tag cleanup:(BOOL)cleanup;

/** Removes all children from the container and do a cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
-(void) removeAllChildrenWithCleanup:(BOOL)cleanup;

// composition: GET
/** Gets a child from the container given its tag
 @return returns a CCNode object
 @since v0.7.1
 */
-(CCNode*) getChildByTag:(int) tag;

/** Returns the array that contains all the children */
- (NSArray *)children;

/** Reorders a child according to a new z value.
 * The child MUST be already added.
 */
-(void) reorderChild:(CCNode*)child z:(int)zOrder;

/** Stops all running actions and schedulers
 @since v0.8
 */
-(void) cleanup;

// draw

/** override this method to draw your own node. */
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

/** returns an axis aligned bounding box of the node.
 It takes into account any kind of transformation.
 
 @since v0.8.2
 */
- (CGRect) boundingBox;


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
-(void) stopActionByTag:(int) tag;
/** Gets an action from the running action list given its tag
 @since v0.7.1
 @return the Action the with the given tag
 */
-(CCAction*) getActionByTag:(int) tag;
/** Returns the numbers of actions that are running plus the ones that are schedule to run (actions in actionsToAdd and actions arrays). 
 * Composable actions are counted as 1 action. Example:
 *    If you are running 1 Sequence of 7 actions, it will return 1.
 *    If you are running 7 Sequences of 2 actions, it will return 7.
 */
-(int) numberOfRunningActions;

// timers

/** check whether a selector is scheduled. */
//-(BOOL) isScheduled: (SEL) selector;

/** schedules a selector.
 The scheduled selector will be ticked every frame
 */
-(void) schedule: (SEL) s;
/** schedules a selector with an interval time in seconds.
 If time is 0 it will be ticked every frame.
 */
-(void) schedule: (SEL) s interval:(ccTime)seconds;
/** schedules a selector.
 The scheduled selector will be ticked every frame, repeating a limited number of times
 */
-(void) schedule: (SEL) s repeat:(int)times;
/** schedules a selector with an interval time in seconds.
 If time is 0 it will be ticked every frame.
 In either case, repeating a limited number of times
 */
-(void) schedule: (SEL) s interval:(ccTime)seconds repeat:(int)times;
/** unschedule a selector */
-(void) unschedule: (SEL) s;
/** activate all scheduled timers.
 Called internally by onEnter
 */
-(void) activateTimers;
/** deactivate all scheduled timers.
 Called internally by onExit
 */
-(void) deactivateTimers;

// transformation methods

/** actual affine transforms used
 @todo nodeToParentTransform needs documentation
 @since v0.7.1
 */
- (CGAffineTransform)nodeToParentTransform;
/** @todo parentToNodeTransform needs documentation
 @since v0.7.1
 */
- (CGAffineTransform)parentToNodeTransform;
/** @todo nodeToWorldTransform needs documentation
 @since v0.7.1
 */
- (CGAffineTransform)nodeToWorldTransform;
/** @todo worldToNodeTransform needs documentation
 @since v0.7.1
 */
- (CGAffineTransform)worldToNodeTransform;
/** converts a world coordinate to local coordinate
 @since v0.7.1
 */
- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint;
/** converts local coordinate to world space
 @since v0.7.1
 */
- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint;
/** converts a world coordinate to local coordinate
 treating the returned/received node point as anchor relative
 @since v0.7.1
 */
- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint;
/** converts local coordinate to world space
 treating the returned/received node point as anchor relative
 @since v0.7.1
 */
- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint;
/** convenience methods which take a UITouch instead of CGPoint
 @todo convertTouchToNodeSpace needs documentation
 @since v0.7.1
 */
- (CGPoint)convertTouchToNodeSpace:(UITouch *)touch;
/** @todo convertTouchToNodeSpaceAR needs documentation
 @since v0.7.1
 */
- (CGPoint)convertTouchToNodeSpaceAR:(UITouch *)touch;
@end
