/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright 2009 lhunath (Maarten Billemont)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CCPropertyAction.h"


@implementation CCPropertyAction

+ (id)actionWithDuration:(ccTime)aDuration key:(NSString *)aKey from:(float)aFrom to:(float)aTo {

	return [[[[self class] alloc] initWithDuration:aDuration key:aKey from:aFrom to:aTo] autorelease];
}


- (id)initWithDuration:(ccTime)aDuration key:(NSString *)key from:(float)from to:(float)to {
    
	if ((self = [super initWithDuration:aDuration])) {
    
		key_	= [key copy];
		to_		= to;
		from_	= from;

	}
    
	return self;
}

- (void) dealloc
{
	[key_ release];
	[super dealloc];
}

- (void)startWithTarget:aTarget
{
    
	[super startWithTarget:aTarget];
    
	delta_ = to_ - from_;
}

- (void) update:(ccTime) dt {
    
	[target setValue:[NSNumber numberWithFloat:to_  - delta_ * (1 - dt)] forKey:key_];
}

- (CCIntervalAction *) reverse
{
	return [[self class] actionWithDuration:duration key:key_ from:to_ to:from_];
}


@end
