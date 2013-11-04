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

#import "MainMenu.h"
#import "TestBase.h"
#import "CCTransition.h"

#define kCCTestMenuItemHeight 44

@implementation MainMenu

- (NSArray*) testClassNames
{
    return [NSArray arrayWithObjects:
            @"CCScrollViewTest",
            @"CCTableViewTest",
            @"CCTransitionTest",
            @"CCSprite9SliceTest",
            @"CCTextFieldTest",
            @"CCLayoutTest",
            @"CCSliderTest",
#ifdef __CC_PLATFORM_IOS
            @"CCResponderTest",
#endif
            nil];
}

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenu *node = [MainMenu node];
	
	// add layer as a child to scene
	[scene addChild: node];
	
	// return the scene
	return scene;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    // Load resources
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Interface.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] registerSpriteFramesFile:@"Sprites.plist"];
    
    // Make the node the same size as the parent container (i.e. the screen)
    self.contentSizeType = CCContentSizeTypeNormalized;
    self.contentSize = CGSizeMake(1, 1);
    
    // Header background
    CCSprite9Slice* headerBg = [CCSprite9Slice spriteWithImageNamed:@"Interface/header.png"];
    headerBg.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
    headerBg.position = ccp(0,0);
    headerBg.anchorPoint = ccp(0,1);
    headerBg.contentSizeType = CCContentSizeTypeMake(CCContentSizeUnitNormalized, CCContentSizeUnitPoints);
    headerBg.contentSize = CGSizeMake(1, kCCUITestHeaderHeight);
    
    [self addChild:headerBg];
    
    // Header label
    CCLabelTTF* lblTitle = [CCLabelTTF labelWithString:@"Cocos2d Tests" fontName:@"HelveticaNeue-Medium" fontSize:17];
    lblTitle.positionType = CCPositionTypeNormalized;
    lblTitle.position = ccp(0.5, 0.5);
    
    [headerBg addChild:lblTitle];
    
    // Table view
    CCTableView* tableView = [[CCTableView alloc] init];
    tableView.contentSizeType = CCContentSizeTypeMake(CCContentSizeUnitNormalized, CCContentSizeUnitInsetPoints);
    tableView.contentSize = CGSizeMake(1, kCCUITestHeaderHeight);
    tableView.rowHeight = kCCTestMenuItemHeight;
    tableView.dataSource = self;
    
    [self addChild:tableView z:-1];
    
    [tableView setTarget:self selector:@selector(selectedRow:)];
    
    return self;
}

- (void) selectedRow:(id)sender
{
    CCTableView* tableView = sender;
    
    NSString* className = [[self testClassNames] objectAtIndex:tableView.selectedRow];
    
    CCScene* test = [TestBase sceneWithTestName:className];
    CCTransition* transition = [CCTransition transitionMoveInWithDirection:CCTransitionDirectionLeft duration:0.3];
    
    [[CCDirector sharedDirector] replaceScene:test withTransition:transition];
}

- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index
{
    CCTableViewCell* cell = [[CCTableViewCell alloc] init];
    cell.contentSizeType = CCContentSizeTypeMake(CCContentSizeUnitNormalized, CCContentSizeUnitPoints);
    cell.contentSize = CGSizeMake(1, kCCTestMenuItemHeight);
    
    CCSpriteFrame* frameNormal = [CCSpriteFrame frameWithImageNamed:@"Interface/table-bg-normal.png"];
    CCSpriteFrame* frameHilite = [CCSpriteFrame frameWithImageNamed:@"Interface/table-bg-hilite.png"];
    
    [cell.button setBackgroundSpriteFrame:frameNormal forState:CCControlStateNormal];
    [cell.button setBackgroundSpriteFrame:frameHilite forState:CCControlStateHighlighted];
    
    CCLabelTTF* label = [CCLabelTTF labelWithString:[[self testClassNames] objectAtIndex:index] fontName:@"HelveticaNeue" fontSize:17];
    label.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitNormalized, CCPositionReferenceCornerBottomLeft);
    label.position = ccp(20, 0.5f);
    label.anchorPoint = ccp(0, 0.5f);
    
    [cell addChild:label];
    
    return cell;
}

- (NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView
{
    return [self testClassNames].count;
}

@end
