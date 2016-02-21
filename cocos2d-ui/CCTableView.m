/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
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
 */

#import "CCTableView.h"
#import "CCButton.h"
#import "CCDirector.h"
#import "CGPointExtension.h"
#import <objc/message.h>

#pragma mark Helper classes

@interface CCTableView (Helper)
- (void) updateVisibleRows;
- (void) markVisibleRowsDirty;
- (void) selectedRow:(NSUInteger) row;
@end

@interface CCTableViewCellHolder : NSObject

@property (nonatomic,strong) id<CCTableViewCellProtocol> cell;

@end

@implementation CCTableViewCellHolder
@end


@interface CCTableViewContentNode : CCNode
@end

@implementation CCTableViewContentNode

- (void) setPosition:(CGPoint)position
{
    [super setPosition:position];
    
    CCTableView* tableView = (CCTableView*)self.parent;
    [tableView markVisibleRowsDirty];
    [tableView updateVisibleRows];
}

@end


#pragma mark CCTableViewCell

@interface CCTableViewCell (Helper)

@end


@implementation CCTableViewCell

@synthesize index;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    _button = [CCButton buttonWithTitle:NULL];
    _button.contentSizeType = CCSizeTypeNormalized;
    _button.preferredSize = CGSizeMake(1, 1);
    _button.anchorPoint = ccp(0, 0);
    _button.zoomWhenHighlighted = NO;
    [_button setTarget:self selector:@selector(pressedCell:)];
    [self addChild:_button z:-1];
    
    return self;
}

- (void) pressedCell:(id)sender
{
    [(CCTableView*)(self.parent.parent) selectedRow:self.index];
}

@end


#pragma mark CCTableView

@implementation CCTableView

- (id) init
{
    self = [super init];
    if (!self) return self;
    
    self.contentNode = [CCTableViewContentNode node];
    
    self.contentNode.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
    
    _rowHeightUnit = CCSizeUnitPoints;
    _rowHeight = 32;
    self.horizontalScrollEnabled = NO;
    
    _visibleRowsDirty = YES;
    
    return self;
}

/*
- (id) initWithContentNode:(CCNode *)contentNode
{
    NSAssert(NO, @"Constructor is not supported in CCTableView");
    return NULL;
}*/

- (NSRange) visibleRangeForScrollPosition:(CGFloat) scrollPosition
{
    CGFloat positionScale = [CCDirector sharedDirector].UIScaleFactor;
    
    if ([_dataSource respondsToSelector:@selector(tableView:heightForRowAtIndex:)])
    {
        // Rows may have different heights
        
        NSUInteger startRow = 0;
        CGFloat currentRowPos = 0;
        
        NSUInteger numRows = [_dataSource tableViewNumberOfRows:self];
        
        // Find start row
        for (NSUInteger currentRow = 0; currentRow < numRows; currentRow++)
        {
            // Increase row position
            CGFloat rowHeight = [_dataSource tableView:self heightForRowAtIndex:currentRow];
            if (_rowHeightUnit == CCSizeUnitUIPoints) rowHeight *= positionScale;
            currentRowPos += rowHeight;
            
            // Check if we are within visible range
            if (currentRowPos >= scrollPosition)
            {
                startRow = currentRow;
                break;
            }
        }
        
        // Find end row
        NSUInteger numVisibleRows = 1;
        CGFloat tableHeight = self.contentSizeInPoints.height;
        for (NSUInteger currentRow = startRow; currentRow < numRows; currentRow++)
        {
            // Check if we are out of visible range
            if (currentRowPos > scrollPosition + tableHeight)
            {
                break;
            }
            
            // Increase row position
            CGFloat rowHeight = [_dataSource tableView:self heightForRowAtIndex:currentRow + 1];
            if (_rowHeightUnit == CCSizeUnitUIPoints) rowHeight *= positionScale;
            currentRowPos += rowHeight;
            
            numVisibleRows ++;
        }
        
        // Handle potential edge case
        if ((startRow + numVisibleRows) > numRows) numVisibleRows -= 1;
        
        return NSMakeRange(startRow, numVisibleRows);
    }
    else
    {
        // All rows have the same height
        NSUInteger totalNumRows = [_dataSource tableViewNumberOfRows:self];
        
        NSUInteger startRow = clampf(floorf(scrollPosition/self.rowHeightInPoints), 0, totalNumRows -1);
        NSUInteger numVisibleRows = floorf( self.contentSizeInPoints.height / self.rowHeightInPoints) + 2;
        
        // Make sure we are in range
        if (startRow + numVisibleRows >= totalNumRows)
        {
            numVisibleRows = totalNumRows - startRow;
        }
        
        return NSMakeRange(startRow, numVisibleRows);
    }
}

- (CGFloat) locationForCellWithIndex:(NSUInteger)idx
{
    if (!_dataSource) return 0;
    
    CGFloat location = 0;
    
    if ([_dataSource respondsToSelector:@selector(tableView:heightForRowAtIndex:)])
    {
        for (NSUInteger i = 0; i < idx; i++)
        {
            location += [_dataSource tableView:self heightForRowAtIndex:i];
        }
    }
    else
    {
        location = idx * _rowHeight;
    }
    
    if (_rowHeightUnit == CCSizeUnitUIPoints)
    {
        location *= [CCDirector sharedDirector].UIScaleFactor;
    }
    
    return location;
}

- (void) showRowsForRange:(NSRange)range
{
    if (NSEqualRanges(range, _currentlyVisibleRange)) return;
    
    for (NSUInteger oldIdx = _currentlyVisibleRange.location; oldIdx < NSMaxRange(_currentlyVisibleRange); oldIdx++)
    {
        if (!NSLocationInRange(oldIdx, range))
        {
            CCTableViewCellHolder* holder = [_rows objectAtIndex:oldIdx];
            if (holder)
            {
                [self.contentNode removeChild:(CCNode*)holder.cell cleanup:YES];
                holder.cell = NULL;
            }
        }
    }
    
    for (NSUInteger newIdx = range.location; newIdx < NSMaxRange(range); newIdx++)
    {
        if (!NSLocationInRange(newIdx, _currentlyVisibleRange))
        {
            CCTableViewCellHolder* holder = [_rows objectAtIndex:newIdx];
            CCNode* node;
            if (!holder.cell)
            {
                holder.cell = [_dataSource tableView:self nodeForRowAtIndex:newIdx];
                holder.cell.index = newIdx;
                
                node = (CCNode*)holder.cell;
                node.position = CGPointMake(0, [self locationForCellWithIndex:newIdx]);
                node.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
                node.anchorPoint = CGPointMake(0, 1);
            } else {
                node = (CCNode*)holder.cell;
            }
            
            if (holder.cell)
            {
                [self.contentNode addChild:node];
            }
        }
    }
    
    _currentlyVisibleRange = range;
}

- (void) markVisibleRowsDirty
{
    _visibleRowsDirty = YES;
}

- (void) updateVisibleRows
{
    if (_visibleRowsDirty)
    {
        [self showRowsForRange:[self visibleRangeForScrollPosition:-self.contentNode.position.y]];
        _visibleRowsDirty = NO;
    }
}

- (void) reloadData
{
    _currentlyVisibleRange = NSMakeRange(0, 0);
    
    [self.contentNode removeAllChildrenWithCleanup:YES];
    
    if (!_dataSource) return;
    
    // Resize the content node
    NSUInteger numRows = [_dataSource tableViewNumberOfRows:self];
    CGFloat layerHeight = 0;
    
    if (_dataSourceFlags.heightForRowAtIndex)
    {
        for (int i = 0; i < numRows; i++)
        {
            layerHeight += [_dataSource tableView:self heightForRowAtIndex:i];
        }
    }
    else
    {
        layerHeight = numRows * _rowHeight;
    }
    
    self.contentNode.contentSize = CGSizeMake(1, layerHeight);
    self.contentNode.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, _rowHeightUnit);
    
    // Create empty placeholders for all rows
    _rows = [NSMutableArray arrayWithCapacity:numRows];
    for (int i = 0; i < numRows; i++)
    {
        [_rows addObject:[[CCTableViewCellHolder alloc] init]];
    }
    
    // Update scroll position
    self.scrollPosition = self.scrollPosition;
    
    [self markVisibleRowsDirty];
    [self updateVisibleRows];
}

- (void) setDataSource:(id<CCTableViewDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSourceFlags.heightForRowAtIndex = [dataSource respondsToSelector:@selector(tableView:heightForRowAtIndex:)];
        _dataSource = dataSource;
        [self reloadData];
    }
}

- (CGFloat) rowHeightInPoints
{
    if (_rowHeightUnit == CCSizeUnitPoints) return _rowHeight;
    else if (_rowHeightUnit == CCSizeUnitUIPoints)
        return _rowHeight * [CCDirector sharedDirector].UIScaleFactor;
    else
    {
        NSAssert(NO, @"Only point and scaled units are supported for row height");
        return 0;
    }
}

- (void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    [self updateVisibleRows];
    [super visit:renderer parentTransform:parentTransform];
}

- (void) setRowHeight:(CGFloat)rowHeight
{
    if (_rowHeight != rowHeight)
    {
        _rowHeight = rowHeight;
        [self reloadData];        
    }
}

- (void) setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    [self markVisibleRowsDirty];
}

- (void) setContentSizeType:(CCSizeType)contentSizeType
{
    [super setContentSizeType:contentSizeType];
    [self markVisibleRowsDirty];
}

- (void) onEnter
{
    [super onEnter];
    [self markVisibleRowsDirty];
}

#pragma mark Action handling

- (void) setTarget:(id)target selector:(SEL)selector
{
    __weak id weakTarget = target; // avoid retain cycle
    [self setBlock:^(id sender) {
        typedef void (*Func)(id, SEL, id);
        ((Func)objc_msgSend)(weakTarget, selector, sender);
	}];
}

- (void) selectedRow:(NSUInteger)row
{
    self.selectedRow = row;
    [self triggerAction];
}

- (void) triggerAction
{
    if (self.userInteractionEnabled && _block)
    {
        _block(self);
    }
}

@end
