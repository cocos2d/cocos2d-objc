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


#import <UIKit/UIKit.h>

#import "Action.h"

/** Instant actions are immediate actions. They don't have a duration like
 the Interval Actions.
*/ 
@interface InstantAction : FiniteTimeAction <NSCopying>
{}
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
 N means Node
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
