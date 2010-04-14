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

+ (id)actionWithDuration:(ccTime)aDuration key:(NSString *)aKey from:(NSNumber *)aFrom to:(NSNumber *)aTo {

    return [[[[self class] alloc] initWithDuration:aDuration key:aKey from:aFrom to:aTo] autorelease];
}


- (id)initWithDuration:(ccTime)aDuration key:(NSString *)key from:(NSNumber *)from to:(NSNumber *)to {
    
    if ((self = [super initWithDuration:aDuration])) {
    
		key_     = [key copy];
		from_    = [from copy];
		to_      = [to copy];
		
		toFloat_ = [to_ floatValue];
		fromFloat_ = [from_ floatValue];
	}
    
    return self;
}

- (void)startWithTarget:aTarget
{
    
    [super startWithTarget:aTarget];
    
    if (from_)
        [target setValue:from_ forKey:key_];
	
    delta_ = toFloat_ - fromFloat_;
}

- (void) update:(ccTime) dt {
    
    [target setValue:[NSNumber numberWithFloat:toFloat_  - delta_ * (1 - dt)] forKey:key_];
}

- (CCIntervalAction *) reverse
{
	return [[self class] actionWithDuration:duration key:key_ from:to_ to:from_];
}

- (void) dealloc
{
	[key_ release];
	[from_ release];
	[to_ release];
	[super dealloc];
}

@end
