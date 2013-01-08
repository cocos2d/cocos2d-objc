/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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



#import "CCTransition.h"
#import "CCNode.h"
#import "CCSprite.h"
#import "CCDirector.h"
#import "CCActionInterval.h"
#import "CCActionInstant.h"
#import "CCActionCamera.h"
#import "CCLayer.h"
#import "CCCamera.h"
#import "CCActionTiledGrid.h"
#import "CCActionEase.h"
#import "CCRenderTexture.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCTouchDispatcher.h"
#import "Platforms/iOS/CCDirectorIOS.h"
#elif defined(__CC_PLATFORM_MAC)
#import "Platforms/Mac/CCDirectorMac.h"
#import "Platforms/Mac/CCEventDispatcher.h"
#endif

const NSInteger kSceneFade = 0xFADEFADE;


@interface CCTransitionScene (Private)
-(void) sceneOrder;
- (void)setNewScene:(ccTime)dt;
@end

@implementation CCTransitionScene
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s
{
	return [[[self alloc] initWithDuration:t scene:s] autorelease];
}

-(id) initWithDuration:(ccTime) t scene:(CCScene*)s
{
	NSAssert( s != nil, @"Argument scene must be non-nil");

	if( (self=[super init]) ) {

		_duration = t;

		// retain
		_inScene = [s retain];
		_outScene = [[CCDirector sharedDirector] runningScene];
		[_outScene retain];

		NSAssert( _inScene != _outScene, @"Incoming scene must be different from the outgoing scene" );

		[self sceneOrder];
	}
	return self;
}
-(void) sceneOrder
{
	_inSceneOnTop = YES;
}

-(void) draw
{
	[super draw];

	if( _inSceneOnTop ) {
		[_outScene visit];
		[_inScene visit];
	} else {
		[_inScene visit];
		[_outScene visit];
	}
}

-(void) finish
{
	/* clean up */
	[_inScene setVisible:YES];
	[_inScene setPosition:ccp(0,0)];
	[_inScene setScale:1.0f];
	[_inScene setRotation:0.0f];
	[_inScene.camera restore];

	[_outScene setVisible:NO];
	[_outScene setPosition:ccp(0,0)];
	[_outScene setScale:1.0f];
	[_outScene setRotation:0.0f];
	[_outScene.camera restore];

	[self schedule:@selector(setNewScene:) interval:0];
}

-(void) setNewScene: (ccTime) dt
{
	[self unschedule:_cmd];

	CCDirector *director = [CCDirector sharedDirector];

	// Before replacing, save the "send cleanup to scene"
	_sendCleanupToScene = [director sendCleanupToScene];

	[director replaceScene: _inScene];

	// issue #267
	[_outScene setVisible:YES];
}

-(void) hideOutShowIn
{
	[_inScene setVisible:YES];
	[_outScene setVisible:NO];
}

// custom onEnter
-(void) onEnter
{
	[super onEnter];
	
	// disable events while transitions
	CCDirector *director = [CCDirector sharedDirector];
#ifdef __CC_PLATFORM_IOS
	[[director touchDispatcher] setDispatchEvents: NO];
#elif defined(__CC_PLATFORM_MAC)
	[[director eventDispatcher] setDispatchEvents: NO];
#endif
	
	
	// _outScene should not receive the onExit callback
	// only the onExitTransitionDidStart
	[_outScene onExitTransitionDidStart];
	
	[_inScene onEnter];
}

// custom onExit
-(void) onExit
{
	[super onExit];
	
	// enable events while transitions
	CCDirector *director = [CCDirector sharedDirector];
#ifdef __CC_PLATFORM_IOS
	[[director touchDispatcher] setDispatchEvents: YES];
#elif defined(__CC_PLATFORM_MAC)
	[[director eventDispatcher] setDispatchEvents: YES];
#endif
	

	[_outScene onExit];

	// _inScene should not receive the onEnter callback
	// only the onEnterTransitionDidFinish
	[_inScene onEnterTransitionDidFinish];
}

// custom cleanup
-(void) cleanup
{
	[super cleanup];

	if( _sendCleanupToScene )
	   [_outScene cleanup];
}

-(void) dealloc
{
	[_inScene release];
	[_outScene release];
	[super dealloc];
}
@end

//
// Oriented Transition
//
@implementation CCTransitionSceneOriented
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s orientation:(tOrientation)o
{
	return [[[self alloc] initWithDuration:t scene:s orientation:o] autorelease];
}

-(id) initWithDuration:(ccTime) t scene:(CCScene*)s orientation:(tOrientation)o
{
	if( (self=[super initWithDuration:t scene:s]) )
		orientation = o;
	return self;
}
@end


//
// RotoZoom
//
@implementation CCTransitionRotoZoom
-(id) init {
	return [super init];
}

-(void) onEnter
{
	[super onEnter];

	[_inScene setScale:0.001f];
	[_outScene setScale:1.0f];

	[_inScene setAnchorPoint:ccp(0.5f, 0.5f)];
	[_outScene setAnchorPoint:ccp(0.5f, 0.5f)];

	CCActionInterval *rotozoom = [CCSequence actions: [CCSpawn actions:
								   [CCScaleBy actionWithDuration:_duration/2 scale:0.001f],
								   [CCRotateBy actionWithDuration:_duration/2 angle:360 *2],
								   nil],
								[CCDelayTime actionWithDuration:_duration/2],
							nil];


	[_outScene runAction: rotozoom];
	[_inScene runAction: [CCSequence actions:
					[rotozoom reverse],
					[CCCallFunc actionWithTarget:self selector:@selector(finish)],
				  nil]];
}
@end

//
// JumpZoom
//
@implementation CCTransitionJumpZoom
-(id) init {
	return [super init];
}
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];

	[_inScene setScale:0.5f];
	[_inScene setPosition:ccp( s.width,0 )];

	[_inScene setAnchorPoint:ccp(0.5f, 0.5f)];
	[_outScene setAnchorPoint:ccp(0.5f, 0.5f)];

	CCActionInterval *jump = [CCJumpBy actionWithDuration:_duration/4 position:ccp(-s.width,0) height:s.width/4 jumps:2];
	CCActionInterval *scaleIn = [CCScaleTo actionWithDuration:_duration/4 scale:1.0f];
	CCActionInterval *scaleOut = [CCScaleTo actionWithDuration:_duration/4 scale:0.5f];

	CCActionInterval *jumpZoomOut = [CCSequence actions: scaleOut, jump, nil];
	CCActionInterval *jumpZoomIn = [CCSequence actions: jump, scaleIn, nil];

	CCActionInterval *delay = [CCDelayTime actionWithDuration:_duration/2];

	[_outScene runAction: jumpZoomOut];
	[_inScene runAction: [CCSequence actions: delay,
								jumpZoomIn,
								[CCCallFunc actionWithTarget:self selector:@selector(finish)],
								nil] ];
}
@end

//
// MoveInL
//
@implementation CCTransitionMoveInL
-(void) onEnter
{
	[super onEnter];

	[self initScenes];

	CCActionInterval *a = [self action];

	[_inScene runAction: [CCSequence actions:
						 [self easeActionWithAction:a],
						 [CCCallFunc actionWithTarget:self selector:@selector(finish)],
						 nil]
	];

}
-(CCActionInterval*) action
{
	return [CCMoveTo actionWithDuration:_duration position:ccp(0,0)];
}

-(CCActionInterval*) easeActionWithAction:(CCActionInterval*)action
{
	return [CCEaseOut actionWithAction:action rate:2.0f];
//	return [EaseElasticOut actionWithAction:action period:0.4f];
}

-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[_inScene setPosition: ccp( -s.width,0) ];
}
@end

//
// MoveInR
//
@implementation CCTransitionMoveInR
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[_inScene setPosition: ccp( s.width,0) ];
}
@end

//
// MoveInT
//
@implementation CCTransitionMoveInT
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[_inScene setPosition: ccp( 0, s.height) ];
}
@end

//
// MoveInB
//
@implementation CCTransitionMoveInB
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[_inScene setPosition: ccp( 0, -s.height) ];
}
@end

//
// SlideInL
//

// The adjust factor is needed to prevent issue #442
// One solution is to use DONT_RENDER_IN_SUBPIXELS images, but NO
// The other issue is that in some transitions (and I don't know why)
// the order should be reversed (In in top of Out or vice-versa).
#define ADJUST_FACTOR 0.5f
@implementation CCTransitionSlideInL
-(void) onEnter
{
	[super onEnter];

	[self initScenes];

	CCActionInterval *in = [self action];
	CCActionInterval *out = [self action];

	id inAction = [self easeActionWithAction:in];
	id outAction = [CCSequence actions:
					[self easeActionWithAction:out],
					[CCCallFunc actionWithTarget:self selector:@selector(finish)],
					nil];

	[_inScene runAction: inAction];
	[_outScene runAction: outAction];
}
-(void) sceneOrder
{
	_inSceneOnTop = NO;
}
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[_inScene setPosition: ccp( -(s.width-ADJUST_FACTOR),0) ];
}
-(CCActionInterval*) action
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [CCMoveBy actionWithDuration:_duration position:ccp(s.width-ADJUST_FACTOR,0)];
}

-(CCActionInterval*) easeActionWithAction:(CCActionInterval*)action
{
	return [CCEaseOut actionWithAction:action rate:2.0f];
//	return [EaseElasticOut actionWithAction:action period:0.4f];
}

@end

//
// SlideInR
//
@implementation CCTransitionSlideInR
-(void) sceneOrder
{
	_inSceneOnTop = YES;
}
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[_inScene setPosition: ccp( s.width-ADJUST_FACTOR,0) ];
}

-(CCActionInterval*) action
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [CCMoveBy actionWithDuration:_duration position:ccp(-(s.width-ADJUST_FACTOR),0)];
}

@end

//
// SlideInT
//
@implementation CCTransitionSlideInT
-(void) sceneOrder
{
	_inSceneOnTop = NO;
}
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[_inScene setPosition: ccp(0,s.height-ADJUST_FACTOR) ];
}

-(CCActionInterval*) action
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [CCMoveBy actionWithDuration:_duration position:ccp(0,-(s.height-ADJUST_FACTOR))];
}

@end

//
// SlideInB
//
@implementation CCTransitionSlideInB
-(void) sceneOrder
{
	_inSceneOnTop = YES;
}

-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[_inScene setPosition: ccp(0,-(s.height-ADJUST_FACTOR)) ];
}

-(CCActionInterval*) action
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [CCMoveBy actionWithDuration:_duration position:ccp(0,s.height-ADJUST_FACTOR)];
}
@end

//
// ShrinkGrow Transition
//
@implementation CCTransitionShrinkGrow
-(id) init {
	return [super init];
}
-(void) onEnter
{
	[super onEnter];

	[_inScene setScale:0.001f];
	[_outScene setScale:1.0f];

	[_inScene setAnchorPoint:ccp(2/3.0f,0.5f)];
	[_outScene setAnchorPoint:ccp(1/3.0f,0.5f)];

	CCActionInterval *scaleOut = [CCScaleTo actionWithDuration:_duration scale:0.01f];
	CCActionInterval *scaleIn = [CCScaleTo actionWithDuration:_duration scale:1.0f];

	[_inScene runAction: [self easeActionWithAction:scaleIn]];
	[_outScene runAction: [CCSequence actions:
					[self easeActionWithAction:scaleOut],
					[CCCallFunc actionWithTarget:self selector:@selector(finish)],
					nil] ];
}
-(CCActionInterval*) easeActionWithAction:(CCActionInterval*)action
{
	return [CCEaseOut actionWithAction:action rate:2.0f];
//	return [EaseElasticOut actionWithAction:action period:0.3f];
}
@end

//
// FlipX Transition
//
@implementation CCTransitionFlipX
-(id) init {
	return [super init];
}
-(void) onEnter
{
	[super onEnter];

	CCActionInterval *inA, *outA;
	[_inScene setVisible: NO];

	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kCCTransitionOrientationRightOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}

	inA = [CCSequence actions:
		   [CCDelayTime actionWithDuration:_duration/2],
		   [CCShow action],
		   [CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:0 deltaAngleX:0],
		   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [CCSequence actions:
			[CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:0 deltaAngleX:0],
			[CCHide action],
			[CCDelayTime actionWithDuration:_duration/2],
			nil ];

	[_inScene runAction: inA];
	[_outScene runAction: outA];

}
@end

//
// FlipY Transition
//
@implementation CCTransitionFlipY
-(id) init {
	return [super init];
}
-(void) onEnter
{
	[super onEnter];

	CCActionInterval *inA, *outA;
	[_inScene setVisible: NO];

	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kCCTransitionOrientationUpOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
	inA = [CCSequence actions:
		   [CCDelayTime actionWithDuration:_duration/2],
		   [CCShow action],
		   [CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:90 deltaAngleX:0],
		   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [CCSequence actions:
			[CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:90 deltaAngleX:0],
			[CCHide action],
			[CCDelayTime actionWithDuration:_duration/2],
			nil ];

	[_inScene runAction: inA];
	[_outScene runAction: outA];

}
@end

//
// FlipAngular Transition
//
@implementation CCTransitionFlipAngular
-(id) init {
	return [super init];
}
-(void) onEnter
{
	[super onEnter];

	CCActionInterval *inA, *outA;
	[_inScene setVisible: NO];

	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kCCTransitionOrientationRightOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
	inA = [CCSequence actions:
			   [CCDelayTime actionWithDuration:_duration/2],
			   [CCShow action],
			   [CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:-45 deltaAngleX:0],
			   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
			   nil ];
	outA = [CCSequence actions:
				[CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:45 deltaAngleX:0],
				[CCHide action],
				[CCDelayTime actionWithDuration:_duration/2],
				nil ];

	[_inScene runAction: inA];
	[_outScene runAction: outA];
}
@end

//
// ZoomFlipX Transition
//
@implementation CCTransitionZoomFlipX
-(id) init {
	return [super init];
}
-(void) onEnter
{
	[super onEnter];

	CCActionInterval *inA, *outA;
	[_inScene setVisible: NO];

	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kCCTransitionOrientationRightOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
	inA = [CCSequence actions:
		   [CCDelayTime actionWithDuration:_duration/2],
		   [CCSpawn actions:
			[CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:0 deltaAngleX:0],
			[CCScaleTo actionWithDuration:_duration/2 scale:1],
			[CCShow action],
			nil],
		   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [CCSequence actions:
			[CCSpawn actions:
			 [CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:0 deltaAngleX:0],
			 [CCScaleTo actionWithDuration:_duration/2 scale:0.5f],
			 nil],
			[CCHide action],
			[CCDelayTime actionWithDuration:_duration/2],
			nil ];

	_inScene.scale = 0.5f;
	[_inScene runAction: inA];
	[_outScene runAction: outA];
}
@end

//
// ZoomFlipY Transition
//
@implementation CCTransitionZoomFlipY
-(id) init {
	return [super init];
}
-(void) onEnter
{
	[super onEnter];

	CCActionInterval *inA, *outA;
	[_inScene setVisible: NO];

	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kCCTransitionOrientationUpOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}

	inA = [CCSequence actions:
			   [CCDelayTime actionWithDuration:_duration/2],
			   [CCSpawn actions:
				 [CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:90 deltaAngleX:0],
				 [CCScaleTo actionWithDuration:_duration/2 scale:1],
				 [CCShow action],
				 nil],
			   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
			   nil ];
	outA = [CCSequence actions:
				[CCSpawn actions:
				 [CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:90 deltaAngleX:0],
				 [CCScaleTo actionWithDuration:_duration/2 scale:0.5f],
				 nil],
				[CCHide action],
				[CCDelayTime actionWithDuration:_duration/2],
				nil ];

	_inScene.scale = 0.5f;
	[_inScene runAction: inA];
	[_outScene runAction: outA];
}
@end

//
// ZoomFlipAngular Transition
//
@implementation CCTransitionZoomFlipAngular
-(id) init {
	return [super init];
}
-(void) onEnter
{
	[super onEnter];

	CCActionInterval *inA, *outA;
	[_inScene setVisible: NO];

	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kCCTransitionOrientationUpOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}

	inA = [CCSequence actions:
		   [CCDelayTime actionWithDuration:_duration/2],
		   [CCSpawn actions:
			[CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:-45 deltaAngleX:0],
			[CCScaleTo actionWithDuration:_duration/2 scale:1],
			[CCShow action],
			nil],
		   [CCShow action],
		   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [CCSequence actions:
			[CCSpawn actions:
			 [CCOrbitCamera actionWithDuration: _duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:45 deltaAngleX:0],
			 [CCScaleTo actionWithDuration:_duration/2 scale:0.5f],
			 nil],
			[CCHide action],
			[CCDelayTime actionWithDuration:_duration/2],
			nil ];

	_inScene.scale = 0.5f;
	[_inScene runAction: inA];
	[_outScene runAction: outA];
}
@end


//
// Fade Transition
//
@implementation CCTransitionFade
+(id) transitionWithDuration:(ccTime)d scene:(CCScene*)s withColor:(ccColor3B)color
{
	return [[[self alloc] initWithDuration:d scene:s withColor:color] autorelease];
}

-(id) initWithDuration:(ccTime)d scene:(CCScene*)s withColor:(ccColor3B)aColor
{
	if( (self=[super initWithDuration:d scene:s]) ) {
		color.r = aColor.r;
		color.g = aColor.g;
		color.b = aColor.b;
	}

	return self;
}

-(id) initWithDuration:(ccTime)d scene:(CCScene*)s
{
	return [self initWithDuration:d scene:s withColor:ccBLACK];
}

-(void) onEnter
{
	[super onEnter];

	CCLayerColor *l = [CCLayerColor layerWithColor:color];
	[_inScene setVisible: NO];

	[self addChild: l z:2 tag:kSceneFade];


	CCNode *f = [self getChildByTag:kSceneFade];

	CCActionInterval *a = [CCSequence actions:
						   [CCFadeIn actionWithDuration:_duration/2],
						   [CCCallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
						   [CCFadeOut actionWithDuration:_duration/2],
						   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
						   nil ];
	[f runAction: a];
}

-(void) onExit
{
	[super onExit];
	[self removeChildByTag:kSceneFade cleanup:YES];
}
@end


//
// Cross Fade Transition
//
@implementation CCTransitionCrossFade
-(id) init {
	return [super init];
}
-(void) draw
{
	// override draw since both scenes (textures) are rendered in 1 scene
}

-(void) onEnter
{
	[super onEnter];

	// create a transparent color layer
	// in which we are going to add our rendertextures
	ccColor4B  color = {0,0,0,0};
	CGSize size = [[CCDirector sharedDirector] winSize];
	CCLayerColor * layer = [CCLayerColor layerWithColor:color];

	// create the first render texture for _inScene
	CCRenderTexture *inTexture = [CCRenderTexture renderTextureWithWidth:size.width height:size.height];
	inTexture.sprite.anchorPoint= ccp(0.5f,0.5f);
	inTexture.position = ccp(size.width/2, size.height/2);
	inTexture.anchorPoint = ccp(0.5f,0.5f);

	// render _inScene to its texturebuffer
	[inTexture begin];
	[_inScene visit];
	[inTexture end];

	// create the second render texture for _outScene
	CCRenderTexture *outTexture = [CCRenderTexture renderTextureWithWidth:size.width height:size.height];
	outTexture.sprite.anchorPoint= ccp(0.5f,0.5f);
	outTexture.position = ccp(size.width/2, size.height/2);
	outTexture.anchorPoint = ccp(0.5f,0.5f);

	// render _outScene to its texturebuffer
	[outTexture begin];
	[_outScene visit];
	[outTexture end];

	// create blend functions

	ccBlendFunc blend1 = {GL_ONE, GL_ONE}; // _inScene will lay on background and will not be used with alpha
	ccBlendFunc blend2 = {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}; // we are going to blend _outScene via alpha

	// set blendfunctions
	[inTexture.sprite setBlendFunc:blend1];
	[outTexture.sprite setBlendFunc:blend2];

	// add render textures to the layer
	[layer addChild:inTexture];
	[layer addChild:outTexture];

	// initial opacity:
	[inTexture.sprite setOpacity:255];
	[outTexture.sprite setOpacity:255];

	// create the blend action
	CCActionInterval * layerAction = [CCSequence actions:
									  [CCFadeTo actionWithDuration:_duration opacity:0],
									  [CCCallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
									  [CCCallFunc actionWithTarget:self selector:@selector(finish)],
									  nil ];


	// run the blend action
	[outTexture.sprite runAction: layerAction];

	// add the layer (which contains our two rendertextures) to the scene
	[self addChild: layer z:2 tag:kSceneFade];
}

// clean up on exit
-(void) onExit
{
	// remove our layer and release all containing objects
	[self removeChildByTag:kSceneFade cleanup:YES];

	[super onExit];
}
@end

//
// TurnOffTilesTransition
//
@implementation CCTransitionTurnOffTiles
-(id) init {
	return [super init];
}
// override addScenes, and change the order
-(void) sceneOrder
{
	_inSceneOnTop = NO;
}

-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	float aspect = s.width / s.height;
	int x = 12 * aspect;
	int y = 12;

	id toff = [CCTurnOffTiles actionWithDuration:_duration size:CGSizeMake(x,y)];
	id action = [self easeActionWithAction:toff];
	[_outScene runAction: [CCSequence actions: action,
				   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
				   [CCStopGrid action],
				   nil]
	 ];

}
-(CCActionInterval*) easeActionWithAction:(CCActionInterval*)action
{
	return action;
//	return [EaseIn actionWithAction:action rate:2.0f];
}
@end

#pragma mark Split Transitions

//
// SplitCols Transition
//
@implementation CCTransitionSplitCols

-(void) onEnter
{
	[super onEnter];

	_inScene.visible = NO;

	id split = [self action];
	id seq = [CCSequence actions:
				split,
				[CCCallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
				[split reverse],
				nil
			  ];
	[self runAction: [CCSequence actions:
			   [self easeActionWithAction:seq],
			   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
			   [CCStopGrid action],
			   nil]
	 ];
}

-(CCActionInterval*) action
{
	return [CCSplitCols actionWithDuration:_duration/2.0f cols:3];
}

-(CCActionInterval*) easeActionWithAction:(CCActionInterval*)action
{
	return [CCEaseInOut actionWithAction:action rate:3.0f];
}
@end

//
// SplitRows Transition
//
@implementation CCTransitionSplitRows
-(CCActionInterval*) action
{
	return [CCSplitRows actionWithDuration:_duration/2.0f rows:3];
}
@end


#pragma mark Fade Grid Transitions

//
// FadeTR Transition
//
@implementation CCTransitionFadeTR
-(void) sceneOrder
{
	_inSceneOnTop = NO;
}

-(void) onEnter
{
	[super onEnter];

	CGSize s = [[CCDirector sharedDirector] winSize];
	float aspect = s.width / s.height;
	int x = 12 * aspect;
	int y = 12;

	id action  = [self actionWithSize:CGSizeMake(x,y)];

	[_outScene runAction: [CCSequence actions:
					[self easeActionWithAction:action],
				    [CCCallFunc actionWithTarget:self selector:@selector(finish)],
				    [CCStopGrid action],
				    nil]
	 ];
}

-(CCActionInterval*) actionWithSize: (CGSize) v
{
	return [CCFadeOutTRTiles actionWithDuration:_duration size:v];
}

-(CCActionInterval*) easeActionWithAction:(CCActionInterval*)action
{
	return action;
//	return [CCEaseOut actionWithAction:action rate:3.0f];
}
@end

//
// FadeBL Transition
//
@implementation CCTransitionFadeBL
-(CCActionInterval*) actionWithSize: (CGSize) v
{
	return [CCFadeOutBLTiles actionWithDuration:_duration size:v];
}
@end

//
// FadeUp Transition
//
@implementation CCTransitionFadeUp
-(CCActionInterval*) actionWithSize: (CGSize) v
{
	return [CCFadeOutUpTiles actionWithDuration:_duration size:v];
}
@end

//
// FadeDown Transition
//
@implementation CCTransitionFadeDown
-(CCActionInterval*) actionWithSize: (CGSize) v
{
	return [CCFadeOutDownTiles actionWithDuration:_duration size:v];
}
@end
