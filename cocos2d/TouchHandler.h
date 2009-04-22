#import <UIKit/UIKit.h>
#import "TargetedTouchDelegate.h"

//
// TouchHandler
//
@interface TouchHandler : NSObject {
@private
	id<TargetedTouchDelegate> delegate;
	int priority;
	BOOL swallowsTouches;
	NSMutableSet *claimedTouches;
}

@property(nonatomic, readonly) id<TargetedTouchDelegate> delegate;
@property(nonatomic, readwrite) int priority; // default 0
@property(nonatomic, readwrite) BOOL swallowsTouches; // default NO
@property(nonatomic, readonly) NSMutableSet *claimedTouches;

+ (id)handlerWithDelegate:(id<TargetedTouchDelegate>) aDelegate;
- (id)initWithDelegate:(id<TargetedTouchDelegate>) aDelegate;

@end
