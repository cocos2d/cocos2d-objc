/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008, 2009 Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "IntervalAction.h"

/** Base class for Easing actions
 */
@interface EaseAction : IntervalAction <NSCopying>
{
	IntervalAction * other;
}
/** creates the action */
+(id) actionWithAction: (IntervalAction*) action;
/** initializes the action */
-(id) initWithAction: (IntervalAction*) action;
@end

/** Base class for Easing actions with rate parameters
 */
@interface EaseRateAction :  EaseAction <NSCopying>
{
	float	rate;
}
/** rate value for the actions */
@property (readwrite,assign) float rate;
/** Creates the action with the inner action and the rate parameter */
+(id) actionWithAction: (IntervalAction*) action rate:(float)rate;
/** Initializes the action with the inner action and the rate parameter */
-(id) initWithAction: (IntervalAction*) action rate:(float)rate;
@end

/** EaseIn action with a rate
 */
@interface EaseIn : EaseRateAction <NSCopying> {} @end

/** EaseOut action with a rate
 */
@interface EaseOut : EaseRateAction <NSCopying> {} @end

/** EaseInOut action with a rate
 */
@interface EaseInOut : EaseRateAction <NSCopying> {} @end

/** Ease Exponential In
 */
@interface EaseExponentialIn : EaseAction <NSCopying> {} @end
/** Ease Exponential Out
 */
@interface EaseExponentialOut : EaseAction <NSCopying> {} @end
/** Ease Exponential InOut
 */
@interface EaseExponentialInOut : EaseAction <NSCopying> {} @end
/** Ease Sine In
 */
@interface EaseSineIn : EaseAction <NSCopying> {} @end
/** Ease Sine Out
 */
@interface EaseSineOut : EaseAction <NSCopying> {} @end
/** Ease Sine InOut
 */
@interface EaseSineInOut : EaseAction <NSCopying> {} @end
