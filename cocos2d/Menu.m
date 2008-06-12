//
//  Menu.m
//  cocos2d
//

#import "Menu.h"
#import "Director.h"

@implementation Menu
// Sets up an array of values to use as the sprite vertices.

- (id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"MenuInit"
								reason:@"Use initWithItems instead"
								userInfo:nil];
	@throw myException;
}

+(id) menuWithItems: (MenuItem*) item, ...
{
	va_list args;
	va_start(args,item);
	
	id s = [[[self alloc] initWithItems: item vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithItems: (MenuItem*) item vaList: (va_list) args
{
	if( ![super init] )
		return nil;

	isEventHandler = YES;
	
	[self add: item];
	MenuItem *i = va_arg(args, MenuItem*);
	while(i) {
		[self add: i];
		i = va_arg(args, MenuItem*);
	}
	[self alignItems];
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint location = [touch locationInView: [touch view]];

	location = [[Director sharedDirector] convertCoordinate: location];
	
	for( NSArray* array in children ) {
		MenuItem *item = [array objectAtIndex:1];
		if( CGRectContainsPoint( [item rect], location ) ) {
			[item activate];
			break;
		}
	}
}

-(void) alignItems
{
	CGRect s = [[Director sharedDirector] winSize];
	int x = s.size.width;
	int y = s.size.height;
	int incY = [[[children objectAtIndex:0] objectAtIndex:1] height] + 5;
	int initialY = (y/2) + (incY * [children count])/2;
	
	for( NSArray* array in children ) {
		MenuItem *item = [array objectAtIndex:1];
		[item setPosition:CGPointMake(x/2, initialY)];
		initialY -= incY;
	}
}
@end
