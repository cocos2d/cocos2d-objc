/* Copyright (c) 2007 Scott Lembcke
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/** 
 @file
 Based on Chipmunk cpArray.
 ccArray is a faster alternative to NSMutableArray, it does pretty much the
 same thing (stores NSObjects and retains/releases them appropriately). It's
 faster because:
 - it uses a plain C interface so it doesn't incur Objective-c messaging overhead 
 - it assumes you know what you're doing, so it doesn't spend time on safety checks
 (index out of bounds, required capacity etc.)
 - comparisons are done using pointer equality instead of isEqual
 
 There are 2 kind of functions:
 - ccArray functions that manipulates objective-c objects (retain and release are performanced)
 - ccCArray functions that manipulates values like if they were standard C structures (no retain/release is performed)
 */

#ifndef CC_ARRAY_H
#define CC_ARRAY_H

#import <Foundation/Foundation.h>

#import <stdlib.h>
#import <string.h>


#pragma mark -
#pragma mark ccArray for Objects

// Easy integration	
#define CCARRAYDATA_FOREACH(__array__, __object__)															\
__object__=__array__->arr[0]; for(NSUInteger i=0, num=__array__->num; i<num; i++, __object__=__array__->arr[i])	\


typedef struct ccArray {
	NSUInteger num, max;
#if defined(__has_feature) && __has_feature(objc_arc)
	__unsafe_unretained id *arr;
#else
	id *arr;
#endif
} ccArray;

/** Allocates and initializes a new array with specified capacity */
inline ccArray* ccArrayNew(NSUInteger capacity);

inline void ccArrayRemoveAllObjects(ccArray *arr);

/** Frees array after removing all remaining objects. Silently ignores nil arr. */
inline void ccArrayFree(ccArray *arr);

/** Doubles array capacity */
inline void ccArrayDoubleCapacity(ccArray *arr);

/** Increases array capacity such that max >= num + extra. */
inline void ccArrayEnsureExtraCapacity(ccArray *arr, NSUInteger extra);

/** shrinks the array so the memory footprint corresponds with the number of items */
inline void ccArrayShrink(ccArray *arr);

/** Returns index of first occurence of object, NSNotFound if object not found. */
inline NSUInteger ccArrayGetIndexOfObject(ccArray *arr, id object);

/** Returns a Boolean value that indicates whether object is present in array. */
inline BOOL ccArrayContainsObject(ccArray *arr, id object);

/** Appends an object. Bahaviour undefined if array doesn't have enough capacity. */
inline void ccArrayAppendObject(ccArray *arr, id object);

/** Appends an object. Capacity of arr is increased if needed. */
inline void ccArrayAppendObjectWithResize(ccArray *arr, id object);

/** Appends objects from plusArr to arr. Behaviour undefined if arr doesn't have
 enough capacity. */
inline void ccArrayAppendArray(ccArray *arr, ccArray *plusArr);

/** Appends objects from plusArr to arr. Capacity of arr is increased if needed. */
inline void ccArrayAppendArrayWithResize(ccArray *arr, ccArray *plusArr);

/** Inserts an object at index */
inline void ccArrayInsertObjectAtIndex(ccArray *arr, id object, NSUInteger index);

/** Swaps two objects */
inline void ccArraySwapObjectsAtIndexes(ccArray *arr, NSUInteger index1, NSUInteger index2);

/** Removes all objects from arr */
inline void ccArrayRemoveAllObjects(ccArray *arr);

/** Removes object at specified index and pushes back all subsequent objects.
 Behaviour undefined if index outside [0, num-1]. */
inline void ccArrayRemoveObjectAtIndex(ccArray *arr, NSUInteger index);

/** Removes object at specified index and fills the gap with the last object,
 thereby avoiding the need to push back subsequent objects.
 Behaviour undefined if index outside [0, num-1]. */
inline void ccArrayFastRemoveObjectAtIndex(ccArray *arr, NSUInteger index);

inline void ccArrayFastRemoveObject(ccArray *arr, id object);

/** Searches for the first occurance of object and removes it. If object is not
 found the function has no effect. */
inline void ccArrayRemoveObject(ccArray *arr, id object);

/** Removes from arr all objects in minusArr. For each object in minusArr, the
 first matching instance in arr will be removed. */
inline void ccArrayRemoveArray(ccArray *arr, ccArray *minusArr);

/** Removes from arr all objects in minusArr. For each object in minusArr, all
 matching instances in arr will be removed. */
inline void ccArrayFullRemoveArray(ccArray *arr, ccArray *minusArr);

/** Sends to each object in arr the message identified by given selector. */
inline void ccArrayMakeObjectsPerformSelector(ccArray *arr, SEL sel);

inline void ccArrayMakeObjectsPerformSelectorWithObject(ccArray *arr, SEL sel, id object);


#pragma mark -
#pragma mark ccCArray for Values (c structures)

typedef ccArray ccCArray;

inline void ccCArrayRemoveAllValues(ccCArray *arr);

/** Allocates and initializes a new C array with specified capacity */
inline ccCArray* ccCArrayNew(NSUInteger capacity);

/** Frees C array after removing all remaining values. Silently ignores nil arr. */
inline void ccCArrayFree(ccCArray *arr);

/** Doubles C array capacity */
inline void ccCArrayDoubleCapacity(ccCArray *arr);

/** Increases array capacity such that max >= num + extra. */
inline void ccCArrayEnsureExtraCapacity(ccCArray *arr, NSUInteger extra);

/** Returns index of first occurence of value, NSNotFound if value not found. */
inline NSUInteger ccCArrayGetIndexOfValue(ccCArray *arr, void* value);

/** Returns a Boolean value that indicates whether value is present in the C array. */
inline BOOL ccCArrayContainsValue(ccCArray *arr, void* value);

/** Inserts a value at a certain position. Behaviour undefined if aray doesn't have enough capacity */
inline void ccCArrayInsertValueAtIndex( ccCArray *arr, void *value, NSUInteger index);

/** Appends an value. Bahaviour undefined if array doesn't have enough capacity. */
inline void ccCArrayAppendValue(ccCArray *arr, void* value);

/** Appends an value. Capacity of arr is increased if needed. */
inline void ccCArrayAppendValueWithResize(ccCArray *arr, void* value);

/** Appends values from plusArr to arr. Behaviour undefined if arr doesn't have
 enough capacity. */
inline void ccCArrayAppendArray(ccCArray *arr, ccCArray *plusArr);

/** Appends values from plusArr to arr. Capacity of arr is increased if needed. */
inline void ccCArrayAppendArrayWithResize(ccCArray *arr, ccCArray *plusArr);

/** Removes all values from arr */
inline void ccCArrayRemoveAllValues(ccCArray *arr);

/** Removes value at specified index and pushes back all subsequent values.
 Behaviour undefined if index outside [0, num-1].
 @since v0.99.4
 */
inline void ccCArrayRemoveValueAtIndex(ccCArray *arr, NSUInteger index);

/** Removes value at specified index and fills the gap with the last value,
 thereby avoiding the need to push back subsequent values.
 Behaviour undefined if index outside [0, num-1].
 @since v0.99.4
 */
inline void ccCArrayFastRemoveValueAtIndex(ccCArray *arr, NSUInteger index);

/** Searches for the first occurance of value and removes it. If value is not found the function has no effect.
 @since v0.99.4
 */
inline void ccCArrayRemoveValue(ccCArray *arr, void* value);

/** Removes from arr all values in minusArr. For each Value in minusArr, the first matching instance in arr will be removed.
 @since v0.99.4
 */
inline void ccCArrayRemoveArray(ccCArray *arr, ccCArray *minusArr);

/** Removes from arr all values in minusArr. For each value in minusArr, all matching instances in arr will be removed.
 @since v0.99.4
 */
inline void ccCArrayFullRemoveArray(ccCArray *arr, ccCArray *minusArr);

#endif // CC_ARRAY_H