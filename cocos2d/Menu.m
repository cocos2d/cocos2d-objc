/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
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

enum {
	kDefaultPadding =  5,
};

@interface Menu (Private)
// returns touched menu item, if any
-(MenuItem *) itemForTouch: (UITouch *) touch idx: (int*) idx;
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
	CGSize s = [[Director sharedDirector] winSize];
	
	// XXX: in v0.7, winSize should return the visible size
	// XXX: so the bar calculation should be done there
	CGRect r = [[UIApplication sharedApplication] statusBarFrame];
	if([[Director sharedDirector] landscape])
		s.height -= r.size.width;
	else
	    s.height -= r.size.height;
	position = CGPointMake(s.width/2, s.height/2);

	isTouchEnabled = YES;
	selectedItem = -1;
	
	int z=0;
	
	if (item) {
		[self addChild: item z:z];
		MenuItem *i = va_arg(args, MenuItem*);
		while(i) {
			z++;
			[self addChild: i z:z];
			i = va_arg(args, MenuItem*);
		}
	}
//	[self alignItemsVertically];
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

/*
 * override add:
 */
-(id) addChild:(MenuItem*)child z:(int)z tag:(int) aTag
{
	NSAssert( [child isKindOfClass:[MenuItem class]], @"Menu only supports MenuItem objects as children");
	return [super addChild:child z:z tag:aTag];
}

#pragma mark Menu - Events

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];	
	int idx;
	MenuItem *item = [self itemForTouch:touch idx:&idx];

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
	int idx;
	MenuItem *item = [self itemForTouch:touch idx:&idx];
	
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
	int idx;
	MenuItem *item = [self itemForTouch:touch idx:&idx];
	
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
	return [self alignItemsVerticallyWithPadding:kDefaultPadding];
}
-(void) alignItemsVerticallyWithPadding:(float)padding
{
	float height = -padding;
	for(MenuItem *item in children)
	    height += [item contentSize].height + padding;

	float y = height / 2.0f;
	for(MenuItem *item in children) {
	    [item setPosition:CGPointMake(0, y - [item contentSize].height / 2.0f)];
	    y -= [item contentSize].height + padding;
	}
}

-(void) alignItemsHorizontally
{
	return [self alignItemsHorizontallyWithPadding:kDefaultPadding];
}

-(void) alignItemsHorizontallyWithPadding:(float)padding
{
	
	float width = -padding;
	for(MenuItem* item in children)
	    width += [item contentSize].width + padding;

	float x = -width / 2.0f;
	for(MenuItem* item in children) {
		[item setPosition:CGPointMake(x + [item contentSize].width / 2.0f, 0)];
		x += [item contentSize].width + padding;
	}
}

-(void) alignItemsInColumns: (NSNumber *) columns, ...
{
	va_list args;
	va_start(args, columns);
	
	[self alignItemsInColumns:columns vaList:args];
	
	va_end(args);
}

-(void) alignItemsInColumns: (NSNumber *) columns vaList: (va_list) args
{
    NSMutableArray *rows = [[NSMutableArray alloc] initWithObjects:columns, nil];
	columns = va_arg(args, NSNumber*);
	while(columns) {
        [rows addObject:columns];
		columns = va_arg(args, NSNumber*);
	}
    
	int height = -5;
    NSUInteger row = 0, rowHeight = 0, columnsOccupied = 0, rowColumns;
	for(MenuItem *item in children) {
        if(row >= [rows count])
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Too many menu items for the amount of rows/columns."
                                         userInfo:nil];
        
        rowColumns = [(NSNumber *) [rows objectAtIndex:row] unsignedIntegerValue];
        if(rowColumns == 0)
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"Can't have zero columns on a row (row %d).", row]
                                         userInfo:nil];
        
        rowHeight = fmaxf(rowHeight, [item contentSize].height);
        ++columnsOccupied;
        
        if(columnsOccupied >= rowColumns) {
            height += rowHeight + 5;
            
            columnsOccupied = 0;
            rowHeight = 0;
            ++row;
        }
    }
    if(columnsOccupied != 0)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Too many rows/columns for available menu items."
                                     userInfo:nil];

    CGSize winSize = [[Director sharedDirector] winSize];
    
    row = 0; rowHeight = 0; rowColumns = 0;
	float w, x, y = height / 2;
	for(MenuItem *item in children) {
        if(rowColumns == 0) {
            rowColumns = [(NSNumber *) [rows objectAtIndex:row] unsignedIntegerValue];
            w = winSize.width / (1 + rowColumns);
            x = w;
        }

        rowHeight = fmaxf(rowHeight, [item contentSize].height);
        [item setPosition:CGPointMake(x - winSize.width / 2,
                              y - [item contentSize].height / 2)];
            
        x += w + 10;
        ++columnsOccupied;
        
        if(columnsOccupied >= rowColumns) {
            y -= rowHeight + 5;
            
            columnsOccupied = 0;
            rowColumns = 0;
            rowHeight = 0;
            ++row;
        }
	}
    
    [rows release];
}

-(void) alignItemsInRows: (NSNumber *) rows, ...
{
	va_list args;
	va_start(args, rows);
	
	[self alignItemsInRows:rows vaList:args];
	
	va_end(args);
}

-(void) alignItemsInRows: (NSNumber *) rows vaList: (va_list) args
{
    NSMutableArray *columns = [[NSMutableArray alloc] initWithObjects:rows, nil];
	rows = va_arg(args, NSNumber*);
	while(rows) {
        [columns addObject:rows];
		rows = va_arg(args, NSNumber*);
	}

    NSMutableArray *columnWidths = [[NSMutableArray alloc] init];
    NSMutableArray *columnHeights = [[NSMutableArray alloc] init];
    
	int width = -10, columnHeight = -5;
    NSUInteger column = 0, columnWidth = 0, rowsOccupied = 0, columnRows;
	for(MenuItem *item in children) {
        if(column >= [columns count])
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Too many menu items for the amount of rows/columns."
                                         userInfo:nil];
        
        columnRows = [(NSNumber *) [columns objectAtIndex:column] unsignedIntegerValue];
        if(columnRows == 0)
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"Can't have zero rows on a column (column %d).", column]
                                         userInfo:nil];
        
        columnWidth = fmaxf(columnWidth, [item contentSize].width);
        columnHeight += [item contentSize].height + 5;
        ++rowsOccupied;
        
        if(rowsOccupied >= columnRows) {
            [columnWidths addObject:[NSNumber numberWithUnsignedInteger:columnWidth]];
            [columnHeights addObject:[NSNumber numberWithUnsignedInteger:columnHeight]];
            width += columnWidth + 10;
            
            rowsOccupied = 0;
            columnWidth = 0;
            columnHeight = -5;
            ++column;
        }
    }
    if(rowsOccupied != 0)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Too many rows/columns for available menu items."
                                     userInfo:nil];
    
    CGSize winSize = [[Director sharedDirector] winSize];
    
    column = 0; columnWidth = 0; columnRows = 0;
	float x = -width / 2, y;
	for(MenuItem *item in children) {
        if(columnRows == 0) {
            columnRows = [(NSNumber *) [columns objectAtIndex:column] unsignedIntegerValue];
            y = ([(NSNumber *) [columnHeights objectAtIndex:column] intValue] + winSize.height) / 2;
        }
        
        columnWidth = fmaxf(columnWidth, [item contentSize].width);
        [item setPosition:CGPointMake(x + [(NSNumber *) [columnWidths objectAtIndex:column] unsignedIntegerValue] / 2,
                              y - winSize.height / 2)];
        
        y -= [item contentSize].height + 10;
        ++rowsOccupied;
        
        if(rowsOccupied >= columnRows) {
            x += columnWidth + 5;
            
            rowsOccupied = 0;
            columnRows = 0;
            columnWidth = 0;
            ++column;
        }
	}
    
    [columns release];
    [columnWidths release];
    [columnHeights release];
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

-(MenuItem *) itemForTouch: (UITouch *) touch idx: (int*) idx;
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[Director sharedDirector] convertCoordinate: touchLocation];
	
	int i=0;
	for( MenuItem* item in children ) {
		CGPoint local = [item convertToNodeSpace:touchLocation];

		CGRect r = [item rect];
		r.origin = CGPointZero;
		
		if( CGRectContainsPoint( r, local ) ) {
			*idx = i;
			return item;
		}
		
		i++;
	}
	return nil;
}



@end
