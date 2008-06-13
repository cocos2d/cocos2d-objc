//
//  MenuItem.m
//  cocos2d
//

#import "MenuItem.h"
#import "Label.h"
#import "IntervalAction.h"

@implementation MenuItem

-(id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"MenuItemInit"
								reason:@"Init not supported. Use InitFromString"
								userInfo:nil];
	@throw myException;	
}

+(id) itemFromString: (NSString*) value receiver:(id) r selector:(SEL) s
{
	return [[[self alloc] initFromString: value receiver:r selector:s] autorelease];
}

-(id) initFromString: (NSString*) value receiver:(id) rec selector:(SEL) cb
{
	if(! [super init])
		return nil;

	NSMethodSignature * sig = nil;
	sig = [[rec class] instanceMethodSignatureForSelector:cb];
	
	invocation = nil;
	invocation = [NSInvocation invocationWithMethodSignature:sig];
	[invocation setTarget:rec];
	[invocation setSelector:cb];
	[invocation retain];
	
	label = [Label labelWithString:value dimensions:CGSizeMake(kItemSize*[value length], kItemSize) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize:kItemSize];
	[label retain];

	return self;
}

-(void) dealloc
{
	[invocation release];
	[label release];
	[super dealloc];
}

-(CGRect) rect
{
	CGSize s = [[label texture] contentSize];
	
	CGRect r = CGRectMake( position.x - s.width/2, position.y-s.height/2, s.width, s.height);
	return r;
}

-(void) selected
{
	[self stop];
	[self do: [ScaleTo actionWithDuration:0.2 scale:1.5]];
}

-(void) unselected
{
	[self stop];
	[self do: [ScaleTo actionWithDuration:0.2 scale:1.0]];

}

-(void) activate
{
	[invocation invoke];
}

-(unsigned int) height
{
	return [[label texture] contentSize].height;
}
-(void) draw
{
	[label draw];
}
@end


