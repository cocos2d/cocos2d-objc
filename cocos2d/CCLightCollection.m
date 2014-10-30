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
    __block NSUInteger matchCount = 0;
    NSPredicate *groupsMatch = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        CCLightNode *light = (CCLightNode*)evaluatedObject;
        
        BOOL match = ((light.groupMask & mask) != 0);
        if (match)
        {
            matchCount++;
        }
        
        return match && (matchCount <= count);
    }];
    NSArray *results = [self.lights filteredArrayUsingPredicate:groupsMatch];
    return results;
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

@end

#endif
