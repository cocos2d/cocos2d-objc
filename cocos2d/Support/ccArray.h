/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

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
 */

#ifndef CC_ARRAY_H
#define CC_ARRAY_H

#import <Foundation/Foundation.h>

#import <stdlib.h>
#import <string.h>

typedef struct ccArray {
	NSUInteger num, max;
	id *arr;
} ccArray;

/** Allocates and initializes a new array with specified capacity */
static inline ccArray* ccArrayNew(NSUInteger capacity) {
	if (capacity == 0)
		capacity = 1; 
	
	ccArray *arr = (ccArray*)malloc( sizeof(ccArray) );
	arr->num = 0;
	arr->arr =  (id*) malloc( capacity * sizeof(id) );
	arr->max = capacity;
	
	return arr;
}

static inline void ccArrayRemoveAllObjects(ccArray *arr);

/** Frees array after removing all remaining objects. Silently ignores nil arr. */
static inline void ccArrayFree(ccArray *arr)
{
	if( arr == nil ) return;
	
	ccArrayRemoveAllObjects(arr);
	
	free(arr->arr);
	free(arr);
}

/** Doubles array capacity */
static inline void ccArrayDoubleCapacity(ccArray *arr)
{
	arr->max *= 2;
	arr->arr = (id*) realloc( arr->arr, arr->max * sizeof(id) );
}

/** Increases array capacity such that max >= num + extra. */
static inline void ccArrayEnsureExtraCapacity(ccArray *arr, NSUInteger extra)
{
	while (arr->max < arr->num + extra)
		ccArrayDoubleCapacity(arr);
}

/** Returns index of first occurence of object, NSNotFound if object not found. */
static inline NSUInteger ccArrayGetIndexOfObject(ccArray *arr, id object)
{
	for( NSUInteger i = 0; i < arr->num; i++)
		if( arr->arr[i] == object ) return i;
	return NSNotFound;
}

/** Returns a Boolean value that indicates whether object is present in array. */
static inline BOOL ccArrayContainsObject(ccArray *arr, id object)
{
	return ccArrayGetIndexOfObject(arr, object) != NSNotFound;
}

/** Appends an object. Bahaviour undefined if array doesn't have enough capacity. */
static inline void ccArrayAppendObject(ccArray *arr, id object)
{
	arr->arr[arr->num] = [object retain];
	arr->num++;
}

/** Appends an object. Capacity of arr is increased if needed. */
static inline void ccArrayAppendObjectWithResize(ccArray *arr, id object)
{
	ccArrayEnsureExtraCapacity(arr, 1);
	ccArrayAppendObject(arr, object);
}

/** Appends objects from plusArr to arr. Behaviour undefined if arr doesn't have
 enough capacity. */
static inline void ccArrayAppendArray(ccArray *arr, ccArray *plusArr)
{
	for( NSUInteger i = 0; i < plusArr->num; i++)
		ccArrayAppendObject(arr, plusArr->arr[i]);
}

/** Appends objects from plusArr to arr. Capacity of arr is increased if needed. */
static inline void ccArrayAppendArrayWithResize(ccArray *arr, ccArray *plusArr)
{
	ccArrayEnsureExtraCapacity(arr, plusArr->num);
	ccArrayAppendArray(arr, plusArr);
}

/** Removes all objects from arr */
static inline void ccArrayRemoveAllObjects(ccArray *arr)
{
	while( arr->num > 0 )
		[arr->arr[--arr->num] release]; 
}

/** Removes object at specified index and pushes back all subsequent objects.
 Behaviour undefined if index outside [0, num-1]. */
static inline void ccArrayRemoveObjectAtIndex(ccArray *arr, NSUInteger index)
{
	[arr->arr[index] release];
	
	for( NSUInteger last = --arr->num; index < last; index++)
		arr->arr[index] = arr->arr[index + 1];
}

/** Removes object at specified index and fills the gap with the last object,
 thereby avoiding the need to push back subsequent objects.
 Behaviour undefined if index outside [0, num-1]. */
static inline void ccArrayFastRemoveObjectAtIndex(ccArray *arr, NSUInteger index)
{
	[arr->arr[index] release];
	NSUInteger last = --arr->num;
	arr->arr[index] = arr->arr[last];
}

/** Searches for the first occurance of object and removes it. If object is not
 found the function has no effect. */
static inline void ccArrayRemoveObject(ccArray *arr, id object)
{
	NSUInteger index = ccArrayGetIndexOfObject(arr, object);
	if (index != NSNotFound)
		ccArrayRemoveObjectAtIndex(arr, index);
}

/** Removes from arr all objects in minusArr. For each object in minusArr, the
 first matching instance in arr will be removed. */
static inline void ccArrayRemoveArray(ccArray *arr, ccArray *minusArr)
{
	for( NSUInteger i = 0; i < minusArr->num; i++)
		ccArrayRemoveObject(arr, minusArr->arr[i]);
}

/** Removes from arr all objects in minusArr. For each object in minusArr, all
 matching instances in arr will be removed. */
static inline void ccArrayFullRemoveArray(ccArray *arr, ccArray *minusArr)
{
	NSUInteger back = 0;
	
	for( NSUInteger i = 0; i < arr->num; i++) {
		if( ccArrayContainsObject(minusArr, arr->arr[i]) ) {
			[arr->arr[i] release];
			back++;
		} else
			arr->arr[i - back] = arr->arr[i];
	}
	
	arr->num -= back;
}

/** Sends to each object in arr the message identified by given selector. */
static inline void ccArrayMakeObjectsPerformSelector(ccArray *arr, SEL sel)
{
	for( NSUInteger i = 0; i < arr->num; i++)
		[arr->arr[i] performSelector:sel];
}

#endif // CC_ARRAY_H
