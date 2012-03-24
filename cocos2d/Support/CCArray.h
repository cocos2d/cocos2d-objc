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


#import "ccCArray.h"


/** A faster alternative of NSArray.
 CCArray uses internally a c-array.
 @since v0.99.4
 */


/** @def CCARRAY_FOREACH
 A convience macro to iterate over a CCArray using. It is faster than the "fast enumeration" interface.
 @since v0.99.4
 */

#define CCARRAY_FOREACH(__array__, __object__)												\
if (__array__ && __array__->data->num > 0)													\
for(const CC_ARC_UNSAFE_RETAINED id *__arr__ = __array__->data->arr, *end = __array__->data->arr + __array__->data->num-1;	\
	__arr__ <= end && ((__object__ = *__arr__) != nil || true);										\
	__arr__++)

@interface CCArray : NSObject <NSFastEnumeration, NSCoding, NSCopying>
{
	@public ccArray *data;
}

+ (id) array;
+ (id) arrayWithCapacity:(NSUInteger)capacity;
+ (id) arrayWithArray:(CCArray*)otherArray;
+ (id) arrayWithNSArray:(NSArray*)otherArray;


- (id) initWithCapacity:(NSUInteger)capacity;
- (id) initWithArray:(CCArray*)otherArray;
- (id) initWithNSArray:(NSArray*)otherArray;


// Querying an Array

- (NSUInteger) count;
- (NSUInteger) capacity;
- (NSUInteger) indexOfObject:(id)object;
- (id) objectAtIndex:(NSUInteger)index;
- (BOOL) containsObject:(id)object;
- (id) randomObject;
- (id) lastObject;
- (NSArray*) getNSArray;
/** @since 1.1 */
- (BOOL) isEqualToArray:(CCArray*)otherArray;


// Adding Objects

- (void) addObject:(id)object;
- (void) addObjectsFromArray:(CCArray*)otherArray;
- (void) addObjectsFromNSArray:(NSArray*)otherArray;
- (void) insertObject:(id)object atIndex:(NSUInteger)index;


// Removing Objects

- (void) removeLastObject;
- (void) removeObject:(id)object;
- (void) removeObjectAtIndex:(NSUInteger)index;
- (void) removeObjectsInArray:(CCArray*)otherArray;
- (void) removeAllObjects;
- (void) fastRemoveObject:(id)object;
- (void) fastRemoveObjectAtIndex:(NSUInteger)index;


// Rearranging Content

- (void) exchangeObject:(id)object1 withObject:(id)object2;
- (void) exchangeObjectAtIndex:(NSUInteger)index1 withObjectAtIndex:(NSUInteger)index2;
/** @since 1.1 */
- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void) reverseObjects;
- (void) reduceMemoryFootprint;

// Sorting Array 
/** all since @1.1 */
- (void) qsortUsingCFuncComparator:(int(*)(const void *, const void *))comparator;	// c qsort is used for sorting
- (void) insertionSortUsingCFuncComparator:(int(*)(const void *, const void *))comparator;  // insertion sort 
- (void) mergesortLUsingCFuncComparator:(int(*)(const void *, const void *))comparator;	// mergesort
- (void) insertionSort:(SEL)selector; // It sorts source array in ascending order
- (void) sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;

// Sending Messages to Elements

- (void) makeObjectsPerformSelector:(SEL)aSelector;
- (void) makeObjectsPerformSelector:(SEL)aSelector withObject:(id)object;
/** @since 1.1 */
- (void) makeObjectPerformSelectorWithArrayObjects:(id)object selector:(SEL)aSelector; 

@end
