/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * EaseAction by Jason Booth
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
/** Ease Quadratic In
 */
@interface EaseQuadIn : EaseAction <NSCopying> {} @end
/** Ease Quadratic Out
 */
@interface EaseQuadOut : EaseAction <NSCopying> {} @end
/** Ease Quadratic InOut
 */
@interface EaseQuadInOut : EaseAction <NSCopying> {} @end
/** Ease Cubic In
 */
@interface EaseCubicIn : EaseAction <NSCopying> {} @end
/** Ease Cubic Out
 */
@interface EaseCubicOut : EaseAction <NSCopying> {} @end
/** Ease Cubic InOut
 */
@interface EaseCubicInOut : EaseAction <NSCopying> {} @end

