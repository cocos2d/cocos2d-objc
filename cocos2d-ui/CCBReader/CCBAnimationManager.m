/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
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
 */

#import "CCBAnimationManager.h"
#import "CCBKeyframe.h"
#import "CCBSequence.h"
#import "CCBSequenceProperty.h"
#import "CCBReader.h"
#import "CCBKeyframe.h"
#import "OALSimpleAudio.h"
#import <objc/runtime.h>

#import "CCDirector_Private.h"
#import "CCBReader_Private.h"
#import "CCActionManager.h"

// Unique Manager ID
static NSInteger ccbAnimationManagerID = 0;

@implementation CCBAnimationManager

- (id)init {
    self = [super init];
    if (!self) return NULL;
    
    _animationManagerId = ccbAnimationManagerID;
    ccbAnimationManagerID++;
    
    _sequences = [[NSMutableArray alloc] init];
    _nodeSequences = [[NSMutableDictionary alloc] init];
    _baseValues = [[NSMutableDictionary alloc] init];
    
    // Scheduler
    _scheduler = [[CCDirector sharedDirector] scheduler];
    [_scheduler scheduleTarget:self];
    [_scheduler setPaused:NO target:self];
    
    // Current Sequence Actions
    _currentActions = [[NSMutableArray alloc] init];
    _playbackSpeed  = 1.0f;
    _paused         = NO;
    
    _lastSequence   = nil;
    _fixedTimestep  = NO;
    _loop           = NO;
    
    return self;
}

- (NSInteger)priority {
	return 0;
}

- (CGSize)containerSize:(CCNode*)node {
    if (node) {
        return node.contentSize;
    } else {
        return _rootContainerSize;
    }
}

- (void)addNode:(CCNode*)node andSequences:(NSDictionary*)seq {
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    [_nodeSequences setObject:seq forKey:nodePtr];
}

- (id)seqForNode:(CCNode*)node {
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    return [_nodeSequences objectForKey:nodePtr];
}

- (void)moveAnimationsFromNode:(CCNode*)fromNode toNode:(CCNode*)toNode {
    NSValue* fromNodePtr = [NSValue valueWithPointer:(__bridge const void *)(fromNode)];
    NSValue* toNodePtr = [NSValue valueWithPointer:(__bridge const void *)(toNode)];
    
    // Move base values
    id baseValue = [_baseValues objectForKey:fromNodePtr];
    if (baseValue) {
        [_baseValues setObject:baseValue forKey:toNodePtr];
        [_baseValues removeObjectForKey:fromNodePtr];
    }
    
    // Move keyframes
    NSDictionary* seqs = [_nodeSequences objectForKey:fromNodePtr];
    if (seqs) {
        [_nodeSequences setObject:seqs forKey:toNodePtr];
        [_nodeSequences removeObjectForKey:fromNodePtr];
    }
}

- (void)setBaseValue:(id)value forNode:(CCNode*)node propertyName:(NSString*)propName {
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    
    NSMutableDictionary* props = [_baseValues objectForKey:nodePtr];
    if (!props) {
        props = [NSMutableDictionary dictionary];
        [_baseValues setObject:props forKey:nodePtr];
    }
    
    [props setObject:value forKey:propName];
}

- (id)baseValueForNode:(CCNode*) node propertyName:(NSString*) propName {
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    
    NSMutableDictionary* props = [_baseValues objectForKey:nodePtr];
    return [props objectForKey:propName];
}

- (int)sequenceIdForSequenceNamed:(NSString*)name {
    for (CCBSequence* seq in _sequences) {
        if ([seq.name isEqualToString:name]) {
            return seq.sequenceId;
        }
    }
    
    return -1;
}

- (CCBSequence*)sequenceFromSequenceId:(int)seqId {
    for (CCBSequence* seq in _sequences)
    {
        if (seq.sequenceId == seqId) return seq;
    }
    return NULL;
}

- (CCActionInterval*)actionFromKeyframe0:(CCBKeyframe*)kf0 andKeyframe1:(CCBKeyframe*)kf1 propertyName:(NSString*)name node:(CCNode*)node {
    float duration = kf1.time - kf0.time;
    
    if ([name isEqualToString:@"rotation"]) {
        return [CCActionRotateTo actionWithDuration:duration angle:[kf1.value floatValue] simple:YES];
    } else if ([name isEqualToString:@"position"]) {
        id value = kf1.value;
        
        // Get relative position
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];

        return [CCActionMoveTo actionWithDuration:duration position:ccp(x,y)];
    } else if ([name isEqualToString:@"scale"]) {
        id value = kf1.value;
        
        // Get relative scale
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        return [CCActionScaleTo actionWithDuration:duration scaleX:x scaleY:y];
    } else if ([name isEqualToString:@"skew"]) {
        id value = kf1.value;
        
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        return [CCActionSkewTo actionWithDuration:duration skewX:x skewY:y];
    } else if ([name isEqualToString:@"rotationalSkewX"]) {
        return [CCActionRotateTo actionWithDuration:duration angleX:[kf1.value floatValue]];
    } else if ([name isEqualToString:@"rotationalSkewY"]) {
        return [CCActionRotateTo actionWithDuration:duration angleY:[kf1.value floatValue]];
    } else if ([name isEqualToString:@"opacity"]) {
        return [CCActionFadeTo actionWithDuration:duration opacity:[kf1.value intValue]];
    } else if ([name isEqualToString:@"color"]) {
        CCColor* color = kf1.value;
        return [CCActionTintTo actionWithDuration:duration color:color];
    } else if ([name isEqualToString:@"visible"]) {
        if ([kf1.value boolValue]) {
            return [CCActionSequence actionOne:[CCActionDelay actionWithDuration:duration] two:[CCActionShow action]];
        } else {
            return [CCActionSequence actionOne:[CCActionDelay actionWithDuration:duration] two:[CCActionHide action]];
        }
    } else if ([name isEqualToString:@"spriteFrame"]) {
        return [CCActionSequence actionOne:[CCActionDelay actionWithDuration:duration] two:[CCActionSpriteFrame actionWithSpriteFrame:kf1.value]];
    } else {
        CCLOG(@"CCBReader: Failed to create animation for property: %@", name);
    }
              
    return NULL;
}

- (void)setAnimatedProperty:(NSString*)name forNode:(CCNode*)node toValue:(id)value tweenDuration:(float) tweenDuration {
    if (tweenDuration > 0) {
        // Create a fake keyframe to generate the action from
        CCBKeyframe* kf1 = [[CCBKeyframe alloc] init];
        kf1.value = value;
        kf1.time = tweenDuration;
        kf1.easingType = kCCBKeyframeEasingLinear;
        
        CCActionInterval* tweenAction = [self actionFromKeyframe0:NULL andKeyframe1:kf1 propertyName:name node:node];
        tweenAction.tag = (int)_animationManagerId;
        [tweenAction startWithTarget:node];
        [_currentActions addObject:tweenAction];
    } else {
    
        if ([name isEqualToString:@"position"]) {
            
            // Get relative position
            float x = [[value objectAtIndex:0] floatValue];
            float y = [[value objectAtIndex:1] floatValue];
#ifdef __CC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGPoint:ccp(x,y)] forKey:name];
#elif defined (__CC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithPoint:ccp(x,y)] forKey:name];
#endif
        } else if ([name isEqualToString:@"scale"]) {
            // Get relative scale
            float x = [[value objectAtIndex:0] floatValue];
            float y = [[value objectAtIndex:1] floatValue];
            
            [node setValue:[NSNumber numberWithFloat:x] forKey:[name stringByAppendingString:@"X"]];
            [node setValue:[NSNumber numberWithFloat:y] forKey:[name stringByAppendingString:@"Y"]];
        } else if ([name isEqualToString:@"skew"]) {
            node.skewX = [[value objectAtIndex:0] floatValue];
            node.skewY = [[value objectAtIndex:1] floatValue];
        } else if ([name isEqualToString:@"spriteFrame"]) {
            [(CCSprite*)node setSpriteFrame:value];
        } else {
            [node setValue:value forKey:name];
        }
    }  
}

- (void)setKeyFrameForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp tweenDuration:(float)tweenDuration keyFrame:(int)kf {
    NSArray* keyframes = [seqProp keyframes];
    
    if ([keyframes count] == 0) {
        // No Animation, Set Base Value
        id baseValue = [self baseValueForNode:node propertyName:seqProp.name];
        NSAssert1(baseValue, @"No baseValue found for property (%@)", seqProp.name);
        [self setAnimatedProperty:seqProp.name forNode:node toValue:baseValue tweenDuration:tweenDuration];
    } else {
        // Use Specified KeyFrame
        CCBKeyframe* keyframe = [keyframes objectAtIndex:kf];
        [self setAnimatedProperty:seqProp.name forNode:node toValue:keyframe.value tweenDuration:tweenDuration];
    }
}

- (CCActionInterval*)easeAction:(CCActionInterval*) action easingType:(int)easingType easingOpt:(float) easingOpt
{
    if ([action isKindOfClass:[CCActionSequence class]]) return action;
    
    if (easingType == kCCBKeyframeEasingLinear)
    {
        return action;
    }
    else if (easingType == kCCBKeyframeEasingInstant)
    {
        return [CCActionEaseInstant actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingCubicIn)
    {
        return [CCActionEaseIn actionWithAction:action rate:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingCubicOut)
    {
        return [CCActionEaseOut actionWithAction:action rate:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingCubicInOut)
    {
        return [CCActionEaseInOut actionWithAction:action rate:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingBackIn)
    {
        return [CCActionEaseBackIn actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBackOut)
    {
        return [CCActionEaseBackOut actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBackInOut)
    {
        return [CCActionEaseBackInOut actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBounceIn)
    {
        return [CCActionEaseBounceIn actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBounceOut)
    {
        return [CCActionEaseBounceOut actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBounceInOut)
    {
        return [CCActionEaseBounceInOut actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingElasticIn)
    {
        return [CCActionEaseElasticIn actionWithAction:action period:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingElasticOut)
    {
        return [CCActionEaseElasticOut actionWithAction:action period:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingElasticInOut)
    {
        return [CCActionEaseElasticInOut actionWithAction:action period:easingOpt];
    }
    else
    {
        NSLog(@"CCBReader: Unkown easing type %d", easingType);
        return action;
    }
}

- (void)runActionsForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp tweenDuration:(float)tweenDuration startKeyFrame:(int)startFrame {
    
    // Grab Key Frames / Count
    NSArray* keyframes = [seqProp keyframes];
    int numKeyframes = (int)keyframes.count;
    
    // Nothing to do - No Keyframes
    if(numKeyframes<1) return;
    
    // Action Sequence Builder
        NSMutableArray* actions = [NSMutableArray array];
    int endFrame            = startFrame+1;
            
    if(endFrame==numKeyframes || endFrame<0)
        return;
    
    // First Frame
    CCBKeyframe* kf0 = [keyframes objectAtIndex:startFrame];
    
    // Initial Tween Required
    if(startFrame==0) {
        float timeFirst = kf0.time + tweenDuration;
    
        // Handle Tween
        if (timeFirst > 0) {
            [actions addObject:[CCActionDelay actionWithDuration:timeFirst]];
        }
    }
        
    // Build Actions
    CCActionSequence* actionSeq = [self createActionForNode:node sequenceProperty:seqProp beginKeyFrame:startFrame endKeyFrame:endFrame];
    if(actionSeq) {
        [actions addObject:actionSeq];
    }
            
    // Next Sequence
    CCActionCallBlock* nextKeyFrameBlock = [CCActionCallBlock actionWithBlock:^{
        [self runActionsForNode:node sequenceProperty:seqProp tweenDuration:0 startKeyFrame:endFrame];
    }];
                
    [actions addObject:nextKeyFrameBlock];
        
    CCActionSequence* seq = [CCActionSequence actionWithArray:actions];
    seq.tag = _animationManagerId;
    [seq startWithTarget:node];
    if(kf0.time>0 || _loop) { // Ensure Sync
        [seq step:0];
        [seq step:_runningSequence.time-kf0.time];
    }
    [_currentActions addObject:seq];
}

- (id)actionForCallbackChannel:(CCBSequenceProperty*) channel {
    float lastKeyframeTime = 0;
    
    NSMutableArray* actions = [NSMutableArray array];
    
    for (CCBKeyframe* keyframe in channel.keyframes) {
        
        float timeSinceLastKeyframe = keyframe.time - lastKeyframeTime;
        lastKeyframeTime = keyframe.time;
        if (timeSinceLastKeyframe > 0) {
            [actions addObject:[CCActionDelay actionWithDuration:timeSinceLastKeyframe]];
        }
        
        NSString* selectorName = [keyframe.value objectAtIndex:0];
        int selectorTarget = [[keyframe.value objectAtIndex:1] intValue];
        
        // Callback through obj-c
        id target = NULL;
        if (selectorTarget == kCCBTargetTypeDocumentRoot) target = self.rootNode;
        else if (selectorTarget == kCCBTargetTypeOwner) target = _owner;
        
        SEL selector = NSSelectorFromString(selectorName);
        
        if (target && selector) {
            [actions addObject:[CCActionCallFunc actionWithTarget:target selector:selector]];
        }
    }
    
    if (!actions.count) return NULL;
    
    return [CCActionSequence actionWithArray:actions];
}

- (id)actionForSoundChannel:(CCBSequenceProperty*) channel {
    
    float lastKeyframeTime = 0;
    
    NSMutableArray* actions = [NSMutableArray array];
    
    for (CCBKeyframe* keyframe in channel.keyframes) {
        
        float timeSinceLastKeyframe = keyframe.time - lastKeyframeTime;
        lastKeyframeTime = keyframe.time;
        if (timeSinceLastKeyframe > 0) {
            [actions addObject:[CCActionDelay actionWithDuration:timeSinceLastKeyframe]];
        }
        
        NSString* soundFile = [keyframe.value objectAtIndex:0];
        float pitch = [[keyframe.value objectAtIndex:1] floatValue];
        float pan = [[keyframe.value objectAtIndex:2] floatValue];
        float gain = [[keyframe.value objectAtIndex:3] floatValue];
        
        [actions addObject:[CCActionSoundEffect actionWithSoundFile:soundFile pitch:pitch pan:pan gain:gain]];
    }
    
    if (!actions.count) return NULL;
    
    return [CCActionSequence actionWithArray:actions];
}

- (void)runAnimationsForSequenceId:(int)seqId tweenDuration:(float) tweenDuration {
    
    NSAssert(seqId != -1, @"Sequence id %d couldn't be found",seqId);
    
    _paused = YES;
    [self clearAllActions];
    
    // Contains all Sequence Propertys / Keyframe
    for (NSValue* nodePtr in _nodeSequences) {
        
        CCNode* node = [nodePtr pointerValue];
        
        NSDictionary* seqs = [_nodeSequences objectForKey:nodePtr];
        NSDictionary* seqNodeProps = [seqs objectForKey:[NSNumber numberWithInt:seqId]];
        
        NSMutableSet* seqNodePropNames = [NSMutableSet set];
        
        if(_lastSequence.sequenceId!=seqId) {
            _loop = NO;
            
            // Reset the nodes that may have been changed by other timelines
            NSDictionary* nodeBaseValues = [_baseValues objectForKey:nodePtr];
            for (NSString* propName in nodeBaseValues) {
                
                if (![seqNodePropNames containsObject:propName]) {
                    
                    id value = [nodeBaseValues objectForKey:propName];
                    
                    if (value) {
                        [self setAnimatedProperty:propName forNode:node toValue:value tweenDuration:tweenDuration];
                    }
                }
            }
        }
        
        // Reset nodes that have sequence node properties, build first keyframe action sequence.
        for (NSString* propName in seqNodeProps) {
            CCBSequenceProperty* seqProp = [seqNodeProps objectForKey:propName];
            [seqNodePropNames addObject:propName];
            
            // Reset Node State to First KeyFrame
            [self setKeyFrameForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration keyFrame:0];
            
            // Build First Key Frame Sequence
            [self runActionsForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration startKeyFrame:0];
        }
        
    }
    
    [self addSequenceCallBacks:seqId tweenDuration:tweenDuration startTime:0];
    
    // Set the running scene
    _runningSequence      = [self sequenceFromSequenceId:seqId];
    _runningSequence.time = 0.0f;
    
    _paused = NO;
}

- (void)runAnimationsForSequenceNamed:(NSString*)name tweenDuration:(float)tweenDuration {
    int seqId = [self sequenceIdForSequenceNamed:name];
    [self runAnimationsForSequenceId:seqId tweenDuration:tweenDuration];
}

- (void)runAnimationsForSequenceNamed:(NSString*)name {
    [self runAnimationsForSequenceNamed:name tweenDuration:0];
}

- (void)addSequenceCallBacks:(int)seqId tweenDuration:(float)tweenDuration startTime:(float)time {
    
    // End of Sequence Callback
    CCBSequence* seq = [self sequenceFromSequenceId:seqId];
    
    CCActionSequence* completeAction = [CCActionSequence
                                        actionOne:[CCActionDelay actionWithDuration:seq.duration+tweenDuration-time]
                                        two:[CCActionCallFunc actionWithTarget:self selector:@selector(sequenceCompleted)]];
    completeAction.tag = (int)_animationManagerId;
    [completeAction startWithTarget:self.rootNode];
    [_currentActions addObject:completeAction];
    
    // Playback callbacks and sounds
    if (seq.callbackChannel) {
        // Build sound actions for channel
        CCAction* action = [self actionForCallbackChannel:seq.callbackChannel];
        if (action) {
            action.tag = (int)_animationManagerId;
            [action startWithTarget:self.rootNode];
            [_currentActions addObject:action];
        }
    }
    
    if (seq.soundChannel) {
        // Build sound actions for channel
        CCAction* action = [self actionForSoundChannel:seq.soundChannel];
        if (action) {
            action.tag = (int)_animationManagerId;
            [action startWithTarget:self.rootNode];
            [_currentActions addObject:action];
        }
    }

}

- (void)sequenceCompleted {
    
    // Save last completed sequence
    if (_lastCompletedSequenceName != _runningSequence.name) {
        _lastCompletedSequenceName = [_runningSequence.name copy];
        _lastSequence              = _runningSequence;
    }
    
    // Play next sequence
    int nextSeqId = _runningSequence.chainedSequenceId;
    
    // Repeat Same Sequence
    if(nextSeqId!=-1&& nextSeqId==_runningSequence.sequenceId) {
        _loop = YES;
    }
    
    _runningSequence = NULL;
    
    // Callbacks
    [_delegate completedAnimationSequenceNamed:_lastCompletedSequenceName];
    if (block) block(self);
    
    // Run next sequence if callbacks did not start a new sequence
    if (_runningSequence == NULL && nextSeqId != -1) {
        [self runAnimationsForSequenceId:nextSeqId tweenDuration:0];
    }
}

- (NSString*)runningSequenceName {
    return _runningSequence.name;
}

- (void)setCompletedAnimationCallbackBlock:(void(^)(id sender))b {
    block = [b copy];
}

- (void)cleanup {
    [_scheduler setPaused:YES target:self];
	[_scheduler unscheduleTarget:self];
    [self clearAllActions];
}

- (void)dealloc {
    _rootNode = NULL;
}

- (void)debug {
    CCLOG(@"baseValues: %@", _baseValues);
    CCLOG(@"nodeSequences: %@", _nodeSequences);
}

- (void)setPlaybackSpeed:(float)playbackSpeed  {
    
    // Backward Motion (Backwards)
    if(_playbackSpeed>0 && playbackSpeed<0 && _runningSequence) {
        [self timeSeekStaticForSequenceId:_runningSequence.sequenceId time:_runningSequence.time];
    }
    
    // Forward Motion
    if(_playbackSpeed<0 && playbackSpeed>0 && _runningSequence) {
        [self timeSeekForSequenceId:_runningSequence.sequenceId time:_runningSequence.time];
    }
    
    _playbackSpeed = playbackSpeed;
}


- (void)timeSeekStaticForSequenceId:(int)seqId time:(float)time {
    NSAssert(seqId != -1, @"Sequence id %d couldn't be found",seqId);
    
    // Reverse Loop Hack
    if(_playbackSpeed<0 && time<0 && _runningSequence.chainedSequenceId==_runningSequence.sequenceId) {
        time = _runningSequence.duration;
    }
    
    [self clearAllActions];
    
    // Contains all Sequence Propertys / Keyframe
    for (NSValue* nodePtr in _nodeSequences) {
        CCNode* node = [nodePtr pointerValue];
        
        NSDictionary* seqs = [_nodeSequences objectForKey:nodePtr];
        NSDictionary* seqNodeProps = [seqs objectForKey:[NSNumber numberWithInt:seqId]];
        
        // Reset Nodes, Create Actions
        NSMutableSet* seqNodePropNames = [NSMutableSet set];
        
        // Reset the nodes that may have been changed by other timelines
        NSDictionary* nodeBaseValues = [_baseValues objectForKey:nodePtr];
        for (NSString* propName in nodeBaseValues) {
            if (![seqNodePropNames containsObject:propName]) {
                id value = [nodeBaseValues objectForKey:propName];
                if (value) {
                    [self setAnimatedProperty:propName forNode:node toValue:value tweenDuration:0];
                }
            }
        }
        
        for (NSString* propName in seqNodeProps) {
            CCBSequenceProperty* seqProp = [seqNodeProps objectForKey:propName];
            NSMutableArray* keyFrames    = [self findFrames:time sequenceProperty:seqProp];
            
            // No KeyFrames Found
            if([keyFrames count]==0) {
                continue;
            }
            
            // Last Sequence KeyFrame Ended Before Seek Time / Set State
            if([keyFrames count]==1) {
                [self setKeyFrameForNode:node sequenceProperty:seqProp tweenDuration:0 keyFrame:[[keyFrames objectAtIndex:0] intValue]];
                continue;
            }
            
            // Set Initial State First Key Frame
            [self setKeyFrameForNode:node sequenceProperty:seqProp tweenDuration:0 keyFrame:[[keyFrames objectAtIndex:0] intValue]];
            
            CCBKeyframe* currentKeyFrame = [seqProp.keyframes objectAtIndex:[[keyFrames objectAtIndex:0] unsignedIntegerValue]];
            
            float timeFoward = time - currentKeyFrame.time;
            
            // Create Action Sequence
            CCActionSequence* action = [self createActionForNode:node
                                                sequenceProperty:seqProp
                                                   beginKeyFrame:[[keyFrames objectAtIndex:0] intValue]
                                                     endKeyFrame:[[keyFrames objectAtIndex:1] intValue]];
            
            // Fast forward to time point
            [action startWithTarget:node];
            [action step:0]; // First Tick
            [action step:timeFoward];
            
        }
        
    }
    
    _runningSequence      = [self sequenceFromSequenceId:seqId];
    _runningSequence.time = time;
}


- (void)timeSeekForSequenceNamed:(NSString*)name time:(float)time {
    int seqId = [self sequenceIdForSequenceNamed:name];
    [self timeSeekForSequenceId:seqId time:time];
}

- (void) timeSeekForSequenceId:(int)seqId time:(float)time {
    NSAssert(seqId != -1, @"Sequence id %d couldn't be found",seqId);

    [self clearAllActions];
    // Contains all Sequence Propertys / Keyframe
    for (NSValue* nodePtr in _nodeSequences) {
        CCNode* node = [nodePtr pointerValue];
        
        NSDictionary* seqs = [_nodeSequences objectForKey:nodePtr];
        NSDictionary* seqNodeProps = [seqs objectForKey:[NSNumber numberWithInt:seqId]];
        
        // Reset Nodes, Create Actions
        NSMutableSet* seqNodePropNames = [NSMutableSet set];
        
        // Reset the nodes that may have been changed by other timelines
        NSDictionary* nodeBaseValues = [_baseValues objectForKey:nodePtr];
        for (NSString* propName in nodeBaseValues) {
            if (![seqNodePropNames containsObject:propName]) {
                id value = [nodeBaseValues objectForKey:propName];
                if (value) {
                    [self setAnimatedProperty:propName forNode:node toValue:value tweenDuration:0];
                }
            }
        }

        for (NSString* propName in seqNodeProps) {
            CCBSequenceProperty* seqProp = [seqNodeProps objectForKey:propName];
            NSMutableArray* keyFrames    = [self findFrames:time sequenceProperty:seqProp];
            
            // No KeyFrames Found
            if([keyFrames count]==0) {
                continue;
            }
            
            // Last Sequence KeyFrame Ended Before Seek Time / Set State
            if([keyFrames count]==1) {
                [self setKeyFrameForNode:node sequenceProperty:seqProp tweenDuration:0 keyFrame:[[keyFrames objectAtIndex:0] intValue]];
                continue;
            }
            
            // Set Initial State First Key Frame
            [self setKeyFrameForNode:node sequenceProperty:seqProp tweenDuration:0 keyFrame:[[keyFrames objectAtIndex:0] intValue]];
            
            CCBKeyframe* currentKeyFrame = [seqProp.keyframes objectAtIndex:[[keyFrames objectAtIndex:0] unsignedIntegerValue]];
            
            float timeFoward = time - currentKeyFrame.time;
            
            // Create Action Sequence
            CCActionSequence* action = [self createActionForNode:node
                                                sequenceProperty:seqProp
                                                   beginKeyFrame:[[keyFrames objectAtIndex:0] intValue]
                                                     endKeyFrame:[[keyFrames objectAtIndex:1] intValue]];
            
            
            // Next Sequence
            CCActionCallBlock* nextKeyFrameBlock = [CCActionCallBlock actionWithBlock:^{
                [self runActionsForNode:node sequenceProperty:seqProp tweenDuration:0 startKeyFrame:[[keyFrames objectAtIndex:1] intValue]];
            }];
            
            
            CCActionSequence* animSequence = [CCActionSequence actions:action, nextKeyFrameBlock,nil];
    
            // Fast forward to time point
            [animSequence setTag:_animationManagerId];
            [animSequence startWithTarget:node];
            [animSequence step:0]; // First Tick
            [animSequence step:timeFoward];
            [_currentActions addObject:animSequence];
    
        }

    }

    [self addSequenceCallBacks:seqId tweenDuration:0 startTime:time];
    
    _runningSequence      = [self sequenceFromSequenceId:seqId];
    _runningSequence.time = time;
}

- (NSMutableArray*)findFrames:(float)time sequenceProperty:(CCBSequenceProperty*) seqProp{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    CCBKeyframe* startKeyFrame = [seqProp.keyframes objectAtIndex:0];
    CCBKeyframe* endKeyFrame   = [seqProp.keyframes objectAtIndex:0];
    
    NSUInteger frameCount = [seqProp.keyframes count];
    
    // Find KeyFrames
    int i;
    for (i = 0; i < frameCount; i++) {
        CCBKeyframe* currentKey = [seqProp.keyframes objectAtIndex:i];
        
        if (currentKey.time>time) {
            endKeyFrame = currentKey;
            // Add KeyFrames
            [result addObject:[NSNumber numberWithUnsignedInteger:[seqProp.keyframes indexOfObject:startKeyFrame]]];
            [result addObject:[NSNumber numberWithUnsignedInteger:[seqProp.keyframes indexOfObject:endKeyFrame]]];
            break;
        }
        
        startKeyFrame = [seqProp.keyframes objectAtIndex:i];
    }
    
    // No Frames
    if([result count]==0) {
        [result addObject:[NSNumber numberWithInteger:(i-1)]];
    }
    
    return result;
}

- (CCActionSequence*)createActionForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp beginKeyFrame:(int)beginKeyFrame endKeyFrame:(int)endKeyFrame
{
    NSArray* keyframes = [seqProp keyframes];
    
    CCBKeyframe* startKF = [keyframes objectAtIndex:beginKeyFrame];
    CCBKeyframe* endKF   = [keyframes objectAtIndex:endKeyFrame];
    
    CCActionSequence* seq = nil;
    
    // Check Keyframe Cache
    if(endKF.frameActions) {
        seq = [endKF.frameActions copy];
    } else {
        
        // Build Animation Actions
        NSMutableArray* actions = [[NSMutableArray alloc] init];
        
        CCActionInterval* action = [self actionFromKeyframe0:startKF andKeyframe1:endKF propertyName:seqProp.name node:node];
        
        if (action) {
            // Apply Easing
            action = [self easeAction:action easingType:startKF.easingType easingOpt:startKF.easingOpt];
            [actions addObject:action];
            
            // Cache
            seq = [CCActionSequence actionWithArray:actions];
            seq.tag = _animationManagerId;
            endKF.frameActions = [seq copy];
        }
    }
    
    return seq;
}

-(void)fixedUpdate:(CCTime)delta {
    
	if(self.fixedTimestep) {
		[self updateInternal:delta];
	}
}

- (void)update:(CCTime)delta {
    
	if(!self.fixedTimestep) {
		[self updateInternal:delta];
	}
}

- (void)updateInternal:(CCTime)delta {
    
    if(_paused) return;
    
    float step = delta*_playbackSpeed;
    
    if(_playbackSpeed<0) {
        [self timeSeekStaticForSequenceId:_runningSequence.sequenceId time:_runningSequence.time+step];
        return;
    }
    
    if(_currentActions.count==0) return;
    
    CCAction *action;
    NSArray *actionsCopy = [_currentActions copy];
    
    for(action in actionsCopy) {
        [action step:step];
        
        if([action isDone]) {
            [_currentActions removeObject:action];
        }
    }
    
    _runningSequence.time+=step;
}

- (void)clearAllActions {
    
    if(!_currentActions.count) return;
    
    for(CCAction *action in _currentActions) {
        [action stop];
    }
    
    [_currentActions removeAllObjects];
}

#pragma mark Simple Sequence Builder

- (void)addKeyFramesForSequenceNamed:(NSString*)name propertyType:(CCBSequencePropertyType)propertyType frameArray:(NSArray*)frameArray node:(CCNode *)node loop:(BOOL)loop {
    
    int seqId = (int)[self.sequences count];
    
    // Create New Sequence
    CCBSequence* sequence = [[CCBSequence alloc] init];
    [sequence setName:name];
    [sequence setSequenceId:seqId];
    [self.sequences addObject:sequence];
    
    // Repeat Sequence (Loop)
    if(loop) {
        [sequence setChainedSequenceId:seqId];
    }
    
    NSString *propertyName = [CCBSequenceProperty getPropertyNameFromTypeId:propertyType];
    NSAssert(propertyName != nil, @"Property type %d couldn't be found",(int)propertyType);
    
    // Create Sequence Property
    CCBSequenceProperty* sequenceProperty = [[CCBSequenceProperty alloc] init];
    [sequenceProperty setName:propertyName];
    [sequenceProperty setType:propertyType];
    
    // Keyframe total time
    float duration = 0.0f;
    
    for(NSDictionary* frameDict in frameArray) {
        
        // Create KeyFrame
        CCBKeyframe* newFrame = [[CCBKeyframe alloc] init];
        [newFrame setTime:[[frameDict valueForKey:@"time"] floatValue]];
        [newFrame setValue:[CCSpriteFrame frameWithImageNamed:[frameDict objectForKey:@"value"]]];
        
        [sequenceProperty.keyframes addObject:newFrame];
        duration=newFrame.time;
    }
    
    // Set Sequence Duration
    sequence.duration = duration;
    
    NSMutableDictionary* seqs         = [NSMutableDictionary dictionary];
    NSMutableDictionary* seqNodeProps = [NSMutableDictionary dictionary];

    [seqNodeProps setObject:sequenceProperty forKey:sequenceProperty.name];
    [seqs setObject:seqNodeProps forKey:[NSNumber numberWithInt:seqId]];
    
    NSMutableDictionary* seqNode      = [self seqForNode:node];
    if(seqNode) {
        [seqNode setObject:seqNodeProps forKey:[NSNumber numberWithInt:seqId]];
    } else {
        [self addNode:node andSequences:seqs];
    }
    
}

@end
