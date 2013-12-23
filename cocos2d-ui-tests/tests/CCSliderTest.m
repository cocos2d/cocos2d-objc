//
//  CCSliderTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 10/25/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"
#import "CCSlider.h"

@interface CCSliderTest : TestBase @end

@implementation CCSliderTest

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"setupBasicSliderTest",
            @"setupBasicSliderRotatedTest",
            nil];
}

- (void) setupBasicSliderTest
{
    self.subTitle = @"Tests a slider.";
    
    CCSpriteFrame* background = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background.png"];
    CCSpriteFrame* backgroundHilite = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background-hilite.png"];
    CCSpriteFrame* handle = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-handle.png"];
    
    CCSlider* slider = [[CCSlider alloc] initWithBackground:background andHandleImage:handle];
    [slider setBackgroundSpriteFrame:backgroundHilite forState:CCControlStateHighlighted];
    slider.positionType = CCPositionTypeNormalized;
    slider.position = ccp(0.5f, 0.5f);
    
    slider.preferredSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitUIPoints);
    slider.preferredSize = CGSizeMake(0.5f, 32);
    
    slider.anchorPoint = ccp(0.5f, 0.5f);
    
    [slider setTarget:self selector:@selector(actionCallback:)];
    
    [self.contentNode addChild:slider];
}

- (void) setupBasicSliderRotatedTest
{
    self.subTitle = @"Tests a rotated slider with continuous callbacks.";
    
    CCSpriteFrame* background = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background.png"];
    CCSpriteFrame* backgroundHilite = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-background-hilite.png"];
    CCSpriteFrame* handle = [CCSpriteFrame frameWithImageNamed:@"Tests/slider-handle.png"];
    
    CCSlider* slider = [[CCSlider alloc] initWithBackground:background andHandleImage:handle];
    [slider setBackgroundSpriteFrame:backgroundHilite forState:CCControlStateHighlighted];
    slider.positionType = CCPositionTypeNormalized;
    slider.position = ccp(0.5f, 0.5f);
    
    slider.preferredSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitUIPoints);
    slider.preferredSize = CGSizeMake(0.5f, 32);
    
    slider.anchorPoint = ccp(0.5f, 0.5f);
    slider.rotation = 30;
    
    [slider setTarget:self selector:@selector(actionCallback:)];
    slider.continuous = YES;
    
    [self.contentNode addChild:slider];
}

- (void) actionCallback:(id)sender
{
    CCSlider* slider = sender;
    NSLog(@"Value changed: %f", slider.sliderValue);
}

@end
