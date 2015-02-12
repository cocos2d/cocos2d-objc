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

#import "CCScrollView.h"

@class CCButton;
@class CCTableView;

#pragma mark CCTableViewCell

/** Represents a cell in a CCTableView. It is essentially a thin wrapper around CCButton that allows the user to interact with the cell.
 You can add any node(s) as content to the cell. */
@interface CCTableViewCell : CCNode
{
    NSUInteger _index;
}

/** The CCButton instance used to allow interaction with the cell. */
@property (nonatomic,readonly) CCButton* button;

@end

#pragma mark CCTableViewDataSource

/** Protocol for a CCTableView data source. It is similar to but technically incompatible with the
 [UITableViewDataSource](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableViewDataSource_Protocol/index.html) protocol.
 
 For complex table views or such cells which are potentially expensive to create it is recommended that the data source caches the cells after creation, so that when
 tableView:nodeForRowAtIndex: requests a new set of cells the cached cells can be returned rather than creating all cells anew. */
@protocol CCTableViewDataSource <NSObject>

/** Requests a CCTableViewCell for a node at a specific index for the given table view. Should always return a valid cell, ie one created using `[CCTableViewCell node]`
 but it doesn't necessarily have to have any child nodes.
 
 @param tableView The CCTableView that is requesting a cell for the index.
 @param index The index of the cell that is requested.
 @returns The CCTableViewCell for the given index. */
- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index;
/** Requests the number of rows in the given table view.
 @param tableView The CCTableView for which the number of rows should be returned.
 @returns The number of rows in the table view. */
- (NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView;

@optional

/** Requests the height of a row, in points.
 @param tableView The CCTableView requesting with the rows.
 @param index The index of the row.
 @returns The height (in points) of the row at the given index. */
- (float) tableView:(CCTableView*)tableView heightForRowAtIndex:(NSUInteger) index;

@end


#pragma mark CCTableView

/** A vertical table view that resembles (but is technically incompatible to) [UITableView](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/index.html).
 
 A table view consists of one or more rows, where each row is a CCTableViewCell node. The height of each row is the same but the content's height can vary depending on the CCTableViewCell contents.
 It is entirely up to you to adhere to the row height of the table view, or not to (if it makes sense). For instance you could have parts of a preceeding row blend into the next row.
 
 You **must assign a dataSource**, which is any object implementing the CCTableViewDataSource protocol. The data source returns CCTableViewCell instances when requested. The cells make up the table view's content.
 
 A minimal table view with touch input looks like this:
 
 **Objective-C:**
 
    CCTableView* tableView = [CCTableView node];
    tableView.dataSource = self;
    tableView.block = ^(CCTableView* tableView) {
        NSLog(@"Selected cell at index: %i", (int)tableView.selectedRow);
    };
    [self addChild:tableView];

 **Swift:**
 
    let tableView = CCTableView()
    tableView.dataSource = self
    tableView.block = { (tableView) in
        NSLog("Selected cell at index: %i", Int(tableView.selectedRow))
    }
    addChild(tableView)
 
 Of course `self` here needs to implement the CCTableViewDataSource protocol. A simple example implementation of the proctocol with 8 rows and all rows the same height looks like this:
 
 **Objective-C:**
 
    -(CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger)index {
        // use the same seed so that the random colors don't change when scrolling
        srandom(index);
 
        CCSprite* icon = [CCSprite spriteWithImageNamed:@"Settings.png"];
        icon.color = [CCColor colorWithRed:CCRANDOM_0_1() green:CCRANDOM_0_1() blue:CCRANDOM_0_1()];
        icon.anchorPoint = CGPointZero;
 
        CCTableViewCell* cell = [CCTableViewCell node];
        cell.contentSize = icon.contentSize;
        [cell addChild:icon];
 
        _rowHeight = cell.contentSize.height;
        return cell;
    }
 
    -(NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView {
        return 8;
    }
 
    -(float) tableView:(CCTableView*)tableView heightForRowAtIndex:(NSUInteger)index {
        return _rowHeight;
    }
 
 **Swift:**
 
 
 The `_rowHeight` is an ivar of type CGFloat.
 
 Refer to the [CCTableViewTest](https://github.com/cocos2d/cocos2d-swift/blob/develop/cocos2d-ui-tests/tests/CCTableViewTest.m) for a code sample.
 
 @warning Do not add nodes directly to the CCTableView. You must create rows via the CCTableViewDataSource.
 */
@interface CCTableView : CCScrollView
{
    BOOL _visibleRowsDirty;
    NSMutableArray* _rows;
    NSRange _currentlyVisibleRange;
    struct {
        int heightForRowAtIndex:1;
        // reserved for future dataSource delegation
    } _dataSourceFlags;
}

/** @name Working with the Data Source */

/** An object implementing the CCTableViewDataSource protocol. The data source provides the table with cells that make up the table view's content.
 
 @note Assigning a new or different data source immediately calls reloadData.
 */
@property (nonatomic,strong) id <CCTableViewDataSource> dataSource;

/** Removes all cells from memory and requests a new set of cells from the dataSource.
 Assigning a different dataSource and changing the rowHeight will cause reloadData to run.
 
 @warning Depending on which and how many nodes are in the table view and how the dataSource is implemented this operation can be potentially expensive
 as cells are first removed from the table view and requested anew from the dataSource. */
- (void) reloadData;

/** @name Working with Rows */

/** The height of the rows. The unit depends on rowHeightUnit and defaults to points.
 @note Changing the row height calls reloadData. */
@property (nonatomic,assign) CGFloat rowHeight;
/** The size scale type for row Height, one of CCSizeUnit. Defaults to CCSizeUnitPoints (rowHeight is in points). */
@property (nonatomic,assign) CCSizeUnit rowHeightUnit;
/** Returns the rowHeight in points, properly converting the rowHeight value based on rowHeightUnit. */
@property (nonatomic,readonly) CGFloat rowHeightInPoints;
/** The index of the currently selected row. */
@property (nonatomic,assign) NSUInteger selectedRow;

/** @name Running Code when a Cell gets selected */

/** Block that is executed when a row is selected (tapped, clicked).
 
 **Objective-C:**
 
    tableView.block = ^(id sender) {
        NSLog(@"row selected: %i", (int)tableView.selectedRow);
    };
 
 **Swift:**
 
    tableView.block = {(sender: AnyObject!) in
        NSLog("row selected: %i", Int(tableView.selectedRow))
    }
 
 */
@property (nonatomic,copy) void(^block)(id sender);

/** Selector that is executed when a row is selected (tapped, clicked). The selector must take one parameter of type `id` and return void:
 
 **Objective-C:**

    -(void) onRowSelected:(id)sender {
    }
 
 **Swift:**
 
    func onRowSelected(sender: AnyObject!) {
    }
 
 @param target The object that should receive the selector.
 @param selector The selector to run, ie `@selector(onRowSelected:)`. */
-(void) setTarget:(id)target selector:(SEL)selector;

@end
