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


#import "CCActionInstant.h"
#import "CCNode.h"
#import "CCSprite.h"
#import <objc/message.h>
#import "OALSimpleAudio.h"

//
// InstantAction
//
#pragma mark CCActionInstant

@implementation CCActionInstant

-(id) init
{
	if( (self=[super init]) )
		_duration = 0;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] init];
	return copy;
}

- (BOOL) isDone
{
	return YES;
}

-(void) step: (CCTime) dt
{
	[self update: 1];
}

-(void) update: (CCTime) t
{
	// nothing
}

-(CCActionFiniteTime*) reverse
{
	return [self copy];
}
@end

//
// Remove
//
#pragma mark CCActionRemove

@implementation CCActionRemove

+(id)action {
    return [[self alloc] init];
}

+(id)actionWithCleanUp:(BOOL)cleanup {
    return [[self alloc] initWithCleanUp:cleanup];
}

-(id)init {
    self = [super init];
    if (!self) return nil;
    
    _cleanUp = true;
    
    return self;
}

-(id)initWithCleanUp:(BOOL)cleanUp {
    self = [super init];
    if (!self) return nil;
    
    _cleanUp = cleanUp;
    
    return self;
}


-(void) update:(CCTime)time {
	[(CCNode *)_target removeFromParentAndCleanup:_cleanUp];
}
@end


//
// Show
//
#pragma mark CCShow

@implementation CCActionShow
-(void) update:(CCTime)time
{
	((CCNode *)_target).visible = YES;
}

-(CCActionFiniteTime*) reverse
{
	return [CCActionHide action];
}
@end

//
// Hide
//
#pragma mark CCHide

@implementation CCActionHide
-(void) update:(CCTime)time
{
	((CCNode *)_target).visible = NO;
}

-(CCActionFiniteTime*) reverse
{
	return [CCActionShow action];
}
@end

//
// ToggleVisibility
//
#pragma mark CCToggleVisibility

@implementation CCActionToggleVisibility
-(void) update:(CCTime)time
{
	((CCNode *)_target).visible = !((CCNode *)_target).visible;
}
@end

//
// FlipX
//
#pragma mark CCFlipX

@implementation CCActionFlipX
+(instancetype) actionWithFlipX:(BOOL)x
{
	return [[self alloc] initWithFlipX:x];
}

-(id) initWithFlipX:(BOOL)x
{
	if(( self=[super init]))
		_flipX = x;

	return self;
}

-(void) update:(CCTime)time
{
	[(CCSprite*)_target setFlipX:_flipX];
}

-(CCActionFiniteTime*) reverse
{
	return [CCActionFlipX actionWithFlipX:!_flipX];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithFlipX:_flipX];
	return copy;
}
@end

//
// FlipY
//
#pragma mark CCFlipY

@implementation CCActionFlipY
+(instancetype) actionWithFlipY:(BOOL)y
{
	return [[self alloc] initWithFlipY:y];
}

-(id) initWithFlipY:(BOOL)y
{
	if(( self=[super init]))
		_flipY = y;

	return self;
}

-(void) update:(CCTime)time
{
	[(CCSprite*)_target setFlipY:_flipY];
}

-(CCActionFiniteTime*) reverse
{
	return [CCActionFlipY actionWithFlipY:!_flipY];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithFlipY:_flipY];
	return copy;
}
@end


//
// Place
//
#pragma mark CCPlace

@implementation CCActionPlace
+(instancetype) actionWithPosition: (CGPoint) pos
{
	return [[self alloc]initWithPosition:pos];
}

-(id) initWithPosition: (CGPoint) pos
{
	if( (self=[super init]) )
		_position = pos;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithPosition: _position];
	return copy;
}

-(void) update:(CCTime)time
{
	((CCNode *)_target).position = _position;
}

@end

//
// CallFunc
//
#pragma mark CCCallFunc

@implementation CCActionCallFunc

@synthesize targetCallback = _targetCallback;

+(instancetype) actionWithTarget: (id) t selector:(SEL) s
{
	return [[self alloc] initWithTarget: t selector: s];
}

-(id) initWithTarget: (id) t selector:(SEL) s
{
	if( (self=[super init]) ) {
        
        NSAssert(t == nil || [t respondsToSelector:s], @"target cannot perform selector %@.",        NSStringFromSelector(s));
        
		self.targetCallback = t;
		_selector = s;
	}
	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %ld | selector = %@>",
			[self class],
			self,
			(long)_tag,
			NSStringFromSelector(_selector)
			];
}


-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithTarget:_targetCallback selector:_selector];
	return copy;
}

-(void) update:(CCTime)time
{
	[self execute];
}

-(void) execute
{
    typedef void (*Func)(id, SEL);
    ((Func)objc_msgSend)(_targetCallback, _selector);
}
@end


#pragma mark -
#pragma mark Blocks

#pragma mark CCCallBlock

@implementation CCActionCallBlock

+(instancetype) actionWithBlock:(void(^)())block
{
	return [[self alloc] initWithBlock:block];
}

-(id) initWithBlock:(void(^)())block
{
	if ((self = [super init]))
		_block = [block copy];

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithBlock:_block];
	return copy;
}

-(void) update:(CCTime)time
{
	[self execute];
}

-(void) execute
{
	_block();
}

@end


#pragma mark CCActionSpriteFrame
@implementation CCActionSpriteFrame

+ (id)actionWithSpriteFrame:(CCSpriteFrame*)spriteFrame;
{
	return [[self alloc]initWithSpriteFrame:spriteFrame];
}

- (id)initWithSpriteFrame:(CCSpriteFrame*)spriteFrame;
{
	if( (self=[super init]) )
		_spriteFrame = spriteFrame;
    
	return self;
}

- (id)copyWithZone:(NSZone*)zone
{
	CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithSpriteFrame:_spriteFrame];
	return copy;
}

- (void)update:(CCTime)time
{
	((CCSprite *)self.target).spriteFrame = _spriteFrame;
}

@end
