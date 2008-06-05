//
//  CocosNode.h
//  test-opengl2
//
//  Created by Ricardo Quesada on 29/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <UIKit/UIKit.h>

#import "Action.h"

@interface CocosNode : NSObject {

	// rotation angle
	float rotation;
	
	// scale factor
	float scale;
	
	// position of the node
	CGPoint position;

	// is visible
	BOOL visible;
	
	// transformation anchor point
	CGPoint transformAnchor;
	
	// where are the children placed (anchor)
	CGPoint childrenAnchor;
	
	// array of children
	NSMutableArray *children;
	
	// is running
	BOOL isRunning;
	
	// weakref to parent
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
+(id) node;
-(id) init;

// composition
-(void) add: (CocosNode*)node;
-(void) add: (CocosNode*)node z:(int)z;
-(void) remove: (CocosNode*)node;
-(void) onEnter;
-(void) onExit;

// draw
-(void) draw;
-(void) visit;
-(void) transform;

// actions
-(Action*) do: (Action*) action;
-(void) _step;

// timers
-(void) schedule: (SEL) method;
-(void) unschedule: (SEL) method;
-(void) activateTimers;
-(void) activateTimer: (SEL) method;
-(void) deactivateTimers;
@end
