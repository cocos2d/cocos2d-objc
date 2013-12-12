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
#import "CCBSequence.h"
#import "CCBSequenceProperty.h"
#import "CCBReader.h"
#import "CCBKeyframe.h"
#import "OALSimpleAudio.h"
#import <objc/runtime.h>

#import "CCDirector_Private.h"
#import "CCBReader_Private.h"
#import "CCActionManager.h"

static NSInteger ccbAnimationManagerID = 0;

@implementation CCBAnimationManager

@synthesize sequences;
@synthesize autoPlaySequenceId;
@synthesize rootNode;
@synthesize rootContainerSize;
@synthesize owner;
@synthesize delegate;
@synthesize lastCompletedSequenceName;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    animationManagerId = ccbAnimationManagerID;
    ccbAnimationManagerID++;
    
    sequences = [[NSMutableArray alloc] init];
    nodeSequences = [[NSMutableDictionary alloc] init];
    baseValues = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (CGSize) containerSize:(CCNode*)node
{
    if (node) return node.contentSize;
    else return rootContainerSize;
}

- (void) addNode:(CCNode*)node andSequences:(NSDictionary*)seq
{
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    [nodeSequences setObject:seq forKey:nodePtr];
}

- (void) moveAnimationsFromNode:(CCNode*)fromNode toNode:(CCNode*)toNode
{
    NSValue* fromNodePtr = [NSValue valueWithPointer:(__bridge const void *)(fromNode)];
    NSValue* toNodePtr = [NSValue valueWithPointer:(__bridge const void *)(toNode)];
    
    // Move base values
    id baseValue = [baseValues objectForKey:fromNodePtr];
    if (baseValue)
    {
        [baseValues setObject:baseValue forKey:toNodePtr];
        [baseValues removeObjectForKey:fromNodePtr];
    }
    
    // Move keyframes
    NSDictionary* seqs = [nodeSequences objectForKey:fromNodePtr];
    if (seqs)
    {
        [nodeSequences setObject:seqs forKey:toNodePtr];
        [nodeSequences removeObjectForKey:fromNodePtr];
    }
}

- (void) setBaseValue:(id)value forNode:(CCNode*)node propertyName:(NSString*)propName
{
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    
    NSMutableDictionary* props = [baseValues objectForKey:nodePtr];
    if (!props)
    {
        props = [NSMutableDictionary dictionary];
        [baseValues setObject:props forKey:nodePtr];
    }
    
    [props setObject:value forKey:propName];
}

- (id) baseValueForNode:(CCNode*) node propertyName:(NSString*) propName
{
    NSValue* nodePtr = [NSValue valueWithPointer:(__bridge const void *)(node)];
    
    NSMutableDictionary* props = [baseValues objectForKey:nodePtr];
    return [props objectForKey:propName];
}

- (int) sequenceIdForSequenceNamed:(NSString*)name
{
    for (CCBSequence* seq in sequences)
    {
        if ([seq.name isEqualToString:name])
        {
            return seq.sequenceId;
        }
    }
    return -1;
}

- (CCBSequence*) sequenceFromSequenceId:(int)seqId
{
    for (CCBSequence* seq in sequences)
    {
        if (seq.sequenceId == seqId) return seq;
    }
    return NULL;
}

- (CCActionInterval*) actionFromKeyframe0:(CCBKeyframe*)kf0 andKeyframe1:(CCBKeyframe*)kf1 propertyName:(NSString*)name node:(CCNode*)node
{
    float duration = kf1.time - kf0.time;
    
    if ([name isEqualToString:@"rotation"])
    {
        return [CCBRotateTo actionWithDuration:duration angle:[kf1.value floatValue]];
    }
    else if ([name isEqualToString:@"rotationX"])
    {
        return [CCBRotateXTo actionWithDuration:duration angle:[kf1.value floatValue]];
    }
    else if ([name isEqualToString:@"rotationY"])
    {
        return [CCBRotateYTo actionWithDuration:duration angle:[kf1.value floatValue]];
    }
    else if ([name isEqualToString:@"opacity"])
    {
        return [CCActionFadeTo actionWithDuration:duration opacity:[kf1.value intValue]];
    }
    else if ([name isEqualToString:@"color"])
    {
        CCColor* color = kf1.value;
        return [CCActionTintTo actionWithDuration:duration color:color];
    }
    else if ([name isEqualToString:@"visible"])
    {
        if ([kf1.value boolValue])
        {
            return [CCActionSequence actionOne:[CCActionDelay actionWithDuration:duration] two:[CCActionShow action]];
        }
        else
        {
            return [CCActionSequence actionOne:[CCActionDelay actionWithDuration:duration] two:[CCActionHide action]];
        }
    }
    else if ([name isEqualToString:@"spriteFrame"])
    {
        return [CCActionSequence actionOne:[CCActionDelay actionWithDuration:duration] two:[CCBSetSpriteFrame actionWithSpriteFrame:kf1.value]];
    }
    else if ([name isEqualToString:@"position"])
    {
        // Get position type
        //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
        
        id value = kf1.value;
        
        // Get relative position
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        //CGSize containerSize = [self containerSize:node.parent];
        
        //CGPoint absPos = [node absolutePositionFromRelative:ccp(x,y) type:type parentSize:containerSize propertyName:name];
        
        return [CCActionMoveTo actionWithDuration:duration position:ccp(x,y)];
    }
    else if ([name isEqualToString:@"scale"])
    {
        // Get position type
        //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
        
        id value = kf1.value;
        
        // Get relative scale
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        /*
        if (type == kCCBScaleTypeMultiplyResolution)
        {
            float resolutionScale = [node resolutionScale];
            x *= resolutionScale;
            y *= resolutionScale;
        }*/
        
        return [CCActionScaleTo actionWithDuration:duration scaleX:x scaleY:y];
    }
    else if ([name isEqualToString:@"skew"])
    {
        id value = kf1.value;
        
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        return [CCActionSkewTo actionWithDuration:duration skewX:x skewY:y];
    }
    else
    {
        NSLog(@"CCBReader: Failed to create animation for property: %@", name);
    }
    return NULL;
}

- (void) setAnimatedProperty:(NSString*)name forNode:(CCNode*)node toValue:(id)value tweenDuration:(float) tweenDuration
{
    if (tweenDuration > 0)
    {
        // Create a fake keyframe to generate the action from
        CCBKeyframe* kf1 = [[CCBKeyframe alloc] init];
        kf1.value = value;
        kf1.time = tweenDuration;
        kf1.easingType = kCCBKeyframeEasingLinear;
        
        // Animate
        CCActionInterval* tweenAction = [self actionFromKeyframe0:NULL andKeyframe1:kf1 propertyName:name node:node];
        [node runAction:tweenAction];
    }
    else
    {
        // Just set the value
    
        if ([name isEqualToString:@"position"])
        {
            // Get position type
            //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
            
            // Get relative position
            float x = [[value objectAtIndex:0] floatValue];
            float y = [[value objectAtIndex:1] floatValue];
#ifdef __CC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGPoint:ccp(x,y)] forKey:name];
#elif defined (__CC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithPoint:ccp(x,y)] forKey:name];
#endif
            
            //[node setRelativePosition:ccp(x,y) type:type parentSize:[self containerSize:node.parent] propertyName:name];
        }
        else if ([name isEqualToString:@"scale"])
        {
            // Get scale type
            //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
            
            // Get relative scale
            float x = [[value objectAtIndex:0] floatValue];
            float y = [[value objectAtIndex:1] floatValue];
            
            [node setValue:[NSNumber numberWithFloat:x] forKey:[name stringByAppendingString:@"X"]];
            [node setValue:[NSNumber numberWithFloat:y] forKey:[name stringByAppendingString:@"Y"]];
            
            //[node setRelativeScaleX:x Y:y type:type propertyName:name];
        }
        else if ([name isEqualToString:@"skew"])
        {
            node.skewX = [[value objectAtIndex:0] floatValue];
            node.skewY = [[value objectAtIndex:1] floatValue];
        }
        else
        {
            [node setValue:value forKey:name];
        }
    }  
}

- (void) setFirstFrameForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp tweenDuration:(float)tweenDuration
{
    NSArray* keyframes = [seqProp keyframes];
    
    if (keyframes.count == 0)
    {
        // Use base value (no animation)
        id baseValue = [self baseValueForNode:node propertyName:seqProp.name];
        NSAssert1(baseValue, @"No baseValue found for property (%@)", seqProp.name);
        [self setAnimatedProperty:seqProp.name forNode:node toValue:baseValue tweenDuration:tweenDuration];
    }
    else
    {
        // Use first keyframe
        CCBKeyframe* keyframe = [keyframes objectAtIndex:0];
        [self setAnimatedProperty:seqProp.name forNode:node toValue:keyframe.value tweenDuration:tweenDuration];
    }
}

- (CCActionInterval*) easeAction:(CCActionInterval*) action easingType:(int)easingType easingOpt:(float) easingOpt
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

- (void) removeActionsByTag:(NSInteger)tag fromNode:(CCNode*)node
{
    CCActionManager* am = [[CCDirector sharedDirector] actionManager];
    
    while ([am getActionByTag:tag target:node])
    {
        [am removeActionByTag:tag target:node];
    }
}

- (void) runActionsForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp tweenDuration:(float)tweenDuration
{
    NSArray* keyframes = [seqProp keyframes];
    int numKeyframes = (int)keyframes.count;
    
    if (numKeyframes > 1)
    {
        // Make an animation!
        NSMutableArray* actions = [NSMutableArray array];
            
        CCBKeyframe* keyframeFirst = [keyframes objectAtIndex:0];
        float timeFirst = keyframeFirst.time + tweenDuration;
        
        if (timeFirst > 0)
        {
            [actions addObject:[CCActionDelay actionWithDuration:timeFirst]];
        }
        
        for (int i = 0; i < numKeyframes - 1; i++)
        {
            CCBKeyframe* kf0 = [keyframes objectAtIndex:i];
            CCBKeyframe* kf1 = [keyframes objectAtIndex:i+1];
            
            CCActionInterval* action = [self actionFromKeyframe0:kf0 andKeyframe1:kf1 propertyName:seqProp.name node:node];
            if (action)
            {
                // Apply easing
                action = [self easeAction:action easingType:kf0.easingType easingOpt:kf0.easingOpt];
                
                [actions addObject:action];
            }
        }
        
        CCActionSequence* seq = [CCActionSequence actionWithArray:actions];
        seq.tag = animationManagerId;
        [node runAction:seq];
    }
}

- (id) actionForCallbackChannel:(CCBSequenceProperty*) channel
{
    float lastKeyframeTime = 0;
    
    NSMutableArray* actions = [NSMutableArray array];
    
    for (CCBKeyframe* keyframe in channel.keyframes)
    {
        float timeSinceLastKeyframe = keyframe.time - lastKeyframeTime;
        lastKeyframeTime = keyframe.time;
        if (timeSinceLastKeyframe > 0)
        {
            [actions addObject:[CCActionDelay actionWithDuration:timeSinceLastKeyframe]];
        }
        
        NSString* selectorName = [keyframe.value objectAtIndex:0];
        int selectorTarget = [[keyframe.value objectAtIndex:1] intValue];
        
        // Callback through obj-c
        id target = NULL;
        if (selectorTarget == kCCBTargetTypeDocumentRoot) target = self.rootNode;
        else if (selectorTarget == kCCBTargetTypeOwner) target = owner;
        
        SEL selector = NSSelectorFromString(selectorName);
        
        if (target && selector)
        {
            [actions addObject:[CCActionCallFunc actionWithTarget:target selector:selector]];
        }
    }
    
    if (!actions.count) return NULL;
    
    return [CCActionSequence actionWithArray:actions];
}

- (id) actionForSoundChannel:(CCBSequenceProperty*) channel
{
    float lastKeyframeTime = 0;
    
    NSMutableArray* actions = [NSMutableArray array];
    
    for (CCBKeyframe* keyframe in channel.keyframes)
    {
        float timeSinceLastKeyframe = keyframe.time - lastKeyframeTime;
        lastKeyframeTime = keyframe.time;
        if (timeSinceLastKeyframe > 0)
        {
            [actions addObject:[CCActionDelay actionWithDuration:timeSinceLastKeyframe]];
        }
        
        NSString* soundFile = [keyframe.value objectAtIndex:0];
        float pitch = [[keyframe.value objectAtIndex:1] floatValue];
        float pan = [[keyframe.value objectAtIndex:2] floatValue];
        float gain = [[keyframe.value objectAtIndex:3] floatValue];
        
        [actions addObject:[CCBSoundEffect actionWithSoundFile:soundFile pitch:pitch pan:pan gain:gain]];
    }
    
    if (!actions.count) return NULL;
    
    return [CCActionSequence actionWithArray:actions];
}

- (void) runAnimationsForSequenceId:(int)seqId tweenDuration:(float) tweenDuration
{
    NSAssert(seqId != -1, @"Sequence id %d couldn't be found",seqId);
    
    // Stop actions associated with this animation manager
    [self removeActionsByTag:animationManagerId fromNode:rootNode];
    
    for (NSValue* nodePtr in nodeSequences)
    {
        CCNode* node = [nodePtr pointerValue];
        
        // Stop actions associated with this animation manager
        [self removeActionsByTag:animationManagerId fromNode:node];
        
        NSDictionary* seqs = [nodeSequences objectForKey:nodePtr];
        NSDictionary* seqNodeProps = [seqs objectForKey:[NSNumber numberWithInt:seqId]];
        
        NSMutableSet* seqNodePropNames = [NSMutableSet set];
        
        // Reset nodes that have sequence node properties, and run actions on them
        for (NSString* propName in seqNodeProps)
        {
            CCBSequenceProperty* seqProp = [seqNodeProps objectForKey:propName];
            [seqNodePropNames addObject:propName];
            
            [self setFirstFrameForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration];
            [self runActionsForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration];
        }
        
        // Reset the nodes that may have been changed by other timelines
        NSDictionary* nodeBaseValues = [baseValues objectForKey:nodePtr];
        for (NSString* propName in nodeBaseValues)
        {
            if (![seqNodePropNames containsObject:propName])
            {
                id value = [nodeBaseValues objectForKey:propName];
                
                if (value)
                {
                    [self setAnimatedProperty:propName forNode:node toValue:value tweenDuration:tweenDuration];
                }
            }
        }
    }
    
    // Make callback at end of sequence
    CCBSequence* seq = [self sequenceFromSequenceId:seqId];
    CCAction* completeAction = [CCActionSequence actionOne:[CCActionDelay actionWithDuration:seq.duration+tweenDuration] two:[CCActionCallFunc actionWithTarget:self selector:@selector(sequenceCompleted)]];
    completeAction.tag = animationManagerId;
    [rootNode runAction:completeAction];
    
    // Playback callbacks and sounds
    if (seq.callbackChannel)
    {
        // Build sound actions for channel
        CCAction* action = [self actionForCallbackChannel:seq.callbackChannel];
        if (action)
        {
            action.tag = animationManagerId;
            [self.rootNode runAction:action];
        }
    }
    
    if (seq.soundChannel)
    {
        // Build sound actions for channel
        CCAction* action = [self actionForSoundChannel:seq.soundChannel];
        if (action)
        {
            action.tag = animationManagerId;
            [self.rootNode runAction:action];
        }
    }
    
    // Set the running scene
    runningSequence = [self sequenceFromSequenceId:seqId];
}

- (void) runAnimationsForSequenceNamed:(NSString*)name tweenDuration:(float)tweenDuration
{
    int seqId = [self sequenceIdForSequenceNamed:name];
    [self runAnimationsForSequenceId:seqId tweenDuration:tweenDuration];
}

- (void) runAnimationsForSequenceNamed:(NSString*)name
{
    [self runAnimationsForSequenceNamed:name tweenDuration:0];
}

- (void) sequenceCompleted
{
    // Save last completed sequence
    if (lastCompletedSequenceName != runningSequence.name)
    {
        lastCompletedSequenceName = [runningSequence.name copy];
    }
    
    // Play next sequence
    int nextSeqId = runningSequence.chainedSequenceId;
    runningSequence = NULL;
    
    // Callbacks
    [delegate completedAnimationSequenceNamed:lastCompletedSequenceName];
    if (block) block(self);
    
    // Run next sequence if callbacks did not start a new sequence
    if (runningSequence == NULL && nextSeqId != -1)
    {
        [self runAnimationsForSequenceId:nextSeqId tweenDuration:0];
    }
}

- (NSString*) runningSequenceName
{
    return runningSequence.name;
}

-(void) setCompletedAnimationCallbackBlock:(void(^)(id sender))b
{
    block = [b copy];
}

/*
- (void) setCallFunc:(CCCallBlockN *)callFunc forJSCallbackNamed:(NSString *)callbackNamed
{
    [keyframeCallFuncs setObject:callFunc forKey:callbackNamed];
}
 */

- (void) dealloc
{
    self.rootNode = NULL;
    
    
    
    
    
}

- (void) debug
{
    //NSLog(@"baseValues: %@", baseValues);
    //NSLog(@"nodeSequences: %@", nodeSequences);
}

@end

#pragma mark Custom Actions

@implementation CCBSetSpriteFrame
+(id) actionWithSpriteFrame: (CCSpriteFrame*) sf;
{
	return [[self alloc]initWithSpriteFrame:sf];
}

-(id) initWithSpriteFrame: (CCSpriteFrame*) sf;
{
	if( (self=[super init]) )
		spriteFrame = sf;
    
	return self;
}


-(id) copyWithZone: (NSZone*) zone
{
	CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithSpriteFrame:spriteFrame];
	return copy;
}

-(void) update:(CCTime)time
{
	((CCSprite *)self.target).spriteFrame = spriteFrame;
}

@end


@implementation CCBRotateTo

+(id) actionWithDuration:(CCTime)duration angle:(float)angle
{
    return [[self alloc] initWithDuration:duration angle:angle];
}

-(id) initWithDuration:(CCTime)duration angle:(float)angle
{
    self = [super initWithDuration:duration];
    if (!self) return NULL;
    
    dstAngle_ = angle;
    
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration:[self duration] angle:dstAngle_];
	return copy;
}

-(void) startWithTarget:(CCNode *)aTarget
{
	[super startWithTarget:aTarget];
    startAngle_ = [self.target rotation];
    diffAngle_ = dstAngle_ - startAngle_;
}

-(void) update: (CCTime) t
{
	[self.target setRotation: startAngle_ + diffAngle_ * t];
}

@end


@implementation CCBRotateXTo

-(void) startWithTarget:(CCNode *)aTarget
{
    _originalTarget = _target = aTarget;
    
    _elapsed = 0.0f;
	_firstTick = YES;
    
    startAngle_ = [self.target rotationalSkewX];
    diffAngle_ = dstAngle_ - startAngle_;
}

-(void) update: (CCTime) t
{
	[self.target setRotationalSkewX: startAngle_ + diffAngle_ * t];
}

@end


@implementation CCBRotateYTo

-(void) startWithTarget:(CCNode *)aTarget
{
	_originalTarget = _target = aTarget;
    
    _elapsed = 0.0f;
	_firstTick = YES;
    
    startAngle_ = [self.target rotationalSkewY];
    diffAngle_ = dstAngle_ - startAngle_;
}

-(void) update: (CCTime) t
{
	[self.target setRotationalSkewY: startAngle_ + diffAngle_ * t];
}

@end


@implementation CCBSoundEffect

+(id) actionWithSoundFile:(NSString*)f pitch:(float)pi pan:(float) pa gain:(float)ga
{
    return [[CCBSoundEffect alloc] initWithSoundFile:f pitch:pi pan:pa gain:ga];
}

-(id) initWithSoundFile:(NSString*)file pitch:(float)pi pan:(float) pa gain:(float)ga
{
    self = [super init];
    if (!self) return NULL;
    
    soundFile = [file copy];
    pitch = pi;
    pan = pa;
    gain = ga;
    
    return self;
}


- (void) update:(CCTime)time
{
    [[OALSimpleAudio sharedInstance] playEffect:soundFile volume:gain pitch:pitch pan:pan loop:NO];
}

@end

@implementation CCActionEaseInstant
-(void) update: (CCTime) t
{
    if (t < 0)
    {
        [self.inner update:0];
    }
    else
    {
        [self.inner update:1];
    }
}
@end

