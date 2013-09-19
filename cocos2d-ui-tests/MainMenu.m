//
//  MainMenu.m
//  cocos2d-ui-tests-osx
//
//  Created by Viktor on 9/16/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "MainMenu.h"
#import "TestBase.h"

#define kCCTestMenuItemHeight 32

@implementation MainMenu

- (NSArray*) testClassNames
{
    return [NSArray arrayWithObjects:
            @"CCScrollViewTest",
            @"TestButton1",
            @"TestButton2",
            @"TestButton3",
            @"TestButton4",
            @"TestButton5",
            @"TestButton6",
            @"TestButton7",
            @"TestButton8",
            @"TestButton9",
            @"TestButton10",
            @"TestButton11",
            @"TestButton12",
            @"TestButton13",
            @"TestButton14",
            @"TestButton15",
            @"TestButton16",
            @"TestButton17",
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
    
    // Setup a scroll view containing menu with tests
    
    NSArray* testClassNames = [self testClassNames];
    
    // Create the content layer, make it fill the width of the scroll view and each menu item have a height of 32 px * positionScaleFactor
    CCNode* contentNode = [CCNode node];
    contentNode.contentSizeType = CCContentSizeTypeMake(kCCContentSizeUnitNormalized, kCCContentSizeUnitScaled);
    contentNode.contentSize = CGSizeMake(1, testClassNames.count * kCCTestMenuItemHeight);
    
    // Add buttons to the scroll view content view
    int num = 0;
    for (NSString* testClassName in testClassNames)
    {
        CCButton* btn = [CCButton buttonWithTitle:testClassName fontName:@"Marker Felt" fontSize:24];
        [contentNode addChild:btn];
        btn.positionType = CCPositionTypeMake(kCCPositionUnitNormalized, kCCPositionUnitScaled, kCCPositionReferenceCornerTopLeft);
        btn.position = ccp(0.5, kCCTestMenuItemHeight * 0.5f + kCCTestMenuItemHeight * num);
        
        [btn setTarget:self selector:@selector(pressedButton:)];
        
        num++;
    }
    
    CCScrollView* scrollView = [[CCScrollView alloc] init];
    scrollView.contentSizeType = kCCContentSizeTypeNormalized;
    scrollView.contentSize = CGSizeMake(1, 1);
    scrollView.flipYCoordinates = YES;
    scrollView.contentNode = contentNode;
    scrollView.horizontalScrollEnabled = NO;
    
    [self addChild:scrollView];
    
    return self;
}

- (void) pressedButton:(id)sender
{
    CCButton* btn = sender;
    
    CCScene* test = [TestBase sceneWithTestName:btn.label.string];
    [[CCDirector sharedDirector] replaceScene:test];
}

@end
