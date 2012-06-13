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

#import "ccMacros.h"
#import "CCAnimation.h"
#import "CCSpriteFrame.h"
#import "CCTexture2D.h"
#import "CCTextureCache.h"

#pragma mark - CCAnimationFrame
@implementation CCAnimationFrame

@synthesize spriteFrame = spriteFrame_, delayUnits = delayUnits_, userInfo=userInfo_;

-(id) initWithSpriteFrame:(CCSpriteFrame *)spriteFrame delayUnits:(float)delayUnits userInfo:(NSDictionary*)userInfo
{
	if( (self=[super init]) ) {
		self.spriteFrame = spriteFrame;
		self.delayUnits = delayUnits;
		self.userInfo = userInfo;
	}
	
	return self;
}

-(void) dealloc
{    
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	[spriteFrame_ release];
	[userInfo_ release];

    [super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAnimationFrame *copy = [[[self class] allocWithZone: zone] initWithSpriteFrame:[[spriteFrame_ copy] autorelease] delayUnits:delayUnits_ userInfo:[[userInfo_ copy] autorelease] ];
	return copy;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | SpriteFrame = %p, delayUnits = %0.2f >", [self class], self, spriteFrame_, delayUnits_ ];
}
@end


#pragma mark - CCAnimation

@implementation CCAnimation
@synthesize frames = frames_, totalDelayUnits=totalDelayUnits_, delayPerUnit=delayPerUnit_, restoreOriginalFrame=restoreOriginalFrame_, loops=loops_;

+(id) animation
{
	return [[[self alloc] init] autorelease];
}

+(id) animationWithSpriteFrames:(NSArray*)frames
{
	return [[[self alloc] initWithSpriteFrames:frames] autorelease];
}

+(id) animationWithSpriteFrames:(NSArray*)frames delay:(float)delay
{
	return [[[self alloc] initWithSpriteFrames:frames delay:delay] autorelease];
}

+(id) animationWithAnimationFrames:(NSArray*)arrayOfAnimationFrames delayPerUnit:(float)delayPerUnit loops:(NSUInteger)loops
{
	return [[[self alloc] initWithAnimationFrames:arrayOfAnimationFrames delayPerUnit:delayPerUnit loops:loops] autorelease];
}

-(id) init
{
	return [self initWithSpriteFrames:nil delay:0];
}

-(id) initWithSpriteFrames:(NSArray*)frames
{
	return [self initWithSpriteFrames:frames delay:0];
}

-(id) initWithSpriteFrames:(NSArray*)array delay:(float)delay
{
	if( (self=[super init]) )
	{
		loops_ = 1;
		delayPerUnit_ = delay;

		self.frames = [NSMutableArray arrayWithCapacity:[array count]];
		
		for( CCSpriteFrame *frame in array ) {
			CCAnimationFrame *animFrame = [[CCAnimationFrame alloc] initWithSpriteFrame:frame delayUnits:1 userInfo:nil];
			
			[self.frames addObject:animFrame];
			[animFrame release];
			totalDelayUnits_++;
		}
		
	}
	return self;
}

-(id) initWithAnimationFrames:(NSArray*)arrayOfAnimationFrames delayPerUnit:(float)delayPerUnit loops:(NSUInteger)loops
{
	if( ( self=[super init]) )
	{
		delayPerUnit_ = delayPerUnit;
		loops_ = loops;

		self.frames = [NSMutableArray arrayWithArray:arrayOfAnimationFrames];

		for( CCAnimationFrame *animFrame in frames_ )
			totalDelayUnits_ += animFrame.delayUnits;
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | frames=%lu, totalDelayUnits=%f, delayPerUnit=%f, loops=%lu>", [self class], self,
			(unsigned long)[frames_ count],
			totalDelayUnits_,
			delayPerUnit_,
			(unsigned long)loops_
			];
}

-(float) duration
{
	return totalDelayUnits_ * delayPerUnit_;
}

- (id)copyWithZone:(NSZone *)zone
{
	CCAnimation *animation  = [[[self class] allocWithZone: zone] initWithAnimationFrames:frames_ delayPerUnit:delayPerUnit_ loops:loops_];
	animation.restoreOriginalFrame = restoreOriginalFrame_;

	return animation;
}

-(void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);

	[frames_ release];
	[super dealloc];
}

-(void) addSpriteFrame:(CCSpriteFrame*)frame
{
	CCAnimationFrame *animFrame = [[CCAnimationFrame alloc] initWithSpriteFrame:frame delayUnits:1 userInfo:nil];
	[frames_ addObject:animFrame];
	[animFrame release];
	
	// update duration
	totalDelayUnits_++;
}

-(void) addSpriteFrameWithFilename:(NSString*)filename
{
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:filename];
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	CCSpriteFrame *spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:rect];

	[self addSpriteFrame:spriteFrame];
}

-(void) addSpriteFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect];
	[self addSpriteFrame:frame];
}

@end
