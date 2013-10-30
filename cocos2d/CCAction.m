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

@synthesize tag = _tag, target = _target, originalTarget = _originalTarget;

+(id) action
{
	return [[self alloc] init];
}

-(id) init
{
	if( (self=[super init]) ) {
		_originalTarget = _target = nil;
		_tag = kCCActionTagInvalid;
	}
	return self;
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %ld>", [self class], self, (long)_tag];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] init];
	copy.tag = _tag;
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	_originalTarget = _target = aTarget;
}

-(void) stop
{
	_target = nil;
}

-(BOOL) isDone
{
	return YES;
}

-(void) step: (CCTime) dt
{
	CCLOG(@"[Action step]. override me");
}

-(void) update: (CCTime) time
{
	CCLOG(@"[Action update]. override me");
}
@end

//
// FiniteTimeAction
//
#pragma mark -
#pragma mark FiniteTimeAction
@implementation CCActionFiniteTime
@synthesize duration = _duration;

- (CCActionFiniteTime*) reverse
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
@implementation CCActionRepeatForever
@synthesize innerAction=_innerAction;
+(id) actionWithAction: (CCActionInterval*) action
{
	return [[self alloc] initWithAction: action];
}

-(id) initWithAction: (CCActionInterval*) action
{
	if( (self=[super init]) )
		self.innerAction = action;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithAction:[_innerAction copy] ];
    return copy;
}


-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_innerAction startWithTarget:_target];
}

-(void) step:(CCTime) dt
{
	[_innerAction step: dt];
	if( [_innerAction isDone] ) {
		CCTime diff = _innerAction.elapsed - _innerAction.duration;
		[_innerAction startWithTarget:_target];

		// to prevent jerk. issue #390, 1247
		[_innerAction step: 0.0f];
		[_innerAction step: diff];
	}
}


-(BOOL) isDone
{
	return NO;
}

- (CCActionInterval *) reverse
{
	return [CCActionRepeatForever actionWithAction:[_innerAction reverse]];
}
@end

//
// Speed
//
#pragma mark -
#pragma mark Speed
@implementation CCActionSpeed
@synthesize speed=_speed;
@synthesize innerAction=_innerAction;

+(id) actionWithAction: (CCActionInterval*) action speed:(CGFloat)value
{
	return [[self alloc] initWithAction: action speed:value];
}

-(id) initWithAction: (CCActionInterval*) action speed:(CGFloat)value
{
	if( (self=[super init]) ) {
		self.innerAction = action;
		_speed = value;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithAction:[_innerAction copy] speed:_speed];
    return copy;
}


-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_innerAction startWithTarget:_target];
}

-(void) stop
{
	[_innerAction stop];
	[super stop];
}

-(void) step:(CCTime) dt
{
	[_innerAction step: dt * _speed];
}

-(BOOL) isDone
{
	return [_innerAction isDone];
}

- (CCActionInterval *) reverse
{
	return [CCActionSpeed actionWithAction:[_innerAction reverse] speed:_speed];
}
@end

//
// Follow
//
#pragma mark -
#pragma mark Follow
@implementation CCActionFollow

@synthesize boundarySet = _boundarySet;

+(id) actionWithTarget:(CCNode *) fNode
{
	return [[self alloc] initWithTarget:fNode];
}

+(id) actionWithTarget:(CCNode *) fNode worldBoundary:(CGRect)rect
{
	return [[self alloc] initWithTarget:fNode worldBoundary:rect];
}

-(id) initWithTarget:(CCNode *)fNode
{
	if( (self=[super init]) ) {

		_followedNode = fNode;
		_boundarySet = FALSE;
		_boundaryFullyCovered = FALSE;

		CGSize s = [[CCDirector sharedDirector] viewSize];
		_fullScreenSize = CGPointMake(s.width, s.height);
		_halfScreenSize = ccpMult(_fullScreenSize, .5f);
	}

	return self;
}

-(id) initWithTarget:(CCNode *)fNode worldBoundary:(CGRect)rect
{
	if( (self=[super init]) ) {

		_followedNode = fNode;
		_boundarySet = TRUE;
		_boundaryFullyCovered = FALSE;

		CGSize winSize = [[CCDirector sharedDirector] viewSize];
		_fullScreenSize = CGPointMake(winSize.width, winSize.height);
		_halfScreenSize = ccpMult(_fullScreenSize, .5f);

		_leftBoundary = -((rect.origin.x+rect.size.width) - _fullScreenSize.x);
		_rightBoundary = -rect.origin.x ;
		_topBoundary = -rect.origin.y;
		_bottomBoundary = -((rect.origin.y+rect.size.height) - _fullScreenSize.y);

		if(_rightBoundary < _leftBoundary)
		{
			// screen width is larger than world's boundary width
			//set both in the middle of the world
			_rightBoundary = _leftBoundary = (_leftBoundary + _rightBoundary) / 2;
		}
		if(_topBoundary < _bottomBoundary)
		{
			// screen width is larger than world's boundary width
			//set both in the middle of the world
			_topBoundary = _bottomBoundary = (_topBoundary + _bottomBoundary) / 2;
		}

		if( (_topBoundary == _bottomBoundary) && (_leftBoundary == _rightBoundary) )
			_boundaryFullyCovered = TRUE;
	}

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] init];
	copy.tag = _tag;
	return copy;
}

-(void) step:(CCTime) dt
{
	if(_boundarySet)
	{
		// whole map fits inside a single screen, no need to modify the position - unless map boundaries are increased
		if(_boundaryFullyCovered)
			return;

		CGPoint tempPos = ccpSub( _halfScreenSize, _followedNode.position);
		[_target setPosition:ccp(clampf(tempPos.x, _leftBoundary, _rightBoundary), clampf(tempPos.y, _bottomBoundary, _topBoundary))];
	}
	else
		[_target setPosition:ccpSub( _halfScreenSize, _followedNode.position )];
}


-(BOOL) isDone
{
	return !_followedNode.runningInActiveScene;
}

-(void) stop
{
	_target = nil;
	[super stop];
}


@end


