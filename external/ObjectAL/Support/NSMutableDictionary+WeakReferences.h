//
//  NSMutableDictionary+WeakReferences.h
//
//  Created by Karl Stenerud on 12-09-06.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (WeakReferences)

/** Create an NSMutableDictionary that uses weak references.
 */
+ (NSMutableDictionary*) mutableDictionaryUsingWeakReferences;

/** Create an NSMutableDictionary that uses weak references.
 *
 * @param capacity The initial capacity of the dictionary.
 */
+ (NSMutableDictionary*) mutableDictionaryUsingWeakReferencesWithCapacity:(NSUInteger) capacity;

/** Create an NSMutableDictionary that uses weak references (no pending autorelease).
 */
+ (NSMutableDictionary*) newMutableDictionaryUsingWeakReferences;

/** Create an NSMutableDictionary that uses weak references (no pending autorelease).
 *
 * @param capacity The initial capacity of the dictionary.
 */
+ (NSMutableDictionary*) newMutableDictionaryUsingWeakReferencesWithCapacity:(NSUInteger) capacity;

@end
