
#import "ccCArray.h"

/** Allocates and initializes a new array with specified capacity */
ccArray* ccArrayNew(NSUInteger capacity) {
	if (capacity == 0)
		capacity = 1; 
	
	ccArray *arr = (ccArray*)malloc( sizeof(ccArray) );
	arr->num = 0;
	arr->arr =  (id*) malloc( capacity * sizeof(id) );
	arr->max = capacity;
	
	return arr;
}

/** Frees array after removing all remaining objects. Silently ignores nil arr. */
void ccArrayFree(ccArray *arr)
{
	if( arr == nil ) return;
	
	ccArrayRemoveAllObjects(arr);
	
	free(arr->arr);
	free(arr);
}

/** Doubles array capacity */
void ccArrayDoubleCapacity(ccArray *arr)
{
	arr->max *= 2;
	id *newArr = (id *)realloc( arr->arr, arr->max * sizeof(id) );
	// will fail when there's not enough memory
    NSCAssert(newArr != NULL, @"ccArrayDoubleCapacity failed. Not enough memory");
	arr->arr = newArr;
}

/** Increases array capacity such that max >= num + extra. */
void ccArrayEnsureExtraCapacity(ccArray *arr, NSUInteger extra)
{
	while (arr->max < arr->num + extra)
		ccArrayDoubleCapacity(arr);
}

/** shrinks the array so the memory footprint corresponds with the number of items */
void ccArrayShrink(ccArray *arr)
{
    NSUInteger newSize;
	
	//only resize when necessary
	if (arr->max > arr->num && !(arr->num==0 && arr->max==1))
	{
		if (arr->num!=0) 
		{
			newSize=arr->num;
			arr->max=arr->num; 
		}
		else 
		{//minimum capacity of 1, with 0 elements the array would be free'd by realloc
			newSize=1;
			arr->max=1;
		}
		
		arr->arr = (id*) realloc(arr->arr,newSize * sizeof(id) );
		NSCAssert(arr->arr!=NULL,@"could not reallocate the memory");
	}
} 

/** Returns index of first occurence of object, NSNotFound if object not found. */
NSUInteger ccArrayGetIndexOfObject(ccArray *arr, id object)
{
	for( NSUInteger i = 0; i < arr->num; i++)
		if( arr->arr[i] == object ) return i;
    
	return NSNotFound;
}

/** Returns a Boolean value that indicates whether object is present in array. */
BOOL ccArrayContainsObject(ccArray *arr, id object)
{
	return ccArrayGetIndexOfObject(arr, object) != NSNotFound;
}

/** Appends an object. Bahaviour undefined if array doesn't have enough capacity. */
void ccArrayAppendObject(ccArray *arr, id object)
{
	arr->arr[arr->num] = [object retain];
	arr->num++;
}

/** Appends an object. Capacity of arr is increased if needed. */
void ccArrayAppendObjectWithResize(ccArray *arr, id object)
{
	ccArrayEnsureExtraCapacity(arr, 1);
	ccArrayAppendObject(arr, object);
}

/** Appends objects from plusArr to arr. Behaviour undefined if arr doesn't have
 enough capacity. */
void ccArrayAppendArray(ccArray *arr, ccArray *plusArr)
{
	for( NSUInteger i = 0; i < plusArr->num; i++)
		ccArrayAppendObject(arr, plusArr->arr[i]);
}

/** Appends objects from plusArr to arr. Capacity of arr is increased if needed. */
void ccArrayAppendArrayWithResize(ccArray *arr, ccArray *plusArr)
{
	ccArrayEnsureExtraCapacity(arr, plusArr->num);
	ccArrayAppendArray(arr, plusArr);
}

/** Inserts an object at index */
void ccArrayInsertObjectAtIndex(ccArray *arr, id object, NSUInteger index)
{
	NSCAssert(index<=arr->num, @"Invalid index. Out of bounds");
	
	ccArrayEnsureExtraCapacity(arr, 1);
	
	NSUInteger remaining = arr->num - index;
	if( remaining > 0)
		memmove(&arr->arr[index+1], &arr->arr[index], sizeof(id) * remaining );
	
	arr->arr[index] = [object retain];
	arr->num++;
}

/** Swaps two objects */
void ccArraySwapObjectsAtIndexes(ccArray *arr, NSUInteger index1, NSUInteger index2)
{
	NSCAssert(index1 < arr->num, @"(1) Invalid index. Out of bounds");
	NSCAssert(index2 < arr->num, @"(2) Invalid index. Out of bounds");
	
	id object1 = arr->arr[index1];
    
	arr->arr[index1] = arr->arr[index2];
	arr->arr[index2] = object1;
}

/** Removes all objects from arr */
void ccArrayRemoveAllObjects(ccArray *arr)
{
	while( arr->num > 0 )
		[arr->arr[--arr->num] release]; 
}

/** Removes object at specified index and pushes back all subsequent objects.
 Behaviour undefined if index outside [0, num-1]. */
void ccArrayRemoveObjectAtIndex(ccArray *arr, NSUInteger index)
{
	[arr->arr[index] release];
	arr->num--;
	
	NSUInteger remaining = arr->num - index;
	if(remaining>0)
		memmove(&arr->arr[index], &arr->arr[index+1], remaining * sizeof(id));
}

/** Removes object at specified index and fills the gap with the last object,
 thereby avoiding the need to push back subsequent objects.
 Behaviour undefined if index outside [0, num-1]. */
void ccArrayFastRemoveObjectAtIndex(ccArray *arr, NSUInteger index)
{
	[arr->arr[index] release];
	NSUInteger last = --arr->num;
	arr->arr[index] = arr->arr[last];
}

void ccArrayFastRemoveObject(ccArray *arr, id object)
{
	NSUInteger index = ccArrayGetIndexOfObject(arr, object);
	if (index != NSNotFound)
		ccArrayFastRemoveObjectAtIndex(arr, index);
}

/** Searches for the first occurance of object and removes it. If object is not
 found the function has no effect. */
void ccArrayRemoveObject(ccArray *arr, id object)
{
	NSUInteger index = ccArrayGetIndexOfObject(arr, object);
	if (index != NSNotFound)
		ccArrayRemoveObjectAtIndex(arr, index);
}

/** Removes from arr all objects in minusArr. For each object in minusArr, the
 first matching instance in arr will be removed. */
void ccArrayRemoveArray(ccArray *arr, ccArray *minusArr)
{
	for( NSUInteger i = 0; i < minusArr->num; i++)
		ccArrayRemoveObject(arr, minusArr->arr[i]);
}

/** Removes from arr all objects in minusArr. For each object in minusArr, all
 matching instances in arr will be removed. */
void ccArrayFullRemoveArray(ccArray *arr, ccArray *minusArr)
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
void ccArrayMakeObjectsPerformSelector(ccArray *arr, SEL sel)
{
	for( NSUInteger i = 0; i < arr->num; i++)
		[arr->arr[i] performSelector:sel];
}

void ccArrayMakeObjectsPerformSelectorWithObject(ccArray *arr, SEL sel, id object)
{
	for( NSUInteger i = 0; i < arr->num; i++)
		[arr->arr[i] performSelector:sel withObject:object];
}


#pragma mark -
#pragma mark ccCArray for Values (c structures)

/** Allocates and initializes a new C array with specified capacity */
ccCArray* ccCArrayNew(NSUInteger capacity) {
	if (capacity == 0)
		capacity = 1; 
	
	ccCArray *arr = (ccCArray*)malloc( sizeof(ccCArray) );
	arr->num = 0;
	arr->arr =  (id*) malloc( capacity * sizeof(id) );
	arr->max = capacity;
	
	return arr;
}

/** Frees C array after removing all remaining values. Silently ignores nil arr. */
void ccCArrayFree(ccCArray *arr)
{
	if( arr == nil ) return;
	
	ccCArrayRemoveAllValues(arr);
	
	free(arr->arr);
	free(arr);
}

/** Doubles C array capacity */
void ccCArrayDoubleCapacity(ccCArray *arr)
{
	return ccArrayDoubleCapacity(arr);
}

/** Increases array capacity such that max >= num + extra. */
void ccCArrayEnsureExtraCapacity(ccCArray *arr, NSUInteger extra)
{
	return ccArrayEnsureExtraCapacity(arr,extra);
}

/** Returns index of first occurence of value, NSNotFound if value not found. */
NSUInteger ccCArrayGetIndexOfValue(ccCArray *arr, void* value)
{
	for( NSUInteger i = 0; i < arr->num; i++)
		if( arr->arr[i] == value ) return i;
	return NSNotFound;
}

/** Returns a Boolean value that indicates whether value is present in the C array. */
BOOL ccCArrayContainsValue(ccCArray *arr, void* value)
{
	return ccCArrayGetIndexOfValue(arr, value) != NSNotFound;
}

/** Inserts a value at a certain position. Behaviour undefined if aray doesn't have enough capacity */
void ccCArrayInsertValueAtIndex( ccCArray *arr, void *value, NSUInteger index)
{
	NSCAssert( index < arr->max, @"ccCArrayInsertValueAtIndex: invalid index");
	
	NSUInteger remaining = arr->num - index;
	
	// last Value doesn't need to be moved
	if( remaining > 0) {
		// tex coordinates
		memmove( &arr->arr[index+1],&arr->arr[index], sizeof(void*) * remaining );
	}
	
	arr->num++;	
	arr->arr[index] = (id) value;
}

/** Appends an value. Bahaviour undefined if array doesn't have enough capacity. */
void ccCArrayAppendValue(ccCArray *arr, void* value)
{
	arr->arr[arr->num] = (id) value;
	arr->num++;
}

/** Appends an value. Capacity of arr is increased if needed. */
void ccCArrayAppendValueWithResize(ccCArray *arr, void* value)
{
	ccCArrayEnsureExtraCapacity(arr, 1);
	ccCArrayAppendValue(arr, value);
}

/** Appends values from plusArr to arr. Behaviour undefined if arr doesn't have
 enough capacity. */
void ccCArrayAppendArray(ccCArray *arr, ccCArray *plusArr)
{
	for( NSUInteger i = 0; i < plusArr->num; i++)
		ccCArrayAppendValue(arr, plusArr->arr[i]);
}

/** Appends values from plusArr to arr. Capacity of arr is increased if needed. */
void ccCArrayAppendArrayWithResize(ccCArray *arr, ccCArray *plusArr)
{
	ccCArrayEnsureExtraCapacity(arr, plusArr->num);
	ccCArrayAppendArray(arr, plusArr);
}

/** Removes all values from arr */
void ccCArrayRemoveAllValues(ccCArray *arr)
{
	arr->num = 0;
}

/** Removes value at specified index and pushes back all subsequent values.
 Behaviour undefined if index outside [0, num-1].
 @since v0.99.4
 */
void ccCArrayRemoveValueAtIndex(ccCArray *arr, NSUInteger index)
{	
	for( NSUInteger last = --arr->num; index < last; index++)
		arr->arr[index] = arr->arr[index + 1];
}

/** Removes value at specified index and fills the gap with the last value,
 thereby avoiding the need to push back subsequent values.
 Behaviour undefined if index outside [0, num-1].
 @since v0.99.4
 */
void ccCArrayFastRemoveValueAtIndex(ccCArray *arr, NSUInteger index)
{
	NSUInteger last = --arr->num;
	arr->arr[index] = arr->arr[last];
}

/** Searches for the first occurance of value and removes it. If value is not found the function has no effect.
 @since v0.99.4
 */
void ccCArrayRemoveValue(ccCArray *arr, void* value)
{
	NSUInteger index = ccCArrayGetIndexOfValue(arr, value);
	if (index != NSNotFound)
		ccCArrayRemoveValueAtIndex(arr, index);
}

/** Removes from arr all values in minusArr. For each Value in minusArr, the first matching instance in arr will be removed.
 @since v0.99.4
 */
void ccCArrayRemoveArray(ccCArray *arr, ccCArray *minusArr)
{
	for( NSUInteger i = 0; i < minusArr->num; i++)
		ccCArrayRemoveValue(arr, minusArr->arr[i]);
}

/** Removes from arr all values in minusArr. For each value in minusArr, all matching instances in arr will be removed.
 @since v0.99.4
 */
void ccCArrayFullRemoveArray(ccCArray *arr, ccCArray *minusArr)
{
	NSUInteger back = 0;
	
	for( NSUInteger i = 0; i < arr->num; i++) {
		if( ccCArrayContainsValue(minusArr, arr->arr[i]) ) {
			back++;
		} else
			arr->arr[i - back] = arr->arr[i];
	}
	
	arr->num -= back;
}
