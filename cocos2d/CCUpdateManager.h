/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <Foundation/Foundation.h>
#import "ccTypes.h"
#import "CCNode.h"

//
// CCUpdateBucket
//
/** Maintains a list of CCNodes that have requested update
 */
@interface CCUpdateBucket : NSObject {
	NSInteger					priority;
	NSMutableArray*		updateRequests;
}

@property (nonatomic,readwrite) NSInteger priority;

-(id) initWithPriority:(NSInteger) aPriority;
-(void) requestUpdatesFor:(CCNode*) aNode;
-(BOOL) cancelUpdatesFor:(CCNode*) aNode;
-(void) update:(ccTime) dt;

@end


//
// CCUpdateManager
//
/** CCUpdateManager is a singleton that manages
		a list of CCUpdateBuckets with public API
 */
@interface CCUpdateManager : NSObject {
	NSMutableArray*	buckets;	
	NSUInteger	count;
}

@property (readonly) NSUInteger count;

/** returns the shared Update Manager */
+(CCUpdateManager *) sharedUpdateManager;

/** purges the update manager.  It releases the retained instance.
 */
+(void) purgeSharedUpdateManager;

/** Schedules a CCNode to get per-frame updates with a given priority.  It is not legal
		to add the same node twice.  Remove it first (cancelUpdateFor:).  This method does
		 not check for performance reasons.
 
		Higher Priority buckets are processed first.  Data structures performance assumes
		a modest number priority buckets at most, though there is no hard limit.  This is
		the expected and general use-case.
 */
-(void) requestUpdatesFor:(CCNode*) aNode Priority:(NSInteger) aPriority;

/** Removes a CCNode from having per-frame udpates
 */
-(void) cancelUpdatesFor:(CCNode*) aNode;

/** 'tick' the update manager.  Causes all CCNodes to get a perFrameUpdate: method
		call in priority bucket order.
 */
-(void) tick:(ccTime) dt;

@end
