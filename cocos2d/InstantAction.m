/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
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
@synthesize duration;

-(id) init
{
	if( !(self=[super init]) )
		return nil;
	
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
@end

//
// Show
//
@implementation Show
-(void) start
{
	[super start];
	target.visible = YES;
}
@end

//
// Hide
//
@implementation Hide
-(void) start
{
	[super start];
	target.visible = NO;
}
@end

//
// ToggleVisibility
//
@implementation ToggleVisibility
-(void) start
{
	[super start];
	target.visible = ! target.visible;
}
@end

//
// Place
//
@implementation Place
+(id) actionWithPosition: (cpVect) pos
{
	return [[[self alloc]initWithPosition:pos]autorelease];
}

-(id) initWithPosition: (cpVect) pos
{
	if( ! (self=[super init]) )
		return nil;
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
	target.position = position;
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
	if( ! (self=[super init]) )
		return nil;
	
	targetCallback = [t retain];
	selector = s;
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

+(id) actionWithTarget: (id) t selector:(SEL) s data:(void*) d
{
	return [[[self alloc] initWithTarget: t selector: s data:d] autorelease];
}

-(id) initWithTarget:(id) t selector:(SEL) s data:(void*) d
{
	if( !(self=[super initWithTarget:t selector:s]) )
		return nil;
	data = d;
	
	NSMethodSignature * sig = [[t class] instanceMethodSignatureForSelector:s];
	invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:t];
	[invocation setSelector:s];
	[invocation retain];
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	InstantAction *copy = [[[self class] allocWithZone: zone] initWithTarget:targetCallback selector:selector data:data];
	return copy;
}


-(void) dealloc
{
	[invocation release];
	[super dealloc];
}

-(void) execute
{
	[invocation setArgument:&target atIndex:2];
	[invocation setArgument:&data atIndex:3];
	[invocation invoke];
}
@end
