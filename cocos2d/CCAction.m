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


#import "CCDirector.h"
#import "ccMacros.h"
#import "CCAction.h"
#import "CCActionInterval.h"
#import "Support/CGPointExtension.h"

//
// Action Base Class
//
#pragma mark -
#pragma mark Action
@implementation CCAction

@synthesize tag = tag_, target = target_, originalTarget = originalTarget_;

+(id) action
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if( (self=[super init]) ) {
		originalTarget_ = target_ = nil;
		tag_ = kCCActionTagInvalid;
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
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %ld>", [self class], self, (long)tag_];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] init];
	copy.tag = tag_;
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	originalTarget_ = target_ = aTarget;
}

-(void) stop
{
	target_ = nil;
}

-(BOOL) isDone
{
	return YES;
}

-(void) step: (ccTime) dt
{
	CCLOG(@"[Action step]. override me");
}

-(void) update: (ccTime) time
{
	CCLOG(@"[Action update]. override me");
}
@end

//
// FiniteTimeAction
//
#pragma mark -
#pragma mark FiniteTimeAction
@implementation CCFiniteTimeAction
@synthesize duration = duration_;

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
@synthesize innerAction=innerAction_;
+(id) actionWithAction: (CCActionInterval*) action
{
	return [[[self alloc] initWithAction: action] autorelease];
}

-(id) initWithAction: (CCActionInterval*) action
{
	if( (self=[super init]) )
		self.innerAction = action;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithAction:[[innerAction_ copy] autorelease] ];
    return copy;
}

-(void) dealloc
{
	[innerAction_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[innerAction_ startWithTarget:target_];
}

-(void) step:(ccTime) dt
{
	[innerAction_ step: dt];
	if( [innerAction_ isDone] ) {
		ccTime diff = innerAction_.elapsed - innerAction_.duration;
		[innerAction_ startWithTarget:target_];

		// to prevent jerk. issue #390, 1247
		[innerAction_ step: 0.0f];
		[innerAction_ step: diff];
	}
}


-(BOOL) isDone
{
	return NO;
}

- (CCActionInterval *) reverse
{
	return [CCRepeatForever actionWithAction:[innerAction_ reverse]];
}
@end

//
// Speed
//
#pragma mark -
#pragma mark Speed
@implementation CCSpeed
@synthesize speed=speed_;
@synthesize innerAction=innerAction_;

+(id) actionWithAction: (CCActionInterval*) action speed:(float)value
{
	return [[[self alloc] initWithAction: action speed:value] autorelease];
}

-(id) initWithAction: (CCActionInterval*) action speed:(float)value
{
	if( (self=[super init]) ) {
		self.innerAction = action;
		speed_ = value;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithAction:[[innerAction_ copy] autorelease] speed:speed_];
    return copy;
}

-(void) dealloc
{
	[innerAction_ release];
	[super dealloc];
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[innerAction_ startWithTarget:target_];
}

-(void) stop
{
	[innerAction_ stop];
	[super stop];
}

-(void) step:(ccTime) dt
{
	[innerAction_ step: dt * speed_];
}

-(BOOL) isDone
{
	return [innerAction_ isDone];
}

- (CCActionInterval *) reverse
{
	return [CCSpeed actionWithAction:[innerAction_ reverse] speed:speed_];
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

		CGSize s = [[CCDirector sharedDirector] winSize];
		fullScreenSize = CGPointMake(s.width, s.height);
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
	copy.tag = tag_;
	return copy;
}

-(void) step:(ccTime) dt
{
	if(boundarySet)
	{
		// whole map fits inside a single screen, no need to modify the position - unless map boundaries are increased
		if(boundaryFullyCovered)
			return;

		CGPoint tempPos = ccpSub( halfScreenSize, followedNode_.position);
		[target_ setPosition:ccp(clampf(tempPos.x,leftBoundary,rightBoundary), clampf(tempPos.y,bottomBoundary,topBoundary))];
	}
	else
		[target_ setPosition:ccpSub( halfScreenSize, followedNode_.position )];
}


-(BOOL) isDone
{
	return !followedNode_.isRunning;
}

-(void) stop
{
	target_ = nil;
	[super stop];
}

-(void) dealloc
{
	[followedNode_ release];
	[super dealloc];
}

@end


