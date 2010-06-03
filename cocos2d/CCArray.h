//
//  CCArray.h
//  cocos2d-iphone
//
//  Created by Manuel Martinez-Almeida Castañeda on 02/06/10.
//  Copyright 2010 Abstraction Works. All rights reserved.
//  http://www.abstractionworks.com
//

#import "Support/ccArray.h"


@interface CCArray : NSObject <NSFastEnumeration>
{
	@public ccArray *data;
}

+ (id) arrayWithCapacity:(NSUInteger)capacity;
+ (id) arrayWithArray:(CCArray*)otherArray;
+ (id) arrayWithNSArray:(NSArray*)otherArray;


- (id) initWithCapacity:(NSUInteger)capacity;
- (id) initWithArray:(CCArray*)otherArray;
- (id) initWithNSArray:(NSArray*)otherArray;


- (NSUInteger) count;
- (NSUInteger) capacity;
- (NSUInteger) indexOfObject:(id)object;
- (id) objectAtIndex:(NSUInteger)index;
- (id) lastObject;
- (BOOL) containsObject:(id)object;

#pragma mark Adding Objects

- (void) addObject:(id)object;
- (void) addObjectsFromArray:(CCArray*)otherArray;
- (void) addObjectsFromNSArray:(NSArray*)otherArray;
- (void) insertObject:(id)object atIndex:(NSUInteger)index;

#pragma mark Removing Objects

- (void) removeLastObject;
- (void) removeObject:(id)object;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) removeObjectsInArray:(CCArray*)otherArray;
- (void) removeAllObjects;
- (void) makeObjectsPerformSelector:(SEL)aSelector;

- (void) fastRemoveObject:(id)object;
- (void) fastRemoveObjectAtIndex:(NSUInteger)index;


@end
