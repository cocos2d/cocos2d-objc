//
//  CCBActionManager.m
//  CocosBuilderExample
//
//  Created by Viktor Lidholt on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCBActionManager.h"
#import "CCBSequence.h"
#import "CCBSequenceProperty.h"
#import "CCBReader.h"
#import "CCBKeyframe.h"
#import "CCNode+CCBRelativePositioning.h"

@implementation CCBActionManager

@synthesize sequences;
@synthesize autoPlaySequenceId;
@synthesize rootNode;
@synthesize rootContainerSize;
@synthesize delegate;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
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
    [node retain];
    
    NSValue* nodePtr = [NSValue valueWithPointer:node];
    [nodeSequences setObject:seq forKey:nodePtr];
}

- (void) setBaseValue:(id)value forNode:(CCNode*)node propertyName:(NSString*)propName
{
    NSValue* nodePtr = [NSValue valueWithPointer:node];
    
    NSMutableDictionary* props = [baseValues objectForKey:nodePtr];
    if (!props)
    {
        props = [NSMutableDictionary dictionary];
        [baseValues setObject:props forKey:nodePtr];
        [node retain];
    }
    
    [props setObject:value forKey:propName];
}

- (id) baseValueForNode:(CCNode*) node propertyName:(NSString*) propName
{
    NSValue* nodePtr = [NSValue valueWithPointer:node];
    
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

- (void) setAnimatedProperty:(NSString*)name forNode:(CCNode*)node toValue:(id)value ofType:(int)type
{
    if (type == kCCBPropTypePosition)
    {
        // Get position type
        int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
        
        // Get relative position
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        [node setRelativePosition:ccp(x,y) type:type parentSize:[self containerSize:node.parent] propertyName:name];
    }
    else if (type == kCCBPropTypeScaleLock)
    {
        // Get scale type
        int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
        
        NSLog(@"scale type: %d", type);
        
        // Get relative scale
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        [node setRelativeScaleX:x Y:y type:type propertyName:name];
    }
    else
    {
        [node setValue:value forKey:name];
    }
}

- (void) setFirstFrameForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp tweenDuration:(float)tweenDuration
{
    NSArray* keyframes = [seqProp keyframes];
    int type = seqProp.type;
    
    if (keyframes.count == 0)
    {
        // Use base value (no animation)
        id baseValue = [self baseValueForNode:node propertyName:seqProp.name];
        NSAssert1(baseValue, @"No baseValue found for property (%@)", seqProp.name);
        [self setAnimatedProperty:seqProp.name forNode:node toValue:baseValue ofType:type];
    }
    else
    {
        // Use first keyframe
        CCBKeyframe* keyframe = [keyframes objectAtIndex:0];
        [self setAnimatedProperty:seqProp.name forNode:node toValue:keyframe.value ofType:type];
    }
}

- (CCActionInterval*) actionFromKeyframe0:(CCBKeyframe*)kf0 andKeyframe1:(CCBKeyframe*)kf1 sequenceProperty:(CCBSequenceProperty*)seqProp node:(CCNode*)node
{
    int type = seqProp.type;
    NSString* name = seqProp.name;
    float duration = kf1.time - kf0.time;
    
    if (type == kCCBPropTypeDegrees 
        && [name isEqualToString:@"rotation"])
    {
        return [CCRotateTo actionWithDuration:duration angle:[kf1.value floatValue]];
    }
    else if (type == kCCBPropTypeByte
             && [name isEqualToString:@"opacity"])
    {
        return [CCFadeTo actionWithDuration:duration opacity:[kf1.value intValue]];
    }
    else if (type == kCCBPropTypeColor3
             && [name isEqualToString:@"color"])
    {
        ccColor3B c;
        [kf1.value getValue:&c];
        
        return [CCTintTo actionWithDuration:duration red:c.r green:c.g blue:c.b];
    }
    else if (type == kCCBPropTypeCheck
             && [name isEqualToString:@"visible"])
    {
        if ([kf1.value boolValue])
        {
            return [CCSequence actionOne:[CCDelayTime actionWithDuration:duration] two:[CCShow action]];
        }
        else
        {
            return [CCSequence actionOne:[CCDelayTime actionWithDuration:duration] two:[CCHide action]];
        }
    }
    else if (type == kCCBPropTypeSpriteFrame
             && [name isEqualToString:@"spriteFrame"])
    {
        return [CCSequence actionOne:[CCDelayTime actionWithDuration:duration] two:[CCBSetSpriteFrame actionWithSpriteFrame:kf1.value]];
    }
    else if (type == kCCBPropTypePosition
             && [name isEqualToString:@"position"])
    {
        // Get position type
        int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
        
        id value = kf1.value;
        
        // Get relative position
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        CGSize containerSize = [self containerSize:node.parent];
        
        CGPoint absPos = [node absolutePositionFromRelative:ccp(x,y) type:type parentSize:containerSize propertyName:name];
        
        return [CCMoveTo actionWithDuration:duration position:absPos];
    }
    else if (type == kCCBPropTypeScaleLock
             && [name isEqualToString:@"scale"])
    {
        // Get position type
        int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
        
        id value = kf1.value;
        
        // Get relative scale
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        if (type == kCCBScaleTypeMultiplyResolution)
        {
            float resolutionScale = [node resolutionScale];
            x *= resolutionScale;
            y *= resolutionScale;
        }
        
        return [CCScaleTo actionWithDuration:duration scaleX:x scaleY:y];
    }
    else
    {
        NSLog(@"CCBReader: Failed to create animation for type: %d property: %@",type, name);
    }
    return NULL;
}

- (CCActionInterval*) easeAction:(CCActionInterval*) action easingType:(int)easingType easingOpt:(float) easingOpt
{
    if (easingType == kCCBKeyframeEasingLinear
        || easingType == kCCBKeyframeEasingInstant)
    {
        return action;
    }
    else if (easingType == kCCBKeyframeEasingCubicIn)
    {
        return [CCEaseIn actionWithAction:action rate:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingCubicOut)
    {
        return [CCEaseOut actionWithAction:action rate:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingCubicInOut)
    {
        return [CCEaseInOut actionWithAction:action rate:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingBackIn)
    {
        return [CCEaseBackIn actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBackOut)
    {
        return [CCEaseBackOut actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBackInOut)
    {
        return [CCEaseBackInOut actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBounceIn)
    {
        return [CCEaseBounceIn actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBounceOut)
    {
        return [CCEaseBounceOut actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingBounceInOut)
    {
        return [CCEaseBounceInOut actionWithAction:action];
    }
    else if (easingType == kCCBKeyframeEasingElasticIn)
    {
        return [CCEaseElasticIn actionWithAction:action period:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingElasticOut)
    {
        return [CCEaseElasticOut actionWithAction:action period:easingOpt];
    }
    else if (easingType == kCCBKeyframeEasingElasticInOut)
    {
        return [CCEaseElasticInOut actionWithAction:action period:easingOpt];
    }
    else
    {
        NSLog(@"CCBReader: Unkown easing type %d", easingType);
        return action;
    }
}

- (void) runActionsForNode:(CCNode*)node sequenceProperty:(CCBSequenceProperty*)seqProp tweenDuration:(float)tweenDuration
{
    [self setFirstFrameForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration];
    
    NSArray* keyframes = [seqProp keyframes];
    NSUInteger numKeyframes = keyframes.count;
    
    if (numKeyframes > 1)
    {
        // Make an animation!
        NSMutableArray* actions = [NSMutableArray array];
            
        CCBKeyframe* keyframeFirst = [keyframes objectAtIndex:0];
        float timeFirst = keyframeFirst.time;
        
        if (timeFirst > 0)
        {
            [actions addObject:[CCDelayTime actionWithDuration:timeFirst]];
        }
        
        for (int i = 0; i < numKeyframes - 1; i++)
        {
            CCBKeyframe* kf0 = [keyframes objectAtIndex:i];
            CCBKeyframe* kf1 = [keyframes objectAtIndex:i+1];
            
            CCActionInterval* action = [self actionFromKeyframe0:kf0 andKeyframe1:kf1 sequenceProperty:seqProp node:node];
            if (action)
            {
                // Apply easing
                action = [self easeAction:action easingType:kf0.easingType easingOpt:kf0.easingOpt];
                
                [actions addObject:action];
            }
        }
        
        CCSequence* seq = [CCSequence actionWithArray:actions];
        [node runAction:seq];
    }
}

- (void) runActionsForSequenceId:(int)seqId tweenDuration:(float) tweenDuration
{
    NSAssert(seqId != -1, @"Sequence named %d couldn't be found", seqId);
    
    for (NSValue* nodePtr in nodeSequences)
    {
        CCNode* node = [nodePtr pointerValue];
        [node stopAllActions];
        
        NSDictionary* seqs = [nodeSequences objectForKey:nodePtr];
        NSDictionary* seqNodeProps = [seqs objectForKey:[NSNumber numberWithInt:seqId]];
        
        for (NSString* propName in seqNodeProps)
        {
            CCBSequenceProperty* seqProp = [seqNodeProps objectForKey:propName];
            [self runActionsForNode:node sequenceProperty:seqProp tweenDuration:tweenDuration];
        }
    }
    
    // Make callback at end of sequence
    CCBSequence* seq = [self sequenceFromSequenceId:seqId];
    CCAction* completeAction = [CCSequence actionOne:[CCDelayTime actionWithDuration:seq.duration] two:[CCCallFunc actionWithTarget:self selector:@selector(sequenceCompleted)]];
    [rootNode runAction:completeAction];
    
    // Set the running scene
    runningSequence = [self sequenceFromSequenceId:seqId];
}

- (void) runActionsForSequenceNamed:(NSString*)name tweenDuration:(float)tweenDuration
{
    int seqId = [self sequenceIdForSequenceNamed:name];
    [self runActionsForSequenceId:seqId tweenDuration:tweenDuration];
}

- (void) runActionsForSequenceNamed:(NSString*)name
{
    [self runActionsForSequenceNamed:name tweenDuration:0];
}

- (void) sequenceCompleted
{
    [delegate completedAnimationSequenceNamed:runningSequence.name];
    int nextSeqId = runningSequence.chainedSequenceId;
    runningSequence = NULL;
    
    if (nextSeqId != -1)
    {
        [self runActionsForSequenceId:nextSeqId tweenDuration:0];
    }
    
}

- (NSString*) runningSequenceName
{
    return runningSequence.name;
}

- (void) dealloc
{
    for (NSValue* nodePtr in nodeSequences)
    {
        CCNode* node = [nodePtr pointerValue];
        [node release];
    }
    
    for (NSValue* nodePtr in baseValues)
    {
        CCNode* node = [nodePtr pointerValue];
        [node release];
    }
    
    [baseValues release];
    [sequences release];
    [nodeSequences release];
    self.rootNode = NULL;
    self.delegate = NULL;
    [super dealloc];
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
	return [[[self alloc]initWithSpriteFrame:sf]autorelease];
}

-(id) initWithSpriteFrame: (CCSpriteFrame*) sf;
{
	if( (self=[super init]) )
		spriteFrame = [sf retain];
    
	return self;
}

- (void) dealloc
{
    [spriteFrame release];
    [super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithSpriteFrame:spriteFrame];
	return copy;
}

-(void) update:(ccTime)time
{
	((CCSprite *)target_).displayFrame = spriteFrame;
}

@end
