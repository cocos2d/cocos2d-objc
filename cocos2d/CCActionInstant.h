/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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

// -----------------------------------------------------------------
/** @name CCActionInstant */

/** 
 *  Instant actions are immediate actions. 
 *  They don't have a duration like the CCIntervalAction actions.
 */
@interface CCActionInstant : CCActionFiniteTime <NSCopying>
{
}

// XXX Needed for BridgeSupport
-(id) init;

@end

// -----------------------------------------------------------------
/** @name CCActionShow */

/** 
 *  Shows the target.
 */
 @interface CCActionShow : CCActionInstant
{
}

// Needed for BridgeSupport
-(void) update:(CCTime)time;

@end

// -----------------------------------------------------------------
/** @name CCActionHide */

/** 
 *  Hides the target.
 */
@interface CCActionHide : CCActionInstant
{
}

// Needed for BridgeSupport
-(void) update:(CCTime)time;

@end

// -----------------------------------------------------------------
/** @name CCActionToggleVisibility */

/** 
 *  Toggles the visibility of a target.
 */
@interface CCActionToggleVisibility : CCActionInstant
{
}

// Needed for BridgeSupport
-(void) update:(CCTime)time;

@end

// -----------------------------------------------------------------
/** @name CCActionFlipX */

/** 
 *  Flips the target in x direction.
 */
@interface CCActionFlipX : CCActionInstant
{
	BOOL	_flipX;
}

/**
 *  Creates a flip action with x direction flipped or non flipped
 *
 *  @param x Defines if target is flipped
 *
 *  @return New flip action
 */
+(id) actionWithFlipX:(BOOL)x;

/**
 *  Initializes a flip action with x direction flipped or non flipped
 *
 *  @param x Defines if target is flipped
 *
 *  @return New flip action
 */
-(id) initWithFlipX:(BOOL)x;

@end

// -----------------------------------------------------------------
/** @name CCActionFlipY */

/** 
 *  Flips the target in y direction.
 */
@interface CCActionFlipY : CCActionInstant
{
	BOOL	_flipY;
}

/**
 *  Creates a flip action with y direction flipped or non flipped
 *
 *  @param y Defines if target is flipped
 *
 *  @return New flip action
 */
+(id) actionWithFlipY:(BOOL)y;

/**
 *  Initializes a flip action with y direction flipped or non flipped
 *
 *  @param y Defines if target is flipped
 *
 *  @return New flip action
 */
-(id) initWithFlipY:(BOOL)y;

@end

// -----------------------------------------------------------------
/** @name CCActionPlace */

/** 
 *  Places the target in a certain position
 */
@interface CCActionPlace : CCActionInstant <NSCopying>
{
	CGPoint _position;
}

/**
 *  Creates a place action
 *
 *  @param pos The position the target is placed at
 *
 *  @return New place action
 */
+(id) actionWithPosition: (CGPoint) pos;

/**
 *  Initializes a place action
 *
 *  @param pos The position the target is placed at
 *
 *  @return New place action
 */
-(id) initWithPosition: (CGPoint) pos;

@end

// -----------------------------------------------------------------
/** @name CCActionCallFunc */

/** 
 *  Calls a selector on a specific target
 */
@interface CCActionCallFunc : CCActionInstant <NSCopying>
{
	id _targetCallback;
	SEL _selector;
}

/** 
 *  Target that will be called 
 */
@property (nonatomic, readwrite, strong) id targetCallback;

/**
 *  Creates the action with the callback.
 *
 *  @param t Target the selector is sent to
 *  @param s Selector to execute
 *
 *  @return New call func action
 */
+(id) actionWithTarget: (id) t selector:(SEL) s;

/**
 *  Initializes the action with the callback.
 *
 *  @param t Target the selector is sent to
 *  @param s Selector to execute
 *
 *  @return New call func action
 */
-(id) initWithTarget: (id) t selector:(SEL) s;

/**
 *  Executes the selector on the specific target
 */
-(void) execute;

@end

#pragma mark Blocks Support

// -----------------------------------------------------------------
/** @name CCActionCallBlock */

/** 
 *  Executes a callback using a block.
 */
@interface CCActionCallBlock : CCActionInstant<NSCopying>
{
	void (^_block)();
}

/**
 *  Creates the action with the specified block, to be used as a callback.
 *  The block will be "copied".
 *
 *  @param block Block to execute
 *
 *  @return New call block action
 */
+(id) actionWithBlock:(void(^)())block;

/**
 *  Initializes the action with the specified block, to be used as a callback.
 *  The block will be "copied".
 *
 *  @param block Block to execute
 *
 *  @return New call block action
 */
-(id) initWithBlock:(void(^)())block;

/**
 *  Executes the block
 */
-(void) execute;

@end
