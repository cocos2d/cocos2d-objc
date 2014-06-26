/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
#import "CCSpriteFrame.h"

//
// Base class for instant actions, e.g. they are performed immediately.
//
@interface CCActionInstant : CCActionFiniteTime <NSCopying>

@end


/** This action will remove the target from its parent node. */
@interface CCActionRemove : CCActionInstant

@end


/** 
 *  This action will make the target visible.
 */
@interface CCActionShow : CCActionInstant

@end


/** 
 *  This action will hide the target.
 */
@interface CCActionHide : CCActionInstant

@end


/** 
 *  This action toggles the target's visibility.
 */
@interface CCActionToggleVisibility : CCActionInstant

@end


/** 
 *  This action flips the target in x direction.
 */
@interface CCActionFlipX : CCActionInstant {
	BOOL	_flipX;
}


/// -----------------------------------------------------------------------
/// @name Creating a CCActionFlipX Object
/// -----------------------------------------------------------------------

/**
 *  Creates a flip action with x direction flipped or non flipped.
 *
 *  @param x Defines if target is flipped.
 *
 *  @return The flip action object.
 */
+ (id)actionWithFlipX:(BOOL)x;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionFlipX Object
/// -----------------------------------------------------------------------

/**
 *  Initializes a flip action with x direction flipped or non flipped.
 *
 *  @param x Defines if target is flipped.
 *
 *  @return An initialized flip action object.
 */
- (id)initWithFlipX:(BOOL)x;

@end


/** 
 *  This action will lips the target in y direction.
 */
@interface CCActionFlipY : CCActionInstant {
	BOOL	_flipY;
}


/// -----------------------------------------------------------------------
/// @name Creating a CCActionFlipY Object
/// -----------------------------------------------------------------------

/**
 *  Creates a flip action with y direction flipped or non flipped.
 *
 *  @param y Defines if target is flipped.
 *
 *  @return The flip action object.
 */
+ (id)actionWithFlipY:(BOOL)y;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionFlipY Object
/// -----------------------------------------------------------------------

/**
 *  Initializes a flip action with y direction flipped or non flipped
 *
 *  @param y Defines if target is flipped
 *
 *  @return The initialized flip action object.
 */
- (id)initWithFlipY:(BOOL)y;

@end


/** 
 *  This action will teleport a target to the specififed position.
 */
@interface CCActionPlace : CCActionInstant <NSCopying> {
	CGPoint _position;
}


/// -----------------------------------------------------------------------
/// @name Creating a CCActionPlace Object
/// -----------------------------------------------------------------------

/**
 *  Creates a place action using the specified position.
 *
 *  @param pos The position the target is placed at.
 *
 *  @return The place action object.
 */
+ (id)actionWithPosition:(CGPoint)pos;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionPlace Object
/// -----------------------------------------------------------------------

/**
 *  Initializes a place action using the specified position.
 *
 *  @param pos The position the target is placed at
 *
 *  @return An initialized place action object.
 */
- (id)initWithPosition:(CGPoint)pos;

@end


/**
 *  This action allows a custom function to be called.
 */
@interface CCActionCallFunc : CCActionInstant <NSCopying> {
	__weak id _targetCallback;
	SEL _selector;
}

/** Target function that will be called. */
@property (nonatomic, readwrite, weak) id targetCallback;


/// -----------------------------------------------------------------------
/// @name Creating a CCActionCallFunc Object
/// -----------------------------------------------------------------------

/**
 *  Creates the action with the callback.
 *
 *  @param t Target the selector is sent to.
 *  @param s Selector to execute.
 *
 *  @return The call func action object.
 */
+ (id)actionWithTarget:(id)t selector:(SEL)s;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionCallFunc Object
/// -----------------------------------------------------------------------

/**
 *  Initializes the action with the callback.
 *
 *  @param t Target the selector is sent to
 *  @param s Selector to execute
 *
 *  @return An initialized call func action object.
 */
- (id)initWithTarget:(id)t selector:(SEL)s;

// Executes the selector on the specific target.
- (void)execute;

@end


/** 
 *  This actions executes a code block.
 */
@interface CCActionCallBlock : CCActionInstant<NSCopying> {
	void (^_block)();
}


/// -----------------------------------------------------------------------
/// @name Creating a CCActionCallBlock Object
/// -----------------------------------------------------------------------

/**
 *  Creates the action with the specified block, to be used as a callback.
 *  The block will be "copied".
 *
 *  @param block Block to execute.
 *
 *  @return The call block action object.
 */
+ (id)actionWithBlock:(void(^)())block;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionCallBlock Object
/// -----------------------------------------------------------------------

/**
 *  Initializes the action with the specified block, to be used as a callback.
 *  The block will be "copied".
 *
 *  @param block Block to execute.
 *
 *  @return An initialized call block action object.
 */
- (id)initWithBlock:(void(^)())block;

// Executes the selector on the specific target.
- (void)execute;

@end


/**
 *  This actions changes the target sprite frame.
 */
@interface CCActionSpriteFrame : CCActionInstant <NSCopying>
{
	CCSpriteFrame* _spriteFrame;
}

/// -----------------------------------------------------------------------
/// @name Creating a CCActionSpriteFrame Object
/// -----------------------------------------------------------------------

/**
 *  Creates the action action with the specified sprite frame.
 *
 *  @param spriteFrame SpriteFrame to use.
 *
 *  @return The sprite frame action object.
 */
+(id) actionWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/// -----------------------------------------------------------------------
/// @name Initializing a CCActionSpriteFrame Object
/// -----------------------------------------------------------------------

/**
 *  Initializes the action action with the specified sprite frame.
 *
 *  @param spriteFrame SpriteFrame to use.
 *
 *  @return An initialized sprite frame action object.
 */
-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

@end

/**
 *  This actions plays a sound effect.
 */
@interface CCActionSoundEffect : CCActionInstant
{
    NSString* _soundFile;
    float _pitch;
    float _pan;
    float _gain;
}

/// -----------------------------------------------------------------------
/// @name Creating a CCActionSoundEffect Object
/// -----------------------------------------------------------------------
+(id) actionWithSoundFile:(NSString*)file pitch:(float)pitch pan:(float) pan gain:(float)gain;


/// -----------------------------------------------------------------------
/// @name Initializing a CCActionSoundEffect Object
/// -----------------------------------------------------------------------

-(id) initWithSoundFile:(NSString*)file pitch:(float)pitch pan:(float) pan gain:(float)gain;

@end
