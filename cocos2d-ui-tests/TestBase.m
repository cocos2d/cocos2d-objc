//
//  TestBase.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 9/17/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"

@implementation TestBase

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.contentSizeType = kCCContentSizeTypeNormalized;
    self.contentSize = CGSizeMake(1, 1);
    
    // Create test content
    self.contentNode = [CCNode node];
    self.contentNode.contentSizeType = kCCContentSizeTypeNormalized;
    self.contentNode.contentSize = CGSizeMake(1, 1);
	
    [self addChild:self.contentNode];
    
    // Create interface
    
    // Header background
    CCSprite9Slice* headerBg = [CCSprite9Slice spriteWithSpriteFrameName:@"Interface/header.png"];
    headerBg.positionType = CCPositionTypeMake(kCCPositionUnitPoints, kCCPositionUnitPoints, kCCPositionReferenceCornerTopLeft);
    headerBg.position = ccp(0,0);
    headerBg.anchorPoint = ccp(0,1);
    headerBg.contentSizeType = CCContentSizeTypeMake(kCCContentSizeUnitNormalized, kCCContentSizeUnitPoints);
    headerBg.contentSize = CGSizeMake(1, 44);
    
    [self addChild:headerBg];
    
    // Header label
    _lblTitle = [CCLabelTTF labelWithString:NSStringFromClass([self class]) fontName:@"Helvetica-Bold" fontSize:17];
    _lblTitle.positionType = CCPositionTypeMake(kCCPositionUnitNormalized, kCCPositionUnitPoints, kCCPositionReferenceCornerTopLeft);
    _lblTitle.position = ccp(0.5, 22);
    _lblTitle.shadowColor = ccc4(0, 0, 0, 127);
    _lblTitle.shadowOffset = ccp(0,-1);
    _lblTitle.shadowBlurRadius = 1;
    
    [self addChild:_lblTitle];
    
    // Back button
    CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"Interface/header.png"];
    
    CCButton* btnBack = [CCButton buttonWithTitle:NULL spriteFrame:frame];
    btnBack.positionType = CCPositionTypeMake(kCCPositionUnitPoints, kCCPositionUnitPoints, kCCPositionReferenceCornerTopLeft);
    btnBack.position = ccp(22, 22);
    
    [self addChild:btnBack];
    
    // Prev button
    CCButton* btnPrev = [CCButton buttonWithTitle:NULL spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"Interface/btn-prev.png"]];
    btnPrev.positionType = CCPositionTypeMake(kCCPositionUnitPoints, kCCPositionUnitPoints, kCCPositionReferenceCornerBottomLeft);
    btnPrev.position = ccp(22, 22);
    
    [self addChild:btnPrev];
    
    // Next button
    CCButton* btnNext = [CCButton buttonWithTitle:NULL spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"Interface/btn-next.png"]];
    btnNext.positionType = CCPositionTypeMake(kCCPositionUnitPoints, kCCPositionUnitPoints, kCCPositionReferenceCornerBottomRight);
    btnNext.position = ccp(22, 22);
    
    [self addChild:btnNext];
    
    // Reload button
    CCButton* btnReload = [CCButton buttonWithTitle:NULL spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"Interface/btn-reload.png"]];
    btnReload.positionType = CCPositionTypeMake(kCCPositionUnitNormalized, kCCPositionUnitPoints, kCCPositionReferenceCornerBottomLeft);
    btnReload.position = ccp(0.5, 22);
    
    [self addChild:btnReload];
    
    return self;
}

+ (CCScene *) sceneWithTestName:(NSString*)testName
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
    TestBase *node = [[NSClassFromString(testName) alloc] init];
	
	// add layer as a child to scene
	[scene addChild: node];
    
	// return the scene
	return scene;
}

@end
