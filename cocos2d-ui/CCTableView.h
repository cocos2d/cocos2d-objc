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

@interface CCTableViewCell : CCNode
{
    NSUInteger _index;
}

@property (nonatomic,readonly) CCButton* button;

@end

#pragma mark CCTableViewDataSource

@protocol CCTableViewDataSource <NSObject>

- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index;
- (NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView;

@optional

- (float) tableView:(CCTableView*)tableView heightForRowAtIndex:(NSUInteger) index;

@end


#pragma mark CCTableView

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

@property (nonatomic,strong) id <CCTableViewDataSource> dataSource;
@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,assign) CCContentSizeUnit rowHeightUnit;
@property (nonatomic,readonly) CGFloat rowHeightInPoints;
@property (nonatomic,assign) NSUInteger selectedRow;

@property (nonatomic,copy) void(^block)(id sender);
-(void) setTarget:(id)target selector:(SEL)selector;

- (void) reloadData;

@end
