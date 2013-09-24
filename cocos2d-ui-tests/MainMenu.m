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

#define kCCTestMenuItemHeight 32

@implementation MainMenu

- (NSArray*) testClassNames
{
    return [NSArray arrayWithObjects:
            @"CCScrollViewTest",
            @"CCTableViewTest",
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
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Interface.plist"];
    
    // Make the node the same size as the parent container (i.e. the screen)
    self.contentSizeType = kCCContentSizeTypeNormalized;
    self.contentSize = CGSizeMake(1, 1);
    
    // Header background
    CCSprite9Slice* headerBg = [CCSprite9Slice spriteWithSpriteFrameName:@"Interface/header.png"];
    headerBg.positionType = CCPositionTypeMake(kCCPositionUnitPoints, kCCPositionUnitPoints, kCCPositionReferenceCornerTopLeft);
    headerBg.position = ccp(0,0);
    headerBg.anchorPoint = ccp(0,1);
    headerBg.contentSizeType = CCContentSizeTypeMake(kCCContentSizeUnitNormalized, kCCContentSizeUnitPoints);
    headerBg.contentSize = CGSizeMake(1, kCCUITestHeaderHeight);
    
    [self addChild:headerBg];
    
    // Header label
    CCLabelTTF* lblTitle = [CCLabelTTF labelWithString:@"Cocos2d-UI Tests" fontName:@"HelveticaNeue-Medium" fontSize:17];
    lblTitle.positionType = kCCPositionTypeNormalized;
    lblTitle.position = ccp(0.5, 0.5);
    
    [headerBg addChild:lblTitle];
    
    // Setup a scroll view containing menu with tests
    
    NSArray* testClassNames = [self testClassNames];
    
    // Create the content layer, make it fill the width of the scroll view and each menu item have a height of 32 px * positionScaleFactor
    CCNode* contentNode = [CCNode node];
    contentNode.contentSizeType = CCContentSizeTypeMake(kCCContentSizeUnitNormalized, kCCContentSizeUnitPoints);
    contentNode.contentSize = CGSizeMake(1, testClassNames.count * kCCTestMenuItemHeight);
    
    // Add buttons to the scroll view content view
    int num = 0;
    for (NSString* testClassName in testClassNames)
    {
        CCButton* btn = [CCButton buttonWithTitle:testClassName fontName:@"HelveticaNeue-Medium" fontSize:17];
        [contentNode addChild:btn];
        btn.positionType = CCPositionTypeMake(kCCPositionUnitPoints, kCCPositionUnitPoints, kCCPositionReferenceCornerTopLeft);
        btn.anchorPoint = ccp(0, 0.5f);
        btn.position = ccp(20, kCCTestMenuItemHeight * 0.5f + kCCTestMenuItemHeight * num);
        
        [btn setTarget:self selector:@selector(pressedButton:)];
        
        num++;
    }
    
    CCScrollView* scrollView = [[CCScrollView alloc] init];
    scrollView.contentSizeType = CCContentSizeTypeMake(kCCContentSizeUnitNormalized, kCCContentSizeUnitInsetPoints);
    scrollView.contentSize = CGSizeMake(1, kCCUITestHeaderHeight);
    scrollView.flipYCoordinates = YES;
    scrollView.contentNode = contentNode;
    scrollView.horizontalScrollEnabled = NO;
    
    [self addChild:scrollView z:-1];
    
    return self;
}

- (void) pressedButton:(id)sender
{
    CCButton* btn = sender;
    
    CCScene* test = [TestBase sceneWithTestName:btn.label.string];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:test]];
}

@end
