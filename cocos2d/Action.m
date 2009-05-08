/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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


#import "Action.h"
#import "CocosNode.h"
#import "ccMacros.h"

#import "IntervalAction.h"

//
// Action Base Class
//
#pragma mark -
#pragma mark Action
@implementation Action

@synthesize target;
@synthesize tag;

+(id) action
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if( !(self=[super init]) )
		return nil;
	
	target = nil;
	tag = kActionTagInvalid;
	return self;
}

-(void) dealloc
{
	CCLOG(@"deallocing %@", self);
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] init];
	copy.target = target;
	copy.tag = tag;
	return copy;
}

-(void) start
{
	// override me
}

-(void) stop
{
	// override me
}

-(BOOL) isDone
{
	return YES;
}

-(void) step: (ccTime) dt
{
	NSLog(@"[Action step]. override me");
}

-(void) update: (ccTime) time
{
	NSLog(@"[Action update]. override me");
}
@end

//
// FiniteTimeAction
//
#pragma mark -
#pragma mark FiniteTimeAction
@implementation FiniteTimeAction
@synthesize duration;

- (FiniteTimeAction*) reverse
{
	CCLOG(@"FiniteTimeAction#reverse: Implement me");
	return nil;
}
@end


//
// RepeatForever
//
#pragma mark -
#pragma mark RepeatForever
@implementation RepeatForever
+(id) actionWithAction: (IntervalAction*) action
{
	return [[[self alloc] initWithAction: action] autorelease];
}

-(id) initWithAction: (IntervalAction*) action
{
	if( !(self=[super init]) )
		return nil;
	
	other = [action retain];
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithAction:[[other copy] autorelease] ];
    return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) start
{
	[super start];
	other.target = target;
	[other start];
}

-(void) step:(ccTime) dt
{
	[other step: dt];
	if( [other isDone] ) {
		[other start];
	}
}


-(BOOL) isDone
{
	return NO;
}

- (IntervalAction *) reverse
{
	return [RepeatForever actionWithAction:[other reverse]];
}

@end

//
// Speed
//
#pragma mark -
#pragma mark Speed
@implementation Speed
@synthesize speed;

+(id) actionWithAction: (IntervalAction*) action speed:(float)r
{
	return [[[self alloc] initWithAction: action speed:r] autorelease];
}

-(id) initWithAction: (IntervalAction*) action speed:(float)r
{
	if( !(self=[super init]) )
		return nil;
	
	other = [action retain];
	speed = r;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] initWithAction:[[other copy] autorelease] speed:speed];
    return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) start
{
	[super start];
	other.target = target;
	[other start];
}

-(void) step:(ccTime) dt
{
	[other step: dt * speed];
}

-(BOOL) isDone
{
	return [other isDone];
}

- (IntervalAction *) reverse
{
	return [Speed actionWithAction:[other reverse] speed:speed];
}
@end



