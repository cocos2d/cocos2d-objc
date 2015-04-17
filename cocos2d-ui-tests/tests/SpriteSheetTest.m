//
//  CCSprite9SliceTest.m
//  cocos2d-ui-tests-ios
//
//  Created by Viktor on 10/23/13.
//  Copyright (c) 2013 Cocos2d. All rights reserved.
//

#import "TestBase.h"

@interface SpriteSheetTest : TestBase @end
@implementation SpriteSheetTest

-(void)onEnter
{
    self.scene.color = [CCColor grayColor];
    
    [super onEnter];
}

- (void) setupHelper:(NSString *)sheet
{
    self.subTitle = sheet;
    
    {
        CCSprite *sprite = [CCSprite spriteWithImageNamed:[sheet stringByAppendingPathComponent:@"100x150.png"]];
        sprite.anchorPoint = CGPointZero;
        sprite.position = ccp(4, 58);
        
        [self.contentNode addChild:sprite];
    }{
        CCSprite *sprite = [CCSprite spriteWithImageNamed:[sheet stringByAppendingPathComponent:@"100x200-2.png"]];
        sprite.anchorPoint = CGPointZero;
        sprite.position = ccp(108, 58);
        
        [self.contentNode addChild:sprite];
    }{
        CCSprite *sprite = [CCSprite spriteWithImageNamed:[sheet stringByAppendingPathComponent:@"200x50-2.png"]];
        sprite.anchorPoint = CGPointZero;
        sprite.position = ccp(4, 4);
        
        [self.contentNode addChild:sprite];
    }{
        CCSprite *sprite = [CCSprite spriteWithImageNamed:[sheet stringByAppendingPathComponent:@"200x150.png"]];
        sprite.anchorPoint = CGPointZero;
        sprite.position = ccp(212, 4);
        
        [self.contentNode addChild:sprite];
    }{
        CCSprite *sprite = [CCSprite spriteWithImageNamed:[sheet stringByAppendingPathComponent:@"200x200.png"]];
        sprite.anchorPoint = CGPointZero;
        sprite.position = ccp(212, 158);
        
        [self.contentNode addChild:sprite];
    }{
        CCTexture *atlas = [CCSpriteFrame frameWithImageNamed:[sheet stringByAppendingPathComponent:@"200x200.png"]].texture;
        CCSprite *sprite = [CCSprite spriteWithTexture:atlas];
        sprite.anchorPoint = CGPointZero;
        sprite.position = ccp(4, 250);
        sprite.scale = 0.125;
        
        [self.contentNode addChild:sprite];
        
        NSString *text = [NSString stringWithFormat:@"Atlas size:\n(%dx%d)", (int)atlas.sizeInPixels.width, (int)atlas.sizeInPixels.height];
        CCLabelTTF *label = [CCLabelTTF labelWithString:text fontName:nil fontSize:12];
        label.position = ccp(150, 300);
        label.color = [CCColor blackColor];
        
        [self.contentNode addChild:label];
    }
}

- (void) setupTexturePackerPNGTest
{
    [self setupHelper:@"SpriteSheets/TexturePacker-PNG"];
}

- (void) setupZWoptexTest
{
    [self setupHelper:@"SpriteSheets/Zwoptex"];
}

- (void) setupTexturePackerPVRTest
{
    [self setupHelper:@"SpriteSheets/TexturePacker-PVR"];
}

@end
