/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 ForzeFied Studios S.L. http://forzefield.com
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

#import "CCArray.h"
#import "../ccMacros.h"


@implementation CCArray

+ (id) array
{
	return [[[self alloc] init] autorelease];
}

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

- (id) init
{
	self = [self initWithCapacity:2];
	return self;
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

- (id) initWithCoder:(NSCoder*)coder
{
	self = [self initWithNSArray:[coder decodeObjectForKey:@"nsarray"]];
	return self;
}


#pragma mark Querying an Array

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
	NSAssert2( index < data->num, @"index out of range in objectAtIndex(%d), index %i", data->num, index );
	
	return data->arr[index];
}

- (BOOL) containsObject:(id)object
{
	return ccArrayContainsObject(data, object);
}

- (id) lastObject
{
	if( data->num > 0 )
		return data->arr[data->num-1];
	return nil;
}

- (id) randomObject
{
	if(data->num==0) return nil;
	return data->arr[(int)(data->num*CCRANDOM_0_1())];
}

- (NSArray*) getNSArray
{
	return [NSArray arrayWithObjects:data->arr count:data->num];
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

- (void) removeObject:(id)object
{
	ccArrayRemoveObject(data, object);
}

- (void) removeObjectAtIndex:(NSUInteger)index
{
	ccArrayRemoveObjectAtIndex(data, index);
}

- (void) fastRemoveObject:(id)object
{
	ccArrayFastRemoveObject(data, object);
}

- (void) fastRemoveObjectAtIndex:(NSUInteger)index
{
	ccArrayFastRemoveObjectAtIndex(data, index);
}

- (void) removeObjectsInArray:(CCArray*)otherArray
{
	ccArrayRemoveArray(data, otherArray->data);
}

- (void) removeLastObject
{
	NSAssert( data->num > 0, @"no objects added" );
    
	ccArrayRemoveObjectAtIndex(data, data->num-1);
}

- (void) removeAllObjects
{
	ccArrayRemoveAllObjects(data);
}


#pragma mark Rearranging Content

- (void) exchangeObject:(id)object1 withObject:(id)object2
{
    NSUInteger index1 = ccArrayGetIndexOfObject(data, object1);
    if(index1 == NSNotFound) return;
    NSUInteger index2 = ccArrayGetIndexOfObject(data, object2);
    if(index2 == NSNotFound) return;
    
    ccArraySwapObjectsAtIndexes(data, index1, index2);
}

- (void) exchangeObjectAtIndex:(NSUInteger)index1 withObjectAtIndex:(NSUInteger)index2
{
	ccArraySwapObjectsAtIndexes(data, index1, index2);
}

- (void) reverseObjects
{
	if (data->num > 1)
	{
		//floor it since in case of a oneven number the number of swaps stays the same
		int count = (int) floorf(data->num/2.f); 
		uint maxIndex = data->num - 1;
		
		for (int i = 0; i < count ; i++)
		{
			ccArraySwapObjectsAtIndexes(data, i, maxIndex);
			maxIndex--;
		}
	}
}

- (void) reduceMemoryFootprint
{
	ccArrayShrink(data);
}

#pragma mark Sending Messages to Elements

- (void) makeObjectsPerformSelector:(SEL)aSelector
{
	ccArrayMakeObjectsPerformSelector(data, aSelector);
}

- (void) makeObjectsPerformSelector:(SEL)aSelector withObject:(id)object
{
	ccArrayMakeObjectsPerformSelectorWithObject(data, aSelector, object);
}


#pragma mark CCArray - NSFastEnumeration protocol

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	if(state->state == 1) return 0;
	
	state->mutationsPtr = (unsigned long *)self;
	state->itemsPtr = &data->arr[0];
	state->state = 1;
	return data->num;
}


#pragma mark CCArray - NSCopying protocol

- (id)copyWithZone:(NSZone *)zone
{
	NSArray *nsArray = [self getNSArray];
	CCArray *newArray = [[[self class] allocWithZone:zone] initWithNSArray:nsArray];
	return newArray;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self getNSArray] forKey:@"nsarray"];
}

#pragma mark

- (void) dealloc
{
	ccArrayFree(data);
	[super dealloc];
}

@end
