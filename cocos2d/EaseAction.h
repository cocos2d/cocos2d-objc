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

/** Ease Elastic abstract class
 @since v0.8.2
 */
@interface EaseElastic : EaseAction <NSCopying>
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

/** Ease Elastic In action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface EaseElasticIn : EaseElastic <NSCopying> {} @end
/** Ease Elastic Out action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface EaseElasticOut : EaseElastic <NSCopying> {} @end
/** Ease Elastic InOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface EaseElasticInOut : EaseElastic <NSCopying> {} @end

/** EaseBounce abstract class.
 @since v0.8.2
*/
@interface EaseBounce : EaseAction <NSCopying> {} @end

/** EaseBounceIn action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
*/
@interface EaseBounceIn : EaseBounce <NSCopying> {} @end

/** EaseBounceOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface EaseBounceOut : EaseBounce <NSCopying> {} @end

/** EaseBounceInOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface EaseBounceInOut : EaseBounce <NSCopying> {} @end

/** EaseBackIn action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface EaseBackIn : EaseAction <NSCopying> {} @end

/** EaseBackOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface EaseBackOut : EaseAction <NSCopying> {} @end

/** EaseBackInOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface EaseBackInOut : EaseAction <NSCopying> {} @end

