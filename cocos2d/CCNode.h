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

/**
 CCNode is the base class for all objects displayed by Cocos2D. CCNode handles transformations, can have a content size and provides a coordinate system for its child nodes.
 
 ### Node Hierarchy
 
 Nodes are hierachically organized in a tree with a CCScene as its root node. This is often referred to as *scene graph*, *node hierarchy* or *node tree*.
 
 By default every node can have other nodes as child nodes. Some node classes restrict child nodes to a specific instance type, or don't allow child nodes at all.
 
 A child node is positioned and rotated relative to its parent. Some properties of the parent node are "inherited" by child nodes, for example: scale, visible, paused.
 Other properties are only "inherited" if enabled, see cascadeOpacityEnabled for example.
 
 ### Draw Order
 
 Draw order of nodes is controlled primarily by their order in the node hierarchy. The parent node is drawn first, followed by its child nodes in the order they were added.
 
 You can fine-tune draw order via the zOrder property. By default all nodes have a zOrder of 0. Nodes with lower zOrder are drawn before nodes with higher zOrder.
 This applies only to nodes in the same level (sibling nodes) and their parent node, as the zOrder is relative to the zOrder of the parent.
 
 Assuming you have two parent nodes A and B with zOrder 0 and they are drawn in the order A first, then B. Then all of the children of parent B will be drawn in front of any child node of parent A. If B's zOrder is changed to -1, then parent B and all of its children will be drawn behind parent A and its children.
 
 ### Scheduling Events / Timers
 
 Implementing a method with a signature of `-(void) update:(CCTime)delta` in a CCNode subclass will have that method run once every frame. `CCTime` is declared as `double`.
 
 If this doesn't suffice you can use the various schedule methods of a node, such as schedule:interval: or scheduleBlock:delay:. For example the following selector runs once every second:
 
    [self schedule:@selector(everySecond:) interval:1.0];
 
 The signature of scheduled selectors is always the same with a single CCTime parameter and no return value:
 
    -(void) everySecond:(CCTime)delta {
        NSLog(@"tic-toc ..");
    }
 
 <em>Warning:</em> Any non-Cocos2D scheduling methods will be unaffected by the node's paused state and may run in indeterminate order, possibly causing rendering glitches and timing bugs. It is therfore strongly discouraged to use NSTimer, `performSelector:afterDelay:` or Grand Central Disptach (GCD) `dispatch_xxx` methods to time/schedule tasks in Cocos2D.
 
 #### Pausing
 
 It is common practice to pause the topmost node of a layer whose contents you want to pause. For instance you should have a gameLayer node that you can use to pause the entire game, while the hudLayer and pauseMenuLayer nodes may not need to or shouldn't be paused in order to continue animations and allowing the user to interact with a pause menu.
 
 ### Input Handling
 
  Any CCNode or subclass can receive touch and mouse events, if enabled. See the CCResponder super class for more information.
 
 ### Position and Size Types
 
 Coordinates in the CCNode coordinate system are by default set in points by the position property. The point measurement provides a way to handle different screen pixel densities. For instance, on a Retina device one point corresponds to two pixels, but on non-Retina devices point and pixel resolution are identical.
 
 By using the positionType property you can specify how a node's position is interpreted. For instance, if you set the type to CCPositionTypeNormalized a  position value of (0.5, 0.5) will place the node in the center of its parent's container. The container is specified by the parent's contentSize.
 
 It's also possible to set positions relative to the different corners of the parent's container. The CCPositionType has three components, xUnit, yUnit and corner. 
 The corner can be any reference corner of the parent's container and the xUnit and yUnit can be any of the following:
 
 - CCPositionUnitPoints - This is the default, the position value will be in points.
 - CCPositionUnitScaled - The position is scaled by the UIScaleFactor as defined by CCDirector. This is very useful for scaling up game play without changing the game logic.
    E.g. if you want to support both phones and tablets in native resolutions.
 - CCPositionUnitNormalized - Using the normalized type allows you to position object in relative to the parents container. E.g. it can be used to center nodes on the screen regardless of the device type your game is running on.
 
 Similarily to how you set a node's position and positionType you can also set it's contentSize and contentSizeType. However, some classes doesn't allow you  to set these directly. For instance, the CCSprite sets its contentSize depending on the size of its texture and for descendants of CCControl you should  set the preferredSize and preferredSizeType rather than changing their contentSize directly. The CCSizeType has two components widthUnit and heightUnit  which can be any of the following:
 
 - CCSizeUnitPoints - This is the default, the size will be in points
 - CCSizeUnitScaled - The size is scaled by the UIScaleFactor.
 - CCSizeUnitNormalized - The content size will be set as a normalized value of the parent's container.
 - CCSizeUnitInset - The content size will be the size of it's parent container, but inset by a number of points.
 - CCSizeUnitInsetScaled - The content size will be the size of it's parent container, but inset by a number of points multiplied by the UIScaleFactor.
 
 Even if the positions and content sizes are not set in points you can use actions to animate the nodes. See the examples and tests for more information on how to set positions and content sizes, or use SpriteBuilder to easily play around with the settings. There are also more positioning options available by using CCLayout and CCLayoutBox.
 
#### Prefer to use ..InPoints
 
 There are typically two properties of each property supporting a "type". For instance the position property returns the raw values whose meaning depends on positionType, while positionInPoints will return the position in points regardless of positionType. It is recommended to use the "inPoints" variants of properties if you expect the values to be in points.
 
 Otherwise your code will break if you subsequently change the positionType to something other than points (ie UIPoints or Normalized).

### Subclassing Notes
 
 A common pattern in building a Cocos2d game is to subclass CCNode, add it to a CCScene and override the methods for handling user input.
 Consider each node subclass as being the view in a MVC model, but it's also the controller for this node and perhaps even the node's branch of the node tree.
 The model can also be represented by the node subclass itself, or made separate (M-VC model). 
 
 A separate model could simply be any NSObject class initialized by the node subclass and assigned to an ivar/property.
 
 An advanced subclassing style aims to minimize subclassing node classes except for CCNode itself. A CCNode subclass acts as the controller for its node tree, with one or more child nodes representing the controller node's views. This is particularly useful for composite nodes, such as a player with multiple body parts (head, torso, limbs), attachments (armor, weapons) and effects (health bar, name label, selection rectangle, particle effects).
 
 The userObject property can be used to add custom data and methods (model, components) to any node, in particular to avoid subclassing where the subclass would only add minimal functionality or just data.
 
### Cleanup of nodes
 
  When a node is no longer needed, and is removed (directly or indirectly) from it's parent by one of:
 
 -(void) removeFromParentAndCleanup:(BOOL)cleanup;
 -(void) removeChild: (CCNode*)node cleanup:(BOOL)cleanup;
 -(void) removeChildByName:(NSString*)name cleanup:(BOOL)cleanup;
 -(void) removeAllChildrenWithCleanup:(BOOL)cleanup;

  and the cleanup parameter is YES, the private method:
 
 - (void) cleanup;
 
 is called.  This offers an opportunity for the node to carry out any cleanup such as removing possible circular references that might cause a memory leak.
 
 @note that if you override cleanup, you must call [super cleanup] <em>after</em> any cleanup of your own.
 
 */
@interface CCNode : CCResponder < CCSchedulerTarget, CCShaderProtocol, CCBlendProtocol, CCTextureProtocol> {
    
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
    
@protected
    CCRenderState *_renderState;
    
    CCShader *_shader;
    NSMutableDictionary *_shaderUniforms;
    
    CCBlendMode *_blendMode;
    CCTexture *_texture;
    
}


/// -----------------------------------------------------------------------
/// @name Creating a Node
/// -----------------------------------------------------------------------

/** Creates and returns a new node.
 @note Not all subclasses support initialization via the `node` initializer. Prefer to use specialized initializers
 in CCNode subclasses, where available. */
+(instancetype) node;

// purposefully undocumented: init is inherited from NSObject
-(id) init;

/// -----------------------------------------------------------------------
/// @name Storing Custom Information
/// -----------------------------------------------------------------------

/** Used to store a custom object of any type. For instance you could add a NSMutableDictionary to store custom
 data in a node without needing to subclass the node. */
@property(nonatomic,readwrite,strong) id userObject;


/// -----------------------------------------------------------------------
/// @name Position
/// -----------------------------------------------------------------------

/** Position (x,y) of the node in the units specified by the positionType property. 
 The distance is measured from one of the corners of the node's parent container, which corner is specified by the positionType property. 
 Default setting is referencing the bottom left corner in points.
 @see positionInPoints
 @see positionType */
@property(nonatomic,readwrite,assign) CGPoint position;

/** Position (x,y) of the node in points from the bottom left corner.
 @see position */
@property(nonatomic,readwrite,assign) CGPoint positionInPoints;

/** Defines the position type used for the position property. Changing the position type affects the meaning of the values
 assigned to the position property and allows you to change the referenceCorner relative to the parent container. 
 It also allows position to be interpreted as "UIPoints", which are scaled by [CCDirector UIScaleFactor].
 See "Coordinate System and Positioning" in Class Overview for more information.
 @see CCPositionType, CCPositionUnit, CCPositionReferenceCorner
 @see position
 @see positionInPoints */
@property(nonatomic,readwrite,assign) CCPositionType positionType;

/// -----------------------------------------------------------------------
/// @name Rotation and Skew
/// -----------------------------------------------------------------------

/** The rotation (angle) of the node in degrees. Rotation is relative to the parent node's rotation.
 0 is the default rotation angle. Positive values rotate node clockwise. */
@property(nonatomic,readwrite,assign) float rotation;

/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node clockwise.
 It only modifies the X rotation performing a horizontal rotational skew.
 @see skewX, skewY */
@property(nonatomic,readwrite,assign) float rotationalSkewX;

/** The rotation (angle) of the node in degrees. 0 is the default rotation angle. Positive values rotate node clockwise.
 It only modifies the Y rotation performing a vertical rotational skew. */
@property(nonatomic,readwrite,assign) float rotationalSkewY;

/** The X skew angle of the node in degrees.
 This angle describes the shear distortion in the X direction.
 Thus, it is the angle between the Y axis and the left edge of the shape
 The default skewX angle is 0, with valid ranges from -90 to 90. Positive values distort the node in a clockwise direction.
 @see skewY, rotationalSkewX */
@property(nonatomic,readwrite,assign) float skewX;

/** The Y skew angle of the node in degrees.
 This angle describes the shear distortion in the Y direction.
 Thus, it is the angle between the X axis and the bottom edge of the shape
 The default skewY angle is 0, with valid ranges from -90 to 90. Positive values distort the node in a counter-clockwise direction.
 @see skewX, rotationalSkewY */
@property(nonatomic,readwrite,assign) float skewY;

/// -----------------------------------------------------------------------
/// @name Scale
/// -----------------------------------------------------------------------

/** The scale factor of the node. 1.0 is the default scale factor (original size). Meaning depends on scaleType.
 It modifies the X and Y scale at the same time, preserving the node's aspect ratio.

 Scale is affected by the parent node's scale, ie if parent's scale is 0.5 then setting the child's scale to 2.0 will make the
 child node appear at its original size.
 @see scaleInPoints
 @see scaleType
 @see scaleX, scaleY */
@property(nonatomic,readwrite,assign) float scale;

/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the X scale factor.
 
 Scale is affected by the parent node's scale, ie if parent's scale is 0.5 then setting the child's scale to 2.0 will make the
 child node appear at its original size.
 @see scaleY
 @see scaleXInPoints
 @see scale */
@property(nonatomic,readwrite,assign) float scaleX;

/** The scale factor of the node. 1.0 is the default scale factor. It only modifies the Y scale factor.
 
 Scale is affected by the parent node's scale, ie if parent's scale is 0.5 then setting the child's scale to 2.0 will make the
 child node appear at its original size.
 @see scaleX
 @see scaleYInPoints
 @see scale */
@property(nonatomic,readwrite,assign) float scaleY;

/** The scaleInPoints is the scale factor of the node in both X and Y, measured in points. 
 The scaleType property indicates if the scaleInPoints will be scaled by the UIScaleFactor or not.
 See "Coordinate System and Positioning" in class overview for more information.
 
 Scale is affected by the parent node's scale, ie if parent's scale is 0.5 then setting the child's scale to 2.0 will make the
 child node appear at its original size.

 @see scale
 @see scaleType */
@property (nonatomic,readonly) float scaleInPoints;

/** The scaleInPoints is the scale factor of the node in X, measured in points.
 
 Scale is affected by the parent node's scale, ie if parent's scale is 0.5 then setting the child's scale to 2.0 will make the
 child node appear at its original size.

 @see scaleY, scaleYInPoints */
@property (nonatomic,readonly) float scaleXInPoints;

/** The scaleInPoints is the scale factor of the node in Y, measured in points.
 
 Scale is affected by the parent node's scale, ie if parent's scale is 0.5 then setting the child's scale to 2.0 will make the
 child node appear at its original size.

 @see scaleX
 @see scaleXInPoints */
@property (nonatomic,readonly) float scaleYInPoints;

/** The scaleType defines scale behavior for this node. CCScaleTypeScaled indicates that the node will be scaled by [CCDirector UIScaleFactor].
 This property is analagous to positionType. ScaleType affects the scaleInPoints of a CCNode. 
 See "Coordinate System and Positioning" in class overview for more information.
 @see CCScaleType
 @see scale
 @see scaleInPoints */
@property (nonatomic,assign) CCScaleType scaleType;

/// -----------------------------------------------------------------------
/// @name Size
/// -----------------------------------------------------------------------

/** The untransformed size of the node in the unit specified by contentSizeType property.
 The contentSize remains the same regardless of whether the node is scaled or rotated.
 @see contentSizeInPoints
 @see contentSizeType */
@property (nonatomic,readwrite,assign) CGSize contentSize;

/** The untransformed size of the node in Points. The contentSize remains the same regardless of whether the node is scaled or rotated.
 contentSizeInPoints will be scaled by the [CCDirector UIScaleFactor] if the contentSizeType is CCSizeUnitUIPoints.
 @see contentSize
 @see contentSizeType */
@property (nonatomic,readwrite,assign) CGSize contentSizeInPoints;

/** Defines the contentSize type used for the width and height components of the contentSize property.

 @see CCSizeType, CCSizeUnit
 @see contentSize
 @see contentSizeInPoints */
@property (nonatomic,readwrite,assign) CCSizeType contentSizeType;

/**
 * Invoked automatically when the OS view has been resized.
 *
 * This implementation simply propagates the same method to the children.
 * Subclasses may override to actually do something when the view resizes.
 * @param newViewSize The new size of the view after it has been resized.
 */
-(void) viewDidResizeTo: (CGSize) newViewSize;


/** Returns an axis aligned bounding box in points, in the parent node's coordinate system.
 @see contentSize
 @see nodeToParentTransform */
- (CGRect) boundingBox;

/// -----------------------------------------------------------------------
/// @name Content Anchor
/// -----------------------------------------------------------------------

/** The anchorPoint is the point around which all transformations (scale, rotate) and positioning manipulations take place.
 The anchorPoint is normalized, like a percentage. (0,0) refers to the bottom-left corner and (1,1) refers to the top-right corner.
 The default anchorPoint is (0,0). It starts in the bottom-left corner. CCSprite and some other node subclasses may have a different 
 default anchorPoint, typically centered on the node (0.5,0.5).
 @warning The anchorPoint is not a replacement for moving a node. It defines how the node's content is drawn relative to the node's position. 
 @see anchorPointInPoints */
@property(nonatomic,readwrite) CGPoint anchorPoint;

/** The anchorPoint in absolute points. 
 It is calculated as follows: `x = contentSizeInPoints.width * anchorPoint.x; y = contentSizeInPoints.height * anchorPoint.y;`
 @note The returned point is relative to the node's contentSize origin, not relative to the node's position.
 @see anchorPoint */
@property(nonatomic,readonly) CGPoint anchorPointInPoints;


/// -----------------------------------------------------------------------
/// @name Working with Node Trees
/// -----------------------------------------------------------------------

/**
  Adds a child to the container with default zOrder (0).
  If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be sent
  to the node immediately.
 
  @param node CCNode to add as a child.
 @see addChild:z:
 @see addChild:z:name:
 */
-(void) addChild: (CCNode*)node;

/**
  Adds a child to the container with the given zOrder.
  If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be sent
  to the node immediately.
 
  @param node CCNode to add as a child.
  @param z    Draw order of node. This value will be assigned to the node's zOrder property.
  @see addChild:, addChild:z:name:
  @see zOrder
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z;

/**
  Adds a child to the container with z order and tag.
  If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
 
  @param node CCNode to add as a child.
  @param z    Draw order of node. This value will be assigned to the node's zOrder property.
  @param name Name for this node. This string will be assigned to the node's name property.
  @see addChild:, addChild:z:
  @see zOrder
  @see name
 */
-(void) addChild: (CCNode*)node z:(NSInteger)z name:(NSString*)name;

/** Removes the node from its parent node. Will stop the node's scheduled selectors/blocks and actions.
 @note It is typically more efficient to change a node's visible status rather than remove + addChild: if all you need
 is to temporarily remove the node from the screen.
 @see visible */
-(void) removeFromParent;

/**
 Removes a child from the container. The node must be a child of this node.
 Will stop the node's scheduled selectors/blocks and actions.

 @note It is recommended to use `[node removeFromParent]` over `[self removeChild:node]` as the former will always work,
 even in cases where (in this example) the node hierarchy has changed so that node no longer is a child of self.

 @note It is typically more efficient to change a node's visible status rather than remove + addChild: if all you need
 is to temporarily remove the node from the screen.

 @param child The child node to remove.
 @see removeFromParent
 */
-(void) removeChild:(CCNode*)child;

/**
 Removes a child from the container by name. Does nothing if there's no node with that name.
 Will stop the node's scheduled selectors/blocks and actions.

 @param name Name of node to be removed.
 */
-(void) removeChildByName:(NSString*)name;

/** 
 Removes all children from the container.
 @note It is unnecessary to call this when replacing scenes or removing nodes. All nodes call this method on themselves automatically
 when removed from a parent node or when a new scene is presented.
 */
-(void) removeAllChildren;

/** A weak reference to the parent.
 @warning **Never ever change the parent manually!** This must be done exclusively by Cocos2D. This property is not readonly due to historical
 reasons, and this is prone to change. */
@property(nonatomic,readwrite,weak) CCNode* parent;

/** Array of child nodes. Used to enumerate child nodes, for instance the following allows you to perform a task on all child nodes with a matching name:
 
    for (CCNode* child in self.children)
    {
        if ([child.name isEqualToString:@"so we meet again"])
        {      
            // do stuff here ...
        }
    }
 */
@property(nonatomic,readonly) NSArray *children;

/** The scene this node is added to, or nil if it's not part of a scene.
 
 @note The scene property is nil during a node's init methods. The scene property is set only after addChild: was used to add it
 as a child node to a node that already is in the scene.
 @see CCScene */
@property(nonatomic, readonly) CCScene *scene;

/// -----------------------------------------------------------------------
/// @name Removing Nodes without stopping Actions/Scheduling (unsafe!)
/// -----------------------------------------------------------------------

/**
 Removes the node from its parent node. If cleanup is YES the node will also remove all of its actions and scheduled selectors/blocks.

 @note Running `[self removeFromParentAndCleanup:YES]` is identical to running `[self removeFromParent]`.
 You only need to use this method if you intend to *not stop scheduler and actions*, ie `cleanup:NO`.
 
 @warning Setting cleanup to NO may prevent the node and its children from deallocating. You have to ensure that the node is either re-added 
 to the node hierarchy at some point, or send it the `cleanup` method when you no longer need the node (for instance before switching scenes).
 
 @param cleanup Stops all scheduled selectors/blocks and actions. Set to NO if you intend to "continue" the node at a later point or
 simply want to re-parent the node.
 @see removeFromParent
 */
-(void) removeFromParentAndCleanup:(BOOL)cleanup;

/**
 Removes a child from the container. The node must be a child of this node.
 If cleanup is YES the node will also remove all of its actions and scheduled selectors/blocks.

 @note Running `[self removeChild:node cleanup:YES]` is identical to running `[self removeChild:node]`.
 You only need to use this method if you intend to *not stop scheduler and actions*, ie `cleanup:NO`.

 @note It is recommended to use `[node removeFromParent]` over `[self removeChild:node]` as the former will always work,
 even in cases where (in this example) the node hierarchy has changed so that node no longer is a child of self.
 
 @warning Setting cleanup to NO may prevent the node and its children from deallocating. You have to ensure that the node is either re-added to the node
 hierarchy at some point, or send it the `cleanup` method when you no longer need the node (for instance before switching scenes).
 
 @param node    The child node to remove.
 @param cleanup If YES, stops all scheduled events and actions.
 @see removeFromParent
 @see removeChild:
 */
-(void) removeChild: (CCNode*)node cleanup:(BOOL)cleanup;

/**
 Removes a child from the container by name value.
 If cleanup is YES the node will also remove all of its actions and scheduled selectors/blocks.
 
 @note Running `[self removeChildByName:@"name" cleanup:YES]` is identical to running `[self removeChildByName:@"name"]`.
 You only need to use this method if you intend to *not stop scheduler and actions*, ie `cleanup:NO`.

 @warning Setting cleanup to NO may prevent the node and its children from deallocating. You have to ensure that the node is either re-added to the node
 hierarchy at some point, or send it the `cleanup` method when you no longer need the node (for instance before switching scenes).
 
 @param name    Name of node to be removed.
 @param cleanup Stops all scheduled events and actions.
 @see removeChildByName:
 */
-(void) removeChildByName:(NSString*)name cleanup:(BOOL)cleanup;

/**
 Removes all children from the container and do a cleanup all running actions depending on the cleanup parameter.

 @note Running `[self removeAllChildrenWithCleanup:YES]` is identical to running `[self removeAllChildren]`.
 You only need to use this method if you intend to *not stop scheduler and actions*, ie `cleanup:NO`.

 @warning Setting cleanup to NO may prevent the children from deallocating. You have to ensure that the children are either re-added to the node
 hierarchy at some point, or send them the `cleanup` method when you no longer need the children (for instance before switching scenes).
 
 @param cleanup If YES, stops all scheduled events and actions of removed node.
 @see removeAllChildren */
-(void) removeAllChildrenWithCleanup:(BOOL)cleanup;

/// -----------------------------------------------------------------------
/// @name Naming Nodes
/// -----------------------------------------------------------------------

/** A name tag used to help identify the node easily. Can be used both to encode custom data but primarily meant
 to obtain a node by its name.
 
 @see getChildByName:recursively:
 @see userObject */
@property(nonatomic,strong) NSString* name;

/**
  Search through the children of the container for one matching the name tag.
  If recursive, it returns the first matching node, via a depth first search.
  Otherwise, only immediate children are checked.
 
  @note Avoid calling this often, ie multiple times per frame, as the lookup cost can add up. Specifically if the search is recursive.
 
  @param name The name of the node to look for.
  @param isRecursive Search recursively through node's children (its node tree).
  @return Returns the first node with a matching name, or nil if no node with that name was found.
 @see name
 */
-(CCNode*) getChildByName:(NSString *)name recursively:(bool)isRecursive;

/// -----------------------------------------------------------------------
/// @name Working with Actions
/// -----------------------------------------------------------------------

/** If paused is set to YES, all of the node's actions and its scheduled selectors/blocks will be paused until the node is unpaused.
 
 Changing the paused state of a node will also change the paused state of its children recursively.
 
 @warning Any non-Cocos2D scheduling methods will be unaffected by the paused state. It is strongly discouraged to use NSTimer,
 `performSelector:afterDelay:` or Grand Central Disptach (GCD) `dispatch_xxx` methods to time/schedule tasks in Cocos2D.
 */
@property(nonatomic, assign) BOOL paused;

/** Returns YES if the node is added to an active scene and neither it nor any of it's ancestors is paused. */
@property(nonatomic,readonly,getter=isRunningInActiveScene) BOOL runningInActiveScene;

/**
 Has the node run an action.
 
 @note Depending on when in the frame update cycle this method gets called, the action passed in may either start running
 in the current frame or in the next frame.
 
 @param action Action to run.
 @return The action that is executed (same as the one that was passed in).
 @see CCAction
 */
-(CCAction*) runAction: (CCAction*) action;

/** Stops and removes all actions running on the node.
 @node It is not necessary to call this when removing a node. Removing a node from its parent will also stop its actions. */
-(void) stopAllActions;

/**
 *  Removes an action from the running action list.
 *
 *  @param action Action to remove.
 *  @see CCAction
 */
-(void) stopAction: (CCAction*) action;

/**
 *  Removes an action from the running action list given its tag. If there are multiple actions with the same tag it will
 *  only remove the first action found that has this tag.
 *
 *  @param tag Tag of action to remove.
 */
-(void) stopActionByTag:(NSInteger) tag;

/**
 *  Gets an action running on the node given its tag.
 *  If there are multiple actions with the same tag it will get the first action found that has this tag.
 *
 *  @param tag Tag of an action.
 *
 *  @return The first action with the given tag, or nil if there's no running action with this tag.
 *  @see CCAction
 */
-(CCAction*) getActionByTag:(NSInteger) tag;

/** Returns the numbers of actions that are running plus the ones that are scheduled to run (actions in the internal actionsToAdd array).
 @note Composable actions are counted as 1 action. Example:
 - If you are running 2 Sequences each with 7 actions, it will return 2.
 - If you are running 7 Sequences each with 2 actions, it will return 7.
 */
-(NSUInteger) numberOfRunningActions;

/// -----------------------------------------------------------------------
/// @name SpriteBuilder Animation Manager
/// -----------------------------------------------------------------------

/**
 Returns the Animation Manager of this node, or that of its parent.
 
 @note The animationManager property is nil during a node's init methods.
 @see CCAnimationManager
 */
@property (nonatomic, assign, readwrite) CCAnimationManager * animationManager;


/// -----------------------------------------------------------------------
/// @name Scheduling Selectors and Blocks
/// -----------------------------------------------------------------------

/**
 Schedules a block to run once, after the given delay.
 
 `CCTimerBlock` is a block typedef declared as `void (^)(CCTimer *timer)`
 
 @note There is currently no way to stop/cancel an already scheduled block. If a scheduled block should not run under certain circumstances,
 the block's code itself must check these conditions to determine whether it should or shouldn't perform its task.
 
 @param block Block to execute. The block takes a `CCTimer*` parameter as input and returns nothing.
 @param delay Delay, in seconds.
 
 @return A newly initialized CCTimer object.
 @see CCTimer
 */
-(CCTimer *) scheduleBlock:(CCTimerBlock)block delay:(CCTime)delay;

/**
 Schedules a custom selector to run repeatedly at the given interval (in seconds).
 If the selector is already scheduled, then the interval parameter will be updated without scheduling it again.
 
 @note If interval is 0 the selector will run once every frame. It is recommended and slightly more efficient to implement the update: method
 instead. If the update: method is already implemented, just call a selector from update: that runs whatever selector you wanted to schedule with interval 0.
 
 @param selector Selector to run. The selector must have the following signature: `-(void) theSelector:(CCTime)delta` where *theSelector* is any legal selector name.
 The parameter must be specified with the @selector keyword as `@selector(theSelector:)`.
 @param seconds Interval between executions in seconds.
 
 @return A newly initialized CCTimer object.
 @see CCTimer
 */
-(CCTimer *) schedule:(SEL)selector interval:(CCTime)seconds;

/**
 Schedules a custom selector to run repeatedly at the given interval (in seconds).
 
 @param selector Selector to run. The selector must have the following signature: `-(void) theSelector:(CCTime)delta` where *theSelector* is any legal selector name.
 The parameter must be specified with the @selector keyword as `@selector(theSelector:)`.
 @param interval Interval between executions in seconds.
 @param repeat   Number of times to repeat the selector. The selector will run *repeat* times plus one because the first run is not considered a "repeat".
 @param delay    Delay before running the selector for the first time, in seconds.
 
 @return A newly initialized CCTimer object.
 @see CCTimer
 */
-(CCTimer *) schedule:(SEL)selector interval:(CCTime)interval repeat: (NSUInteger) repeat delay:(CCTime) delay;

/**
 Re-schedules a custom selector with an interval time in seconds.
 If the custom selector you pass in is not already scheduled, this method is equivalent to schedule:interval:.
  
 The difference between this method and schedule:interval: is that if the selector is already scheduled,
 calling this method will only adjust the interval of the already scheduled selector.
 
 In contrast, when you call schedule:interval: on an already scheduled selector, your custom selector will be unscheduled and then rescheduled which
 is less efficient.
  
 @param selector Selector to run. The selector must have the following signature: `-(void) theSelector:(CCTime)delta` where *theSelector* is any legal selector name.
 The parameter must be specified with the @selector keyword as `@selector(theSelector:)`.
 @param interval Interval between execution in seconds.
 @see CCTimer
 */
-(CCTimer*)reschedule:(SEL)selector interval:(CCTime)interval;
 
/**
 Schedules a selector that runs only once, with an initial delay.
 
 @param selector Selector to run. The selector must have the following signature: `-(void) theSelector:(CCTime)delta` where *theSelector* is any legal selector name.
 The parameter must be specified with the @selector keyword as `@selector(theSelector:)`.
 @param delay    Delay before selector runs, in seconds.
 
 @return A newly initialized CCTimer object.
 @see CCTimer
 */
- (CCTimer *) scheduleOnce:(SEL) selector delay:(CCTime) delay;

/**
 Unschedule an already scheduled selector. Does nothing if the given selector isn't scheduled.
 
 @param selector Selector to unschedule. The parameter must be specified with the @selector keyword as `@selector(theSelector:)`.
 */
-(void)unschedule:(SEL)selector;

/** Unschedules all scheduled selectors.
 @note When removing a node from its parent it will automatically unschedule all of its selectors. It is not required to explicitly call this method.
 */
-(void)unscheduleAllSelectors;

/// -----------------------------------------------------------------------
/// @name Transforms and Matrices
/// -----------------------------------------------------------------------

/** Returns the matrix that transform the node's (local) space coordinates into the parent's space coordinates.
 The matrix is in Pixels.
 @see [CGAffineTransform](https://developer.apple.com/library/ios/documentation/graphicsimaging/reference/CGAffineTransform/index.html)
 @see parentToNodeTransform
 */
- (CGAffineTransform)nodeToParentTransform;

/** Returns the matrix that transform parent's space coordinates to the node's (local) space coordinates. The matrix is in Pixels.
 @see [CGAffineTransform](https://developer.apple.com/library/ios/documentation/graphicsimaging/reference/CGAffineTransform/index.html)
 @see nodeToParentTransform
*/
- (CGAffineTransform)parentToNodeTransform;

/** Returns the world affine transform matrix. The matrix is in Pixels.
 @see [CGAffineTransform](https://developer.apple.com/library/ios/documentation/graphicsimaging/reference/CGAffineTransform/index.html)
 @see nodeToParentTransform
 @see worldToNodeTransform
*/
- (CGAffineTransform)nodeToWorldTransform;

/** Returns the inverse world affine transform matrix. The matrix is in Pixels.
 @see [CGAffineTransform](https://developer.apple.com/library/ios/documentation/graphicsimaging/reference/CGAffineTransform/index.html)
 @see nodeToWorldTransform
*/
- (CGAffineTransform)worldToNodeTransform;

/// -----------------------------------------------------------------------
/// @name Converting Point and Size "Types"
/// -----------------------------------------------------------------------

/** Converts the given position values to a position in points.
 
 @param position The position values to convert.
 @param type How the input position values should be interpreted.
 @returns The converted position in points.
 @see positionInPoints
 @see CCPositionType, CCPositionUnit, CCPositionReferenceCorner */
- (CGPoint) convertPositionToPoints:(CGPoint)position type:(CCPositionType)type;

/** Converts the given position in points to position values converted based on the provided CCPositionType.
 
 @param positionInPoints The position in points to convert.
 @param type How the input position values should be converted.
 @returns The position values in the format specified by type.
 @see position
 @see CCPositionType, CCPositionUnit, CCPositionReferenceCorner */
- (CGPoint) convertPositionFromPoints:(CGPoint)positionInPoints type:(CCPositionType) type;

/** Converts the given content size values to a size in points.
 
 @param contentSize The contentSize values to convert.
 @param type How the input contentSize values should be interpreted.
 @returns The converted size in points.
 @see contentSizeInPoints
 @see CCSizeType, CCSizeUnit */
- (CGSize) convertContentSizeToPoints:(CGSize)contentSize type:(CCSizeType) type;

/** Converts the given size in points to size values converted based on the provided CCSizeType.
 
 @param pointSize The size in points to convert.
 @param type How the input size values should be converted.
 @returns The size values in the format specified by type.
 @see contentSize
 @see CCSizeType, CCSizeUnit */
- (CGSize) convertContentSizeFromPoints:(CGSize)pointSize type:(CCSizeType) type;

/// -----------------------------------------------------------------------
/// @name Converting to and from the Node's Coordinate System
/// -----------------------------------------------------------------------

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
 *  Treats the returned/received node point as relative to the anchorPoint.
 *
 *  @param worldPoint World position in points.
 *
 *  @return Local position in points.
 */
- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint;

/**
 *  Converts a local Point to world space coordinates. The result is in Points.
 *  Treats the returned/received node point as relative to the anchorPoint.
 *
 *  @param nodePoint Local position in points.
 *
 *  @return World position in points.
 */
- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint;

/**
 *  Converts a local Point to Window space (UIKit) coordinates. The result is in Points.
 *
 *  @param nodePoint Local position in points.
 *
 *  @return UI position in points.
 */
- (CGPoint)convertToWindowSpace:(CGPoint)nodePoint;

/// -----------------------------------------------------------------------
/// @name Visibility and Draw Order
/// -----------------------------------------------------------------------

/** Whether the node and its children are visible. Default is YES.
 
 @note The children nodes will not change their visible property. Nevertheless they won't be drawn if their parent's visible property is NO.
 This means even if a node's visible property may be YES it could still be invisible if one of its parents has visible set to NO.
 
 @note Nodes that are not visible will not be rendered. For recurring use of the same nodes it is typically more
 efficient to temporarily set `node.visible = NO` compared to removeFromParent and a subsequent addChild:. */
@property(nonatomic,readwrite,assign) BOOL visible;

/** The draw order of the node relative to its sibling (having the same parent) nodes. The default is 0.

 A zOrder of less than 0 will draw nodes behind their parent, a zOrder of 0 or greater will make the nodes draw in front
 of their parent.

 A parent nodes with a lower zOrder value will have itself and its children drawn behind another parent node with a higher zOrder value. 
 The zOrder property only affects sibling nodes and their parent, it can not be used to change the draw order of nodes with different
 parents - in that case adjust the parent node's zOrder.
 
 @note Any sibling nodes with the same zOrder will be drawn in the order they were added as children. It is slightly more efficient
 (and certainly less confusing) to make this natural order work to your advantage.
 */
@property(nonatomic,assign) NSInteger zOrder;

/// -----------------------------------------------------------------------
/// @name Color
/// -----------------------------------------------------------------------

/** Sets and returns the node's color. Alpha is ignored. Changing color has no effect on non-visible nodes (ie CCNode, CCScene).
 
 @note By default color is not "inherited" by child nodes. This can be enabled via cascadeColorEnabled.
 @see CCColor
 @see colorRGBA
 @see opacity
 @see cascadeColorEnabled
 */
@property (nonatomic,strong) CCColor* color;

/** Sets and returns the node's color including alpha. Changing color has no effect on non-visible nodes (ie CCNode, CCScene).

 @note By default color is not "inherited" by child nodes. This can be enabled via cascadeColorEnabled.
 @see CCColor
 @see color
 @see opacity
 @see cascadeColorEnabled
*/
@property (nonatomic,strong) CCColor* colorRGBA;

/** Returns the actual color used by the node. This may be different from the color and colorRGBA properties if the parent
 node has cascadeColorEnabled.

 @see CCColor
 @see color
 @see colorRGBA
*/
@property (nonatomic, readonly) CCColor* displayedColor;

/**
 CascadeColorEnabled causes changes to this node's color to cascade down to it's children. The new color is multiplied
 in with the color of each child, so it doesn't bash the current color of those nodes. Opacity is unaffected by this
 property, see cascadeOpacityEnabled to change the alpha of nodes.
 @see color
 @see colorRGBA
 @see displayedColor
 @see opacity
 */
@property (nonatomic, getter = isCascadeColorEnabled) BOOL cascadeColorEnabled;

// purposefully undocumented: internal method users needn't know about
/*
 *  Recursive method that updates display color.
 *
 *  @param color Color used for update.
 */
- (void)updateDisplayedColor:(ccColor4F)color;

/// -----------------------------------------------------------------------
/// @name Opacity (Alpha)
/// -----------------------------------------------------------------------

/** 
 Sets and returns the opacity in the range 0.0 (fully transparent) to 1.0 (fully opaque).
 
 @note By default opacity is not "inherited" by child nodes. This can be enabled via cascadeOpacityEnabled.
 @warning If the the texture has premultiplied alpha then the RGB channels will be modified.
 */
@property (nonatomic) CGFloat opacity;

/** Returns the actual opacity, in the range 0.0 to 1.0. This may be different from the opacity property if the parent
 node has cascadeOpacityEnabled.
 @see opacity */
@property (nonatomic, readonly) CGFloat displayedOpacity;

/** 
 CascadeOpacity causes changes to this node's opacity to cascade down to it's children. The new opacity is multiplied
 in with the opacity of each child, so it doesn't bash the current opacity of those nodes. Color is unaffected by this
 property. See cascadeColorEnabled for color changes.
 @see opacity
 @see displayedOpacity
 */
@property (nonatomic, getter = isCascadeOpacityEnabled) BOOL cascadeOpacityEnabled;

// purposefully undocumented: internal method users needn't know about
/*
 *  Recursive method that updates the displayed opacity.
 *
 *  @param opacity Opacity to use for update.
 */
- (void)updateDisplayedOpacity:(CGFloat)opacity;

// purposefully undocumented: method marked deprecated
/*
 Sets the premultipliedAlphaOpacity property.
 
 - NO:  opacity will be applied as: `glColor(R,G,B,opacity);`
 - YES: opacity will be applied as: `glColor(opacity, opacity, opacity, opacity);`
 
 Textures with premultiplied alpha will have this property set to YES by default. Otherwise the default value is NO.
 
 @param boolean Enables or disables setting of opacity with color.
 */
-(void) setOpacityModifyRGB:(BOOL)boolean __attribute__((deprecated));

// purposefully undocumented: method marked deprecated
/* Returns whether or not the opacity will be applied using glColor(R,G,B,opacity) or glColor(opacity, opacity, opacity, opacity).
 */
-(BOOL) doesOpacityModifyRGB __attribute__((deprecated));


/// -----------------------------------------------------------------------
/// @name Rendering (Implemented in Subclasses)
/// -----------------------------------------------------------------------

/**
 Override this method to add custom rendering code to your node. 
 
 @note You should only use Cocos2D's CCRenderer API to modify the render state and shaders. For further info, please see the CCRenderer documentation.
 @warning You **must not** call `[super draw:transform:];`
 
 @param renderer The CCRenderer instance to use for drawing.
 @param transform The parent node's transform.
 @see CCRenderer
 */
-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform;

// purposefully undocumented: users needn't override/implement visit in their own subclasses
/* Calls visit:parentTransform: using the current renderer and projection. */
-(void) visit;


/// -----------------------------------------------------------------------
/// @name Scene Management (Implemented in Subclasses)
/// -----------------------------------------------------------------------

/** Called every time the CCNode (or one of its parents) has been added to the scene, or when the scene is presented.
 If a new scene is presented with a transition, this event is sent to nodes when the transition animation starts.
 
 @warning You must call `[super onEnter]` in your own implementation.
 @see onExit
 @see onEnterTransitionDidFinish
 */
-(void) onEnter __attribute__((objc_requires_super));

/** Called every time the CCNode (or one of its parents) has been added to the scene, or when the scene is presented.
 If a new scene is presented with a transition, this event is sent to nodes after the transition animation ended. Otherwise
 it will be called immediately after onEnter.
 
 @warning You must call `[super onEnterTransitionDidFinish]` in your own implementation.
 @see onEnter
 @see onExit
 */
-(void) onEnterTransitionDidFinish __attribute__((objc_requires_super));

/** Called every time the CCNode is removed from the node tree.
 If a new scene is presented with a transition, this event is sent when the transition animation ended.
 
 @warning You must call `[super onExit]` in your own implementation.
 @see onEnter
 @see onExitTransitionDidStart
 */
-(void) onExit __attribute__((objc_requires_super));

/** Called every time the CCNode is removed from the node tree.
 If a new scene is presented with a transition, this event is sent when the transition animation starts.
 
 @warning You must call `[super onExitTransitionDidStart]` in your own implementation.
 @see onExit
 @see onEnter
 */
-(void) onExitTransitionDidStart __attribute__((objc_requires_super));

/// -----------------------------------------------------------------------
/// @name Physics Body
/// -----------------------------------------------------------------------

/** The physics body (if any) that this node is attached to.
 Initialize and assign a CCPhysicsBody instance to this property to have the node participate in the physics simulation.
 @see CCPhysicsBody
 @see physicsNode
 */
@property(nonatomic, strong) CCPhysicsBody *physicsBody;

/// Returns true if the node is not using custom uniforms.
-(BOOL)hasDefaultShaderUniforms;

/// Cache and return the current render state.
/// Should be set to nil whenever changing a property that affects the renderstate.
@property(nonatomic, strong) CCRenderState *renderState;

/* The real openGL Z vertex.
 Differences between openGL Z vertex and cocos2d Z order:
 - OpenGL Z modifies the Z vertex, and not the Z order in the relation between parent-children
 - OpenGL Z might require to set 2D projection
 - cocos2d Z order works OK if all the nodes uses the same openGL Z vertex. eg: vertexZ = 0
 @warning: Use it at your own risk since it might break the cocos2d parent-children z order
 */
@property (nonatomic,readwrite) float vertexZ;

@property (nonatomic,readonly) BOOL isPhysicsNode;

/* used internally for zOrder sorting, don't change this manually */
@property(nonatomic,readwrite) NSUInteger orderOfArrival;

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
 If you override cleanup, you must call [super cleanup] <em>after</em> any cleanup of your own.
 */
-(void) cleanup __attribute__((objc_requires_super));

///* performs OpenGL view-matrix transformation of its ancestors.
// Generally the ancestors are already transformed, but in certain cases (eg: attaching a FBO) it is necessary to transform the ancestors again.
// */
//-(void) transformAncestors;

/* final method called to actually remove a child node from the children.
 *  @param node    The child node to remove
 *  @param cleanup Stops all scheduled events and actions
 */
-(void) detachChild:(CCNode *)child cleanup:(BOOL)doCleanup;

- (void) contentSizeChanged;
- (void) parentsContentSizeChanged;

@end

CGPoint NodeToPhysicsScale(CCNode * node);
float NodeToPhysicsRotation(CCNode *node);
CGAffineTransform NodeToPhysicsTransform(CCNode *node);
CGAffineTransform RigidBodyToParentTransform(CCNode *node, CCPhysicsBody *body);
CGPoint GetPositionFromBody(CCNode *node, CCPhysicsBody *body);
CGPoint TransformPointAsVector(CGPoint p, CGAffineTransform t);
CGAffineTransform CGAffineTransformMakeRigid(CGPoint translate, CGFloat radians);

@interface CCNode(NoARC)

// purposefully undocumented: internal method, users should prefer to implement draw:transform:
/* Returns the 4x4 drawing transformation for this node. Only useful when overriding `visit:parentTransform:`
 @param parentTransform The parent node's transform. */
-(GLKMatrix4)transform:(const GLKMatrix4 *)parentTransform;

// purposefully undocumented: internal method, users should prefer to implement draw:transform:
/* Recursive method that visit its children and draw them.
 * @param renderer The CCRenderer instance to use for drawing.
 * @param parentTransform The parent node's transform.
 */
-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform;

@end

