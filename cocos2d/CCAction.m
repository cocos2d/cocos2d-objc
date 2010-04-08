/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CCAction.h"
#import "ccMacros.h"

#import "CCIntervalAction.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
//
// Action Base Class
//
#pragma mark -
#pragma mark Action
@implementation CCAction

@synthesize tag, target, originalTarget;

+(id) action
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if( (self=[super init]) ) {	
		originalTarget = target = nil;
		tag = kActionTagInvalid;
	}
	return self;
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i>", [self class], self, tag];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] init];
	copy.tag = tag;
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	originalTarget = target = aTarget;
}

-(void) stop
{
	target = nil;
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
@implementation CCFiniteTimeAction
@synthesize duration;

- (CCFiniteTimeAction*) reverse
{
	CCLOG(@"cocos2d: FiniteTimeAction#reverse: Implement me");
	return nil;
}
@end


//
// RepeatForever
//
#pragma mark -
#pragma mark RepeatForever
@implementation CCRepeatForever
+(id) actionWithAction: (CCIntervalAction*) action
{
	return [[[self alloc] initWithAction: action] autorelease];
}

-(id) initWithAction: (CCIntervalAction*) action
{
	if( (self=[super init]) )	
		other = [action retain];

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithAction:[[other copy] autorelease] ];
    return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[other startWithTarget:target];
}

-(void) step:(ccTime) dt
{
	[other step: dt];
	if( [other isDone] ) {
		ccTime diff = dt + other.duration - other.elapsed;
		[other startWithTarget:target];
		
		// to prevent jerk. issue #390
		[other step: diff];
	}
}


-(BOOL) isDone
{
	return NO;
}

- (CCIntervalAction *) reverse
{
	return [CCRepeatForever actionWithAction:[other reverse]];
}

@end

//
// Speed
//
#pragma mark -
#pragma mark Speed
@implementation CCSpeed
@synthesize speed;

+(id) actionWithAction: (CCIntervalAction*) action speed:(float)r
{
	return [[[self alloc] initWithAction: action speed:r] autorelease];
}

-(id) initWithAction: (CCIntervalAction*) action speed:(float)r
{
	if( !(self=[super init]) )
		return nil;
	
	other = [action retain];
	speed = r;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithAction:[[other copy] autorelease] speed:speed];
    return copy;
}

-(void) dealloc
{
	[other release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[other startWithTarget:target];
}

-(void) stop
{
	[other stop];
	[super stop];
}

-(void) step:(ccTime) dt
{
	[other step: dt * speed];
}

-(BOOL) isDone
{
	return [other isDone];
}

- (CCIntervalAction *) reverse
{
	return [CCSpeed actionWithAction:[other reverse] speed:speed];
}
@end

//
// Follow
//
#pragma mark -
#pragma mark Follow
@implementation CCFollow

@synthesize boundarySet;

+(id) actionWithTarget:(CCNode *) fNode
{
	return [[[self alloc] initWithTarget:fNode] autorelease];
}

+(id) actionWithTarget:(CCNode *) fNode worldBoundary:(CGRect)rect
{
	return [[[self alloc] initWithTarget:fNode worldBoundary:rect] autorelease];
}

-(id) initWithTarget:(CCNode *)fNode
{
	if( (self=[super init]) ) {
	
		followedNode_ = [fNode retain];
		boundarySet = FALSE;
		boundaryFullyCovered = FALSE;
		
		fullScreenSize = CGPointMake([CCDirector sharedDirector].winSize.width, [CCDirector sharedDirector].winSize.height);
		halfScreenSize = ccpMult(fullScreenSize, .5f);
	}
	
	return self;
}

-(id) initWithTarget:(CCNode *)fNode worldBoundary:(CGRect)rect
{
	if( (self=[super init]) ) {
	
		followedNode_ = [fNode retain];
		boundarySet = TRUE;
		boundaryFullyCovered = FALSE;
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		fullScreenSize = CGPointMake(winSize.width, winSize.height);
		halfScreenSize = ccpMult(fullScreenSize, .5f);
		
		leftBoundary = -((rect.origin.x+rect.size.width) - fullScreenSize.x);
		rightBoundary = -rect.origin.x ;
		topBoundary = -rect.origin.y;
		bottomBoundary = -((rect.origin.y+rect.size.height) - fullScreenSize.y);
		
		if(rightBoundary < leftBoundary)
		{
			// screen width is larger than world's boundary width
			//set both in the middle of the world
			rightBoundary = leftBoundary = (leftBoundary + rightBoundary) / 2;
		}
		if(topBoundary < bottomBoundary)
		{
			// screen width is larger than world's boundary width
			//set both in the middle of the world
			topBoundary = bottomBoundary = (topBoundary + bottomBoundary) / 2;
		}
		
		if( (topBoundary == bottomBoundary) && (leftBoundary == rightBoundary) )
			boundaryFullyCovered = TRUE;
	}
	
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] init];
	copy.tag = tag;
	return copy;
}

-(void) step:(ccTime) dt
{
#define CLAMP(x,y,z) MIN(MAX(x,y),z)
	
	if(boundarySet)
	{
		// whole map fits inside a single screen, no need to modify the position - unless map boundaries are increased
		if(boundaryFullyCovered)
			return;
		
		CGPoint tempPos = ccpSub( halfScreenSize, followedNode_.position);
		[target setPosition:ccp(CLAMP(tempPos.x,leftBoundary,rightBoundary), CLAMP(tempPos.y,bottomBoundary,topBoundary))];
	}
	else
		[target setPosition:ccpSub( halfScreenSize, followedNode_.position )];
	
#undef CLAMP
}


-(BOOL) isDone
{
	return ( ! followedNode_.isRunning );
}

-(void) stop
{
	target = nil;
	[super stop];
}

-(void) dealloc
{
	[followedNode_ release];
	[super dealloc];
}

@end


