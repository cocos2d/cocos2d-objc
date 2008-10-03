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
#include <stdio.h>
#include <math.h>
#include <assert.h>

#include "chipmunk.h"
#include "prime.h"

static cpHandle*
cpHandleAlloc(void)
{
	return (cpHandle *)malloc(sizeof(cpHandle));
}

static cpHandle*
cpHandleInit(cpHandle *hand, void *obj)
{
	hand->obj = obj;
	hand->retain = 0;
	hand->stamp = 0;
	
	return hand;
}

static cpHandle*
cpHandleNew(void *obj)
{
	return cpHandleInit(cpHandleAlloc(), obj);
}

static inline void
cpHandleRetain(cpHandle *hand)
{
	hand->retain++;
}

static inline void
cpHandleFree(cpHandle *hand)
{
	free(hand);
}

static inline void
cpHandleRelease(cpHandle *hand)
{
	hand->retain--;
	if(hand->retain == 0)
		cpHandleFree(hand);
}


cpSpaceHash*
cpSpaceHashAlloc(void)
{
	return (cpSpaceHash *)calloc(1, sizeof(cpSpaceHash));
}

// Frees the old table, and allocates a new one.
static void
cpSpaceHashAllocTable(cpSpaceHash *hash, int numcells)
{
	free(hash->table);
	
	hash->numcells = numcells;
	hash->table = (cpSpaceHashBin **)calloc(numcells, sizeof(cpSpaceHashBin *));
}

// Equality function for the handleset.
static int
handleSetEql(void *obj, void *elt)
{
	cpHandle *hand = (cpHandle *)elt;
	return (obj == hand->obj);
}

// Transformation function for the handleset.
static void *
handleSetTrans(void *obj, void *unused)
{
	cpHandle *hand = cpHandleNew(obj);
	cpHandleRetain(hand);
	
	return hand;
}

cpSpaceHash*
cpSpaceHashInit(cpSpaceHash *hash, cpFloat celldim, int numcells, cpSpaceHashBBFunc bbfunc)
{
	cpSpaceHashAllocTable(hash, next_prime(numcells));
	hash->celldim = celldim;
	hash->bbfunc = bbfunc;
	
	hash->bins = NULL;
	hash->handleSet = cpHashSetNew(0, &handleSetEql, &handleSetTrans);
	
	hash->stamp = 1;
	
	return hash;
}

cpSpaceHash*
cpSpaceHashNew(cpFloat celldim, int cells, cpSpaceHashBBFunc bbfunc)
{
	return cpSpaceHashInit(cpSpaceHashAlloc(), celldim, cells, bbfunc);
}

static inline void
clearHashCell(cpSpaceHash *hash, int index)
{
	cpSpaceHashBin *bin = hash->table[index];
	while(bin){
		cpSpaceHashBin *next = bin->next;
		
		// Release the lock on the handle.
		cpHandleRelease(bin->handle);
		// Recycle the bin.
		bin->next = hash->bins;
		hash->bins = bin;
		
		bin = next;
	}
	
	hash->table[index] = NULL;
}

// Clear all cells in the hashtable.
static void
clearHash(cpSpaceHash *hash)
{
	for(int i=0; i<hash->numcells; i++)
		clearHashCell(hash, i);
}

// Free the recycled hash bins.
static void
freeBins(cpSpaceHash *hash)
{
	cpSpaceHashBin *bin = hash->bins;
	while(bin){
		cpSpaceHashBin *next = bin->next;
		free(bin);
		bin = next;
	}
}

// Hashset iterator function to free the handles.
static void
handleFreeWrap(void *elt, void *unused)
{
	cpHandle *hand = (cpHandle *)elt;
	cpHandleFree(hand);
}

void
cpSpaceHashDestroy(cpSpaceHash *hash)
{
	clearHash(hash);
	freeBins(hash);
	
	// Free the handles.
	cpHashSetEach(hash->handleSet, &handleFreeWrap, NULL);
	cpHashSetFree(hash->handleSet);
	
	free(hash->table);
}

void
cpSpaceHashFree(cpSpaceHash *hash)
{
	if(!hash) return;
	cpSpaceHashDestroy(hash);
	free(hash);
}

void
cpSpaceHashResize(cpSpaceHash *hash, cpFloat celldim, int numcells)
{
	// Clear the hash to release the old handle locks.
	clearHash(hash);
	
	hash->celldim = celldim;
	cpSpaceHashAllocTable(hash, next_prime(numcells));
}

// Return true if the chain contains the handle.
static inline int
containsHandle(cpSpaceHashBin *bin, cpHandle *hand)
{
	while(bin){
		if(bin->handle == hand) return 1;
		bin = bin->next;
	}
	
	return 0;
}

// Get a recycled or new bin.
static inline cpSpaceHashBin *
getEmptyBin(cpSpaceHash *hash)
{
	cpSpaceHashBin *bin = hash->bins;
	
	// Make a new one if necessary.
	if(bin == NULL) return (cpSpaceHashBin *)malloc(sizeof(cpSpaceHashBin));

	hash->bins = bin->next;
	return bin;
}

// The hash function itself.
static inline unsigned int
hash_func(unsigned int x, unsigned int y, unsigned int n)
{
	return (x*2185031351ul ^ y*4232417593ul) % n;
}

static inline void
hashHandle(cpSpaceHash *hash, cpHandle *hand, cpBB bb)
{
	// Find the dimensions in cell coordinates.
	cpFloat dim = hash->celldim;
	int l = bb.l/dim;
	int r = bb.r/dim;
	int b = bb.b/dim;
	int t = bb.t/dim;
	
	int n = hash->numcells;
	for(int i=l; i<=r; i++){
		for(int j=b; j<=t; j++){
			int index = hash_func(i,j,n);
			cpSpaceHashBin *bin = hash->table[index];
			
			// Don't add an object twice to the same cell.
			if(containsHandle(bin, hand)) continue;

			cpHandleRetain(hand);
			// Insert a new bin for the handle in this cell.
			cpSpaceHashBin *newBin = getEmptyBin(hash);
			newBin->handle = hand;
			newBin->next = bin;
			hash->table[index] = newBin;
		}
	}
}

void
cpSpaceHashInsert(cpSpaceHash *hash, void *obj, unsigned int id, cpBB bb)
{
	cpHandle *hand = (cpHandle *)cpHashSetInsert(hash->handleSet, id, obj, NULL);
	hashHandle(hash, hand, bb);
}

void
cpSpaceHashRehashObject(cpSpaceHash *hash, void *obj, unsigned int id)
{
	cpHandle *hand = (cpHandle *)cpHashSetFind(hash->handleSet, id, obj);
	hashHandle(hash, hand, hash->bbfunc(obj));
}

// Hashset iterator function for rehashing the spatial hash. (hash hash hash hash?)
static void
handleRehashHelper(void *elt, void *data)
{
	cpHandle *hand = (cpHandle *)elt;
	cpSpaceHash *hash = (cpSpaceHash *)data;
	
	hashHandle(hash, hand, hash->bbfunc(hand->obj));
}

void
cpSpaceHashRehash(cpSpaceHash *hash)
{
	clearHash(hash);
	
	// Rehash all of the handles.
	cpHashSetEach(hash->handleSet, &handleRehashHelper, hash);
}

void
cpSpaceHashRemove(cpSpaceHash *hash, void *obj, unsigned int id)
{
	cpHandle *hand = (cpHandle *)cpHashSetRemove(hash->handleSet, id, obj);
	
	if(hand){
		hand->obj = NULL;
		cpHandleRelease(hand);
	}
}

// Used by the cpSpaceHashEach() iterator.
typedef struct eachPair {
	cpSpaceHashIterator func;
	void *data;
} eachPair;

// Calls the user iterator function. (Gross I know.)
static void
eachHelper(void *elt, void *data)
{
	cpHandle *hand = (cpHandle *)elt;
	eachPair *pair = (eachPair *)data;
	
	pair->func(hand->obj, pair->data);
}

// Iterate over the objects in the spatial hash.
void
cpSpaceHashEach(cpSpaceHash *hash, cpSpaceHashIterator func, void *data)
{
	// Bundle the callback up to send to the hashset iterator.
	eachPair pair = {func, data};
	
	cpHashSetEach(hash->handleSet, &eachHelper, &pair);
}

// Calls the callback function for the objects in a given chain.
static inline void
query(cpSpaceHash *hash, cpSpaceHashBin *bin, void *obj, cpSpaceHashQueryFunc func, void *data)
{
	for(; bin; bin = bin->next){
		cpHandle *hand = bin->handle;
		void *other = hand->obj;
		
		// Skip over certain conditions
		if(
			// Have we already tried this pair in this query?
			hand->stamp == hash->stamp
			// Is obj the same as other?
			|| obj == other 
			// Has other been removed since the last rehash?
			|| !other
			) continue;
		
		func(obj, other, data);

		// Stamp that the handle was checked already against this object.
		hand->stamp = hash->stamp;
	}
}

void
cpSpaceHashPointQuery(cpSpaceHash *hash, cpVect point, cpSpaceHashQueryFunc func, void *data)
{
	cpFloat dim = hash->celldim;
	int index = hash_func((int)(point.x/dim), (int)(point.y/dim), hash->numcells);
	
	query(hash, hash->table[index], &point, func, data);

	// Increment the stamp.
	// Only one cell is checked, but query() requires it anyway.
	hash->stamp++;
}

void
cpSpaceHashQuery(cpSpaceHash *hash, void *obj, cpBB bb, cpSpaceHashQueryFunc func, void *data)
{
	// Get the dimensions in cell coordinates.
	cpFloat dim = hash->celldim;
	int l = bb.l/dim;
	int r = bb.r/dim;
	int b = bb.b/dim;
	int t = bb.t/dim;
	
	int n = hash->numcells;
	
	// Iterate over the cells and query them.
	for(int i=l; i<=r; i++){
		for(int j=b; j<=t; j++){
			int index = hash_func(i,j,n);
			query(hash, hash->table[index], obj, func, data);
		}
	}
	
	// Increment the stamp.
	hash->stamp++;
}

// Similar to struct eachPair above.
typedef struct queryRehashPair {
	cpSpaceHash *hash;
	cpSpaceHashQueryFunc func;
	void *data;
} queryRehashPair;

// Hashset iterator func used with cpSpaceHashQueryRehash().
static void
handleQueryRehashHelper(void *elt, void *data)
{
	cpHandle *hand = (cpHandle *)elt;
	
	// Unpack the user callback data.
	queryRehashPair *pair = (queryRehashPair *)data;
	cpSpaceHash *hash = pair->hash;
	cpSpaceHashQueryFunc func = pair->func;

	cpFloat dim = hash->celldim;
	int n = hash->numcells;

	void *obj = hand->obj;
	cpBB bb = hash->bbfunc(obj);

	int l = bb.l/dim;
	int r = bb.r/dim;
	int b = bb.b/dim;
	int t = bb.t/dim;

	for(int i=l; i<=r; i++){
		for(int j=b; j<=t; j++){
			int index = hash_func(i,j,n);
			cpSpaceHashBin *bin = hash->table[index];
			
			if(containsHandle(bin, hand)) continue;
			query(hash, bin, obj, func, pair->data);
			
			cpHandleRetain(hand);
			cpSpaceHashBin *newBin = getEmptyBin(hash);
			newBin->handle = hand;
			newBin->next = bin;
			hash->table[index] = newBin;
		}
	}
	
	// Increment the stamp for each object we hash.
	hash->stamp++;
}

void
cpSpaceHashQueryRehash(cpSpaceHash *hash, cpSpaceHashQueryFunc func, void *data)
{
	clearHash(hash);

	queryRehashPair pair = {hash, func, data};
	cpHashSetEach(hash->handleSet, &handleQueryRehashHelper, &pair);
}
