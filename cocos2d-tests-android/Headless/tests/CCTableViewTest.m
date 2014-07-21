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

#import "TestBase.h"
#import "cocos2d-ui.h"

@interface CCTableViewTest : TestBase @end

#define kSimpleTableViewRowHeight 24
#define kSimpleTableViewInset 50

@interface SimpleTableViewDataSource : NSObject <CCTableViewDataSource>
@end

@implementation SimpleTableViewDataSource

- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index
{
    CCTableViewCell* cell = [CCTableViewCell node];
    
    cell.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
    cell.contentSize = CGSizeMake(1, kSimpleTableViewRowHeight);
    
    // Color every other row differently
    CCNodeColor* bg;
    if (index % 2 != 0) bg = [CCNodeColor nodeWithColor:[CCColor colorWithRed:1 green:0 blue:0 alpha:0.5]];
    else bg = [CCNodeColor nodeWithColor: [CCColor colorWithRed:0 green:1 blue:0 alpha:0.5]];
    
    bg.userInteractionEnabled = NO;
    bg.contentSizeType = CCSizeTypeNormalized;
    bg.contentSize = CGSizeMake(1, 1);
    [cell addChild:bg];
    
    // Create a label with the row number
    CCLabelTTF* lbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)index] fontName:@"HelveticaNeue" fontSize:18];
    lbl.positionType = CCPositionTypeNormalized;
    lbl.position = ccp(0.5f, 0.5f);
    
    [cell addChild:lbl];
    
    return cell;
}

- (NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView
{
    return 50;
}

//- (float) tableView:(CCTableView*)tableView heightForRowAtIndex:(NSUInteger) index;

@end


@interface MultiplyScaleTableViewDataSource : NSObject <CCTableViewDataSource>
@end

@implementation MultiplyScaleTableViewDataSource

- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index
{
    CCTableViewCell* cell = [CCTableViewCell node];
    
    cell.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitUIPoints);
    cell.contentSize = CGSizeMake(1, kSimpleTableViewRowHeight);
    
    // Color every other row differently
    CCNodeColor* bg;
    if (index % 2 != 0) bg = [CCNodeColor nodeWithColor:[CCColor colorWithRed:1 green:0 blue:0 alpha:0.5]];
    else bg = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0 green:1 blue:0 alpha:0.5]];
    
    bg.userInteractionEnabled = NO;
    bg.contentSizeType = CCSizeTypeNormalized;
    bg.contentSize = CGSizeMake(1, 1);
    [cell addChild:bg];
    
    // Create a label with the row number
    CCLabelTTF* lbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)index] fontName:@"HelveticaNeue" fontSize:18 * [CCDirector sharedDirector].UIScaleFactor];
    lbl.positionType = CCPositionTypeNormalized;
    lbl.position = ccp(0.5f, 0.5f);
    
    [cell addChild:lbl];
    
    return cell;
}

- (NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView
{
    return 50;
}

//- (float) tableView:(CCTableView*)tableView heightForRowAtIndex:(NSUInteger) index;

@end


@interface VariableHeightTableViewDataSource : NSObject <CCTableViewDataSource>
@end

@implementation VariableHeightTableViewDataSource

- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index
{
    CCTableViewCell* cell = [CCTableViewCell node];
    
    cell.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitUIPoints);
    
    // Make every row have a different height
    cell.contentSize = CGSizeMake(1, 5 * index + 15);
    
    // Color every other row differently
    CCNodeColor* bg;
    if (index % 2 != 0) bg = [CCNodeColor nodeWithColor:[CCColor colorWithRed:1 green:0 blue:0 alpha:0.5]];
    else bg = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0 green:1 blue:0 alpha:0.5]];
    
    bg.userInteractionEnabled = NO;
    bg.contentSizeType = CCSizeTypeNormalized;
    bg.contentSize = CGSizeMake(1, 1);
    [cell addChild:bg];
    
    // Create a label with the row number
    CCLabelTTF* lbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)index] fontName:@"HelveticaNeue" fontSize:18 * [CCDirector sharedDirector].UIScaleFactor];
    lbl.positionType = CCPositionTypeNormalized;
    lbl.position = ccp(0.5f, 0.5f);
    
    [cell addChild:lbl];
    
    return cell;
}

- (NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView
{
    return 50;
}

- (float) tableView:(CCTableView*)tableView heightForRowAtIndex:(NSUInteger) index
{
    return 5 * index + 15;
}

@end


@implementation CCTableViewTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupTableViewBasicTest",
            @"setupTableViewMultiplyScaleTest",
            @"setupTableViewVariableHeightTest",
            nil];
}

- (void) setupTableViewBasicTest
{
    self.subTitle = @"Simple table view. Displays a number for each row within box (no clipping).";
    
    // Add a gray background box
    CCNodeColor* colorBg = [CCNodeColor nodeWithColor:[CCColor grayColor]];
    colorBg.contentSizeType = CCSizeTypeMake(CCSizeUnitInsetPoints, CCSizeUnitInsetPoints);
    colorBg.contentSize = CGSizeMake(kSimpleTableViewInset * 2, kSimpleTableViewInset * 2);
    colorBg.userInteractionEnabled = NO;
    colorBg.position = ccp(kSimpleTableViewInset, kSimpleTableViewInset);
    [self.contentNode addChild:colorBg];
    
    // Create the table view and add it to the box
    CCTableView* tableView = [[CCTableView alloc] init];
    tableView.rowHeight = kSimpleTableViewRowHeight;
    [colorBg addChild:tableView];
    
    tableView.dataSource = [[SimpleTableViewDataSource alloc] init];
}

- (void) setupTableViewMultiplyScaleTest
{
    self.subTitle = @"Table rows height multiplied by positionScaleFactor.";
    
    // Add a gray background box
    CCNodeColor* colorBg = [CCNodeColor nodeWithColor:[CCColor grayColor]];
    colorBg.contentSizeType = CCSizeTypeMake(CCSizeUnitInsetPoints, CCSizeUnitInsetPoints);
    colorBg.contentSize = CGSizeMake(kSimpleTableViewInset * 2, kSimpleTableViewInset * 2);
    colorBg.userInteractionEnabled = NO;
    colorBg.position = ccp(kSimpleTableViewInset, kSimpleTableViewInset);
    [self.contentNode addChild:colorBg];
    
    // Create the table view and add it to the box
    CCTableView* tableView = [[CCTableView alloc] init];
    tableView.rowHeightUnit = CCSizeUnitUIPoints;
    tableView.rowHeight = kSimpleTableViewRowHeight;
    [colorBg addChild:tableView];
    
    tableView.dataSource = [[MultiplyScaleTableViewDataSource alloc] init];
}

- (void) setupTableViewVariableHeightTest
{
    self.subTitle = @"Table rows have different (increasing) heights.";
    
    // Add a gray background box
    CCNodeColor* colorBg = [CCNodeColor nodeWithColor:[CCColor grayColor]];
    colorBg.contentSizeType = CCSizeTypeMake(CCSizeUnitInsetPoints, CCSizeUnitInsetPoints);
    colorBg.contentSize = CGSizeMake(kSimpleTableViewInset * 2, kSimpleTableViewInset * 2);
    colorBg.userInteractionEnabled = NO;
    colorBg.position = ccp(kSimpleTableViewInset, kSimpleTableViewInset);
    [self.contentNode addChild:colorBg];
    
    // Create the table view and add it to the box
    CCTableView* tableView = [[CCTableView alloc] init];
    tableView.rowHeightUnit = CCSizeUnitUIPoints;
    tableView.rowHeight = kSimpleTableViewRowHeight;
    [colorBg addChild:tableView];
    
    tableView.dataSource = [[VariableHeightTableViewDataSource alloc] init];
}

@end
