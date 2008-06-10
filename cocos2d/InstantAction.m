//
//  InstantAction.m
//  cocos2d
//


#import "InstantAction.h"
#import "CocosNode.h"

//
// InstantAction
//
@implementation InstantAction
@synthesize duration;

-(id) init
{
	if( ![super init] )
		return nil;
	
	duration = 0;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	InstantAction *copy = [[[self class] allocWithZone: zone] init];
	return copy;
}

- (BOOL) isDone
{
	return YES;
}
-(void) step
{
	[self update: 1];
}
-(void) update: (double) t
{
	// ignore
}
@end

//
// Show
//
@implementation Show
-(void) start
{
	[super start];
	target.visible = YES;
}
@end

//
// Hide
//
@implementation Hide
-(void) start
{
	[super start];
	target.visible = NO;
}
@end

//
// ToggleVisibility
//
@implementation ToggleVisibility
-(void) start
{
	[super start];
	target.visible = ! target.visible;
}
@end

//
// Place
//
@implementation Place
+(id) actionWithPosition: (CGPoint) pos
{
	return [[[self alloc]initWithPosition:pos]autorelease];
}

-(id) initWithPosition: (CGPoint) pos
{
	if( ! [super init] )
		return nil;
	position = pos;
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	InstantAction *copy = [[[self class] allocWithZone: zone] initWithPosition: position];
	return copy;
}

-(void) start
{
	[super start];
	target.position = position;
}
@end

//
// CallFunc
//
@implementation CallFunc
+(id) actionWithTarget: (id) receiver selector:(SEL) cb
{
	return [[[self alloc] initWithTarget: receiver selector: cb] autorelease];
}

-(id) initWithTarget: (id) rec selector:(SEL) cb
{
	NSMethodSignature * sig = nil;
	sig = [[rec class] instanceMethodSignatureForSelector:cb];

	invocation = nil;
	invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:rec];
	[invocation setSelector:cb];
	[invocation retain];
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	InstantAction *copy = [[[self class] allocWithZone: zone] initWithTarget: [invocation target] selector: [invocation selector]];
	return copy;
}

-(void) dealloc
{
	if( invocation )
		[invocation release];
	[super dealloc];
}

-(void) start
{
	[super start];
	[invocation invoke];
}
@end