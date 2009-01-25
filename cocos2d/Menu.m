/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "Menu.h"
#import "Director.h"

@interface Menu (Private)
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
	CGRect s = [[UIApplication sharedApplication] statusBarFrame];
	if([[Director sharedDirector] landscape])
	    r.size.height -= s.size.width;
	else
	    r.size.height -= s.size.height;
	position = cpv(r.size.width/2, r.size.height/2);

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
//	[self alignItemsVertically];
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

#pragma mark Menu - Events

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint point = [touch locationInView: [touch view]];
	int idx;

	MenuItem *item = [self itemInPoint: point idx:&idx];

	if( item ) {
		[item selected];
		selectedItem = idx;
		return kEventHandled;
	}
	
	return kEventIgnored;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	CGPoint point = [touch locationInView: [touch view]];
	int idx;

	MenuItem *item = [self itemInPoint: point idx:&idx];
	if( item ) {
		[item unselected];
		[item activate];
		return kEventHandled;

	} else if( selectedItem != -1 ) {
		[[children objectAtIndex:selectedItem] unselected];
		selectedItem = -1;
		
		// don't return kEventHandled here, since we are not handling it!
	}
	return kEventIgnored;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
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
			return kEventHandled;
		}

	// "mouse" draged outside the selected button
	} else {
		if( selectedItem != -1 ) {
			[[children objectAtIndex:selectedItem] unselected];
			selectedItem = -1;
			
			// don't return kEventHandled here, since we are not handling it!
		}
	}
	
	return kEventIgnored;
}

#pragma mark Menu - Alignment
-(void) alignItemsVertically
{
	int height = -5;
	for(MenuItem *item in children)
	    height += [item contentSize].height + 5;

	float y = height / 2;
	for(MenuItem *item in children) {
	    [item setPosition:cpv(0, y - [item contentSize].height / 2)];
	    y -= [item contentSize].height + 5;
	}
}

// XXX: deprecated
-(void) alignItemsVerticallyOld
{
	int incY = [[children objectAtIndex:0] contentSize].height + 5;
	int initialY =  (incY * [children count])/2;
	
	for( MenuItem* item in children ) {
		[item setPosition:cpv(0,initialY)];
		initialY -= incY;
	}
}

-(void) alignItemsHorizontally
{
	
	int width = -5;
	for(MenuItem* item in children)
	    width += [item contentSize].width + 5;

	int x = -width / 2;
	for(MenuItem* item in children) {
		[item setPosition:cpv(x + [item contentSize].width / 2, 0)];
		x += [item contentSize].width + 5;
	}
}

#pragma mark Menu - Opacity Protocol

/** Override synthesized setOpacity to recurse items */
- (void) setOpacity:(GLubyte)newOpacity
{
	opacity = newOpacity;
	for(id<CocosNodeOpacity> item in children)
		[item setOpacity:opacity];
}

#pragma mark Menu - Private

-(id) itemInPoint: (CGPoint) point idx:(int*)idx
{
	point = [[Director sharedDirector] convertCoordinate: point];
	
	int i=0;
	for( MenuItem* item in children ) {
		*idx = i;
		CGRect r = [item rect];
		
		cpVect offset = [self absolutePosition];		
		r.origin.x += offset.x;
		r.origin.y += offset.y;
		if( CGRectContainsPoint( r, point ) )
			return item;
		i++;
	}
	return nil;
}



@end
