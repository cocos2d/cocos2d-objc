//
//  Transition.h
//  cocos2d
//


#import "Scene.h"
@class IntervalAction;
@class CocosNode;
/** Base class for actions
 */
@interface TransitionScene : Scene {
	Scene * inScene;
	Scene * outScene;
	double duration;
}
/** creates a base transition with duration and incoming scene */
+(id) transitionWithDuration:(double) t scene:(Scene*)s;
/** initializes a transition with duration and incoming scene */
-(id) initWithDuration:(double) t scene:(Scene*)s;
/** called before the transition starts */
-(void) start;
/** called after the transition finishes */
-(void) finish;
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
@interface FlipXTransition : TransitionScene
{
}
@end

/** FlipY Transition
 Flips the screen vertically.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface FlipYTransition : TransitionScene
{
}
@end

/** FlipAngular Transition
 Flips the screen half horizontally and half vertically.
 The front face is the outgoing scene and the back face is the incoming scene.
 */
@interface FlipAngularTransition : TransitionScene
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