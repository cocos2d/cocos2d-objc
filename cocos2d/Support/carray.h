/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */
#import <Foundation/Foundation.h>

#import <stdlib.h>
#import <string.h>

/**
 @file
 Implements a C array in continguos memory.
 @since v0.8.2
 */

/** C array structure
 */
typedef struct CArray {
	NSUInteger num, max;
	void **arr;
} CArray;

/** Allocates and initializes a new array with specified capacity */
static inline CArray* CArrayNew(NSUInteger capacity) {
	CArray *arr = (CArray *) calloc(1, sizeof(CArray));
	arr->num = 0;
	arr->arr = (void **) malloc( capacity * sizeof(void *) );
	arr->max = capacity;
	
	return arr;
}

/** Frees array. Silently ignores nil values. */
static inline void CArrayFree(CArray *arr)
{
	if( arr == nil ) return;
	
	free(arr->arr);
	free(arr);
}

/** Doubles array capacity */
static inline void CArrayDoubleCapacity(CArray *arr)
{
	arr->max *= 2;
	arr->arr = (void **) realloc( arr->arr, arr->max * sizeof(void *) );
}	

/** Appends a value. Behaviour undefined if array doesn't have enough capacity. */
static inline void CArrayAppendValue(CArray *arr, void *value)
{
	arr->arr[arr->num] = value;
	arr->num++;
}

/** Inserts a value at a certain position. Behaviour undefined if aray doesn't have enough capacity */
static inline void CArrayInsertValueAtIndex( CArray *arr, void *value, NSUInteger index)
{
	int remaining = arr->num - index;
	
	// last object doesn't need to be moved
	if( remaining > 0) {
		// tex coordinates
		memmove( &arr->arr[index+1],&arr->arr[index], sizeof(void*) * remaining );
	}
	
	arr->num++;	
	arr->arr[index] = value;
}

/** Returns index of first occurence of value, NSNotFound if value not found. */
static inline NSUInteger CArrayGetIndexOfValue(CArray *arr, void *value)
{
	for( NSUInteger i = 0; i < arr->num; i++)
		if( arr->arr[i] == value ) return i;
	return NSNotFound;
}

/** Removes all values from arr */
static inline void CArrayRemoveAllValues(CArray *arr)
{
	arr->num = 0;
}

/** Removes value at specified index and pushes back all subsequent values.
 Behaviour undefined if index outside [0, num-1]. */
static inline void CArrayRemoveValueAtIndex(CArray *arr, NSUInteger index)
{
	for (NSUInteger last = --arr->num; index < last; index++)
		arr->arr[index] = arr->arr[index + 1];
}

/** Removes value at specified index and fills the gap with the last value,
 thereby avoiding the need to push back subsequent values.
 Behaviour undefined i index outside [0, num-1]. */
static inline void CArrayFastRemoveValueAtIndex(CArray *arr, NSUInteger index)
{
	NSUInteger last = --arr->num;
	arr->arr[index] = arr->arr[last];
}

/** Searches for the first occurance of value and removes it. If value is not
 found the function has no effect. */
static inline void CArrayRemoveValue(CArray *arr, void *value)
{
	NSUInteger index = CArrayGetIndexOfValue(arr, value);
	if( index != NSNotFound )
		CArrayRemoveValueAtIndex(arr, index);
}

static inline BOOL CArrayContainsValue(CArray *arr, void *value)
{
	return CArrayGetIndexOfValue(arr, value) != NSNotFound;
}

/** Removes from arr all values in minusArr. For each value in minusArr, the
 first matching instance in arr will be removed. */
static inline void CArrayRemoveArray(CArray *arr, CArray *minusArr)
{
	for( NSUInteger i = 0; i < minusArr->num; i++)
		CArrayRemoveValue(arr, minusArr->arr[i]);
}

/** Removes from arr all values in minusArr. For each value in minusArr, all
 matching instances in arr will be removed. */
static inline void CArrayFullRemoveArray(CArray *arr, CArray *minusArr)
{
	NSUInteger back = 0;
	
	for( NSUInteger i = 0; i < arr->num; i++) {
		if( CArrayContainsValue(minusArr, arr->arr[i]) )
			back++;
		else
			arr->arr[i - back] = arr->arr[i];
	}
	
	arr->num -= back;
}

/** Appends values from plusArr to arr. Capacity of arr is increased if needed. */
static inline void CArrayAppendArrayWithResize(CArray *arr, CArray *plusArr)
{
	while (arr->max < arr->num + plusArr->num)
		CArrayDoubleCapacity(arr);
	
	for( NSUInteger i = 0; i < plusArr->num; i++)
		CArrayAppendValue(arr, plusArr->arr[i]);
}

#define C_ARRAY_EACH(ARR, FUNC) \
{ \
	for( NSUInteger i = 0; i < ARR->num; i++) \
		FUNC( ARR->arr[i] ); \
}
