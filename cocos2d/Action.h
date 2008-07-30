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

#import <UIKit/UIKit.h>
#include <sys/time.h>

#import "types.h"
#import "chipmunk.h"

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
-(void) step: (ccTime) dt;
//! called once per frame. time a value between 0 and 1
//! For example: 
//! * 0 means that the action just started
//! * 0.5 means that the action is in the middle
//! * 1 means that the action is over
-(void) update: (ccTime) time;

@end
