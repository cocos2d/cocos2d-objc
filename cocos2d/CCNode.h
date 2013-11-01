/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Lars Birkemose
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

#import "Platforms/CCGL.h"
#import "ccTypes.h"
#import "CCProtocols.h"
#import "ccConfig.h"
#import "ccGLStateCache.h"
#import "kazmath/kazmath.h"
#import "CCResponder.h"
#import "CCScheduler.h"

@class CCScene;
@class CCGLProgram;
@class CCScheduler;
@class CCActionManager;
@class CCAction;
@class CCPhysicsBody;

/** CCNode is the base class for all objects displayed by Cocos2d. The nodes are hierachically organized in a tree, normally with a CCScene as its root node. Example of CCNode:s are CCSprite, CCScene and CCButton. The CCNode handles transformations, can have a content size and provides a coordinate system to its children. Any CCNode or subclass can handle user interaction, such as touches and mouse events, see the CCResponder for more information on this.
 
 ### Coordinate System and Positioning
 
 Coordinates in the CCNode coordinate system are by default set in points by the position property. The point measurement provides a way to handle different screen densities. For instance, on a retina display one point corresponds to two pixels, but on non-retina devices one point corresponds directly to one pixel.
 
 By using the positionType property you can specify how a node's position is interpreted. For instance, if you set the type to CCPositionTypeNormalized a position value of (0.5, 0.5) will place the node in the center of its parent's container. The container is specified by the parent's contentSize. It's also possible to set positions relative to the different corners of the parent's container. The CCPositionType has three components, xUnit, yUnit and corner. The corner can be any reference corner of the parent's container and the xUnit and yUnit can be any of the following:
 
 - CCPositionUnitPoints - This is the default, the position value will be in points.
 - CCPositionUnitScaled - The position is scaled by the positionScaleFactor as defined by CCDirector. This is very useful for scaling up game play without changing the game logic. E.g. if you want to support both phones and tablets in native resolutions.
 - CCPositionUnitNormalized - Using the normalized type allows you to position object in relative to the parents container. E.g. it can be used to center nodes on the screen regardless of the device type your game is running on.
 
 Similarily to how you set a node's position and positionType you can also set it's contentSize and contentSizeType. However, some classes doesn't allow you to set these directly. For instance, the CCSprite sets its contentSize depending on the size of its texture and for descendants of CCControl you should set the preferredSize and preferredSizeType rather than changing their contentSize directly. The CCSizeType has two components widthUnit and heightUnit which can be any of the following:
 
 - CCSizeUnitPoints - This is the default, the size will be in points
 - CCSizeUnitScaled - The size is scaled by the positionScaleFactor.
 - CCSizeUnitNormalized - The content size will be set as a normalized value of the parent's container.
 - CCSizeUnitInset - The content size will be the size of it's parent container, but inset by a number of points.
 - CCSizeUnitInsetScaled - The content size will be the size of it's parent container, but inset by a number of points multiplied by the positionScaleFactor.
 
 Even if the positions and content sizes are not set in points you can use actions to animate the nodes. See the examples and tests for more information on how to set positions and content sizes, or use SpriteBuilder to easily play around with the settings. There are also more positioning options available by using CCLayout and CCLayoutBox.

### Subclassing Notes
 
A common user pattern in building a Cocos2d game is to subclass CCNode, add it to a CCScene and override the methods for handling user input.
 */
@interface CCNode : CCResponder < CCSchedulerTarget > {
	// rotation angle
	float _rotationalSkewX, _rotationalSkewY;

	// scaling factors
	float _scaleX, _scaleY;

	// openGL real Z vertex
	float _vertexZ;

	// position of the node
	CGPoint _position;

	// skew angles
	float _skewX, _skewY;

	// anchor point in points
	CGPoint _anchorPointInPoints;
	// anchor point normalized (NOT in points)
	CGPoint _anchorPoint;

	// untransformed size of the node
	CGSize	_contentSize;

	// transform
	CGAffineTransform _transform, _inverse;
	BOOL _isTransformDirty;
	BOOL _isInverseDirty;

	// z-order value
	NSInteger _zOrder;

	// array of children
	NSMutableArray *_children;

	// weak ref to parent
	CCNode *__unsafe_unretained _parent;

	// a tag. any number you want to assign to the node
	//NSInteger _tag;
    NSString* _name;

	// user data field
	id _userObject;

	// Shader
	CCGLProgram	*_shaderProgram;

	// Server side state
	ccGLServerState _glServerState;

	// used to preserve sequence while sorting children with the same zOrder
	NSUInteger _orderOfArrival;

	// scheduler used to schedule timers and updates
	CCScheduler		*_scheduler;

	// ActionManager used to handle all the actions
	CCActionManager	*_actionManager;
	
	// YES if the node is added to an active scene.
	BOOL _isInActiveScene;
	
	BOOL _paused;
	
	// Number of paused parent or ancestor nodes.
	int _pausedAncestors;
	
	// is visible
	BOOL _visible;

	BOOL _isReorderChildDirty;
    
    CCPhysicsBody* _physicsBody;
}

/// -----------------------------------------------------------------------
/// @name Creating Nodes
/// -----------------------------------------------------------------------

/** Allocates and initializes a node.
 The node will be created as "autorelease".
 */
+(id) node;

/** Initializes the node */
-(id) init;

/// -----------------------------------------------------------------------
/// @name Pausing and Hiding
/// -----------------------------------------------------------------------

/** If paused, no callbacks will be called, and no actions will be run. */
@property(nonatomic, assign) BOOL paused;

/** Whether of not the node is visible. Default is YES */
@property( nonatomic,readwrite,assign) BOOL visible;

/// -----------------------------------------------------------------------
/// @name Tagging and Setting User Object
/// -----------------------------------------------------------------------

/** A tag used to identify the node easily */
//@property(nonatomic,readwrite,assign) NSInteger tag;
@property(nonatomic,strong) NSString* name;

/** Similar to userData, but instead of holding a void* it holds an id */
@property(nonatomic,readwrite,strong) id userObject;

/// -----------------------------------------------------------------------
/// @name Position and Size
/// -----------------------------------------------------------------------

/** Position (x,y) of the node in the unit specified by the positionType property. The distance is measured from one of the corners of the node's parent container, which corner is specified by the positionType property. Default setting is referencing the bottom left corner in points. */
@property(nonatomic,readwrite,assign) CGPoint position;

/** Position (x,y) of the node in points from the bottom left corner */
@property(nonatomic,readonly) CGPoint positionInPoints;

/** Defines the position type used for the X component of the position property */
@property(nonatomic,readwrite,assign) CCPositionType positionType;

/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node CW. */
@property(nonatomic,readwrite,assign) float rotation;

/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node CW. It only modifies the X rotation performing a horizontal rotational skew . */
@property(nonatomic,readwrite,assign) float rotationalSkewX;

/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node CW. It only modifies the Y rotation performing a vertical rotational skew . */
@property(nonatomic,readwrite,assign) float rotationalSkewY;

/** The scale factor of the node. 1.0 is the default scale factor. It modifies the X and Y scale at the same time. */
@property(nonatomic,readwrite,assign) float scale;

/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the X scale factor. */
@property(nonatomic,readwrite,assign) float scaleX;

/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the Y scale factor. */
@property(nonatomic,readwrite,assign) float scaleY;

@property (nonatomic,readonly) float scaleInPoints;
@property (nonatomic,readonly) float scaleXInPoints;
@property (nonatomic,readonly) float scaleYInPoints;

@property (nonatomic,assign) CCScaleType scaleType;

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

/** The untransformed size of the node in the unit specified by contentSizeType property. The contentSize remains the same no matter the node is scaled or rotated.
 @since v0.8
 */
@property (nonatomic,readwrite,assign) CGSize contentSize;

/** The untransformed size of the node in Points. The contentSize remains the same no matter the node is scaled or rotated. */
@property (nonatomic,readonly) CGSize contentSizeInPoints;

/** Defines the contentSize type used for the widht and height component of the contentSize property. */
@property (nonatomic,readwrite,assign) CCContentSizeType contentSizeType;

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
@property(nonatomic,readonly) CGPoint anchorPointInPoints;

/** returns a "local" axis aligned bounding box of the node in points.
 The returned box is relative only to its parent.
 The returned box is in Points.
 
 @since v0.8.2
 */
- (CGRect) boundingBox;

/// -----------------------------------------------------------------------
/// @name Adding, Removing and Sorting Children
/// -----------------------------------------------------------------------

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
-(void) addChild: (CCNode*)node z:(NSInteger)z name:(NSString*)name;

/** Remove itself from its parent node forcing a cleanup.
 If the node orphan, then nothing happens.
 @since v2.1
 */
-(void) removeFromParent;

/** Remove itself from its parent node. If cleanup is YES, then also remove all actions and callbacks.
 If the node orphan, then nothing happens.
 @since v0.99.3
 */
-(void) removeFromParentAndCleanup:(BOOL)cleanup;

/** Removes a child from the container forcing a cleanup
 @since v2.1
 */
-(void) removeChild:(CCNode*)child;

/** Removes a child from the container. It will also cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
-(void) removeChild: (CCNode*)node cleanup:(BOOL)cleanup;

/** Removes a child from the container by tag value forcing a cleanup.
 @since v2.1
 */
-(void) removeChildByName:(NSString*)name;

/** Removes a child from the container by tag value. It will also cleanup all running actions depending on the cleanup parameter
 @since v0.7.1
 */
-(void) removeChildByName:(NSString*)name cleanup:(BOOL)cleanup;

/** Removes all children from the container forcing a cleanup.
 @since v2.1
 */
-(void) removeAllChildren;

/** Removes all children from the container and do a cleanup all running actions depending on the cleanup parameter.
 @since v0.7.1
 */
-(void) removeAllChildrenWithCleanup:(BOOL)cleanup;

/** A weak reference to the parent */
@property(nonatomic,readwrite,unsafe_unretained) CCNode* parent;

/** Array of children */
@property(nonatomic,readonly) NSArray *children;

/** Gets a child from the container given its tag
 @return returns a CCNode object
 @since v0.7.1
 */
-(CCNode*) getChildByName:(NSString*) name;

/** The z order of the node relative to its "siblings": children of the same parent */
@property(nonatomic,assign) NSInteger zOrder;

/// -----------------------------------------------------------------------
/// @name Hit tests
/// -----------------------------------------------------------------------

/** check if a touch is inside the node
 to expand or shrink the touch area of a node, override this method
 @since v3.0
 */
- (BOOL)hitTestWithWorldPos:(CGPoint)pos;

/** Expands ( or contracts ) the hit area of the node, value is in points.
 @since v3.0
 */
@property (nonatomic, assign) float hitAreaExpansion;

/// -----------------------------------------------------------------------
/// @name Scene Management
/// -----------------------------------------------------------------------

/** Event that is called every time the CCNode enters the 'stage'.
 If the CCNode enters the 'stage' with a transition, this event is called when the transition starts.
 During onEnter you can't access a sibling node.
 If you override onEnter, you shall call [super onEnter].
 */
-(void) onEnter;

/** Event that is called when the CCNode enters in the 'stage'.
 If the CCNode enters the 'stage' with a transition, this event is called when the transition finishes.
 If you override onEnterTransitionDidFinish, you shall call [super onEnterTransitionDidFinish].
 @since v0.8
 */
-(void) onEnterTransitionDidFinish;

/** Event that is called every time the CCNode leaves the 'stage'.
 If the CCNode leaves the 'stage' with a transition, this event is called when the transition finishes.
 During onExit you can't access a sibling node.
 If you override onExit, you shall call [super onExit].
 */
-(void) onExit;

/** callback that is called every time the CCNode leaves the 'stage'.
 If the CCNode leaves the 'stage' with a transition, this callback is called when the transition starts.
 */
-(void) onExitTransitionDidStart;

/** The scene this node is added to, or nil if it's not part of a scene. */
@property(nonatomic, readonly) CCScene *scene;

/** Returns YES if the node is added to an active scene and neither it nor any of it's ancestors is paused. */
@property(nonatomic,readonly,getter=isRunningInActiveScene) BOOL runningInActiveScene;

/// -----------------------------------------------------------------------
/// @name Physics
/// -----------------------------------------------------------------------

/** The physics body (if any) that this node is attached to. */
@property(nonatomic, strong) CCPhysicsBody *physicsBody;

/// -----------------------------------------------------------------------
/// @name Actions
/// -----------------------------------------------------------------------

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

/// -----------------------------------------------------------------------
/// @name Scheduling Repeating Callbacks
/// -----------------------------------------------------------------------

-(CCTimer *) scheduleBlock:(CCTimerBlock)block delay:(CCTime)delay;

/** schedules a custom selector with an interval time in seconds.
 If time is 0 it will be ticked every frame.
 If time is 0, it is recommended to use 'scheduleUpdate' instead.
 
 If the selector is already scheduled, then the interval parameter will be updated without scheduling it again.
 */
-(CCTimer *) schedule: (SEL) s interval:(CCTime)seconds;

/**
 repeat will execute the action repeat + 1 times, for a continues action use kCCRepeatForever
 delay is the amount of time the action will wait before execution
 */
-(CCTimer *) schedule:(SEL)selector interval:(CCTime)interval repeat: (uint) repeat delay:(CCTime) delay;

/**
 Schedules a selector that runs only once, with a delay of 0 or larger
 */
- (CCTimer *) scheduleOnce:(SEL) selector delay:(CCTime) delay;

-(void)unschedule:(SEL)selector;

-(void)unscheduleAllSelectors;

/// -----------------------------------------------------------------------
/// @name Accessing Transformations and Matrices
/// -----------------------------------------------------------------------

/** performs OpenGL view-matrix transformation based on position, scale, rotation and other attributes. */
-(void) transform;

/** Returns the matrix that transform the node's (local) space coordinates into the parent's space coordinates.
 The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)nodeToParentTransform;

- (CGPoint) convertPositionToPoints:(CGPoint)position type:(CCPositionType)type;
- (CGPoint) convertPositionFromPoints:(CGPoint)positionInPoints type:(CCPositionType) type;

- (CGSize) convertContentSizeToPoints:(CGSize)contentSize type:(CCContentSizeType) type;
- (CGSize) convertContentSizeFromPoints:(CGSize)pointSize type:(CCContentSizeType) type;

/** Returns the matrix that transform parent's space coordinates to the node's (local) space coordinates.
 The matrix is in Pixels.
 @since v0.7.1
 */
- (CGAffineTransform)parentToNodeTransform;

/** Returns the world affine transform matrix. The matrix is in Pixels.
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

/// -----------------------------------------------------------------------
/// @name Rendering (Used by Subclasses)
/// -----------------------------------------------------------------------

/** Override this method to draw your own node.
 You should use cocos2d's GL API to enable/disable the GL state / shaders.
 For further info, please see ccGLstate.h.
 You shall NOT call [super draw];
 */
-(void) draw;

/** recursive method that visit its children and draw them */
-(void) visit;

@end


#pragma mark - CCNodeRGBA

/** CCNodeRGBA is a subclass of CCNode that implements the CCRGBAProtocol protocol.

 All features from CCNode are valid, plus the following new features:
 - opacity
 - RGB colors

 Opacity/Color propagates into children that conform to the CCRGBAProtocol if cascadeOpacity/cascadeColor is enabled.
 @since v2.1
 */
@interface CCNodeRGBA : CCNode <CCRGBAProtocol>
{
	GLubyte		_displayedOpacity, _realOpacity;
	ccColor3B	_displayedColor, _realColor;
	BOOL		_cascadeColorEnabled, _cascadeOpacityEnabled;
}

// XXX To make BridgeSupport happy
-(GLubyte) opacity;

@end
