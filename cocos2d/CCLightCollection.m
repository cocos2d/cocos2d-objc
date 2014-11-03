/*
 * cocos2d swift: http://www.cocos2d-swift.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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

#import "CCLightCollection.h"
#import "CCLightGroups.h"
#import "CCLightNode.h"

#import "CCLightNode_Private.h"


#if CC_EFFECTS_EXPERIMENTAL


const CCLightGroupMask CCLightCollectionAllGroups = ~((CCLightGroupMask)0);
static const NSUInteger CCLightCollectionMaxGroupCount = sizeof(NSUInteger) * 8;


@interface CCLightCollection ()

@property (nonatomic, strong) NSMutableArray *groupNames;
@property (nonatomic, strong) NSMutableArray *lights;

@end


@implementation CCLightCollection

- (id)init
{
    if ((self = [super init]))
    {
        _groupNames = [[NSMutableArray alloc] init];
        _lights = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Adding and removing lights

- (void)addLight:(CCLightNode *)light
{
    [self.lights addObject:light];
}

- (void)removeLight:(CCLightNode *)light
{
    [self.lights removeObject:light];
}

- (void)removeAllLights
{
    [self.lights removeAllObjects];
}


#pragma mark - Queries

- (NSArray*)findClosestKLights:(NSUInteger)count toPoint:(CGPoint)point withMask:(CCLightGroupMask)mask
{
    NSPredicate *groupsMatch = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
                                {
                                    CCLightNode *light = (CCLightNode*)evaluatedObject;
                                    return [CCLightCollection light:light hasEffectOnGroups:mask atPoint:point];
                                }];
    NSArray *maskedLights = [self.lights filteredArrayUsingPredicate:groupsMatch];
    
    if (maskedLights.count <= count)
    {
        // If we only have as many lights as are being requested, just return them.
        return [maskedLights copy];
    }
    else
    {
        // If we have more lights than are being requested, use quick select to find the
        // closest ones.
        return [CCLightCollection selectClosestKLights:count inArray:maskedLights forPoint:point];
    }
}


#pragma mark - Group management

- (CCLightGroupMask)maskForGroups:(NSArray *)groups
{
    if (groups)
    {
        CCLightGroupMask bitmask = 0;
        for(NSString *group in groups)
        {
            bitmask |= (1 << [self indexForGroupName:group]);
        }
        return bitmask;
    }
    else
    {
        // nil (the default value) is equivalent to all groups.
        return CCLightCollectionAllGroups;
    }
}


#pragma mark - Private helpers

- (NSUInteger)indexForGroupName:(NSString *)groupName
{
    // Add the group name if it doesn't exist yet.
    if(![_groupNames containsObject:groupName])
    {
        NSAssert(_groupNames.count < CCLightCollectionMaxGroupCount, @"A collection can only track up to %lu groups.", (unsigned long)CCLightCollectionMaxGroupCount);
        [_groupNames addObject:groupName];
    }
    
    return [_groupNames indexOfObject:groupName];
}

+ (NSArray *)selectClosestKLights:(NSUInteger)count inArray:(NSArray *)array forPoint:(CGPoint)refPoint
{
    NSMutableArray *sortedArray = [array mutableCopy];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    if (array.count == 0)
    {
        return [results copy];
    }
    else if (array.count == 1)
    {
        [results addObject:array[0]];
        return [results copy];
    }
    
    NSUInteger leftIndex = 0;
    NSUInteger rightIndex = array.count - 1;

    while (1)
    {
        NSUInteger pivotIndex = leftIndex + arc4random_uniform((uint32_t)(rightIndex - leftIndex + 1));        
        pivotIndex = [CCLightCollection partitionArray:sortedArray forPoint:refPoint withLeftIndex:leftIndex rightIndex:rightIndex pivotIndex:pivotIndex];
        
        if ((count - 1) == pivotIndex)
        {
            for (NSUInteger i = 0; i < count; i++)
            {
                [results addObject:sortedArray[i]];
            }
            break;
        }
        else if ((count - 1) < pivotIndex)
        {
            rightIndex = pivotIndex - 1;
        }
        else
        {
            leftIndex = pivotIndex + 1;
        }
    }

    return [results copy];
}

+ (NSUInteger)partitionArray:(NSMutableArray *)array forPoint:(CGPoint)refPoint withLeftIndex:(NSUInteger)leftIndex rightIndex:(NSUInteger)rightIndex pivotIndex:(NSUInteger)pivotIndex
{
    float pivotValue = [CCLightCollection distanceSquaredFromLight:(CCLightNode *)array[pivotIndex] toPoint:refPoint];
    [array exchangeObjectAtIndex:pivotIndex withObjectAtIndex:rightIndex];
    
    NSUInteger storeIndex = leftIndex;
    for (NSUInteger i = leftIndex; i < rightIndex; i++)
    {
        CCLightNode *light = (CCLightNode*)array[i];
        float currentValue = [CCLightCollection distanceSquaredFromLight:light toPoint:refPoint];
        if (currentValue < pivotValue)
        {
            [array exchangeObjectAtIndex:storeIndex withObjectAtIndex:i];
            storeIndex++;
        }
    }
    [array exchangeObjectAtIndex:rightIndex withObjectAtIndex:storeIndex];
    return storeIndex;
}

+ (float)distanceSquaredFromLight:(CCLightNode*)light toPoint:(CGPoint)refPoint
{
    CGPoint lightPosition = CGPointApplyAffineTransform(light.anchorPointInPoints, light.nodeToWorldTransform);
    CGPoint delta = CGPointMake(lightPosition.x - refPoint.x, lightPosition.y - refPoint.y);
    
    float distSquared = delta.x * delta.x + delta.y * delta.y;
    return distSquared;
}

+ (BOOL)light:(CCLightNode *)light hasEffectOnGroups:(CCLightGroupMask)groupMask atPoint:(CGPoint)point
{
    BOOL groupsIntersect = ((light.groupMask & groupMask) != 0);
    BOOL distanceMatters = (light.cutoffRadius > 0.0f);

    float dSquared = [CCLightCollection distanceSquaredFromLight:light toPoint:point];
    BOOL inRange = (dSquared < (light.cutoffRadius * light.cutoffRadius));
    
    return groupsIntersect && (!distanceMatters || inRange);
}

@end

#endif
