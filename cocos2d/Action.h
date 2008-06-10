//
//  Action.h
//  test-opengl2
//
//  Created by Ricardo Quesada on 30/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#include <sys/time.h>

@class CocosNode;
/** Base class for actions
 */
@interface Action : NSObject <NSCopying> {
	CocosNode *target;	
}

@property (readwrite,retain) CocosNode *target;

+(id) action;
-(id) init;

-(id) copyWithZone: (NSZone*) zone;

//! called before the action start
-(void) start;
//! return YES if the action has finished
-(BOOL) isDone;
//! called after the action has finished
-(void) stop;
-(void) step;
//! called once per frame. time a value between 0 and 1
//! For example: 
//! * 0 means that the action just started
//! * 0.5 means that the action is in the middle
//! * 1 means that the action is over
-(void) update: (double) time;

@end