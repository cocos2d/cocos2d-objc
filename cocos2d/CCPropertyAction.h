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

#import <Foundation/Foundation.h>
#import "CCIntervalAction.h"

@interface CCPropertyAction : CCIntervalAction {

	NSString		*key_;
    
	float			from_, to_;
	float			delta_;
}

+ (id)actionWithDuration:(ccTime)aDuration key:(NSString *)aKey from:(float)aFrom to:(float)aTo;

- (id)initWithDuration:(ccTime)aDuration key:(NSString *)aKey from:(float)aFrom to:(float)aTo;
    
@end
