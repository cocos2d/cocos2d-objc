/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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


#import "CCMenu.h"
#import "CCDirector.h"
#import "CCTouchDispatcher.h"
#import "Support/CGPointExtension.h"

enum {
	kDefaultPadding =  5,
};

@interface CCMenu (Private)
// returns touched menu item, if any
-(CCMenuItem *) itemForTouch: (UITouch *) touch;
@end

@implementation CCMenu

@synthesize opacity=opacity_, color=color_;

- (id) init
{
	NSException* myException = [NSException
								exceptionWithName:@"MenuInit"
								reason:@"Use initWithItems instead"
								userInfo:nil];
	@throw myException;
}

+(id) menuWithItems: (CCMenuItem*) item, ...
{
	va_list args;
	va_start(args,item);
	
	id s = [[[self alloc] initWithItems: item vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithItems: (CCMenuItem*) item vaList: (va_list) args
{
	if( (self=[super init]) ) {

		self.isTouchEnabled = YES;
		
		// menu in the center of the screen
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		self.relativeAnchorPoint = NO;
		anchorPoint_ = ccp(0.5f, 0.5f);
		[self setContentSize:s];
		
		// XXX: in v0.7, winSize should return the visible size
		// XXX: so the bar calculation should be done there
		CGRect r = [[UIApplication sharedApplication] statusBarFrame];
		ccDeviceOrientation orientation = [[CCDirector sharedDirector] deviceOrientation];
		if( orientation == CCDeviceOrientationLandscapeLeft || orientation == CCDeviceOrientationLandscapeRight )
			s.height -= r.size.width;
		else
			s.height -= r.size.height;
		self.position = ccp(s.width/2, s.height/2);

		int z=0;
		
		if (item) {
			[self addChild: item z:z];
			CCMenuItem *i = va_arg(args, CCMenuItem*);
			while(i) {
				z++;
				[self addChild: i z:z];
				i = va_arg(args, CCMenuItem*);
			}
		}
	//	[self alignItemsVertically];
		
		selectedItem = nil;
		state = kMenuStateWaiting;
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

/*
 * override add:
 */
-(id) addChild:(CCMenuItem*)child z:(int)z tag:(int) aTag
{
	NSAssert( [child isKindOfClass:[CCMenuItem class]], @"Menu only supports MenuItem objects as children");
	return [super addChild:child z:z tag:aTag];
}
	
#pragma mark Menu - Events

//- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	UITouch *touch = [touches anyObject];	
//	MenuItem *item = [self itemForTouch:touch];
//	
//	if( item ) {
//		[item selected];
//		selectedItem = item;
//		return kEventHandled;
//	}
//	
//	return kEventIgnored;
//}
//
//- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	UITouch *touch = [touches anyObject];	
//	MenuItem *item = [self itemForTouch:touch];
//	
//	if( item ) {
//		[item unselected];
//		[item activate];
//		return kEventHandled;
//		
//	} else if( selectedItem ) {
//		[selectedItem unselected];
//		selectedItem = nil;
//		
//		// don't return kEventHandled here, since we are not handling it!
//	}
//	return kEventIgnored;
//}
//
//- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	UITouch *touch = [touches anyObject];	
//	MenuItem *item = [self itemForTouch:touch];
//	
//	// "mouse" draged inside a button
//	if( item ) {
//		if( item != selectedItem ) {
//			if( selectedItem  )
//				[selectedItem unselected];
//			[item selected];
//			selectedItem = item;
//			return kEventHandled;
//		}
//		
//		// "mouse" draged outside the selected button
//	} else {
//		if( selectedItem ) {
//			[selectedItem unselected];
//			selectedItem = nil;
//			
//			// don't return kEventHandled here, since we are not handling it!
//		}
//	}
//	
//	return kEventIgnored;
//}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( state != kMenuStateWaiting ) return NO;
	
	selectedItem = [self itemForTouch:touch];
	[selectedItem selected];
	
	if( selectedItem ) {
		state = kMenuStateTrackingTouch;
		return YES;
	}
	return NO;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state == kMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
	
	[selectedItem unselected];
	[selectedItem activate];
	
	state = kMenuStateWaiting;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state == kMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
	
	[selectedItem unselected];
	
	state = kMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state == kMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	CCMenuItem *currentItem = [self itemForTouch:touch];
	
	if (currentItem != selectedItem) {
		[selectedItem unselected];
		selectedItem = currentItem;
		[selectedItem selected];
	}
}

#pragma mark Menu - Alignment
-(void) alignItemsVertically
{
	return [self alignItemsVerticallyWithPadding:kDefaultPadding];
}
-(void) alignItemsVerticallyWithPadding:(float)padding
{
	float height = -padding;
	for(CCMenuItem *item in children)
	    height += [item contentSize].height * item.scaleY + padding;

	float y = height / 2.0f;
	for(CCMenuItem *item in children) {
	    [item setPosition:ccp(0, y - [item contentSize].height * item.scaleY / 2.0f)];
	    y -= [item contentSize].height * item.scaleY + padding;
	}
}

-(void) alignItemsHorizontally
{
	return [self alignItemsHorizontallyWithPadding:kDefaultPadding];
}

-(void) alignItemsHorizontallyWithPadding:(float)padding
{
	
	float width = -padding;
	for(CCMenuItem* item in children)
	    width += [item contentSize].width * item.scaleX + padding;

	float x = -width / 2.0f;
	for(CCMenuItem* item in children) {
		[item setPosition:ccp(x + [item contentSize].width * item.scaleX / 2.0f, 0)];
		x += [item contentSize].width * item.scaleX + padding;
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
	for(CCMenuItem *item in children) {
		NSAssert( row < [rows count], @"Too many menu items for the amount of rows/columns.");
        
        rowColumns = [(NSNumber *) [rows objectAtIndex:row] unsignedIntegerValue];
		NSAssert( rowColumns, @"Can't have zero columns on a row");
        
        rowHeight = fmaxf(rowHeight, [item contentSize].height);
        ++columnsOccupied;
        
        if(columnsOccupied >= rowColumns) {
            height += rowHeight + 5;
            
            columnsOccupied = 0;
            rowHeight = 0;
            ++row;
        }
    }
	NSAssert( !columnsOccupied, @"Too many rows/columns for available menu items." );

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    row = 0; rowHeight = 0; rowColumns = 0;
	float w, x, y = height / 2;
	for(CCMenuItem *item in children) {
        if(rowColumns == 0) {
            rowColumns = [(NSNumber *) [rows objectAtIndex:row] unsignedIntegerValue];
            w = winSize.width / (1 + rowColumns);
            x = w;
        }

        rowHeight = fmaxf(rowHeight, [item contentSize].height);
        [item setPosition:ccp(x - winSize.width / 2,
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
	for(CCMenuItem *item in children) {
		NSAssert( column < [columns count], @"Too many menu items for the amount of rows/columns.");
        
        columnRows = [(NSNumber *) [columns objectAtIndex:column] unsignedIntegerValue];
		NSAssert( columnRows, @"Can't have zero rows on a column");
        
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
	NSAssert( !rowsOccupied, @"Too many rows/columns for available menu items.");
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    column = 0; columnWidth = 0; columnRows = 0;
	float x = -width / 2, y;
	for(CCMenuItem *item in children) {
        if(columnRows == 0) {
            columnRows = [(NSNumber *) [columns objectAtIndex:column] unsignedIntegerValue];
            y = ([(NSNumber *) [columnHeights objectAtIndex:column] intValue] + winSize.height) / 2;
        }
        
        columnWidth = fmaxf(columnWidth, [item contentSize].width);
        [item setPosition:ccp(x + [(NSNumber *) [columnWidths objectAtIndex:column] unsignedIntegerValue] / 2,
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
	opacity_ = newOpacity;
	for(id<CCRGBAProtocol> item in children)
		[item setOpacity:opacity_];
}

-(void) setColor:(ccColor3B)color
{
	color_ = color;
	for(id<CCRGBAProtocol> item in children)
		[item setColor:color_];
}

#pragma mark Menu - Private

-(CCMenuItem *) itemForTouch: (UITouch *) touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	for( CCMenuItem* item in children ) {
		CGPoint local = [item convertToNodeSpace:touchLocation];

		CGRect r = [item rect];
		r.origin = CGPointZero;
		
		if( CGRectContainsPoint( r, local ) )
			return item;
	}
	return nil;
}
@end
