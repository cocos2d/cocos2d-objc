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


#import "CCInstantAction.h"
#import "CCNode.h"
#import "CCSprite.h"

//
// InstantAction
//
@implementation CCInstantAction

-(id) init
{
	if( (self=[super init]) )	
		duration = 0;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCInstantAction *copy = [[[self class] allocWithZone: zone] init];
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
	// ignore
}
-(CCFiniteTimeAction*) reverse
{
	return [[self copy] autorelease];
}
@end

//
// Show
//
@implementation CCShow
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	((CCNode *)target).visible = YES;
}
-(CCFiniteTimeAction*) reverse
{
	return [CCHide action];
}
@end

//
// Hide
//
@implementation CCHide
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	((CCNode *)target).visible = NO;
}
-(CCFiniteTimeAction*) reverse
{
	return [CCShow action];
}
@end

//
// ToggleVisibility
//
@implementation CCToggleVisibility
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	((CCNode *)target).visible = !((CCNode *)target).visible;
}
@end

//
// FlipX
//
@implementation CCFlipX
+(id) actionWithFlipX:(BOOL)x
{
	return [[[self alloc] initWithFlipX:x] autorelease];
}

-(id) initWithFlipX:(BOOL)x
{
	if(( self=[super init])) {
		flipX = x;
	}
	
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[(CCSprite*)aTarget setFlipX:flipX];
}

-(CCFiniteTimeAction*) reverse
{
	return [CCFlipX actionWithFlipX:!flipX];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCInstantAction *copy = [[[self class] allocWithZone: zone] initWithFlipX:flipX];
	return copy;
}
@end

//
// FlipY
//
@implementation CCFlipY
+(id) actionWithFlipY:(BOOL)y
{
	return [[[self alloc] initWithFlipY:y] autorelease];
}

-(id) initWithFlipY:(BOOL)y
{
	if(( self=[super init])) {
		flipY = y;
	}
	
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[(CCSprite*)aTarget setFlipY:flipY];
}

-(CCFiniteTimeAction*) reverse
{
	return [CCFlipY actionWithFlipY:!flipY];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCInstantAction *copy = [[[self class] allocWithZone: zone] initWithFlipY:flipY];
	return copy;
}
@end


//
// Place
//
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
	CCInstantAction *copy = [[[self class] allocWithZone: zone] initWithPosition: position];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	((CCNode *)target).position = position;
}
@end

//
// CallFunc
//
@implementation CCCallFunc
+(id) actionWithTarget: (id) t selector:(SEL) s
{
	return [[[self alloc] initWithTarget: t selector: s] autorelease];
}

-(id) initWithTarget: (id) t selector:(SEL) s
{
	if( (self=[super init]) ) {
		targetCallback = [t retain];
		selector = s;
	}
	return self;
}

-(void) dealloc
{
	[targetCallback release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCInstantAction *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback selector:selector];
	return copy;
}


-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[self execute];
}

-(void) execute
{
	[targetCallback performSelector:selector];
}
@end

//
// CallFuncN
//
@implementation CCCallFuncN

-(void) execute
{
	[targetCallback performSelector:selector withObject:target];
}
@end

//
// CallFuncND
//
@implementation CCCallFuncND

@synthesize invocation = invocation_;

+(id) actionWithTarget: (id) t selector:(SEL) s data:(void*) d
{
	return [[[self alloc] initWithTarget: t selector: s data:d] autorelease];
}

-(id) initWithTarget:(id) t selector:(SEL) s data:(void*) d
{
	if( (self=[super initWithTarget:t selector:s]) ) {
		data = d;	
		NSMethodSignature * sig = [[t class] instanceMethodSignatureForSelector:s];
		self.invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation_ setTarget:t];
		[invocation_ setSelector:s];
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCInstantAction *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback selector:selector data:data];
	return copy;
}


-(void) dealloc
{
	[invocation_ release];
	[super dealloc];
}

-(void) execute
{
	[invocation_ setArgument:&target atIndex:2];
	[invocation_ setArgument:&data atIndex:3];
	[invocation_ invoke];
}
@end
