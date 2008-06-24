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
	double duration;
}
@property (readonly,assign) double duration;

-(void) step;
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
	CGPoint position;
}
/** creates a Place action with a position */
+(id) actionWithPosition: (CGPoint) pos;
/** Initializes a Place action with a position */
-(id) initWithPosition: (CGPoint) pos;
@end

/** Calls a 'callback'
 */
@interface CallFunc : InstantAction <NSCopying>
{
	NSInvocation *invocation;
}
/** creates the action with the callback */
+(id) actionWithTarget: (id) receiver selector:(SEL) callback;
/** initializes the action with the callback */
-(id) initWithTarget: (id) receiver selector:(SEL) callback;
@end
