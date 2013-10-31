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

/** Instant actions are immediate actions. They don't have a duration like
 the CCIntervalAction actions.
*/
@interface CCActionInstant : CCActionFiniteTime <NSCopying>
{
}
// XXX Needed for BridgeSupport
-(id) init;
@end

/** Show the node
 */
 @interface CCActionShow : CCActionInstant
{
}
// XXX Needed for BridgeSupport
-(void) update:(CCTime)time;
@end

/** Hide the node
 */
@interface CCActionHide : CCActionInstant
{
}
-(void) update:(CCTime)time;
@end

/** Toggles the visibility of a node
 */
@interface CCActionToggleVisibility : CCActionInstant
{
}
-(void) update:(CCTime)time;
@end

/** Flips the sprite horizontally
 @since v0.99.0
 */
@interface CCActionFlipX : CCActionInstant
{
	BOOL	_flipX;
}
+(id) actionWithFlipX:(BOOL)x;
-(id) initWithFlipX:(BOOL)x;
@end

/** Flips the sprite vertically
 @since v0.99.0
 */
@interface CCActionFlipY : CCActionInstant
{
	BOOL	_flipY;
}
+(id) actionWithFlipY:(BOOL)y;
-(id) initWithFlipY:(BOOL)y;
@end

/** Places the node in a certain position
 */
@interface CCActionPlace : CCActionInstant <NSCopying>
{
	CGPoint _position;
}
/** creates a Place action with a position */
+(id) actionWithPosition: (CGPoint) pos;
/** Initializes a Place action with a position */
-(id) initWithPosition: (CGPoint) pos;
@end

/** Calls a 'callback'
 */
@interface CCActionCallFunc : CCActionInstant <NSCopying>
{
	id _targetCallback;
	SEL _selector;
}

/** Target that will be called */
@property (nonatomic, readwrite, strong) id targetCallback;

/** creates the action with the callback */
+(id) actionWithTarget: (id) t selector:(SEL) s;
/** initializes the action with the callback */
-(id) initWithTarget: (id) t selector:(SEL) s;
/** executes the callback */
-(void) execute;
@end

#pragma mark Blocks Support

/** Executes a callback using a block.
 */
@interface CCActionCallBlock : CCActionInstant<NSCopying>
{
	void (^_block)();
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
