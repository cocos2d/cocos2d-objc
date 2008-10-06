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

#import "Action.h"

/** Instant actions are immediate actions. They don't have a duration like
 the Interval Actions.
*/ 
@interface InstantAction : Action <NSCopying>
{
	ccTime duration;
}
@property (readonly,assign) ccTime duration;

-(BOOL) isDone;
@end

/** Show the node
 */
 @interface Show : InstantAction
{
}
@end

/** Hide the node
 */
@interface Hide : InstantAction
{
}
@end

/** Toggles the visibility of a node
 */
@interface ToggleVisibility : InstantAction
{
}
@end

/** Places the node in a certain position
 */
@interface Place : InstantAction <NSCopying>
{
	cpVect position;
}
/** creates a Place action with a position */
+(id) actionWithPosition: (cpVect) pos;
/** Initializes a Place action with a position */
-(id) initWithPosition: (cpVect) pos;
@end

/** Calls a 'callback'
 */
@interface CallFunc : InstantAction <NSCopying>
{
	id targetCallback;
	SEL selector;
}
/** creates the action with the callback */
+(id) actionWithTarget: (id) t selector:(SEL) s;
/** initializes the action with the callback */
-(id) initWithTarget: (id) t selector:(SEL) s;
/** exeuctes the callback */
-(void) execute;
@end

/** Calls a 'callback' with the node as the first argument
 /* N means Node
 */
@interface CallFuncN : CallFunc
{
}
@end

/** Calls a 'callback' with the node as the first argument and the 2nd argument is data
 * ND means: Node Data
 */
@interface CallFuncND : CallFuncN
{
	void *data;
	NSInvocation *invocation;
}
/** creates the action with the callback and the data to pass as an argument */
+(id) actionWithTarget: (id) t selector:(SEL) s data:(void*)d;
/** initializes the action with the callback and the data to pass as an argument */
-(id) initWithTarget:(id) t selector:(SEL) s data:(void*) d;
@end
