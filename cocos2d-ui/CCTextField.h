//
//  CCTextField.h
//  cocos2d-ios
//
//  Created by Viktor on 10/22/13.
//
//

#import "cocos2d.h"
#import "CCControl.h"

#ifdef __CC_PLATFORM_IOS
@interface CCTextField : CCControl <UITextFieldDelegate>
#elif defined(__CC_PLATFORM_MAC)
@interface CCTextField : CCControl <NSTextFieldDelegate>
#endif
{
#ifdef __CC_PLATFORM_IOS
    BOOL _keyboardIsShown;
    float _keyboardHeight;
#endif
}


- (id) initWithSpriteFrame:(CCSpriteFrame*)frame;

#ifdef __CC_PLATFORM_IOS
@property (nonatomic,readonly) UITextField* textField;
#elif defined(__CC_PLATFORM_MAC)
@property (nonatomic,readonly) NSTextField* textField;
#endif

@property (nonatomic,readonly) CCSprite9Slice* background;
@property (nonatomic,strong) CCSpriteFrame* backgroundSpriteFrame;
@property (nonatomic,assign) float padding;
@property (nonatomic,strong) NSString* string;

@end
