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

@interface CCScrollViewTest : TestBase @end

@implementation CCScrollViewTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupScrollViewBasicTest",
            @"setupScrollViewPagingTest",
            @"setupScrollViewHorizontalTest",
            @"setupScrollViewVerticalTest",
            @"setupScrollViewFlippedYTest",
            @"setupScrollNoBounceTest",
            nil];
}

- (void)setupScrollViewBasicTest
{
    self.subTitle = @"Basic Scrolling - Pan the content layer by dragging it around.";
    
    CCScrollView* scrollView = [[CCScrollView alloc] initWithContentNode:[self createScrollContent]];
    scrollView.flipYCoordinates = NO;
    
    [self.contentNode addChild:scrollView];
}

- (void)setupScrollViewPagingTest
{
    self.subTitle = @"Paging - Pan the content layer it should snap into a 3 x 3 grid.";
    
    CCScrollView* scrollView = [[CCScrollView alloc] initWithContentNode:[self createScrollContent]];
    scrollView.flipYCoordinates = NO;
    scrollView.pagingEnabled = YES;
    
    [self.contentNode addChild:scrollView];
}

- (void)setupScrollViewHorizontalTest
{
    self.subTitle = @"Horizontal Scrolling - Layer should only scroll horizontally.";
    
    CCScrollView* scrollView = [[CCScrollView alloc] initWithContentNode:[self createScrollContent]];
    scrollView.contentSizeType = CCSizeTypeNormalized;
    scrollView.flipYCoordinates = NO;
    scrollView.verticalScrollEnabled = NO;
    
    [self.contentNode addChild:scrollView];
}

- (void)setupScrollViewVerticalTest
{
    self.subTitle = @"Vertical Scrolling - Layer should only scroll vertically.";
    
    CCScrollView* scrollView = [[CCScrollView alloc] initWithContentNode:[self createScrollContent]];
    scrollView.flipYCoordinates = NO;
    scrollView.horizontalScrollEnabled = NO;
    
    [self.contentNode addChild:scrollView];
}

- (void)setupScrollViewFlippedYTest
{
    self.subTitle = @"Flip y coordinates - Layer should start in top-left position.";
    
    CCNode* node = [self createScrollContent];
    
    CCScrollView* scrollView = [[CCScrollView alloc] init];
    scrollView.contentNode = node;
    
    [self.contentNode addChild:scrollView];
}

- (void)setupScrollNoBounceTest
{
    self.subTitle = @"Bounce disabled - Layer cannot be dragged out of bounds.";
    
    CCNode* node = [self createScrollContent];
    
    CCScrollView* scrollView = [[CCScrollView alloc] init];
    scrollView.contentNode = node;
    scrollView.bounces = NO;
    
    [self.contentNode addChild:scrollView];
}


- (CCNode*) createScrollContent
{
    CCDirector* dir = [CCDirector sharedDirector];
    
    CCNode* node = [CCNode node];
    
    float w = 3;
    float h = 3;
    
    // Make it 3 times the width and height of the parents container
    node.contentSizeType = CCSizeTypeNormalized;
    node.contentSize = CGSizeMake(w, h);
    
    BOOL toggle = NO;
    
    for (int x = 0; x < w; x++)
    {
        for (int y = 0; y < h; y++)
        {
            CCLabelTTF* lbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"(%d,%d)",x,y] fontName:@"HelveticaNeue-Light" fontSize:100 * dir.UIScaleFactor];
            lbl.positionType = CCPositionTypeNormalized;
            lbl.position = ccp((x + 0.5f)/w, (y + 0.5f)/h);
            [node addChild:lbl];
            
            // Create checkered patterns
            if (toggle)
            {
                CCNodeColor* layer = [CCNodeColor nodeWithColor:[CCColor grayColor]];
                layer.contentSizeType = CCSizeTypeNormalized;
                layer.contentSize = CGSizeMake(1.0f/w, 1.0f/h);
                //layer.contentSize = CGSizeMake(100, 100);
                
                layer.positionType = CCPositionTypeNormalized;
                layer.position = ccp(x/w, y/h);
                [node addChild:layer z:-1];
            }
            toggle = !toggle;
        }
    }
    
    return node;
}

@end
