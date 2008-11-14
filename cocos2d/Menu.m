/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


#import "Menu.h"
#import "Director.h"

@interface Menu (Private)
// align items
-(void) alignItems;
// if a point in inside an item, in returns the item
-(id) itemInPoint: (CGPoint) p idx:(int*)idx;
@end

@implementation Menu

@synthesize opacity;

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
	if( !(self=[super init]) )
		return nil;
	
	// menu in the center of the screen
	CGRect r = [[Director sharedDirector] winSize];
	position = cpv( r.size.width/2, r.size.height/2);

	isTouchEnabled = YES;
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

/** Override synthesized setOpacity to recurse items */
- (void) setOpacity:(GLubyte)newOpacity
{
	opacity = newOpacity;
	for(id<CocosNodeOpacity> item in children)
		[item setOpacity:opacity];
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
		[[children objectAtIndex:selectedItem] unselected];
		selectedItem = -1;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint point = [touch locationInView: [touch view]];
	int idx;
	
	MenuItem *item = [self itemInPoint: point idx:&idx];
	
	// "mouse" draged inside a button
	if( item ) {
		if( idx != selectedItem ) {
			if( selectedItem != -1 )
				[[children objectAtIndex:selectedItem] unselected];
			[item selected];
			selectedItem = idx;
		}

	// "mouse" draged outside the selected button
	} else {
		if( selectedItem != -1 ) {
			[[children objectAtIndex:selectedItem] unselected];
			selectedItem = -1;
		}
	}
}

-(void) alignItems
{
	int incY = [[children objectAtIndex:0] height] + 5;
	int initialY =  (incY * [children count])/2;
	
	for( MenuItem* item in children ) {
		[item setPosition:cpv(0,initialY)];
		initialY -= incY;
	}
}

-(id) itemInPoint: (CGPoint) point idx:(int*)idx
{
	point = [[Director sharedDirector] convertCoordinate: point];

	int i=0;
	for( MenuItem* item in children ) {
		*idx = i;
		CGRect r = [item rect];
		r.origin.x += position.x;
		r.origin.y += position.y;
		if( CGRectContainsPoint( r, point ) )
			return item;
		i++;
	}
	return nil;
}
@end
