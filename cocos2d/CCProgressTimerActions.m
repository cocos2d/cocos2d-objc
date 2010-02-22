/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2010 Lam Pham
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCProgressTimerActions.h"

#define kProgressTimerCast CCProgressTimer*

@implementation CCProgressTo
+(id) actionWithDuration: (ccTime) t percent: (float) v
{
	return [[[ self alloc] initWithDuration: t percent: v] autorelease];
}

-(id) initWithDuration: (ccTime) t percent: (float) v
{
	if( (self=[super initWithDuration: t] ) )
		to_ = v;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:duration percent:to_];
	return copy;
}

-(void) startWithTarget:(id) aTarget;
{
	[super startWithTarget:aTarget];
	from_ = [(kProgressTimerCast)target percentage];
	
	// XXX: Is this correct ?
	// Adding it to support CCRepeat
	if( from_ == 100)
		from_ = 0;
}

-(void) update: (ccTime) t
{
	[(kProgressTimerCast)target setPercentage: from_ + ( to_ - from_ ) * t];
}
@end

@implementation CCProgressFromTo
+(id) actionWithDuration: (ccTime) t from:(float)fromPercentage to:(float) toPercentage
{
	return [[[self alloc] initWithDuration: t from: fromPercentage to: toPercentage] autorelease];
}

-(id) initWithDuration: (ccTime) t from:(float)fromPercentage to:(float) toPercentage
{
	if( (self=[super initWithDuration: t] ) ){
		to_ = toPercentage;
		from_ = fromPercentage;
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:duration from:from_ to:to_];
	return copy;
}

- (CCIntervalAction *) reverse
{
	return [[self class] actionWithDuration:duration from:to_ to:from_];
}

-(void) startWithTarget:(id) aTarget;
{
	[super startWithTarget:aTarget];
}

-(void) update: (ccTime) t
{
	[(kProgressTimerCast)target setPercentage: from_ + ( to_ - from_ ) * t];
}
@end
