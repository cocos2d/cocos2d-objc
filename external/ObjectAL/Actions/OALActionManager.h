//
//  OALActionManager.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-09-18.
//
//  Copyright (c) 2009 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Attribution is not required, but appreciated :)
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "OALAction.h"
#import "ObjectALConfig.h"

/* This object is only available if OBJECTAL_CFG_USE_COCOS2D_ACTIONS is enabled in ObjectALConfig.h.
 */
#if !OBJECTAL_CFG_USE_COCOS2D_ACTIONS


#pragma mark OALActionManager

/**
 * Manages all ObjectAL actions.
 */
@interface OALActionManager : NSObject
{
	/** All targets that have actions running on them (id). */
	NSMutableArray* targets;
	
	/** Parallel array to "targets", maintaining a list of all actions per target (NSMutableArray*) */
	NSMutableArray* targetActions;
	
	/** All actions that are to be added on the next pass (OALAction*) */
	NSMutableArray* actionsToAdd;
	
	/** All actions that are to be removed on the next pass (OALAction*) */
	NSMutableArray* actionsToRemove;
	
	/** The timer which we use to update the actions. */
	NSTimer* stepTimer;
	
	/** The last time that was recorded. */
	uint64_t lastTimestamp;
}


#pragma mark Object Management

/** Singleton implementation providing "sharedInstance" and "purgeSharedInstance" methods.
 *
 * <b>- (OALAudioSupport*) sharedInstance</b>: Get the shared singleton instance. <br>
 * <b>- (void) purgeSharedInstance</b>: Purge (deallocate) the shared instance.
 */
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(OALActionManager);


#pragma mark Action Management

/** Stops ALL running actions on ALL targets.
 */
- (void) stopAllActions;


#pragma mark Internal Use

/** \cond */
/** (INTERNAL USE) Used by OALAction to announce that it is starting.
 *
 * @param action The action that is starting.
 */
- (void) notifyActionStarted:(OALAction*) action;

/** (INTERNAL USE) Used by OALAction to announce that it is stopping.
 *
 * @param action The action that is stopping.
 */
- (void) notifyActionStopped:(OALAction*) action;
/** \endcond */

@end

#endif /* OBJECTAL_CFG_USE_COCOS2D_ACTIONS */
