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
@property (nonatomic,readwrite,assign) float rate;
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

/** Ease Elastic abstract class */
@interface ElasticAction : EaseAction <NSCopying>
{
	float period_;
}

/** period of the wave in radians. default is 0.3 */
@property (nonatomic,readwrite) float period;

/** Creates the action with the inner action and the period in radians (default is 0.3) */
+(id) actionWithAction: (IntervalAction*) action period:(float)period;
/** Initializes the action with the inner action and the period in radians (default is 0.3) */
-(id) initWithAction: (IntervalAction*) action period:(float)period;
@end

/** Ease Elastic In action */
@interface EaseElasticIn : ElasticAction <NSCopying> {} @end
/** Ease Elastic Out action. */
@interface EaseElasticOut : ElasticAction <NSCopying> {} @end
/** Ease Elastic InOut action */
@interface EaseElasticInOut : ElasticAction <NSCopying> {} @end


@interface EaseBounce : EaseAction <NSCopying> {} @end

@interface EaseBounceIn : EaseBounce <NSCopying> {} @end

@interface EaseBounceOut : EaseBounce <NSCopying> {} @end

@interface EaseBounceInOut : EaseBounce <NSCopying> {} @end



