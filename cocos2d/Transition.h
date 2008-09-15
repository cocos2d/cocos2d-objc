/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#import "Scene.h"
@class IntervalAction;
@class CocosNode;

typedef enum {
	kOrientationLeftRight = 0,
	kOrientationRightLeft = 1,
	kOrientationUpOver = 0,
	kOrientationDownOver = 1,
} tOrientation;

/** Base class for actions
 */
@interface TransitionScene : Scene {
	Scene * inScene;
	Scene * outScene;
	ccTime duration;	
}
/** creates a base transition with duration and incoming scene */
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s;
/** initializes a transition with duration and incoming scene */
-(id) initWithDuration:(ccTime) t scene:(Scene*)s;
/** called after the transition finishes */
-(void) finish;
@end

@interface OrientedTransitionScene : TransitionScene
{
	tOrientation orientation;
}
/** creates a base transition with duration and incoming scene */
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s orientation:(tOrientation)o;
/** initializes a transition with duration and incoming scene */
-(id) initWithDuration:(ccTime) t scene:(Scene*)s orientation:(tOrientation)o;
@end


/** RotoZoom Transition.
 Rotate and zoom out the outgoing scene, and then rotate and zoom in the incoming 
 */
@interface RotoZoomTransition : TransitionScene
{
}
@end

/** JumpZoom Transition
 Zoom out and jump the outgoing scene, and then jump and zoom in the incoming 
*/
@interface JumpZoomTransition : TransitionScene
{
}
@end

/** MoveInL Transition
 Move in from to the left the incoming scene.
*/
@interface MoveInLTransition : TransitionScene
{
}
/** initializes the scenes */
-(void) initScenes;
/** returns the action that will be performed */
-(IntervalAction*) action;
@end

/** MoveInR Transition
 Move in from to the right the incoming scene.
 */
@interface MoveInRTransition : MoveInLTransition
{
}
@end

/** MoveInT Transition
 Move in from to the top the incoming scene.
 */
@interface MoveInTTransition : MoveInLTransition
{
}
@end

/** MoveInB Transition
 Move in from to the bottom the incoming scene.
 */
@interface MoveInBTransition : MoveInLTransition
{
}
@end

/** SlideInL Transition
 Slide in the incoming scene from the left border.
 */
@interface SlideInLTransition : TransitionScene
{
}
/** initializes the scenes */
-(void) initScenes;
/** returns the action that will be performed */
-(IntervalAction*) action;
@end

/** SlideInR Transition
 Slide in the incoming scene from the right border.
 */
@interface SlideInRTransition : SlideInLTransition
{
}
@end

/** SlideInB Transition
 Slide in the incoming scene from the bottom border.
 */
@interface SlideInBTransition : SlideInLTransition
{
}
@end

/** SlideInT Transition
 Slide in the incoming scene from the top border.
 */
@interface SlideInTTransition : SlideInLTransition
{
}
@end

/**
 Shrink the outgoing scene while grow the incoming scene
 */
@interface ShrinkGrowTransition : TransitionScene
{
}
@end

/** FlipX Transition
 Flips the screen horizontally.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface FlipXTransition : OrientedTransitionScene
{
}
@end

/** FlipY Transition
 Flips the screen vertically.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface FlipYTransition : OrientedTransitionScene
{
}
@end

/** FlipAngular Transition
 Flips the screen half horizontally and half vertically.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface FlipAngularTransition : OrientedTransitionScene
{
}
@end

/** ZoomFlipX Transition
 Flips the screen horizontally doing a zoom out/in
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface ZoomFlipXTransition : OrientedTransitionScene
{
}
@end

/** ZoomFlipY Transition
 Flips the screen vertically doing a little zooming out/in
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface ZoomFlipYTransition : OrientedTransitionScene
{
}
@end

/** ZoomFlipAngular Transition
 Flips the screen half horizontally and half vertically doing a little zooming out/in.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface ZoomFlipAngularTransition : OrientedTransitionScene
{
}
@end

/** Fade Transition
 Fade out the outgoing scene and then fade in the incoming scene.'''
 */
@interface FadeTransition : TransitionScene
{
}
-(void) hideOutShowIn;
@end
