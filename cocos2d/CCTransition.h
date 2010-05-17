/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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


#import "CCScene.h"
@class CCIntervalAction;
@class CCNode;

/** CCTransitionEaseScene can ease the actions of the scene protocol.
 @since v0.8.2
 */
@protocol CCTransitionEaseScene <NSObject>
/** returns the Ease action that will be performed on a linear action.
 @since v0.8.2
 */
-(CCIntervalAction*) easeActionWithAction:(CCIntervalAction*)action;
@end

/** Orientation Type used by some transitions
 */
typedef enum {
	/// An horizontal orientation where the Left is nearer
	kOrientationLeftOver = 0,
	/// An horizontal orientation where the Right is nearer
	kOrientationRightOver = 1,
	/// A vertical orientation where the Up is nearer
	kOrientationUpOver = 0,
	/// A vertical orientation where the Bottom is nearer
	kOrientationDownOver = 1,
} tOrientation;

/** Base class for CCTransition scenes
 */
@interface CCTransitionScene : CCScene {
	CCScene	*inScene;
	CCScene	*outScene;
	ccTime	duration;
	BOOL	inSceneOnTop;
	BOOL	sendCleanupToScene;
}
/** creates a base transition with duration and incoming scene */
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s;
/** initializes a transition with duration and incoming scene */
-(id) initWithDuration:(ccTime) t scene:(CCScene*)s;
/** called after the transition finishes */
-(void) finish;
/** used by some transitions to hide the outter scene */
-(void) hideOutShowIn;
@end

/** A CCTransition that supports orientation like.
 * Possible orientation: LeftOver, RightOver, UpOver, DownOver
 */
@interface CCOrientedTransitionScene : CCTransitionScene
{
	tOrientation orientation;
}
/** creates a base transition with duration and incoming scene */
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s orientation:(tOrientation)o;
/** initializes a transition with duration and incoming scene */
-(id) initWithDuration:(ccTime) t scene:(CCScene*)s orientation:(tOrientation)o;
@end


/** CCRotoZoomTransition:
 Rotate and zoom out the outgoing scene, and then rotate and zoom in the incoming 
 */
@interface CCRotoZoomTransition : CCTransitionScene
{}
@end

/** CCJumpZoomTransition:
 Zoom out and jump the outgoing scene, and then jump and zoom in the incoming 
*/
@interface CCJumpZoomTransition : CCTransitionScene
{}
@end

/** CCMoveInLTransition:
 Move in from to the left the incoming scene.
*/
@interface CCMoveInLTransition : CCTransitionScene <CCTransitionEaseScene>
{}
/** initializes the scenes */
-(void) initScenes;
/** returns the action that will be performed */
-(CCIntervalAction*) action;
@end

/** CCMoveInRTransition:
 Move in from to the right the incoming scene.
 */
@interface CCMoveInRTransition : CCMoveInLTransition
{}
@end

/** CCMoveInTTransition:
 Move in from to the top the incoming scene.
 */
@interface CCMoveInTTransition : CCMoveInLTransition 
{}
@end

/** CCMoveInBTransition:
 Move in from to the bottom the incoming scene.
 */
@interface CCMoveInBTransition : CCMoveInLTransition
{}
@end

/** CCSlideInLTransition:
 Slide in the incoming scene from the left border.
 */
@interface CCSlideInLTransition : CCTransitionScene <CCTransitionEaseScene>
{}
/** initializes the scenes */
-(void) initScenes;
/** returns the action that will be performed by the incomming and outgoing scene */
-(CCIntervalAction*) action;
@end

/** CCSlideInRTransition:
 Slide in the incoming scene from the right border.
 */
@interface CCSlideInRTransition : CCSlideInLTransition 
{}
@end

/** CCSlideInBTransition:
 Slide in the incoming scene from the bottom border.
 */
@interface CCSlideInBTransition : CCSlideInLTransition
{}
@end

/** CCSlideInTTransition:
 Slide in the incoming scene from the top border.
 */
@interface CCSlideInTTransition : CCSlideInLTransition
{}
@end

/**
 Shrink the outgoing scene while grow the incoming scene
 */
@interface CCShrinkGrowTransition : CCTransitionScene <CCTransitionEaseScene>
{}
@end

/** CCFlipXTransition:
 Flips the screen horizontally.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCFlipXTransition : CCOrientedTransitionScene
{}
@end

/** CCFlipYTransition:
 Flips the screen vertically.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCFlipYTransition : CCOrientedTransitionScene
{}
@end

/** CCFlipAngularTransition:
 Flips the screen half horizontally and half vertically.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCFlipAngularTransition : CCOrientedTransitionScene
{}
@end

/** CCZoomFlipXTransition:
 Flips the screen horizontally doing a zoom out/in
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCZoomFlipXTransition : CCOrientedTransitionScene
{
}
@end

/** CCZoomFlipYTransition:
 Flips the screen vertically doing a little zooming out/in
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCZoomFlipYTransition : CCOrientedTransitionScene
{}
@end

/** CCZoomFlipAngularTransition:
 Flips the screen half horizontally and half vertically doing a little zooming out/in.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCZoomFlipAngularTransition : CCOrientedTransitionScene
{}
@end

/** CCFadeTransition:
 Fade out the outgoing scene and then fade in the incoming scene.'''
 */
@interface CCFadeTransition : CCTransitionScene
{
	ccColor4B	color;
}
/** creates the transition with a duration and with an RGB color
 * Example: [FadeTransition transitionWithDuration:2 scene:s withColor:ccc3(255,0,0)]; // red color
 */
+(id) transitionWithDuration:(ccTime)duration scene:(CCScene*)scene withColor:(ccColor3B)color;
/** initializes the transition with a duration and with an RGB color */
-(id) initWithDuration:(ccTime)duration scene:(CCScene*)scene withColor:(ccColor3B)color;
@end

/**
 CCCrossFadeTransition:
 Cross fades two scenes using the CCRenderTexture object.
 */
@class CCRenderTexture;
@interface CCCrossFadeTransition : CCTransitionScene
{
}
@end

/** CCTurnOffTilesTransition:
 Turn off the tiles of the outgoing scene in random order
 */
@interface CCTurnOffTilesTransition : CCTransitionScene <CCTransitionEaseScene>
{}
@end

/** CCSplitColsTransition:
 The odd columns goes upwards while the even columns goes downwards.
 */
@interface CCSplitColsTransition : CCTransitionScene <CCTransitionEaseScene>
{}
-(CCIntervalAction*) action;
@end

/** CCSplitRowsTransition:
 The odd rows goes to the left while the even rows goes to the right.
 */
@interface CCSplitRowsTransition : CCSplitColsTransition
{}
@end

/** CCFadeTRTransition:
 Fade the tiles of the outgoing scene from the left-bottom corner the to top-right corner.
 */
@interface CCFadeTRTransition : CCTransitionScene <CCTransitionEaseScene>
{}
-(CCIntervalAction*) actionWithSize:(ccGridSize) vector;
@end

/** CCFadeBLTransition:
 Fade the tiles of the outgoing scene from the top-right corner to the bottom-left corner.
 */
@interface CCFadeBLTransition : CCFadeTRTransition
{}
@end

/** CCFadeUpTransition:
 * Fade the tiles of the outgoing scene from the bottom to the top.
 */
@interface CCFadeUpTransition : CCFadeTRTransition
{}
@end

/** CCFadeDownTransition:
 * Fade the tiles of the outgoing scene from the top to the bottom.
 */
@interface CCFadeDownTransition : CCFadeTRTransition
{}
@end
