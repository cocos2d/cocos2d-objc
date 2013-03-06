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


#import "CCActionInstant.h"
#import "CCNode.h"
#import "CCSprite.h"


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

-(void) step: (ccTime) dt
{
	[self update: 1];
}

-(void) update: (ccTime) t
{
	// nothing
}

-(CCFiniteTimeAction*) reverse
{
	return [[self copy] autorelease];
}
@end

//
// Show
//
#pragma mark CCShow

@implementation CCShow
-(void) update:(ccTime)time
{
	((CCNode *)_target).visible = YES;
}

-(CCFiniteTimeAction*) reverse
{
	return [CCHide action];
}
@end

//
// Hide
//
#pragma mark CCHide

@implementation CCHide
-(void) update:(ccTime)time
{
	((CCNode *)_target).visible = NO;
}

-(CCFiniteTimeAction*) reverse
{
	return [CCShow action];
}
@end

//
// ToggleVisibility
//
#pragma mark CCToggleVisibility

@implementation CCToggleVisibility
-(void) update:(ccTime)time
{
	((CCNode *)_target).visible = !((CCNode *)_target).visible;
}
@end

//
// FlipX
//
#pragma mark CCFlipX

@implementation CCFlipX
+(id) actionWithFlipX:(BOOL)x
{
	return [[[self alloc] initWithFlipX:x] autorelease];
}

-(id) initWithFlipX:(BOOL)x
{
	if(( self=[super init]))
		_flipX = x;

	return self;
}

-(void) update:(ccTime)time
{
	[(CCSprite*)_target setFlipX:_flipX];
}

-(CCFiniteTimeAction*) reverse
{
	return [CCFlipX actionWithFlipX:!_flipX];
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

@implementation CCFlipY
+(id) actionWithFlipY:(BOOL)y
{
	return [[[self alloc] initWithFlipY:y] autorelease];
}

-(id) initWithFlipY:(BOOL)y
{
	if(( self=[super init]))
		_flipY = y;

	return self;
}

-(void) update:(ccTime)time
{
	[(CCSprite*)_target setFlipY:_flipY];
}

-(CCFiniteTimeAction*) reverse
{
	return [CCFlipY actionWithFlipY:!_flipY];
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

@implementation CCPlace
+(id) actionWithPosition: (CGPoint) pos
{
	return [[[self alloc]initWithPosition:pos]autorelease];
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

-(void) update:(ccTime)time
{
	((CCNode *)_target).position = _position;
}

@end

//
// CallFunc
//
#pragma mark CCCallFunc

@implementation CCCallFunc

@synthesize targetCallback = _targetCallback;

+(id) actionWithTarget: (id) t selector:(SEL) s
{
	return [[[self alloc] initWithTarget: t selector: s] autorelease];
}

-(id) initWithTarget: (id) t selector:(SEL) s
{
	if( (self=[super init]) ) {
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

-(void) dealloc
{
	[_targetCallback release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithTarget:_targetCallback selector:_selector];
	return copy;
}

-(void) update:(ccTime)time
{
	[self execute];
}

-(void) execute
{
	[_targetCallback performSelector:_selector];
}
@end

//
// CallFuncN
//
#pragma mark CCCallFuncN

@implementation CCCallFuncN

-(void) execute
{
	[_targetCallback performSelector:_selector withObject:_target];
}
@end

//
// CallFuncND
//
#pragma mark CCCallFuncND

@implementation CCCallFuncND

@synthesize callbackMethod = _callbackMethod;

+(id) actionWithTarget:(id)t selector:(SEL)s data:(void*)d
{
	return [[[self alloc] initWithTarget:t selector:s data:d] autorelease];
}

-(id) initWithTarget:(id)t selector:(SEL)s data:(void*)d
{
	if( (self=[super initWithTarget:t selector:s]) ) {
		_data = d;

#if COCOS2D_DEBUG
		NSMethodSignature * sig = [t methodSignatureForSelector:s]; // added
		NSAssert(sig !=0 , @"Signature not found for selector - does it have the following form? -(void)name:(id)sender data:(void*)data");
#endif
		_callbackMethod = (CC_CALLBACK_ND) [t methodForSelector:s];
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithTarget:_targetCallback selector:_selector data:_data];
	return copy;
}

-(void) dealloc
{
	// nothing to dealloc really. Everything is dealloc on super (CCCallFuncN)
	[super dealloc];
}

-(void) execute
{
	_callbackMethod(_targetCallback,_selector,_target, _data);
}
@end

@implementation CCCallFuncO
@synthesize  object = _object;

+(id) actionWithTarget: (id) t selector:(SEL) s object:(id)object
{
	return [[[self alloc] initWithTarget:t selector:s object:object] autorelease];
}

-(id) initWithTarget:(id) t selector:(SEL) s object:(id)object
{
	if( (self=[super initWithTarget:t selector:s] ) )
		self.object = object;

	return self;
}

- (void) dealloc
{
	[_object release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithTarget:_targetCallback selector:_selector object:_object];
	return copy;
}


-(void) execute
{
	[_targetCallback performSelector:_selector withObject:_object];
}

@end


#pragma mark -
#pragma mark Blocks

#pragma mark CCCallBlock

@implementation CCCallBlock

+(id) actionWithBlock:(void(^)())block
{
	return [[[self alloc] initWithBlock:block] autorelease];
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

-(void) update:(ccTime)time
{
	[self execute];
}

-(void) execute
{
	_block();
}

-(void) dealloc
{
	[_block release];
	[super dealloc];
}

@end

#pragma mark CCCallBlockN

@implementation CCCallBlockN

+(id) actionWithBlock:(void(^)(CCNode *node))block
{
	return [[[self alloc] initWithBlock:block] autorelease];
}

-(id) initWithBlock:(void(^)(CCNode *node))block
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

-(void) update:(ccTime)time
{
	[self execute];
}

-(void) execute
{
	_block(_target);
}

-(void) dealloc
{
	[_block release];
	[super dealloc];
}

@end

#pragma mark CCCallBlockO

@implementation CCCallBlockO

@synthesize object=_object;

+(id) actionWithBlock:(void(^)(id object))block object:(id)object
{
	return [[[self alloc] initWithBlock:block object:object] autorelease];
}

-(id) initWithBlock:(void(^)(id object))block object:(id)object
{
	if ((self = [super init])) {
		_block = [block copy];
		_object = [object retain];
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithBlock:_block];
	return copy;
}

-(void) update:(ccTime)time
{
	[self execute];
}

-(void) execute
{
	_block(_object);
}

-(void) dealloc
{
	[_object release];
	[_block release];

	[super dealloc];
}

@end

