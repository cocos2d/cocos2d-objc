//
//  MutableArray-WeakReferences.h
//
//  Created by Karl Stenerud on 05/12/09.
//

#import <Foundation/Foundation.h>


/**
 * Adds to NSMutableArray the ability to create an array that keeps weak references.
 */
@interface NSMutableArray (WeakReferences)

/** Create an NSMutableArray that uses weak references.
 */
+ (id) mutableArrayUsingWeakReferences;

/** Create an NSMutableArray that uses weak references.
 *
 * @param capacity The initial capacity of the array.
 */
+ (id) mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger) capacity;

/** Create an NSMutableArray that uses weak references (no pending autorelease).
 */
+ (id) newMutableArrayUsingWeakReferences;

/** Create an NSMutableArray that uses weak references (no pending autorelease).
 *
 * @param capacity The initial capacity of the array.
 */
+ (id) newMutableArrayUsingWeakReferencesWithCapacity:(NSUInteger) capacity;


@end
