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
 
// ccHashSet uses a chained hashtable implementation.

#ifndef __CC_HASH_SET_H
#define __CC_HASH_SET_H

#ifdef __cplusplus
extern "C" {
#endif	
	

/** 
 @file
 Based on Chipmunk cpHashSet.
 ccHashSet is a faster alternative to NSMutableDictionary. The main difference between ccHashSet and NSDictionary
 is that ccHashSet uses pointers, while NSMutableDictionary uses NSObject.
 ccHashSet is faster because:
 - it uses a plain C interface so it doesn't incur Objective-c messaging overhead 
 - it assumes you know what you're doing, so it doesn't spend time on safety checks
 (index out of bounds, required capacity etc.)
 - comparisons are done using pointer equality instead of isEqual
 
 If you use the CC_HASH_INT, it will use the One-At-A-Time hash function.
 When the number of entries of the ccHashSet are greater than the size * 3 of the ccHashSet, then the ccHashSet size will be doubled.
 Ideally, the ccHashSet will have no more than 3 entries per hash value.
 */


/** Performs the Shift-Add-Xor hash function
*/
unsigned int cc_hash_sax ( void *key, int len );
 
/** Performns the One-At-a-time hash function
 */
unsigned int cc_hash_oat ( void *key, int len );

#define CC_HASH_INT(A) cc_hash_oat(&A,sizeof(A))

// ccHashSetBin's form the linked lists in the chained hash table.
typedef struct ccHashSetBin {
	// Pointer to the element.
	void *elt;
	// Hash value of the element.
	unsigned int hash;
	// Next element in the chain.
	struct ccHashSetBin *next;
} ccHashSetBin;

// Equality function. Returns true if ptr is equal to elt.
typedef int (*ccHashSetEqlFunc)(void *ptr, void *elt);
// Iterator function for a hashset.
typedef void (*ccHashSetIterFunc)(void *elt, void *data);
// Reject function. Returns true if elt should be dropped.
typedef int (*ccHashSetRejectFunc)(void *elt, void *data);

/** ccHashSet type */
typedef struct ccHashSet {
	// Number of elements stored in the table.
	int entries;
	// Number of cells in the table.
	int size;
	
	ccHashSetEqlFunc eql;
	
	// Default value returned by ccHashSetFind() when no element is found.
	// Defaults to NULL.
	void *default_value;
	
	ccHashSetBin **table;
} ccHashSet;

/** Destroy the ccHashSet */
void ccHashSetDestroy(ccHashSet *set);
/** Free the ccHashSet */
void ccHashSetFree(ccHashSet *set);

/** Allocates the ccHashSet */
ccHashSet *ccHashSetAlloc(void);
/** Initializes the ccHashSet with a size and a equal function */
ccHashSet *ccHashSetInit(ccHashSet *set, int size, ccHashSetEqlFunc eqlFunc);
/** Allocates and initialize a ccHashSet with a size and a equal function */
ccHashSet *ccHashSetNew(int size, ccHashSetEqlFunc eqlFunc);

/** Insert an element into the set, returns the element.
If it doesn't already exist, the transformation function is applied.
 */
void *ccHashSetInsert(ccHashSet *set, unsigned int hash, void *ptr, void *data);
/** Remove and return an element from the set.
 */
void *ccHashSetRemove(ccHashSet *set, unsigned int hash, void *ptr);
/** Find an element in the set. Returns the default value if the element isn't found.
 */
void *ccHashSetFind(ccHashSet *set, unsigned int hash, void *ptr);

/** Iterate over a hashset.
 */
void ccHashSetEach(ccHashSet *set, ccHashSetIterFunc func, void *data);
/** Iterate over a hashset while rejecting certain elements.
 */
void ccHashSetReject(ccHashSet *set, ccHashSetRejectFunc func, void *data);
	
#ifdef __cplusplus
}
#endif	

#endif // __CC_HASH_SET_H

