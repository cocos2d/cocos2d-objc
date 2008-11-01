/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


#import <OpenGLES/ES1/gl.h>
#import <UIKit/UIKit.h>

#import "Action.h"
#import "chipmunk.h"
#import "types.h"

enum {
	kCocosNodeTagInvalid = -1,
};

// XXX: children anchor is not working
// but since cocos2d-iphone uses a different way to call it's children
// it is not necesary to have children anchor
//#define USING_CHILDREN_ANCHOR 1

@class Camera;

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
	
	/// rotation angle
	float rotation;	
	
	/// scale factor
	float scale;
	
	/// position of the node
	cpVect position;

	/// is visible
	BOOL visible;
	
	/// a Camera
	Camera *camera;
	
	/// z-order value
	int zOrder;

	/// If YES the transformtions will be relative to (-transform.x, -transform.y).
	/// Sprites, Labels and any other "small" object uses it.
	/// Scenes, Layers and other "whole screen" object don't use it.
	BOOL relativeTransformAnchor;

	/// transformation anchor point
	cpVect transformAnchor;
	
	/// where are the children placed (anchor)
//	cpVect childrenAnchor;
	
	/// array of children
	NSMutableArray *children;
	
	/// dictionary of child name -> child
	NSMutableDictionary *childrenNames;
	
	/// is running
	BOOL isRunning;
	
	/// weakref to parent
	CocosNode *parent;
	
	/// a tag. any number you want to assign to the node
	int tag;
	
	// actions
	NSMutableArray *actions;
	NSMutableArray *actionsToRemove;
	NSMutableArray *actionsToAdd;

	
	// scheduled selectors
	NSMutableDictionary *scheduledSelectors;
}

@property(readwrite,assign) int zOrder;
@property(readwrite,assign) float rotation;
@property(readwrite,assign) float scale;
@property(readwrite,assign) cpVect position;
@property(readwrite,assign) Camera* camera;
@property(readwrite,assign) BOOL visible;
@property(readwrite,assign) cpVect transformAnchor;
@property(readwrite,assign) CocosNode* parent;
@property(readwrite,assign) BOOL relativeTransformAnchor;
@property(readwrite,assign) int tag;
#if USING_CHILDREN_ANCHOR
@property(readwrite,assign) cpVect childrenAnchor;
#endif

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


// composition

/** Adds a child to the container with z-order as 0 
 @return returns self
 */
-(id) add: (CocosNode*)node;
/** Adds a child to the container with a z-order
 @return returns self
 */
-(id) add: (CocosNode*)node z:(int)z;
/** Adds a child to the container with z order and name
 @return returns self
 @deprecated Use add:z:tag instead
 */
-(id) add: (CocosNode*)node z:(int)z name:(NSString*)name;
/** Adds a child to the container with z order and tag
 @return returns self
 */
-(id) add: (CocosNode*)node z:(int)z tag:(int)tag;
/** Removes a child from the container
 If you have added a 'named' child, you MUST remove it using removeByName instead
 */
-(void) remove: (CocosNode*)node;
/** Removes a child from the container given its name
 * @deprecated Use removeByTag instead
 */
-(void) removeByName: (NSString*)name;
/** Removes all children from the container
 */
-(void) removeAll;
/** Gets a child from the container given its name 
 * @deprecated Use getByTag instead
 */
-(CocosNode*) get: (NSString*) name;
/** Removes a child from the container given its tag */
-(void) removeByTag:(int) tag;
/** Gets a child from the container given its tag */
-(CocosNode*) getByTag:(int) tag;


// draw

/** override this method to draw your own node. */
-(void) draw;
/** recursive method that visit its children and draw them */
-(void) visit;
/** performs opengl view-matrix transformation based on position, scale, rotation and other attributes. */
-(void) transform;


// actions

/** Executes an action, and returns the action that is executed */
-(Action*) do: (Action*) action;
/** Removes all actions from the running action list */
-(void) stopAllActions;
/** Removes one action from the running action list */
-(void) stopAction: (Action*) action;


// timers

/** schedules a selector.
 The scheduled selector will be ticked every frame
 */
-(void) schedule: (SEL) s;
/** schedules a selector with an interval time.
 If time is 0 it will be ticked every frame.
 */
-(void) schedule: (SEL) s interval:(ccTime) i;
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
/// returns the size in pixels of a CocosNode
-(CGSize) contentSize;
@end



