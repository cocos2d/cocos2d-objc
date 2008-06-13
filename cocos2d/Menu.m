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
	selectedItem = -1;
	
	int z=0;
	
	[self add: item z:z];
	MenuItem *i = va_arg(args, MenuItem*);
	while(i) {
		z++;
		[self add: i z:z];
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
	CGPoint point = [touch locationInView: [touch view]];
	int idx;

	MenuItem *item = [self itemInPoint: point idx:&idx];

	if( item ) {
		[item selected];
		selectedItem = idx;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint point = [touch locationInView: [touch view]];
	int idx;

	MenuItem *item = [self itemInPoint: point idx:&idx];
	if( item ) {
		[item unselected];
		[item activate];
	} else if( selectedItem != -1 ) {
		[[[children objectAtIndex:selectedItem] objectAtIndex:1] unselected];
		selectedItem = -1;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint point = [touch locationInView: [touch view]];
	int idx;
	
	MenuItem *item = [self itemInPoint: point idx:&idx];
	if( item ) {
		if( idx != selectedItem ) {
			if( selectedItem != -1 )
				[[[children objectAtIndex:selectedItem] objectAtIndex:1] unselected];
			[item selected];
			selectedItem = idx;
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

-(id) itemInPoint: (CGPoint) point idx:(int*)idx
{
	point = [[Director sharedDirector] convertCoordinate: point];

	int i=0;
	for( NSArray* array in children ) {
		*idx = i;
		MenuItem *item = [array objectAtIndex:1];
		if( CGRectContainsPoint( [item rect], point ) )
			return item;
		i++;
	}
	return nil;
}
@end
