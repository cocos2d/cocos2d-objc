/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 ForzeField Studios S.L. http://forzefield.com
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

- (BOOL) isEqualToArray:(CCArray*)otherArray {
	for (int i = 0; i< [self count]; i++)
	{
		if (![[self objectAtIndex:i] isEqual: [otherArray objectAtIndex:i]])
		{
			return NO;
		}
	}
	return YES;
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

- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    ccArrayInsertObjectAtIndex(data, anObject, index);
    ccArrayRemoveObjectAtIndex(data, index+1);
}

- (void) reverseObjects
{
	if (data->num > 1)
	{
		//floor it since in case of a oneven number the number of swaps stays the same
		int count = (int) floorf(data->num/2.f);
		NSUInteger maxIndex = data->num - 1;

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

- (void) makeObjectPerformSelectorWithArrayObjects:(id)object selector:(SEL)aSelector 
{		
	ccArrayMakeObjectPerformSelectorWithArrayObjects(data, aSelector, object);
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

#pragma mark CCArray - sorting 

/** @since 1.1 */ 
#pragma mark -
#pragma mark CCArray insertionSortUsingCFuncComparator

- (void) insertionSortUsingCFuncComparator:(int(*)(const void *, const void *))comparator
{
    insertionSort(data, comparator);
}

#pragma mark CCArray qsortUsingCFuncComparator

- (void) qsortUsingCFuncComparator:(int(*)(const void *, const void *))comparator {
	
	// stable c qsort is used - cost of sorting:  best n*log(n), average n*log(n)
	//  qsort(void *, size_t, size_t, int (*)(const void *arg1, const void *arg2));
	
    qsort(data->arr, data->num, sizeof (id), comparator);  
}

#pragma mark CCArray mergesortLUsingCFuncComparator

- (void) mergesortLUsingCFuncComparator:(int(*)(const void *, const void *))comparator
{
    mergesortL(data, sizeof (id), comparator); 
}

#pragma mark CCArray insertionSort with (SEL)selector

- (void) insertionSort:(SEL)selector // It sorts source array in ascending order
{
	NSInteger i,j,length = data->num;
	
	id * x = data->arr;
	id temp;	
	
	// insertion sort
	for(i=1; i<length; i++)
	{
		j = i;
		// continue moving element downwards while order is descending 
		while( j>0 && ( (int)([x[j-1] performSelector:selector withObject:x[j]]) == NSOrderedDescending) )
		{
			temp = x[j];
			x[j] = x[j-1];
			x[j-1] = temp;
			j--;
		}
	}
}

static inline NSInteger selectorCompare(id object1,id object2,void *userData){
    SEL selector=userData;
    
    return (NSInteger)[object1 performSelector:selector withObject:object2];
}

-(void)sortUsingSelector:(SEL)selector {
    [self sortUsingFunction:selectorCompare context:selector];
}

#pragma mark CCArray sortUsingFunction

// using a comparison function
-(void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context
{
    NSInteger h, i, j, k, l, m, n = [self count];
    id  A, *B = malloc( (n/2 + 1) * sizeof(id));
    
	// to prevent retain counts from temporarily hitting zero.  
    for( i=0;i<n;i++)
        // [[self objectAtIndex:i] retain]; // prevents compiler warning
		[data->arr[i] retain];

    
    for (h = 1; h < n; h += h)
    {
        for (m = n - 1 - h; m >= 0; m -= h + h)
        {
            l = m - h + 1;
            if (l < 0)
                l = 0;
            for (i = 0, j = l; j <= m; i++, j++)
                B[i] = [self objectAtIndex:j];

            for (i = 0, k = l; k < j && j <= m + h; k++)
            {
                A = [self objectAtIndex:j];
                if (compare(A, B[i], context) == NSOrderedDescending)
                    [self replaceObjectAtIndex:k withObject:B[i++]];
                else
                {
                    [self replaceObjectAtIndex:k withObject:A];
                    j++;
                }
            }
            
            while (k < j)
                [self replaceObjectAtIndex:k++ withObject:B[i++]];
        }
    }
    
    for(i=0;i<n;i++)
		// [[self objectAtIndex:i] release]; // prevents compiler warning
		[data->arr[i] release];
    
    free(B);
}

#pragma mark CCArray - NSCopying protocol

- (id)copyWithZone:(NSZone *)zone
{
	return [(CCArray*)[[self class] allocWithZone:zone] initWithArray:self];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:[self getNSArray] forKey:@"nsarray"];
}

#pragma mark

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

	ccArrayFree(data);
	[super dealloc];
}

#pragma mark

- (NSString*) description
{
	NSMutableString *ret = [NSMutableString stringWithFormat:@"<%@ = %p> = ( ", [self class], self];

	for( id obj in self)
		[ret appendFormat:@"%@, ",obj];

	[ret appendString:@")"];

	return ret;
}

@end
