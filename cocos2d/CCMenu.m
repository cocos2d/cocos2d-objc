/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */



#import "CCMenu.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "ccMacros.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#import "Platforms/iOS/CCTouchDispatcher.h"
#elif defined(__CC_PLATFORM_MAC)
#import "Platforms/Mac/CCGLView.h"
#import "Platforms/Mac/CCDirectorMac.h"
#endif

enum {
	kDefaultPadding =  5,
};

#pragma mark - CCMenu

@implementation CCMenu

@synthesize enabled=_enabled;

+(id) menuWithArray:(NSArray *)arrayOfItems
{
	return [[[self alloc] initWithArray:arrayOfItems] autorelease];
}

+(id) menuWithItems: (CCMenuItem*) item, ...
{
	va_list args;
	va_start(args,item);

	id ret = [self menuWithItems:item vaList:args];

	va_end(args);
	
	return ret;
}

+(id) menuWithItems: (CCMenuItem*) item vaList: (va_list) args
{
	NSMutableArray *array = nil;
	if( item ) {
		array = [NSMutableArray arrayWithObject:item];
		CCMenuItem *i = va_arg(args, CCMenuItem*);
		while(i) {
			[array addObject:i];
			i = va_arg(args, CCMenuItem*);
		}
	}
	
	return [[[self alloc] initWithArray:array] autorelease];
}

-(id) init
{
	return [self initWithArray:nil];
}


-(id) initWithArray:(NSArray *)arrayOfItems
{
	if( (self=[super init]) ) {
#ifdef __CC_PLATFORM_IOS
		[self setTouchPriority:kCCMenuHandlerPriority];
		[self setTouchMode:kCCTouchesOneByOne];
		[self setTouchEnabled:YES];

#elif defined(__CC_PLATFORM_MAC)
		[self setMousePriority:kCCMenuHandlerPriority+1];
		[self setMouseEnabled:YES];
		
#endif
		_enabled = YES;
		
		// by default, menu in the center of the screen
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		self.ignoreAnchorPointForPosition = YES;
		_anchorPoint = ccp(0.5f, 0.5f);
		[self setContentSize:s];
		
		// XXX: in v0.7, winSize should return the visible size
		// XXX: so the bar calculation should be done there
#ifdef __CC_PLATFORM_IOS
		CGRect r = [[UIApplication sharedApplication] statusBarFrame];
		s.height -= r.size.height;
#endif
		self.position = ccp(s.width/2, s.height/2);
		
		int z=0;
		
		for( CCMenuItem *item in arrayOfItems) {
			[self addChild: item z:z];
			z++;
		}

//		[self alignItemsVertically];
		
		_selectedItem = nil;
		_state = kCCMenuStateWaiting;
		
		// enable cascade color and opacity on menus
		self.cascadeColorEnabled = YES;
		self.cascadeOpacityEnabled = YES;
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
-(void) addChild:(CCMenuItem*)child z:(NSInteger)z tag:(NSInteger) aTag
{
	NSAssert( [child isKindOfClass:[CCMenuItem class]], @"Menu only supports MenuItem objects as children");
	[super addChild:child z:z tag:aTag];
}

- (void) onExit
{
	if(_state == kCCMenuStateTrackingTouch)
	{
		[_selectedItem unselected];
		_state = kCCMenuStateWaiting;
		_selectedItem = nil;
	}
	[super onExit];
}

#pragma mark Menu - Events

-(void) setHandlerPriority:(NSInteger)newPriority
{
#ifdef __CC_PLATFORM_IOS
	CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
	[dispatcher setPriority:newPriority forDelegate:self];

#elif defined(__CC_PLATFORM_MAC)
	CCEventDispatcher *dispatcher = [[CCDirector sharedDirector] eventDispatcher];
	[dispatcher removeMouseDelegate:self];
	[dispatcher addMouseDelegate:self priority:newPriority];
#endif
}

#pragma mark Menu - Events Touches

#ifdef __CC_PLATFORM_IOS

-(CCMenuItem *) itemForTouch: (UITouch *) touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];

	CCMenuItem* item;
	CCARRAY_FOREACH(_children, item){
		// ignore invisible and disabled items: issue #779, #866
		if ( [item visible] && [item isEnabled] ) {

			CGPoint local = [item convertToNodeSpace:touchLocation];
			CGRect r = [item activeArea];

			if( CGRectContainsPoint( r, local ) )
				return item;
		}
	}
	return nil;
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( _state != kCCMenuStateWaiting || !_visible || ! _enabled)
		return NO;

	for( CCNode *c = self.parent; c != nil; c = c.parent )
		if( c.visible == NO )
			return NO;

	_selectedItem = [self itemForTouch:touch];
	[_selectedItem selected];

	if( _selectedItem ) {
		_state = kCCMenuStateTrackingTouch;
		return YES;
	}
	return NO;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(_state == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");

	[_selectedItem unselected];
	[_selectedItem activate];

	_state = kCCMenuStateWaiting;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(_state == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");

	[_selectedItem unselected];

	_state = kCCMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(_state == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");

	CCMenuItem *currentItem = [self itemForTouch:touch];

	if (currentItem != _selectedItem) {
		[_selectedItem unselected];
		_selectedItem = currentItem;
		[_selectedItem selected];
	}
}

#pragma mark Menu - Events Mouse

#elif defined(__CC_PLATFORM_MAC)

-(CCMenuItem *) itemForMouseEvent: (NSEvent *) event
{
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];

	CCMenuItem* item;
	CCARRAY_FOREACH(_children, item){
		// ignore invisible and disabled items: issue #779, #866
		if ( [item visible] && [item isEnabled] ) {

			CGPoint local = [item convertToNodeSpace:location];

			CGRect r = [item activeArea];

			if( CGRectContainsPoint( r, local ) )
				return item;
		}
	}
	return nil;
}

-(BOOL) ccMouseUp:(NSEvent *)event
{
	if( ! _visible || ! _enabled)
		return NO;

	if(_state == kCCMenuStateTrackingTouch) {
		if( _selectedItem ) {
			[_selectedItem unselected];
			[_selectedItem activate];
		}
		_state = kCCMenuStateWaiting;

		return YES;
	}
	return NO;
}

-(BOOL) ccMouseDown:(NSEvent *)event
{
	if( ! _visible || ! _enabled)
		return NO;

	_selectedItem = [self itemForMouseEvent:event];
	[_selectedItem selected];

	if( _selectedItem ) {
		_state = kCCMenuStateTrackingTouch;
		return YES;
	}

	return NO;
}

-(BOOL) ccMouseDragged:(NSEvent *)event
{
	if( ! _visible || ! _enabled)
		return NO;

	if(_state == kCCMenuStateTrackingTouch) {
		CCMenuItem *currentItem = [self itemForMouseEvent:event];

		if (currentItem != _selectedItem) {
			[_selectedItem unselected];
			_selectedItem = currentItem;
			[_selectedItem selected];
		}

		return YES;
	}
	return NO;
}

#endif // Mac Mouse support

#pragma mark Menu - Alignment
-(void) alignItemsVertically
{
	[self alignItemsVerticallyWithPadding:kDefaultPadding];
}
-(void) alignItemsVerticallyWithPadding:(float)padding
{
	float height = -padding;

	CCMenuItem *item;
	CCARRAY_FOREACH(_children, item)
	    height += item.contentSize.height * item.scaleY + padding;

	float y = height / 2.0f;

	CCARRAY_FOREACH(_children, item) {
		CGSize itemSize = item.contentSize;
	    [item setPosition:ccp(0, y - itemSize.height * item.scaleY / 2.0f)];
	    y -= itemSize.height * item.scaleY + padding;
	}
}

-(void) alignItemsHorizontally
{
	[self alignItemsHorizontallyWithPadding:kDefaultPadding];
}

-(void) alignItemsHorizontallyWithPadding:(float)padding
{

	float width = -padding;
	CCMenuItem *item;
	CCARRAY_FOREACH(_children, item)
	    width += item.contentSize.width * item.scaleX + padding;

	float x = -width / 2.0f;

	CCARRAY_FOREACH(_children, item){
		CGSize itemSize = item.contentSize;
		[item setPosition:ccp(x + itemSize.width * item.scaleX / 2.0f, 0)];
		x += itemSize.width * item.scaleX + padding;
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

	[self alignItemsInColumnsWithArray:rows];
	
	[rows release];
}

-(void) alignItemsInColumnsWithArray:(NSArray*) rows
{	
	int height = -5;
    NSUInteger row = 0, rowHeight = 0, columnsOccupied = 0, rowColumns;
	CCMenuItem *item;
	CCARRAY_FOREACH(_children, item){
		NSAssert( row < [rows count], @"Too many menu items for the amount of rows/columns.");
		
		rowColumns = [(NSNumber *) [rows objectAtIndex:row] unsignedIntegerValue];
		NSAssert( rowColumns, @"Can't have zero columns on a row");
		
		rowHeight = fmaxf(rowHeight, item.contentSize.height);
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
	CCARRAY_FOREACH(_children, item) {
		if(rowColumns == 0) {
			rowColumns = [(NSNumber *) [rows objectAtIndex:row] unsignedIntegerValue];
			w = winSize.width / (1 + rowColumns);
			x = w;
		}
		
		CGSize itemSize = item.contentSize;
		rowHeight = fmaxf(rowHeight, itemSize.height);
		[item setPosition:ccp(x - winSize.width / 2,
							  y - itemSize.height / 2)];
		
		x += w;
		++columnsOccupied;
		
		if(columnsOccupied >= rowColumns) {
			y -= rowHeight + 5;
			
			columnsOccupied = 0;
			rowColumns = 0;
			rowHeight = 0;
			++row;
		}
	}
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

	[self alignItemsInRowsWithArray:columns];
	
	[columns release];
}

-(void) alignItemsInRowsWithArray:(NSArray*) columns
{
	NSMutableArray *columnWidths = [[NSMutableArray alloc] init];
	NSMutableArray *columnHeights = [[NSMutableArray alloc] init];
	
	int width = -10, columnHeight = -5;
	NSUInteger column = 0, columnWidth = 0, rowsOccupied = 0, columnRows;
	CCMenuItem *item;
	CCARRAY_FOREACH(_children, item){
		NSAssert( column < [columns count], @"Too many menu items for the amount of rows/columns.");
		
		columnRows = [(NSNumber *) [columns objectAtIndex:column] unsignedIntegerValue];
		NSAssert( columnRows, @"Can't have zero rows on a column");
		
		CGSize itemSize = item.contentSize;
		columnWidth = fmaxf(columnWidth, itemSize.width);
		columnHeight += itemSize.height + 5;
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
	
	CCARRAY_FOREACH(_children, item){
		if(columnRows == 0) {
			columnRows = [(NSNumber *) [columns objectAtIndex:column] unsignedIntegerValue];
			y = ([(NSNumber *) [columnHeights objectAtIndex:column] intValue] + winSize.height) / 2;
		}
		
		CGSize itemSize = item.contentSize;
		columnWidth = fmaxf(columnWidth, itemSize.width);
		[item setPosition:ccp(x + [(NSNumber *) [columnWidths objectAtIndex:column] unsignedIntegerValue] / 2,
							  y - winSize.height / 2)];
		
		y -= itemSize.height + 10;
		++rowsOccupied;
		
		if(rowsOccupied >= columnRows) {
			x += columnWidth + 5;
			
			rowsOccupied = 0;
			columnRows = 0;
			columnWidth = 0;
			++column;
		}
	}

	[columnWidths release];
	[columnHeights release];
}
@end
