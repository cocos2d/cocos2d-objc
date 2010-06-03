//
//  CCArray.m
//  cocos2d-iphone
//
//  Created by Manuel Martinez-Almeida Castañeda on 02/06/10.
//  Copyright 2010 Abstraction Works. All rights reserved.
//  http://www.abstractionworks.com
//

#import "CCArray.h"


@implementation CCArray

+ (id) arrayWithCapacity:(NSUInteger)capacity
{
	return [[[self alloc] initWithCapacity:capacity] autorelease];
}

+ (id) arrayWithArray:(CCArray*)otherArray
{
	return [[(CCArray*)[self alloc] initWithArray:otherArray] autorelease];
}

+ (id) arrayWithNSArray:(NSArray*)otherArray
{
	return [[(CCArray*)[self alloc] initWithNSArray:otherArray] autorelease];
}


- (id) initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
	if (self != nil) {
		data = ccArrayNew(capacity);
	}
	return self;
}

- (id) initWithArray:(CCArray*)otherArray
{
	self = [self initWithCapacity:otherArray->data->num];
	if (self != nil) {
		[self addObjectsFromArray:otherArray];
	}
	return self;
}

- (id) initWithNSArray:(NSArray*)otherArray
{
	self = [self initWithCapacity:otherArray.count];
	if (self != nil) {
		[self addObjectsFromNSArray:otherArray];
	}
	return self;
}

- (NSUInteger) count
{
	return data->num;
}

- (NSUInteger) capacity
{
	return data->max;
}

- (NSUInteger) indexOfObject:(id)object
{
	return ccArrayGetIndexOfObject(data, object);
}

- (id) objectAtIndex:(NSUInteger)index
{
	return data->arr[index];
}

- (id) lastObject
{
	return data->arr[data->num];
}



- (BOOL) containsObject:(id)object
{
	return ccArrayContainsObject(data, object);
}

#pragma mark Adding Objects

- (void) addObject:(id)object
{
	ccArrayAppendObjectWithResize(data, object);
}

- (void) addObjectsFromArray:(CCArray*)otherArray
{
	ccArrayAppendArrayWithResize(data, otherArray->data);
}

- (void) addObjectsFromNSArray:(NSArray*)otherArray
{
	ccArrayEnsureExtraCapacity(data, otherArray.count);
	for(id object in otherArray)
		ccArrayAppendObject(data, object);
}

- (void) insertObject:(id)object atIndex:(NSUInteger)index
{
	ccArrayInsertObjectAtIndex(data, object, index);
}

#pragma mark Removing Objects


- (void) removeLastObject
{
	ccArrayRemoveObjectAtIndex(data, data->num);
}

- (void) removeObject:(id)object
{
	ccArrayRemoveObject(data, object);
}

- (void) removeObjectAtIndex:(NSUInteger)index
{
	ccArrayRemoveObjectAtIndex(data, index);
}

- (void) removeObjectsInArray:(CCArray*)otherArray
{
	ccArrayRemoveArray(data, otherArray->data);
}

- (void) removeAllObjects
{
	ccArrayRemoveAllObjects(data);
}

- (void) fastRemoveObjectAtIndex:(NSUInteger)index
{
	ccArrayFastRemoveObjectAtIndex(data, 0);
}

- (void) fastRemoveObject:(id)object
{
	ccArrayFastRemoveObject(data, object);
}

- (void) makeObjectsPerformSelector:(SEL)aSelector
{
	ccArrayMakeObjectsPerformSelector(data, aSelector);
}

- (NSArray*) getNSArray{
	return [NSMutableArray arrayWithCapacity:data->num];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	if(state->state == 1) return 0;
	
	state->mutationsPtr = (unsigned long *)self;
	state->itemsPtr = &data->arr[0];
	state->state = 1;
	return data->num;
}

- (void) dealloc
{
	ccArrayFree(data);
	[super dealloc];
}


@end


