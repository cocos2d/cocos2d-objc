/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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

#import "CCAction.h"

/** Instant actions are immediate actions. They don't have a duration like
 the CCIntervalAction actions.
*/ 
@interface CCInstantAction : CCFiniteTimeAction <NSCopying>
{}
@end

/** Show the node
 */
 @interface CCShow : CCInstantAction
{
}
@end

/** Hide the node
 */
@interface CCHide : CCInstantAction
{
}
@end

/** Toggles the visibility of a node
 */
@interface CCToggleVisibility : CCInstantAction
{
}
@end

/** Flips the sprite horizontally
 @since v0.9.0
 */
@interface CCFlipX : CCInstantAction
{
	BOOL	flipX;
}
+(id) actionWithFlipX:(BOOL)x;
-(id) initWithFlipX:(BOOL)x;
@end

/** Flips the sprite vertically
 @since v0.9.0
 */
@interface CCFlipY : CCInstantAction
{
	BOOL	flipY;
}
+(id) actionWithFlipY:(BOOL)y;
-(id) initWithFlipY:(BOOL)y;
@end

/** Places the node in a certain position
 */
@interface CCPlace : CCInstantAction <NSCopying>
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
@interface CCCallFunc : CCInstantAction <NSCopying>
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
@interface CCCallFuncN : CCCallFunc
{
}
@end

/** Calls a 'callback' with the node as the first argument and the 2nd argument is data
 * ND means: Node Data
 */
@interface CCCallFuncND : CCCallFuncN
{
	void *data;
	NSInvocation *invocation_;
}

/** Invocation object that has the target#selector and the parameters */
@property (nonatomic,readwrite,retain) NSInvocation *invocation;

/** creates the action with the callback and the data to pass as an argument */
+(id) actionWithTarget: (id) t selector:(SEL) s data:(void*)d;
/** initializes the action with the callback and the data to pass as an argument */
-(id) initWithTarget:(id) t selector:(SEL) s data:(void*) d;
@end
