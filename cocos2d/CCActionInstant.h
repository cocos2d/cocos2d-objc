/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "CCAction.h"

/** Instant actions are immediate actions. They don't have a duration like
 the CCIntervalAction actions.
*/ 
@interface CCActionInstant : CCFiniteTimeAction <NSCopying>
{
}
@end

/** Show the node
 */
 @interface CCShow : CCActionInstant
{
}
@end

/** Hide the node
 */
@interface CCHide : CCActionInstant
{
}
@end

/** Toggles the visibility of a node
 */
@interface CCToggleVisibility : CCActionInstant
{
}
@end

/** Flips the sprite horizontally
 @since v0.99.0
 */
@interface CCFlipX : CCActionInstant
{
	BOOL	flipX;
}
+(id) actionWithFlipX:(BOOL)x;
-(id) initWithFlipX:(BOOL)x;
@end

/** Flips the sprite vertically
 @since v0.99.0
 */
@interface CCFlipY : CCActionInstant
{
	BOOL	flipY;
}
+(id) actionWithFlipY:(BOOL)y;
-(id) initWithFlipY:(BOOL)y;
@end

/** Places the node in a certain position
 */
@interface CCPlace : CCActionInstant <NSCopying>
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
@interface CCCallFunc : CCActionInstant <NSCopying>
{
	id targetCallback_;
	SEL selector_;
}

/** Target that will be called */
@property (nonatomic, readwrite, retain) id targetCallback;

/** creates the action with the callback */
+(id) actionWithTarget: (id) t selector:(SEL) s;
/** initializes the action with the callback */
-(id) initWithTarget: (id) t selector:(SEL) s;
/** exeuctes the callback */
-(void) execute;
@end

/** Calls a 'callback' with the node as the first argument.
 N means Node
 */
@interface CCCallFuncN : CCCallFunc
{
}
@end

typedef void (*CC_CALLBACK_ND)(id, SEL, id, void *);
/** Calls a 'callback' with the node as the first argument and the 2nd argument is data.
 * ND means: Node and Data. Data is void *, so it could be anything.
 */
@interface CCCallFuncND : CCCallFuncN
{
	void			*data_;
	CC_CALLBACK_ND	callbackMethod_;
}

/** Invocation object that has the target#selector and the parameters */
@property (nonatomic,readwrite) CC_CALLBACK_ND callbackMethod;

/** creates the action with the callback and the data to pass as an argument */
+(id) actionWithTarget: (id) t selector:(SEL) s data:(void*)d;
/** initializes the action with the callback and the data to pass as an argument */
-(id) initWithTarget:(id) t selector:(SEL) s data:(void*) d;
@end

/** Calls a 'callback' with an object as the first argument.
 O means Object.
 @since v0.99.5
 */
@interface CCCallFuncO : CCCallFunc
{
	id	object_;
}
/** object to be passed as argument */
@property (nonatomic, readwrite, retain) id object;

/** creates the action with the callback and the object to pass as an argument */
+(id) actionWithTarget: (id) t selector:(SEL) s object:(id)object;
/** initializes the action with the callback and the object to pass as an argument */
-(id) initWithTarget:(id) t selector:(SEL) s object:(id)object;

@end

#pragma mark Blocks Support

#if NS_BLOCKS_AVAILABLE

/** Executes a callback using a block.
 */
@interface CCCallBlock : CCActionInstant<NSCopying>
{
	void (^block_)();
}

/** creates the action with the specified block, to be used as a callback.
 The block will be "copied".
 */
+(id) actionWithBlock:(void(^)())block;

/** initialized the action with the specified block, to be used as a callback.
 The block will be "copied".
 */
-(id) initWithBlock:(void(^)())block;

/** executes the callback */
-(void) execute;
@end

@class CCNode;

/** Executes a callback using a block with a single CCNode parameter.
 */
@interface CCCallBlockN : CCActionInstant<NSCopying>
{
	void (^block_)(CCNode *);
}

/** creates the action with the specified block, to be used as a callback.
 The block will be "copied".
 */
+(id) actionWithBlock:(void(^)(CCNode *node))block;

/** initialized the action with the specified block, to be used as a callback.
 The block will be "copied".
 */
-(id) initWithBlock:(void(^)(CCNode *node))block;

/** executes the callback */
-(void) execute;
@end

#endif
