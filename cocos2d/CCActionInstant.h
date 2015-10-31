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

/**
 Base class for instant actions, ie actions which perform their task immediately and quit.
 
 ### Subclasses
 
 - CCActionCallBlock, CCActionCallFunc (runs a block or runs a selector on a given target)
 - CCActionFlipX, CCActionFlipY (sets the flipX / flipY properties of a CCSprite)
 - CCActionPlace (sets the position property of a CCNode)
 - CCActionRemove (removes a CCNode from its parent by calling removeFromParent)
 - CCActionShow, CCActionHide, CCActionToggleVisibility (sets the visible property of a CCNode)
 - CCActionSoundEffect (plays a sound effect via OALSimpleAudio)
 - CCActionSpriteFrame (sets the spriteFrame property of a CCSprite)
*/
@interface CCActionInstant : CCActionFiniteTime <NSCopying>

@end


/** This action will remove the node running this action from its parent.
 
 The action is created using the default CCAction initializer:
 
    id action = [CCActionRemove action];
 */
@interface CCActionRemove : CCActionInstant {
    BOOL _cleanUp;
}

+(id)action;
+(id)actionWithCleanUp:(BOOL)cleanup;

@end


/** 
 This action will make the target visible by setting its `visible` property to YES.

 The action is created using the default CCAction initializer:
 
    id action = [CCActionShow action];
 */
@interface CCActionShow : CCActionInstant

@end


/** 
 This action will hide the target by setting its `visible` property to NO.
 
 The action is created using the default CCAction initializer:
 
    id action = [CCActionHide action];
 */
@interface CCActionHide : CCActionInstant

@end


/** 
 This action toggles the target's visibility by altering the `visible` property.

 The action is created using the default CCAction initializer:
 
    id action = [CCActionToggleVisibility action];
 */
@interface CCActionToggleVisibility : CCActionInstant

@end


/** 
 This action flips the target in x direction.

 @note Target must be a CCSprite node or inherit from CCSprite.
 */
@interface CCActionFlipX : CCActionInstant {
	BOOL	_flipX;
}


/// -----------------------------------------------------------------------
/// @name Creating a Flip Action
/// -----------------------------------------------------------------------

/**
 *  Creates a flip action with x direction flipped or non flipped.
 *
 *  @param x Defines if target is flipped.
 *
 *  @return The flip action object.
 */
+ (id)actionWithFlipX:(BOOL)x;

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
 This action will lips the target in y direction.
 
 @note Target must be a CCSprite node or inherit from CCSprite.
 */
@interface CCActionFlipY : CCActionInstant {
	BOOL	_flipY;
}


/// -----------------------------------------------------------------------
/// @name Creating a Flip Action
/// -----------------------------------------------------------------------

/**
 *  Creates a flip action with y direction flipped or non flipped.
 *
 *  @param y Defines if target is flipped.
 *
 *  @return The flip action object.
 */
+ (id)actionWithFlipY:(BOOL)y;

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
 *  This action will set the target's `position` property.
 */
@interface CCActionPlace : CCActionInstant <NSCopying> {
	CGPoint _position;
}


/// -----------------------------------------------------------------------
/// @name Creating a Place Action
/// -----------------------------------------------------------------------

/**
 *  Creates a place action using the specified position.
 *
 *  @param pos The position the target is placed at.
 *
 *  @return The place action object.
 */
+ (id)actionWithPosition:(CGPoint)pos;

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
 This action allows a custom selector to be called. The selector takes no arguments and returns nothing.

 ### Passing Parameters
 
 The selector takes no parameters. Any parameter that the selector needs would have to be in an ivar or property.
 
 It is often preferable to use CCActionCallBlock if you need to "pass in data" without having to add and assign a ivar/property.

 ### Code Example
 
    id callFunc = [CCActionCallFunc actionWithTarget:self selector@selector(myCallFuncMethod)];
    [self runAction:callFunc];
 
 The method needs to be declared as follows within the target's class (here: the class `self` is an instance of):
 
    -(void) myCallFuncMethod {
        NSLog(@"call func action ran my method");
    }
 
 Note that this simple example above is equivalent (but not as efficient) than simply calling the method directly:
 
    [self myCallFuncMethod];
 */
@interface CCActionCallFunc : CCActionInstant <NSCopying> {
	__weak id _targetCallback;
	SEL _selector;
}

// purposefully undocumented: there's little to no need to change the action's target
/* Target for the selector that will be called. */
@property (nonatomic, readwrite, weak) id targetCallback;


/// -----------------------------------------------------------------------
/// @name Creating a Perform Selector Action
/// -----------------------------------------------------------------------

/**
 *  Creates the action with the callback.
 *
 *  @param t Target the selector is sent to.
 *  @param s Selector to execute. Selector takes no parameters and returns nothing.
 *
 *  @return The call func action object.
 */
+ (id)actionWithTarget:(id)t selector:(SEL)s;

/**
 *  Initializes the action with the callback.
 *
 *  @param t Target the selector is sent to
 *  @param s Selector to execute. Selector takes no parameters and returns nothing.
 *
 *  @return An initialized call func action object.
 */
- (id)initWithTarget:(id)t selector:(SEL)s;

// Executes the selector on the specific target.
- (void)execute;

@end


/** 
 This action executes a code block. The block takes no parameters and returns nothing.
 
 ### Passing Parameters
 
 Blocks can access all variables in scope, both variables local to the method as well as instance variables. 
 Local variables require to be declared with the `__block` keyword if the block needs to modify the variable.
 
 Running a block is often preferable to running a selector because the CCActionCallFunc selector can not accept parameters.
 
 ### Memory Management
 
 To avoid potential memory management issues it is recommended to use a weak self reference inside
 the block. If you are knowledgeable about [memory management with ARC and blocks](http://stackoverflow.com/questions/20030873/always-pass-weak-reference-of-self-into-block-in-arc)
 you can omit the weakSelf reference at your discretion.
 
 ### Code Example
 
 Example block that reads and modifies a variable in scope and rotates a node to illustrate the code syntax:

    __weak typeof(self) weakSelf = self;
    __block BOOL blockDidRun = NO;
 
    id callBlock = [CCActionCallBlock actionWithBlock:^{
        if (blockDidRun == NO) {
            blockDidRun = YES;
            weakSelf.rotation += 90;
        }
    }];
 
    [self runAction:callBlock];
 
 @see [Blocks Programming Guide](https://developer.apple.com/library/ios/documentation/cocoa/Conceptual/Blocks/Articles/00_Introduction.html)
 */
@interface CCActionCallBlock : CCActionInstant<NSCopying> {
	void (^_block)();
}


/// -----------------------------------------------------------------------
/// @name Creating a Run Block Action
/// -----------------------------------------------------------------------

/**
 *  Creates the action with the specified block, to be used as a callback.
 *  The block will be copied.
 *
 *  @param block Block to run. Block takes no parameters, returns nothing.
 *
 *  @return The call block action.
 */
+ (id)actionWithBlock:(void(^)())block;

/**
 *  Initializes the action with the specified block, to be used as a callback.
 *  The block will be copied.
 *
 *  @param block Block to run. Block takes no parameters, returns nothing.
 *
 *  @return An initialized call block action.
 */
- (id)initWithBlock:(void(^)())block;

// Executes the selector on the specific target.
- (void)execute;

@end


/**
 This actions changes the target's `spriteFrame` property.
 
 @note The target node must be a CCSprite or subclass of CCSprite or have a `CCSpriteFrame* spriteFrame` property.
 */
@interface CCActionSpriteFrame : CCActionInstant <NSCopying>
{
	CCSpriteFrame* _spriteFrame;
}

/// -----------------------------------------------------------------------
/// @name Creating a Sprite Frame Action
/// -----------------------------------------------------------------------

/**
 *  Creates the action action with the specified sprite frame.
 *
 *  @param spriteFrame SpriteFrame to use.
 *
 *  @return The sprite frame action object.
 *  @see CCSpriteFrame
 */
+(instancetype) actionWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

/**
 *  Initializes the action action with the specified sprite frame.
 *
 *  @param spriteFrame SpriteFrame to use.
 *
 *  @return An initialized sprite frame action object.
 *  @see CCSpriteFrame
 */
-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame;

@end

/**
 This actions plays a sound effect through OALSimpleAudio. To play back music use a CCActionCallBlock or CCActionCallFunc
 so that you can use the playBg method of OALSimpleAudio.
 
 @note The action ends immediately, it does not wait for the sound to stop playing. */
@interface CCActionSoundEffect : CCActionInstant
{
    NSString* _soundFile;
    float _pitch;
    float _pan;
    float _gain;
}

/** @name Creating a Sound Effect Action */

/**
 Creates a sound effect action.
 
 @param file The audio file to play.
 @param pitch The playback pitch. 1.0 equals *normal* pitch.
 @param pan Stereo panning, values from -1.0 (far left) to 1.0 (far right).
 @param gain Gain (loudness), default 1.0 equals *normal* volume.
 
 @see OALSimpleAudio
 @see [OALSimpleAudio playEffect:volume:pitch:pan:loop:]
 */
+(instancetype) actionWithSoundFile:(NSString*)file pitch:(float)pitch pan:(float) pan gain:(float)gain;

/**
 Creates a sound effect action.
 
 @param file The audio file to play.
 @param pitch The playback pitch. 1.0 equals *normal* pitch.
 @param pan Stereo panning, values from -1.0 (far left) to 1.0 (far right).
 @param gain Gain (loudness), default 1.0 equals *normal* volume.
 
 @see OALSimpleAudio
 @see [OALSimpleAudio playEffect:volume:pitch:pan:loop:]
 */
-(id) initWithSoundFile:(NSString*)file pitch:(float)pitch pan:(float) pan gain:(float)gain;

@end
