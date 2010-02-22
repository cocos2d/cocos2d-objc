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

#import <Foundation/Foundation.h>
#import "CCProgressTimer.h"
#import "CCIntervalAction.h"

/**
 Progress to percentage
@since v0.99.1
*/
@interface CCProgressTo : CCIntervalAction <NSCopying>
{
	float to_;
	float from_;
}
/** Creates and initializes with a duration and a percent */
+(id) actionWithDuration:(ccTime)duration percent:(float)percent;
/** Initializes with a duration and a percent */
-(id) initWithDuration:(ccTime)duration percent:(float)percent;
@end

/**
 Progress from a percentage to another percentage
 @since v0.99.1
 */
@interface CCProgressFromTo : CCIntervalAction <NSCopying>
{
	float to_;
	float from_;
}
/** Creates and initializes the action with a duration, a "from" percentage and a "to" percentage */
+(id) actionWithDuration:(ccTime)duration from:(float)fromPercentage to:(float) toPercentage;
/** Initializes the action with a duration, a "from" percentage and a "to" percentage */
-(id) initWithDuration:(ccTime)duration from:(float)fromPercentage to:(float) toPercentage;
@end
