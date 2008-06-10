//
//  CocosNode.h
//	cocos2d
//

#import <OpenGLES/ES1/gl.h>
#import <UIKit/UIKit.h>

#import "Action.h"

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
	CGPoint position;

	/// is visible
	BOOL visible;
	
	/// transformation anchor point
	CGPoint transformAnchor;
	
	/// where are the children placed (anchor)
	CGPoint childrenAnchor;
	
	/// array of children
	NSMutableArray *children;
	
	/// is running
	BOOL isRunning;
	
	/// weakref to parent
	CocosNode *parent;
	
	// actions
	NSMutableArray *actions;
	NSMutableArray *actionsToRemove;
	
	// scheduled selectors
	NSMutableDictionary *scheduledSelectors;
}

@property(readwrite,assign) float rotation;
@property(readwrite,assign) float scale;
@property(readwrite,assign) CGPoint position;
@property(readwrite,assign) BOOL visible;
@property(readwrite,assign) CGPoint transformAnchor;
@property(readwrite,assign) CGPoint childrenAnchor;
@property(readwrite,assign) CocosNode* parent;

// initializators
//! creates a node
+(id) node;
//! initializes the node
-(id) init;

// composition

/** Adds a child to the container with z-order as 0 */
-(void) add: (CocosNode*)node;
/** Adds a child to the container */
-(void) add: (CocosNode*)node z:(int)z;
/** Removes a child from the container */
-(void) remove: (CocosNode*)node;
/** callback that is called every time the node enters the 'stage' */
-(void) onEnter;
/** callback that is called every time the node leaves the 'stage'. */
-(void) onExit;

// draw
/** override this method to draw your own node. */
-(void) draw;
/** recursive method that visit its children and draw them */
-(void) visit;
/** performs opengl view-matrix transformation based on position, scale, rotation and other attributes. */
-(void) transform;

// actions
/** executes an action */
-(Action*) do: (Action*) action;
-(void) step_;

// timers
/** schedules a method */
-(void) schedule: (SEL) method;
/** unschedule a method */
-(void) unschedule: (SEL) method;
-(void) activateTimers;
-(void) activateTimer: (SEL) method;
-(void) deactivateTimers;
@end
