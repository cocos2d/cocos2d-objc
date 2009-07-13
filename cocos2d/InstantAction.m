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


#import "InstantAction.h"
#import "CocosNode.h"

//
// InstantAction
//
@implementation InstantAction

-(id) init
{
	if( (self=[super init]) )	
		duration = 0;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	InstantAction *copy = [[[self class] allocWithZone: zone] init];
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
-(FiniteTimeAction*) reverse
{
	return [[self copy] autorelease];
}
@end

//
// Show
//
@implementation Show
-(void) start
{
	[super start];
	[target setVisible: YES];
}
-(FiniteTimeAction*) reverse
{
	return [Hide action];
}
@end

//
// Hide
//
@implementation Hide
-(void) start
{
	[super start];
	[target setVisible: NO];
}
-(FiniteTimeAction*) reverse
{
	return [Show action];
}
@end

//
// ToggleVisibility
//
@implementation ToggleVisibility
-(void) start
{
	[super start];
	BOOL v = [target visible];
	[target setVisible: !v];
}
@end

//
// Place
//
@implementation Place
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
	InstantAction *copy = [[[self class] allocWithZone: zone] initWithPosition: position];
	return copy;
}

-(void) start
{
	[super start];
	[target setPosition: position];
}
@end

//
// CallFunc
//
@implementation CallFunc
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
	InstantAction *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback selector:selector];
	return copy;
}


-(void) start
{
	[super start];
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
@implementation CallFuncN

-(void) execute
{
	[targetCallback performSelector:selector withObject:target];
}
@end

//
// CallFuncND
//
@implementation CallFuncND

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
	InstantAction *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback selector:selector data:data];
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
