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


#include <stdlib.h>
#include <assert.h>
#include <stdio.h>

#import "ccHashSet.h"
 
// Used for resizing hash tables.
// Values approximately double.

static int primes[] = {
	5,          //2^2  + 1
	11,         //2^3  + 3
	17,         //2^4  + 1
	37,         //2^5  + 5
	67,         //2^6  + 3
	131,        //2^7  + 3
	257,        //2^8  + 1
	521,        //2^9  + 9
	1031,       //2^10 + 7
	2053,       //2^11 + 5
	4099,       //2^12 + 3
	8209,       //2^13 + 17
	16411,      //2^14 + 27
	32771,      //2^15 + 3
	65537,      //2^16 + 1
	131101,     //2^17 + 29
	262147,     //2^18 + 3
	524309,     //2^19 + 21
	1048583,    //2^20 + 7
	2097169,    //2^21 + 17
	4194319,    //2^22 + 15
	8388617,    //2^23 + 9
	16777259,   //2^24 + 43
	33554467,   //2^25 + 35
	67108879,   //2^26 + 15
	134217757,  //2^27 + 29
	268435459,  //2^28 + 3
	536870923,  //2^29 + 11
	1073741827, //2^30 + 3
	0,
};

static int
next_prime(int n)
{
	int i = 0;
	while(n > primes[i]){
		i++;
		assert(primes[i]); // realistically this should never happen
	}
	
	return primes[i];
}

unsigned int cc_hash_sax( void *key, int len )
{
	unsigned char *p = key;
	unsigned int h = 0;
	int i;
	for ( i = 0; i < len; i++ )
		h ^= ( h << 5 ) + ( h >> 2 ) + p[i];
	
	return h;
}
unsigned int cc_hash_oat ( void *key, int len )
{
	unsigned char *p = key;
	unsigned int h = 0;
	int i;
	
	for ( i = 0; i < len; i++ ) {
		h += p[i];
		h += ( h << 10 );
		h ^= ( h >> 6 );
	}
	h += ( h << 3 );
	h ^= ( h >> 11 );
	h += ( h << 15 );
	return h;
}

void
ccHashSetDestroy(ccHashSet *set)
{
	// Free the chains.
	for(int i=0; i<set->size; i++){
		// Free the bins in the chain.
		ccHashSetBin *bin = set->table[i];
		while(bin){
			ccHashSetBin *next = bin->next;
			free(bin);
			bin = next;
		}
	}
	
	// Free the table.
	free(set->table);
}

void
ccHashSetFree(ccHashSet *set)
{
	if(set) ccHashSetDestroy(set);
	free(set);
}

ccHashSet *
ccHashSetAlloc(void)
{
	return (ccHashSet *)calloc(1, sizeof(ccHashSet));
}

ccHashSet *
ccHashSetInit(ccHashSet *set, int size, ccHashSetEqlFunc eqlFunc)
{
	set->size = next_prime(size);
	set->entries = 0;
	
	set->eql = eqlFunc;
	
	set->default_value = NULL;
	
	set->table = (ccHashSetBin **)calloc(set->size, sizeof(ccHashSetBin *));
	
	return set;
}

ccHashSet *
ccHashSetNew(int size, ccHashSetEqlFunc eqlFunc)
{
	return ccHashSetInit(ccHashSetAlloc(), size, eqlFunc);
}

static int
setIsFull(ccHashSet *set)
{
	return (set->entries >= set->size * 3.0f);
}

static void
ccHashSetResize(ccHashSet *set)
{
	// Get the next approximate doubled prime.
	int newSize = next_prime(set->size + 1);
	// Allocate a new table.
	ccHashSetBin **newTable = (ccHashSetBin **)calloc(newSize, sizeof(ccHashSetBin *));
	
	// Iterate over the chains.
	for(int i=0; i<set->size; i++){
		// Rehash the bins into the new table.
		ccHashSetBin *bin = set->table[i];
		while(bin){
			ccHashSetBin *next = bin->next;
			
			int index = bin->hash%newSize;
			bin->next = newTable[index];
			newTable[index] = bin;
			
			bin = next;
		}
	}
	
	free(set->table);
	
	set->table = newTable;
	set->size = newSize;
}

void *
ccHashSetInsert(ccHashSet *set, unsigned int hash, void *ptr, void *data)
{
	int index = hash%set->size;
	
	// Find the bin with the matching element.
	ccHashSetBin *bin = set->table[index];
	while(bin && !set->eql(ptr, bin->elt))
		bin = bin->next;
	
	// Create it necessary.
	if(!bin){
		bin = (ccHashSetBin *)malloc(sizeof(ccHashSetBin));
		bin->hash = hash;
		bin->elt = ptr;
		
		bin->next = set->table[index];
		set->table[index] = bin;
		
		set->entries++;
		
		// Resize the set if it's full.
		if(setIsFull(set))
			ccHashSetResize(set);
	}
	
	return bin->elt;
}

void *
ccHashSetRemove(ccHashSet *set, unsigned int hash, void *ptr)
{
	int index = hash%set->size;
	
	// Pointer to the previous bin pointer.
	ccHashSetBin **prev_ptr = &set->table[index];
	// Pointer the the current bin.
	ccHashSetBin *bin = set->table[index];
	
	// Find the bin
	while(bin && !set->eql(ptr, bin->elt)){
		prev_ptr = &bin->next;
		bin = bin->next;
	}
	
	// Remove it if it exists.
	if(bin){
		// Update the previos bin pointer to point to the next bin.
		(*prev_ptr) = bin->next;
		set->entries--;
		
		void *return_value = bin->elt;
		free(bin);
		return return_value;
	}
	
	return NULL;
}

void *
ccHashSetFind(ccHashSet *set, unsigned int hash, void *ptr)
{	
	int index = hash%set->size;

//	printf("bucket index: %3d - %x\n", index, hash);
	ccHashSetBin *bin = set->table[index];
	while(bin && !set->eql(ptr, bin->elt))
		bin = bin->next;
		
	return (bin ? bin->elt : set->default_value);
}

void
ccHashSetEach(ccHashSet *set, ccHashSetIterFunc func, void *data)
{
	for(int i=0; i<set->size; i++){
		ccHashSetBin *bin;
		for(bin = set->table[i]; bin; bin = bin->next)
			func(bin->elt, data);
	}
}

void
ccHashSetReject(ccHashSet *set, ccHashSetRejectFunc func, void *data)
{
	// Iterate over all the chains.
	for(int i=0; i<set->size; i++){
		// The rest works similarly to ccHashSetRemove() above.
		ccHashSetBin **prev_ptr = &set->table[i];
		ccHashSetBin *bin = set->table[i];
		while(bin){
			ccHashSetBin *next = bin->next;
			
			if(func(bin->elt, data)){
				prev_ptr = &bin->next;
			} else {
				(*prev_ptr) = next;

				set->entries--;
				free(bin);
			}
			
			bin = next;
		}
	}
}
