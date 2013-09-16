//
//  MainMenu.m
//  cocos2d-ui-tests-osx
//
//  Created by Viktor on 9/16/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "MainMenu.h"
#import "CCButton.h"

#define kCCTestMenuItemHeight 32

@implementation MainMenu

- (NSArray*) testClassNames
{
    return [NSArray arrayWithObjects:
            @"TestButton",
            nil];
}

+(CCScene *) scene
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
    
    // Make the node the same size as the parent container (i.e. the screen)
    self.contentSizeType = kCCContentSizeTypeNormalized;
    self.contentSize = CGSizeMake(1, 1);
    
    // Setup a scroll view containing menu with tests
    
    NSArray* testClassNames = [self testClassNames];
    
    // Create the content layer, make it fill the width of the scroll view and each menu item have a height of 32 px * positionScaleFactor
    CCNode* contentLayer = [CCNode node];
    contentLayer.contentSizeType = CCContentSizeTypeMake(kCCContentSizeUnitNormalized, kCCContentSizeUnitScaled);
    contentLayer.contentSize = CGSizeMake(1, testClassNames.count * kCCTestMenuItemHeight);
    
    CCButton* btn = [CCButton buttonWithTitle:@"Hello"];
    btn.positionType = kCCPositionTypeNormalized;
    btn.position = ccp(0.5f, 0.5f);
    
    [self addChild:btn];
    
    /*
    // Add buttons to the scroll view content view
    for (NSString* testClassName in testClassNames)
    {
        CCButton* 
    }*/
    
    return self;
}

@end
