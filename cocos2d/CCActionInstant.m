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
		duration_ = 0;

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
	((CCNode *)target_).visible = YES;
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
	((CCNode *)target_).visible = NO;
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
	((CCNode *)target_).visible = !((CCNode *)target_).visible;
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
		flipX = x;

	return self;
}

-(void) update:(ccTime)time
{
	[(CCSprite*)target_ setFlipX:flipX];
}

-(CCFiniteTimeAction*) reverse
{
	return [CCFlipX actionWithFlipX:!flipX];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithFlipX:flipX];
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
		flipY = y;

	return self;
}

-(void) update:(ccTime)time
{
	[(CCSprite*)target_ setFlipY:flipY];
}

-(CCFiniteTimeAction*) reverse
{
	return [CCFlipY actionWithFlipY:!flipY];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithFlipY:flipY];
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
		position = pos;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithPosition: position];
	return copy;
}

-(void) update:(ccTime)time
{
	((CCNode *)target_).position = position;
}

@end

//
// CallFunc
//
#pragma mark CCCallFunc

@implementation CCCallFunc

@synthesize targetCallback = targetCallback_;

+(id) actionWithTarget: (id) t selector:(SEL) s
{
	return [[[self alloc] initWithTarget: t selector: s] autorelease];
}

-(id) initWithTarget: (id) t selector:(SEL) s
{
	if( (self=[super init]) ) {
		self.targetCallback = t;
		selector_ = s;
	}
	return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i | target = %@ | selector = %@>",
			[self class],
			self,
			tag_,
			[targetCallback_ class],
			NSStringFromSelector(selector_)
			];
}

-(void) dealloc
{
	[targetCallback_ release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback_ selector:selector_];
	return copy;
}

-(void) update:(ccTime)time
{
	[self execute];
}

-(void) execute
{
	[targetCallback_ performSelector:selector_];
}
@end

//
// CallFuncN
//
#pragma mark CCCallFuncN

@implementation CCCallFuncN

-(void) execute
{
	[targetCallback_ performSelector:selector_ withObject:target_];
}
@end

//
// CallFuncND
//
#pragma mark CCCallFuncND

@implementation CCCallFuncND

@synthesize callbackMethod = callbackMethod_;

+(id) actionWithTarget:(id)t selector:(SEL)s data:(void*)d
{
	return [[[self alloc] initWithTarget:t selector:s data:d] autorelease];
}

-(id) initWithTarget:(id)t selector:(SEL)s data:(void*)d
{
	if( (self=[super initWithTarget:t selector:s]) ) {
		data_ = d;

#if COCOS2D_DEBUG
		NSMethodSignature * sig = [t methodSignatureForSelector:s]; // added
		NSAssert(sig !=0 , @"Signature not found for selector - does it have the following form? -(void)name:(id)sender data:(void*)data");
#endif
		callbackMethod_ = (CC_CALLBACK_ND) [t methodForSelector:s];
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback_ selector:selector_ data:data_];
	return copy;
}

-(void) dealloc
{
	// nothing to dealloc really. Everything is dealloc on super (CCCallFuncN)
	[super dealloc];
}

-(void) execute
{
	callbackMethod_(targetCallback_,selector_,target_, data_);
}
@end

@implementation CCCallFuncO
@synthesize  object = object_;

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
	[object_ release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback_ selector:selector_ object:object_];
	return copy;
}


-(void) execute
{
	[targetCallback_ performSelector:selector_ withObject:object_];
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
		block_ = [block copy];

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithBlock:block_];
	return copy;
}

-(void) update:(ccTime)time
{
	[self execute];
}

-(void) execute
{
	block_();
}

-(void) dealloc
{
	[block_ release];
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
		block_ = [block copy];

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithBlock:block_];
	return copy;
}

-(void) update:(ccTime)time
{
	[self execute];
}

-(void) execute
{
	block_(target_);
}

-(void) dealloc
{
	[block_ release];
	[super dealloc];
}

@end

#pragma mark CCCallBlockO

@implementation CCCallBlockO

@synthesize object=object_;

+(id) actionWithBlock:(void(^)(id object))block object:(id)object
{
	return [[[self alloc] initWithBlock:block object:object] autorelease];
}

-(id) initWithBlock:(void(^)(id object))block object:(id)object
{
	if ((self = [super init])) {
		block_ = [block copy];
		object_ = [object retain];
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithBlock:block_];
	return copy;
}

-(void) update:(ccTime)time
{
	[self execute];
}

-(void) execute
{
	block_(object_);
}

-(void) dealloc
{
	[object_ release];
	[block_ release];

	[super dealloc];
}

@end

