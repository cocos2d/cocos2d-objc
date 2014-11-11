//
//  MutableArray-WeakReferences.m
//
//  Created by Karl Stenerud on 05/12/09.
//

#import "NSMutableArray+WeakReferences.h"


#if __has_feature(objc_arc)
    #define as_autorelease(X)        (X)
    #define as_bridge_transfer       __bridge_transfer
#else
    #define as_autorelease(X)       [(X) autorelease]
    #define as_bridge_transfer
#endif

@implementation NSMutableArray (WeakReferences)

+ (id) newMutableArrayUsingWeakReferencesWithCapacity:(NSUInteger) capacity
{
	CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
	return (as_bridge_transfer id)CFArrayCreateMutable(NULL,
                                                       (CFIndex)capacity,
                                                       &callbacks);
}

+ (id) newMutableArrayUsingWeakReferences
{
	return [self newMutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (id) mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger) capacity
{
    return as_autorelease([self newMutableArrayUsingWeakReferencesWithCapacity:capacity]);
}

+ (id) mutableArrayUsingWeakReferences
{
	return [self mutableArrayUsingWeakReferencesWithCapacity:0];
}

@end

#define FIX_CATEGORY_BUG(name) @interface FIX_CATEGORY_BUG_##name : NSObject @end @implementation FIX_CATEGORY_BUG_##name @end


FIX_CATEGORY_BUG(NSMutableArray_WeakReferences);
