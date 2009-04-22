#import "TouchHandler.h"

@implementation TouchHandler

@synthesize delegate, priority, swallowsTouches, claimedTouches;

+ (id)handlerWithDelegate:(id<TargetedTouchDelegate>) aDelegate
{
	return [[[self alloc] initWithDelegate:aDelegate] autorelease];
}

- (id)initWithDelegate:(id<TargetedTouchDelegate>) aDelegate
{
	if ((self = [super init]) == nil)
		return nil;
	
	delegate = [aDelegate retain];
	claimedTouches = [[NSMutableSet alloc] initWithCapacity:2];
	
	return self;
}

- (void)dealloc {
	[delegate release];
	[claimedTouches release];
	[super dealloc];
}

@end
