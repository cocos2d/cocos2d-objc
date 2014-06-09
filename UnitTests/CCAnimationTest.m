//
//  CCAnimationTest.m
//  cocos2d-tests-ios
//
//  Created by John Twigg on 4/9/14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"
#import "CCAnimationManager.h"
#import "CCBSequence.h"
#import "CCBKeyframe.h"
#import "CCAnimationManager_Private.h"

#define NUM_ELEMENTS(array) (sizeof(array)/sizeof(array[0]))

#define AssertNotEqualWithAccuracy(a1,a2,accuracy,format...)\
{\
__typeof__(a1) a1value = (a1);\
__typeof__(a2) a2value = (a2);\
__typeof__(accuracy) accuracyvalue = (accuracy); \
{\
if((MAX(a1value, a2value) - MIN(a1value, a2)) <= accuracy)\
{\
NSValue *a1encoded = [NSValue value:&a1value withObjCType:@encode(__typeof__(a1))]; \
NSValue *a2encoded = [NSValue value:&a2value withObjCType:@encode(__typeof__(a2))]; \
NSValue *accuracyencoded = [NSValue value:&accuracyvalue withObjCType:@encode(__typeof__(accuracy))]; \
_XCTRegisterFailure(_XCTFailureDescription(_XCTAssertion_NotEqualWithAccuracy, 0, @#a1, @#a2, @#accuracy, _XCTDescriptionForValue(a1encoded), _XCTDescriptionForValue(a2encoded), _XCTDescriptionForValue(accuracyencoded)), ## format); \
}\
}\
}

//XCTFail(format);\

@interface CCAnimationTest : XCTestCase

@end

@implementation CCAnimationTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}


- (void)testSmallKeyframesTest
{
	CCAnimationManager * animationManager = [[CCAnimationManager alloc] init];
	CCNode * node = [[CCNode alloc] init];
	node.name = @"testNode";
	node.position = ccp(0.0f,0.0f);
	

	CCBSequence* seq = [[CCBSequence alloc] init];
	seq.duration = 5.0f;
	seq.name = @"TestSequence";
	seq.sequenceId = 0;
	seq.chainedSequenceId = 0;
	[animationManager.sequences addObject:seq];
	
	CCBSequenceProperty* seqProp = [[CCBSequenceProperty alloc] init];
	
	seqProp.name = @"position";
	seqProp.type = 0;
	
	const int numKeyframes = 6;
	
	NSArray * points = @[@[@(0.0f),@(0.0f)],
						 @[@(10.0f),@(0.0f)],
						 @[@(30.0f),@(0.0f)],
						 @[@(40.0f),@(0.0f)],
						 @[@(50.0f),@(0.0f)],
						 @[@(0.0f),@(0.0f)]];
	
	
	for (int k = 0; k < numKeyframes; k++)
	{
		CCBKeyframe* keyframe = [[CCBKeyframe alloc] init];
		keyframe.time = (float)k * seq.duration / (float)(numKeyframes - 1);
		
		keyframe.easingType = kCCBKeyframeEasingLinear;
		keyframe.easingOpt = 0;
		keyframe.value = points[k];
		
		[seqProp.keyframes addObject:keyframe];
	}
	
	NSMutableDictionary* seqNodeProps = [NSMutableDictionary dictionary];
	[seqNodeProps setObject:seqProp forKey:seqProp.name];
	
	NSMutableDictionary* seqs = [NSMutableDictionary dictionary];
	[seqs setObject:seqNodeProps forKey:[NSNumber numberWithInt:seq.sequenceId]];
	
	[animationManager addNode:node andSequences:seqs];
	[animationManager runAnimationsForSequenceId:seq.sequenceId tweenDuration:0];
	
	CGFloat accuracy = 0.01f;
	
	CGPoint lastPos = node.position;
	for(int i = 0; i <= 5 * 20; i++)
	{
		[animationManager update:0.1f];
		
		//Uncomment to debug
		//CCLOG(@"Pos (%0.2f,%0.2f) i=%i",node.position.x,node.position.y, i);
	
		if(i == 49)
		{
			//When we zoom back to to the root pos, there should be no abrupt jump.
			//On the last frame we zoom back to the root pos.
			//We're moving from x=50 to x=0 in 1second, stepping at 0.1 deltaTime per step.
			//Therefore, we're moving x=5 per step. On our last step we should be x=5 from the end.
			//However because we stuttured on the previous frames, we're out of sync.
			XCTAssertTrue(node.position.x < 6.0f, @"Should be one tick from the end. ~5x i=%i, ", i);

			
		}
		else if(i >= 1) //Forgive the first frame.
		{
			//watch out for keyframe changes. Should not stutter.
			XCTAssertTrue(fabsf(lastPos.x - node.position.x) > accuracy, @"Should move the position every tick. i=%i, ", i);
		}
		
		lastPos = node.position;
	}
}

struct PositionKeyframes
{
	float   time;
	CGPoint position;
};

NSDictionary * createPositionSequencePropery(struct PositionKeyframes * keyframes, int count)
{
	
	const int kSequencerID = 0; //for now;
	
	CCBSequenceProperty* seqProp = [[CCBSequenceProperty alloc] init];
	
	seqProp.name = @"position";
	seqProp.type = 0;
	
	
	for (int k = 0; k < count; k++)
	{
		CCBKeyframe* keyframe = [[CCBKeyframe alloc] init];
		keyframe.time = keyframes[k].time;
		
		keyframe.easingType = kCCBKeyframeEasingLinear;
		keyframe.easingOpt = 0;
		keyframe.value = @[@(keyframes[k].position.x),@(keyframes[k].position.y)];
		
		[seqProp.keyframes addObject:keyframe];
	}

	NSMutableDictionary* seqNodeProps = [NSMutableDictionary dictionary];
	[seqNodeProps setObject:seqProp forKey:seqProp.name];
	
	NSMutableDictionary* seqs = [NSMutableDictionary dictionary];
	[seqs setObject:seqNodeProps forKey:[NSNumber numberWithInt:kSequencerID]];
	
	return seqs;
}

- (void)testAnimationSync
{
	CCAnimationManager * animationManager = [[CCAnimationManager alloc] init];
	CCBSequence* seq = [[CCBSequence alloc] init];
	seq.duration = 4.0f;
	seq.name = @"TestSequence";
	seq.sequenceId = 0;
	seq.chainedSequenceId = 0;
	[animationManager.sequences addObject:seq];
	
	/////////////////////////////////////////////
	
	CCNode * nodeA = [[CCNode alloc] init];
	nodeA.name = @"testA";
	nodeA.position = ccp(0.0f,0.0f);
	
	struct PositionKeyframes  positionsA[] =
		{{0.0f,0.0f,0.0f},
		{1.0f,100.0f,0.0f},
		{3.0f,100.0f,0.0f},
		{4.0f,0.0f,0.0f}};
		
				
	[animationManager addNode:nodeA andSequences:createPositionSequencePropery(positionsA, NUM_ELEMENTS(positionsA))];
	
	/////////////////////////////////////////////
	
	CCNode * nodeB = [[CCNode alloc] init];
	nodeB.name = @"testB";
	nodeB.position = ccp(0.0f,0.0f);
	
	struct PositionKeyframes  positionsB[] =
		{{0.0f,0.0f,0.0f},
		 {1.0f,0.0f,0.0f},
		{2.0f,100.0f,0.0f},
		{3.0f,100.0f,0.0f},
		{4.0f,0.0f,0.0f}};
	
	[animationManager addNode:nodeB andSequences:createPositionSequencePropery(positionsB, NUM_ELEMENTS(positionsB))];


	/////////////////////////////////////////////
	
	
	CCNode * nodeC = [[CCNode alloc] init];
	nodeC.name = @"testC";
	nodeC.position = ccp(0.0f,0.0f);
	
	struct PositionKeyframes  positionsC[] =
		{	{0.0f,0.0f,0.0f},
			{2.0f,0.0f,0.0f},
			{3.0f,100.0f,0.0f},
			{4.0f,0.0f,0.0f}};
		
	[animationManager addNode:nodeC andSequences:createPositionSequencePropery(positionsC, NUM_ELEMENTS(positionsC))];
	
	/////////////////////////////////////////////
	
	[animationManager runAnimationsForSequenceId:seq.sequenceId tweenDuration:0];
	
	
	const float kDelta = 0.1f;//100ms;
	const CGFloat kAccuracy = 0.01f;
	
	float timeIntoSeq = 0.0f;
	float elapsed = 0.0f;
	
	while(elapsed <= seq.duration * 10)
	{
		timeIntoSeq = fmod(elapsed, seq.duration);
		[animationManager update:kDelta];
		
		elapsed += kDelta;
		
		timeIntoSeq = fmod(elapsed, seq.duration);
		
		if(timeIntoSeq >= 3.0f)
		{
			//All final translations go from x=100 -> x=0 over 1 second.
			float perentageIntroSyncedTranlation = 1.0f - (seq.duration - timeIntoSeq);
			float desiredXCoord = (1.0f - perentageIntroSyncedTranlation) * 100.0f;
			
			
			XCTAssertTrue(fabsf(nodeA.position.x - nodeB.position.x) < kAccuracy, @"They should all equal each other");
			
			XCTAssertTrue(fabsf(nodeA.position.x - nodeC.position.x) < kAccuracy, @"They should all equal each other");
			
			XCTAssertTrue(fabsf(nodeA.position.x - desiredXCoord) < kAccuracy, @"They should all equal each desiredXCoord: XPos:%0.2f DesiredPos:%0.2f elapsed:%0.2f", nodeA.position.x,desiredXCoord, elapsed);
			
		}

	}
	
}



@end
