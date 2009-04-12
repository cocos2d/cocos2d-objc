/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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
 ccArray stores ids and retains/releases them appropriately.
 And it's way faster than NSMutableArray.
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
	ccArray *arr = (ccArray *) calloc(1, sizeof(ccArray));
	arr->num = 0;
	arr->arr = (id *) malloc( capacity * sizeof(id) );
	arr->max = capacity;
	
	return arr;
}

/** Frees array. Silently ignores nil values. */
static inline void ccArrayFree(ccArray *arr)
{
	if( arr == nil ) return;
	
	free(arr->arr);
	free(arr);
}

/** Doubles array capacity */
static inline void ccArrayDoubleCapacity(ccArray *arr)
{
	arr->max *= 2;
	arr->arr = (id *) realloc( arr->arr, arr->max * sizeof(id) );
}	

/** Appends a value. Bahaviour undefined if array doesn't have enough capacity. */
static inline void ccArrayAppendValue(ccArray *arr, id value)
{
	arr->arr[arr->num] = [value retain];
	arr->num++;
}

/** Returns index of first occurence of value, NSNotFound if value not found. */
static inline NSUInteger ccArrayGetIndexOfValue(ccArray *arr, id value)
{
	for( NSUInteger i = 0; i < arr->num; i++)
		if( arr->arr[i] == value ) return i;
	return NSNotFound;
}

/** Removes all values from arr */
static inline void ccArrayRemoveAllValues(ccArray *arr)
{
	while (arr->num > 0)
		[arr->arr[--arr->num] release]; 
}

/** Removes value at specified index and pushes back all subsequent values.
 Behaviour undefined if index outside [0, num-1]. */
static inline void ccArrayRemoveValueAtIndex(ccArray *arr, NSUInteger index)
{
	[arr->arr[index] release];
	
	for (NSUInteger last = --arr->num; index < last; index++)
		arr->arr[index] = arr->arr[index + 1];
}

/** Removes value at specified index and fills the gap with the last value,
 thereby avoiding the need to push back subsequent values.
 Behaviour undefined i index outside [0, num-1]. */
static inline void ccArrayFastRemoveValueAtIndex(ccArray *arr, NSUInteger index)
{
	[arr->arr[index] release];
	NSUInteger last = --arr->num;
	arr->arr[index] = arr->arr[last];
}

/** Searches for the first occurance of value and removes it. If value is not
 found the function has no effect. */
static inline void ccArrayRemoveValue(ccArray *arr, id value)
{
	NSUInteger index = ccArrayGetIndexOfValue(arr, value);
	if (index != NSNotFound)
		ccArrayRemoveValueAtIndex(arr, index);
}

static inline BOOL ccArrayContainsValue(ccArray *arr, id value)
{
	return ccArrayGetIndexOfValue(arr, value) != NSNotFound;
}

/** Removes from arr all values in minusArr. For each value in minusArr, the
 first matching instance in arr will be removed. */
static inline void ccArrayRemoveArray(ccArray *arr, ccArray *minusArr)
{
	for( NSUInteger i = 0; i < minusArr->num; i++)
		ccArrayRemoveValue(arr, minusArr->arr[i]);
}

/** Removes from arr all values in minusArr. For each value in minusArr, all
 matching instances in arr will be removed. */
static inline void ccArrayFullRemoveArray(ccArray *arr, ccArray *minusArr)
{
	NSUInteger back = 0;
	
	for( NSUInteger i = 0; i < arr->num; i++) {
		if( ccArrayContainsValue(minusArr, arr->arr[i]) ) {
			[arr->arr[i] release];
			back++;
		} else
			arr->arr[i - back] = arr->arr[i];
	}
	
	arr->num -= back;
}

/** Appends values from plusArr to arr. Capacity of arr is increased if needed. */
static inline void ccArrayAppendArrayWithResize(ccArray *arr, ccArray *plusArr)
{
	while (arr->max < arr->num + plusArr->num)
		ccArrayDoubleCapacity(arr);
	
	for( NSUInteger i = 0; i < plusArr->num; i++)
		ccArrayAppendValue(arr, plusArr->arr[i]);
}

#endif // CC_ARRAY_H
