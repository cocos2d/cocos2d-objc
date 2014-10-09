/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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
 */

#import "Platforms/CCGL.h"
#import "ccTypes.h"
#import "CCProtocols.h"
#import "ccConfig.h"
#import "CCResponder.h"
#import "CCScheduler.h"
#import "CCRenderer.h"


@class CCScene;
@class CCShader;
@class CCScheduler;
@class CCActionManager;
@class CCAction;
@class CCPhysicsBody;
@class CCBAnimationManager;
@class CCAnimationManager;

/** CCNode is the base class for all objects displayed by Cocos2d. The nodes are hierachically organized in a tree, normally with a CCScene as its root node. Example of CCNode:s are CCSprite, CCScene and CCButton. The CCNode handles transformations, can have a content size and provides a coordinate system to its children. Any CCNode or subclass can handle user interaction, such as touches and mouse events, see the CCResponder for more information on this.
 
 ### Coordinate System and Positioning
 
 Coordinates in the CCNode coordinate system are by default set in points by the position property. The point measurement provides a way to handle different screen densities. For instance, on a retina display one point corresponds to two pixels, but on non-retina devices one point corresponds directly to one pixel.
 
 By using the positionType property you can specify how a node's position is interpreted. For instance, if you set the type to CCPositionTypeNormalized a position value of (0.5, 0.5) will place the node in the center of its parent's container. The container is specified by the parent's contentSize. It's also possible to set positions relative to the different corners of the parent's container. The CCPositionType has three components, xUnit, yUnit and corner. The corner can be any reference corner of the parent's container and the xUnit and yUnit can be any of the following:
 
 - CCPositionUnitPoints - This is the default, the position value will be in points.
 - CCPositionUnitScaled - The position is scaled by the UIScaleFactor as defined by CCDirector. This is very useful for scaling up game play without changing the game logic. E.g. if you want to support both phones and tablets in native resolutions.
 - CCPositionUnitNormalized - Using the normalized type allows you to position object in relative to the parents container. E.g. it can be used to center nodes on the screen regardless of the device type your game is running on.
 
 Similarily to how you set a node's position and positionType you can also set it's contentSize and contentSizeType. However, some classes doesn't allow you to set these directly. For instance, the CCSprite sets its contentSize depending on the size of its texture and for descendants of CCControl you should set the preferredSize and preferredSizeType rather than changing their contentSize directly. The CCSizeType has two components widthUnit and heightUnit which can be any of the following:
 
 - CCSizeUnitPoints - This is the default, the size will be in points
 - CCSizeUnitScaled - The size is scaled by the UIScaleFactor.
 - CCSizeUnitNormalized - The content size will be set as a normalized value of the parent's container.
 - CCSizeUnitInset - The content size will be the size of it's parent container, but inset by a number of points.
 - CCSizeUnitInsetScaled - The content size will be the size of it's parent container, but inset by a number of points multiplied by the UIScaleFactor.
 
 Even if the positions and content sizes are not set in points you can use actions to animate the nodes. See the examples and tests for more information on how to set positions and content sizes, or use SpriteBuilder to easily play around with the settings. There are also more positioning options available by using CCLayout and CCLayoutBox.

### Subclassing Notes
 
A common user pattern in building a Cocos2d game is to subclass CCNode, add it to a CCScene and override the methods for handling user input.
 */

@interface CCNode : CCResponder < CCSchedulerTarget > {
    
	// Rotation angle.
	float _rotationalSkewX, _rotationalSkewY;

	// Scaling factors.
	float _scaleX, _scaleY;

	// OpenGL real Z vertex.
	float _vertexZ;

	// Position of the node.
	CGPoint _position;

	// Skew angles.
	float _skewX, _skewY;

	// Anchor point in points.
	CGPoint _anchorPointInPoints;
    
	// Anchor point normalized (NOT in points).
	CGPoint _anchorPoint;

	// Untransformed size of the node.
	CGSize	_contentSize;

	// Transform.
	CGAffineTransform _transform, _inverse;

	BOOL _isTransformDirty;
	BOOL _isInverseDirty;

	// Z-order value.
	NSInteger _zOrder;

	// Array of children.
	NSMutableArray *_children;

	// Weak ref to parent.
	__weak CCNode *_parent;

	// A tag any name you want to assign to the node
    NSString* _name;

	// User data field.
	id _userObject;

	// Used to preserve sequence while sorting children with the same zOrder.
	NSUInteger _orderOfArrival;
	
	// True when visible.
	BOOL _visible;

    // True to ensure reorder.
	BOOL _isReorderChildDirty;
	
	// DisplayColor and Color are kept separate to allow for cascading color and alpha changes through node children.
	// Alphas tend to be multiplied together so you can fade groups of objects that are colored differently.
	ccColor4F	_displayColor, _color;

	// Opacity/Color propagates into children that conform to if cascadeOpacity/cascadeColor is enabled.
	BOOL		_cascadeColorEnabled, _cascadeOpacityEnabled;
	
@private
	// Physics Body.
	CCPhysicsBody* _physicsBody;
	
	// Scheduler used to schedule timers and updates/
	CCScheduler		*_scheduler;
	
	// ActionManager used to handle all the actions.
	CCActionManager	*_actionManager;
	
    //Animation Manager used to handle CCB animations
    CCAnimationManager * _animationManager;
	
	// YES if the node is added to an active scene.
	BOOL _isInActiveScene;
	
    // True if paused.
	BOOL _paused;
	
	// Number of paused parent or ancestor nodes.
	int _pausedAncestors;
}


/// -----------------------------------------------------------------------
/// @name Creating Nodes
/// -----------------------------------------------------------------------

/** Allocates and initializes a node. The node will be created as "autorelease". */
+(id) node;

/** Initializes the node. */
-(id) init;


/// -----------------------------------------------------------------------
/// @name Pausing and Hiding
/// -----------------------------------------------------------------------

/** If paused, no callbacks will be called, and no actions will be run. */
@property(nonatomic, assign) BOOL paused;

/** Whether of not the node is visible. Default is YES. */
@property( nonatomic,readwrite,assign) BOOL visible;


/// -----------------------------------------------------------------------
/// @name Tagging and Setting User Object
/// -----------------------------------------------------------------------

/** A name tag used to help identify the node easily. */
@property(nonatomic,strong) NSString* name;

/** Similar to userData, but instead of holding a void* it holds an id. */
@property(nonatomic,readwrite,strong) id userObject;


/// -----------------------------------------------------------------------
/// @name Position and Size
/// -----------------------------------------------------------------------

/** Position (x,y) of the node in the unit specified by the positionType property. The distance is measured from one of the corners of the node's parent container, which corner is specified by the positionType property. Default setting is referencing the bottom left corner in points. */
@property(nonatomic,readwrite,assign) CGPoint position;

/** Position (x,y) of the node in points from the bottom left corner. */
@property(nonatomic,readwrite,assign) CGPoint positionInPoints;

/** Defines the position type used for the position property. Changing the position type affects the meaning of the position, and allows you to change the referenceCorner, relative to the parent container. It allso allows changing from points to UIPoints. UIPoints are scaled by [CCDirector sharedDirector].UIScaleFactor. See "Coordinate System and Positioning" for more information. */
@property(nonatomic,readwrite,assign) CCPositionType positionType;

/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node CW. */
@property(nonatomic,readwrite,assign) float rotation;

/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node CW. It only modifies the X rotation performing a horizontal rotational skew. */
@property(nonatomic,readwrite,assign) float rotationalSkewX;

/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node CW. It only modifies the Y rotation performing a vertical rotational skew. */
@property(nonatomic,readwrite,assign) float rotationalSkewY;

/** The scale factor of the node. 1.0 is the default scale factor. It modifies the X and Y scale at the same time. */
@property(nonatomic,readwrite,assign) float scale;

/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the X scale factor. */
@property(nonatomic,readwrite,assign) float scaleX;

/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the Y scale factor. */
@property(nonatomic,readwrite,assign) float scaleY;

/** The scaleInPoints is the scale factor of the node in both X and Y, measured in points. The scaleType indicates if the scaleInPoints will be scaled byt the UIScaleFactor or not. See "Coordinate System and Positioning" for more information. */
@property (nonatomic,readonly) float scaleInPoints;

/** The scaleInPoints is the scale factor of the node in X, measured in points. */
@property (nonatomic,readonly) float scaleXInPoints;

/** The scaleInPoints is the scale factor of the node in Y, measured in points. */
@property (nonatomic,readonly) float scaleYInPoints;

/** The scaleType defines scale behavior for this node. CCScaleTypeScaled indicates that the node will be scaled by [CCDirector sharedDirector].UIScaleFactor. This property is analagous to positionType. ScaleType affects the scaleInPoints of a CCNode. See "Coordinate System and Positioning" for more information.
 */
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

/** The untransformed size of the node in the unit specified by contentSizeType property. The contentSize remains the same no matter the node is scaled or rotated. contentSize is relative to the node.
 */
@property (nonatomic,readwrite,assign) CGSize contentSize;

/** The untransformed size of the node in Points. The contentSize remains the same no matter the node is scaled or rotated. contentSizeInPoints is affected by the contentSizeType and will be scaled by the [CCDirector sharedDirector].UIScaleFactor if the type is CCSizeUnitUIPoints. */
@property (nonatomic,readwrite,assign) CGSize contentSizeInPoints;

/** Defines the contentSize type used for the widht and height component of the contentSize property. */
@property (nonatomic,readwrite,assign) CCSizeType contentSizeType;

/** The anchorPoint is the point around which all transformations and positioning manipulations take place.
 It's like a pin in the node where it is "attached" to its parent.
 The anchorPoint is normalized, like a percentage. (0,0) means the bottom-left corner and (1,1) means the top-right corner.
 But you can use values higher than (1,1) and lower than (0,0) too.
 The default anchorPoint is (0,0). It starts in the bottom-left corner. CCSprite and other subclasses have a different default anchorPoint.
 */
@property(nonatomic,readwrite) CGPoint anchorPoint;

/** The anchorPoint in absolute pixels.  Since v0.8 you can only read it. If you wish to modify it, use anchorPoint instead. */
@property(nonatomic,readonly) CGPoint anchorPointInPoints;

/**
 * Invoked automatically when the OS view has been resized.
 *
 * This implementation simply propagates the same method to the children.
 * Subclasses may override to actually do something when the view resizes.
 */
-(void) viewDidResizeTo: (CGSize) newViewSize;


/** Returns a "local" axis aligned bounding box of the node in points.
 The returned box is relative only to its parent.
 The returned box is in Points.
 */
- (CGRect) boundingBox;


/// -----------------------------------------------------------------------
/// @name Adding, Removing and Sorting Children
/// -----------------------------------------------------------------------

/**
 *  Adds a child to the container with z-order as 0.
 *  If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
 *
 *  @param node CCNode to add as a child.
 */
-(void) addChild: (CCNode*)node;

/**
 *  Adds a child to the container with a z-order.
 *  If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
 *
 *  @param node CCNode to add as a child.
 *  @param z    Z depth of node.
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z;

/**
 *  Adds a child to the container with z order and tag.
 *  If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
 *
 *  @param node CCNode to add as a child.
 *  @param z    Z depth of node.
 *  @param name name tag.
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z name:(NSString*)name;

/** 
 *  Remove itself from its parent node forcing a cleanup.
 *  If the node orphan, then nothing happens.
 */
-(void) removeFromParent;

/**
 *  Remove itself from its parent node. If cleanup is YES, then also remove all actions and callbacks.
 *  If the node orphan, then nothing happens.
 *
 *  @param cleanup Stops all scheduled events and actions.
 */
-(void) removeFromParentAndCleanup:(BOOL)cleanup;

/**
 *  Removes a child from the container forcing a cleanup. This method checks to ensure the parameter node is actually a child of this node.
 *
 *  @param child The child node to remove.
 */
-(void) removeChild:(CCNode*)child;

/**
 *  Removes a child from the container. It will also cleanup all running and scheduled actions depending on the cleanup parameter.
 *  This method checks to ensure the parameter node is actually a child of this node.
 *
 *  @param node    The child node to remove.
 *  @param cleanup Stops all scheduled events and actions.
 */
-(void) removeChild: (CCNode*)node cleanup:(BOOL)cleanup;

/**
 *  Removes a child from the container by name value forcing a cleanup.
 *
 *  @param name Name of node to be removed.
 */
-(void) removeChildByName:(NSString*)name;

/**
 *  Removes a child from the container by name value. It will also cleanup all running actions depending on the cleanup parameter
 *
 *  @param name    Name of node to be removed.
 *  @param cleanup Stops all scheduled events and actions.
 */
-(void) removeChildByName:(NSString*)name cleanup:(BOOL)cleanup;

/** 
 *  Removes all children from the container forcing a cleanup.
 */
-(void) removeAllChildren;

/**
 *  Removes all children from the container and do a cleanup all running actions depending on the cleanup parameter.
 *
 *  @param cleanup Stops all scheduled events and actions.
 */
-(void) removeAllChildrenWithCleanup:(BOOL)cleanup;

/** A weak reference to the parent. */
@property(nonatomic,readwrite,weak) CCNode* parent;

/** Array of child nodes. */
@property(nonatomic,readonly) NSArray *children;

/**
 *  Search through the children of the container for one matching the name tag.
 *  If recursive, it returns the first matching node, via a depth first search.
 *  Otherwise, only immediate children are checked.
 *
 *  @param name Name tag.
 *  @param isRecursive Search recursively through children of children.
 *
 *  @return Returns a CCNode, or nil if no marching nodes are found.
 */
-(CCNode*) getChildByName:(NSString *)name recursively:(bool)isRecursive;

/** The z order of the node relative to its "siblings": children of the same parent. */
@property(nonatomic,assign) NSInteger zOrder;

/// -----------------------------------------------------------------------
/// @name Scene Management
/// -----------------------------------------------------------------------

/** Event that is called every time the CCNode enters the 'stage'.
 If the CCNode enters the 'stage' with a transition, this event is called when the transition starts.
 During onEnter you can't access a sibling node.
 If you override onEnter, you shall call [super onEnter].
 */
-(void) onEnter __attribute__((objc_requires_super));

/** Event that is called when the CCNode enters in the 'stage'.
 If the CCNode enters the 'stage' with a transition, this event is called when the transition finishes.
 If you override onEnterTransitionDidFinish, you shall call [super onEnterTransitionDidFinish].
 */
-(void) onEnterTransitionDidFinish __attribute__((objc_requires_super));

/** Event that is called every time the CCNode leaves the 'stage'.
 If the CCNode leaves the 'stage' with a transition, this event is called when the transition finishes.
 During onExit you can't access a sibling node.
 If you override onExit, you shall call [super onExit].
 */
-(void) onExit __attribute__((objc_requires_super));

/** Callback that is called every time the CCNode leaves the 'stage'.
 If the CCNode leaves the 'stage' with a transition, this callback is called when the transition starts.
 */
-(void) onExitTransitionDidStart __attribute__((objc_requires_super));

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

/**
 *  Executes an action, and returns the action that is executed.
 *  The node becomes the action's target.
 *
 *  @param action Action to run.
 *
 *  @return An Action pointer
 */
-(CCAction*) runAction: (CCAction*) action;

/** Removes all actions from the running action list */
-(void) stopAllActions;

/**
 *  Removes an action from the running action list.
 *
 *  @param action Action to remove.
 */
-(void) stopAction: (CCAction*) action;

/**
 *  Removes an action from the running action list given its tag.
 *
 *  @param tag Tag to remove.
 */
-(void) stopActionByTag:(NSInteger) tag;

/**
 *  Gets an action from the running action list given its tag.
 *
 *  @param tag Tag to retrieve.
 *
 *  @return the Action the with the given tag.
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

/**
 *  Schedules a block to run once, after a certain delay.
 *
 *  @param block Block to execute.
 *  @param delay Delay in seconds.
 *
 *  @return A newly initialized CCTimer object.
 */
-(CCTimer *) scheduleBlock:(CCTimerBlock)block delay:(CCTime)delay;

/**
 *  Schedules a custom selector with an interval time in seconds.
 *  If time is 0 it will be ticked every frame. In that case, it is recommended to override update: in stead.
 *  If the selector is already scheduled, then the interval parameter will be updated without scheduling it again.
 *
 *  @param s       Selector to execute.
 *  @param seconds Interval between execution in seconds.
 *
 *  @return A newly initialized CCTimer object.
 */
-(CCTimer *) schedule: (SEL) s interval:(CCTime)seconds;

/**
 *  Schedules a custom selector with an interval time in seconds.
 *
 *  @param selector Selector to execute.
 *  @param interval Interval between execution in seconds.
 *  @param repeat   Number of times to repeat.
 *  @param delay    Initial delay in seconds.
 *
 *  @return A newly initialized CCTimer object.
 */
-(CCTimer *) schedule:(SEL)selector interval:(CCTime)interval repeat: (NSUInteger) repeat delay:(CCTime) delay;

/**
 *  Schedules a selector that runs only once, with a delay of 0 or larger.
 *
 *  @param selector Selector to execute.
 *  @param delay    Initial delay in seconds.
 *
 *  @return A newly initialized CCTimer object.
 */
 
 /**
 * Schedules a custom selector with an interval time in seconds.
 * If the custom selector you pass in is not already scheduled, this method simply schedules it for the first time.
 * The difference between this method and the schedule:interval: method is that if the selector passed in this method is already scheduled, calling this method will only adjust the interval on the already scheduled method. In contrast, when you call schedule:interval: on an already scheduled selector, your custom selector will be unscheduled and then rescheduled.
*  @param selector       Selector to execute.
*  @param interval Interval between execution in seconds.
 */
-(CCTimer*)reschedule:(SEL)selector interval:(CCTime)interval;
 
 
- (CCTimer *) scheduleOnce:(SEL) selector delay:(CCTime) delay;

/**
 *  Unschedule a scheduled selector.
 *
 *  @param selector Selector to unschedule.
 */
-(void)unschedule:(SEL)selector;

/**
 *  Unschedule all scheduled selectors.
 */
-(void)unscheduleAllSelectors;

/**
 *  Returns the CCB Animation Manager of this node, or that of its parent.
 */
@property (nonatomic, readonly) CCAnimationManager * animationManager;

/// -----------------------------------------------------------------------
/// @name Accessing Transformations and Matrices
/// -----------------------------------------------------------------------

/** Returns the matrix that transform the node's (local) space coordinates into the parent's space coordinates.
 The matrix is in Pixels.
 */
- (CGAffineTransform)nodeToParentTransform;

- (CGPoint) convertPositionToPoints:(CGPoint)position type:(CCPositionType)type;
- (CGPoint) convertPositionFromPoints:(CGPoint)positionInPoints type:(CCPositionType) type;

- (CGSize) convertContentSizeToPoints:(CGSize)contentSize type:(CCSizeType) type;
- (CGSize) convertContentSizeFromPoints:(CGSize)pointSize type:(CCSizeType) type;

/** Returns the matrix that transform parent's space coordinates to the node's (local) space coordinates. The matrix is in Pixels. */
- (CGAffineTransform)parentToNodeTransform;

/** Returns the world affine transform matrix. The matrix is in Pixels. */
- (CGAffineTransform)nodeToWorldTransform;

/** Returns the inverse world affine transform matrix. The matrix is in Pixels. */
- (CGAffineTransform)worldToNodeTransform;

/**
 *  Converts a Point to node (local) space coordinates. The result is in Points.
 *
 *  @param worldPoint World position in points.
 *
 *  @return Local position in points.
 */
- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint;

/**
 *  Converts a Point to world space coordinates. The result is in Points.
 *
 *  @param nodePoint Local position in points.
 *
 *  @return World position in points.
 */
- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint;

/**
 *  Converts a Point to node (local) space coordinates. The result is in Points.
 *  Treats the returned/received node point as anchor relative.
 *
 *  @param worldPoint World position in points.
 *
 *  @return Local position in points.
 */
- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint;

/**
 *  Converts a local Point to world space coordinates.The result is in Points.
 *  Treats the returned/received node point as anchor relative.
 *
 *  @param nodePoint Local position in points.
 *
 *  @return World position in points.
 */
- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint;

/**
 *  Converts a local Point to Window space coordinates.The result is in Points.
 *  Treats the returned/received node point as anchor relative.
 *
 *  @param nodePoint Local position in points.
 *
 *  @return UI position in points.
 */
- (CGPoint)convertToWindowSpace:(CGPoint)nodePoint;


/// -----------------------------------------------------------------------
/// @name Rendering (Used by Subclasses)
/// -----------------------------------------------------------------------

/** 
 * Override this method to draw your own node.
 * You should use cocos2d's GL API to enable/disable the GL state / shaders.
 * For further info, please see ccGLstate.h.
 * You shall NOT call [super draw];
 */
-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;

/** Calls visit:parentTransform using the current renderer and projection. */
-(void) visit;

/** Sets and returns the color (tint), alpha is ignored when setting. */
@property (nonatomic,strong) CCColor* color;

/** Sets and returns the color (tint) with alpha. */
@property (nonatomic,strong) CCColor* colorRGBA;

/** Returns the displayed color. */
@property (nonatomic, readonly) CCColor* displayedColor;

/**
 * CascadeColorEnabled causes changes to this node's color to cascade down to it's children. The new color is multiplied
 * in with the color of each child, so it doesn't bash the current color of those nodes. Opacity is unaffected by this
 * property, see cascadeOpacityEnabled to change the alpha of nodes.
 */
@property (nonatomic, getter = isCascadeColorEnabled) BOOL cascadeColorEnabled;

/**
 *  Recursive method that updates display color.
 *
 *  @param color Color used for update.
 */
- (void)updateDisplayedColor:(ccColor4F)color;

/** 
 *  Sets and returns the opacity.
 *  @warning If the the texture has premultiplied alpha then, the R, G and B channels will be modified.
 *  Values goes from 0 to 1, where 1 means fully opaque.
 */
@property (nonatomic) CGFloat opacity;

/** Returns the displayed opacity. */
@property (nonatomic, readonly) CGFloat displayedOpacity;

/** 
 *  CascadeOpacity causes changes to this node's opacity to cascade down to it's children. The new opacity is multiplied
 *  in with the opacity of each child, so it doesn't bash the current opacity of those nodes. Color is unaffected by this
 *  property, see cascadeColorEnabled for color tint changes.
 */
@property (nonatomic, getter = isCascadeOpacityEnabled) BOOL cascadeOpacityEnabled;

/**
 *  Recursive method that updates the displayed opacity.
 *
 *  @param opacity Opacity to use for update.
 */
- (void)updateDisplayedOpacity:(CGFloat)opacity;

/**
 *  Sets the premultipliedAlphaOpacity property.
 *
 *  If set to NO then opacity will be applied as: glColor(R,G,B,opacity);
 *
 *  If set to YES then opacity will be applied as: glColor(opacity, opacity, opacity, opacity );
 *
 *  Textures with premultiplied alpha will have this property by default on YES. Otherwise the default value is NO.
 *
 *  @param boolean Enables or disables setting of opacity with color.
 */
-(void) setOpacityModifyRGB:(BOOL)boolean __attribute__((deprecated));

/** Returns whether or not the opacity will be applied using glColor(R,G,B,opacity) or glColor(opacity, opacity, opacity, opacity).
 */
-(BOOL) doesOpacityModifyRGB __attribute__((deprecated));

@end


@interface CCNode(NoARC)

/** Returns the 4x4 drawing transformation for this node. Really only useful when overriding visit:parentTransform: */
-(GLKMatrix4)transform:(const GLKMatrix4 *)parentTransform;

/** Recursive method that visit its children and draw them. */
-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform;

@end

