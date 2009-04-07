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

/* Based on Chipmunk cpArray.
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

static inline ccArray* ccArrayNew(NSUInteger size) {
	ccArray *arr = (ccArray *) calloc(1, sizeof(ccArray));
	arr->num = 0;
	arr->arr = (id *) malloc( size * sizeof(id) );
	arr->max = size;
	
	return arr;
}

static inline void ccArrayFree(ccArray *arr)
{
	if( arr == nil ) return;
	
	free(arr->arr);
	free(arr);
}

static inline void ccArrayDoubleCapacity(ccArray *arr)
{
	arr->max *= 2;
	arr->arr = (id *) realloc( arr->arr, arr->max * sizeof(id) );
}	

static inline void ccArrayDumbCopy(ccArray *dest, ccArray *src)
{
	memcpy(dest, src, src->num * sizeof(id));
	dest->num = src->num;
}

// Make sure you have enough capacity before adding another value.
static inline void ccArrayAppendValue(ccArray *arr, id value)
{
	arr->arr[arr->num] = [value retain];
	arr->num++;
}

static inline NSUInteger ccArrayGetIndexOfValue(ccArray *arr, id value)
{
	for( NSUInteger i = 0; i < arr->num; i++)
		if( arr->arr[i] == value ) return i;
	return NSNotFound;
}

static inline void ccArrayRemoveAllValues(ccArray *arr)
{
	while (arr->num > 0)
		[arr->arr[--arr->num] release]; 
}

static inline void ccArrayRemoveValueAtIndex(ccArray *arr, NSUInteger index)
{
	[arr->arr[index] release];
	NSUInteger last = --arr->num;
	while( index < last )
		arr->arr[index] = arr->arr[++index];
}

static inline void ccArrayFastRemoveValueAtIndex(ccArray *arr, NSUInteger index)
{
	[arr->arr[index] release];
	NSUInteger last = --arr->num;
	arr->arr[index] = arr->arr[last];
}

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

#endif // CC_ARRAY_H
