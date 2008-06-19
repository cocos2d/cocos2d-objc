//
//  Transition.m
//  cocos2d
//


#import "Transition.h"
#import "CocosNode.h"
#import "Director.h"
#import "IntervalAction.h"
#import "InstantAction.h"
#import "CameraAction.h"
#import "Layer.h"

@implementation TransitionScene
+(id) transitionWithDuration:(double) t scene:(Scene*)s
{
	return [[[self alloc] initWithDuration:t scene:s] autorelease];
}

-(id) initWithDuration:(double) t scene:(Scene*)s
{
	NSAssert( s != nil, @"Argument scene must be non-nil");
	
	if( ! [super init] )
		return nil;
	
	duration = t;
	
	// Don't retain them, it will be reatined when added
	inScene = s;
	outScene = [[Director sharedDirector] runningScene];
	
	if( inScene == outScene ) {
		NSException* myException = [NSException
									exceptionWithName:@"TransitionWithInvalidScene"
									reason:@"Incoming scene must be different from the outgoing scene"
									userInfo:nil];
		@throw myException;		
	}
	
	[self start];
	return self;
}

-(void) start
{
	[self add: inScene z:1];
	[self add: outScene z:0];
}

-(void) finish
{
	/* clean up */	
	[inScene setVisible:YES];
	[inScene setPosition:CGPointMake(0,0)];
	[inScene setScale:1.0f];
	[inScene setRotation:0.0f];
	
	[outScene setVisible:YES];
	[outScene setPosition:CGPointMake(0,0)];
	[outScene setScale:1.0f];
	[outScene setRotation:0.0f];
	
	
	[[Director sharedDirector] replaceScene: inScene];

	[self remove: inScene];
	[self remove: outScene];
	
	inScene = nil;
	outScene = nil;

}
@end

//
// RotoZoom
//
@implementation RotoZoomTransition
-(void) start
{
	[super start];
	CGRect s = [[Director sharedDirector] winSize];
	
	[inScene setScale:0.001f];
	[outScene setScale:1.0f];
	
	[inScene setTransformAnchor: CGPointMake( s.size.width/2, s.size.height/2) ];
	[outScene setTransformAnchor: CGPointMake( s.size.width/2, s.size.height/2) ];
	
	IntervalAction *rotozoom = [Sequence actions: [Spawn actions:
								   [ScaleBy actionWithDuration:duration/2 scale:0.001f],
								   [RotateBy actionWithDuration:duration/2 angle:360 *2],
								   nil],
								[DelayTime actionWithDuration:duration/2],
							nil];
	
	
	[outScene do: rotozoom];
	[inScene do: [Sequence actions:
					[rotozoom reverse],
					[CallFunc actionWithTarget:self selector:@selector(finish)],
				  nil]];
}
@end

//
// JumpZoom
//
@implementation JumpZoomTransition
-(void) start
{
	[super start];
	CGRect s = [[Director sharedDirector] winSize];
	
	[inScene setScale:0.5f];
	[inScene setPosition:CGPointMake( s.size.width,0 )];
	
	[inScene setTransformAnchor: CGPointMake( s.size.width/2, s.size.height/2) ];
	[outScene setTransformAnchor: CGPointMake( s.size.width/2, s.size.height/2) ];

	IntervalAction *jump = [JumpBy actionWithDuration:duration/4 position:CGPointMake(-s.size.width,0) height:s.size.width/4 jumps:2];
	IntervalAction *scaleIn = [ScaleTo actionWithDuration:duration/4 scale:1.0f];
	IntervalAction *scaleOut = [ScaleTo actionWithDuration:duration/4 scale:0.5f];
	
	IntervalAction *jumpZoomOut = [Sequence actions: scaleOut, jump, nil];
	IntervalAction *jumpZoomIn = [Sequence actions: jump, scaleIn, nil];
	
	IntervalAction *delay = [DelayTime actionWithDuration:duration/2];
	
	[outScene do: jumpZoomOut];
	[inScene do: [Sequence actions: delay,
								jumpZoomIn,
								[CallFunc actionWithTarget:self selector:@selector(finish)],
								nil] ];
}
@end

//
// MoveInL
//
@implementation MoveInLTransition
-(void) start
{
	[super start];
	
	[self initScenes];
	
	IntervalAction *a = [self action];

	[inScene do: [Sequence actions:
		[Accelerate actionWithAction:a rate:0.5],
		[CallFunc actionWithTarget:self selector:@selector(finish)],
		nil] ];
	 		
}
-(IntervalAction*) action
{
	return [MoveTo actionWithDuration:duration position:CGPointMake(0,0)];
}

-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: CGPointMake( -s.size.width,0) ];
}
@end

//
// MoveInR
//
@implementation MoveInRTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: CGPointMake( s.size.width,0) ];
}
@end

//
// MoveInT
//
@implementation MoveInTTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: CGPointMake( 0, s.size.height) ];
}
@end

//
// MoveInB
//
@implementation MoveInBTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: CGPointMake( 0, -s.size.height) ];
}
@end

//
// SlideInL
//
@implementation SlideInLTransition
-(void) start
{
	[super start];
	
	[self initScenes];
	
	IntervalAction *a = [self action];

	[inScene do: [Accelerate actionWithAction:a rate:0.5] ];
	[outScene do: [Sequence actions:
				   [Accelerate actionWithAction:a rate:0.5],
				   [CallFunc actionWithTarget:self selector:@selector(finish)],
				   nil] ];	
}

-(IntervalAction*) action
{
	CGRect s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration delta:CGPointMake(s.size.width,0)];
}

-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: CGPointMake( -s.size.width,0) ];
}
@end

//
// SlideInR
//
@implementation SlideInRTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: CGPointMake( s.size.width,0) ];
}

-(IntervalAction*) action
{
	CGRect s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration delta:CGPointMake(-s.size.width,0)];
}

@end

//
// SlideInT
//
@implementation SlideInTTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: CGPointMake(0,s.size.height) ];
}

-(IntervalAction*) action
{
	CGRect s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration delta:CGPointMake(0,-s.size.height)];
}

@end

//
// SlideInB
//
@implementation SlideInBTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: CGPointMake(0,-s.size.height) ];
}

-(IntervalAction*) action
{
	CGRect s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration delta:CGPointMake(0,s.size.height)];
}
@end

//
// ShrinkGrow Transition
//
@implementation ShrinkGrowTransition
-(void) start
{
	[super start];
	
	CGRect s = [[Director sharedDirector] winSize];
	
	[inScene setScale:0.001f];
	[outScene setScale:1.0f];
	
	[inScene setTransformAnchor:CGPointMake(2*s.size.width/3,s.size.height/2) ];
	[outScene setTransformAnchor:CGPointMake(s.size.width/3,s.size.height/2) ];
	
	
	IntervalAction *scaleOut = [ScaleTo actionWithDuration:duration scale:0.01f];
	IntervalAction *scaleIn = [ScaleTo actionWithDuration:duration scale:1.0f];

	[inScene do: [Accelerate actionWithAction:scaleIn rate:0.5] ];
	[outScene do: [Sequence actions:
					[Accelerate actionWithAction:scaleOut rate:0.5],
					[CallFunc actionWithTarget:self selector:@selector(finish)],
					nil] ];
}
@end

//
// FlipX Transition
//
@implementation FlipXTransition
-(void) start
{
	[super start];

	[inScene setVisible: NO];
	IntervalAction *inA = [Sequence actions:
							[DelayTime actionWithDuration:duration/2],
							[Show action],
							[OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:270 deltaAngleZ:90 angleX:0 deltaAngleX:0],
							[CallFunc actionWithTarget:self selector:@selector(finish)],
						  nil ];
	IntervalAction *outA = [Sequence actions:
							[OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:90 angleX:0 deltaAngleX:0],
							[Hide action],
							[DelayTime actionWithDuration:duration/2],							
							nil ];
	
	[inScene do: inA];
	[outScene do: outA];
}
@end

//
// FlipY Transition
//
@implementation FlipYTransition
-(void) start
{
	[super start];
	
	[inScene setVisible: NO];
	IntervalAction *inA = [Sequence actions:
						   [DelayTime actionWithDuration:duration/2],
						   [Show action],
						   [OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:270 deltaAngleZ:90 angleX:90 deltaAngleX:0],
						   [CallFunc actionWithTarget:self selector:@selector(finish)],
						   nil ];
	IntervalAction *outA = [Sequence actions:
							[OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:90 angleX:90 deltaAngleX:0],
							[Hide action],
							[DelayTime actionWithDuration:duration/2],							
							nil ];
	
	[inScene do: inA];
	[outScene do: outA];
}
@end

//
// FlipAngular Transition
//
@implementation FlipAngularTransition
-(void) start
{
	[super start];
	
	[inScene setVisible: NO];
	IntervalAction *inA = [Sequence actions:
						   [DelayTime actionWithDuration:duration/2],
						   [Show action],
						   [OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:270 deltaAngleZ:90 angleX:-45 deltaAngleX:0],
						   [CallFunc actionWithTarget:self selector:@selector(finish)],
						   nil ];
	IntervalAction *outA = [Sequence actions:
							[OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:0 deltaAngleZ:90 angleX:45 deltaAngleX:0],
							[Hide action],
							[DelayTime actionWithDuration:duration/2],							
							nil ];
	
	[inScene do: inA];
	[outScene do: outA];
}
@end

//
// Fade Transition
//
@implementation FadeTransition
-(void) start
{
	[super start];
	
	ColorLayer *l = [ColorLayer layerWithColor: 0x00000000];
	[inScene setVisible: NO];
	
	[self add: l z:2 name:@"fade"];
}
-(void) onEnter
{
	[super onEnter];
	
	CocosNode *f = [self get:@"fade"];

	IntervalAction *a = [Sequence actions:
							[FadeIn actionWithDuration:duration/2],
							[CallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
							[FadeOut actionWithDuration:duration/2],
							[CallFunc actionWithTarget:self selector:@selector(finish)],
						 nil ];
	[f do: a];
}

-(void) onExit
{
	[super onExit];
	[self removeByName: @"fade"];
}

-(void) hideOutShowIn
{
	[inScene setVisible:YES];
	[outScene setVisible:NO];
}
@end


