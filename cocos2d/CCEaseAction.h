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

#import "CCIntervalAction.h"

/** Base class for Easing actions
 */
@interface CCEaseAction : CCIntervalAction <NSCopying>
{
	CCIntervalAction * other;
}
/** creates the action */
+(id) actionWithAction: (CCIntervalAction*) action;
/** initializes the action */
-(id) initWithAction: (CCIntervalAction*) action;
@end

/** Base class for Easing actions with rate parameters
 */
@interface CCEaseRateAction :  CCEaseAction <NSCopying>
{
	float	rate;
}
/** rate value for the actions */
@property (nonatomic,readwrite,assign) float rate;
/** Creates the action with the inner action and the rate parameter */
+(id) actionWithAction: (CCIntervalAction*) action rate:(float)rate;
/** Initializes the action with the inner action and the rate parameter */
-(id) initWithAction: (CCIntervalAction*) action rate:(float)rate;
@end

/** CCEaseIn action with a rate
 */
@interface CCEaseIn : CCEaseRateAction <NSCopying> {} @end

/** CCEaseOut action with a rate
 */
@interface CCEaseOut : CCEaseRateAction <NSCopying> {} @end

/** CCEaseInOut action with a rate
 */
@interface CCEaseInOut : CCEaseRateAction <NSCopying> {} @end

/** CCEase Exponential In
 */
@interface CCEaseExponentialIn : CCEaseAction <NSCopying> {} @end
/** Ease Exponential Out
 */
@interface CCEaseExponentialOut : CCEaseAction <NSCopying> {} @end
/** Ease Exponential InOut
 */
@interface CCEaseExponentialInOut : CCEaseAction <NSCopying> {} @end
/** Ease Sine In
 */
@interface CCEaseSineIn : CCEaseAction <NSCopying> {} @end
/** Ease Sine Out
 */
@interface CCEaseSineOut : CCEaseAction <NSCopying> {} @end
/** Ease Sine InOut
 */
@interface CCEaseSineInOut : CCEaseAction <NSCopying> {} @end

/** Ease Elastic abstract class
 @since v0.8.2
 */
@interface CCEaseElastic : CCEaseAction <NSCopying>
{
	float period_;
}

/** period of the wave in radians. default is 0.3 */
@property (nonatomic,readwrite) float period;

/** Creates the action with the inner action and the period in radians (default is 0.3) */
+(id) actionWithAction: (CCIntervalAction*) action period:(float)period;
/** Initializes the action with the inner action and the period in radians (default is 0.3) */
-(id) initWithAction: (CCIntervalAction*) action period:(float)period;
@end

/** Ease Elastic In action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCEaseElasticIn : CCEaseElastic <NSCopying> {} @end
/** Ease Elastic Out action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCEaseElasticOut : CCEaseElastic <NSCopying> {} @end
/** Ease Elastic InOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCEaseElasticInOut : CCEaseElastic <NSCopying> {} @end

/** CCEaseBounce abstract class.
 @since v0.8.2
*/
@interface CCEaseBounce : CCEaseAction <NSCopying> {} @end

/** CCEaseBounceIn action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
*/
@interface CCEaseBounceIn : CCEaseBounce <NSCopying> {} @end

/** EaseBounceOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCEaseBounceOut : CCEaseBounce <NSCopying> {} @end

/** CCEaseBounceInOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCEaseBounceInOut : CCEaseBounce <NSCopying> {} @end

/** CCEaseBackIn action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCEaseBackIn : CCEaseAction <NSCopying> {} @end

/** CCEaseBackOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCEaseBackOut : CCEaseAction <NSCopying> {} @end

/** CCEaseBackInOut action.
 @warning This action doesn't use a bijective fucntion. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCEaseBackInOut : CCEaseAction <NSCopying> {} @end

