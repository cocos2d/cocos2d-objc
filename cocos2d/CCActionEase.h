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

/** Base class for Easing actions
 */
@interface CCActionEase : CCActionInterval <NSCopying>
{
	CCActionInterval *_inner;
}
/** The inner action */
@property (nonatomic, readonly) CCActionInterval *inner;

/** creates the action */
+(id) actionWithAction: (CCActionInterval*) action;
/** initializes the action */
-(id) initWithAction: (CCActionInterval*) action;
@end

/** Base class for Easing actions with rate parameters
 */
@interface CCActionEaseRate :  CCActionEase <NSCopying>
{
	float	_rate;
}
/** rate value for the actions */
@property (nonatomic,readwrite,assign) float rate;
/** Creates the action with the inner action and the rate parameter */
+(id) actionWithAction: (CCActionInterval*) action rate:(float)rate;
/** Initializes the action with the inner action and the rate parameter */
-(id) initWithAction: (CCActionInterval*) action rate:(float)rate;
@end

/** CCEaseIn action with a rate
 */
@interface CCActionEaseIn : CCActionEaseRate <NSCopying>
{} 
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** CCEaseOut action with a rate
 */
@interface CCActionEaseOut : CCActionEaseRate <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** CCEaseInOut action with a rate
 */
@interface CCActionEaseInOut : CCActionEaseRate <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** Ease Elastic abstract class
 @since v0.8.2
 */
@interface CCActionEaseElastic : CCActionEase <NSCopying>
{
	float _period;
}

/** period of the wave in radians. default is 0.3 */
@property (nonatomic,readwrite) float period;

/** Creates the action with the inner action and the period in radians (default is 0.3) */
+(id) actionWithAction: (CCActionInterval*) action period:(float)period;
/** Initializes the action with the inner action and the period in radians (default is 0.3) */
-(id) initWithAction: (CCActionInterval*) action period:(float)period;
@end

/** Ease Elastic In action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCActionEaseElasticIn : CCActionEaseElastic <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** Ease Elastic Out action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCActionEaseElasticOut : CCActionEaseElastic <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** Ease Elastic InOut action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCActionEaseElasticInOut : CCActionEaseElastic <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** CCEaseBounce abstract class.
 @since v0.8.2
*/
@interface CCActionEaseBounce : CCActionEase <NSCopying>
{}
// Needed for BridgeSupport
-(CCTime) bounceTime:(CCTime) t;
@end

/** CCEaseBounceIn action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
*/
@interface CCActionEaseBounceIn : CCActionEaseBounce <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** EaseBounceOut action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCActionEaseBounceOut : CCActionEaseBounce <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** CCEaseBounceInOut action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCActionEaseBounceInOut : CCActionEaseBounce <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** CCEaseBackIn action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCActionEaseBackIn : CCActionEase <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** CCEaseBackOut action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCActionEaseBackOut : CCActionEase <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

/** CCEaseBackInOut action.
 @warning This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 @since v0.8.2
 */
@interface CCActionEaseBackInOut : CCActionEase <NSCopying>
{}
// Needed for BridgeSupport
-(void) update: (CCTime) t;
@end

