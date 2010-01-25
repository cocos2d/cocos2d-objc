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

#import "CCUpdateManager.h"

#pragma mark -
#pragma mark CCUpdateBucket

@implementation CCUpdateBucket
@synthesize priority;


-(id) initWithPriority:(NSInteger) aPriority {
	
	self = [super init];
	
	priority = aPriority;
	updateRequests = [[NSMutableArray arrayWithCapacity:64] retain];
	
	
	return self;
	
}

- (void) dealloc {
	[updateRequests release];
	[super dealloc];
}

-(void) requestUpdatesFor:(CCNode*) aNode {
	[updateRequests addObject:aNode];
}

-(BOOL) cancelUpdatesFor:(CCNode*) aNode {
	NSUInteger index = [updateRequests indexOfObject:aNode];
	if(index == NSNotFound)
		return NO;
	[updateRequests removeObjectAtIndex:index];
	return YES;
}

-(void) update:(ccTime) dt {
	for(CCNode* n in updateRequests) {
		if(n.isRunning)
			[n perFrameUpdate:dt];
	}
}

@end


#pragma mark -
#pragma mark CCUpdateManager


@implementation CCUpdateManager

@synthesize count;

static CCUpdateManager *sharedUpdateManager;


+(CCUpdateManager *)sharedUpdateManager
{
	@synchronized([CCUpdateManager class])
	{
		if (!sharedUpdateManager)
			sharedUpdateManager = [[CCUpdateManager alloc] init];
		
	}
	// to avoid compiler warning
	return sharedUpdateManager;
}

+(void) purgeSharedUpdateManager {
	@synchronized( self ) {
		[sharedUpdateManager release];
	}	
}

+(id)alloc
{
	@synchronized([CCUpdateManager class])
	{
		NSAssert(sharedUpdateManager == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	// to avoid compiler warning
	return nil;
}

-(id) init {
	self = [super init];
	
	buckets = [[NSMutableArray arrayWithCapacity:128] retain];
	
	count = 0;
	
	return self;
}

-(void) dealloc {
	
	[buckets release];
	
	[super dealloc];
}



-(void) requestUpdatesFor:(CCNode*) aNode Priority:(NSInteger) aPriority {
	
	// The number of buckets will likely be small, so a linear scan is fine
	
	CCUpdateBucket* updateBucket = nil;
	for(CCUpdateBucket* b in buckets) {
		if(b.priority == aPriority) {
			updateBucket = b;
			break;
		}
	}
	
	if(updateBucket == nil) {
		updateBucket = [[[CCUpdateBucket alloc] initWithPriority:aPriority] autorelease];

		// Insertion sort
		NSUInteger insertAt = 0;
		for(CCUpdateBucket* b in buckets) {
			if(b.priority < aPriority)  // Higher priority buckets happen first
				break;
			++insertAt;
		}
		if(insertAt >= [buckets count]) {
			[buckets addObject:updateBucket];
		}
		else {
			[buckets insertObject:updateBucket atIndex:insertAt];
		}
	}
	
	[updateBucket requestUpdatesFor:aNode];
	++count;
	
	
}


-(void) cancelUpdatesFor:(CCNode*) aNode {
	for(CCUpdateBucket* b in buckets) {
		if([b cancelUpdatesFor:aNode]) {
			--count;
			break;
		}
	}
}

-(void) tick:(ccTime) dt {
	if(count > 0) {
		for(CCUpdateBucket* b in buckets) {
			[b update:dt];
		}
	}
}


@end
