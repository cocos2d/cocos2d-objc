//
//  ALWeakDictionary.m
//  cocos2d-ios
//
//  Created by Philippe Hausler on 7/1/14.
//
//

#import "ALWeakDictionary.h"
#import "ALWeakElement.h"

@implementation ALWeakDictionary {
    NSMutableDictionary *_elements;
}

+ (id)dictionaryWithCapacity:(NSUInteger)numItems
{
    return [[self alloc] initWithCapacity:numItems];
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    if (self)
    {
        _elements = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    }
    return self;
}

- (NSUInteger)count
{
    return [_elements count];
}

- (id)objectForKey:(id)aKey
{
    ALWeakElement *element = _elements[aKey];
    return element.object;
}

- (NSEnumerator *)keyEnumerator
{
    return [_elements keyEnumerator];
}

- (void)removeObjectForKey:(id)aKey
{
    [_elements removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    ALWeakElement *element = [[ALWeakElement alloc] init];
    element.object = anObject;
    _elements[aKey] = element;
}

@end
