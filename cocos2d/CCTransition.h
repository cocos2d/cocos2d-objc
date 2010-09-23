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
@class CCActionInterval;
@class CCNode;

/** CCTransitionEaseScene can ease the actions of the scene protocol.
 @since v0.8.2
 */
@protocol CCTransitionEaseScene <NSObject>
/** returns the Ease action that will be performed on a linear action.
 @since v0.8.2
 */
-(CCActionInterval*) easeActionWithAction:(CCActionInterval*)action;
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
	CCScene	*inScene_;
	CCScene	*outScene_;
	ccTime	duration_;
	BOOL	inSceneOnTop_;
	BOOL	sendCleanupToScene_;
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
@interface CCTransitionSceneOriented : CCTransitionScene
{
	tOrientation orientation;
}
/** creates a base transition with duration and incoming scene */
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s orientation:(tOrientation)o;
/** initializes a transition with duration and incoming scene */
-(id) initWithDuration:(ccTime) t scene:(CCScene*)s orientation:(tOrientation)o;
@end


/** CCTransitionRotoZoom:
 Rotate and zoom out the outgoing scene, and then rotate and zoom in the incoming 
 */
@interface CCTransitionRotoZoom : CCTransitionScene
{}
@end

/** CCTransitionJumpZoom:
 Zoom out and jump the outgoing scene, and then jump and zoom in the incoming 
*/
@interface CCTransitionJumpZoom : CCTransitionScene
{}
@end

/** CCTransitionMoveInL:
 Move in from to the left the incoming scene.
*/
@interface CCTransitionMoveInL : CCTransitionScene <CCTransitionEaseScene>
{}
/** initializes the scenes */
-(void) initScenes;
/** returns the action that will be performed */
-(CCActionInterval*) action;
@end

/** CCTransitionMoveInR:
 Move in from to the right the incoming scene.
 */
@interface CCTransitionMoveInR : CCTransitionMoveInL
{}
@end

/** CCTransitionMoveInT:
 Move in from to the top the incoming scene.
 */
@interface CCTransitionMoveInT : CCTransitionMoveInL 
{}
@end

/** CCTransitionMoveInB:
 Move in from to the bottom the incoming scene.
 */
@interface CCTransitionMoveInB : CCTransitionMoveInL
{}
@end

/** CCTransitionSlideInL:
 Slide in the incoming scene from the left border.
 */
@interface CCTransitionSlideInL : CCTransitionScene <CCTransitionEaseScene>
{}
/** initializes the scenes */
-(void) initScenes;
/** returns the action that will be performed by the incomming and outgoing scene */
-(CCActionInterval*) action;
@end

/** CCTransitionSlideInR:
 Slide in the incoming scene from the right border.
 */
@interface CCTransitionSlideInR : CCTransitionSlideInL 
{}
@end

/** CCTransitionSlideInB:
 Slide in the incoming scene from the bottom border.
 */
@interface CCTransitionSlideInB : CCTransitionSlideInL
{}
@end

/** CCTransitionSlideInT:
 Slide in the incoming scene from the top border.
 */
@interface CCTransitionSlideInT : CCTransitionSlideInL
{}
@end

/**
 Shrink the outgoing scene while grow the incoming scene
 */
@interface CCTransitionShrinkGrow : CCTransitionScene <CCTransitionEaseScene>
{}
@end

/** CCTransitionFlipX:
 Flips the screen horizontally.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCTransitionFlipX : CCTransitionSceneOriented
{}
@end

/** CCTransitionFlipY:
 Flips the screen vertically.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCTransitionFlipY : CCTransitionSceneOriented
{}
@end

/** CCTransitionFlipAngular:
 Flips the screen half horizontally and half vertically.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCTransitionFlipAngular : CCTransitionSceneOriented
{}
@end

/** CCTransitionZoomFlipX:
 Flips the screen horizontally doing a zoom out/in
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCTransitionZoomFlipX : CCTransitionSceneOriented
{}
@end

/** CCTransitionZoomFlipY:
 Flips the screen vertically doing a little zooming out/in
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCTransitionZoomFlipY : CCTransitionSceneOriented
{}
@end

/** CCTransitionZoomFlipAngular:
 Flips the screen half horizontally and half vertically doing a little zooming out/in.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface CCTransitionZoomFlipAngular : CCTransitionSceneOriented
{}
@end

/** CCTransitionFade:
 Fade out the outgoing scene and then fade in the incoming scene.'''
 */
@interface CCTransitionFade : CCTransitionScene
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
 CCTransitionCrossFade:
 Cross fades two scenes using the CCRenderTexture object.
 */
@class CCRenderTexture;
@interface CCTransitionCrossFade : CCTransitionScene
{}
@end

/** CCTransitionTurnOffTiles:
 Turn off the tiles of the outgoing scene in random order
 */
@interface CCTransitionTurnOffTiles : CCTransitionScene <CCTransitionEaseScene>
{}
@end

/** CCTransitionSplitCols:
 The odd columns goes upwards while the even columns goes downwards.
 */
@interface CCTransitionSplitCols : CCTransitionScene <CCTransitionEaseScene>
{}
-(CCActionInterval*) action;
@end

/** CCTransitionSplitRows:
 The odd rows goes to the left while the even rows goes to the right.
 */
@interface CCTransitionSplitRows : CCTransitionSplitCols
{}
@end

/** CCTransitionFadeTR:
 Fade the tiles of the outgoing scene from the left-bottom corner the to top-right corner.
 */
@interface CCTransitionFadeTR : CCTransitionScene <CCTransitionEaseScene>
{}
-(CCActionInterval*) actionWithSize:(ccGridSize) vector;
@end

/** CCTransitionFadeBL:
 Fade the tiles of the outgoing scene from the top-right corner to the bottom-left corner.
 */
@interface CCTransitionFadeBL : CCTransitionFadeTR
{}
@end

/** CCTransitionFadeUp:
 * Fade the tiles of the outgoing scene from the bottom to the top.
 */
@interface CCTransitionFadeUp : CCTransitionFadeTR
{}
@end

/** CCTransitionFadeDown:
 * Fade the tiles of the outgoing scene from the top to the bottom.
 */
@interface CCTransitionFadeDown : CCTransitionFadeTR
{}
@end
