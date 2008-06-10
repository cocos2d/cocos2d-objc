//
//  Action.m
//  cocos2d
//


#import "Action.h"
#import "CocosNode.h"

//
// Action Base Class
//
@implementation Action

@synthesize target;

+(id) action
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if( ![super init] )
		return nil;
	
	target = nil;
	return self;
}

-(void) dealloc
{
	NSLog(@"deallocing %@", self);
	if( target )
		[target release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	Action *copy = [[[self class] allocWithZone: zone] init];
					 	
    [copy setTarget:[self target]];
    return copy;
}

-(void) start
{
	// override me
}

-(void) stop
{
	// override me
}

-(BOOL) isDone
{
	return YES;
}

-(void) step
{
	NSLog(@"[Action step]. override me");
}

-(void) update: (double) time
{
	NSLog(@"[Action update]. override me");
}

@end