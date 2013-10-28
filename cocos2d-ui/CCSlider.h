//
//  CCSlider.h
//  cocos2d-ios
//
//  Created by Viktor on 10/25/13.
//
//

#import "CCControl.h"
#import "cocos2d.h"

@interface CCSlider : CCControl
{
    NSMutableDictionary* _backgroundSpriteFrames;
    NSMutableDictionary* _handleSpriteFrames;
    
    BOOL _draggingHandle;
    CGPoint _handleStartPos;
    CGPoint _dragStartPos;
    float _dragStartValue;
}

@property (nonatomic,readonly) CCSprite9Slice* background;
@property (nonatomic,readonly) CCSprite* handle;
@property (nonatomic,assign) float sliderValue;

- (id) initWithBackground:(CCSpriteFrame*)background andHandleImage:(CCSpriteFrame*) handle;

- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state;

- (CCSpriteFrame*) backgroundSpriteFrameForState:(CCControlState)state;

- (void) setHandleSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state;

- (CCSpriteFrame*) handleSpriteFrameForState:(CCControlState)state;

@end
