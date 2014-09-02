//
//  ALWeakArray.m
//  cocos2d-ios
//
//  Created by Philippe Hausler on 7/1/14.
//
//

#import "ALWeakArray.h"
#import "ALWeakElement.h"

@implementation ALWeakArray {
    NSMutableArray *_elements;
}

+ (id)arrayWithCapacity:(NSUInteger)numItems
{
    return [[self alloc] initWithCapacity:numItems];
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    if (self)
    {
        _elements = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    return self;
}

- (NSUInteger)count
{
    return [_elements count];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    ALWeakElement *element = _elements[idx];
    return element.object;
}

- (void)addObject:(id)obj
{
    ALWeakElement *element = [[ALWeakElement alloc] init];
    element.object = obj;
    [_elements addObject:element];
}

- (void)insertObject:(id)obj atIndex:(NSUInteger)idx
{
    ALWeakElement *element = [[ALWeakElement alloc] init];
    element.object = obj;
    [_elements insertObject:element atIndex:idx];
}

- (void)removeLastObject
{
    [_elements removeLastObject];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    [_elements removeObjectAtIndex:idx];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj
{
    ALWeakElement *element = [[ALWeakElement alloc] init];
    element.object = obj;
    [_elements replaceObjectAtIndex:idx withObject:element];
}

@end
