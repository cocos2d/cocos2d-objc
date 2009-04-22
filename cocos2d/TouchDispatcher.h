#import <UIKit/UIKit.h>
#import "Layer.h"
#import "TargetedTouchDelegate.h"

@interface TouchDispatcher : NSObject <TouchEventsDelegate>
{
@private
	NSMutableArray *touchHandlers;
	BOOL dispatchEvents;
}

+ (TouchDispatcher*)sharedDispatcher;

/** When NO, dispatcher is muted. Default YES. */
@property (readwrite, assign) BOOL dispatchEvents;

/** Convenience method. Adds self to the Director's event handlers */
-(void) link;
/** Convenience method. Removes self from the Director's event handlers */
-(void) unlink;

/** Adds a delegate to the list of multi-touch event handlers, with priority 0
 and touch swallowing on. */
-(void) addEventHandler:(id<TargetedTouchDelegate>) delegate;
/** Adds a delegate to the list of multi-touch event handlers.
 If a handler swallows touches, it will be the exclusive owner of the touch(es)
 it claims. Not swallowing allows other handlers to claim and receive updates on
 the same touch. */
-(void) addEventHandler:(id<TargetedTouchDelegate>) delegate
							 priority:(int) priority swallowTouches:(BOOL) swallowTouches;
/** Changes the priority of a previously added event handler. The lower the number,
 the higher the priority */
-(void) setPriority:(int) priority forEventHandler:(id<TargetedTouchDelegate>) delegate;
/** Removes a delegate from the list of multi-touch event handlers. */
-(void) removeEventHandler:(id<TargetedTouchDelegate>) delegate;
/** Removes all multi-touch event handlers. */
-(void) removeAllEventHandlers;

@end
