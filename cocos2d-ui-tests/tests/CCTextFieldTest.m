//
//  CCTextFieldTest.m
//  cocos2d-ui-tests-osx
//
//  Created by Viktor on 10/23/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "CCTextField.h"

@interface CCTextFieldTest : TestBase @end

@implementation CCTextFieldTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupTextFieldBasicTest",
            nil];
}

- (void) setupTextFieldBasicTest
{
    self.subTitle = @"Tests text fields.";
    
    CCSpriteFrame* bg = [CCSpriteFrame frameWithImageNamed:@"Tests/textfield-bg.png"];
    CCTextField* textField = [[CCTextField alloc] initWithSpriteFrame:bg];
    
    textField.preferredSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
    textField.preferredSize = CGSizeMake(0.5, 36);
    textField.positionType = CCPositionTypeNormalized;
    textField.position = ccp(0.5f, 0.5f);
    textField.padding = 6;
    textField.anchorPoint = ccp(0.5f, 0.5f);
    textField.string = @"Hello!";
    
    [textField setTarget:self selector:@selector(pressedEnter:)];
    
    [self.contentNode addChild:textField];
}

- (void) pressedEnter:(id)sender
{
    CCTextField* textField = sender;
    
    NSLog(@"Finished editing: %@", textField.string);
}

@end
