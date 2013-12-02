/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2009 Jason Booth
 * Copyright (c) 2013 Nader Eloshaiker
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCActionInterval.h"

// -----------------------------------------------------------------
/** @name CCActionEase */

/** 
 *  Base class for Easing actions.
 */
@interface CCActionEase : CCActionInterval <NSCopying>
{
	CCActionInterval *_inner;
}

/**
 *  The inner action
 */
@property (nonatomic, readonly) CCActionInterval *inner;

/**
 *  Creates a new basic ease action
 *
 *  @param action Interval action
 *
 *  @return New ease action
 */
+(id) actionWithAction: (CCActionInterval*) action;

/**
 *  Initializes a new basic ease action
 *
 *  @param action Interval action
 *
 *  @return New ease action
 */
-(id) initWithAction: (CCActionInterval*) action;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseRate */

/** 
 *  Base class for Easing actions with rate parameters
 */
@interface CCActionEaseRate :  CCActionEase <NSCopying>
{
	float	_rate;
}

/** 
 *  Rate value for the actions 
 */
@property (nonatomic,readwrite,assign) float rate;

/**
 *  Creates the action with the inner action and the rate parameter
 *
 *  @param action Interval action to ease
 *  @param rate   Action rate
 *
 *  @return New rate action
 */
+(id) actionWithAction: (CCActionInterval*) action rate:(float)rate;

/**
 *  Initializes the action with the inner action and the rate parameter
 *
 *  @param action Interval action to ease
 *  @param rate   Action rate
 *
 *  @return New rate action
 */
-(id) initWithAction: (CCActionInterval*) action rate:(float)rate;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseIn */

/** 
 *  CCEaseIn action
 *  Action accelerates with rate
 */
@interface CCActionEaseIn : CCActionEaseRate <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseOut */

/** 
 *  CCEaseOut action 
 *  Action deaccelerates with rate
 */
@interface CCActionEaseOut : CCActionEaseRate <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseInOut */

/** 
 *  CCEaseInOut action
 *  Action both accelerates and deaccelerates with same rate
 */
@interface CCActionEaseInOut : CCActionEaseRate <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseElastic */

/** 
 *  Ease Elastic abstract class
 *  Creates an dampened oscillation action
 */
@interface CCActionEaseElastic : CCActionEase <NSCopying>
{
	float _period;
}

/** 
 *  Period of the wave in radians. default is 0.3 
 */
@property (nonatomic,readwrite) float period;

/**
 *  Creates the action with the inner action and the period in radians (default is 0.3).
 *
 *  @param action Action to apply ease action to
 *  @param period eriod of wave in radians
 *
 *  @return New elastic action
 */
+(id) actionWithAction: (CCActionInterval*) action period:(float)period;

/**
 *  Initializes the action with the inner action and the period in radians (default is 0.3).
 *
 *  @param action Action to apply ease action to
 *  @param period eriod of wave in radians
 *
 *  @return New elastic action
 */
-(id) initWithAction: (CCActionInterval*) action period:(float)period;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseElasticIn */

/** 
 *  Ease Elastic In action.
 *  Starts the action with an elastic effect
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseElasticIn : CCActionEaseElastic <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseElasticOut */

/** 
 *  Ease Elastic Out action.
 *  Ends the action with an elastic effect
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseElasticOut : CCActionEaseElastic <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseElasticInOut */

/** 
 *  Ease Elastic InOut action.
 *  Starts and ends the action with an elastic effect
 *  Note: 
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseElasticInOut : CCActionEaseElastic <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseBounce */

/** 
 *  Bounce action abstract class.
 *  Creates a bouncing effect in the action
 */
@interface CCActionEaseBounce : CCActionEase <NSCopying>
{
}

// Needed for BridgeSupport

-(CCTime) bounceTime:(CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseBounceIn */

/** 
 *  Bounce in action.
 *  Starts the action with a bounce effect
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
*/

@interface CCActionEaseBounceIn : CCActionEaseBounce <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseBounceOut */

/** 
 *  Bounce out action.
 *  Ends the action with a bounce effect
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBounceOut : CCActionEaseBounce <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseBounceInOut */

/** 
 *  Bounce in and out action.
 *  Starts and ends the action with a bounce effect
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBounceInOut : CCActionEaseBounce <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseBackIn */

/** 
 *  Ease back in action.
 *  Starts the action with a reversed acceleration
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBackIn : CCActionEase <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseBackOut */

/** Ease back out action.
 *  Ends the action with a reversed acceleration
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBackOut : CCActionEase <NSCopying>
{
}

// Needed for BridgeSupport
-(void) update: (CCTime) t;

@end

// -----------------------------------------------------------------
/** @name CCActionEaseBackInOut */

/** Ease back in out action.
 *  Starts and ends the action with a reversed acceleration
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBackInOut : CCActionEase <NSCopying>
{
}

// Needed for BridgeSupport

-(void) update: (CCTime) t;

@end

