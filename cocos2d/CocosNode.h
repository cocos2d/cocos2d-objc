/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import <OpenGLES/ES1/gl.h>
#import <UIKit/UIKit.h>

#import "Action.h"
#import "chipmunk.h"
#import "cctypes.h"

enum {
	kCocosNodeTagInvalid = -1,
};

@class Camera;
@class GridBase;

/** CocosNode is the main element. Anything thats gets drawn or contains things that get drawn is a CocosNode.
 The most popular CocosNodes are: Scene, Layer, Sprite.
 
 The main features of a cocosnode are:
 - They can contain other cocos nodes (add, get, remove, etc)
 - They can schedule periodic callback (schedule, unschedule, etc)
 - They can execute actions (do, pause, stop, etc)
 
 Some CocosNodes provide extra functionality for them or their children.
 
 Subclassing a CocosNode usually means (one/all) of:
 - overriding init to initialize resources and schedule calbacks
 - create callbacks to handle the advancement of time
 - overriding draw to render the node    
 */ 
@interface CocosNode : NSObject {
	
	// rotation angle
	float rotation;	
	
	// scale factor
	float scale;
	
	// scale X factor
	float scaleX;
	
	// scale Y factor
	float scaleY;
	
	// position of the node
	cpVect position;
	
	// parallax X factor
	float parallaxRatioX;
	
	// parallax Y factor
	float parallaxRatioY;
	
	// is visible
	BOOL visible;
	
	// a Camera
	Camera *camera;
	
	// a Grid
	GridBase *grid;
	
	// z-order value
	int zOrder;
	
	// If YES the transformtions will be relative to (-transform.x, -transform.y).
	// Sprites, Labels and any other "small" object uses it.
	// Scenes, Layers and other "whole screen" object don't use it.
	BOOL relativeTransformAnchor;
	
	// transformation anchor point
	cpVect transformAnchor;
	
	// array of children
	NSMutableArray *children;
	
	// is running
	BOOL isRunning;
	
	// weakref to parent
	CocosNode *parent;
	
	// a tag. any number you want to assign to the node
	int tag;
	
	// actions
	NSMutableArray *actions;
	
	// (vali) make the following 3 @private?
	NSMutableArray *actionsToRemove;
	NSMutableArray *actionsToAdd;
	
	// scheduled selectors
	NSMutableDictionary *scheduledSelectors;
}

/** The z order of the node relative to it's "brothers": children of the same parent */
@property(readonly) int zOrder;
/** The rotation (angle) of the node in degrees. 0 is the default rotation angle */
@property(readwrite,assign) float rotation;
/** The scale factor of the node. 1.0 is the default scale factor */
@property(readwrite,assign) float scale, scaleX, scaleY;
/** The parallax ratio of the node. 1.0 is the default ratio */
@property(readwrite,assign) float parallaxRatio;
/** The X parallax ratio of the node. 1.0 is the default ratio */
@property(readwrite,assign) float parallaxRatioY;
/** The Y parallax ratio of the node. 1.0 is the default ratio */
@property(readwrite,assign) float parallaxRatioX;
/** Position (x,y) of the node in OpenGL coordinates. (0,0) is the left-bottom corner */
@property(readwrite,assign) cpVect position;
/** A Camera object that lets you move the node using camera coordinates.
 * If you use the Camera then position, scale & rotation won't be used */
@property(readonly) Camera* camera;
/** A Grid object that is used when applying Effects */
@property(readwrite,retain) GridBase* grid;
/** Whether of not the node is visible. Default is YES */
@property(readwrite,assign) BOOL visible;
/** The transformation anchor point. For Sprite and Label the transform anchor point is (width/2, height/2) */
@property(readwrite,assign) cpVect transformAnchor;
/** A weak reference to the parent */
@property(readwrite,assign) CocosNode* parent;
/** If YES the transformtions will be relative to (-transform.x, -transform.y).
 * Sprites, Labels and any other sizeble object use it.
 * Scenes, Layers and other "whole screen" object don't use it.
 */
@property(readwrite,assign) BOOL relativeTransformAnchor;
/** A tag used to identify the node easily */
@property(readwrite,assign) int tag;
/** An array with the children */
@property (readonly) NSArray *children;

// initializators
//! creates a node
+(id) node;
//! initializes the node
-(id) init;


// scene managment

/** callback that is called every time the node enters the 'stage' */
-(void) onEnter;
/** callback that is called every time the node leaves the 'stage'. */
-(void) onExit;


// composition: ADD

/** Adds a child to the container with z-order as 0 
 @return returns self
 */
-(id) addChild: (CocosNode*)node;

/** Adds a child to the container with a z-order
 @return returns self
 */
-(id) addChild: (CocosNode*)node z:(int)z;

/** Adds a child to the container with z order and tag
 @deprecated Will be removed in v0.8. Used addChild:z:tag instead
 @return returns self
 */
-(id) addChild: (CocosNode*)node z:(int)z tag:(int)tag;

/** Adds a child to the container with a z-order and a parallax ratio
 @return returns self
 */
-(id) addChild: (CocosNode*)node z:(int)z parallaxRatio:(cpVect)c;

// composition: ADD (deprecated)

/** Adds a child to the container with z-order as 0 
 @deprecated Will be removed in v0.8. Used addChild instead
 @return returns self
 */
-(id) add: (CocosNode*)node;
/** Adds a child to the container with a z-order
 @deprecated Will be removed in v0.8. Used addChild:z instead
 @return returns self
 */
-(id) add: (CocosNode*)node z:(int)z;
/** Adds a child to the container with z order and tag
 @deprecated Will be removed in v0.8. Used addChild:z:tag instead
 @return returns self
 */
-(id) add: (CocosNode*)node z:(int)z tag:(int)tag;
/** Adds a child to the container with a z-order and a parallax ratio
 @deprecated Will be removed in v0.8. Used addChild:z:tag:paralalxRatio instead
 @return returns self
 */
-(id) add: (CocosNode*)node z:(int)z parallaxRatio:(cpVect)c;

// composition: REMOVE

/** Removes a child from the container. It will also cleanup all running actions depending on the cleanup parameter.
 */
-(void) removeChild: (CocosNode*)node cleanup:(BOOL)cleanup;

/** Removes a child from the container by tag value. It will also cleanup all running actions depending on the cleanup parameter
 */
-(void) removeChildByTag:(int) tag cleanup:(BOOL)cleanup;

/** Removes all children from the container and do a cleanup all running actions depending on the cleanup parameter.
 */
-(void) removeAllChildrenWithCleanup:(BOOL)cleanup;

// composition: REMOVE (deprecated)

/** Removes a child from the container
 @deprecated Will be removed in v0.8. Used removeChild:cleanup:NO instead
 @warning It DOESN'T stop all running actions from the removed object and it DOESN'T unschedules all scheduled selectors 
 */
-(void) remove: (CocosNode*)node;
/** Removes a child from the container given its tag
 @deprecated Will be removed in v0.8. Used removeChildByTag:cleanup:NO instead
 @warning It DOESN'T stop all running actions from the removed object and it DOESN'T unschedules all scheduled selectors 
 */
-(void) removeByTag:(int) tag;
/** Removes all children from the container.
 @deprecated Will be removed in v0.8. Used removeAllChildrenWithCleanup:NO instead
 @warning It DOESN'T stop all running actions from the removed object and it DOESN'T unschedules all scheduled selectors 
 */
-(void) removeAll;
/** Removes a child from the container by reference and stops all running actions and scheduled functions
 @deprecated Will be removed in v0.8. Used removeChild:cleanup:YES instead
 */
-(void) removeAndStop: (CocosNode*)node;
/** Removes a child from the container by tag and stops all running actions and scheduled functions
 @deprecated Will be removed in v0.8. Used removeChildByTag:cleanup:YES instead
 */
-(void) removeAndStopByTag:(int) tag;
/** Removes all children from the container.
 It stops all running actions from the removed objects and unschedules all scheduled selectors
 @deprecated Will be removed in v0.8. Used removeAllChildrenWithCleanup:YES instead
 */
-(void) removeAndStopAll;

// composition: GET
/** Gets a child from the container given its tag
 @return returns a CocosNode object
 */
-(CocosNode*) getChildByTag:(int) tag;

// composition: GET (deprecated)

/** Gets a child from the container given its tag
 @deprecated Will be removed in v0.8. Used getChildByTag instead
 @return returns a CocosNode object
 */
-(CocosNode*) getByTag:(int) tag;

/** Returns the absolute position of the CocosNode
 * @return a cpVect value with the absolute position of the noe
 */
-(cpVect) absolutePosition;

/** Reorders a child according to a new z value.
 * The child MUST be already added.
 */
-(void) reorderChild:(CocosNode*)child z:(int)zOrder;

// draw

/** override this method to draw your own node. */
-(void) draw;
/** recursive method that visit its children and draw them */
-(void) visit;


// transformations

/** performs opengl view-matrix transformation based on position, scale, rotation and other attributes. */
-(void) transform;


// actions

/** Executes an action, and returns the action that is executed
 @deprecated Will be removed in v0.8. Used runAction instead
 */
-(Action*) do: (Action*) action;
/** Executes an action, and returns the action that is executed
 */
-(Action*) runAction: (Action*) action;
/** Removes all actions from the running action list */
-(void) stopAllActions;
/** Removes one action from the running action list */
-(void) stopAction: (Action*) action;
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
/** unschedule a selector */
-(void) unschedule: (SEL) s;
@end

//
// protocols
//

/// CocosNode opacity protocol
@protocol CocosNodeOpacity
/// returns the opacity
-(GLubyte) opacity;
/// sets the opacity
-(void) setOpacity: (GLubyte) opacity;
@end


/// Size CocosNode protocol
@protocol CocosNodeSize
/// returns the size in pixels of the un-tranformted texture.
-(CGSize) contentSize;
@end


/// Size CocosNode protocol
@protocol CocosNodeRGB
/** set the color of the node.
 * example:  [node setRGB: 255:128:24];  or  [node setRGB:0xff:0x88:0x22];
 */
-(void) setRGB: (GLubyte)r :(GLubyte)g :(GLubyte)b;
/// The red component of the node's color.
-(GLubyte) r;
/// The green component of the node's color.
-(GLubyte) g;
/// The blue component of the node's color.
-(GLubyte) b;
@end




